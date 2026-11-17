import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'build_cache.dart';
import 'error.dart';
import 'fingerprint.dart';
import 'options.dart';
import 'path_remap.dart';
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
    this.cargo = runCommandStream,
    Map<String, String>? environment,
  }) : _environment = environment ?? Platform.environment;

  final String rootDir;
  final BuildConfig config;
  final BuildCache cache;
  final BuildNotice notice;
  final List<String> harnessInputs;
  final StreamedCommand cargo;
  final Map<String, String> _environment;

  static const _package = 'concord-desktop';

  static const _binary = 'concord';

  static const _macosDeploymentTarget = '12.0';

  String get _workspace => p.join(rootDir, config.concordDir);

  String get _targetDir => cargoTargetDir(_workspace, _environment);

  String get _infoPlistPath => p.join(cache.cacheDir, 'core-info.plist');

  Future<BuildExecution> build(Target target) async {
    final destDir = p.join(rootDir, config.outputDir, target.platformDir);
    ensureDir(destDir);
    final destPath = p.join(
      destDir,
      '${config.coreName}${target.executableExtension}',
    );
    final args = _buildArguments(target);
    final env = _buildEnvironment(target);
    return cache.run(
      key: '${target.platformDir}-${target.goarch}-core',
      fingerprint: () => _calculateFingerprint(target, args, env),
      primaryOutput: destPath,
      notice: notice,
      build: () async {
        _log.info('Building Rust core: $target');
        if (target.goos == 'darwin') {
          File(
            _infoPlistPath,
          ).writeAsStringSync(coreInfoPlist(config.coreBundleId));
        }
        await cargo(
          'cargo',
          args,
          workingDirectory: _workspace,
          environment: env,
        );
        // The Helper hashes the Core it finds, so a failed build must not leave
        // a half-copied file behind.
        final built = p.join(
          _targetDir,
          target.rustTriple,
          'release',
          '$_binary${target.executableExtension}',
        );
        final staged = '$destPath.staging-$pid';
        copyFile(built, staged);
        replaceFile(staged, destPath);
        _log.info('Built: $destPath');
        return [destPath];
      },
    );
  }

  Map<String, String> _buildEnvironment(Target target) => {
    ...trimmedPathEnvironment(
      checkoutDir: rootDir,
      toolchainDir: _workspace,
      targetTriple: target.rustTriple,
    ),
    'CONCORD_PRODUCT_NAME': config.productName,
    if (target.goos == 'darwin') ..._macosEnvironment(),
  };

  // Hooks lack Xcode's SDK settings; the target matches macos/Runner.xcodeproj.
  Map<String, String> _macosEnvironment() {
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

  // `cargo rustc` gives these flags to the executable alone, not its deps.
  List<String> _buildArguments(Target target) => [
    if (target.goos == 'darwin') 'rustc' else 'build',
    '--release',
    '--locked',
    '--target',
    target.rustTriple,
    '-p',
    _package,
    if (target.goos == 'darwin') ...[
      '--bin',
      _binary,
      '--',
      ...infoPlistLinkArguments(_infoPlistPath),
    ],
  ];

  Future<Fingerprint> _calculateFingerprint(
    Target target,
    List<String> args,
    Map<String, String> env,
  ) async {
    final builder = FingerprintBuilder(rootDir: rootDir)
      ..addValue('cache_schema', BuildCache.schemaVersion)
      ..addValue('kind', 'rust-core')
      ..addValue('target', {'goos': target.goos, 'goarch': target.goarch})
      ..addValue('config', config.toFingerprintMap())
      ..addValue('arguments', args)
      ..addValue('environment', env);
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

/// A non-root Core sees other sockets on macOS 27 only under a dotted id.
String coreInfoPlist(String bundleId) {
  if (!RegExp(r'^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$').hasMatch(bundleId)) {
    throw BuildException(
      'core_bundle_id must be a reverse-DNS name with a dot: $bundleId',
    );
  }
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>CFBundleIdentifier</key>
\t<string>$bundleId</string>
</dict>
</plist>
''';
}

List<String> infoPlistLinkArguments(String plistPath) => [
  for (final argument in [
    '-sectcreate',
    '__TEXT',
    '__info_plist',
    plistPath,
  ]) ...['-C', 'link-arg=-Xlinker', '-C', 'link-arg=$argument'],
];
