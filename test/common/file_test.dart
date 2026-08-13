import 'dart:io';

import 'package:fl_clash/common/file.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('FileExt.safeCopy', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('fl_clash_file_test');
    });

    tearDown(() {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('copies an existing file and reports success', () async {
      final source = File(join(dir.path, 'source.txt'))
        ..writeAsStringSync('payload');
      final targetPath = join(dir.path, 'nested', 'target.txt');

      expect(await source.safeCopy(targetPath), isTrue);
      expect(File(targetPath).readAsStringSync(), 'payload');
    });

    test('overwrites an existing target', () async {
      final source = File(join(dir.path, 'source.txt'))
        ..writeAsStringSync('new');
      final targetPath = join(dir.path, 'target.txt');
      File(targetPath).writeAsStringSync('old');

      expect(await source.safeCopy(targetPath), isTrue);
      expect(File(targetPath).readAsStringSync(), 'new');
    });

    // It used to create the *source* instead, leaving an empty file behind
    // and reporting nothing, so a backup missing a profile restored silently.
    test(
      'reports failure and creates nothing when the source is missing',
      () async {
        final source = File(join(dir.path, 'missing.txt'));
        final targetPath = join(dir.path, 'target.txt');

        expect(await source.safeCopy(targetPath), isFalse);
        expect(source.existsSync(), isFalse);
        expect(File(targetPath).existsSync(), isFalse);
      },
    );
  });
}
