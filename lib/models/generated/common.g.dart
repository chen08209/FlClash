// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Package _$PackageFromJson(Map<String, dynamic> json) => _Package(
  packageName: json['packageName'] as String,
  label: json['label'] as String,
  system: json['system'] as bool,
  internet: json['internet'] as bool,
  lastUpdateTime: (json['lastUpdateTime'] as num).toInt(),
);

Map<String, dynamic> _$PackageToJson(_Package instance) => <String, dynamic>{
  'packageName': instance.packageName,
  'label': instance.label,
  'system': instance.system,
  'internet': instance.internet,
  'lastUpdateTime': instance.lastUpdateTime,
};

_Metadata _$MetadataFromJson(Map<String, dynamic> json) => _Metadata(
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
  sourceGeoIP:
      (json['sourceGeoIP'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  destinationGeoIP:
      (json['destinationGeoIP'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  destinationIPASN: json['destinationIPASN'] as String? ?? '',
  sourceIPASN: json['sourceIPASN'] as String? ?? '',
  specialRules: json['specialRules'] as String? ?? '',
  specialProxy: json['specialProxy'] as String? ?? '',
);

Map<String, dynamic> _$MetadataToJson(_Metadata instance) => <String, dynamic>{
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

_TrackerInfo _$TrackerInfoFromJson(Map<String, dynamic> json) => _TrackerInfo(
  id: json['id'] as String,
  upload: (json['upload'] as num?)?.toInt() ?? 0,
  download: (json['download'] as num?)?.toInt() ?? 0,
  start: DateTime.parse(json['start'] as String),
  metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
  chains: (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
  rule: json['rule'] as String,
  rulePayload: json['rulePayload'] as String,
  downloadSpeed: (json['downloadSpeed'] as num?)?.toInt(),
  uploadSpeed: (json['uploadSpeed'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrackerInfoToJson(_TrackerInfo instance) =>
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

_Log _$LogFromJson(Map<String, dynamic> json) => _Log(
  logLevel:
      $enumDecodeNullable(_$LogLevelEnumMap, json['LogLevel']) ?? LogLevel.info,
  payload: json['Payload'] as String? ?? '',
  dateTime: _logDateTime(json['dateTime']),
);

Map<String, dynamic> _$LogToJson(_Log instance) => <String, dynamic>{
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

_DAV _$DAVFromJson(Map<String, dynamic> json) => _DAV(
  uri: json['uri'] as String,
  user: json['user'] as String,
  password: json['password'] as String,
  fileName: json['fileName'] as String? ?? defaultDavFileName,
);

Map<String, dynamic> _$DAVToJson(_DAV instance) => <String, dynamic>{
  'uri': instance.uri,
  'user': instance.user,
  'password': instance.password,
  'fileName': instance.fileName,
};

_VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => _VersionInfo(
  clashName: json['clashName'] as String? ?? '',
  version: json['version'] as String? ?? '',
);

Map<String, dynamic> _$VersionInfoToJson(_VersionInfo instance) =>
    <String, dynamic>{
      'clashName': instance.clashName,
      'version': instance.version,
    };

_Traffic _$TrafficFromJson(Map<String, dynamic> json) =>
    _Traffic(up: json['up'] as num? ?? 0, down: json['down'] as num? ?? 0);

Map<String, dynamic> _$TrafficToJson(_Traffic instance) => <String, dynamic>{
  'up': instance.up,
  'down': instance.down,
};

_Proxy _$ProxyFromJson(Map<String, dynamic> json) => _Proxy(
  name: json['name'] as String,
  type: json['type'] as String,
  now: json['now'] as String?,
);

Map<String, dynamic> _$ProxyToJson(_Proxy instance) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'now': instance.now,
};

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  type: $enumDecode(_$GroupTypeEnumMap, json['type']),
  all:
      (json['all'] as List<dynamic>?)
          ?.map((e) => Proxy.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  now: json['now'] as String?,
  hidden: json['hidden'] as bool?,
  testUrl: json['testUrl'] as String?,
  icon: json['icon'] as String? ?? '',
  name: json['name'] as String,
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
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

_HotKeyAction _$HotKeyActionFromJson(Map<String, dynamic> json) =>
    _HotKeyAction(
      action: $enumDecode(_$HotActionEnumMap, json['action']),
      key: (json['key'] as num?)?.toInt(),
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$KeyboardModifierEnumMap, e))
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$HotKeyActionToJson(_HotKeyAction instance) =>
    <String, dynamic>{
      'action': _$HotActionEnumMap[instance.action]!,
      'key': instance.key,
      'modifiers': instance.modifiers
          .map((e) => _$KeyboardModifierEnumMap[e]!)
          .toList(),
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

_AndroidState _$AndroidStateFromJson(Map<String, dynamic> json) =>
    _AndroidState(
      currentProfileName: json['currentProfileName'] as String,
      stopText: json['stopText'] as String,
      onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool,
      crashlytics: json['crashlytics'] as bool,
    );

Map<String, dynamic> _$AndroidStateToJson(_AndroidState instance) =>
    <String, dynamic>{
      'currentProfileName': instance.currentProfileName,
      'stopText': instance.stopText,
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'crashlytics': instance.crashlytics,
    };

_Script _$ScriptFromJson(Map<String, dynamic> json) => _Script(
  id: json['id'] as String,
  label: json['label'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$ScriptToJson(_Script instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'content': instance.content,
};
