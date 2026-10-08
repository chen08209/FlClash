import 'dart:io';

import 'package:archive/archive.dart';
import 'package:test/test.dart';

import '../setup.dart' as setup;

void main() {
  group('setup.dart', () {
    test('parses -v as verbose mode', () {
      final results = setup.createSetupArgParser().parse(['android', '-v']);

      expect(results['verbose'], isTrue);
      expect(results.rest, ['android']);
    });

    test('accepts dev application environment', () {
      final results = setup.createSetupArgParser().parse([
        'android',
        '--env',
        'dev',
      ]);

      expect(results['env'], 'dev');
    });

    test('Flutter build environment does not depend on Core SHA256', () {
      expect(setup.createBuildEnvironment('dev'), {'APP_ENV': 'dev'});
    });

    test('omits verbose from flutter build args by default', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        verbose: false,
      );

      expect(args, ['dart-define-from-file=env.json', 'split-per-abi']);
    });

    test('adds verbose to flutter build args with -v', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        verbose: true,
      );

      expect(args, [
        'verbose',
        'dart-define-from-file=env.json',
        'split-per-abi',
      ]);
    });

    test('refuses to package while a native build hook is skipped', () {
      const pubspec = '''
hooks:
  user_defines:
    setup:
      build_assets: false
    rust_api:
      build_assets: true
''';

      expect(setup.packagesNotBuildingAssets(pubspec), ['setup']);
      expect(setup.packagesNotBuildingAssets('name: x\n'), isEmpty);
    });

    test('packages every Linux format on every architecture', () {
      expect(setup.createPackageTargets('linux', null), 'deb,appimage,rpm');
      expect(setup.createPackageTargets('linux', 'deb'), 'deb');
      expect(setup.createPackageTargets('macos', null), 'dmg');
    });

    test('downloads the appimagetool build matching the host', () {
      expect(setup.appImageToolArch('arm64'), 'aarch64');
      expect(setup.appImageToolArch('amd64'), 'x86_64');
    });
  });

  group('portable zip packaging', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('setup_zip_test');
    });

    tearDown(() {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    Future<String> writeZip(List<ArchiveFile> entries) async {
      final zipPath = '${dir.path}/FlClash-windows-amd64.zip';
      final archive = Archive();
      for (final entry in entries) {
        archive.addFile(entry);
      }
      await File(zipPath).writeAsBytes(ZipEncoder().encode(archive));
      return zipPath;
    }

    Archive readZip(String zipPath) =>
        ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    test('injects a config directory into a windows zip', () async {
      final zipPath = await writeZip([
        ArchiveFile.bytes('FlClash.exe', [1, 2, 3]),
      ]);

      await setup.injectPortableDirectoryIntoZip(zipPath);

      final archive = readZip(zipPath);
      expect(archive.find('config/'), isNotNull);
      expect(archive.find('FlClash.exe'), isNotNull);
    });

    test('leaves a zip that already carries the directory alone', () async {
      final zipPath = await writeZip([
        ArchiveFile.directory('config/'),
        ArchiveFile.bytes('FlClash.exe', [1, 2, 3]),
      ]);

      await setup.injectPortableDirectoryIntoZip(zipPath);

      expect(
        readZip(zipPath).where((file) => file.name == 'config/').length,
        1,
      );
    });
  });
}
