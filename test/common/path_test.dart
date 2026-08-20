import 'dart:io';

import 'package:fl_clash/common/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  late Directory tempDir;
  late Directory appDir;
  late Directory supportDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('path_test');
    appDir = Directory('${tempDir.path}/app')..createSync(recursive: true);
    supportDir = Directory('${tempDir.path}/support')
      ..createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(supportDir.path);
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('AppPath portable detection', () {
    test('detects portable mode when config/ exists next to the executable', () async {
      Directory('${appDir.path}/config').createSync();
      AppPath.resetInstanceForTest(appDirPath: appDir.path);
      addTearDown(AppPath.resetInstanceForTest);

      final path = AppPath();
      await path.homeDirPath;

      expect(path.isPortable, isTrue);
      expect(await path.homeDirPath, p.join(appDir.path, 'config'));
      expect(await path.databasePath, p.join(appDir.path, 'config', 'database.sqlite'));
    });

    test('falls back to the application support directory without config/', () async {
      AppPath.resetInstanceForTest(appDirPath: appDir.path);
      addTearDown(AppPath.resetInstanceForTest);

      final path = AppPath();
      await path.homeDirPath;

      expect(path.isPortable, isFalse);
      expect(await path.homeDirPath, supportDir.path);
    });

    test('redirects cache into the portable config dir', () async {
      Directory('${appDir.path}/config').createSync();
      AppPath.resetInstanceForTest(appDirPath: appDir.path);
      addTearDown(AppPath.resetInstanceForTest);

      final path = AppPath();

      expect((await path.cacheDir.future).path, p.join(appDir.path, 'config', '.cache'));
    });

    test('migrates legacy system data into a fresh portable config dir', () async {
      final legacyDir = Directory('${tempDir.path}/legacy')..createSync();
      final configDir = Directory('${appDir.path}/config')..createSync();
      File('${legacyDir.path}/shared_preferences.json').writeAsStringSync(
        '{"version":1}',
      );
      File('${legacyDir.path}/database.sqlite').writeAsBytesSync([1, 2, 3]);
      Directory('${legacyDir.path}/profiles').createSync();
      File('${legacyDir.path}/profiles/default.yaml').writeAsStringSync(
        'mixed-port: 7890',
      );

      AppPath.resetInstanceForTest(
        appDirPath: appDir.path,
        legacyDir: legacyDir,
      );
      addTearDown(AppPath.resetInstanceForTest);

      final path = AppPath();
      await path.homeDirPath;

      expect(
        File('${configDir.path}/shared_preferences.json').existsSync(),
        isTrue,
      );
      expect(File('${configDir.path}/database.sqlite').existsSync(), isTrue);
      expect(
        File('${configDir.path}/profiles/default.yaml').existsSync(),
        isTrue,
      );
    });

    test('migration does not overwrite existing portable data', () async {
      final legacyDir = Directory('${tempDir.path}/legacy')..createSync();
      final configDir = Directory('${appDir.path}/config')..createSync();
      File('${configDir.path}/database.sqlite').writeAsBytesSync([9, 9]);
      File('${legacyDir.path}/database.sqlite').writeAsBytesSync([1, 2, 3]);

      AppPath.resetInstanceForTest(
        appDirPath: appDir.path,
        legacyDir: legacyDir,
      );
      addTearDown(AppPath.resetInstanceForTest);

      final path = AppPath();
      await path.homeDirPath;

      expect(
        File('${configDir.path}/database.sqlite').readAsBytesSync(),
        [9, 9],
      );
    });
  });
}