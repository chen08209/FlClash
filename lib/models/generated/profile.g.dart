// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionInfoImpl _$$SubscriptionInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionInfoImpl(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SubscriptionInfoImplToJson(
        _$SubscriptionInfoImpl instance) =>
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
      url: json['url'] as String? ?? '',
      lastUpdateDate: json['lastUpdateDate'] == null
          ? null
          : DateTime.parse(json['lastUpdateDate'] as String),
      autoUpdateDuration:
          Duration(microseconds: (json['autoUpdateDuration'] as num).toInt()),
      subscriptionInfo: json['subscriptionInfo'] == null
          ? null
          : SubscriptionInfo.fromJson(
              json['subscriptionInfo'] as Map<String, dynamic>),
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      selectedMap: (json['selectedMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      unfoldSet: (json['unfoldSet'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      overrideData: json['overrideData'] == null
          ? const OverrideData()
          : OverrideData.fromJson(json['overrideData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
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

_$OverrideDataImpl _$$OverrideDataImplFromJson(Map<String, dynamic> json) =>
    _$OverrideDataImpl(
      enable: json['enable'] as bool? ?? false,
      rule: json['rule'] == null
          ? const OverrideRule()
          : OverrideRule.fromJson(json['rule'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OverrideDataImplToJson(_$OverrideDataImpl instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'rule': instance.rule,
    };

_$OverrideRuleImpl _$$OverrideRuleImplFromJson(Map<String, dynamic> json) =>
    _$OverrideRuleImpl(
      type: $enumDecodeNullable(_$OverrideRuleTypeEnumMap, json['type']) ??
          OverrideRuleType.added,
      overrideRules: (json['overrideRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      addedRules: (json['addedRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OverrideRuleImplToJson(_$OverrideRuleImpl instance) =>
    <String, dynamic>{
      'type': _$OverrideRuleTypeEnumMap[instance.type]!,
      'overrideRules': instance.overrideRules,
      'addedRules': instance.addedRules,
    };

const _$OverrideRuleTypeEnumMap = {
  OverrideRuleType.override: 'override',
  OverrideRuleType.added: 'added',
};
