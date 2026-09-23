import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'generated/clash_config.freezed.dart';

part 'generated/clash_config.g.dart';

const defaultClashConfig = PatchClashConfig();

const defaultTun = Tun();
const defaultDns = Dns();
const defaultNtp = Ntp();

/// What a profile that brings no DNS section of its own is given, so the core
/// always resolves. The user's own override set starts empty.
const baselineDnsOverrideKeys = {
  DnsOverrideKey.enable,
  DnsOverrideKey.enhancedMode,
  DnsOverrideKey.nameserver,
};
const defaultGeoXUrl = {
  GeoResource.MMDB:
      'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb',
  GeoResource.ASN:
      'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb',
  GeoResource.GEOIP:
      'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat',
  GeoResource.GEOSITE:
      'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat',
};

const defaultMixedPort = 7890;
const defaultKeepAliveInterval = 30;

const defaultBypassPrivateRouteAddress = [
  '1.0.0.0/8',
  '2.0.0.0/7',
  '4.0.0.0/6',
  '8.0.0.0/7',
  '11.0.0.0/8',
  '12.0.0.0/6',
  '16.0.0.0/4',
  '32.0.0.0/3',
  '64.0.0.0/3',
  '96.0.0.0/4',
  '112.0.0.0/5',
  '120.0.0.0/6',
  '124.0.0.0/7',
  '126.0.0.0/8',
  '128.0.0.0/3',
  '160.0.0.0/5',
  '168.0.0.0/8',
  '169.0.0.0/9',
  '169.128.0.0/10',
  '169.192.0.0/11',
  '169.224.0.0/12',
  '169.240.0.0/13',
  '169.248.0.0/14',
  '169.252.0.0/15',
  '169.255.0.0/16',
  '170.0.0.0/7',
  '172.0.0.0/12',
  '172.32.0.0/11',
  '172.64.0.0/10',
  '172.128.0.0/9',
  '173.0.0.0/8',
  '174.0.0.0/7',
  '176.0.0.0/4',
  '192.0.0.0/9',
  '192.128.0.0/11',
  '192.160.0.0/13',
  '192.169.0.0/16',
  '192.170.0.0/15',
  '192.172.0.0/14',
  '192.176.0.0/12',
  '192.192.0.0/10',
  '193.0.0.0/8',
  '194.0.0.0/7',
  '196.0.0.0/6',
  '200.0.0.0/5',
  '208.0.0.0/4',
  '240.0.0.0/5',
  '248.0.0.0/6',
  '252.0.0.0/7',
  '254.0.0.0/8',
  '255.0.0.0/9',
  '255.128.0.0/10',
  '255.192.0.0/11',
  '255.224.0.0/12',
  '255.240.0.0/13',
  '255.248.0.0/14',
  '255.252.0.0/15',
  '255.254.0.0/16',
  '255.255.0.0/17',
  '255.255.128.0/18',
  '255.255.192.0/19',
  '255.255.224.0/20',
  '255.255.240.0/21',
  '255.255.248.0/22',
  '255.255.252.0/23',
  '255.255.254.0/24',
  '255.255.255.0/25',
  '255.255.255.128/26',
  '255.255.255.192/27',
  '255.255.255.224/28',
  '255.255.255.240/29',
  '255.255.255.248/30',
  '255.255.255.252/31',
  '255.255.255.254/32',
  '::/1',
  '8000::/2',
  'c000::/3',
  'e000::/4',
  'f000::/5',
  'f800::/6',
  'fe00::/9',
  'fec0::/10',
];

@freezed
abstract class ProxyGroup with _$ProxyGroup {
  const factory ProxyGroup({
    int? profileId,
    @JsonKey(fromJson: Snowflake.buildId) required int id,
    required String name,
    required GroupType type,
    List<String>? proxies,
    List<String>? use,
    int? interval,
    bool? lazy,
    @JsonKey(name: 'disable-udp') bool? disableUDP,
    String? url,
    int? timeout,
    @JsonKey(name: 'max-failed-times') int? maxFailedTimes,
    String? filter,
    @JsonKey(name: 'exclude-filter') String? excludeFilter,
    @JsonKey(name: 'exclude-type') String? excludeType,
    @JsonKey(name: 'expected-status') String? expectedStatus,
    int? tolerance,
    LoadBalanceStrategy? strategy,
    @JsonKey(name: 'include-all') bool? includeAll,
    @JsonKey(name: 'include-all-proxies') bool? includeAllProxies,
    @JsonKey(name: 'include-all-providers') bool? includeAllProviders,
    bool? hidden,
    String? icon,
    String? order,
  }) = _ProxyGroup;

  factory ProxyGroup.fromJson(Map<String, Object?> json) =>
      _$ProxyGroupFromJson(json);
}

extension ProxyGroupExt on ProxyGroup {
  /// Only what `GroupCommonOption` and the per-type option structs read, so the
  /// generated config carries no FlClash bookkeeping and no null placeholders.
  Map<String, dynamic> get definition {
    return {
      'name': name,
      'type': type.value,
      if (proxies?.isNotEmpty == true) 'proxies': proxies,
      if (use?.isNotEmpty == true) 'use': use,
      if (url?.isNotEmpty == true) 'url': url,
      if (interval != null) 'interval': interval,
      if (timeout != null) 'timeout': timeout,
      if (maxFailedTimes != null) 'max-failed-times': maxFailedTimes,
      if (lazy != null) 'lazy': lazy,
      if (disableUDP != null) 'disable-udp': disableUDP,
      if (filter?.isNotEmpty == true) 'filter': filter,
      if (excludeFilter?.isNotEmpty == true) 'exclude-filter': excludeFilter,
      if (excludeType?.isNotEmpty == true) 'exclude-type': excludeType,
      if (expectedStatus?.isNotEmpty == true) 'expected-status': expectedStatus,
      if (includeAll != null) 'include-all': includeAll,
      if (includeAllProxies != null) 'include-all-proxies': includeAllProxies,
      if (includeAllProviders != null)
        'include-all-providers': includeAllProviders,
      if (hidden != null) 'hidden': hidden,
      if (icon?.isNotEmpty == true) 'icon': icon,
      if (type == GroupType.URLTest && tolerance != null)
        'tolerance': tolerance,
      if (type == GroupType.LoadBalance && strategy != null)
        'strategy': strategy!.value,
    };
  }
}

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

extension ProxyExt on Proxy {
  List<String> get searchFields => [name, type];
}

/// The `type` values `adapter.ParseProxy` accepts, in its own order.
const customProxyTypes = [
  'ss',
  'ssr',
  'socks5',
  'http',
  'vmess',
  'vless',
  'snell',
  'trojan',
  'hysteria',
  'hysteria2',
  'wireguard',
  'tuic',
  'shadowquic',
  'gost-relay',
  'direct',
  'dns',
  'reject',
  'rematch',
  'ssh',
  'mieru',
  'anytls',
  'sudoku',
  'masque',
  'trusttunnel',
  'openvpn',
  'tailscale',
  'zerotier',
  'easytier',
];

/// One entry of a custom overwrite's `proxies`, kept as the raw mapping the
/// core parses, since each proxy type reads its own set of keys.
@freezed
abstract class CustomProxy with _$CustomProxy {
  const factory CustomProxy({
    int? profileId,
    @JsonKey(fromJson: Snowflake.buildId) required int id,
    @Default({}) Map<String, dynamic> definition,
    String? order,
  }) = _CustomProxy;

  factory CustomProxy.fromJson(Map<String, Object?> json) =>
      _$CustomProxyFromJson(json);

  factory CustomProxy.fromDefinition(Map definition, {int? id}) {
    return CustomProxy(
      id: id ?? snowflake.id,
      definition: Map<String, dynamic>.from(definition),
    );
  }
}

extension CustomProxyExt on CustomProxy {
  String get name => definition['name']?.toString() ?? '';

  String get type => definition['type']?.toString() ?? '';

  String? get server => definition['server']?.toString();

  int? get port => switch (definition['port']) {
    final int port => port,
    final Object port => int.tryParse(port.toString()),
    null => null,
  };

  String? get address {
    final server = this.server;
    if (server == null || server.isEmpty) {
      return null;
    }
    final port = this.port;
    return port == null ? server : '$server:$port';
  }

  List<String> get searchFields => [name, type, ?server];

  String get definitionYaml => yaml.encode(definition);

  /// Throws a [FormatException] unless [content] is a mapping that names a
  /// proxy and its type.
  CustomProxy withDefinitionYaml(String content) {
    final document = _plainYaml(loadYaml(content));
    if (document is! Map<String, Object?> ||
        document['name'] is! String ||
        document['type'] is! String) {
      throw const FormatException('Not a proxy mapping');
    }
    return copyWith(definition: document);
  }

  CustomProxy withValue(String key, Object? value) {
    final next = Map<String, dynamic>.from(definition);
    if (value == null || value == '') {
      next.remove(key);
    } else {
      next[key] = value;
    }
    return copyWith(definition: next);
  }
}

@freezed
sealed class OverwriteIssue with _$OverwriteIssue {
  const factory OverwriteIssue.emptyName() = EmptyNameIssue;

  const factory OverwriteIssue.reservedName(String name) = ReservedNameIssue;

  const factory OverwriteIssue.duplicateName(String name) = DuplicateNameIssue;

  const factory OverwriteIssue.coreRejected(String message) = CoreRejectedIssue;

  const factory OverwriteIssue.missingProxies(List<String> names) =
      MissingProxiesIssue;

  const factory OverwriteIssue.missingProviders(List<String> names) =
      MissingProvidersIssue;

  const factory OverwriteIssue.noProxySource() = NoProxySourceIssue;

  const factory OverwriteIssue.groupLoop(List<String> names) = GroupLoopIssue;

  const factory OverwriteIssue.invalidPayload(RulePayloadError error) =
      InvalidPayloadIssue;

  const factory OverwriteIssue.missingRuleSet(String name) =
      MissingRuleSetIssue;

  const factory OverwriteIssue.missingSubRule(String name) =
      MissingSubRuleIssue;

  const factory OverwriteIssue.missingTarget(String name) = MissingTargetIssue;
}

@freezed
abstract class CustomOverwriteIssues with _$CustomOverwriteIssues {
  const factory CustomOverwriteIssues({
    @Default({}) Map<int, List<OverwriteIssue>> proxies,
    @Default({}) Map<int, List<OverwriteIssue>> proxyGroups,
    @Default({}) Map<int, List<OverwriteIssue>> rules,
  }) = _CustomOverwriteIssues;
}

@freezed
abstract class CustomOverwriteDate with _$CustomOverwriteDate {
  const factory CustomOverwriteDate({
    @Default(false) bool loaded,
    @Default([]) List<String> proxyNames,
    @Default({}) Map<String, String> proxyTypes,
    @Default([]) List<ProxyGroup> proxyGroups,
    @Default({}) Set<String> proxyProviders,
    @Default({}) Set<String> ruleProviders,
    @Default({}) Set<String> ruleTargets,
    @Default({}) Set<String> subRules,
  }) = _CustomOverwriteDate;
}

@freezed
abstract class CustomOverwriteSelectorState
    with _$CustomOverwriteSelectorState {
  const factory CustomOverwriteSelectorState({
    required bool loaded,
    required List<Proxy> proxies,
    required List<String> subRules,
    required List<String> proxyProviders,
    required List<String> ruleProviders,
  }) = _CustomOverwriteSelectorState;
}

@freezed
abstract class OverwriteIncludeSelectorState
    with _$OverwriteIncludeSelectorState {
  const factory OverwriteIncludeSelectorState({
    required bool includeAll,
    required List<String> names,
  }) = _OverwriteIncludeSelectorState;
}

@freezed
abstract class RuleProvider with _$RuleProvider {
  const factory RuleProvider({required String name}) = _RuleProvider;

  factory RuleProvider.fromJson(Map<String, Object?> json) =>
      _$RuleProviderFromJson(json);
}

@freezed
abstract class ProxyProvider with _$ProxyProvider {
  const factory ProxyProvider({required String name}) = _ProxyProvider;

  factory ProxyProvider.fromJson(Map<String, Object?> json) =>
      _$ProxyProviderFromJson(json);
}

@freezed
abstract class Sniffer with _$Sniffer {
  const factory Sniffer({
    @Default(false) bool enable,
    @Default(true) @JsonKey(name: 'override-destination') bool overrideDest,
    @Default([]) List<String> sniffing,
    @Default([]) @JsonKey(name: 'force-domain') List<String> forceDomain,
    @Default([]) @JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,
    @Default([]) @JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,
    @Default([]) @JsonKey(name: 'skip-domain') List<String> skipDomain,
    @Default([]) @JsonKey(name: 'port-whitelist') List<String> port,
    @Default(true) @JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,
    @Default(true) @JsonKey(name: 'parse-pure-ip') bool parsePureIp,
    @Default({}) Map<String, SnifferConfig> sniff,
  }) = _Sniffer;

  factory Sniffer.fromJson(Map<String, Object?> json) =>
      _$SnifferFromJson(json);
}

List<String> _formJsonPorts(List? ports) {
  return ports?.map((item) => item.toString()).toList() ?? [];
}

@freezed
abstract class SnifferConfig with _$SnifferConfig {
  const factory SnifferConfig({
    @Default([]) @JsonKey(fromJson: _formJsonPorts) List<String> ports,
    @JsonKey(name: 'override-destination') bool? overrideDest,
  }) = _SnifferConfig;

  factory SnifferConfig.fromJson(Map<String, Object?> json) =>
      _$SnifferConfigFromJson(json);
}

@freezed
abstract class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(appName) String device,
    @JsonKey(name: 'auto-route') @Default(false) bool autoRoute,
    @Default(TunStack.mips) TunStack stack,
    @JsonKey(name: 'dns-hijack') @Default(['any:53']) List<String> dnsHijack,
    @JsonKey(name: 'route-address') @Default([]) List<String> routeAddress,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);

  factory Tun.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTun;
    }
    return decodeOrRestoreDefault(
      'tun config',
      () => Tun.fromJson(json),
      () => defaultTun,
    );
  }
}

extension TunExt on Tun {
  List<String> resolveRouteAddress(RouteMode routeMode) =>
      routeMode == RouteMode.bypassPrivate
      ? defaultBypassPrivateRouteAddress
      : routeAddress;

  Tun getRealTun(RouteMode routeMode) {
    final mRouteAddress = resolveRouteAddress(routeMode);
    return switch (system.isDesktop) {
      true => copyWith(autoRoute: true, routeAddress: []),
      false => copyWith(
        autoRoute: mRouteAddress.isEmpty ? true : false,
        routeAddress: mRouteAddress,
      ),
    };
  }
}

@freezed
abstract class FallbackFilter with _$FallbackFilter {
  const factory FallbackFilter({
    @Default(true) bool geoip,
    @Default('CN') @JsonKey(name: 'geoip-code') String geoipCode,
    @Default([]) List<String> geosite,
    @Default([]) List<String> ipcidr,
    @Default([]) List<String> domain,
  }) = _FallbackFilter;

  factory FallbackFilter.fromJson(Map<String, Object?> json) =>
      _$FallbackFilterFromJson(json);
}

@freezed
abstract class Dns with _$Dns {
  const factory Dns({
    @Default(true) bool enable,
    @Default('0.0.0.0:1053') String listen,
    @Default(0) @JsonKey(name: 'listen-routing-mark') int listenRoutingMark,
    @Default(false) @JsonKey(name: 'prefer-h3') bool preferH3,
    @Default(true) @JsonKey(name: 'use-hosts') bool useHosts,
    @Default(true) @JsonKey(name: 'use-system-hosts') bool useSystemHosts,
    @Default(false) @JsonKey(name: 'respect-rules') bool respectRules,
    @Default(false) bool ipv6,
    @Default(100) @JsonKey(name: 'ipv6-timeout') int ipv6Timeout,
    @Default(DnsCacheAlgorithm.lru)
    @JsonKey(name: 'cache-algorithm')
    DnsCacheAlgorithm cacheAlgorithm,
    @Default(4096) @JsonKey(name: 'cache-max-size') int cacheMaxSize,
    @Default(['114.114.114.114', '223.5.5.5', '8.8.8.8', '1.0.0.1'])
    @JsonKey(name: 'default-nameserver')
    List<String> defaultNameserver,
    @Default(DnsMode.fakeIp)
    @JsonKey(name: 'enhanced-mode')
    DnsMode enhancedMode,
    @Default('198.18.0.1/16')
    @JsonKey(name: 'fake-ip-range')
    String fakeIpRange,
    @Default('fdfe:dcba:9876::1/64')
    @JsonKey(name: 'fake-ip-range6')
    String fakeIpRange6,
    @Default([
      'dns.msftnsci.com',
      'www.msftnsci.com',
      'www.msftconnecttest.com',
    ])
    @JsonKey(name: 'fake-ip-filter')
    List<String> fakeIpFilter,
    @Default(FakeIpFilterMode.blacklist)
    @JsonKey(name: 'fake-ip-filter-mode')
    FakeIpFilterMode fakeIpFilterMode,
    @Default(1) @JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,
    @Default({})
    @JsonKey(name: 'nameserver-policy')
    Map<String, String> nameserverPolicy,
    @Default(['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query'])
    List<String> nameserver,
    @Default([]) List<String> fallback,
    @Default(false)
    @JsonKey(name: 'fallback-lazy-query')
    bool fallbackLazyQuery,
    @Default([])
    @JsonKey(name: 'proxy-server-nameserver')
    List<String> proxyServerNameserver,
    @Default({})
    @JsonKey(name: 'proxy-server-nameserver-policy')
    Map<String, String> proxyServerNameserverPolicy,
    @Default([])
    @JsonKey(name: 'direct-nameserver')
    List<String> directNameserver,
    @Default(false)
    @JsonKey(name: 'direct-nameserver-follow-policy')
    bool directNameserverFollowPolicy,
    @Default(FallbackFilter())
    @JsonKey(name: 'fallback-filter')
    FallbackFilter fallbackFilter,
  }) = _Dns;

  factory Dns.fromJson(Map<String, Object?> json) => _$DnsFromJson(json);

  factory Dns.safeDnsFromJson(Map<String, Object?> json) {
    return decodeOrRestoreDefault(
      'dns config',
      () => Dns.fromJson(json),
      () => const Dns(),
    );
  }
}

const _dnsOverrideKeysJsonKey = 'dns-override-keys';

/// Configs saved before the key set existed overrode the whole DNS section as
/// the model held it then.
const _legacyDnsOverrideKeys = {
  DnsOverrideKey.enable,
  DnsOverrideKey.listen,
  DnsOverrideKey.useHosts,
  DnsOverrideKey.useSystemHosts,
  DnsOverrideKey.ipv6,
  DnsOverrideKey.respectRules,
  DnsOverrideKey.preferH3,
  DnsOverrideKey.enhancedMode,
  DnsOverrideKey.fakeIpRange,
  DnsOverrideKey.fakeIpFilter,
  DnsOverrideKey.defaultNameserver,
  DnsOverrideKey.nameserverPolicy,
  DnsOverrideKey.nameserver,
  DnsOverrideKey.fallback,
  DnsOverrideKey.proxyServerNameserver,
  DnsOverrideKey.fallbackFilterGeoip,
  DnsOverrideKey.fallbackFilterGeoipCode,
  DnsOverrideKey.fallbackFilterGeosite,
  DnsOverrideKey.fallbackFilterIpcidr,
  DnsOverrideKey.fallbackFilterDomain,
};

Map<String, Object?> _withLegacyDnsOverrideKeys(Map<String, Object?> json) {
  if (json.containsKey(_dnsOverrideKeysJsonKey) || !json.containsKey('dns')) {
    return json;
  }
  return {
    ...json,
    _dnsOverrideKeysJsonKey: [
      for (final key in _legacyDnsOverrideKeys) key.path,
    ],
  };
}

extension DnsOverrideExt on Dns {
  // toJson leaves nested models as objects; the fragment is read as plain maps.
  Map<String, Object?> get _json {
    final json = toJson();
    json[DnsOverrideKey.fallbackFilterSection] = fallbackFilter.toJson();
    json[DnsOverrideKey.nameserverPolicy.path] = _splitPolicyServers(
      nameserverPolicy,
    );
    json[DnsOverrideKey.proxyServerNameserverPolicy.path] = _splitPolicyServers(
      proxyServerNameserverPolicy,
    );
    return json;
  }

  Object? valueOf(DnsOverrideKey key) {
    final json = _json;
    if (!key.isFallbackFilter) {
      return json[key.path];
    }
    final section = json[DnsOverrideKey.fallbackFilterSection] as Map;
    return section[key.jsonKey];
  }

  Map<String, Object?> overrideJson(Set<DnsOverrideKey> keys) {
    final json = _json;
    final section = json[DnsOverrideKey.fallbackFilterSection] as Map;
    final result = <String, Object?>{};
    for (final key in DnsOverrideKey.values) {
      if (!keys.contains(key)) {
        continue;
      }
      if (!key.isFallbackFilter) {
        result[key.path] = json[key.path];
        continue;
      }
      final filter =
          result.putIfAbsent(
                DnsOverrideKey.fallbackFilterSection,
                () => <String, Object?>{},
              )
              as Map<String, Object?>;
      filter[key.jsonKey] = section[key.jsonKey];
    }
    return result;
  }

  String overrideYaml(Set<DnsOverrideKey> keys) =>
      yaml.encode(overrideJson(keys));

  /// Reads an edited override document back; the keys it names become the
  /// override set. Throws on a key the model does not know or a value it
  /// cannot hold.
  ({Dns dns, Set<DnsOverrideKey> keys}) applyOverrideYaml(String content) {
    final document = _plainYaml(loadYaml(content));
    if (document == null) {
      return (dns: this, keys: const {});
    }
    if (document is! Map) {
      throw const FormatException('The override must be a map of DNS keys');
    }
    final keys = <DnsOverrideKey>{};
    final json = _json;
    final filter = Map<String, Object?>.from(
      json[DnsOverrideKey.fallbackFilterSection] as Map,
    );
    void take(String path, Object? value) {
      final key = DnsOverrideKey.values.firstWhereOrNull(
        (key) => key.path == path,
      );
      if (key == null) {
        throw FormatException('Unknown DNS key: $path');
      }
      keys.add(key);
      if (key.isFallbackFilter) {
        filter[key.jsonKey] = value;
      } else {
        json[path] = value;
      }
    }

    for (final entry in document.entries) {
      final name = entry.key.toString();
      if (name != DnsOverrideKey.fallbackFilterSection) {
        take(name, entry.value);
        continue;
      }
      if (entry.value is! Map) {
        throw FormatException('$name must be a map');
      }
      for (final sub in (entry.value as Map).entries) {
        take('$name.${sub.key}', sub.value);
      }
    }
    json[DnsOverrideKey.fallbackFilterSection] = filter;
    for (final policy in _policyKeys) {
      json[policy.path] = _joinPolicyServers(json[policy.path]);
    }
    return (dns: Dns.fromJson(json), keys: keys);
  }
}

Object? _plainYaml(Object? node) => switch (node) {
  YamlMap() => {
    for (final entry in node.entries)
      entry.key.toString(): _plainYaml(entry.value),
  },
  YamlList() => [for (final item in node) _plainYaml(item)],
  _ => node,
};

const _policyKeys = [
  DnsOverrideKey.nameserverPolicy,
  DnsOverrideKey.proxyServerNameserverPolicy,
];

Map<String, Object> _splitPolicyServers(Map<String, String> policy) => {
  for (final entry in policy.entries)
    entry.key: entry.value.splitByMultipleSeparators,
};

Object? _joinPolicyServers(Object? value) => switch (value) {
  Map() => {
    for (final entry in value.entries)
      entry.key.toString(): switch (entry.value) {
        List() => (entry.value as List).join(', '),
        final server => server.toString(),
      },
  },
  _ => value,
};

Map<String, dynamic> mergeDnsOverride(
  Map<String, dynamic> raw,
  Map<String, Object?> override,
) {
  final merged = Map<String, dynamic>.from(raw);
  for (final entry in override.entries) {
    final current = merged[entry.key];
    final value = entry.value;
    merged[entry.key] = current is Map && value is Map
        ? {...Map<String, dynamic>.from(current), ...value}
        : value;
  }
  return merged;
}

@freezed
abstract class Ntp with _$Ntp {
  const factory Ntp({
    @Default(false) bool enable,
    @Default('time.apple.com') String server,
    @Default(123) int port,
    @Default(30) int interval,
    @Default('') @JsonKey(name: 'dialer-proxy') String dialerProxy,
    @Default(false) @JsonKey(name: 'write-to-system') bool writeToSystem,
  }) = _Ntp;

  factory Ntp.fromJson(Map<String, Object?> json) => _$NtpFromJson(json);

  factory Ntp.safeNtpFromJson(Map<String, Object?> json) {
    return decodeOrRestoreDefault(
      'ntp config',
      () => Ntp.fromJson(json),
      () => const Ntp(),
    );
  }
}

const _ntpOverrideKeysJsonKey = 'ntp-override-keys';

extension NtpOverrideExt on Ntp {
  Map<String, Object?> overrideJson(Set<NtpOverrideKey> keys) {
    final json = toJson();
    return {
      for (final key in NtpOverrideKey.values)
        if (keys.contains(key)) key.path: json[key.path],
    };
  }

  String overrideYaml(Set<NtpOverrideKey> keys) =>
      yaml.encode(overrideJson(keys));

  ({Ntp ntp, Set<NtpOverrideKey> keys}) applyOverrideYaml(String content) {
    final document = _plainYaml(loadYaml(content));
    if (document == null) {
      return (ntp: this, keys: const {});
    }
    if (document is! Map) {
      throw const FormatException('The override must be a map of NTP keys');
    }
    final keys = <NtpOverrideKey>{};
    final json = toJson();
    for (final entry in document.entries) {
      final path = entry.key.toString();
      final key = NtpOverrideKey.values.firstWhereOrNull(
        (key) => key.path == path,
      );
      if (key == null) {
        throw FormatException('Unknown NTP key: $path');
      }
      keys.add(key);
      json[path] = entry.value;
    }
    return (ntp: Ntp.fromJson(json), keys: keys);
  }
}

@freezed
abstract class Rule with _$Rule {
  const factory Rule({
    @Default(-1) int id,
    @Default(RuleAction.DOMAIN) RuleAction ruleAction,
    String? content,
    String? ruleTarget,
    String? ruleProvider,
    String? subRule,
    @Default(false) bool noResolve,
    @Default(false) bool src,
    String? order,
  }) = _Rule;

  factory Rule.init() {
    return Rule(
      ruleAction: RuleAction.DOMAIN,
      ruleTarget: RuleTarget.DIRECT.name,
    );
  }

  // Mirrors mihomo's ParseRulePayload with needTarget set.
  factory Rule.parse(String value, {int? id}) {
    id ??= snowflake.id;
    final fields = value.split(',').map((item) => item.trim()).toList();
    final type = fields.first.toUpperCase();
    if (type.isEmpty) {
      return Rule(
        id: id,
        ruleAction: RuleAction.DOMAIN,
        ruleTarget: RuleTarget.DIRECT.name,
      );
    }
    final action = RuleAction.values.firstWhere(
      (item) => item.value == type,
      orElse: () => RuleAction.DOMAIN,
    );
    final rest = fields.sublist(1);
    String? payload;
    String? target;
    var params = const <String>[];
    if (action == RuleAction.MATCH) {
      target = rest.firstOrNull;
    } else if (action.hasCommaPayload) {
      target = rest.lastOrNull;
      payload = rest.length > 1
          ? rest.sublist(0, rest.length - 1).join(',')
          : null;
    } else {
      payload = rest.elementAtOrNull(0);
      target = rest.elementAtOrNull(1);
      params = rest.skip(2).toList();
    }
    payload = payload?.isNotEmpty == true ? payload : null;
    target = target?.isNotEmpty == true ? target : null;

    return Rule(
      id: id,
      ruleAction: action,
      content: action == RuleAction.RULE_SET ? null : payload,
      ruleProvider: action == RuleAction.RULE_SET ? payload : null,
      ruleTarget: action == RuleAction.SUB_RULE ? null : target,
      subRule: action == RuleAction.SUB_RULE ? target : null,
      src: params.contains('src'),
      noResolve: params.contains('no-resolve'),
    );
  }

  factory Rule.fromJson(Map<String, Object?> json) => _$RuleFromJson(json);
}

extension RuleExt on Rule {
  Rule autoOrder(Rule rule, String? a, String? b) {
    final newRule = rule.order?.isNotEmpty != true
        ? rule.copyWith(order: indexing.generateKeyBetween(a, b))
        : rule;
    return newRule;
  }

  String? get realContent {
    return switch (ruleAction) {
      RuleAction.MATCH => null,
      RuleAction.RULE_SET => ruleProvider,
      _ => content,
    };
  }

  String? get realTarget {
    return switch (ruleAction == RuleAction.SUB_RULE) {
      true => subRule,
      false => ruleTarget,
    };
  }

  String? targetErrorTip(String invalidSubRuleTip, String invalidPolicyTip) {
    return switch (ruleAction == RuleAction.SUB_RULE) {
      true => invalidSubRuleTip,
      false => invalidPolicyTip,
    };
  }

  /// The core rejects the whole config over one of these, taking the profile
  /// down with it, so they are caught before the rule can be saved.
  RulePayloadError? get payloadError {
    final payload = realContent?.trim() ?? '';
    if (payload.isEmpty) {
      return null;
    }
    switch (ruleAction) {
      case RuleAction.NETWORK:
        return const ['tcp', 'udp'].contains(payload.toLowerCase())
            ? null
            : RulePayloadError.network;
      case RuleAction.DST_PORT:
      case RuleAction.SRC_PORT:
      case RuleAction.IN_PORT:
      case RuleAction.UID:
        return _parseRanges(payload) == null
            ? RulePayloadError.numberRange
            : null;
      case RuleAction.DSCP:
        final bounds = _parseRanges(payload);
        if (bounds == null) {
          return RulePayloadError.numberRange;
        }
        return bounds.every((item) => item <= 63)
            ? null
            : RulePayloadError.dscpRange;
      default:
        return null;
    }
  }

  String get rawValue {
    final content = realContent;
    final target = realTarget;
    return [
      ruleAction.value,
      if (content?.isNotEmpty == true) content!,
      if (target?.isNotEmpty == true) target!,
      if (ruleAction.hasParams) ...[
        if (src) 'src',
        if (noResolve) 'no-resolve',
      ],
    ].join(',');
  }

  List<String> get searchFields => [ruleAction.name, rawValue];
}

/// Mirrors mihomo's newIntRanges: `80`, `80-90`, and `/` or `,` between them.
List<int>? _parseRanges(String payload) {
  if (payload == '*') {
    return null;
  }
  final segments = payload.replaceAll(',', '/').split('/');
  if (segments.length > 28) {
    return null;
  }
  final bounds = <int>[];
  for (final segment in segments) {
    final trimmed = segment.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final parts = trimmed.split('-');
    if (parts.length > 2) {
      return null;
    }
    for (final part in parts) {
      final bound = int.tryParse(part.replaceAll(RegExp(r'[\[\] ]'), ''));
      if (bound == null || bound < 0) {
        return null;
      }
      bounds.add(bound);
    }
  }
  return bounds.isEmpty ? null : bounds;
}

List<Rule> _genRules(List<dynamic>? rules) {
  if (rules == null) {
    return [];
  }
  return rules.map((item) => Rule.parse(item)).toList();
}

List<String> _genList(Map<String, dynamic> json) {
  return json.entries.map((entry) => entry.key).toList();
}

@freezed
abstract class ClashConfig with _$ClashConfig {
  const factory ClashConfig({
    @Default([]) @JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,
    @JsonKey(fromJson: _genRules) @Default([]) List<Rule> rules,
    @Default([]) List<Proxy> proxies,
    @JsonKey(name: 'proxy-providers', fromJson: _genList)
    @Default([])
    List<String> proxyProviders,
    @JsonKey(name: 'rule-providers', fromJson: _genList)
    @Default([])
    List<String> ruleProviders,
    @JsonKey(name: 'sub-rules', fromJson: _genList)
    @Default([])
    List<String> subRules,
    @Default({}) Map<String, String> proxyTypeMap,
  }) = _ClashConfig;

  factory ClashConfig.fromJson(Map<String, Object?> json) =>
      _$ClashConfigFromJson(json);
}

extension GeoResourceUrlMapExt on Map<GeoResource, String> {
  Map<String, String> get raw =>
      map((key, value) => MapEntry(key.configKey, value));
}

Map<GeoResource, String> _geoXUrlFromJson(Map<String, Object?>? json) {
  if (json == null) {
    return defaultGeoXUrl;
  }
  return json.map(
    (key, value) => MapEntry(GeoResource.fromJson(key), value as String),
  );
}

Map<String, String> _geoXUrlToJson(Map<GeoResource, String> value) {
  return value.raw;
}

@freezed
abstract class PatchClashConfig with _$PatchClashConfig {
  const factory PatchClashConfig({
    @Default(defaultMixedPort) @JsonKey(name: 'mixed-port') int mixedPort,
    @Default(0) @JsonKey(name: 'socks-port') int socksPort,
    @Default(0) @JsonKey(name: 'port') int port,
    @Default(0) @JsonKey(name: 'redir-port') int redirPort,
    @Default(0) @JsonKey(name: 'tproxy-port') int tproxyPort,
    @Default(Mode.rule) Mode mode,
    @Default(false) @JsonKey(name: 'allow-lan') bool allowLan,
    @Default(LogLevel.error) @JsonKey(name: 'log-level') LogLevel logLevel,
    @Default(false) bool ipv6,
    @Default(FindProcessMode.off)
    @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off)
    FindProcessMode findProcessMode,
    @Default(InterfaceNameMode.clear)
    @JsonKey(
      name: 'interface-name-mode',
      unknownEnumValue: InterfaceNameMode.clear,
    )
    InterfaceNameMode interfaceNameMode,
    @Default('') @JsonKey(name: 'interface-name') String interfaceName,
    @Default(defaultKeepAliveInterval)
    @JsonKey(name: 'keep-alive-interval')
    int keepAliveInterval,
    @Default(true) @JsonKey(name: 'unified-delay') bool unifiedDelay,
    @Default(true) @JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,
    @Default(defaultTun) @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
    @Default(defaultDns) @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
    @Default({})
    @JsonKey(name: _dnsOverrideKeysJsonKey)
    Set<DnsOverrideKey> dnsOverrideKeys,
    @Default(defaultNtp) @JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,
    @Default({})
    @JsonKey(name: _ntpOverrideKeysJsonKey)
    Set<NtpOverrideKey> ntpOverrideKeys,
    @Default(defaultGeoXUrl)
    @JsonKey(
      name: 'geox-url',
      fromJson: _geoXUrlFromJson,
      toJson: _geoXUrlToJson,
    )
    Map<GeoResource, String> geoXUrl,
    @Default(GeodataLoader.memconservative)
    @JsonKey(name: 'geodata-loader')
    GeodataLoader geodataLoader,
    @JsonKey(name: 'global-ua') String? globalUa,
    @Default(ExternalControllerStatus.close)
    @JsonKey(name: 'external-controller')
    ExternalControllerStatus externalController,
    @Default({}) Map<String, String> hosts,
    @Default(false) @JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,
    @Default(24) @JsonKey(name: 'geo-update-interval') int geoUpdateInterval,
  }) = _PatchClashConfig;

  factory PatchClashConfig.fromJson(Map<String, Object?> json) =>
      _$PatchClashConfigFromJson(_withLegacyDnsOverrideKeys(json));

  factory PatchClashConfig.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultClashConfig;
    }
    return decodeOrRestoreDefault(
      'clash config',
      () => PatchClashConfig.fromJson(json),
      () => defaultClashConfig,
    );
  }
}

extension PatchClashConfigExt on PatchClashConfig {
  UpdateParams toUpdateParams({
    required RouteMode routeMode,
    required List<String> authentication,
  }) {
    return UpdateParams(
      tun: tun.getRealTun(routeMode),
      authentication: authentication,
      allowLan: allowLan,
      findProcessMode: findProcessMode,
      mode: mode,
      logLevel: logLevel,
      ipv6: ipv6,
      tcpConcurrent: tcpConcurrent,
      externalController: externalController,
      unifiedDelay: unifiedDelay,
      mixedPort: mixedPort,
      geoAutoUpdate: geoAutoUpdate,
      geoUpdateInterval: geoUpdateInterval,
    );
  }
}
