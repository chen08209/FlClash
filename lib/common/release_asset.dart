// tool/package.dart imports this on the plain Dart VM: no Flutter imports.
import 'dart:convert';
import 'dart:ffi' show Abi;

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

/// File names carry no line, so an rs version says so in its first
/// prerelease identifier, as an rs tag such as `v0.9.4-rs.1` does.
bool isRsReleaseVersion(String version) {
  final dash = version.indexOf('-');
  return dash != -1 && version.substring(dash + 1).split('.').first == 'rs';
}

String nightlyReleaseVersion(
  ReleaseLine line,
  String base,
  DateTime commitDate,
  String commit,
) {
  if (commit.length < 7) {
    throw ArgumentError.value(commit, 'commit', 'needs at least 7 characters');
  }
  final utc = commitDate.toUtc();
  final day =
      '${utc.year.toString().padLeft(4, '0')}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}';
  final channel = line == ReleaseLine.rs ? 'rs.nightly' : 'nightly';
  return '$base-$channel.$day.${commit.substring(0, 7)}';
}

final _version = RegExp(r'^\d+\.\d+\.\d+(-[0-9A-Za-z.]+)?$');

String _checkedVersion(String version) {
  if (!_version.hasMatch(version)) {
    throw ArgumentError.value(version, 'version', 'is not a release version');
  }
  return version;
}

String releaseAssetName({
  required String version,
  required ReleaseOs os,
  required ReleaseArch arch,
  ReleaseForm? form,
  required String extension,
}) {
  final parts = [
    releaseFilePrefix,
    _checkedVersion(version),
    os.name,
    arch.name,
    ?form?.name,
  ];
  return '${parts.join('-')}.$extension';
}

String releaseChecksumsName(String version) {
  return '$releaseFilePrefix-${_checkedVersion(version)}-SHA256SUMS';
}

typedef SelfUpdateAsset = ({
  ReleaseOs os,
  ReleaseArch arch,
  ReleaseForm? form,
  String extension,
});

// The release matrix in .github/workflows/build.yaml builds each of these.
SelfUpdateAsset? selfUpdateAssetFor(Abi abi, {required bool windowsInstalled}) {
  SelfUpdateAsset apk(ReleaseArch arch) =>
      (os: ReleaseOs.android, arch: arch, form: null, extension: 'apk');
  SelfUpdateAsset setup(ReleaseArch arch) => (
    os: ReleaseOs.windows,
    arch: arch,
    form: ReleaseForm.setup,
    extension: 'exe',
  );
  return switch (abi) {
    Abi.androidArm64 => apk(ReleaseArch.arm64),
    Abi.androidArm => apk(ReleaseArch.armv7),
    Abi.androidX64 => apk(ReleaseArch.amd64),
    Abi.windowsX64 when windowsInstalled => setup(ReleaseArch.amd64),
    Abi.windowsArm64 when windowsInstalled => setup(ReleaseArch.arm64),
    _ => null,
  };
}

String updateAssetName(String tag, SelfUpdateAsset asset) {
  return releaseAssetName(
    version: releaseVersionOfTag(tag),
    os: asset.os,
    arch: asset.arch,
    form: asset.form,
    extension: asset.extension,
  );
}

String updateChecksumsName(String tag) {
  return releaseChecksumsName(releaseVersionOfTag(tag));
}

final _checksumLine = RegExp(r'^([0-9a-fA-F]{64}) [ *](.+)$');

String? releaseChecksum(String sums, String name) {
  for (final line in const LineSplitter().convert(sums)) {
    final match = _checksumLine.firstMatch(line.trim());
    if (match != null && match[2] == name) {
      return match[1]!.toLowerCase();
    }
  }
  return null;
}
