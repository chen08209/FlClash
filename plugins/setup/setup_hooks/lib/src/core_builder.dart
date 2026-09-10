import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'build.dart';
import 'error.dart';
import 'logging.dart';
import 'target.dart';

typedef CoreBuildFunction = Future<BuildReport> Function(BuildRequest request);

final _log = Logger('setup_hooks');

/// CI sets `build_assets: false` for `flutter test`; no test loads the Core.
bool buildsAssets(BuildInput input) =>
    input.userDefines['build_assets'] != false;

final class CoreBuilder implements Builder {
  const CoreBuilder({
    CoreBuildFunction build = buildPlatform,
    Architecture? hostArchitecture,
  }) : _build = build,
       _hostArchitecture = hostArchitecture;

  final CoreBuildFunction _build;
  final Architecture? _hostArchitecture;

  @override
  Future<void> run({
    required BuildInput input,
    required BuildOutputBuilder output,
    Logger? logger,
  }) async {
    try {
      await _run(input: input, output: output);
    } finally {
      closeLogging();
    }
  }

  Future<void> _run({
    required BuildInput input,
    required BuildOutputBuilder output,
  }) async {
    final BuildReport report;
    try {
      if (!buildsAssets(input)) {
        initLogging(logFile: hookLogPath(repositoryRoot(input)));
        _log.info(
          '=== ${DateTime.now().toIso8601String()} skipped: '
          'user-define build_assets=false pid $pid',
        );
        return;
      }
      final request = requestFor(input);
      if (request == null) return;
      initLogging(logFile: hookLogPath(request.rootDir));
      _log.info(
        '=== ${DateTime.now().toIso8601String()} ${request.target} pid $pid',
      );
      report = await _build(request);
    } on BuildException catch (error, stackTrace) {
      throw BuildError(
        message: error.message,
        wrappedException: error,
        wrappedTrace: stackTrace,
      );
    } on CommandFailedException catch (error, stackTrace) {
      throw BuildError(
        message: error.toString(),
        wrappedException: error,
        wrappedTrace: stackTrace,
      );
    } on ProcessException catch (error, stackTrace) {
      throw InfraError(
        message: 'Cannot run ${error.executable}: ${error.message}',
        wrappedException: error,
        wrappedTrace: stackTrace,
      );
    } on FileSystemException catch (error, stackTrace) {
      throw InfraError(
        message: error.toString(),
        wrappedException: error,
        wrappedTrace: stackTrace,
      );
    }
    output.dependencies.addAll([
      for (final path in report.inputs) Uri.file(path),
      for (final path in report.outputDirectories) Uri.directory(path),
    ]);
  }

  BuildRequest? requestFor(BuildInput input) {
    if (!input.config.buildCodeAssets) return null;
    final code = input.config.code;
    final platform = switch (code.targetOS) {
      OS.android => 'android',
      OS.linux => 'linux',
      OS.macOS => 'macos',
      OS.windows => 'windows',
      _ => null,
    };
    if (platform == null) return null;
    final goarch = switch (code.targetArchitecture) {
      Architecture.arm => 'arm',
      Architecture.arm64 => 'arm64',
      Architecture.x64 => 'amd64',
      final other => throw BuildException('No Core build for $platform $other'),
    };
    final target = Target.resolve(platform: platform, goarch: goarch);

    final host = _hostArchitecture ?? Architecture.current;
    if (code.targetOS == OS.macOS && code.targetArchitecture != host) {
      _log.info('Skipping non-host macOS slice: $target');
      return null;
    }

    final rootDir = repositoryRoot(input);
    return BuildRequest(
      rootDir: rootDir,
      harnessDir: p.join(p.fromUri(input.packageRoot), 'setup_hooks'),
      target: target,
      androidToolchain: code.targetOS == OS.android
          ? _androidToolchain(code)
          : null,
    );
  }

  String repositoryRoot(BuildInput input) {
    final packageRoot = p.fromUri(input.packageRoot);
    final rootDir = p.normalize(p.join(packageRoot, '..', '..'));
    if (!Directory(p.join(rootDir, 'core')).existsSync() ||
        !File(p.join(rootDir, 'pubspec.yaml')).existsSync()) {
      throw InfraError(
        message:
            'The setup package must live at plugins/setup of the FlClash '
            'repository; $rootDir has no core/ and pubspec.yaml',
      );
    }
    return rootDir;
  }

  AndroidToolchain _androidToolchain(CodeConfig code) {
    final compiler = code.cCompiler?.compiler;
    if (compiler == null) {
      throw InfraError(
        message:
            'Flutter passed no NDK C compiler to the setup build hook; '
            'install the NDK version android/gradle/libs.versions.toml names',
      );
    }
    return AndroidToolchain(
      clangDirectory: p.dirname(p.fromUri(compiler)),
      apiLevel: code.android.targetNdkApi,
    );
  }
}
