import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'steps.dart';

class PackageContext {
  PackageContext({
    required this.root,
    required this.os,
    required this.arch,
    required this.line,
    required this.version,
    required this.channel,
    required this.commit,
    required this.pubspecVersion,
    required this.description,
    required this.outputDirectory,
  });

  final String root;
  final ReleaseOs os;
  final ReleaseArch arch;
  final ReleaseLine line;
  final String version;
  final String channel;
  final String commit;

  /// `X.Y.Z+N`, which the installers and package managers record.
  final String pubspecVersion;
  final String description;
  final String outputDirectory;

  String get buildName => pubspecVersion.split('+').first;

  String get buildNumber => pubspecVersion.split('+').last;

  String path(String relative) => p.join(root, relative);

  String outputPath(String name) => p.join(outputDirectory, name);

  String stagingPath(String name) => p.join(outputDirectory, '.staging', name);

  String assetName(ReleaseArch arch, String extension, {ReleaseForm? form}) {
    return releaseAssetName(
      line: line,
      version: version,
      os: os,
      arch: arch,
      form: form,
      extension: extension,
    );
  }

  Map<String, dynamic> makeConfig(String format) {
    final file = File(path('${os.name}/packaging/$format/make_config.yaml'));
    if (!file.existsSync()) {
      throw PackageError('${file.path} is missing');
    }
    return _plainYaml(loadYaml(file.readAsStringSync()))
        as Map<String, dynamic>;
  }

  String get linuxBinaryName {
    final cmake = File(path('linux/CMakeLists.txt')).readAsStringSync();
    final match = RegExp(r'set\(BINARY_NAME "([^"]+)"\)').firstMatch(cmake);
    if (match == null) {
      throw const PackageError('no BINARY_NAME in linux/CMakeLists.txt');
    }
    return match[1]!;
  }

  String get linuxApplicationId {
    final cmake = File(path('linux/CMakeLists.txt')).readAsStringSync();
    final match = RegExp(r'set\(APPLICATION_ID "([^"]+)"\)').firstMatch(cmake);
    if (match == null) {
      throw const PackageError('no APPLICATION_ID in linux/CMakeLists.txt');
    }
    return match[1]!;
  }
}

class PlannedArtifact {
  const PlannedArtifact({required this.name, required this.arch, this.form});

  final String name;
  final ReleaseArch arch;
  final ReleaseForm? form;
}

class TargetPlan {
  const TargetPlan({required this.steps, required this.artifacts});

  final List<Step> steps;
  final List<PlannedArtifact> artifacts;
}

Object? _plainYaml(Object? node) {
  return switch (node) {
    YamlMap() => <String, dynamic>{
      for (final MapEntry(:key, :value) in node.entries)
        key.toString(): _plainYaml(value),
    },
    YamlList() => [for (final value in node) _plainYaml(value)],
    _ => node,
  };
}

List<String> stringList(Object? value) {
  return value == null ? const [] : (value as List).cast<String>();
}
