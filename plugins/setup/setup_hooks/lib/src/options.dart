import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _log = Logger('options');

class BuildConfig {
  const BuildConfig({
    required this.concordDir,
    required this.coreName,
    required this.coreBundleId,
    required this.productName,
    required this.outputDir,
    required this.helperDir,
    required this.helperName,
  });

  final String concordDir;
  final String coreName;
  final String coreBundleId;
  final String productName;
  final String outputDir;
  final String helperDir;
  final String helperName;

  static const _defaults = BuildConfig(
    concordDir: 'concord',
    coreName: 'FlClashCore',
    coreBundleId: 'com.follow.clash.core',
    productName: 'FlClash',
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
      concordDir: yaml['concord_dir'] as String? ?? _defaults.concordDir,
      coreName: yaml['core_name'] as String? ?? _defaults.coreName,
      coreBundleId: yaml['core_bundle_id'] as String? ?? _defaults.coreBundleId,
      productName: yaml['product_name'] as String? ?? _defaults.productName,
      outputDir: yaml['output_dir'] as String? ?? _defaults.outputDir,
      helperDir: yaml['helper_dir'] as String? ?? _defaults.helperDir,
      helperName: yaml['helper_name'] as String? ?? _defaults.helperName,
    );
  }

  Map<String, String> toFingerprintMap() => {
    'concord_dir': concordDir,
    'core_name': coreName,
    'core_bundle_id': coreBundleId,
    'product_name': productName,
    'output_dir': outputDir,
    'helper_dir': helperDir,
    'helper_name': helperName,
  };
}
