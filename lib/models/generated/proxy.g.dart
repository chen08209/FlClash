// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../proxy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      type: $enumDecode(_$GroupTypeEnumMap, json['type']),
      all: (json['all'] as List<dynamic>?)
              ?.map((e) => Proxy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      now: json['now'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'type': _$GroupTypeEnumMap[instance.type]!,
      'all': instance.all,
      'now': instance.now,
      'name': instance.name,
    };

const _$GroupTypeEnumMap = {
  GroupType.Selector: 'Selector',
  GroupType.URLTest: 'URLTest',
  GroupType.Fallback: 'Fallback',
  GroupType.LoadBalance: 'LoadBalance',
  GroupType.Relay: 'Relay',
};

_$ProxyImpl _$$ProxyImplFromJson(Map<String, dynamic> json) => _$ProxyImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      now: json['now'] as String?,
    );

Map<String, dynamic> _$$ProxyImplToJson(_$ProxyImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'now': instance.now,
    };
