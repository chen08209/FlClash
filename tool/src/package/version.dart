import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'steps.dart';

ReleaseLine releaseLineOf(String buildConfig) {
  final config = loadYaml(buildConfig);
  if (config is YamlMap) {
    if (config.containsKey('concord_dir')) return ReleaseLine.rs;
    if (config.containsKey('core_dir')) return ReleaseLine.dev;
  }
  throw const PackageError(
    'build_config.yaml names neither concord_dir nor core_dir',
  );
}

ReleaseLine detectReleaseLine(String root) {
  return releaseLineOf(
    File(p.join(root, 'build_config.yaml')).readAsStringSync(),
  );
}

String pubspecVersionOf(String root) {
  final pubspec = loadYaml(
    File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
  );
  return (pubspec as YamlMap)['version'] as String;
}

String pubspecDescriptionOf(String root) {
  final pubspec = loadYaml(
    File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
  );
  return (pubspec as YamlMap)['description'] as String;
}

typedef ResolvedVersion = ({String version, String commit, String? tag});

/// A tagged commit releases as its tag; any other build is a nightly of the
/// pubspec version, dated by its commit so a rebuild keeps the same name.
Future<ResolvedVersion> resolveVersion(String root, {String? tag}) async {
  final commit = await capture('git', [
    'rev-parse',
    'HEAD',
  ], workingDirectory: root);
  final line = detectReleaseLine(root);
  tag ??= _tagFromEnvironment() ?? await _tagAtHead(root);
  if (tag != null) {
    final version = releaseVersionOfTag(tag);
    if (isRsReleaseVersion(version) != (line == ReleaseLine.rs)) {
      throw PackageError(
        'tag $tag does not name the ${line.name} line, and both lines '
        'publish under the same file names',
      );
    }
    return (version: version, commit: commit, tag: tag);
  }
  final seconds = await capture('git', [
    'show',
    '-s',
    '--format=%ct',
    'HEAD',
  ], workingDirectory: root);
  final date = DateTime.fromMillisecondsSinceEpoch(
    int.parse(seconds) * 1000,
    isUtc: true,
  );
  final base = pubspecVersionOf(root).split('+').first;
  return (
    version: nightlyReleaseVersion(line, base, date, commit),
    commit: commit,
    tag: null,
  );
}

String? _tagFromEnvironment() {
  final env = Platform.environment;
  if (env['GITHUB_REF_TYPE'] == 'tag') return env['GITHUB_REF_NAME'];
  return null;
}

Future<String?> _tagAtHead(String root) async {
  final tags = await capture('git', [
    'tag',
    '--points-at',
    'HEAD',
    '--list',
    'v*',
    '--sort=-v:refname',
  ], workingDirectory: root);
  return tags.isEmpty ? null : tags.split('\n').first.trim();
}
