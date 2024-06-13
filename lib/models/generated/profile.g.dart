// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      upload: (json['upload'] as num?)?.toInt(),
      download: (json['download'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      expire: (json['expire'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String?,
      label: json['label'] as String?,
      url: json['url'] as String?,
      currentGroupName: json['currentGroupName'] as String?,
      userInfo: json['userInfo'] == null
          ? null
          : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
      lastUpdateDate: json['lastUpdateDate'] == null
          ? null
          : DateTime.parse(json['lastUpdateDate'] as String),
      selectedMap: (json['selectedMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      autoUpdateDuration: json['autoUpdateDuration'] == null
          ? null
          : Duration(microseconds: (json['autoUpdateDuration'] as num).toInt()),
      autoUpdate: json['autoUpdate'] as bool? ?? true,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'currentGroupName': instance.currentGroupName,
      'url': instance.url,
      'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
      'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
      'userInfo': instance.userInfo,
      'autoUpdate': instance.autoUpdate,
      'selectedMap': instance.selectedMap,
    };
