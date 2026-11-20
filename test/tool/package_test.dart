import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/package.dart' as package;
import '../../tool/src/package/context.dart';
import '../../tool/src/package/linux.dart';
import '../../tool/src/package/manifest.dart';
import '../../tool/src/package/steps.dart';
import '../../tool/src/package/tools.dart';
import '../../tool/src/package/version.dart';
import '../../tool/src/package/windows.dart';

PackageContext _context(
  ReleaseOs os, {
  ReleaseArch arch = ReleaseArch.amd64,
  String output = 'dist',
}) {
  return PackageContext(
    root: Directory.current.path,
    os: os,
    arch: arch,
    line: ReleaseLine.rs,
    version: '0.9.4-pre.2',
    channel: 'pre',
    commit: '394f5bb82a524db3838aa441a8a348d038666ad7',
    pubspecVersion: '0.9.4+2026111612',
    description: 'A proxy client.',
    outputDirectory: output,
  );
}

void main() {
  test('parses -v, --env and several Android ABIs', () {
    final results = package.createPackageArgParser().parse([
      'android',
      '-v',
      '--env',
      'dev',
      '--arch',
      'arm64,universal',
    ]);

    expect(results['verbose'], isTrue);
    expect(results['env'], 'dev');
    expect(results['arch'], ['arm64', 'universal']);
    expect(results.rest, ['android']);
  });

  group('flutter build arguments', () {
    test('split the APK per ABI the run asks for', () {
      expect(
        package.flutterBuildArguments(
          _context(ReleaseOs.android),
          androidArches: [ReleaseArch.arm64, ReleaseArch.armv7],
          verbose: false,
        ),
        [
          'build',
          'apk',
          '--dart-define-from-file=env.json',
          '--split-per-abi',
          '--target-platform',
          'android-arm64,android-arm',
          '--build-name',
          '0.9.4',
          '--build-number',
          '2026111612',
        ],
      );
    });

    test('build a desktop bundle, verbose with -v', () {
      expect(
        package.flutterBuildArguments(
          _context(ReleaseOs.windows),
          verbose: true,
        ),
        [
          'build',
          'windows',
          '--dart-define-from-file=env.json',
          '--build-name',
          '0.9.4',
          '--build-number',
          '2026111612',
          '--verbose',
        ],
      );
    });
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

    expect(package.packagesNotBuildingAssets(pubspec), ['setup']);
    expect(package.packagesNotBuildingAssets('name: x\n'), isEmpty);
  });

  test('packages every format of a platform by default', () {
    expect(package.defaultTargets, {
      ReleaseOs.android: ['apk'],
      ReleaseOs.linux: ['deb', 'appimage', 'rpm'],
      ReleaseOs.macos: ['dmg'],
      ReleaseOs.windows: ['exe', 'zip'],
    });
  });

  test('a desktop build takes the host arch, another only as a dry run', () {
    expect(
      package.desktopArch(const [], host: ReleaseArch.arm64, dryRun: false),
      ReleaseArch.arm64,
    );
    expect(
      package.desktopArch(const [ReleaseArch.amd64], host: null, dryRun: true),
      ReleaseArch.amd64,
    );
    expect(
      () => package.desktopArch(
        const [ReleaseArch.amd64],
        host: ReleaseArch.arm64,
        dryRun: false,
      ),
      throwsA(isA<PackageError>()),
    );
    expect(
      () => package.desktopArch(
        const [ReleaseArch.armv7],
        host: ReleaseArch.arm64,
        dryRun: true,
      ),
      throwsA(isA<PackageError>()),
    );
  });

  test('downloads the appimagetool build matching the host', () {
    expect(appImageToolArch(ReleaseArch.arm64), 'aarch64');
    expect(appImageToolArch(ReleaseArch.amd64), 'x86_64');
  });

  test('passes appimagetool the architecture under its own name', () {
    expect(
      appImageArch(_context(ReleaseOs.linux, arch: ReleaseArch.arm64)),
      'arm_aarch64',
    );
    expect(appImageArch(_context(ReleaseOs.linux)), 'x86_64');
  });

  test('the line follows the core build_config.yaml builds', () {
    expect(releaseLineOf('concord_dir: concord\n'), ReleaseLine.rs);
    expect(releaseLineOf('core_dir: core\n'), ReleaseLine.dev);
    expect(() => releaseLineOf('x: 1\n'), throwsA(isA<PackageError>()));
  });

  test('plans every target under its release name', () {
    String names(ReleaseOs os, List<String> targets, {ReleaseArch? arch}) {
      final context = _context(os, arch: arch ?? ReleaseArch.amd64);
      return [
        for (final target in targets)
          ...package
              .planTarget(
                context,
                target,
                androidArches: const [
                  ReleaseArch.arm64,
                  ReleaseArch.armv7,
                  ReleaseArch.amd64,
                  ReleaseArch.universal,
                ],
              )
              .artifacts
              .map((artifact) => artifact.name),
      ].join(' ');
    }

    expect(
      names(ReleaseOs.windows, ['exe', 'zip'], arch: ReleaseArch.arm64),
      'FlClash-0.9.4-pre.2-windows-arm64-setup.exe '
      'FlClash-0.9.4-pre.2-windows-arm64-portable.zip',
    );
    expect(
      names(ReleaseOs.linux, ['deb', 'rpm', 'appimage']),
      'FlClash-0.9.4-pre.2-linux-amd64.deb '
      'FlClash-0.9.4-pre.2-linux-amd64.rpm '
      'FlClash-0.9.4-pre.2-linux-amd64.AppImage',
    );
    expect(
      names(ReleaseOs.macos, ['dmg'], arch: ReleaseArch.arm64),
      'FlClash-0.9.4-pre.2-macos-arm64.dmg',
    );
    expect(
      names(ReleaseOs.android, ['apk']),
      'FlClash-0.9.4-pre.2-android-arm64.apk '
      'FlClash-0.9.4-pre.2-android-armv7.apk '
      'FlClash-0.9.4-pre.2-android-amd64.apk '
      'FlClash-0.9.4-pre.2-android-universal.apk',
    );
    expect(() => names(ReleaseOs.macos, ['deb']), throwsA(isA<PackageError>()));
  });

  group('Inno Setup script', () {
    test('fills placeholders and leaves Inno constants alone', () {
      expect(
        renderInnoScript(
          'AppId={{APP_ID}}\nDefaultDirName={autopf64}\\{{APP_NAME}}\n'
          'Check: {{{param:x}',
          {'APP_ID': 'GUID', 'APP_NAME': 'FlClash'},
        ),
        'AppId=GUID\nDefaultDirName={autopf64}\\FlClash\nCheck: {{{param:x}',
      );
    });

    test('refuses a placeholder without a value or a template tag', () {
      expect(
        () => renderInnoScript('{{MISSING}}', const {}),
        throwsA(isA<PackageError>()),
      );
      expect(
        () => renderInnoScript('{% if x %}', const {}),
        throwsA(isA<PackageError>()),
      );
    });

    test('the template has a value for every placeholder', () {
      final context = _context(ReleaseOs.windows, arch: ReleaseArch.arm64);
      final config = context.makeConfig('exe');
      final template = File(
        'windows/packaging/exe/${config['script_template']}',
      ).readAsStringSync();
      final variables = innoVariables(
        context,
        config,
        sourceDir: 'stage',
        outputBaseName: 'out',
      );

      expect(variables['ARCH'], 'arm64');
      expect(variables['APP_VERSION'], '0.9.4+2026111612');
      expect(
        RegExp(r'\{\{([A-Z_]+)\}\}')
            .allMatches(template)
            .map((match) => match[1])
            .where((name) => !variables.containsKey(name)),
        isEmpty,
      );
    });
  });

  test('points absolute RUNPATH entries at the library directory', () {
    expect(
      sanitizeRpath(r'/home/runner/lib:$ORIGIN/x:/usr/lib'),
      r'$ORIGIN:$ORIGIN/x',
    );
    expect(sanitizeRpath(r'$ORIGIN'), r'$ORIGIN');
  });

  test(
    'the AppImage leaves the C++ runtime and graphics stack to the host',
    () {
      const ldd = '''
	linux-vdso.so.1 (0x0000ffff)
	libkeybinder-3.0.so.0 => /lib/aarch64-linux-gnu/libkeybinder-3.0.so.0 (0x1)
	libstdc++.so.6 => /lib/aarch64-linux-gnu/libstdc++.so.6 (0x2)
	libEGL.so.1 => /lib/aarch64-linux-gnu/libEGL.so.1 (0x3)
	/lib/ld-linux-aarch64.so.1 (0x4)
''';

      expect(bundledLibraries(ldd), {
        '/lib/aarch64-linux-gnu/libkeybinder-3.0.so.0',
      });
    },
  );

  test('the AppImage passes launch arguments on and keeps LD_LIBRARY_PATH', () {
    final appRun = appImageAppRun('FlClash');

    expect(appRun, contains('exec ./FlClash "\$@"'));
    expect(
      appRun,
      contains(
        'export LD_LIBRARY_PATH="\$PWD/usr/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"',
      ),
    );
  });

  test('the rpm spec keeps the Core bytes and names the arch', () {
    final context = _context(ReleaseOs.linux, arch: ReleaseArch.arm64);
    final spec = rpmSpec(context, context.makeConfig('rpm'));

    expect(
      spec,
      startsWith(
        '%global debug_package %{nil}\n%global __os_install_post %{nil}\n\n',
      ),
    );
    expect(spec, contains('\nRelease: 2026111612%{?dist}\n'));
    expect(spec, contains('\nBuildArch: aarch64'));
    expect(spec, contains('\n%postun\nupdate-mime-database'));
  });

  test('the deb postrm removes the launcher link even when it is gone', () {
    final context = _context(ReleaseOs.linux);
    final binary = context.linuxBinaryName;
    final files = debFiles(context, context.makeConfig('deb'));

    expect(
      files['DEBIAN/postinst'],
      contains('\nln -s /opt/$binary/$binary /usr/bin/$binary\n'),
    );
    final postrm = files['DEBIAN/postrm']!;
    expect(postrm, contains('\nrm -f /usr/bin/$binary\n'));
    expect(postrm, isNot(contains('\nrm /usr/bin/')));
    expect(postrm, endsWith('\nexit 0'));
  });

  test('desktop entries name the GTK application id as their window class', () {
    final context = _context(ReleaseOs.linux);
    final wmClass = 'StartupWMClass=${context.linuxApplicationId}';

    expect(
      rpmDesktopEntry(context, context.makeConfig('rpm')),
      contains(wmClass),
    );
    expect(
      appImageDesktopEntry(context, context.makeConfig('appimage')),
      contains(wmClass),
    );
  });

  group('manifest', () {
    late Directory temp;

    setUp(() => temp = Directory.systemTemp.createTempSync('package_test'));
    tearDown(() => temp.deleteSync(recursive: true));

    Future<ManifestEntry> artifact(
      String directory,
      ReleaseOs os,
      ReleaseArch arch,
      String extension, {
      ReleaseLine line = ReleaseLine.rs,
    }) {
      Directory(directory).createSync(recursive: true);
      final context = PackageContext(
        root: Directory.current.path,
        os: os,
        arch: arch,
        line: line,
        version: '0.9.4',
        channel: 'stable',
        commit: 'c' * 40,
        pubspecVersion: '0.9.4+1',
        description: '',
        outputDirectory: directory,
      );
      final name = context.assetName(arch, extension);
      File(p.join(directory, name)).writeAsStringSync(name);
      return describeArtifact(context, PlannedArtifact(name: name, arch: arch));
    }

    test('records each artifact and writes the checksum file', () async {
      final dir = p.join(temp.path, 'linux');
      final entry = await artifact(
        dir,
        ReleaseOs.linux,
        ReleaseArch.amd64,
        'deb',
      );
      final checksums = writeManifest(dir, [entry]);

      expect(checksums, 'FlClash-0.9.4-SHA256SUMS');
      expect(
        File(p.join(dir, checksums)).readAsStringSync(),
        '${sha256.convert(utf8.encode(entry.name))}  ${entry.name}\n',
      );
      final json = jsonDecode(
        File(p.join(dir, manifestName)).readAsStringSync(),
      );
      expect(json['checksums'], checksums);
      expect(json['artifacts'], [
        {
          'name': 'FlClash-0.9.4-linux-amd64.deb',
          'sha256': entry.sha256,
          'size': entry.name.length,
          'line': 'rs',
          'version': '0.9.4',
          'channel': 'stable',
          'os': 'linux',
          'arch': 'amd64',
          'form': null,
          'commit': 'c' * 40,
        },
      ]);
    });

    test('merges the manifests of several runs into one', () async {
      final linux = p.join(temp.path, 'a');
      final macos = p.join(temp.path, 'b');
      final out = p.join(temp.path, 'dist');
      writeManifest(linux, [
        await artifact(linux, ReleaseOs.linux, ReleaseArch.amd64, 'deb'),
      ]);
      writeManifest(macos, [
        await artifact(macos, ReleaseOs.macos, ReleaseArch.arm64, 'dmg'),
      ]);

      final checksums = await mergeManifests([linux, macos], out);

      expect(readManifest(out).map((entry) => entry.name), [
        'FlClash-0.9.4-linux-amd64.deb',
        'FlClash-0.9.4-macos-arm64.dmg',
      ]);
      expect(
        File(
          p.join(out, checksums),
        ).readAsLinesSync().map((l) => l.split('  ').last),
        ['FlClash-0.9.4-linux-amd64.deb', 'FlClash-0.9.4-macos-arm64.dmg'],
      );
      expect(
        File(p.join(out, 'FlClash-0.9.4-macos-arm64.dmg')).existsSync(),
        isTrue,
      );
    });

    test('refuses a file that changed after its run', () async {
      final dir = p.join(temp.path, 'a');
      final entry = await artifact(
        dir,
        ReleaseOs.linux,
        ReleaseArch.amd64,
        'deb',
      );
      writeManifest(dir, [entry]);
      File(p.join(dir, entry.name)).writeAsStringSync('changed');

      expect(
        mergeManifests([dir], p.join(temp.path, 'dist')),
        throwsA(isA<PackageError>()),
      );
    });

    test('keeps one line and version per manifest', () async {
      final dir = p.join(temp.path, 'a');
      final rs = await artifact(dir, ReleaseOs.linux, ReleaseArch.amd64, 'deb');
      final dev = await artifact(
        dir,
        ReleaseOs.linux,
        ReleaseArch.amd64,
        'rpm',
        line: ReleaseLine.dev,
      );

      expect(() => writeManifest(dir, [rs, dev]), throwsA(isA<PackageError>()));
    });
  });
}
