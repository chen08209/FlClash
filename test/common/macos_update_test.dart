import 'dart:io';

import 'package:fl_clash/common/macos_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('macos_update');
  });

  tearDown(() async {
    await Process.run('chmod', ['-R', 'u+w', temp.path]);
    await temp.delete(recursive: true);
  });

  Future<String> makeApp(String path, String marker) async {
    final contents = Directory(p.join(path, 'Contents'));
    await contents.create(recursive: true);
    await File(p.join(contents.path, 'marker')).writeAsString(marker);
    return path;
  }

  Object macosOnly(String reason) => Platform.isMacOS ? false : reason;

  String? markerOf(String app) {
    final file = File(p.join(app, 'Contents', 'marker'));
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  test('appBundleOf finds the bundle an executable runs from', () {
    expect(
      appBundleOf('/Applications/FlClash RS.app/Contents/MacOS/FlClash RS'),
      '/Applications/FlClash RS.app',
    );
    expect(appBundleOf('/opt/flutter/bin/cache/flutter_tester'), isNull);
    expect(appBundleOf('/tmp/Contents/MacOS/FlClash'), isNull);
  });

  group('stage', () {
    late String bundle;
    late String directory;
    late String dmg;
    late List<List<String>> calls;
    late Map<String, String> bundleIds;
    late int appsInDmg;

    setUp(() async {
      bundle = await makeApp(p.join(temp.path, 'FlClash RS.app'), 'old');
      directory = p.join(temp.path, 'update');
      await Directory(directory).create();
      dmg = p.join(directory, 'FlClash-1.0.0-macos-arm64.dmg');
      await File(dmg).writeAsString('dmg');
      calls = [];
      bundleIds = {bundle: 'com.follow.clash.rs'};
      appsInDmg = 1;
    });

    Future<ProcessResult> fake(
      String executable,
      List<String> arguments,
    ) async {
      calls.add([executable, ...arguments]);
      var stdout = '';
      switch ((executable, arguments.first)) {
        case ('hdiutil', 'attach'):
          final mount = arguments.last;
          for (var index = 0; index < appsInDmg; index++) {
            final app = p.join(mount, 'FlClash RS $index.app');
            await makeApp(app, 'new');
            bundleIds[app] = 'com.follow.clash.rs';
          }
        case ('ditto', _):
          await makeApp(arguments.last, markerOf(arguments.first)!);
          bundleIds[arguments.last] = bundleIds[arguments.first]!;
        case ('plutil', _):
          stdout = '${bundleIds[p.dirname(p.dirname(arguments.last))]}\n';
      }
      return ProcessResult(0, 0, stdout, '');
    }

    MacosAppUpdate update() => MacosAppUpdate(bundle, runProcess: fake);

    test('copies the app out of the dmg and clears its quarantine', () async {
      final staged = await update().stage(dmg, directory);

      expect(staged, p.join(directory, 'FlClash RS.app'));
      expect(markerOf(staged), 'new');
      expect(File(dmg).existsSync(), isFalse);
      expect(
        calls,
        contains(
          equals(['hdiutil', 'detach', p.join(directory, 'mount'), '-force']),
        ),
      );
      expect(calls.last, ['xattr', '-dr', 'com.apple.quarantine', staged]);
    });

    test('refuses a dmg that does not hold exactly one app', () async {
      appsInDmg = 2;

      await expectLater(
        update().stage(dmg, directory),
        throwsA(isA<MacosUpdateException>()),
      );
      expect(calls.last.take(2), ['hdiutil', 'detach']);
    });

    test('refuses an app with another bundle id', () async {
      bundleIds[bundle] = 'com.follow.clash';

      await expectLater(
        update().stage(dmg, directory),
        throwsA(isA<MacosUpdateException>()),
      );
    });

    test('reports a dmg hdiutil cannot attach', () async {
      Future<ProcessResult> failing(
        String executable,
        List<String> args,
      ) async {
        calls.add([executable, ...args]);
        return ProcessResult(0, 1, '', 'image not recognized');
      }

      await expectLater(
        MacosAppUpdate(bundle, runProcess: failing).stage(dmg, directory),
        throwsA(isA<MacosUpdateException>()),
      );
      expect(calls, hasLength(1));
    });
  });

  group('writability', () {
    test('a bundle this user owns can be replaced and written', () async {
      final bundle = await makeApp(p.join(temp.path, 'FlClash.app'), 'old');
      final update = MacosAppUpdate(bundle);

      expect(update.canReplace, isTrue);
      await update.checkWritable();
      expect(Directory(p.join(bundle, 'Contents')).listSync(), hasLength(1));
    });

    test(
      'a bundle in a folder this user cannot write cannot be replaced',
      () async {
        final folder = p.join(temp.path, 'Applications');
        final bundle = await makeApp(p.join(folder, 'FlClash.app'), 'old');
        await Process.run('chmod', ['555', folder]);

        expect(MacosAppUpdate(bundle).canReplace, isFalse);
      },
    );
  });

  Future<String> writeOpener(String opened) async {
    final opener = p.join(temp.path, 'open.sh');
    await File(
      opener,
    ).writeAsString('#!/bin/sh\nprintf %s "\$1" > "$opened"\n');
    await Process.run('chmod', ['+x', opener]);
    return opener;
  }

  test('a second install while one is under way starts nothing', () async {
    final bundle = await makeApp(
      p.join(temp.path, 'Apps', 'FlClash.app'),
      'old',
    );
    final staged = await makeApp(
      p.join(temp.path, 'update', 'FlClash.app'),
      'new',
    );
    final opened = p.join(temp.path, 'opened');
    final update = MacosAppUpdate(bundle, opener: await writeOpener(opened));
    Future<bool> install() => update.install(
      staged: staged,
      tag: 'v1.0.0',
      marker: p.join(temp.path, 'update', 'install-failed'),
    );

    expect(await Future.wait([install(), install()]), [true, false]);

    for (var tries = 0; !File(opened).existsSync() && tries < 100; tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(markerOf(bundle), 'new');
  }, skip: macosOnly('install runs the swap script on the inherited PATH'));

  group('swap script', () {
    late String folder;
    late String app;
    late String staged;
    late String marker;
    late String opened;
    late String opener;
    late String fakeBin;

    Future<void> fakeCommand(String name, String body) async {
      final command = p.join(fakeBin, name);
      await File(command).writeAsString('#!/bin/sh\n$body\n');
      await Process.run('chmod', ['+x', command]);
    }

    setUp(() async {
      folder = p.join(temp.path, 'Applications');
      app = await makeApp(p.join(folder, 'FlClash RS.app'), 'old');
      staged = await makeApp(
        p.join(temp.path, 'update', 'FlClash RS.app'),
        'new',
      );
      marker = p.join(temp.path, 'update', 'install-failed');
      opened = p.join(temp.path, 'opened');
      opener = await writeOpener(opened);
      fakeBin = p.join(temp.path, 'bin');
      await Directory(fakeBin).create();
      if (!Platform.isMacOS) {
        await fakeCommand('ditto', 'exec cp -R "\$1" "\$2"');
      }
    });

    Future<int> exitedPid() async {
      final process = await Process.start('true', []);
      await process.exitCode;
      return process.pid;
    }

    Future<void> refuseMv(String sources) => fakeCommand(
      'mv',
      'case "\$1" in $sources) echo "mv: refused" >&2; exit 1 ;; esac\n'
          'exec /bin/mv "\$@"',
    );

    Future<ProcessResult> swap({int? pid, int ticks = 300}) async {
      return Process.run(
        '/bin/sh',
        [
          '-c',
          macosSwapScript,
          'flclash-update',
          '${pid ?? await exitedPid()}',
          app,
          staged,
          marker,
          'v1.0.0',
          opener,
          '$ticks',
        ],
        environment: {'PATH': '$fakeBin:/usr/bin:/bin:/usr/sbin:/sbin'},
      );
    }

    List<String> leftovers() => [
      for (final entity in Directory(folder).listSync())
        if (p.basename(entity.path).startsWith('.FlClash RS.app.'))
          p.basename(entity.path),
    ];

    String? openedApp() {
      final file = File(opened);
      return file.existsSync() ? file.readAsStringSync() : null;
    }

    test('puts the staged app in place and opens it', () async {
      await makeApp(p.join(folder, '.FlClash RS.app.old.1'), 'left over');
      await makeApp(p.join(folder, '.FlClash RS.app.new.2'), 'left over');

      expect((await swap()).exitCode, 0);

      expect(markerOf(app), 'new');
      expect(leftovers(), isEmpty);
      expect(File(marker).existsSync(), isFalse);
      expect(Directory('$marker.lock').existsSync(), isFalse);
      expect(openedApp(), app);
    });

    test('updates past a leftover it cannot delete', () async {
      final stuck = p.join(folder, '.FlClash RS.app.old.1', 'Contents');
      await Directory(stuck).create(recursive: true);
      await File(p.join(stuck, 'core')).writeAsString('');
      await Process.run('chmod', ['555', stuck]);

      expect((await swap()).exitCode, 0);

      expect(markerOf(app), 'new');
      expect(leftovers(), ['.FlClash RS.app.old.1']);
      expect(openedApp(), app);
    });

    test('keeps the old app when the staged one cannot be copied', () async {
      await Directory(staged).delete(recursive: true);

      expect((await swap()).exitCode, 1);

      expect(markerOf(app), 'old');
      expect(leftovers(), isEmpty);
      expect(openedApp(), app);
      final failure = await takeMacosInstallFailure(marker);
      expect(failure?.tag, 'v1.0.0');
      expect(failure?.reason, isNotEmpty);
      expect(File(marker).existsSync(), isFalse);
    });

    test('leaves the old app untouched when its folder is read-only', () async {
      await Process.run('chmod', ['555', folder]);

      expect((await swap()).exitCode, 1);

      expect(markerOf(app), 'old');
      expect(openedApp(), app);
      expect((await takeMacosInstallFailure(marker))?.tag, 'v1.0.0');
    });

    test('puts the old app back when the new one cannot move in', () async {
      await refuseMv('*.new.*');

      expect((await swap()).exitCode, 1);

      expect(markerOf(app), 'old');
      expect(leftovers(), isEmpty);
      expect(openedApp(), app);
      expect((await takeMacosInstallFailure(marker))?.reason, 'mv: refused');
    });

    test(
      'opens nothing and says where the old app is when it cannot come back',
      () async {
        await refuseMv('*.new.*|*.old.*');

        expect((await swap()).exitCode, 1);

        expect(Directory(app).existsSync(), isFalse);
        expect(openedApp(), isNull);
        final old = leftovers().singleWhere((name) => name.contains('.old.'));
        expect(markerOf(p.join(folder, old)), 'old');
        final failure = await takeMacosInstallFailure(marker);
        expect(failure?.reason, contains(p.join(folder, old)));
        expect(Directory('$marker.lock').existsSync(), isFalse);
      },
    );

    group('waiting for the app', () {
      late Process running;

      tearDown(() => running.kill());

      test('reopens the old app when it does not exit', () async {
        final executable = p.join(app, 'Contents', 'MacOS', 'FlClash RS');
        await Directory(p.dirname(executable)).create();
        // A copy of a system binary is killed at launch and leaves a crash
        // report; ps still names the process by the link's path.
        await Link(executable).create('/bin/sleep');
        running = await Process.start(executable, ['30']);

        expect((await swap(pid: running.pid, ticks: 3)).exitCode, 1);

        expect(markerOf(app), 'old');
        expect(openedApp(), app);
        final failure = await takeMacosInstallFailure(marker);
        expect(failure?.reason, 'the app did not exit');
      }, skip: macosOnly('only macOS ps names a process by its executable'));

      test('swaps once its pid belongs to another program', () async {
        running = await Process.start('/bin/sleep', ['30']);

        expect((await swap(pid: running.pid, ticks: 3)).exitCode, 0);

        expect(markerOf(app), 'new');
      });
    });

    test('a second script leaves everything alone', () async {
      await Directory('$marker.lock').create(recursive: true);

      expect((await swap()).exitCode, 0);

      expect(markerOf(app), 'old');
      expect(markerOf(staged), 'new');
      expect(File(marker).existsSync(), isFalse);
      expect(openedApp(), isNull);
    });
  });

  test('takeMacosInstallFailure answers null without a marker', () async {
    expect(
      await takeMacosInstallFailure(p.join(temp.path, 'install-failed')),
      isNull,
    );
  });
}
