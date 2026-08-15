import 'dart:io';

import 'package:build_tool/src/build_cache.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporaryDirectory;
  late BuildCache cache;
  late BuildNotice notice;
  late File output;
  late int buildCount;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'setup_build_cache_test_',
    );
    cache = BuildCache(rootDir: temporaryDirectory.path);
    notice = BuildNotice();
    output = File('${temporaryDirectory.path}/output/core');
    buildCount = 0;
  });

  tearDown(() {
    temporaryDirectory.deleteSync(recursive: true);
  });

  Future<BuildExecution> runBuild({
    String fingerprint = 'fingerprint-a',
    bool force = false,
    Duration delay = Duration.zero,
  }) {
    return cache.run(
      key: 'macos-arm64-core',
      fingerprint: () async => fingerprint,
      primaryOutput: output.path,
      force: force,
      notice: notice,
      build: () async {
        buildCount++;
        if (delay > Duration.zero) await Future<void>.delayed(delay);
        output
          ..createSync(recursive: true)
          ..writeAsStringSync('core-$buildCount');
        return [output.path];
      },
    );
  }

  test('skips build when fingerprint and outputs are unchanged', () async {
    final first = await runBuild();
    final second = await runBuild();

    expect(first.rebuilt, isTrue);
    expect(second.rebuilt, isFalse);
    expect(buildCount, 1);
  });

  test('rebuilds when fingerprint changes', () async {
    await runBuild();
    final result = await runBuild(fingerprint: 'fingerprint-b');

    expect(result.rebuilt, isTrue);
    expect(buildCount, 2);
  });

  test('rebuilds when an output is missing or modified', () async {
    await runBuild();
    output.deleteSync();
    expect((await runBuild()).rebuilt, isTrue);

    output.writeAsStringSync('externally modified output');
    expect((await runBuild()).rebuilt, isTrue);
    expect(buildCount, 3);
  });

  test('force always rebuilds', () async {
    await runBuild();
    final result = await runBuild(force: true);

    expect(result.rebuilt, isTrue);
    expect(buildCount, 2);
  });

  test('does not write a successful record after a failed build', () async {
    final failingBuild = cache.run(
      key: 'macos-arm64-core',
      fingerprint: () async => 'fingerprint-a',
      primaryOutput: output.path,
      notice: notice,
      build: () async {
        buildCount++;
        throw StateError('build failed');
      },
    );

    await expectLater(failingBuild, throwsStateError);
    expect((await runBuild()).rebuilt, isTrue);
    expect(buildCount, 2);
  });

  test('serializes concurrent checks and rebuilds only once', () async {
    final results = await Future.wait([
      runBuild(delay: const Duration(milliseconds: 50)),
      runBuild(delay: const Duration(milliseconds: 50)),
    ]);

    expect(results.where((result) => result.rebuilt), hasLength(1));
    expect(buildCount, 1);
  });
}
