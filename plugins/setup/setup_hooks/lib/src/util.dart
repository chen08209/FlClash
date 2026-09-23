import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'error.dart';

final _log = Logger('util');

/// Recovers the toolchains that Xcode's and Gradle's stripped PATH would hide.
final String? _toolSearchPath = _resolveToolSearchPath();

String? _resolveToolSearchPath() {
  if (Platform.isWindows) return null;
  final entries = (Platform.environment['PATH'] ?? '').split(':');
  final home = Platform.environment['HOME'];
  final candidates = [
    '/opt/homebrew/bin',
    '/usr/local/bin',
    '/usr/local/go/bin',
    if (home != null && home.isNotEmpty) ...[
      p.join(home, 'go', 'bin'),
      p.join(home, '.cargo', 'bin'),
    ],
  ];
  final missing = candidates
      .where((dir) => !entries.contains(dir) && Directory(dir).existsSync())
      .toList();
  if (missing.isEmpty) return null;
  return [...entries, ...missing].join(':');
}

Map<String, String>? _withToolSearchPath(Map<String, String>? environment) {
  final path = _toolSearchPath;
  if (path == null) return environment;
  return {...?environment, 'PATH': path};
}

ProcessResult runCommand(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
}) {
  _log.finer('Running: $executable ${arguments.join(' ')}');
  if (environment != null && environment.isNotEmpty) {
    _log.finer('  env: $environment');
  }
  final result = Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: _withToolSearchPath(environment),
    includeParentEnvironment: includeParentEnvironment,
    stdoutEncoding: systemEncoding,
    stderrEncoding: systemEncoding,
  );
  final out = (result.stdout as String).trim();
  final err = (result.stderr as String).trim();
  if (out.isNotEmpty) _log.finest(out);
  if (err.isNotEmpty) _log.finest(err);
  if (result.exitCode != 0) {
    throw CommandFailedException(
      executable: executable,
      arguments: arguments,
      exitCode: result.exitCode,
      stdout: out,
      stderr: err,
    );
  }
  return result;
}

Future<void> runCommandStream(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  _log.info('exec: $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: _withToolSearchPath(environment),
    includeParentEnvironment: true,
    runInShell: Platform.isWindows,
  );
  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      if (line.isNotEmpty) _log.info(line);
    },
  );
  process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      if (line.isNotEmpty) _log.warning(line);
    },
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw CommandFailedException(
      executable: executable,
      arguments: arguments,
      exitCode: exitCode,
      stdout: '',
      stderr: '',
    );
  }
}

Future<String> calcSha256(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw BuildException('File not found: $filePath');
  }
  final hash = await sha256.bind(file.openRead()).first;
  return hash.toString();
}

const coreManifestName = 'manifest.json';

void writeCoreManifest({required String path, required String coreSha256}) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(coreSha256)) {
    throw BuildException('Invalid Core SHA256: $coreSha256');
  }

  final manifest = File(path);
  final content = '${jsonEncode({'coreSha256': coreSha256})}\n';
  if (manifest.existsSync() && manifest.readAsStringSync() == content) {
    return;
  }
  ensureDir(manifest.parent.path);
  manifest.writeAsStringSync(content, flush: true);
}

void ensureDir(String dirPath) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

void copyFile(String source, String destination) {
  final src = File(source);
  if (!src.existsSync()) {
    throw BuildException('Source file not found: $source');
  }
  final dest = File(destination);
  ensureDir(dest.parent.path);
  final partial = File('$destination.$pid.tmp');
  src.copySync(partial.path);
  _renameOver(partial, dest);
  _log.fine('Copied $source -> $destination');
}

void replaceFile(String source, String destination) {
  final dest = File(destination);
  ensureDir(dest.parent.path);
  _renameOver(File(source), dest);
}

void _renameOver(File from, File to) {
  try {
    from.renameSync(to.path);
  } on FileSystemException {
    // Windows refuses to rename over an existing file.
    if (to.existsSync()) to.deleteSync();
    from.renameSync(to.path);
  }
}
