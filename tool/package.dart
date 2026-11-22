import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'src/package/android.dart';
import 'src/package/context.dart';
import 'src/package/linux.dart';
import 'src/package/macos.dart';
import 'src/package/manifest.dart';
import 'src/package/release_contract.dart';
import 'src/package/steps.dart';
import 'src/package/tools.dart';
import 'src/package/version.dart';
import 'src/package/windows.dart';

const defaultTargets = <ReleaseOs, List<String>>{
  ReleaseOs.android: ['apk'],
  ReleaseOs.linux: ['deb', 'appimage', 'rpm'],
  ReleaseOs.macos: ['dmg'],
  ReleaseOs.windows: ['exe', 'zip'],
};

ArgParser createPackageArgParser() {
  return ArgParser()
    ..addOption(
      'env',
      defaultsTo: 'pre',
      allowed: ['dev', 'pre', 'stable'],
      help: 'Application environment, written to env.json as APP_ENV.',
    )
    ..addMultiOption(
      'targets',
      valueHelp: 'exe,zip,dmg,deb,rpm,appimage,apk',
      help: 'Package formats (default: every format of the platform).',
    )
    ..addMultiOption(
      'arch',
      valueHelp: 'arm64,armv7,amd64,universal',
      allowed: ['arm64', 'armv7', 'amd64', 'universal'],
      help:
          'Android ABIs (default: arm64, armv7 and amd64). On the desktop, '
          'the host architecture; another one only with --dry-run.',
    )
    ..addOption(
      'tag',
      help:
          'Release tag the build is named after; defaults to the v* tag on '
          'HEAD, else a nightly name.',
    )
    ..addOption('out', defaultsTo: 'dist', help: 'Output directory.')
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Print every artifact name and step, build nothing.',
    )
    ..addFlag('verbose', abbr: 'v', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);
}

void _usage(ArgParser parser) {
  stderr
    ..writeln('Usage: dart tool/package.dart [platform] [options]')
    ..writeln('       dart tool/package.dart merge <dir>... [--out dist]')
    ..writeln('       dart tool/package.dart check <dir>')
    ..writeln()
    ..writeln('Platform: the host platform (default) or android.')
    ..writeln(parser.usage);
}

ReleaseOs? hostOs() {
  return switch (Platform.operatingSystem) {
    'linux' => ReleaseOs.linux,
    'macos' => ReleaseOs.macos,
    'windows' => ReleaseOs.windows,
    _ => null,
  };
}

ReleaseArch hostArch() {
  if (Platform.isWindows) {
    final arch = Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'AMD64';
    return arch.toUpperCase() == 'ARM64'
        ? ReleaseArch.arm64
        : ReleaseArch.amd64;
  }
  final machine = (Process.runSync('uname', ['-m']).stdout as String).trim();
  return switch (machine) {
    'aarch64' || 'arm64' => ReleaseArch.arm64,
    'x86_64' => ReleaseArch.amd64,
    _ => throw PackageError('unsupported host architecture $machine'),
  };
}

ReleaseArch desktopArch(
  List<ReleaseArch> requested, {
  required ReleaseArch? host,
  required bool dryRun,
}) {
  if (requested.length > 1 ||
      requested.any(
        (arch) => arch != ReleaseArch.amd64 && arch != ReleaseArch.arm64,
      )) {
    throw const PackageError(
      'a desktop package takes one --arch: amd64 or arm64',
    );
  }
  final arch = requested.firstOrNull ?? host ?? ReleaseArch.amd64;
  if (arch != host && !dryRun) {
    throw PackageError(
      'this host builds ${host?.name}; ${arch.name} only plans with --dry-run',
    );
  }
  return arch;
}

List<String> packagesNotBuildingAssets(String pubspec) {
  final document = loadYaml(pubspec);
  if (document is! Map) return const [];
  final defines = (document['hooks'] as Map?)?['user_defines'];
  if (defines is! Map) return const [];
  return [
    for (final MapEntry(:key, :value) in defines.entries)
      if (value is Map && value['build_assets'] == false) key.toString(),
  ]..sort();
}

List<String> flutterBuildArguments(
  PackageContext context, {
  List<ReleaseArch> androidArches = const [],
  required bool verbose,
}) {
  final android = context.os == ReleaseOs.android;
  final split = androidArches.where((arch) => arch != ReleaseArch.universal);
  return [
    'build',
    if (android) 'apk' else context.os.name,
    '--dart-define-from-file=env.json',
    if (android && split.isNotEmpty) ...[
      '--split-per-abi',
      '--target-platform',
      split.map((arch) => androidFlutterTargets[arch]!).join(','),
    ],
    '--build-name',
    context.buildName,
    '--build-number',
    context.buildNumber,
    if (verbose) '--verbose',
  ];
}

/// The app compares a prerelease by its tag, since its version name is only
/// `X.Y.Z`; see installedReleaseVersion in lib/common/app_update.dart.
Map<String, String> buildDefines({required String env, String? tag}) {
  return {'APP_ENV': env, 'RELEASE_TAG': ?tag};
}

List<Step> planBuild(
  PackageContext context, {
  required String env,
  String? tag,
  required List<ReleaseArch> androidArches,
  required bool verbose,
}) {
  final defines = buildDefines(env: env, tag: tag);
  final steps = <Step>[
    Task('write env.json with ${jsonEncode(defines)}', () async {
      File(context.path('env.json')).writeAsStringSync(jsonEncode(defines));
    }),
    Task('install the packaging tools ${context.os.name} is missing', () {
      return ensurePackagingTools(context.os, context.arch);
    }),
    Task('create ${context.outputDirectory}', () async {
      Directory(context.outputDirectory).createSync(recursive: true);
    }),
  ];
  final hasUniversal = androidArches.contains(ReleaseArch.universal);
  final splitArches = androidArches
      .where((arch) => arch != ReleaseArch.universal)
      .toList();
  if (context.os != ReleaseOs.android || splitArches.isNotEmpty) {
    steps.add(
      Command(
        'flutter',
        flutterBuildArguments(
          context,
          androidArches: splitArches,
          verbose: verbose,
        ),
        workingDirectory: context.root,
      ),
    );
  }
  if (hasUniversal) {
    steps.add(
      Command(
        'flutter',
        flutterBuildArguments(context, verbose: verbose),
        workingDirectory: context.root,
      ),
    );
  }
  return steps;
}

TargetPlan planTarget(
  PackageContext context,
  String target, {
  required List<ReleaseArch> androidArches,
}) {
  return switch ((context.os, target)) {
    (ReleaseOs.android, 'apk') => planApk(context, androidArches),
    (ReleaseOs.linux, 'deb') => planDeb(context),
    (ReleaseOs.linux, 'rpm') => planRpm(context),
    (ReleaseOs.linux, 'appimage') => planAppImage(context),
    (ReleaseOs.macos, 'dmg') => planDmg(context),
    (ReleaseOs.windows, 'exe') => planExe(context),
    (ReleaseOs.windows, 'zip') => planZip(context),
    _ => throw PackageError('${context.os.name} has no $target target'),
  };
}

Future<int> _package(ArgResults results) async {
  final host = hostOs();
  if (host == null) {
    throw PackageError('unsupported host ${Platform.operatingSystem}');
  }
  final os = results.rest.isEmpty
      ? host
      : ReleaseOs.values.asNameMap()[results.rest.first];
  final dryRun = results['dry-run'] as bool;
  if (os == null || (os != host && os != ReleaseOs.android && !dryRun)) {
    throw PackageError(
      'cannot package "${results.rest.first}" on ${host.name}; '
      'allowed: ${host.name}, android',
    );
  }
  final root = Directory.current.path;
  final skipped = packagesNotBuildingAssets(
    File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
  );
  if (skipped.isNotEmpty && !dryRun) {
    throw PackageError(
      'pubspec.yaml sets hooks.user_defines.<package>.build_assets: false for '
      '${skipped.join(', ')}; a package built this way would ship whatever is '
      'left in libclash/ and no Rust library. Restore "build_assets: true".',
    );
  }

  final env = results['env'] as String;
  final targets = (results['targets'] as List<String>).isEmpty
      ? defaultTargets[os]!
      : results['targets'] as List<String>;
  final arches = (results['arch'] as List<String>)
      .map(ReleaseArch.values.byName)
      .toList();
  final androidArches = os != ReleaseOs.android
      ? const <ReleaseArch>[]
      : arches.isEmpty
      ? const [ReleaseArch.arm64, ReleaseArch.armv7, ReleaseArch.amd64]
      : arches;
  final arch = os == ReleaseOs.android
      ? ReleaseArch.universal
      : desktopArch(
          arches,
          host: os == host ? hostArch() : null,
          dryRun: dryRun,
        );
  final resolved = await resolveVersion(root, tag: results['tag'] as String?);
  final context = PackageContext(
    root: root,
    os: os,
    arch: arch,
    line: detectReleaseLine(root),
    version: resolved.version,
    channel: env,
    commit: resolved.commit,
    pubspecVersion: pubspecVersionOf(root),
    description: pubspecDescriptionOf(root),
    outputDirectory: p.absolute(results['out'] as String),
  );
  final verbose = results['verbose'] as bool;
  final plans = [
    for (final target in targets)
      planTarget(context, target, androidArches: androidArches),
  ];
  final steps = [
    ...planBuild(
      context,
      env: env,
      tag: resolved.tag,
      androidArches: androidArches,
      verbose: verbose,
    ),
    for (final plan in plans) ...plan.steps,
  ];
  final artifacts = [for (final plan in plans) ...plan.artifacts];
  final checksums = releaseChecksumsName(context.version);

  if (dryRun) {
    stdout
      ..writeln(
        'line ${context.line.name}, version ${context.version}, '
        'channel $env, commit ${context.commit}'
        '${resolved.tag == null ? '' : ', tag ${resolved.tag}'}',
      )
      ..writeln()
      ..writeln('Artifacts in ${context.outputDirectory}:');
    for (final artifact in artifacts) {
      stdout.writeln('  ${artifact.name}');
    }
    stdout
      ..writeln('  $checksums')
      ..writeln('  $manifestName')
      ..writeln()
      ..writeln('Steps:');
    for (final step in steps) {
      stdout.writeln('  ${step.describe()}');
    }
    return 0;
  }

  for (final step in steps) {
    await step.run(verbose: verbose);
  }
  final entries = [
    for (final artifact in artifacts) await describeArtifact(context, artifact),
  ];
  writeManifest(context.outputDirectory, entries);
  final staging = Directory(context.stagingPath(''));
  if (staging.existsSync()) staging.deleteSync(recursive: true);
  for (final entry in entries) {
    stdout.writeln('${entry.sha256}  ${entry.name}');
  }
  return 0;
}

Future<int> _merge(List<String> arguments) async {
  final parser = ArgParser()..addOption('out', defaultsTo: 'dist');
  final results = parser.parse(arguments);
  if (results.rest.isEmpty) {
    throw const PackageError('merge needs at least one directory');
  }
  final checksums = await mergeManifests(
    results.rest,
    results['out'] as String,
  );
  stdout.writeln('wrote $manifestName and $checksums in ${results['out']}');
  return 0;
}

int _check(List<String> arguments) {
  if (arguments.length != 1) {
    throw const PackageError('check takes one merged directory');
  }
  final failures = releaseContractFailures(
    Directory.current.path,
    arguments.single,
  );
  for (final failure in failures) {
    stderr.writeln(failure);
  }
  if (failures.isNotEmpty) {
    throw PackageError(
      '${arguments.single} lacks ${failures.length} file(s) the site, '
      'release notes, Homebrew cask or in-app updater look up by name',
    );
  }
  stdout.writeln('${arguments.single} serves every name it is looked up by');
  return 0;
}

Future<void> main(List<String> arguments) async {
  final parser = createPackageArgParser();
  try {
    if (arguments.firstOrNull == 'merge') {
      exit(await _merge(arguments.skip(1).toList()));
    }
    if (arguments.firstOrNull == 'check') {
      exit(_check(arguments.skip(1).toList()));
    }
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      _usage(parser);
      exit(0);
    }
    exit(await _package(results));
  } on PackageError catch (error) {
    stderr.writeln('package: $error');
    exit(1);
  } on FormatException catch (error) {
    stderr.writeln('package: ${error.message}');
    _usage(parser);
    exit(64);
  }
}
