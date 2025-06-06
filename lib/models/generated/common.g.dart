// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PackageImpl _$$PackageImplFromJson(Map<String, dynamic> json) =>
    _$PackageImpl(
      packageName: json['packageName'] as String,
      label: json['label'] as String,
      system: json['system'] as bool,
      internet: json['internet'] as bool,
      lastUpdateTime: (json['lastUpdateTime'] as num).toInt(),
    );

Map<String, dynamic> _$$PackageImplToJson(_$PackageImpl instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'label': instance.label,
      'system': instance.system,
      'internet': instance.internet,
      'lastUpdateTime': instance.lastUpdateTime,
    };

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    _$MetadataImpl(
      uid: (json['uid'] as num?)?.toInt() ?? 0,
      network: json['network'] as String? ?? '',
      sourceIP: json['sourceIP'] as String? ?? '',
      sourcePort: json['sourcePort'] as String? ?? '',
      destinationIP: json['destinationIP'] as String? ?? '',
      destinationPort: json['destinationPort'] as String? ?? '',
      host: json['host'] as String? ?? '',
      dnsMode: $enumDecodeNullable(_$DnsModeEnumMap, json['dnsMode']),
      process: json['process'] as String? ?? '',
      processPath: json['processPath'] as String? ?? '',
      remoteDestination: json['remoteDestination'] as String? ?? '',
      sourceGeoIP: (json['sourceGeoIP'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      destinationGeoIP: (json['destinationGeoIP'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      destinationIPASN: json['destinationIPASN'] as String? ?? '',
      sourceIPASN: json['sourceIPASN'] as String? ?? '',
      specialRules: json['specialRules'] as String? ?? '',
      specialProxy: json['specialProxy'] as String? ?? '',
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
      'dnsMode': _$DnsModeEnumMap[instance.dnsMode],
      'process': instance.process,
      'processPath': instance.processPath,
      'remoteDestination': instance.remoteDestination,
      'sourceGeoIP': instance.sourceGeoIP,
      'destinationGeoIP': instance.destinationGeoIP,
      'destinationIPASN': instance.destinationIPASN,
      'sourceIPASN': instance.sourceIPASN,
      'specialRules': instance.specialRules,
      'specialProxy': instance.specialProxy,
    };

const _$DnsModeEnumMap = {
  DnsMode.normal: 'normal',
  DnsMode.fakeIp: 'fake-ip',
  DnsMode.redirHost: 'redir-host',
  DnsMode.hosts: 'hosts',
};

_$TrackerInfoImpl _$$TrackerInfoImplFromJson(Map<String, dynamic> json) =>
    _$TrackerInfoImpl(
      id: json['id'] as String,
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      start: DateTime.parse(json['start'] as String),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      rule: json['rule'] as String,
      rulePayload: json['rulePayload'] as String,
      downloadSpeed: (json['downloadSpeed'] as num?)?.toInt(),
      uploadSpeed: (json['uploadSpeed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TrackerInfoImplToJson(_$TrackerInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'upload': instance.upload,
      'download': instance.download,
      'start': instance.start.toIso8601String(),
      'metadata': instance.metadata,
      'chains': instance.chains,
      'rule': instance.rule,
      'rulePayload': instance.rulePayload,
      'downloadSpeed': instance.downloadSpeed,
      'uploadSpeed': instance.uploadSpeed,
    };

_$LogImpl _$$LogImplFromJson(Map<String, dynamic> json) => _$LogImpl(
      logLevel: $enumDecodeNullable(_$LogLevelEnumMap, json['LogLevel']) ??
          LogLevel.info,
      payload: json['Payload'] as String? ?? '',
      dateTime: _logDateTime(json['dateTime']),
    );

Map<String, dynamic> _$$LogImplToJson(_$LogImpl instance) => <String, dynamic>{
      'LogLevel': _$LogLevelEnumMap[instance.logLevel]!,
      'Payload': instance.payload,
      'dateTime': instance.dateTime,
    };

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
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
      clashName: json['clashName'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );

Map<String, dynamic> _$$VersionInfoImplToJson(_$VersionInfoImpl instance) =>
    <String, dynamic>{
      'clashName': instance.clashName,
      'version': instance.version,
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

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      type: $enumDecode(_$GroupTypeEnumMap, json['type']),
      all: (json['all'] as List<dynamic>?)
              ?.map((e) => Proxy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      now: json['now'] as String?,
      hidden: json['hidden'] as bool?,
      testUrl: json['testUrl'] as String?,
      icon: json['icon'] as String? ?? '',
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

_$TextPainterParamsImpl _$$TextPainterParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$TextPainterParamsImpl(
      text: json['text'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? double.infinity,
      maxLines: (json['maxLines'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TextPainterParamsImplToJson(
        _$TextPainterParamsImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'fontSize': instance.fontSize,
      'textScaleFactor': instance.textScaleFactor,
      'maxWidth': instance.maxWidth,
      'maxLines': instance.maxLines,
    };

_$ScriptImpl _$$ScriptImplFromJson(Map<String, dynamic> json) => _$ScriptImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$$ScriptImplToJson(_$ScriptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'content': instance.content,
    };
