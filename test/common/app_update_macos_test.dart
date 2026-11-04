import 'dart:io';

import 'package:fl_clash/common/app_update_macos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects an update outside an installed app', () async {
    await expectLater(
      startMacOSUpdate('/missing/update.dmg'),
      throwsA(isA<FileSystemException>()),
    );
  });

  for (final rejectSignature in [false, true]) {
    test(
      'Mac installer ${rejectSignature ? 'keeps the old app on validation failure' : 'replaces and restarts while retaining the old app'}',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'macos-update-test-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final target = Directory('${directory.path}/FlClash.app');
        await target.create();
        await File('${target.path}/version').writeAsString('old');
        final source = Directory('${directory.path}/source.app');
        await source.create();
        await File('${source.path}/version').writeAsString('new');
        final work = Directory('${directory.path}/work');
        await work.create();
        final commands = <String, String>{
          'hdiutil': r'''
if [ "$1" = attach ]; then
  shift
  while [ "$1" != -mountpoint ]; do shift; done
  cp -R "$SOURCE_APP" "$2/FlClash.app"
fi
''',
          'codesign': rejectSignature ? 'exit 1\n' : 'exit 0\n',
          'plutil': 'echo com.follow.clash\n',
          'ditto':
              r'cp -R "$1" "$2"'
              '\n',
          'open':
              r'touch "$WORK/opened"'
              '\n',
        };
        var installer = macOSUpdateInstaller;
        for (final entry in commands.entries) {
          final file = File('${directory.path}/${entry.key}');
          await file.writeAsString('#!/bin/sh\nset -eu\n${entry.value}');
          await Process.run('chmod', ['+x', file.path]);
          installer = installer.replaceAll(
            '/usr/bin/${entry.key}',
            "'${file.path}'",
          );
        }
        final script = File('${directory.path}/install.sh');
        await script.writeAsString(installer);
        final syntax = await Process.run('/bin/sh', ['-n', script.path]);
        expect(syntax.exitCode, 0);
        final result = await Process.run(
          '/bin/sh',
          [script.path, '2147483647', 'update.dmg', target.path, work.path],
          environment: {'SOURCE_APP': source.path, 'WORK': work.path},
        );
        expect(result.exitCode, rejectSignature ? 1 : 0);
        expect(
          await File('${target.path}/version').readAsString(),
          rejectSignature ? 'old' : 'new',
        );
        expect(File('${work.path}/opened').existsSync(), isTrue);
        if (!rejectSignature) {
          expect(
            await File('${work.path}/previous.app/version').readAsString(),
            'old',
          );
          expect(File('${work.path}/complete').existsSync(), isTrue);
        }
      },
      skip: Platform.isWindows,
    );
  }
}
