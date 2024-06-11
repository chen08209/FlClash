// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../clash_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dns _$DnsFromJson(Map<String, dynamic> json) => Dns()
  ..enable = json['enable'] as bool
  ..ipv6 = json['ipv6'] as bool
  ..defaultNameserver = (json['default-nameserver'] as List<dynamic>)
      .map((e) => e as String)
      .toList()
  ..enhancedMode = json['enhanced-mode'] as String
  ..fakeIpRange = json['fake-ip-range'] as String
  ..useHosts = json['use-hosts'] as bool
  ..nameserver =
      (json['nameserver'] as List<dynamic>).map((e) => e as String).toList()
  ..fallback =
      (json['fallback'] as List<dynamic>).map((e) => e as String).toList()
  ..fakeIpFilter = (json['fake-ip-filter'] as List<dynamic>)
      .map((e) => e as String)
      .toList();

Map<String, dynamic> _$DnsToJson(Dns instance) => <String, dynamic>{
      'enable': instance.enable,
      'ipv6': instance.ipv6,
      'default-nameserver': instance.defaultNameserver,
      'enhanced-mode': instance.enhancedMode,
      'fake-ip-range': instance.fakeIpRange,
      'use-hosts': instance.useHosts,
      'nameserver': instance.nameserver,
      'fallback': instance.fallback,
      'fake-ip-filter': instance.fakeIpFilter,
    };

ClashConfig _$ClashConfigFromJson(Map<String, dynamic> json) => ClashConfig(
      mixedPort: (json['mixed-port'] as num?)?.toInt(),
      mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']),
      allowLan: json['allow-lan'] as bool?,
      logLevel: $enumDecodeNullable(_$LogLevelEnumMap, json['log-level']),
      externalController: json['external-controller'] as String? ?? '',
      tun: json['tun'] == null
          ? null
          : Tun.fromJson(json['tun'] as Map<String, dynamic>),
      dns: json['dns'] == null
          ? null
          : Dns.fromJson(json['dns'] as Map<String, dynamic>),
      rules:
          (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ClashConfigToJson(ClashConfig instance) =>
    <String, dynamic>{
      'mixed-port': instance.mixedPort,
      'mode': _$ModeEnumMap[instance.mode]!,
      'allow-lan': instance.allowLan,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'external-controller': instance.externalController,
      'tun': instance.tun,
      'dns': instance.dns,
      'rules': instance.rules,
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

_$TunImpl _$$TunImplFromJson(Map<String, dynamic> json) => _$TunImpl(
      enable: json['enable'] as bool? ?? false,
      device: json['device'] as String? ?? appName,
      stack: $enumDecodeNullable(_$TunStackEnumMap, json['stack']) ??
          TunStack.gvisor,
      dnsHijack: (json['dns-hijack'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["any:53"],
    );

Map<String, dynamic> _$$TunImplToJson(_$TunImpl instance) => <String, dynamic>{
      'enable': instance.enable,
      'device': instance.device,
      'stack': _$TunStackEnumMap[instance.stack]!,
      'dns-hijack': instance.dnsHijack,
    };

const _$TunStackEnumMap = {
  TunStack.gvisor: 'gvisor',
  TunStack.system: 'system',
  TunStack.mixed: 'mixed',
};
