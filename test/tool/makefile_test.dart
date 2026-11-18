import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _makefile = File('Makefile').readAsLinesSync();
final _documented = [
  for (final line in _makefile)
    ?RegExp(r'^([a-z0-9-]+):.*## ').firstMatch(line)?.group(1),
];
final _hasMake =
    !Platform.isWindows &&
    Process.runSync('make', ['--version'], runInShell: true).exitCode == 0;

Set<String> _phony() {
  final joined = _makefile.join('\n').replaceAll('\\\n', ' ');
  final line = joined.split('\n').firstWhere((l) => l.startsWith('.PHONY:'));
  return line.substring('.PHONY:'.length).trim().split(RegExp(r'\s+')).toSet();
}

ProcessResult _make(List<String> arguments) {
  return Process.runSync('make', ['--no-print-directory', ...arguments]);
}

void main() {
  test('every target is phony and carries a ## description', () {
    final defined = {
      for (final line in _makefile)
        ?RegExp(r'^([a-z0-9-]+):').firstMatch(line)?.group(1),
    };

    expect(_documented.toSet(), defined);
    expect(_phony(), defined);
  });

  test('every documented variable is read by a target', () {
    final source = _makefile.join('\n');
    final names = [
      for (final line in _makefile)
        ?RegExp(r'^##> ([A-Z_]+)=').firstMatch(line)?.group(1),
    ];

    expect(names, isNotEmpty);
    for (final name in names) {
      expect(source, contains('\$($name)'), reason: name);
    }
  });

  group('make', () {
    test('help lists the documented targets in order', () {
      final result = _make(['help']);
      final listed = [
        for (final line in (result.stdout as String).split('\n'))
          ?RegExp(r'^  ([a-z0-9-]+) ').firstMatch(line)?.group(1),
      ];

      expect(result.exitCode, 0);
      expect(listed, _documented);
    });

    test('every target expands', () {
      for (final target in _documented) {
        final result = _make(['-n', target]);
        expect(result.exitCode, 0, reason: '$target: ${result.stderr}');
      }
    });

    test('package passes the variables on as packager options', () {
      final result = _make([
        '-n',
        'package-linux',
        'ARCH=arm64',
        'FORM=deb,rpm',
        'DRY=1',
        'APP_ENV=stable',
        'TAG=v1.2.3',
      ]);

      expect(
        (result.stdout as String).trim().split(RegExp(r'\s+')).join(' '),
        'dart tool/package.dart linux --arch arm64 --targets deb,rpm '
        '--dry-run --env stable --tag v1.2.3',
      );
    });

    test('run starts only a safe mode build', () {
      final result = _make(['-n', 'run', 'DEVICE=macos']);

      expect(result.stdout, contains('--dart-define=SAFE_MODE=true'));
      expect(result.stdout, contains('-d macos'));
    });
  }, skip: _hasMake ? false : 'make is not installed');
}
