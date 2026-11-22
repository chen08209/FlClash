import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/package.dart' as package;
import '../../tool/src/package/context.dart';
import '../../tool/src/package/manifest.dart';
import '../../tool/src/package/release_contract.dart';
import '../../tool/src/package/steps.dart';

const _version = '0.9.5';

String _read(String relative) =>
    File(p.join(Directory.current.path, relative)).readAsStringSync();

/// Packages every row of the release matrix in build.yaml the way CI does,
/// with each file holding its own name, and merges them into [directory].
Future<void> _writeRelease(String directory) async {
  final workflow = loadYaml(_read('.github/workflows/build.yaml')) as YamlMap;
  final rows =
      (((workflow['jobs'] as YamlMap)['build'] as YamlMap)['strategy']
              as YamlMap)['matrix']['include']
          as YamlList;
  final entries = <ManifestEntry>[];
  for (final row in rows.cast<YamlMap>()) {
    final os = ReleaseOs.values.byName(row['platform'] as String);
    final context = PackageContext(
      root: Directory.current.path,
      os: os,
      arch: os == ReleaseOs.android
          ? ReleaseArch.universal
          : ReleaseArch.values.byName(row['arch'] as String),
      line: ReleaseLine.dev,
      version: _version,
      channel: 'stable',
      commit: 'c' * 40,
      pubspecVersion: '$_version+1',
      description: '',
      outputDirectory: directory,
    );
    for (final target in package.defaultTargets[os]!) {
      final plan = package.planTarget(
        context,
        target,
        androidArches: const [
          ReleaseArch.arm64,
          ReleaseArch.armv7,
          ReleaseArch.amd64,
        ],
      );
      for (final artifact in plan.artifacts) {
        File(
          context.outputPath(artifact.name),
        ).writeAsStringSync(artifact.name);
        entries.add(await describeArtifact(context, artifact));
      }
    }
  }
  writeManifest(directory, entries);
}

void main() {
  test('reads the names the site asks for from its script', () {
    expect(siteAssetNames(_read(siteScript), _version), [
      'FlClash-0.9.5-android-arm64.apk',
      'FlClash-0.9.5-android-armv7.apk',
      'FlClash-0.9.5-android-amd64.apk',
      'FlClash-0.9.5-windows-amd64-setup.exe',
      'FlClash-0.9.5-windows-arm64-setup.exe',
      'FlClash-0.9.5-windows-amd64-portable.zip',
      'FlClash-0.9.5-windows-arm64-portable.zip',
      'FlClash-0.9.5-macos-arm64.dmg',
      'FlClash-0.9.5-macos-amd64.dmg',
      'FlClash-0.9.5-linux-amd64.deb',
      'FlClash-0.9.5-linux-arm64.deb',
      'FlClash-0.9.5-linux-amd64.rpm',
      'FlClash-0.9.5-linux-arm64.rpm',
      'FlClash-0.9.5-linux-amd64.AppImage',
      'FlClash-0.9.5-linux-arm64.AppImage',
      'FlClash-0.9.5-SHA256SUMS',
    ]);
  });

  test('reads every link of the release notes template', () {
    final names = releaseNotesAssetNames(_read(releaseNotesTemplate), _version);

    expect(names, hasLength(15));
    expect(names.toSet(), hasLength(15));
    expect(
      names,
      containsAll([
        'FlClash-0.9.5-windows-arm64-setup.exe',
        'FlClash-0.9.5-windows-arm64-portable.zip',
        'FlClash-0.9.5-linux-arm64.AppImage',
        'FlClash-0.9.5-linux-arm64.deb',
        'FlClash-0.9.5-linux-arm64.rpm',
      ]),
    );
  });

  test('reads both disk images of the Homebrew cask', () {
    expect(homebrewAssetNames(_read(homebrewCaskTemplate), _version), [
      'FlClash-0.9.5-macos-arm64.dmg',
      'FlClash-0.9.5-macos-amd64.dmg',
    ]);
  });

  test('lists each installer the updater downloads', () {
    expect(
      updaterAssetNames(_version),
      unorderedEquals([
        'FlClash-0.9.5-android-arm64.apk',
        'FlClash-0.9.5-android-armv7.apk',
        'FlClash-0.9.5-android-amd64.apk',
        'FlClash-0.9.5-windows-amd64-setup.exe',
        'FlClash-0.9.5-windows-arm64-setup.exe',
      ]),
    );
  });

  test('refuses a source that still holds a placeholder', () {
    expect(
      () => siteAssetNames(
        _read(siteScript).replaceFirst('macos-arm64.dmg', r'macos-${arch}.dmg'),
        _version,
      ),
      throwsA(isA<PackageError>()),
    );
    expect(
      () => homebrewAssetNames(
        _read(homebrewCaskTemplate).replaceFirst('FlClash-', 'FlClash-LINE-'),
        _version,
      ),
      throwsA(isA<PackageError>()),
    );
  });

  group('a release built by the CI matrix', () {
    late Directory temp;

    setUp(() => temp = Directory.systemTemp.createTempSync('release_contract'));
    tearDown(() => temp.deleteSync(recursive: true));

    test('serves every name it is looked up by', () async {
      await _writeRelease(temp.path);

      expect(releaseContractFailures(Directory.current.path, temp.path), []);
    });

    test('names each reader of a missing file', () async {
      await _writeRelease(temp.path);
      File(
        p.join(temp.path, 'FlClash-0.9.5-windows-arm64-setup.exe'),
      ).deleteSync();

      const missing = 'FlClash-0.9.5-windows-arm64-setup.exe, which is missing';
      expect(releaseContractFailures(Directory.current.path, temp.path), [
        '$siteScript looks for $missing',
        '$releaseNotesTemplate looks for $missing',
        'in-app updater looks for $missing',
      ]);
    });

    test('catches a checksum file that misstates an installer', () async {
      await _writeRelease(temp.path);
      final sums = File(p.join(temp.path, 'FlClash-0.9.5-SHA256SUMS'));
      sums.writeAsStringSync(
        sums
            .readAsLinesSync()
            .map((line) {
              return line.endsWith('android-arm64.apk')
                  ? line.replaceRange(0, 64, '0' * 64)
                  : line;
            })
            .join('\n'),
      );

      const failure =
          'in-app updater finds no matching sha256 for '
          'FlClash-0.9.5-android-arm64.apk in FlClash-0.9.5-SHA256SUMS';
      expect(releaseContractFailures(Directory.current.path, temp.path), [
        failure,
      ]);
    });

    test('catches an installer left from an earlier run that neither list '
        'names', () async {
      await _writeRelease(temp.path);
      const stale = 'FlClash-0.9.5-android-arm64.apk';
      writeManifest(temp.path, [
        for (final entry in readManifest(temp.path))
          if (entry.name != stale) entry,
      ]);

      expect(File(p.join(temp.path, stale)).existsSync(), isTrue);
      expect(releaseContractFailures(Directory.current.path, temp.path), [
        'in-app updater finds no sha256 for $stale in the manifest',
      ]);
    });
  });
}
