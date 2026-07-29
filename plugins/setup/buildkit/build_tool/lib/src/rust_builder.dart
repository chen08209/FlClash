import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'logging.dart';
import 'options.dart';
import 'target.dart';
import 'util.dart';

final _log = Logger('rust_builder');

class RustBuilder {
  final String rootDir;
  final BuildConfig config;

  RustBuilder({required this.rootDir, required this.config});

  String get _helperPath => p.join(rootDir, config.helperDir);
  String get _outputPath => p.join(rootDir, config.outputDir);

  Future<String> build(Target target, String token,
      {bool release = true}) async {
    final args = ['build'];
    if (release) {
      args.addAll(['--release', '--features', 'windows-service']);
    }
    final env = {'TOKEN': token};

    _log.info(kDoubleSeparator);
    _log.info('Building Rust helper: $target');
    _log.info(kSeparator);

    await runCommandStream('cargo', args,
        workingDirectory: _helperPath, environment: env);

    final srcPath = p.join(
      _helperPath,
      'target',
      release ? 'release' : 'debug',
      'helper${target.executableExtension}',
    );
    final destDir = p.join(_outputPath, target.goos);
    final destPath = p.join(
      destDir,
      '${config.helperName}${target.executableExtension}',
    );
    ensureDir(destDir);
    copyFile(srcPath, destPath);

    _log.info('Built: $destPath');
    return destPath;
  }
}
