import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class FingerprintBuilder {
  FingerprintBuilder({required String rootDir})
      : _rootDir = p.normalize(p.absolute(rootDir));

  final String _rootDir;
  final BytesBuilder _bytes = BytesBuilder(copy: false);

  void addValue(String name, Object? value) {
    _addBytes(utf8.encode(name));
    _addBytes(utf8.encode(jsonEncode(value)));
  }

  void addFile(String filePath) {
    final absolutePath = p.normalize(p.absolute(filePath));
    final file = File(absolutePath);
    if (!file.existsSync()) {
      throw FileSystemException('Fingerprint input does not exist', filePath);
    }

    final relativePath =
        p.isWithin(_rootDir, absolutePath) || p.equals(_rootDir, absolutePath)
            ? p.relative(absolutePath, from: _rootDir)
            : absolutePath;
    addValue('file', p.posix.joinAll(p.split(relativePath)));
    _addBytes(file.readAsBytesSync());
  }

  void addFiles(Iterable<String> filePaths) {
    final paths = filePaths.map((path) => p.normalize(p.absolute(path))).toSet()
      ..removeWhere((path) => !File(path).existsSync());
    final sortedPaths = paths.toList()..sort();
    for (final path in sortedPaths) {
      addFile(path);
    }
  }

  String finish() => sha256.convert(_bytes.takeBytes()).toString();

  void _addBytes(List<int> value) {
    final length = ByteData(8)..setUint64(0, value.length, Endian.big);
    _bytes
      ..add(length.buffer.asUint8List())
      ..add(value);
  }
}

List<String> collectFiles(
  String rootDir, {
  bool Function(String relativePath)? include,
  Set<String> excludedDirectories = const {},
}) {
  final root = Directory(rootDir);
  if (!root.existsSync()) return const [];

  final files = <String>[];
  final pending = <Directory>[root];
  while (pending.isNotEmpty) {
    final directory = pending.removeLast();
    final entries = directory.listSync(followLinks: false).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final entity in entries) {
      final relativePath = p.relative(entity.path, from: rootDir);
      if (entity is Directory) {
        if (!excludedDirectories.contains(p.basename(entity.path))) {
          pending.add(entity);
        }
      } else if (entity is File && (include?.call(relativePath) ?? true)) {
        files.add(entity.path);
      }
    }
  }
  files.sort();
  return files;
}

List<String> collectBuildToolInputs(String rootDir) {
  final packageDir = p.join(
    rootDir,
    'plugins',
    'setup',
    'buildkit',
    'build_tool',
  );
  final inputs = collectFiles(p.join(packageDir, 'lib'));
  for (final name in const ['pubspec.yaml', 'pubspec.lock']) {
    final filePath = p.join(packageDir, name);
    if (File(filePath).existsSync()) inputs.add(filePath);
  }
  return inputs;
}
