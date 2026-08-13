import 'package:fl_clash/common/task.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('resolveArchiveEntryPath', () {
    final root = join(rootPrefix(current), 'restore');

    test('accepts a plain file name', () {
      expect(
        resolveArchiveEntryPath(root, 'config.json'),
        join(root, 'config.json'),
      );
    });

    test('accepts a nested entry', () {
      expect(
        resolveArchiveEntryPath(root, 'profiles/1.yaml'),
        join(root, 'profiles', '1.yaml'),
      );
    });

    test('accepts an entry that stays inside after normalisation', () {
      expect(
        resolveArchiveEntryPath(root, 'profiles/../config.json'),
        join(root, 'config.json'),
      );
    });

    test('rejects a parent traversal', () {
      expect(resolveArchiveEntryPath(root, '../evil'), isNull);
      expect(resolveArchiveEntryPath(root, '../../../../evil'), isNull);
      expect(resolveArchiveEntryPath(root, 'profiles/../../evil'), isNull);
    });

    test('rejects a bare parent reference', () {
      expect(resolveArchiveEntryPath(root, '..'), isNull);
    });

    test('rejects an absolute entry', () {
      expect(resolveArchiveEntryPath(root, '/etc/passwd'), isNull);
    });

    // Not posix-absolute, so it reaches the join as an ordinary segment and
    // yields a path inside the root that Windows cannot create.
    test('rejects a drive-qualified entry', () {
      expect(resolveArchiveEntryPath(root, 'C:/evil.txt'), isNull);
      expect(resolveArchiveEntryPath(root, r'C:\evil.txt'), isNull);
      expect(resolveArchiveEntryPath(root, 'profiles/C:/evil.txt'), isNull);
    });

    test('rejects a UNC entry', () {
      expect(resolveArchiveEntryPath(root, r'\\server\share\evil.txt'), isNull);
    });

    test('rejects backslash traversal', () {
      expect(resolveArchiveEntryPath(root, r'..\evil'), isNull);
      expect(resolveArchiveEntryPath(root, r'profiles\..\..\evil'), isNull);
    });

    test('rejects an empty or current-directory entry', () {
      expect(resolveArchiveEntryPath(root, ''), isNull);
      expect(resolveArchiveEntryPath(root, '.'), isNull);
      expect(resolveArchiveEntryPath(root, './'), isNull);
    });
  });
}
