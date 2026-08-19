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
  });

  group('portable zip packaging', () {
    test('injects an empty config/ entry into a windows zip', () async {
      final tmp = Directory.systemTemp.createTempSync('setup_zip_test');
      addTearDown(() {
        try {
          tmp.deleteSync(recursive: true);
        } catch (_) {}
      });
      final zipPath = '${tmp.path}/FlClash-0.8.96-windows-amd64.zip';
      final archive = Archive()
        ..addFile(ArchiveFile.bytes('FlClash.exe', [1, 2, 3]));
      await File(zipPath).writeAsBytes(ZipEncoder().encode(archive));

      await setup.injectPortableConfigDirIntoZip(zipPath);

      final decoded = ZipDecoder().decodeBytes(
        await File(zipPath).readAsBytes(),
      );
      expect(decoded.find('config/'), isNotNull);
      expect(decoded.find('FlClash.exe'), isNotNull);
    });

    test('does not add a duplicate config/ entry when one already exists', () async {
      final tmp = Directory.systemTemp.createTempSync('setup_zip_test');
      addTearDown(() {
        try {
          tmp.deleteSync(recursive: true);
        } catch (_) {}
      });
      final zipPath = '${tmp.path}/FlClash-0.8.96-windows-amd64.zip';
      final archive = Archive()
        ..addFile(ArchiveFile.directory('config/'))
        ..addFile(ArchiveFile.bytes('FlClash.exe', [1, 2, 3]));
      await File(zipPath).writeAsBytes(ZipEncoder().encode(archive));

      await setup.injectPortableConfigDirIntoZip(zipPath);

      final decoded = ZipDecoder().decodeBytes(
        await File(zipPath).readAsBytes(),
      );
      expect(decoded.where((f) => f.name == 'config/').length, 1);
    });
  });
}
