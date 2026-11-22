// tool/publish.dart imports this on the plain Dart VM.
import 'package:fl_clash/common/release_asset.dart';

/// `+M` rebuilds a prerelease after a fix: it only breaks a precedence tie, so
/// `-pre.3` is offered `-pre.3+1` and nothing ranks it above `-pre.4`.
final class ReleaseVersion implements Comparable<ReleaseVersion> {
  const ReleaseVersion(
    this.major,
    this.minor,
    this.patch, {
    this.prerelease = const [],
    this.build = 0,
  });

  final int major;
  final int minor;
  final int patch;
  final List<String> prerelease;
  final int build;

  static final _pattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+(\d+))?$',
  );

  static ReleaseVersion? tryParse(String tag) {
    final match = _pattern.firstMatch(tag.trim());
    if (match == null) return null;
    return ReleaseVersion(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
      prerelease: match[4]?.split('.') ?? const [],
      build: match[5] == null ? 0 : int.parse(match[5]!),
    );
  }

  bool get isPrerelease => prerelease.isNotEmpty;

  ReleaseLine get line =>
      prerelease.firstOrNull == 'rs' ? ReleaseLine.rs : ReleaseLine.dev;

  @override
  int compareTo(ReleaseVersion other) {
    final core = comparePrecedence(other);
    return core != 0 ? core : build.compareTo(other.build);
  }

  int comparePrecedence(ReleaseVersion other) {
    for (final (a, b) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    if (prerelease.isEmpty || other.prerelease.isEmpty) {
      return other.prerelease.length.sign - prerelease.length.sign;
    }
    for (var i = 0; i < prerelease.length && i < other.prerelease.length; i++) {
      final order = _compareIdentifier(prerelease[i], other.prerelease[i]);
      if (order != 0) return order;
    }
    return prerelease.length.compareTo(other.prerelease.length);
  }

  bool operator >(ReleaseVersion other) => compareTo(other) > 0;

  bool operator <(ReleaseVersion other) => compareTo(other) < 0;

  @override
  String toString() {
    final pre = prerelease.isEmpty ? '' : '-${prerelease.join('.')}';
    final rebuild = build == 0 ? '' : '+$build';
    return 'v$major.$minor.$patch$pre$rebuild';
  }
}

final _numeric = RegExp(r'^\d+$');

int _compareIdentifier(String a, String b) {
  final numberA = _numeric.hasMatch(a) ? BigInt.parse(a) : null;
  final numberB = _numeric.hasMatch(b) ? BigInt.parse(b) : null;
  return switch ((numberA, numberB)) {
    (final x?, final y?) => x.compareTo(y),
    (_?, null) => -1,
    (null, _?) => 1,
    _ => a.compareTo(b),
  };
}

List<String> releaseTagsNewestFirst(Iterable<String> tags, ReleaseLine line) {
  final versions = [
    for (final tag in tags)
      if (ReleaseVersion.tryParse(tag) case final version?
          when version.line == line)
        (tag: tag, version: version),
  ]..sort((a, b) => b.version.compareTo(a.version));
  return [for (final entry in versions) entry.tag];
}
