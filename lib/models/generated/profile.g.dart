// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: (json['id'] as num).toInt(),
  label: json['label'] as String? ?? '',
  currentGroupName: json['currentGroupName'] as String?,
  url: json['url'] as String? ?? '',
  lastUpdateDate: json['lastUpdateDate'] == null
      ? null
      : DateTime.parse(json['lastUpdateDate'] as String),
  autoUpdateDuration: Duration(
    microseconds: (json['autoUpdateDuration'] as num).toInt(),
  ),
  subscriptionInfo: json['subscriptionInfo'] == null
      ? null
      : SubscriptionInfo.fromJson(
          json['subscriptionInfo'] as Map<String, dynamic>,
        ),
  autoUpdate: json['autoUpdate'] as bool? ?? true,
  selectedMap:
      (json['selectedMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  unfoldSet:
      (json['unfoldSet'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  overwriteType:
      $enumDecodeNullable(_$OverwriteTypeEnumMap, json['overwriteType']) ??
      OverwriteType.standard,
  scriptId: (json['scriptId'] as num?)?.toInt(),
  order: (json['order'] as num?)?.toInt(),
  loginPassword: json['loginPassword'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'currentGroupName': instance.currentGroupName,
  'url': instance.url,
  'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
  'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
  'subscriptionInfo': instance.subscriptionInfo,
  'autoUpdate': instance.autoUpdate,
  'selectedMap': instance.selectedMap,
  'unfoldSet': instance.unfoldSet.toList(),
  'overwriteType': _$OverwriteTypeEnumMap[instance.overwriteType]!,
  'scriptId': instance.scriptId,
  'order': instance.order,
  'loginPassword': instance.loginPassword,
};

const _$OverwriteTypeEnumMap = {
  OverwriteType.standard: 'standard',
  OverwriteType.script: 'script',
};

_StandardOverwrite _$StandardOverwriteFromJson(Map<String, dynamic> json) =>
    _StandardOverwrite(
      addedRules:
          (json['addedRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      disabledRuleIds:
          (json['disabledRuleIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StandardOverwriteToJson(_StandardOverwrite instance) =>
    <String, dynamic>{
      'addedRules': instance.addedRules,
      'disabledRuleIds': instance.disabledRuleIds,
    };

_ScriptOverwrite _$ScriptOverwriteFromJson(Map<String, dynamic> json) =>
    _ScriptOverwrite(scriptId: (json['scriptId'] as num?)?.toInt());

Map<String, dynamic> _$ScriptOverwriteToJson(_ScriptOverwrite instance) =>
    <String, dynamic>{'scriptId': instance.scriptId};
