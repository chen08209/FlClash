// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      logLevel: $enumDecode(_$LogLevelEnumMap, json['LogLevel']),
      payload: json['Payload'] as String?,
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'LogLevel': _$LogLevelEnumMap[instance.logLevel]!,
      'Payload': instance.payload,
    };

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

_$PackageImpl _$$PackageImplFromJson(Map<String, dynamic> json) =>
    _$PackageImpl(
      packageName: json['packageName'] as String,
      label: json['label'] as String,
      isSystem: json['isSystem'] as bool,
      firstInstallTime: (json['firstInstallTime'] as num).toInt(),
    );

Map<String, dynamic> _$$PackageImplToJson(_$PackageImpl instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'label': instance.label,
      'isSystem': instance.isSystem,
      'firstInstallTime': instance.firstInstallTime,
    };

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    _$MetadataImpl(
      uid: (json['uid'] as num).toInt(),
      network: json['network'] as String,
      sourceIP: json['sourceIP'] as String,
      sourcePort: json['sourcePort'] as String,
      destinationIP: json['destinationIP'] as String,
      destinationPort: json['destinationPort'] as String,
      host: json['host'] as String,
      process: json['process'] as String,
      remoteDestination: json['remoteDestination'] as String,
    );

Map<String, dynamic> _$$MetadataImplToJson(_$MetadataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'network': instance.network,
      'sourceIP': instance.sourceIP,
      'sourcePort': instance.sourcePort,
      'destinationIP': instance.destinationIP,
      'destinationPort': instance.destinationPort,
      'host': instance.host,
      'process': instance.process,
      'remoteDestination': instance.remoteDestination,
    };

_$ConnectionImpl _$$ConnectionImplFromJson(Map<String, dynamic> json) =>
    _$ConnectionImpl(
      id: json['id'] as String,
      upload: json['upload'] as num?,
      download: json['download'] as num?,
      start: DateTime.parse(json['start'] as String),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$ConnectionImplToJson(_$ConnectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'upload': instance.upload,
      'download': instance.download,
      'start': instance.start.toIso8601String(),
      'metadata': instance.metadata,
      'chains': instance.chains,
    };

_$LogsAndKeywordsImpl _$$LogsAndKeywordsImplFromJson(
        Map<String, dynamic> json) =>
    _$LogsAndKeywordsImpl(
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => Log.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LogsAndKeywordsImplToJson(
        _$LogsAndKeywordsImpl instance) =>
    <String, dynamic>{
      'logs': instance.logs,
      'keywords': instance.keywords,
    };

_$ConnectionsAndKeywordsImpl _$$ConnectionsAndKeywordsImplFromJson(
        Map<String, dynamic> json) =>
    _$ConnectionsAndKeywordsImpl(
      connections: (json['connections'] as List<dynamic>?)
              ?.map((e) => Connection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ConnectionsAndKeywordsImplToJson(
        _$ConnectionsAndKeywordsImpl instance) =>
    <String, dynamic>{
      'connections': instance.connections,
      'keywords': instance.keywords,
    };

_$DAVImpl _$$DAVImplFromJson(Map<String, dynamic> json) => _$DAVImpl(
      uri: json['uri'] as String,
      user: json['user'] as String,
      password: json['password'] as String,
      fileName: json['fileName'] as String? ?? defaultDavFileName,
    );

Map<String, dynamic> _$$DAVImplToJson(_$DAVImpl instance) => <String, dynamic>{
      'uri': instance.uri,
      'user': instance.user,
      'password': instance.password,
      'fileName': instance.fileName,
    };

_$VersionInfoImpl _$$VersionInfoImplFromJson(Map<String, dynamic> json) =>
    _$VersionInfoImpl(
      clashName: json['clashName'] as String? ?? "",
      version: json['version'] as String? ?? "",
    );

Map<String, dynamic> _$$VersionInfoImplToJson(_$VersionInfoImpl instance) =>
    <String, dynamic>{
      'clashName': instance.clashName,
      'version': instance.version,
    };

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      type: $enumDecode(_$GroupTypeEnumMap, json['type']),
      all: (json['all'] as List<dynamic>?)
              ?.map((e) => Proxy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      now: json['now'] as String?,
      hidden: json['hidden'] as bool?,
      testUrl: json['testUrl'] as String?,
      icon: json['icon'] as String? ?? "",
      name: json['name'] as String,
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'type': _$GroupTypeEnumMap[instance.type]!,
      'all': instance.all,
      'now': instance.now,
      'hidden': instance.hidden,
      'testUrl': instance.testUrl,
      'icon': instance.icon,
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

_$HotKeyActionImpl _$$HotKeyActionImplFromJson(Map<String, dynamic> json) =>
    _$HotKeyActionImpl(
      action: $enumDecode(_$HotActionEnumMap, json['action']),
      key: (json['key'] as num?)?.toInt(),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$KeyboardModifierEnumMap, e))
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$$HotKeyActionImplToJson(_$HotKeyActionImpl instance) =>
    <String, dynamic>{
      'action': _$HotActionEnumMap[instance.action]!,
      'key': instance.key,
      'modifiers':
          instance.modifiers.map((e) => _$KeyboardModifierEnumMap[e]!).toList(),
    };

const _$HotActionEnumMap = {
  HotAction.start: 'start',
  HotAction.view: 'view',
  HotAction.mode: 'mode',
  HotAction.proxy: 'proxy',
  HotAction.tun: 'tun',
};

const _$KeyboardModifierEnumMap = {
  KeyboardModifier.alt: 'alt',
  KeyboardModifier.capsLock: 'capsLock',
  KeyboardModifier.control: 'control',
  KeyboardModifier.fn: 'fn',
  KeyboardModifier.meta: 'meta',
  KeyboardModifier.shift: 'shift',
};
