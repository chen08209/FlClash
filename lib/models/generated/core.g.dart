// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetupParamsImpl _$$SetupParamsImplFromJson(Map<String, dynamic> json) =>
    _$SetupParamsImpl(
      config: json['config'] as Map<String, dynamic>,
      selectedMap: Map<String, String>.from(json['selected-map'] as Map),
      testUrl: json['test-url'] as String,
    );

Map<String, dynamic> _$$SetupParamsImplToJson(_$SetupParamsImpl instance) =>
    <String, dynamic>{
      'config': instance.config,
      'selected-map': instance.selectedMap,
      'test-url': instance.testUrl,
    };

_$UpdateParamsImpl _$$UpdateParamsImplFromJson(Map<String, dynamic> json) =>
    _$UpdateParamsImpl(
      tun: Tun.fromJson(json['tun'] as Map<String, dynamic>),
      mixedPort: (json['mixed-port'] as num).toInt(),
      allowLan: json['allow-lan'] as bool,
      findProcessMode:
          $enumDecode(_$FindProcessModeEnumMap, json['find-process-mode']),
      mode: $enumDecode(_$ModeEnumMap, json['mode']),
      logLevel: $enumDecode(_$LogLevelEnumMap, json['log-level']),
      ipv6: json['ipv6'] as bool,
      tcpConcurrent: json['tcp-concurrent'] as bool,
      externalController: $enumDecode(
          _$ExternalControllerStatusEnumMap, json['external-controller']),
      unifiedDelay: json['unified-delay'] as bool,
    );

Map<String, dynamic> _$$UpdateParamsImplToJson(_$UpdateParamsImpl instance) =>
    <String, dynamic>{
      'tun': instance.tun,
      'mixed-port': instance.mixedPort,
      'allow-lan': instance.allowLan,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'mode': _$ModeEnumMap[instance.mode]!,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'tcp-concurrent': instance.tcpConcurrent,
      'external-controller':
          _$ExternalControllerStatusEnumMap[instance.externalController]!,
      'unified-delay': instance.unifiedDelay,
    };

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

const _$ExternalControllerStatusEnumMap = {
  ExternalControllerStatus.close: '',
  ExternalControllerStatus.open: '127.0.0.1:9090',
};

_$CoreStateImpl _$$CoreStateImplFromJson(Map<String, dynamic> json) =>
    _$CoreStateImpl(
      vpnProps: VpnProps.fromJson(json['vpn-props'] as Map<String, dynamic>?),
      onlyStatisticsProxy: json['only-statistics-proxy'] as bool,
      currentProfileName: json['current-profile-name'] as String,
      bypassDomain: (json['bypass-domain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CoreStateImplToJson(_$CoreStateImpl instance) =>
    <String, dynamic>{
      'vpn-props': instance.vpnProps,
      'only-statistics-proxy': instance.onlyStatisticsProxy,
      'current-profile-name': instance.currentProfileName,
      'bypass-domain': instance.bypassDomain,
    };

_$AndroidVpnOptionsImpl _$$AndroidVpnOptionsImplFromJson(
        Map<String, dynamic> json) =>
    _$AndroidVpnOptionsImpl(
      enable: json['enable'] as bool,
      port: (json['port'] as num).toInt(),
      accessControl: json['accessControl'] == null
          ? null
          : AccessControl.fromJson(
              json['accessControl'] as Map<String, dynamic>),
      allowBypass: json['allowBypass'] as bool,
      systemProxy: json['systemProxy'] as bool,
      bypassDomain: (json['bypassDomain'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ipv4Address: json['ipv4Address'] as String,
      ipv6Address: json['ipv6Address'] as String,
      routeAddress: (json['routeAddress'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dnsServerAddress: json['dnsServerAddress'] as String,
    );

Map<String, dynamic> _$$AndroidVpnOptionsImplToJson(
        _$AndroidVpnOptionsImpl instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'port': instance.port,
      'accessControl': instance.accessControl,
      'allowBypass': instance.allowBypass,
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'ipv4Address': instance.ipv4Address,
      'ipv6Address': instance.ipv6Address,
      'routeAddress': instance.routeAddress,
      'dnsServerAddress': instance.dnsServerAddress,
    };

_$InitParamsImpl _$$InitParamsImplFromJson(Map<String, dynamic> json) =>
    _$InitParamsImpl(
      homeDir: json['home-dir'] as String,
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$$InitParamsImplToJson(_$InitParamsImpl instance) =>
    <String, dynamic>{
      'home-dir': instance.homeDir,
      'version': instance.version,
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

_$UpdateGeoDataParamsImpl _$$UpdateGeoDataParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateGeoDataParamsImpl(
      geoType: json['geo-type'] as String,
      geoName: json['geo-name'] as String,
    );

Map<String, dynamic> _$$UpdateGeoDataParamsImplToJson(
        _$UpdateGeoDataParamsImpl instance) =>
    <String, dynamic>{
      'geo-type': instance.geoType,
      'geo-name': instance.geoName,
    };

_$AppMessageImpl _$$AppMessageImplFromJson(Map<String, dynamic> json) =>
    _$AppMessageImpl(
      type: $enumDecode(_$AppMessageTypeEnumMap, json['type']),
      data: json['data'],
    );

Map<String, dynamic> _$$AppMessageImplToJson(_$AppMessageImpl instance) =>
    <String, dynamic>{
      'type': _$AppMessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$AppMessageTypeEnumMap = {
  AppMessageType.log: 'log',
  AppMessageType.delay: 'delay',
  AppMessageType.request: 'request',
  AppMessageType.loaded: 'loaded',
};

_$InvokeMessageImpl _$$InvokeMessageImplFromJson(Map<String, dynamic> json) =>
    _$InvokeMessageImpl(
      type: $enumDecode(_$InvokeMessageTypeEnumMap, json['type']),
      data: json['data'],
    );

Map<String, dynamic> _$$InvokeMessageImplToJson(_$InvokeMessageImpl instance) =>
    <String, dynamic>{
      'type': _$InvokeMessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$InvokeMessageTypeEnumMap = {
  InvokeMessageType.protect: 'protect',
  InvokeMessageType.process: 'process',
};

_$DelayImpl _$$DelayImplFromJson(Map<String, dynamic> json) => _$DelayImpl(
      name: json['name'] as String,
      url: json['url'] as String,
      value: (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DelayImplToJson(_$DelayImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
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

_$ProviderSubscriptionInfoImpl _$$ProviderSubscriptionInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$ProviderSubscriptionInfoImpl(
      upload: (json['UPLOAD'] as num?)?.toInt() ?? 0,
      download: (json['DOWNLOAD'] as num?)?.toInt() ?? 0,
      total: (json['TOTAL'] as num?)?.toInt() ?? 0,
      expire: (json['EXPIRE'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProviderSubscriptionInfoImplToJson(
        _$ProviderSubscriptionInfoImpl instance) =>
    <String, dynamic>{
      'UPLOAD': instance.upload,
      'DOWNLOAD': instance.download,
      'TOTAL': instance.total,
      'EXPIRE': instance.expire,
    };

_$ExternalProviderImpl _$$ExternalProviderImplFromJson(
        Map<String, dynamic> json) =>
    _$ExternalProviderImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      path: json['path'] as String?,
      count: (json['count'] as num).toInt(),
      subscriptionInfo: subscriptionInfoFormCore(
          json['subscription-info'] as Map<String, Object?>?),
      isUpdating: json['isUpdating'] as bool? ?? false,
      vehicleType: json['vehicle-type'] as String,
      updateAt: DateTime.parse(json['update-at'] as String),
    );

Map<String, dynamic> _$$ExternalProviderImplToJson(
        _$ExternalProviderImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'path': instance.path,
      'count': instance.count,
      'subscription-info': instance.subscriptionInfo,
      'isUpdating': instance.isUpdating,
      'vehicle-type': instance.vehicleType,
      'update-at': instance.updateAt.toIso8601String(),
    };

_$ActionImpl _$$ActionImplFromJson(Map<String, dynamic> json) => _$ActionImpl(
      method: $enumDecode(_$ActionMethodEnumMap, json['method']),
      data: json['data'],
      id: json['id'] as String,
    );

Map<String, dynamic> _$$ActionImplToJson(_$ActionImpl instance) =>
    <String, dynamic>{
      'method': _$ActionMethodEnumMap[instance.method]!,
      'data': instance.data,
      'id': instance.id,
    };

const _$ActionMethodEnumMap = {
  ActionMethod.message: 'message',
  ActionMethod.initClash: 'initClash',
  ActionMethod.getIsInit: 'getIsInit',
  ActionMethod.forceGc: 'forceGc',
  ActionMethod.shutdown: 'shutdown',
  ActionMethod.validateConfig: 'validateConfig',
  ActionMethod.updateConfig: 'updateConfig',
  ActionMethod.getConfig: 'getConfig',
  ActionMethod.getProxies: 'getProxies',
  ActionMethod.changeProxy: 'changeProxy',
  ActionMethod.getTraffic: 'getTraffic',
  ActionMethod.getTotalTraffic: 'getTotalTraffic',
  ActionMethod.resetTraffic: 'resetTraffic',
  ActionMethod.asyncTestDelay: 'asyncTestDelay',
  ActionMethod.getConnections: 'getConnections',
  ActionMethod.closeConnections: 'closeConnections',
  ActionMethod.resetConnections: 'resetConnections',
  ActionMethod.closeConnection: 'closeConnection',
  ActionMethod.getExternalProviders: 'getExternalProviders',
  ActionMethod.getExternalProvider: 'getExternalProvider',
  ActionMethod.updateGeoData: 'updateGeoData',
  ActionMethod.updateExternalProvider: 'updateExternalProvider',
  ActionMethod.sideLoadExternalProvider: 'sideLoadExternalProvider',
  ActionMethod.startLog: 'startLog',
  ActionMethod.stopLog: 'stopLog',
  ActionMethod.startListener: 'startListener',
  ActionMethod.stopListener: 'stopListener',
  ActionMethod.getCountryCode: 'getCountryCode',
  ActionMethod.getMemory: 'getMemory',
  ActionMethod.crash: 'crash',
  ActionMethod.setupConfig: 'setupConfig',
  ActionMethod.setState: 'setState',
  ActionMethod.startTun: 'startTun',
  ActionMethod.stopTun: 'stopTun',
  ActionMethod.getRunTime: 'getRunTime',
  ActionMethod.updateDns: 'updateDns',
  ActionMethod.getAndroidVpnOptions: 'getAndroidVpnOptions',
  ActionMethod.getCurrentProfileName: 'getCurrentProfileName',
};

_$ActionResultImpl _$$ActionResultImplFromJson(Map<String, dynamic> json) =>
    _$ActionResultImpl(
      method: $enumDecode(_$ActionMethodEnumMap, json['method']),
      data: json['data'],
      id: json['id'] as String?,
      code: $enumDecodeNullable(_$ResultTypeEnumMap, json['code']) ??
          ResultType.success,
    );

Map<String, dynamic> _$$ActionResultImplToJson(_$ActionResultImpl instance) =>
    <String, dynamic>{
      'method': _$ActionMethodEnumMap[instance.method]!,
      'data': instance.data,
      'id': instance.id,
      'code': _$ResultTypeEnumMap[instance.code]!,
    };

const _$ResultTypeEnumMap = {
  ResultType.success: 0,
  ResultType.error: -1,
};
