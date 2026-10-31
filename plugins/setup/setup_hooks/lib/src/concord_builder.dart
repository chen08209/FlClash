import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'build_cache.dart';
import 'fingerprint.dart';
import 'options.dart';
import 'target.dart';
import 'util.dart';

final _log = Logger('concord_builder');

class ConcordBuilder {
  ConcordBuilder({
    required this.rootDir,
    required this.config,
    required this.cache,
    required this.notice,
    this.harnessInputs = const [],
  });

  final String rootDir;
  final BuildConfig config;
  final BuildCache cache;
  final BuildNotice notice;
  final List<String> harnessInputs;

  static const _package = 'concord-desktop';

  static const _macosDeploymentTarget = '12.0';

  String get _workspace => p.join(rootDir, config.concordDir);

  Future<BuildExecution> build(Target target) async {
    final destDir = p.join(rootDir, config.outputDir, target.platformDir);
    ensureDir(destDir);
    final fileName = '${config.coreName}${target.executableExtension}';
    final destPath = p.join(destDir, fileName);
    final args = _buildArguments(target);
    return cache.run(
      key: '${target.platformDir}-${target.goarch}-core',
      fingerprint: () => _calculateFingerprint(target, args),
      primaryOutput: destPath,
      notice: notice,
      build: () async {
        _log.info('Building Rust core: $target');
        await runCommandStream(
          'cargo',
          args,
          workingDirectory: _workspace,
          environment: _buildEnvironment(target),
        );
        // The Helper hashes the Core it finds, so a failed build must not leave
        // a half-copied file behind.
        final built = p.join(
          _workspace,
          'target',
          target.rustTriple,
          'release',
          fileName,
        );
        final staged = '$destPath.staging-$pid';
        copyFile(built, staged);
        replaceFile(staged, destPath);
        _log.info('Built: $destPath');
        return [destPath];
      },
    );
  }

  // Hooks lack Xcode's SDK settings; the target matches macos/Runner.xcodeproj.
  Map<String, String>? _buildEnvironment(Target target) {
    if (target.goos != 'darwin') return null;
    final sdk = runCommand('xcrun', [
      '--sdk',
      'macosx',
      '--show-sdk-path',
    ], workingDirectory: _workspace);
    return {
      'SDKROOT': (sdk.stdout as String).trim(),
      'MACOSX_DEPLOYMENT_TARGET': _macosDeploymentTarget,
    };
  }

  List<String> _buildArguments(Target target) => [
    'build',
    '--release',
    '--locked',
    '--target',
    target.rustTriple,
    '-p',
    _package,
  ];

  Future<Fingerprint> _calculateFingerprint(
    Target target,
    List<String> args,
  ) async {
    final builder = FingerprintBuilder(rootDir: rootDir)
      ..addValue('cache_schema', BuildCache.schemaVersion)
      ..addValue('kind', 'rust-core')
      ..addValue('target', {'goos': target.goos, 'goarch': target.goarch})
      ..addValue('config', config.toFingerprintMap())
      ..addValue('arguments', args);
    final cargoVersion = runCommand('cargo', [
      '--version',
    ], workingDirectory: _workspace);
    builder.addValue('cargo_version', (cargoVersion.stdout as String).trim());
    final rustVersion = runCommand('rustc', [
      '-Vv',
    ], workingDirectory: _workspace);
    builder.addValue('rustc_version', (rustVersion.stdout as String).trim());
    final inputs = collectFiles(
      _workspace,
      excludedDirectories: const {'target', '.git', '.idea'},
    )..addAll(harnessInputs);
    builder.addFiles(inputs);
    return builder.finishWithInputs();
  }
}
