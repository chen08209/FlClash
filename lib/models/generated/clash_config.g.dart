// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../clash_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProxyGroupImpl _$$ProxyGroupImplFromJson(Map<String, dynamic> json) =>
    _$ProxyGroupImpl(
      name: json['name'] as String,
      type: GroupType.parseProfileType(json['type'] as String),
      proxies:
          (json['proxies'] as List<dynamic>?)?.map((e) => e as String).toList(),
      use: (json['use'] as List<dynamic>?)?.map((e) => e as String).toList(),
      interval: (json['interval'] as num?)?.toInt(),
      lazy: json['lazy'] as bool?,
      url: json['url'] as String?,
      timeout: (json['timeout'] as num?)?.toInt(),
      maxFailedTimes: (json['max-failed-times'] as num?)?.toInt(),
      filter: json['filter'] as String?,
      excludeFilter: json['expected-filter'] as String?,
      excludeType: json['exclude-type'] as String?,
      expectedStatus: (json['expected-status'] as num?)?.toInt(),
      hidden: json['hidden'] as bool?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$ProxyGroupImplToJson(_$ProxyGroupImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$GroupTypeEnumMap[instance.type]!,
      'proxies': instance.proxies,
      'use': instance.use,
      'interval': instance.interval,
      'lazy': instance.lazy,
      'url': instance.url,
      'timeout': instance.timeout,
      'max-failed-times': instance.maxFailedTimes,
      'filter': instance.filter,
      'expected-filter': instance.excludeFilter,
      'exclude-type': instance.excludeType,
      'expected-status': instance.expectedStatus,
      'hidden': instance.hidden,
      'icon': instance.icon,
    };

const _$GroupTypeEnumMap = {
  GroupType.Selector: 'Selector',
  GroupType.URLTest: 'URLTest',
  GroupType.Fallback: 'Fallback',
  GroupType.LoadBalance: 'LoadBalance',
  GroupType.Relay: 'Relay',
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
      routeAddress: (json['route-address'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TunImplToJson(_$TunImpl instance) => <String, dynamic>{
      'enable': instance.enable,
      'device': instance.device,
      'stack': _$TunStackEnumMap[instance.stack]!,
      'dns-hijack': instance.dnsHijack,
      'route-address': instance.routeAddress,
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
      listen: json['listen'] as String? ?? "0.0.0.0:1053",
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
      'listen': instance.listen,
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

_$GeoXUrlImpl _$$GeoXUrlImplFromJson(Map<String, dynamic> json) =>
    _$GeoXUrlImpl(
      mmdb: json['mmdb'] as String? ??
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb",
      asn: json['asn'] as String? ??
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb",
      geoip: json['geoip'] as String? ??
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat",
      geosite: json['geosite'] as String? ??
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat",
    );

Map<String, dynamic> _$$GeoXUrlImplToJson(_$GeoXUrlImpl instance) =>
    <String, dynamic>{
      'mmdb': instance.mmdb,
      'asn': instance.asn,
      'geoip': instance.geoip,
      'geosite': instance.geosite,
    };

_$ClashConfigSnippetImpl _$$ClashConfigSnippetImplFromJson(
        Map<String, dynamic> json) =>
    _$ClashConfigSnippetImpl(
      proxyGroups: (json['proxy-groups'] as List<dynamic>?)
              ?.map((e) => ProxyGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rule:
          (json['rule'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$ClashConfigSnippetImplToJson(
        _$ClashConfigSnippetImpl instance) =>
    <String, dynamic>{
      'proxy-groups': instance.proxyGroups,
      'rule': instance.rule,
    };

_$ClashConfigImpl _$$ClashConfigImplFromJson(Map<String, dynamic> json) =>
    _$ClashConfigImpl(
      mixedPort: (json['mixed-port'] as num?)?.toInt() ?? defaultMixedPort,
      mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']) ?? Mode.rule,
      allowLan: json['allow-lan'] as bool? ?? false,
      logLevel: $enumDecodeNullable(_$LogLevelEnumMap, json['log-level']) ??
          LogLevel.info,
      ipv6: json['ipv6'] as bool? ?? false,
      findProcessMode: $enumDecodeNullable(
              _$FindProcessModeEnumMap, json['find-process-mode'],
              unknownValue: FindProcessMode.off) ??
          FindProcessMode.off,
      keepAliveInterval: (json['keep-alive-interval'] as num?)?.toInt() ??
          defaultKeepAliveInterval,
      unifiedDelay: json['unified-delay'] as bool? ?? true,
      tcpConcurrent: json['tcp-concurrent'] as bool? ?? true,
      tun: json['tun'] == null
          ? defaultTun
          : Tun.safeFormJson(json['tun'] as Map<String, Object?>?),
      dns: json['dns'] == null
          ? defaultDns
          : Dns.safeDnsFromJson(json['dns'] as Map<String, Object?>),
      geoXUrl: json['geox-url'] == null
          ? defaultGeoXUrl
          : GeoXUrl.safeFormJson(json['geox-url'] as Map<String, Object?>?),
      geodataLoader:
          $enumDecodeNullable(_$GeodataLoaderEnumMap, json['geodata-loader']) ??
              GeodataLoader.memconservative,
      proxyGroups: (json['proxy-groups'] as List<dynamic>?)
              ?.map((e) => ProxyGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rule:
          (json['rule'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      globalUa: json['global-ua'] as String?,
      externalController: $enumDecodeNullable(
              _$ExternalControllerStatusEnumMap, json['external-controller']) ??
          ExternalControllerStatus.close,
      hosts: (json['hosts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$$ClashConfigImplToJson(_$ClashConfigImpl instance) =>
    <String, dynamic>{
      'mixed-port': instance.mixedPort,
      'mode': _$ModeEnumMap[instance.mode]!,
      'allow-lan': instance.allowLan,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'keep-alive-interval': instance.keepAliveInterval,
      'unified-delay': instance.unifiedDelay,
      'tcp-concurrent': instance.tcpConcurrent,
      'tun': instance.tun,
      'dns': instance.dns,
      'geox-url': instance.geoXUrl,
      'geodata-loader': _$GeodataLoaderEnumMap[instance.geodataLoader]!,
      'proxy-groups': instance.proxyGroups,
      'rule': instance.rule,
      'global-ua': instance.globalUa,
      'external-controller':
          _$ExternalControllerStatusEnumMap[instance.externalController]!,
      'hosts': instance.hosts,
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

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$GeodataLoaderEnumMap = {
  GeodataLoader.standard: 'standard',
  GeodataLoader.memconservative: 'memconservative',
};

const _$ExternalControllerStatusEnumMap = {
  ExternalControllerStatus.close: '',
  ExternalControllerStatus.open: '127.0.0.1:9090',
};
