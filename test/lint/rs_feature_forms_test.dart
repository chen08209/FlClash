import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/strip_rs_feature.dart';

void main() {
  test('every rsFeature check takes a form the strip tool reads', () {
    final failures = <String>[];
    for (final root in ['lib', 'test']) {
      for (final file in Directory(root).listSync(recursive: true)) {
        final path = file.path;
        if (file is! File ||
            !path.endsWith('.dart') ||
            path.contains('/generated/') ||
            path.endsWith('.g.dart') ||
            path.endsWith('.freezed.dart')) {
          continue;
        }
        final source = file.readAsStringSync();
        if (!mentionsFlag(source)) {
          continue;
        }
        try {
          stripRsFeature(source, path: path);
        } on StripException catch (e) {
          failures.add('$e');
        }
      }
    }
    expect(failures, isEmpty);
  });
}
