import 'dart:io';

import 'package:fl_clash/common/macos_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('resolves installed bundles without interpreting shell characters', () {
    const bundle = "/Applications/Someone's FlClash \$(test).app";
    expect(macOSAppBundlePath('$bundle/Contents/MacOS/FlClash'), bundle);
    expect(
      () => macOSAppBundlePath('/usr/bin/FlClash'),
      throwsA(isA<FileSystemException>()),
    );
    expect(
      () => macOSAppBundlePath(
        '/private/var/AppTranslocation/id/d/FlClash.app/Contents/MacOS/FlClash',
      ),
      throwsA(isA<FileSystemException>()),
    );
  });

  group('macOS replacement worker', () {
    late Directory directory;
    late String source;
    late String target;
    late String control;
    late Process owner;

    Future<void> command(String executable, List<String> arguments) async {
      final result = await Process.run(executable, arguments);
      expect(result.exitCode, 0, reason: result.stderr.toString());
    }

    Future<Process> startWorker() async {
      return Process.start('/bin/sh', [
        '-c',
        macOSInstallScript,
        'flclash-update-test',
        source,
        target,
        '${owner.pid}',
        control,
      ]);
    }

    Future<void> waitForReady() async {
      final ready = File(p.join(control, 'ready'));
      for (var i = 0; i < 100 && !await ready.exists(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(await ready.exists(), isTrue);
    }

    Future<void> commitAndExit() async {
      await File(p.join(control, 'commit')).writeAsString('');
      await owner.stdin.close();
      await owner.exitCode;
    }

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('macos_update_test');
      source = p.join(directory.path, 'source.app');
      target = p.join(directory.path, "FlClash's \$(literal).app");
      control = p.join(directory.path, 'control');
      await Directory(control).create();
      await Directory(target).create();
      await File(p.join(target, 'old')).writeAsString('old version');
      await Directory(
        p.join(source, 'Contents', 'MacOS'),
      ).create(recursive: true);
      await File(
        '/bin/echo',
      ).copy(p.join(source, 'Contents', 'MacOS', 'Fixture'));
      await File(p.join(source, 'Contents', 'Info.plist')).writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>test.flclash.update</string>
<key>CFBundleExecutable</key><string>Fixture</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
</dict></plist>
''');
      await command('/usr/bin/codesign', ['--force', '--sign', '-', source]);
      owner = await Process.start('/bin/cat', []);
    });

    tearDown(() async {
      await owner.stdin.close();
      await owner.exitCode;
      await directory.delete(recursive: true);
    });

    test(
      'waits for consent and exit before replacing the whole bundle',
      () async {
        final worker = await startWorker();
        await waitForReady();
        await File(p.join(control, 'commit')).writeAsString('');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(await File(p.join(target, 'old')).exists(), isTrue);

        await commitAndExit();
        expect(await worker.exitCode, 0);
        expect(await File(p.join(target, 'old')).exists(), isFalse);
        expect(
          await File(p.join(target, 'Contents', 'MacOS', 'Fixture')).exists(),
          isTrue,
        );
      },
    );

    test(
      'rejects a damaged bundle without touching the installed app',
      () async {
        await File(
          p.join(source, 'Contents', 'MacOS', 'Fixture'),
        ).writeAsString('bad');
        final worker = await startWorker();
        expect(await worker.exitCode, isNot(0));
        expect(await File(p.join(control, 'ready')).exists(), isFalse);
        expect(await File(p.join(target, 'old')).readAsString(), 'old version');
      },
    );

    test('restores the old bundle if the final move fails', () async {
      final worker = await startWorker();
      await waitForReady();
      final stage = (await directory.list().toList()).singleWhere(
        (entry) => p.basename(entry.path).startsWith('.flclash-update.'),
      );
      await Directory(p.join(stage.path, 'update.app')).delete(recursive: true);
      await commitAndExit();

      expect(await worker.exitCode, isNot(0));
      expect(await File(p.join(target, 'old')).readAsString(), 'old version');
    });

    test('aborting preparation leaves the old bundle running', () async {
      final worker = await startWorker();
      await waitForReady();
      await File(p.join(control, 'abort')).writeAsString('');

      expect(await worker.exitCode, isNot(0));
      expect(await File(p.join(target, 'old')).readAsString(), 'old version');
    });
  }, skip: !Platform.isMacOS);
}
