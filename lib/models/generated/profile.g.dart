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
  id: json['id'] as String,
  label: json['label'] as String?,
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
  overrideData: json['overrideData'] == null
      ? const OverrideData()
      : OverrideData.fromJson(json['overrideData'] as Map<String, dynamic>),
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
  'overrideData': instance.overrideData,
};

_OverrideData _$OverrideDataFromJson(Map<String, dynamic> json) =>
    _OverrideData(
      enable: json['enable'] as bool? ?? false,
      rule: json['rule'] == null
          ? const OverrideRule()
          : OverrideRule.fromJson(json['rule'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OverrideDataToJson(_OverrideData instance) =>
    <String, dynamic>{'enable': instance.enable, 'rule': instance.rule};

_OverrideRule _$OverrideRuleFromJson(Map<String, dynamic> json) =>
    _OverrideRule(
      type:
          $enumDecodeNullable(_$OverrideRuleTypeEnumMap, json['type']) ??
          OverrideRuleType.added,
      overrideRules:
          (json['overrideRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      addedRules:
          (json['addedRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OverrideRuleToJson(_OverrideRule instance) =>
    <String, dynamic>{
      'type': _$OverrideRuleTypeEnumMap[instance.type]!,
      'overrideRules': instance.overrideRules,
      'addedRules': instance.addedRules,
    };

const _$OverrideRuleTypeEnumMap = {
  OverrideRuleType.override: 'override',
  OverrideRuleType.added: 'added',
};
