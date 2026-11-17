import 'dart:io';

import 'src/strip_rs_feature.dart';

/// Strips the rsFeature checks in place from lib and test, or the given
/// paths, then drops the imports left unused and formats what changed.
Future<void> main(List<String> arguments) async {
  final roots = arguments.isEmpty ? const ['lib', 'test'] : arguments;
  final changed = <String>[];
  for (final file in _dartFiles(roots)) {
    final source = file.readAsStringSync();
    if (!mentionsFlag(source)) {
      continue;
    }
    final String stripped;
    try {
      stripped = stripRsFeature(source, path: file.path);
    } on StripException catch (e) {
      stderr.writeln(e);
      exitCode = 1;
      continue;
    }
    if (stripped != source) {
      file.writeAsStringSync(stripped);
      changed.add(file.path);
    }
  }
  if (exitCode != 0 || changed.isEmpty) {
    return;
  }
  for (final root in roots) {
    await _run('dart', ['fix', '--apply', '--code=unused_import', root]);
  }
  await _run('dart', ['format', ...changed]);
  stdout.writeln('stripped ${changed.length} files');
}

Iterable<File> _dartFiles(List<String> roots) sync* {
  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root);
    if (entity == FileSystemEntityType.file) {
      yield File(root);
      continue;
    }
    for (final file in Directory(root).listSync(recursive: true)) {
      final path = file.path;
      if (file is File &&
          path.endsWith('.dart') &&
          !path.contains('/generated/') &&
          !path.endsWith('.g.dart') &&
          !path.endsWith('.freezed.dart')) {
        yield file;
      }
    }
  }
}

Future<void> _run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    stderr
      ..write(result.stdout)
      ..write(result.stderr);
    exit(result.exitCode);
  }
}
