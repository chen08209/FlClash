// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../clash_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashConfig _$ClashConfigFromJson(Map<String, dynamic> json) => ClashConfig()
  ..mixedPort = (json['mixed-port'] as num?)?.toInt() ?? 7890
  ..mode = $enumDecodeNullable(_$ModeEnumMap, json['mode']) ?? Mode.rule
  ..findProcessMode = $enumDecodeNullable(
          _$FindProcessModeEnumMap, json['find-process-mode']) ??
      FindProcessMode.off
  ..allowLan = json['allow-lan'] as bool
  ..logLevel =
      $enumDecodeNullable(_$LogLevelEnumMap, json['log-level']) ?? LogLevel.info
  ..externalController = json['external-controller'] as String? ?? ''
  ..keepAliveInterval = (json['keep-alive-interval'] as num?)?.toInt() ?? 30
  ..ipv6 = json['ipv6'] as bool? ?? false
  ..geodataLoader = json['geodata-loader'] as String? ?? 'memconservative'
  ..unifiedDelay = json['unified-delay'] as bool? ?? false
  ..tcpConcurrent = json['tcp-concurrent'] as bool? ?? false
  ..tun = Tun.fromJson(json['tun'] as Map<String, dynamic>)
  ..dns = Dns.safeDnsFromJson(json['dns'] as Map<String, Object?>)
  ..rules = (json['rules'] as List<dynamic>).map((e) => e as String).toList()
  ..globalRealUa = json['global-real-ua'] as String?
  ..geoXUrl = (json['geox-url'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {
        'mmdb':
            'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb',
        'asn':
            'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb',
        'geoip':
            'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat',
        'geosite':
            'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat'
      }
  ..hosts = (json['hosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {}
  ..includeRouteAddress = (json['include-route-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      []
  ..routeMode = $enumDecodeNullable(_$RouteModeEnumMap, json['route-mode']) ??
      RouteMode.config;

Map<String, dynamic> _$ClashConfigToJson(ClashConfig instance) =>
    <String, dynamic>{
      'mixed-port': instance.mixedPort,
      'mode': _$ModeEnumMap[instance.mode]!,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'allow-lan': instance.allowLan,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'external-controller': instance.externalController,
      'keep-alive-interval': instance.keepAliveInterval,
      'ipv6': instance.ipv6,
      'geodata-loader': instance.geodataLoader,
      'unified-delay': instance.unifiedDelay,
      'tcp-concurrent': instance.tcpConcurrent,
      'tun': instance.tun,
      'dns': instance.dns,
      'rules': instance.rules,
      'global-ua': instance.globalUa,
      'global-real-ua': instance.globalRealUa,
      'geox-url': instance.geoXUrl,
      'hosts': instance.hosts,
      'route-address': instance.routeAddress,
      'include-route-address': instance.includeRouteAddress,
      'route-mode': _$RouteModeEnumMap[instance.routeMode]!,
    };

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

const _$RouteModeEnumMap = {
  RouteMode.bypassPrivate: 'bypassPrivate',
  RouteMode.config: 'config',
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

_$FallbackFilterImpl _$$FallbackFilterImplFromJson(Map<String, dynamic> json) =>
    _$FallbackFilterImpl(
      geoip: json['geoip'] as bool? ?? true,
      geoipCode: json['geoip-code'] as String? ?? "CN",
      geosite: (json['geosite'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["gfw"],
      ipcidr: (json['ipcidr'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["240.0.0.0/4"],
      domain: (json['domain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["+.google.com", "+.facebook.com", "+.youtube.com"],
    );

Map<String, dynamic> _$$FallbackFilterImplToJson(
        _$FallbackFilterImpl instance) =>
    <String, dynamic>{
      'geoip': instance.geoip,
      'geoip-code': instance.geoipCode,
      'geosite': instance.geosite,
      'ipcidr': instance.ipcidr,
      'domain': instance.domain,
    };

_$DnsImpl _$$DnsImplFromJson(Map<String, dynamic> json) => _$DnsImpl(
      enable: json['enable'] as bool? ?? true,
      preferH3: json['prefer-h3'] as bool? ?? false,
      useHosts: json['use-hosts'] as bool? ?? true,
      useSystemHosts: json['use-system-hosts'] as bool? ?? true,
      respectRules: json['respect-rules'] as bool? ?? false,
      ipv6: json['ipv6'] as bool? ?? false,
      defaultNameserver: (json['default-nameserver'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["223.5.5.5"],
      enhancedMode:
          $enumDecodeNullable(_$DnsModeEnumMap, json['enhanced-mode']) ??
              DnsMode.fakeIp,
      fakeIpRange: json['fake-ip-range'] as String? ?? "198.18.0.1/16",
      fakeIpFilter: (json['fake-ip-filter'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["*.lan", "localhost.ptlogin2.qq.com"],
      nameserverPolicy:
          (json['nameserver-policy'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {
                "www.baidu.com": "114.114.114.114",
                "+.internal.crop.com": "10.0.0.1",
                "geosite:cn": "https://doh.pub/dns-query"
              },
      nameserver: (json['nameserver'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            "https://doh.pub/dns-query",
            "https://dns.alidns.com/dns-query"
          ],
      fallback: (json['fallback'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["tls://8.8.4.4", "tls://1.1.1.1"],
      proxyServerNameserver: (json['proxy-server-nameserver'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["https://doh.pub/dns-query"],
      fallbackFilter: json['fallback-filter'] == null
          ? const FallbackFilter()
          : FallbackFilter.fromJson(
              json['fallback-filter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DnsImplToJson(_$DnsImpl instance) => <String, dynamic>{
      'enable': instance.enable,
      'prefer-h3': instance.preferH3,
      'use-hosts': instance.useHosts,
      'use-system-hosts': instance.useSystemHosts,
      'respect-rules': instance.respectRules,
      'ipv6': instance.ipv6,
      'default-nameserver': instance.defaultNameserver,
      'enhanced-mode': _$DnsModeEnumMap[instance.enhancedMode]!,
      'fake-ip-range': instance.fakeIpRange,
      'fake-ip-filter': instance.fakeIpFilter,
      'nameserver-policy': instance.nameserverPolicy,
      'nameserver': instance.nameserver,
      'fallback': instance.fallback,
      'proxy-server-nameserver': instance.proxyServerNameserver,
      'fallback-filter': instance.fallbackFilter,
    };

const _$DnsModeEnumMap = {
  DnsMode.normal: 'normal',
  DnsMode.fakeIp: 'fake-ip',
  DnsMode.redirHost: 'redir-host',
  DnsMode.hosts: 'hosts',
};
