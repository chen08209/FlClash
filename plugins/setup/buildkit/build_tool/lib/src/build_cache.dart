import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'error.dart';

final _log = Logger('build_cache');

class BuildExecution {
  const BuildExecution({
    required this.primaryOutput,
    required this.rebuilt,
  });

  final String primaryOutput;
  final bool rebuilt;
}

class BuildNotice {
  bool _shown = false;

  void show({required String key, required String reason}) {
    if (_shown) return;
    _shown = true;
    _log.warning('[setup] Rebuilding $key: $reason');
  }
}

class BuildCache {
  BuildCache({required String rootDir})
      : rootDir = p.normalize(p.absolute(rootDir)),
        cacheDir = p.join(
          p.normalize(p.absolute(rootDir)),
          '.dart_tool',
          'setup_build_cache',
          'v1',
        );

  static const int schemaVersion = 1;
  static final Map<String, _AsyncLock> _processLocks = {};

  final String rootDir;
  final String cacheDir;

  Future<BuildExecution> run({
    required String key,
    required Future<String> Function() fingerprint,
    required String primaryOutput,
    required Future<List<String>> Function() build,
    required BuildNotice notice,
    bool force = false,
  }) {
    Directory(cacheDir).createSync(recursive: true);
    final safeKey = key.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final processLock = _processLocks.putIfAbsent(
      p.join(cacheDir, safeKey),
      _AsyncLock.new,
    );
    return processLock.synchronized(
      () => _runWithFileLock(
        key: key,
        safeKey: safeKey,
        fingerprint: fingerprint,
        primaryOutput: primaryOutput,
        build: build,
        notice: notice,
        force: force,
      ),
    );
  }

  Future<BuildExecution> _runWithFileLock({
    required String key,
    required String safeKey,
    required Future<String> Function() fingerprint,
    required String primaryOutput,
    required Future<List<String>> Function() build,
    required BuildNotice notice,
    required bool force,
  }) async {
    final lockFile = File(p.join(cacheDir, '$safeKey.lock'));
    lockFile.createSync(recursive: true);
    final lock = await lockFile.open(mode: FileMode.append);

    try {
      await lock.lock(FileLock.exclusive);
      final currentFingerprint = await fingerprint();
      final recordFile = File(p.join(cacheDir, '$safeKey.json'));
      final missReason = force
          ? 'forced rebuild'
          : _cacheMissReason(
              recordFile: recordFile,
              fingerprint: currentFingerprint,
              primaryOutput: primaryOutput,
            );
      if (missReason == null) {
        return BuildExecution(
          primaryOutput: primaryOutput,
          rebuilt: false,
        );
      }

      notice.show(key: key, reason: missReason);
      final outputs = <String>{primaryOutput, ...await build()}.toList()
        ..sort();
      final metadata = outputs.map(_outputMetadata).toList();
      _writeRecord(
        recordFile: recordFile,
        fingerprint: currentFingerprint,
        outputs: metadata,
      );
      return BuildExecution(
        primaryOutput: primaryOutput,
        rebuilt: true,
      );
    } finally {
      try {
        await lock.unlock();
      } on FileSystemException {
        // The operating system releases the lock when the file is closed.
      }
      await lock.close();
    }
  }

  String? _cacheMissReason({
    required File recordFile,
    required String fingerprint,
    required String primaryOutput,
  }) {
    if (!recordFile.existsSync()) return 'no cached build';

    try {
      final record = jsonDecode(recordFile.readAsStringSync());
      if (record is! Map<String, dynamic>) return 'invalid cache record';
      if (record['schema'] != schemaVersion) return 'cache schema changed';
      if (record['fingerprint'] != fingerprint) return 'build inputs changed';

      final rawOutputs = record['outputs'];
      if (rawOutputs is! List || rawOutputs.isEmpty) {
        return 'cached output list is missing';
      }
      final outputs = rawOutputs
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
      final primaryPath = _storedPath(primaryOutput);
      if (!outputs.any((output) => output['path'] == primaryPath)) {
        return 'primary output is not cached';
      }

      for (final output in outputs) {
        final reason = _validateOutput(output);
        if (reason != null) return reason;
      }
      return null;
    } on FormatException {
      return 'invalid cache record';
    } on FileSystemException {
      return 'cache record is unreadable';
    }
  }

  Map<String, Object> _outputMetadata(String outputPath) {
    final file = File(outputPath);
    if (!file.existsSync()) {
      throw BuildException('Expected build output not found: $outputPath');
    }
    final stat = file.statSync();
    if (stat.type != FileSystemEntityType.file || stat.size <= 0) {
      throw BuildException('Expected non-empty build output: $outputPath');
    }
    return {
      'path': _storedPath(outputPath),
      'size': stat.size,
      'modified': stat.modified.millisecondsSinceEpoch,
    };
  }

  String? _validateOutput(Map<String, dynamic> metadata) {
    final storedPath = metadata['path'];
    final size = metadata['size'];
    final modified = metadata['modified'];
    if (storedPath is! String || size is! int || modified is! int) {
      return 'invalid output metadata';
    }

    final file = File(_resolvedPath(storedPath));
    if (!file.existsSync()) return 'output is missing: $storedPath';
    final stat = file.statSync();
    if (stat.type != FileSystemEntityType.file || stat.size <= 0) {
      return 'output is invalid: $storedPath';
    }
    if (stat.size != size || stat.modified.millisecondsSinceEpoch != modified) {
      return 'output changed: $storedPath';
    }
    return null;
  }

  String _storedPath(String filePath) {
    final absolutePath = p.normalize(p.absolute(filePath));
    if (p.isWithin(rootDir, absolutePath) || p.equals(rootDir, absolutePath)) {
      return p.posix.joinAll(p.split(p.relative(absolutePath, from: rootDir)));
    }
    return absolutePath;
  }

  String _resolvedPath(String storedPath) => p.isAbsolute(storedPath)
      ? storedPath
      : p.joinAll([rootDir, ...p.posix.split(storedPath)]);

  void _writeRecord({
    required File recordFile,
    required String fingerprint,
    required List<Map<String, Object>> outputs,
  }) {
    final temporaryFile = File(
      '${recordFile.path}.$pid.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    temporaryFile.writeAsStringSync(
      jsonEncode({
        'schema': schemaVersion,
        'fingerprint': fingerprint,
        'outputs': outputs,
      }),
      flush: true,
    );
    try {
      temporaryFile.renameSync(recordFile.path);
    } on FileSystemException {
      if (recordFile.existsSync()) recordFile.deleteSync();
      temporaryFile.renameSync(recordFile.path);
    }
  }
}

class _AsyncLock {
  Future<void> _tail = Future<void>.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
