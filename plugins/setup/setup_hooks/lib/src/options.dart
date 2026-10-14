import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _log = Logger('options');

class BuildConfig {
  const BuildConfig({
    required this.tags,
    required this.goLdflags,
    required this.coreVersion,
    required this.coreDir,
    required this.coreName,
    required this.outputDir,
    required this.helperDir,
    required this.helperName,
  });

  final String tags;
  final String goLdflags;
  final String coreVersion;
  final String coreDir;
  final String coreName;
  final String outputDir;
  final String helperDir;
  final String helperName;

  static const _defaults = BuildConfig(
    tags: 'with_gvisor',
    goLdflags: '-w -s',
    coreVersion: '',
    coreDir: 'core',
    coreName: 'FlClashCore',
    outputDir: 'libclash',
    helperDir: 'services/helper',
    helperName: 'FlClashHelperService',
  );

  static BuildConfig load({required String rootDir}) {
    final file = File(p.join(rootDir, 'build_config.yaml'));
    if (!file.existsSync()) {
      _log.fine('No build_config.yaml found, using defaults');
      return _defaults;
    }
    final yaml = loadYaml(file.readAsStringSync()) as YamlMap?;
    if (yaml == null) return _defaults;
    return BuildConfig(
      tags: yaml['tags'] as String? ?? _defaults.tags,
      goLdflags: yaml['go_ldflags'] as String? ?? _defaults.goLdflags,
      coreVersion: yaml['core_version'] as String? ?? _defaults.coreVersion,
      coreDir: yaml['core_dir'] as String? ?? _defaults.coreDir,
      coreName: yaml['core_name'] as String? ?? _defaults.coreName,
      outputDir: yaml['output_dir'] as String? ?? _defaults.outputDir,
      helperDir: yaml['helper_dir'] as String? ?? _defaults.helperDir,
      helperName: yaml['helper_name'] as String? ?? _defaults.helperName,
    );
  }

  Map<String, String> toFingerprintMap() => {
    'tags': tags,
    'go_ldflags': goLdflags,
    'core_version': coreVersion,
    'core_dir': coreDir,
    'core_name': coreName,
    'output_dir': outputDir,
    'helper_dir': helperDir,
    'helper_name': helperName,
  };
}
