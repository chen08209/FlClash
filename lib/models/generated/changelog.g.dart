// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../changelog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogEntry _$ChangelogEntryFromJson(Map<String, dynamic> json) =>
    _ChangelogEntry(
      id: json['id'] as String,
      scope: json['scope'] as String?,
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$ChangelogEntryToJson(_ChangelogEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scope': instance.scope,
      'text': instance.text,
    };

_ChangelogGroup _$ChangelogGroupFromJson(Map<String, dynamic> json) =>
    _ChangelogGroup(
      type:
          $enumDecodeNullable(
            _$ChangelogTypeEnumMap,
            json['type'],
            unknownValue: ChangelogType.unknown,
          ) ??
          ChangelogType.unknown,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => ChangelogEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChangelogGroupToJson(_ChangelogGroup instance) =>
    <String, dynamic>{
      'type': _$ChangelogTypeEnumMap[instance.type]!,
      'entries': instance.entries,
    };

const _$ChangelogTypeEnumMap = {
  ChangelogType.breaking: 'breaking',
  ChangelogType.feat: 'feat',
  ChangelogType.fix: 'fix',
  ChangelogType.perf: 'perf',
  ChangelogType.revert: 'revert',
  ChangelogType.unknown: 'unknown',
};

_ChangelogVersion _$ChangelogVersionFromJson(Map<String, dynamic> json) =>
    _ChangelogVersion(
      version: json['version'] as String,
      tag: json['tag'] as String,
      date: json['date'] as String? ?? '',
      prerelease: json['prerelease'] as bool? ?? false,
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map((e) => ChangelogGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChangelogVersionToJson(_ChangelogVersion instance) =>
    <String, dynamic>{
      'version': instance.version,
      'tag': instance.tag,
      'date': instance.date,
      'prerelease': instance.prerelease,
      'groups': instance.groups,
    };

_Changelog _$ChangelogFromJson(Map<String, dynamic> json) => _Changelog(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 0,
  versions:
      (json['versions'] as List<dynamic>?)
          ?.map((e) => ChangelogVersion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ChangelogToJson(_Changelog instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'versions': instance.versions,
    };
