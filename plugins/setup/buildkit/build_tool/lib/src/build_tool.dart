import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'environment.dart';
import 'error.dart';
import 'build_cache.dart';
import 'go_builder.dart';
import 'logging.dart';
import 'options.dart';
import 'rust_builder.dart';
import 'target.dart';
import 'util.dart';

final _log = Logger('build_tool');

String _rootDir = '.';

String _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync() &&
        File(p.join(dir.path, 'core')).existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return Directory.current.path;
}

Future<String> _hostGoArch() async {
  if (Platform.isWindows) {
    final pa = Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'AMD64';
    return pa.toUpperCase() == 'ARM64' ? 'arm64' : 'amd64';
  }
  final result = await Process.run('uname', ['-m']);
  final machine = (result.stdout as String).trim();
  if (machine == 'aarch64') return 'arm64';
  if (machine == 'x86_64') return 'amd64';
  return machine;
}

abstract class BuildCommand extends Command {
  BuildCommand() {
    argParser.addFlag(
      'force',
      negatable: false,
      help: 'Rebuild requested artifacts even when inputs are unchanged',
    );
  }

  bool get force => argResults?['force'] as bool? ?? false;

  Future<void> runBuildCommand();

  @override
  Future<void> run() async {
    await runBuildCommand();
  }
}

class BuildAndroidCommand extends BuildCommand {
  BuildAndroidCommand() {
    argParser.addOption(
      'arch',
      valueHelp: 'arm,arm64,amd64',
      help: 'Target architecture (omit to build all)',
    );
    argParser.addOption(
      'target-platform',
      valueHelp: 'android-arm,android-arm64,android-x64',
      help: 'Flutter target platform list (omit to build all)',
    );
  }

  @override
  final name = 'android';

  @override
  final description = 'Build Android Go core (c-shared library)';

  @override
  Future<void> runBuildCommand() async {
    final archName = argResults?['arch'] as String?;
    final flutterTargetPlatforms = argResults?['target-platform'] as String?;
    final config = BuildConfig.load(rootDir: _rootDir);

    final targets = Target.resolveAndroidTargets(
      archName: archName,
      flutterTargetPlatforms: flutterTargetPlatforms,
    );

    final cache = BuildCache(rootDir: _rootDir);
    final notice = BuildNotice();
    final builder = GoBuilder(
      rootDir: _rootDir,
      config: config,
      cache: cache,
      notice: notice,
    );
    final results = await builder.buildAll(targets, force: force);

    if (results.any((result) => result.rebuilt)) {
      _log.info(
        'Build complete: ${results.map((result) => result.primaryOutput)}',
      );
    }
  }
}

class BuildLinuxCommand extends BuildCommand {
  BuildLinuxCommand() {
    argParser.addOption(
      'arch',
      valueHelp: 'arm64,amd64',
      help: 'Target architecture (default: auto-detect)',
    );
  }

  @override
  final name = 'linux';

  @override
  final description = 'Build Linux Go core (executable)';

  @override
  Future<void> runBuildCommand() async {
    final archName = argResults?['arch'] as String?;
    final config = BuildConfig.load(rootDir: _rootDir);

    final arch = archName ?? await _hostGoArch();
    final targets =
        Target.forPlatform('linux').where((t) => t.goarch == arch).toList();

    if (targets.isEmpty) {
      throw BuildException('Invalid arch: $arch');
    }

    final cache = BuildCache(rootDir: _rootDir);
    final notice = BuildNotice();
    final builder = GoBuilder(
      rootDir: _rootDir,
      config: config,
      cache: cache,
      notice: notice,
    );
    final results = await builder.buildAll(targets, force: force);

    if (results.any((result) => result.rebuilt)) {
      _log.info(
        'Build complete: ${results.map((result) => result.primaryOutput)}',
      );
    }
  }
}

class BuildWindowsCommand extends BuildCommand {
  BuildWindowsCommand() {
    argParser.addOption(
      'arch',
      valueHelp: 'amd64,arm64',
      help: 'Target architecture (default: auto-detect)',
    );
  }

  @override
  final name = 'windows';

  @override
  final description = 'Build Windows Go core + Rust helper';

  @override
  Future<void> runBuildCommand() async {
    final archName = argResults?['arch'] as String?;
    final debug = Environment.isDebug;
    final config = BuildConfig.load(rootDir: _rootDir);

    final arch = archName ?? await _hostGoArch();
    final targets =
        Target.forPlatform('windows').where((t) => t.goarch == arch).toList();

    if (targets.isEmpty) {
      throw BuildException('Invalid arch: $arch');
    }

    final cache = BuildCache(rootDir: _rootDir);
    final notice = BuildNotice();
    final goBuilder = GoBuilder(
      rootDir: _rootDir,
      config: config,
      cache: cache,
      notice: notice,
    );
    final coreResults = await goBuilder.buildAll(targets, force: force);
    final corePaths =
        coreResults.map((result) => result.primaryOutput).toList();
    final rustBuilder = RustBuilder(
      rootDir: _rootDir,
      config: config,
      cache: cache,
      notice: notice,
    );
    final coreSha256 = await calcSha256(corePaths.first);
    final helperResult = await rustBuilder.build(
      targets.first,
      coreSha256,
      force: force,
      beforeBuild: debug
          ? () async {
              await Process.run('taskkill', [
                '/F',
                '/IM',
                '${config.helperName}${targets.first.executableExtension}',
              ]);
            }
          : null,
    );

    writeCoreManifest(
      path: p.join(
        _rootDir,
        config.outputDir,
        targets.first.platformDir,
        coreManifestName,
      ),
      coreSha256: coreSha256,
    );

    if (helperResult.rebuilt || coreResults.any((result) => result.rebuilt)) {
      _log.info('Build complete: $corePaths');
    }
  }
}

class BuildMacosCommand extends BuildCommand {
  BuildMacosCommand() {
    argParser.addOption(
      'arch',
      valueHelp: 'arm64,amd64',
      help: 'Target architecture (default: auto-detect)',
    );
  }

  @override
  final name = 'macos';

  @override
  final description = 'Build macOS Go core (executable)';

  @override
  Future<void> runBuildCommand() async {
    final archName = argResults?['arch'] as String?;
    final config = BuildConfig.load(rootDir: _rootDir);

    final arch = archName ?? await _hostGoArch();
    final targets =
        Target.forPlatform('darwin').where((t) => t.goarch == arch).toList();

    if (targets.isEmpty) {
      throw BuildException('Invalid arch: $arch');
    }

    final cache = BuildCache(rootDir: _rootDir);
    final notice = BuildNotice();
    final builder = GoBuilder(
      rootDir: _rootDir,
      config: config,
      cache: cache,
      notice: notice,
    );
    final results = await builder.buildAll(targets, force: force);

    if (results.any((result) => result.rebuilt)) {
      _log.info(
        'Build complete: ${results.map((result) => result.primaryOutput)}',
      );
    }
  }
}

Future<void> runMain(List<String> args) async {
  try {
    initLogging();

    final runner = CommandRunner('build_tool', 'FlClash build tool')
      ..argParser.addOption(
        'root-dir',
        valueHelp: '<path>',
        help: 'Project root directory (default: auto-detect)',
      )
      ..addCommand(BuildAndroidCommand())
      ..addCommand(BuildLinuxCommand())
      ..addCommand(BuildWindowsCommand())
      ..addCommand(BuildMacosCommand());

    final topResults = runner.parse(args);
    _rootDir = (topResults['root-dir'] as String?) ?? _findProjectRoot();
    await runner.run(args);
  } on BuildException catch (e) {
    _log.severe(e.toString());
    exit(1);
  } on CommandFailedException catch (e) {
    _log.severe(e.toString());
    exit(1);
  } on UsageException catch (e) {
    stderr.writeln(e.toString());
    exit(1);
  } catch (e, s) {
    _log.severe(kDoubleSeparator);
    _log.severe('Build failed with unexpected error:');
    _log.severe(kSeparator);
    _log.severe('$e');
    _log.severe(kSeparator);
    _log.severe('$s');
    _log.severe(kDoubleSeparator);
    exit(1);
  }
}
