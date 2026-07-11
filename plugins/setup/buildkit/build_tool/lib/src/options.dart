import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _log = Logger('options');

class BuildConfig {
  final String tags;
  final String goLdflags;
  final String coreDir;
  final String coreName;
  final String libName;
  final String outputDir;
  final String helperDir;
  final String helperName;
  final String distDir;

  const BuildConfig({
    required this.tags,
    required this.goLdflags,
    required this.coreDir,
    required this.coreName,
    required this.libName,
    required this.outputDir,
    required this.helperDir,
    required this.helperName,
    required this.distDir,
  });

  static const _defaults = BuildConfig(
    tags: 'with_gvisor',
    goLdflags: '-w -s',
    coreDir: 'core',
    coreName: 'FlClashCore',
    libName: 'libclash',
    outputDir: 'libclash',
    helperDir: 'services/helper',
    helperName: 'FlClashHelperService',
    distDir: 'dist',
  );

  static BuildConfig load({required String rootDir}) {
    final configPath = p.join(rootDir, 'build_config.yaml');
    final file = File(configPath);
    if (!file.existsSync()) {
      _log.fine('No build_config.yaml found, using defaults');
      return _defaults;
    }
    final yaml = loadYaml(file.readAsStringSync()) as YamlMap?;
    if (yaml == null) return _defaults;
    return BuildConfig(
      tags: yaml['tags'] as String? ?? _defaults.tags,
      goLdflags: yaml['go_ldflags'] as String? ?? _defaults.goLdflags,
      coreDir: yaml['core_dir'] as String? ?? _defaults.coreDir,
      coreName: yaml['core_name'] as String? ?? _defaults.coreName,
      libName: yaml['lib_name'] as String? ?? _defaults.libName,
      outputDir: yaml['output_dir'] as String? ?? _defaults.outputDir,
      helperDir: yaml['helper_dir'] as String? ?? _defaults.helperDir,
      helperName: yaml['helper_name'] as String? ?? _defaults.helperName,
      distDir: yaml['dist_dir'] as String? ?? _defaults.distDir,
    );
  }

  Map<String, String> toFingerprintMap() => {
        'tags': tags,
        'go_ldflags': goLdflags,
        'core_dir': coreDir,
        'core_name': coreName,
        'lib_name': libName,
        'output_dir': outputDir,
        'helper_dir': helperDir,
        'helper_name': helperName,
        'dist_dir': distDir,
      };
}
