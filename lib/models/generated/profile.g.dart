// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserInfoImpl _$$UserInfoImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoImpl(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserInfoImplToJson(_$UserInfoImpl instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      label: json['label'] as String?,
      currentGroupName: json['currentGroupName'] as String?,
      url: json['url'] as String? ?? "",
      lastUpdateDate: json['lastUpdateDate'] == null
          ? null
          : DateTime.parse(json['lastUpdateDate'] as String),
      autoUpdateDuration:
          Duration(microseconds: (json['autoUpdateDuration'] as num).toInt()),
      userInfo: json['userInfo'] == null
          ? null
          : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      selectedMap: (json['selectedMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      unfoldSet: (json['unfoldSet'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'currentGroupName': instance.currentGroupName,
      'url': instance.url,
      'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
      'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
      'userInfo': instance.userInfo,
      'autoUpdate': instance.autoUpdate,
      'selectedMap': instance.selectedMap,
      'unfoldSet': instance.unfoldSet.toList(),
    };
