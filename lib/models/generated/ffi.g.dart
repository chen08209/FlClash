// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ffi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConfigExtendedParamsImpl _$$ConfigExtendedParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$ConfigExtendedParamsImpl(
      isPatch: json['is-patch'] as bool,
      isCompatible: json['is-compatible'] as bool,
      selectedMap: Map<String, String>.from(json['selected-map'] as Map),
      testUrl: json['test-url'] as String,
    );

Map<String, dynamic> _$$ConfigExtendedParamsImplToJson(
        _$ConfigExtendedParamsImpl instance) =>
    <String, dynamic>{
      'is-patch': instance.isPatch,
      'is-compatible': instance.isCompatible,
      'selected-map': instance.selectedMap,
      'test-url': instance.testUrl,
    };

_$UpdateConfigParamsImpl _$$UpdateConfigParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateConfigParamsImpl(
      profilePath: json['profile-path'] as String?,
      config: ClashConfig.fromJson(json['config'] as Map<String, dynamic>),
      params:
          ConfigExtendedParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UpdateConfigParamsImplToJson(
        _$UpdateConfigParamsImpl instance) =>
    <String, dynamic>{
      'profile-path': instance.profilePath,
      'config': instance.config,
      'params': instance.params,
    };

_$ChangeProxyParamsImpl _$$ChangeProxyParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$ChangeProxyParamsImpl(
      groupName: json['group-name'] as String,
      proxyName: json['proxy-name'] as String,
    );

Map<String, dynamic> _$$ChangeProxyParamsImplToJson(
        _$ChangeProxyParamsImpl instance) =>
    <String, dynamic>{
      'group-name': instance.groupName,
      'proxy-name': instance.proxyName,
    };

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      data: json['data'],
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$MessageTypeEnumMap = {
  MessageType.log: 'log',
  MessageType.tun: 'tun',
  MessageType.delay: 'delay',
  MessageType.process: 'process',
  MessageType.now: 'now',
  MessageType.request: 'request',
  MessageType.run: 'run',
  MessageType.loaded: 'loaded',
};

_$DelayImpl _$$DelayImplFromJson(Map<String, dynamic> json) => _$DelayImpl(
      name: json['name'] as String,
      value: (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DelayImplToJson(_$DelayImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

_$NowImpl _$$NowImplFromJson(Map<String, dynamic> json) => _$NowImpl(
      name: json['name'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$$NowImplToJson(_$NowImpl instance) => <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

_$ProcessImpl _$$ProcessImplFromJson(Map<String, dynamic> json) =>
    _$ProcessImpl(
      id: (json['id'] as num).toInt(),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProcessImplToJson(_$ProcessImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metadata': instance.metadata,
    };

_$FdImpl _$$FdImplFromJson(Map<String, dynamic> json) => _$FdImpl(
      id: (json['id'] as num).toInt(),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$$FdImplToJson(_$FdImpl instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
    };

_$ProcessMapItemImpl _$$ProcessMapItemImplFromJson(Map<String, dynamic> json) =>
    _$ProcessMapItemImpl(
      id: (json['id'] as num).toInt(),
      value: json['value'] as String,
    );

Map<String, dynamic> _$$ProcessMapItemImplToJson(
        _$ProcessMapItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
    };

_$ExternalProviderImpl _$$ExternalProviderImplFromJson(
        Map<String, dynamic> json) =>
    _$ExternalProviderImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      vehicleType: json['vehicle-type'] as String,
      updateAt: DateTime.parse(json['update-at'] as String),
    );

Map<String, dynamic> _$$ExternalProviderImplToJson(
        _$ExternalProviderImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'vehicle-type': instance.vehicleType,
      'update-at': instance.updateAt.toIso8601String(),
    };
