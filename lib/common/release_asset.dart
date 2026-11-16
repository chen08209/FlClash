// tool/package.dart imports this on the plain Dart VM: no Flutter imports.
const releaseFilePrefix = 'FlClash';

enum ReleaseLine { dev, rs }

enum ReleaseOs { windows, macos, linux, android }

enum ReleaseArch { amd64, arm64, armv7, universal }

enum ReleaseForm { setup, portable }

/// GitHub rewrites `+` in asset names, so a rebuild tag such as
/// `v0.9.4-rs.1+2` names its files `0.9.4-rs.1.2`.
String releaseVersionOfTag(String tag) {
  final version = tag.startsWith('v') ? tag.substring(1) : tag;
  return version.replaceAll('+', '.');
}

String nightlyReleaseVersion(String base, DateTime commitDate, String commit) {
  if (commit.length < 7) {
    throw ArgumentError.value(commit, 'commit', 'needs at least 7 characters');
  }
  final utc = commitDate.toUtc();
  final day =
      '${utc.year.toString().padLeft(4, '0')}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}';
  return '$base-nightly.$day.${commit.substring(0, 7)}';
}

final _version = RegExp(r'^\d+\.\d+\.\d+(-[0-9A-Za-z.]+)?$');

String _checkedVersion(String version) {
  if (!_version.hasMatch(version)) {
    throw ArgumentError.value(version, 'version', 'is not a release version');
  }
  return version;
}

String releaseAssetName({
  required ReleaseLine line,
  required String version,
  required ReleaseOs os,
  required ReleaseArch arch,
  ReleaseForm? form,
  required String extension,
}) {
  final parts = [
    releaseFilePrefix,
    line.name,
    _checkedVersion(version),
    os.name,
    arch.name,
    ?form?.name,
  ];
  return '${parts.join('-')}.$extension';
}

String releaseChecksumsName(ReleaseLine line, String version) {
  return '$releaseFilePrefix-${line.name}-${_checkedVersion(version)}-SHA256SUMS';
}
