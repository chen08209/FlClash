import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('file_test');
  });

  tearDown(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  group('safeDeletePath', () {
    test('removes a file', () async {
      final path = join(root.path, 'config.yaml');
      File(path).writeAsStringSync('mixed-port: 7890');

      await safeDeletePath(path);

      expect(File(path).existsSync(), isFalse);
    });

    test('removes a directory along with everything under it', () async {
      final path = join(root.path, '42');
      File(join(path, 'proxies', 'abc'))
        ..createSync(recursive: true)
        ..writeAsStringSync('proxies: []');

      await safeDeletePath(path);

      expect(Directory(path).existsSync(), isFalse);
    });

    test('accepts a path that is already gone', () async {
      await expectLater(safeDeletePath(join(root.path, 'missing')), completes);
    });
  });
}
