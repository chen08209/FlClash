import 'dart:io';

import 'package:build_tool/src/fingerprint.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'setup_fingerprint_test_',
    );
  });

  tearDown(() {
    temporaryDirectory.deleteSync(recursive: true);
  });

  String fingerprint({
    required Iterable<String> files,
    Object? target = 'macos-arm64',
  }) {
    final builder = FingerprintBuilder(rootDir: temporaryDirectory.path)
      ..addValue('target', target)
      ..addFiles(files);
    return builder.finish();
  }

  test('uses file content instead of modification time', () {
    final input = File('${temporaryDirectory.path}/input.go')
      ..writeAsStringSync('package main\n');
    final before = fingerprint(files: [input.path]);

    input.setLastModifiedSync(DateTime.now().add(const Duration(hours: 1)));

    expect(fingerprint(files: [input.path]), before);
  });

  test('changes when file content changes', () {
    final input = File('${temporaryDirectory.path}/input.go')
      ..writeAsStringSync('package main\n');
    final before = fingerprint(files: [input.path]);

    input.writeAsStringSync('package core\n');

    expect(fingerprint(files: [input.path]), isNot(before));
  });

  test('changes when an input file is added or removed', () {
    final first = File('${temporaryDirectory.path}/first.go')
      ..writeAsStringSync('package main\n');
    final second = File('${temporaryDirectory.path}/second.go')
      ..writeAsStringSync('package main\n');
    final oneFile = fingerprint(files: [first.path]);
    final twoFiles = fingerprint(files: [first.path, second.path]);

    expect(twoFiles, isNot(oneFile));
    second.deleteSync();
    expect(fingerprint(files: [first.path]), oneFile);
  });

  test('changes when target parameters change', () {
    final input = File('${temporaryDirectory.path}/input.go')
      ..writeAsStringSync('package main\n');

    expect(
      fingerprint(files: [input.path], target: 'android-arm64'),
      isNot(fingerprint(files: [input.path], target: 'android-amd64')),
    );
  });
}
