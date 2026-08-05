import 'dart:io';

import 'package:build_tool/src/error.dart';
import 'package:build_tool/src/util.dart';
import 'package:test/test.dart';

void main() {
  group('calcSha256', () {
    test('returns correct hash for known content', () async {
      final tmp =
          File('${Directory.systemTemp.path}/build_tool_test_sha256.txt');
      tmp.writeAsStringSync('hello');
      try {
        final hash = await calcSha256(tmp.path);
        expect(
          hash,
          '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
        );
      } finally {
        tmp.deleteSync();
      }
    });

    test('throws BuildException for missing file', () async {
      expect(
        calcSha256('/nonexistent/path/file.bin'),
        throwsA(isA<BuildException>()),
      );
    });
  });

  group('writeCoreManifest', () {
    test('writes only the Core SHA256 field', () {
      final directory = Directory.systemTemp.createTempSync(
        'build_tool_manifest_test_',
      );
      final path = '${directory.path}/manifest.json';
      const hash =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      try {
        writeCoreManifest(path: path, coreSha256: hash);

        expect(File(path).readAsStringSync(), '{"coreSha256":"$hash"}\n');
      } finally {
        directory.deleteSync(recursive: true);
      }
    });

    test('replaces an existing manifest', () {
      final directory = Directory.systemTemp.createTempSync(
        'build_tool_manifest_test_',
      );
      final path = '${directory.path}/manifest.json';
      const oldHash =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const newHash =
          'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210';
      try {
        File(path).writeAsStringSync('{"coreSha256":"$oldHash"}\n');

        writeCoreManifest(path: path, coreSha256: newHash);

        expect(File(path).readAsStringSync(), '{"coreSha256":"$newHash"}\n');
      } finally {
        directory.deleteSync(recursive: true);
      }
    });

    test('rejects an invalid Core SHA256', () {
      expect(
        () => writeCoreManifest(path: '/tmp/manifest.json', coreSha256: 'bad'),
        throwsA(isA<BuildException>()),
      );
    });
  });

  group('ensureDir', () {
    test('creates directory recursively', () {
      final tmp = '${Directory.systemTemp.path}/build_tool_test_dir/a/b/c';
      try {
        ensureDir(tmp);
        expect(Directory(tmp).existsSync(), isTrue);
      } finally {
        Directory('${Directory.systemTemp.path}/build_tool_test_dir')
            .deleteSync(recursive: true);
      }
    });
  });

  group('copyFile', () {
    test('copies file to destination', () {
      final src = File('${Directory.systemTemp.path}/build_tool_test_src.txt');
      final dest =
          '${Directory.systemTemp.path}/build_tool_test_dest/sub/file.txt';
      src.writeAsStringSync('content');
      try {
        copyFile(src.path, dest);
        expect(File(dest).existsSync(), isTrue);
        expect(File(dest).readAsStringSync(), 'content');
      } finally {
        src.deleteSync();
        Directory('${Directory.systemTemp.path}/build_tool_test_dest')
            .deleteSync(recursive: true);
      }
    });

    test('throws BuildException for missing source', () {
      expect(
        () => copyFile('/nonexistent/file.txt', '/tmp/out.txt'),
        throwsA(isA<BuildException>()),
      );
    });
  });
}
