import 'dart:io';

import 'package:build_tool/src/build_cache.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporaryDirectory;
  late BuildCache cache;
  late BuildNotice notice;
  late File coreOutput;
  late File helperOutput;
  late int coreBuilds;
  late int helperBuilds;
  late int taskKills;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'setup_windows_cache_test_',
    );
    cache = BuildCache(rootDir: temporaryDirectory.path);
    notice = BuildNotice();
    coreOutput = File('${temporaryDirectory.path}/core.exe');
    helperOutput = File('${temporaryDirectory.path}/helper.exe');
    coreBuilds = 0;
    helperBuilds = 0;
    taskKills = 0;
  });

  tearDown(() {
    temporaryDirectory.deleteSync(recursive: true);
  });

  Future<BuildExecution> buildCore(String fingerprint) => cache.run(
    key: 'windows-amd64-core',
    fingerprint: () async => fingerprint,
    primaryOutput: coreOutput.path,
    notice: notice,
    build: () async {
      coreBuilds++;
      coreOutput.writeAsStringSync('core-$fingerprint');
      return [coreOutput.path];
    },
  );

  Future<BuildExecution> buildHelper({
    required String coreSha256,
    required String sourceFingerprint,
    bool stopRunningHelper = false,
  }) => cache.run(
    key: 'windows-amd64-helper-release',
    fingerprint: () async => '$sourceFingerprint:$coreSha256',
    primaryOutput: helperOutput.path,
    notice: notice,
    build: () async {
      if (stopRunningHelper) taskKills++;
      helperBuilds++;
      helperOutput.writeAsStringSync('helper-$sourceFingerprint-$coreSha256');
      return [helperOutput.path];
    },
  );

  test('core and release helper both skip when unchanged', () async {
    await buildCore('core-a');
    await buildHelper(coreSha256: 'sha-a', sourceFingerprint: 'helper-a');

    expect((await buildCore('core-a')).rebuilt, isFalse);
    expect(
      (await buildHelper(
        coreSha256: 'sha-a',
        sourceFingerprint: 'helper-a',
      )).rebuilt,
      isFalse,
    );
    expect(coreBuilds, 1);
    expect(helperBuilds, 1);
  });

  test('helper source change does not rebuild core', () async {
    await buildCore('core-a');
    await buildHelper(coreSha256: 'sha-a', sourceFingerprint: 'helper-a');

    expect((await buildCore('core-a')).rebuilt, isFalse);
    expect(
      (await buildHelper(
        coreSha256: 'sha-a',
        sourceFingerprint: 'helper-b',
      )).rebuilt,
      isTrue,
    );
    expect(coreBuilds, 1);
    expect(helperBuilds, 2);
  });

  test('Core SHA change invalidates hardened helper', () async {
    await buildHelper(coreSha256: 'sha-a', sourceFingerprint: 'helper-a');

    expect(
      (await buildHelper(
        coreSha256: 'sha-b',
        sourceFingerprint: 'helper-a',
      )).rebuilt,
      isTrue,
    );
    expect(helperBuilds, 2);
  });

  test('development cache hit does not stop running helper', () async {
    await buildHelper(
      coreSha256: 'sha-a',
      sourceFingerprint: 'helper-a',
      stopRunningHelper: true,
    );
    expect(taskKills, 1);

    expect(
      (await buildHelper(
        coreSha256: 'sha-a',
        sourceFingerprint: 'helper-a',
        stopRunningHelper: true,
      )).rebuilt,
      isFalse,
    );
    expect(taskKills, 1);
  });
}
