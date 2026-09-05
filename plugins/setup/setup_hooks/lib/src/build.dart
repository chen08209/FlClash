import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'build_cache.dart';
import 'error.dart';
import 'fingerprint.dart';
import 'go_builder.dart';
import 'options.dart';
import 'rust_builder.dart';
import 'target.dart';
import 'util.dart';

final _log = Logger('setup_hooks');

class AndroidToolchain {
  const AndroidToolchain({
    required this.clangDirectory,
    required this.apiLevel,
  });

  final String clangDirectory;
  final int apiLevel;

  String clangFor(Target target) =>
      p.join(clangDirectory, '${target.ndkTriple}$apiLevel-clang');
}

class BuildRequest {
  const BuildRequest({
    required this.rootDir,
    required this.target,
    this.harnessDir,
    this.androidToolchain,
  });

  final String rootDir;
  final Target target;

  final String? harnessDir;
  final AndroidToolchain? androidToolchain;
}

class BuildReport {
  const BuildReport({
    required this.inputs,
    required this.outputs,
    required this.rebuilt,
  });

  final List<String> inputs;
  final List<String> outputs;
  final bool rebuilt;

  /// A directory dependency hashes child names, not content, so a deleted
  /// artifact still reruns the hook without rereading the Core.
  List<String> get outputDirectories =>
      {for (final output in outputs) p.dirname(output)}.toList()..sort();
}

/// The Helper embeds the Core's SHA256, so the Core is built first.
Future<BuildReport> buildPlatform(BuildRequest request) async {
  final stopwatch = Stopwatch()..start();
  final target = request.target;
  if (target.isLib && request.androidToolchain == null) {
    throw BuildException('Android target $target needs an NDK toolchain');
  }
  final rootDir = request.rootDir;
  final config = BuildConfig.load(rootDir: rootDir);
  final cache = BuildCache(rootDir: rootDir);
  final notice = BuildNotice();
  final harnessInputs = switch (request.harnessDir) {
    null => const <String>[],
    final dir => collectPackageInputs(dir),
  };

  final core = await GoBuilder(
    rootDir: rootDir,
    config: config,
    cache: cache,
    notice: notice,
    harnessInputs: harnessInputs,
    androidToolchain: request.androidToolchain,
  ).build(target);
  if (!target.hasHelper) {
    _log.info('Done in ${stopwatch.elapsed}: ${core.primaryOutput}');
    return _report([core]);
  }

  final coreSha256 = await calcSha256(core.primaryOutput);
  final helper = await RustBuilder(
    rootDir: rootDir,
    config: config,
    cache: cache,
    notice: notice,
    harnessInputs: harnessInputs,
  ).build(target, coreSha256);
  final manifestPath = p.join(
    rootDir,
    config.outputDir,
    target.platformDir,
    coreManifestName,
  );
  writeCoreManifest(path: manifestPath, coreSha256: coreSha256);

  _log.info(
    'Done in ${stopwatch.elapsed}: ${core.primaryOutput}, '
    '${helper.primaryOutput}',
  );
  return _report([core, helper], extraOutputs: [manifestPath]);
}

BuildReport _report(
  List<BuildExecution> results, {
  List<String> extraOutputs = const [],
}) {
  final inputs = <String>{};
  final outputs = <String>{};
  for (final result in results) {
    inputs.addAll(result.inputs);
    outputs.addAll(result.outputs);
  }
  outputs.addAll(extraOutputs);
  return BuildReport(
    inputs: inputs.toList()..sort(),
    outputs: outputs.toList()..sort(),
    rebuilt: results.any((result) => result.rebuilt),
  );
}
