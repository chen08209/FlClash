import 'package:fl_clash/common/release_version.dart';

const keptPrereleases = 2;

List<String> prereleasesToPrune(
  List<Map<String, dynamic>> releases,
  String published,
) {
  final release = ReleaseVersion.tryParse(published);
  if (release == null) {
    throw ArgumentError.value(published, 'published', 'is not a release tag');
  }
  final prereleases = [
    for (final entry in releases)
      if (entry case {
        'tag_name': final String tag,
        'prerelease': true,
        'draft': false,
      })
        if (ReleaseVersion.tryParse(tag) case final version?
            when version.isPrerelease && version.line == release.line)
          (tag: tag, version: version),
  ]..sort((a, b) => b.version.compareTo(a.version));
  ReleaseVersion? floor = release.isPrerelease ? null : release;
  for (final entry in releases) {
    if (entry case {'tag_name': final String tag, 'draft': false}) {
      if (ReleaseVersion.tryParse(tag) case final version?
          when !version.isPrerelease &&
              version.line == release.line &&
              (floor == null || version > floor)) {
        floor = version;
      }
    }
  }
  return [
    for (final (index, entry) in prereleases.indexed)
      if (entry.tag != published &&
          (index >= keptPrereleases || floor != null && entry.version < floor))
        entry.tag,
  ];
}

/// Why each release that could not be deleted was not, by tag.
Future<Map<String, String>> deleteReleases(
  List<String> tags,
  Future<String?> Function(String tag) delete,
) async {
  return {for (final tag in tags) tag: ?await delete(tag)};
}
