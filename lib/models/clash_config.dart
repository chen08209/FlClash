// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/common/common.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/enum.dart';

part 'generated/clash_config.freezed.dart';
part 'generated/clash_config.g.dart';

typedef HostsMap = Map<String, String>;

const defaultClashConfig = ClashConfig();

const defaultTun = Tun();
const defaultDns = Dns();
const defaultGeoXUrl = GeoXUrl();

const defaultMixedPort = 7890;
const defaultKeepAliveInterval = 30;

const defaultBypassPrivateRouteAddress = [
  "1.0.0.0/8",
  "2.0.0.0/7",
  "4.0.0.0/6",
  "8.0.0.0/7",
  "11.0.0.0/8",
  "12.0.0.0/6",
  "16.0.0.0/4",
  "32.0.0.0/3",
  "64.0.0.0/3",
  "96.0.0.0/4",
  "112.0.0.0/5",
  "120.0.0.0/6",
  "124.0.0.0/7",
  "126.0.0.0/8",
  "128.0.0.0/3",
  "160.0.0.0/5",
  "168.0.0.0/8",
  "169.0.0.0/9",
  "169.128.0.0/10",
  "169.192.0.0/11",
  "169.224.0.0/12",
  "169.240.0.0/13",
  "169.248.0.0/14",
  "169.252.0.0/15",
  "169.255.0.0/16",
  "170.0.0.0/7",
  "172.0.0.0/12",
  "172.32.0.0/11",
  "172.64.0.0/10",
  "172.128.0.0/9",
  "173.0.0.0/8",
  "174.0.0.0/7",
  "176.0.0.0/4",
  "192.0.0.0/9",
  "192.128.0.0/11",
  "192.160.0.0/13",
  "192.169.0.0/16",
  "192.170.0.0/15",
  "192.172.0.0/14",
  "192.176.0.0/12",
  "192.192.0.0/10",
  "193.0.0.0/8",
  "194.0.0.0/7",
  "196.0.0.0/6",
  "200.0.0.0/5",
  "208.0.0.0/4",
  "240.0.0.0/5",
  "248.0.0.0/6",
  "252.0.0.0/7",
  "254.0.0.0/8",
  "255.0.0.0/9",
  "255.128.0.0/10",
  "255.192.0.0/11",
  "255.224.0.0/12",
  "255.240.0.0/13",
  "255.248.0.0/14",
  "255.252.0.0/15",
  "255.254.0.0/16",
  "255.255.0.0/17",
  "255.255.128.0/18",
  "255.255.192.0/19",
  "255.255.224.0/20",
  "255.255.240.0/21",
  "255.255.248.0/22",
  "255.255.252.0/23",
  "255.255.254.0/24",
  "255.255.255.0/25",
  "255.255.255.128/26",
  "255.255.255.192/27",
  "255.255.255.224/28",
  "255.255.255.240/29",
  "255.255.255.248/30",
  "255.255.255.252/31",
  "255.255.255.254/32",
  "::/1",
  "8000::/2",
  "c000::/3",
  "e000::/4",
  "f000::/5",
  "f800::/6",
  "fe00::/9",
  "fec0::/10"
];

@freezed
class ProxyGroup with _$ProxyGroup {
  const factory ProxyGroup({
    required String name,
    @JsonKey(
      fromJson: GroupType.parseProfileType,
    )
    required GroupType type,
    List<String>? proxies,
    List<String>? use,
    int? interval,
    bool? lazy,
    String? url,
    int? timeout,
    @JsonKey(name: "max-failed-times") int? maxFailedTimes,
    String? filter,
    @JsonKey(name: "expected-filter") String? excludeFilter,
    @JsonKey(name: "exclude-type") String? excludeType,
    @JsonKey(name: "expected-status") int? expectedStatus,
    bool? hidden,
    String? icon,
  }) = _ProxyGroup;

  factory ProxyGroup.fromJson(Map<String, Object?> json) =>
      _$ProxyGroupFromJson(json);
}

@freezed
class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(appName) String device,
    @Default(TunStack.gvisor) TunStack stack,
    @JsonKey(name: "dns-hijack") @Default(["any:53"]) List<String> dnsHijack,
    @JsonKey(name: "route-address") @Default([]) List<String> routeAddress,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);

  factory Tun.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTun;
    }
    try {
      return Tun.fromJson(json);
    } catch (_) {
      return defaultTun;
    }
  }
}

@freezed
class FallbackFilter with _$FallbackFilter {
  const factory FallbackFilter({
    @Default(true) bool geoip,
    @Default("CN") @JsonKey(name: "geoip-code") String geoipCode,
    @Default(["gfw"]) List<String> geosite,
    @Default(["240.0.0.0/4"]) List<String> ipcidr,
    @Default([
      "+.google.com",
      "+.facebook.com",
      "+.youtube.com",
    ])
    List<String> domain,
  }) = _FallbackFilter;

  factory FallbackFilter.fromJson(Map<String, Object?> json) =>
      _$FallbackFilterFromJson(json);
}

@freezed
class Dns with _$Dns {
  const factory Dns({
    @Default(true) bool enable,
    @Default("0.0.0.0:1053") String listen,
    @Default(false) @JsonKey(name: "prefer-h3") bool preferH3,
    @Default(true) @JsonKey(name: "use-hosts") bool useHosts,
    @Default(true) @JsonKey(name: "use-system-hosts") bool useSystemHosts,
    @Default(false) @JsonKey(name: "respect-rules") bool respectRules,
    @Default(false) bool ipv6,
    @Default(["223.5.5.5"])
    @JsonKey(name: "default-nameserver")
    List<String> defaultNameserver,
    @Default(DnsMode.fakeIp)
    @JsonKey(name: "enhanced-mode")
    DnsMode enhancedMode,
    @Default("198.18.0.1/16")
    @JsonKey(name: "fake-ip-range")
    String fakeIpRange,
    @Default([
      "*.lan",
      "localhost.ptlogin2.qq.com",
    ])
    @JsonKey(name: "fake-ip-filter")
    List<String> fakeIpFilter,
    @Default({
      "www.baidu.com": "114.114.114.114",
      "+.internal.crop.com": "10.0.0.1",
      "geosite:cn": "https://doh.pub/dns-query"
    })
    @JsonKey(name: "nameserver-policy")
    Map<String, String> nameserverPolicy,
    @Default([
      "https://doh.pub/dns-query",
      "https://dns.alidns.com/dns-query",
    ])
    List<String> nameserver,
    @Default([
      "tls://8.8.4.4",
      "tls://1.1.1.1",
    ])
    List<String> fallback,
    @Default([
      "https://doh.pub/dns-query",
    ])
    @JsonKey(name: "proxy-server-nameserver")
    List<String> proxyServerNameserver,
    @Default(FallbackFilter())
    @JsonKey(name: "fallback-filter")
    FallbackFilter fallbackFilter,
  }) = _Dns;

  factory Dns.fromJson(Map<String, Object?> json) => _$DnsFromJson(json);

  factory Dns.safeDnsFromJson(Map<String, Object?> json) {
    try {
      return Dns.fromJson(json);
    } catch (_) {
      return const Dns();
    }
  }
}

@freezed
class GeoXUrl with _$GeoXUrl {
  const factory GeoXUrl({
    @Default(
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb",
    )
    String mmdb,
    @Default(
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb",
    )
    String asn,
    @Default(
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat",
    )
    String geoip,
    @Default(
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat",
    )
    String geosite,
  }) = _GeoXUrl;

  factory GeoXUrl.fromJson(Map<String, Object?> json) =>
      _$GeoXUrlFromJson(json);

  factory GeoXUrl.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultGeoXUrl;
    }
    try {
      return GeoXUrl.fromJson(json);
    } catch (_) {
      return defaultGeoXUrl;
    }
  }
}

@freezed
class ClashConfigSnippet with _$ClashConfigSnippet {
  const factory ClashConfigSnippet({
    @Default([]) @JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
    @Default([]) List<String> rule,
  }) = _ClashConfigSnippet;

  factory ClashConfigSnippet.fromJson(Map<String, Object?> json) =>
      _$ClashConfigSnippetFromJson(json);
}

@freezed
class ClashConfig with _$ClashConfig {
  const factory ClashConfig({
    @Default(defaultMixedPort) @JsonKey(name: "mixed-port") int mixedPort,
    @Default(Mode.rule) Mode mode,
    @Default(false) @JsonKey(name: "allow-lan") bool allowLan,
    @Default(LogLevel.info) @JsonKey(name: "log-level") LogLevel logLevel,
    @Default(false) bool ipv6,
    @Default(FindProcessMode.off)
    @JsonKey(
      name: "find-process-mode",
      unknownEnumValue: FindProcessMode.off,
    )
    FindProcessMode findProcessMode,
    @Default(defaultKeepAliveInterval)
    @JsonKey(name: "keep-alive-interval")
    int keepAliveInterval,
    @Default(true) @JsonKey(name: "unified-delay") bool unifiedDelay,
    @Default(true) @JsonKey(name: "tcp-concurrent") bool tcpConcurrent,
    @Default(defaultTun) @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
    @Default(defaultDns) @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
    @Default(defaultGeoXUrl)
    @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
    GeoXUrl geoXUrl,
    @Default(GeodataLoader.memconservative)
    @JsonKey(name: "geodata-loader")
    GeodataLoader geodataLoader,
    @Default([]) @JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
    @Default([]) List<String> rule,
    @JsonKey(name: "global-ua") String? globalUa,
    @Default(ExternalControllerStatus.close)
    @JsonKey(name: "external-controller")
    ExternalControllerStatus externalController,
    @Default({}) HostsMap hosts,
  }) = _ClashConfig;

  factory ClashConfig.fromJson(Map<String, Object?> json) =>
      _$ClashConfigFromJson(json);

  factory ClashConfig.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultClashConfig;
    }
    try {
      return ClashConfig.fromJson(json);
    } catch (_) {
      return defaultClashConfig;
    }
  }
}
