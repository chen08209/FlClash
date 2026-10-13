import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

const _usage =
    '''
Runs the root package tests from a few generated entrypoints.

usage: dart run tool/test.dart [path ...] [-- flutter test arguments]

Every *_test.dart under the given paths (default: test) is imported into one of
$_bundleCount entrypoints under $_bundleDir, so `flutter test` compiles and
starts $_bundleCount programs rather than one per file. A file carrying a
library-level annotation such as @TestOn runs on its own.

Files in one entrypoint share an isolate. A file that fails there is run again
on its own, and that run decides the result; the files that pass alone are
listed, since they depend on or are broken by state another file left.''';

// Fixed, so a commit groups its files the same way on every machine.
const _bundleCount = 32;
const _bundleDir = '.dart_tool/test_bundles';
const _reportPath = '$_bundleDir/report.json';

final _annotation = RegExp(r'^@(TestOn|Tags|Timeout|Skip|OnPlatform)\b');

// Options of `flutter test` the rerun drops: it only decides pass or fail, and
// would otherwise overwrite the coverage of the whole run.
const _rerunDropsWithValue = {
  '--coverage-path',
  '--coverage-package',
  '--file-reporter',
};
const _rerunDropsFlag = {'--coverage', '--merge-coverage', '--branch-coverage'};

class _Bundle {
  final files = <String>[];
  var size = 0;
}

Future<void> main(List<String> arguments) async {
  final split = arguments.indexOf('--');
  final paths = split < 0 ? arguments : arguments.sublist(0, split);
  final flutterArguments = split < 0
      ? const <String>[]
      : arguments.sublist(split + 1);
  if (paths.contains('-h') || paths.contains('--help')) {
    stdout.writeln(_usage);
    return;
  }

  final files = _collect(paths.isEmpty ? const ['test'] : paths);
  final standalone = files.where(_hasAnnotation).toList();
  final bundles = _writeBundles(
    files.where((file) => !standalone.contains(file)).toList(),
  );
  final setsConcurrency = flutterArguments.any(
    (argument) =>
        argument.startsWith('-j') || argument.startsWith('--concurrency'),
  );
  final reports = !flutterArguments.any(
    (argument) => argument.startsWith('--file-reporter'),
  );

  final code = await _flutterTest([
    if (!setsConcurrency)
      '--concurrency=${min(_bundleCount, Platform.numberOfProcessors)}',
    if (reports) '--file-reporter=json:$_reportPath',
    ...flutterArguments,
    for (final bundle in bundles) bundle.path,
    ...standalone,
  ]);
  if (code == 0 || !reports) exit(code);

  final failed = _failedFiles(bundles);
  if (failed.isEmpty) exit(code);
  stdout.writeln(
    '\n${failed.length} file(s) failed in a shared isolate; '
    'running them on their own:\n${failed.map((f) => '  $f').join('\n')}\n',
  );
  final rerunCode = await _flutterTest([
    ..._rerunArguments(flutterArguments),
    ...failed,
  ]);
  if (rerunCode == 0) {
    stdout.writeln(
      '\nEvery file above passes on its own: each depends on, or is broken by, '
      'state another file in its entrypoint left behind.',
    );
  }
  exit(rerunCode);
}

Future<int> _flutterTest(List<String> arguments) async {
  final process = await Process.start(
    'flutter',
    ['test', ...arguments],
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  return process.exitCode;
}

List<String> _rerunArguments(List<String> arguments) {
  final kept = <String>[];
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    final name = argument.split('=').first;
    if (_rerunDropsFlag.contains(name)) continue;
    if (_rerunDropsWithValue.contains(name)) {
      if (!argument.contains('=')) i++;
      continue;
    }
    kept.add(argument);
  }
  return kept;
}

List<String> _collect(List<String> paths) {
  final files = <String>{};
  for (final path in paths) {
    switch (FileSystemEntity.typeSync(path)) {
      case FileSystemEntityType.directory:
        files.addAll(
          Directory(path)
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => p.normalize(file.path))
              .where((file) => file.endsWith('_test.dart')),
        );
      case FileSystemEntityType.file:
        files.add(p.normalize(path));
      default:
        stderr.writeln('No such test path: $path');
        exit(64);
    }
  }
  if (files.isEmpty) {
    stderr.writeln('No *_test.dart files under ${paths.join(' ')}');
    exit(64);
  }
  return files.toList()..sort();
}

bool _hasAnnotation(String file) {
  for (final line in File(file).readAsLinesSync()) {
    if (_annotation.hasMatch(line)) return true;
    if (line.startsWith('import ') || line.startsWith('void main')) break;
  }
  return false;
}

/// Hands each file, largest first, to the bundle with the least code so far;
/// size stands in for run time.
List<({String path, List<String> files})> _writeBundles(List<String> files) {
  final directory = Directory(_bundleDir);
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);

  final sizes = {for (final file in files) file: File(file).lengthSync()};
  final bundles = List.generate(
    min(_bundleCount, files.length),
    (_) => _Bundle(),
  );
  final bySize = [...files]
    ..sort((a, b) {
      final order = sizes[b]!.compareTo(sizes[a]!);
      return order != 0 ? order : a.compareTo(b);
    });
  for (final file in bySize) {
    final bundle = bundles.reduce((a, b) => b.size < a.size ? b : a);
    bundle.files.add(file);
    bundle.size += sizes[file]!;
  }

  return [
    for (final (index, bundle) in bundles.indexed)
      (
        path: _writeBundle(directory, index, bundle.files..sort()),
        files: bundle.files,
      ),
  ];
}

String _writeBundle(Directory directory, int index, List<String> files) {
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/test.dart.')
    ..writeln("import 'package:flutter_test/flutter_test.dart';");
  for (final (i, file) in files.indexed) {
    buffer.writeln(
      "import '${_posix(p.relative(file, from: directory.path))}' as t$i;",
    );
  }
  buffer
    ..writeln()
    ..writeln('void main() {');
  for (final (i, file) in files.indexed) {
    buffer.writeln("  group('${_posix(file)}', t$i.main);");
  }
  buffer.writeln('}');

  final name = 'bundle_${index.toString().padLeft(2, '0')}_test.dart';
  final path = p.join(directory.path, name);
  File(path).writeAsStringSync(buffer.toString());
  return path;
}

String _posix(String path) => p.posix.joinAll(p.split(path));

/// The files behind every failed test in the JSON report; a bundle that failed
/// to load stands for all of its files.
List<String> _failedFiles(List<({String path, List<String> files})> bundles) {
  final report = File(_reportPath);
  if (!report.existsSync()) return const [];
  final byPath = {
    for (final bundle in bundles) p.canonicalize(bundle.path): bundle.files,
  };
  final suites = <int, String>{};
  final tests = <int, ({int suite, String name})>{};
  final failed = <String>{};
  for (final line in report.readAsLinesSync()) {
    if (!line.startsWith('{')) continue;
    final event = jsonDecode(line) as Map<String, dynamic>;
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        suites[suite['id'] as int] = suite['path'] as String;
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        tests[test['id'] as int] = (
          suite: test['suiteID'] as int,
          name: test['name'] as String,
        );
      case 'testDone' when event['result'] != 'success':
        final test = tests[event['testID'] as int];
        final suite = test == null ? null : suites[test.suite];
        if (test == null || suite == null) continue;
        final files = byPath[p.canonicalize(suite)];
        if (files == null) {
          failed.add(p.relative(suite));
        } else if (test.name.startsWith('loading ')) {
          failed.addAll(files);
        } else {
          failed.addAll(
            files.where((file) => test.name.startsWith('${_posix(file)} ')),
          );
        }
    }
  }
  return failed.toList()..sort();
}
