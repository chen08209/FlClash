import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/changelog.freezed.dart';
part 'generated/changelog.g.dart';

const changelogSchemaVersion = 2;

enum ChangelogType { breaking, feat, fix, perf, revert, unknown }

@freezed
abstract class ChangelogEntry with _$ChangelogEntry {
  const factory ChangelogEntry({
    required String id,
    String? scope,
    @Default('') String text,
  }) = _ChangelogEntry;

  factory ChangelogEntry.fromJson(Map<String, dynamic> json) =>
      _$ChangelogEntryFromJson(json);
}

@freezed
abstract class ChangelogGroup with _$ChangelogGroup {
  const factory ChangelogGroup({
    @JsonKey(unknownEnumValue: ChangelogType.unknown)
    @Default(ChangelogType.unknown)
    ChangelogType type,
    @Default([]) List<ChangelogEntry> entries,
  }) = _ChangelogGroup;

  factory ChangelogGroup.fromJson(Map<String, dynamic> json) =>
      _$ChangelogGroupFromJson(json);
}

@freezed
abstract class ChangelogVersion with _$ChangelogVersion {
  const factory ChangelogVersion({
    required String version,
    required String tag,
    @Default('') String date,
    @Default(false) bool prerelease,
    @Default([]) List<ChangelogGroup> groups,
  }) = _ChangelogVersion;

  factory ChangelogVersion.fromJson(Map<String, dynamic> json) =>
      _$ChangelogVersionFromJson(json);
}

@freezed
abstract class Changelog with _$Changelog {
  const factory Changelog({
    @Default(0) int schemaVersion,
    @Default([]) List<ChangelogVersion> versions,
  }) = _Changelog;

  factory Changelog.fromJson(Map<String, dynamic> json) =>
      _$ChangelogFromJson(json);
}

extension ChangelogVersionExt on ChangelogVersion {
  List<ChangelogGroup> get visibleGroups => groups
      .where((group) => group.type != ChangelogType.unknown)
      .where((group) => group.entries.isNotEmpty)
      .toList();

  bool get isEmpty => visibleGroups.isEmpty;
}

extension ChangelogExt on Changelog {
  bool get isSupported => schemaVersion == changelogSchemaVersion;
}
