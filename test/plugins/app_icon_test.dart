import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app_icon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an app is known by its executable, else by its package', () {
    expect(
      appIconIdOf(
        const Metadata(
          process: 'Google Chrome Helper',
          processPath: '/Applications/Google Chrome.app/Contents/MacOS/x',
        ),
      ),
      '/Applications/Google Chrome.app/Contents/MacOS/x',
    );
    expect(appIconIdOf(const Metadata(process: 'com.a')), 'com.a');
    expect(appIconIdOf(const Metadata()), isEmpty);
  });

  group('DesktopAppIconSource', () {
    late List<(String, int, String)> calls;
    late DesktopAppIconSource source;

    setUp(() {
      calls = [];
      source = DesktopAppIconSource(
        cacheDir: Future.value('/cache/app_icons'),
        render: (path, size, cacheDir) async {
          calls.add((path, size, cacheDir));
          return switch (path) {
            '' => '/cache/app_icons/default.png',
            '/usr/bin/curl' => null,
            _ => '/cache/app_icons${path.hashCode}.png',
          };
        },
      );
    });

    test('maps a process path to the rendered file once', () async {
      final icon = await source.getPackageIcon('/Applications/A.app/a');
      await source.getPackageIcon('/Applications/A.app/a');

      expect(icon, isA<FileImage>());
      expect(calls, hasLength(1));
      final (path, size, cacheDir) = calls.single;
      expect(path, '/Applications/A.app/a');
      expect(size, greaterThanOrEqualTo(appIconExtent.ceil()));
      expect(cacheDir, '/cache/app_icons');
      expect(source.getCachedPackageIcon('/Applications/A.app/a'), same(icon));
    });

    test('a process without an icon of its own gets none as its own', () async {
      final generic = await source.getPackageIcon('');

      expect(await source.getPackageIcon('/usr/bin/curl'), same(generic));
      expect(await source.getOwnPackageIcon('/usr/bin/curl'), isNull);
      expect(source.getCachedOwnPackageIcon('/usr/bin/curl')?.icon, isNull);
      expect(
        await source.getOwnPackageIcon('/Applications/A.app/a'),
        isNot(same(generic)),
      );
    });

    test('a failing render falls back without throwing', () async {
      final failing = DesktopAppIconSource(
        cacheDir: Future.value('/cache'),
        render: (_, _, _) => Future.error(const FileSystemException('denied')),
      );

      expect(await failing.getPackageIcon('/x'), isNull);
      expect(await failing.getOwnPackageIcon('/x'), isNull);
    });
  });
}
