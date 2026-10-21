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
const defaultSniffer = Sniffer();
const defaultProfileTun = ProfileTun();

/// What a profile that brings no DNS section of its own is given, so the core
/// always resolves. The user's own override set starts empty.
const baselineDnsOverrideKeys = {
  DnsOverrideKey.enable,
  DnsOverrideKey.enhancedMode,
  DnsOverrideKey.nameserver,
};
const baselineDns = Dns(
  enable: true,
  enhancedMode: DnsMode.fakeIp,
  nameserver: ['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query'],
);
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
const defaultTunMtu = 9000;
const minTunMtu = 1280;
const maxTunMtu = 65535;
const defaultCongestionController = 'cubic';

// The congestion controls mipstack registers, cubic first as its default.
const congestionControllers = [
  defaultCongestionController,
  'reno',
  'bbr',
  'bbr3',
];
const defaultDnsHijack = ['any:53'];
const defaultTunUdpTimeout = 300;

const privateRouteAddress = [
  '0.0.0.0/8',
  '10.0.0.0/8',
  '127.0.0.0/8',
  '169.254.0.0/16',
  '172.16.0.0/12',
  '192.168.0.0/16',
  '224.0.0.0/4',
  '255.255.255.255/32',
  'fc00::/7',
  'fe80::/10',
  'ff00::/8',
];

Object? _readIncludeAll(Map<dynamic, dynamic> json, String key) {
  return json['include-all'] == true ? true : json[key];
}

@freezed
abstract class ProxyGroup with _$ProxyGroup {
  const factory ProxyGroup({
    int? profileId,
    @JsonKey(fromJson: Snowflake.buildId) required int id,
    required String name,
    required GroupType type,
    List<String>? proxies,
    List<String>? use,
    @JsonKey(name: 'use-position') Map<String, int>? usePosition,
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
    @JsonKey(name: 'hash-key') String? hashKey,
    @JsonKey(name: 'default-selected') String? defaultSelected,
    @JsonKey(name: 'empty-fallback') String? emptyFallback,
    @JsonKey(name: 'include-all-proxies', readValue: _readIncludeAll)
    bool? includeAllProxies,
    @JsonKey(name: 'include-all-providers', readValue: _readIncludeAll)
    bool? includeAllProviders,
    bool? hidden,
    String? icon,
    String? order,

    /// Where the members list shows the filters among the proxies, which no
    /// config carries, as `ProxyGroupMembersSliver` writes it.
    List<String>? memberLayout,
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
      'use-position': ?effectiveUsePosition,
      if (url?.isNotEmpty == true) 'url': url,
      if (interval != null) 'interval': interval,
      if (timeout != null) 'timeout': timeout,
      if (maxFailedTimes != null) 'max-failed-times': maxFailedTimes,
      if (emptyFallback?.isNotEmpty == true) 'empty-fallback': emptyFallback,
      if (lazy != null) 'lazy': lazy,
      if (disableUDP != null) 'disable-udp': disableUDP,
      if (filter?.isNotEmpty == true) 'filter': filter,
      if (excludeFilter?.isNotEmpty == true) 'exclude-filter': excludeFilter,
      if (excludeType?.isNotEmpty == true) 'exclude-type': excludeType,
      if (expectedStatus?.isNotEmpty == true) 'expected-status': expectedStatus,
      if (includeAllProxies == true) 'include-all-proxies': true,
      if (includeAllProviders == true) 'include-all-providers': true,
      if (hidden != null) 'hidden': hidden,
      if (icon?.isNotEmpty == true) 'icon': icon,
      if (type == GroupType.URLTest && tolerance != null)
        'tolerance': tolerance,
      if (type == GroupType.Selector && defaultSelected?.isNotEmpty == true)
        'default-selected': defaultSelected,
      if (type == GroupType.LoadBalance && strategy != null)
        'strategy': strategy!.value,
      // The core refuses a round-robin group that sets one.
      if (type == GroupType.LoadBalance &&
          strategy != LoadBalanceStrategy.roundRobin &&
          hashKey?.isNotEmpty == true)
        'hash-key': hashKey,
    };
  }

  /// [usePosition] without the providers the core would list last anyway.
  Map<String, int>? get effectiveUsePosition {
    final count = proxies?.length ?? 0;
    final positions = {
      for (final name in use ?? const <String>[])
        if (usePosition?[name] case final position? when position < count)
          name: position < 0 ? 0 : position,
    };
    return positions.isEmpty ? null : positions;
  }

  String get definitionYaml => yaml.encode(definition);

  /// What [definitionYaml] leaves out, such as an option added without a
  /// value, was never there to remove, so it stays.
  ProxyGroup withDefinitionYaml(String content) {
    final document = _plainYaml(loadYaml(content));
    if (document is! Map<String, Object?> ||
        (document['name'] is! String && document['name'] is! num) ||
        document['type'] is! String) {
      throw const FormatException('Not a proxy group mapping');
    }
    final shown = definition;
    final group = ProxyGroup.fromJson({
      for (final MapEntry(:key, :value) in toJson().entries)
        if (!shown.containsKey(key) && key != 'use-position') key: value,
      ...document,
      for (final key in proxyGroupTextKeys)
        if (document[key] case final value? when value is! String)
          key: value.toString(),
      for (final key in const ['proxies', 'use'])
        if (document[key] case final List<Object?> names)
          key: [for (final name in names) name.toString()],
      if (document.containsKey('use-position'))
        'use-position': usePositionOf(document['use-position']),
      'id': id,
    }).copyWith(profileId: profileId, order: order);
    return group.copyWith(usePosition: group.effectiveUsePosition);
  }
}

Map<String, int>? usePositionOf(
  Object? value, [
  Map<String, String> names = const {},
]) => switch (value) {
  Map() => {
    for (final MapEntry(:key, :value) in value.entries)
      names['$key'] ?? '$key': ?int.tryParse('$value'),
  },
  _ => null,
};

const proxyGroupTextKeys = [
  'name',
  'url',
  'filter',
  'exclude-filter',
  'exclude-type',
  'expected-status',
  'hash-key',
  'default-selected',
  'empty-fallback',
  'icon',
];

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
    @JsonKey(name: 'provider-name') String? providerName,
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

/// The standard methods of sing-shadowsocks2, which mihomo's ss adapter
/// creates its cipher with.
const _ssCiphers = [
  'aes-128-gcm',
  'aes-192-gcm',
  'aes-256-gcm',
  'chacha20-ietf-poly1305',
  'xchacha20-ietf-poly1305',
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
  'aes-128-ctr',
  'aes-192-ctr',
  'aes-256-ctr',
  'aes-128-cfb',
  'aes-192-cfb',
  'aes-256-cfb',
  'rc4-md5',
  'chacha20-ietf',
  'xchacha20',
  'chacha20',
  'none',
];

/// ShadowsocksR takes stream ciphers only.
const _ssrCiphers = [
  'aes-128-ctr',
  'aes-192-ctr',
  'aes-256-ctr',
  'aes-128-cfb',
  'aes-192-cfb',
  'aes-256-cfb',
  'rc4-md5',
  'chacha20-ietf',
  'xchacha20',
  'chacha20',
  'none',
];

const _choiceEquality = ListEquality<String>();

/// mihomo matches struct keys, like HTTP header names, in any case.
Object? _keyIn(Map map, String key) {
  if (map.containsKey(key)) {
    return key;
  }
  final lower = key.toLowerCase();
  for (final candidate in map.keys) {
    if (candidate.toString().toLowerCase() == lower) {
      return candidate;
    }
  }
  return null;
}

Map<String, dynamic> _withPath(Map map, List<String> path, Object? value) {
  final [key, ...rest] = path;
  final next = Map<String, dynamic>.from(map);
  final existing = _keyIn(next, key) as String? ?? key;
  final child = rest.isEmpty
      ? value
      : _withPath(
          switch (next[existing]) {
            final Map map => map,
            _ => const {},
          },
          rest,
          value,
        );
  if (child == null || child == '' || child is Map && child.isEmpty) {
    next.remove(existing);
  } else {
    next[existing] = child;
  }
  return next;
}

/// One app-level proxy, kept as the raw mapping the core parses, since each
/// proxy type reads its own set of keys.
@freezed
abstract class CustomProxy with _$CustomProxy {
  const factory CustomProxy({
    @JsonKey(fromJson: Snowflake.buildId) required int id,
    @Default({}) Map<String, dynamic> definition,
    String? order,

    /// Options the form lists with no value yet, which [definition] cannot
    /// hold since the core reads every key in it.
    @Default({}) Set<ProxyField> emptyOptions,
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

  Set<String> get requiredKeys => switch (type) {
    'ss' => const {'server', 'port', 'password', 'cipher'},
    'ssr' => const {'server', 'port', 'password', 'cipher', 'obfs', 'protocol'},
    'vmess' => const {'server', 'port', 'uuid', 'alterId', 'cipher'},
    'vless' => const {'server', 'port', 'uuid'},
    'snell' => const {'server', 'port', 'psk'},
    'trojan' || 'anytls' => const {'server', 'port', 'password'},
    'hysteria' => const {'server', 'up', 'down'},
    'hysteria2' => const {'server'},
    'wireguard' => const {'private-key'},
    'ssh' => const {'server', 'port', 'username'},
    'mieru' => const {'server', 'transport', 'username', 'password'},
    'sudoku' => const {'server', 'port', 'key'},
    'masque' => const {'server', 'port', 'private-key', 'public-key'},
    'openvpn' => const {'server', 'port', 'ca'},
    'zerotier' => const {'network'},
    'socks5' ||
    'http' ||
    'tuic' ||
    'shadowquic' ||
    'gost-relay' ||
    'trusttunnel' => const {'server', 'port'},
    _ => const {},
  };

  /// The rows the form always shows: the credentials and [requiredKeys].
  List<ProxyField> get fields => switch (type) {
    'ss' => const [ProxyField.cipher, ProxyField.password],
    'ssr' => const [
      ProxyField.cipher,
      ProxyField.protocol,
      ProxyField.obfs,
      ProxyField.password,
    ],
    'vmess' => const [ProxyField.cipher, ProxyField.alterId, ProxyField.uuid],
    'vless' => const [ProxyField.uuid],
    'tuic' => const [ProxyField.uuid, ProxyField.password],
    'trojan' || 'anytls' || 'hysteria2' => const [ProxyField.password],
    'hysteria' => const [ProxyField.up, ProxyField.down, ProxyField.authStr],
    'snell' => const [ProxyField.psk],
    'sudoku' => const [ProxyField.key],
    'wireguard' ||
    'masque' => const [ProxyField.privateKey, ProxyField.publicKey],
    'mieru' => const [
      ProxyField.transport,
      ProxyField.username,
      ProxyField.password,
    ],
    'socks5' ||
    'http' ||
    'ssh' ||
    'shadowquic' ||
    'trusttunnel' ||
    'gost-relay' ||
    'openvpn' => const [ProxyField.username, ProxyField.password],
    _ => const [],
  };

  /// The username, password and UUID among [fields], which tell one account
  /// on a server from another.
  List<ProxyField> get credentials => [
    for (final field in fields)
      if (const {
        ProxyField.username,
        ProxyField.password,
        ProxyField.uuid,
      }.contains(field))
        field,
  ];

  /// The keys the form adds one at a time, each left to the core's default
  /// until then.
  List<ProxyField> get options {
    final fields = this.fields;
    return [
      for (final field in ProxyField.values)
        if (!fields.contains(field) && _offers(field)) field,
    ];
  }

  bool _offers(ProxyField field) {
    final type = this.type;
    return switch (field) {
      ProxyField.username ||
      ProxyField.password ||
      ProxyField.uuid ||
      ProxyField.psk ||
      ProxyField.key ||
      ProxyField.publicKey ||
      ProxyField.authStr ||
      ProxyField.cipher ||
      ProxyField.alterId ||
      ProxyField.transport => false,
      ProxyField.privateKey || ProxyField.privateKeyPassphrase => type == 'ssh',
      ProxyField.preSharedKey || ProxyField.allowedIps => type == 'wireguard',
      ProxyField.obfs ||
      ProxyField.up ||
      ProxyField.down => type == 'hysteria2',
      ProxyField.obfsPassword =>
        type == 'hysteria2' && valueOf(ProxyField.obfs) != null,
      ProxyField.protocol || ProxyField.obfsSecret => type == 'hysteria',
      ProxyField.network => choicesOf(field).isNotEmpty,
      ProxyField.flow => type == 'vless',
      ProxyField.wsPath || ProxyField.wsHost => _usesNetwork('ws'),
      ProxyField.grpcServiceName => _usesNetwork('grpc'),
      ProxyField.xhttpPath || ProxyField.xhttpHost => _usesNetwork('xhttp'),
      ProxyField.tls => const {
        'socks5',
        'http',
        'vmess',
        'vless',
        'gost-relay',
      }.contains(type),
      ProxyField.sni => const {
        'http',
        'trojan',
        'hysteria',
        'hysteria2',
        'tuic',
        'shadowquic',
        'gost-relay',
        'anytls',
        'masque',
        'trusttunnel',
      }.contains(type),
      ProxyField.servername => type == 'vmess' || type == 'vless',
      ProxyField.alpn => const {
        'vmess',
        'vless',
        'trojan',
        'hysteria',
        'hysteria2',
        'tuic',
        'shadowquic',
        'anytls',
        'trusttunnel',
      }.contains(type),
      ProxyField.skipCertVerify => const {
        'socks5',
        'http',
        'vmess',
        'vless',
        'trojan',
        'hysteria',
        'hysteria2',
        'tuic',
        'gost-relay',
        'anytls',
        'masque',
        'trusttunnel',
      }.contains(type),
      ProxyField.clientFingerprint => const {
        'ss',
        'vmess',
        'vless',
        'snell',
        'trojan',
        'gost-relay',
        'anytls',
        'trusttunnel',
      }.contains(type),
      ProxyField.realityPublicKey || ProxyField.realityShortId => const {
        'vmess',
        'vless',
        'trojan',
      }.contains(type),
      ProxyField.plugin || ProxyField.udpOverTcp => type == 'ss',
      ProxyField.pluginMode => type == 'ss' && _pluginReads('mode'),
      ProxyField.pluginHost => type == 'ss' && _pluginReads('host'),
      ProxyField.protocolParam || ProxyField.obfsParam => type == 'ssr',
      ProxyField.obfsMode ||
      ProxyField.obfsHost ||
      ProxyField.version => type == 'snell',
      ProxyField.ports ||
      ProxyField.hopInterval => type == 'hysteria' || type == 'hysteria2',
      ProxyField.congestionController => const {
        'tuic',
        'shadowquic',
        'masque',
        'trusttunnel',
      }.contains(type),
      ProxyField.udpRelayMode || ProxyField.reduceRtt => type == 'tuic',
      ProxyField.ip ||
      ProxyField.ipv6 ||
      ProxyField.dns ||
      ProxyField.remoteDnsResolve ||
      ProxyField.mtu => type == 'wireguard' || type == 'masque',
      ProxyField.tfo || ProxyField.mptcp => !const {
        'dns',
        'reject',
        'rematch',
        'hysteria',
        'hysteria2',
        'tuic',
        'wireguard',
        'shadowquic',
        'masque',
        'tailscale',
        'zerotier',
        'easytier',
      }.contains(type),
      ProxyField.interfaceName ||
      ProxyField.routingMark ||
      ProxyField.ipVersion => !const {
        'dns',
        'reject',
        'rematch',
      }.contains(type),
    };
  }

  bool _pluginReads(String key) => switch (valueOf(ProxyField.plugin)) {
    'obfs' || 'v2ray-plugin' || 'gost-plugin' => true,
    'kcptun' => key == 'mode',
    'shadow-tls' || 'restls' || 'jls' => key == 'host',
    _ => false,
  };

  bool _usesNetwork(String network) =>
      valueOf(ProxyField.network) == network &&
      choicesOf(ProxyField.network).contains(network);

  /// The values the core accepts, in the order the form lists them.
  List<String> choicesOf(ProxyField field) => switch (field) {
    ProxyField.cipher => switch (type) {
      'ss' => _ssCiphers,
      'ssr' => _ssrCiphers,
      'vmess' => const [
        'auto',
        'aes-128-gcm',
        'chacha20-poly1305',
        'aes-128-cfb',
        'none',
        'zero',
      ],
      _ => const [],
    },
    ProxyField.protocol => switch (type) {
      'ssr' => const [
        'origin',
        'auth_sha1_v4',
        'auth_aes128_md5',
        'auth_aes128_sha1',
        'auth_chain_a',
        'auth_chain_b',
      ],
      'hysteria' => const ['udp', 'wechat-video', 'faketcp'],
      _ => const [],
    },
    ProxyField.obfs => switch (type) {
      'ssr' => const [
        'plain',
        'http_simple',
        'http_post',
        'random_head',
        'tls1.2_ticket_auth',
        'tls1.2_ticket_fastauth',
      ],
      'hysteria2' => const ['salamander', 'gecko'],
      _ => const [],
    },
    ProxyField.transport => const ['TCP', 'UDP'],
    ProxyField.network => switch (type) {
      'vmess' => const ['tcp', 'ws', 'http', 'h2', 'grpc', 'mekya', 'mkcp'],
      'vless' => const ['tcp', 'ws', 'http', 'h2', 'grpc', 'xhttp'],
      'trojan' => const ['tcp', 'ws', 'grpc'],
      _ => const [],
    },
    ProxyField.flow => const ['xtls-rprx-vision'],
    ProxyField.clientFingerprint => const [
      'chrome',
      'firefox',
      'safari',
      'ios',
      'android',
      'edge',
      '360',
      'qq',
      'random',
      'chrome120',
      'firefox120',
      'safari16',
      'none',
    ],
    ProxyField.plugin => const [
      'obfs',
      'v2ray-plugin',
      'gost-plugin',
      'shadow-tls',
      'restls',
      'jls',
      'kcptun',
    ],
    ProxyField.obfsMode => const ['http', 'tls', 'shadow-tls', 'restls', 'jls'],
    ProxyField.congestionController => const [
      'cubic',
      'new_reno',
      'bbr',
      'bbr_meta_v1',
      'bbr_meta_v2',
    ],
    ProxyField.udpRelayMode => const ['native', 'quic'],
    ProxyField.ipVersion => [
      for (final version in IpVersion.values) version.value,
    ],
    _ => const [],
  };

  Object? valueOf(ProxyField field) {
    Object? value = definition;
    for (final key in field.path) {
      if (value is! Map) {
        return null;
      }
      value = value[_keyIn(value, key)];
    }
    return value;
  }

  /// Drops the key on an empty [value], with any map left empty and the
  /// options only the old value made available.
  CustomProxy withField(ProxyField field, Object? value) {
    final offered = options;
    var next = copyWith(definition: _withPath(definition, field.path, value));
    final stillOffered = next.options;
    for (final option in offered) {
      if (!stillOffered.contains(option)) {
        next = next.copyWith(
          definition: _withPath(next.definition, option.path, null),
        );
      }
    }
    return next;
  }

  /// Keeps the values the new type reads alike and fills the ones nearly
  /// every server of it takes.
  CustomProxy withType(String type) {
    if (type == this.type) {
      return this;
    }
    var next = withValue('type', type);
    for (final field in ProxyField.values) {
      final value = next.valueOf(field);
      if (value == null) {
        continue;
      }
      final choices = next.choicesOf(field);
      final readsAlike =
          (next.fields.contains(field) || next.options.contains(field)) &&
          (_choiceEquality.equals(choicesOf(field), choices) ||
              choices.contains(value));
      if (!readsAlike) {
        next = next.withField(field, null);
      }
    }
    final defaults = switch (type) {
      'vmess' => const {ProxyField.cipher: 'auto', ProxyField.alterId: 0},
      'mieru' => const {ProxyField.transport: 'TCP'},
      _ => const <ProxyField, Object>{},
    };
    for (final MapEntry(:key, :value) in defaults.entries) {
      if (next.valueOf(key) == null) {
        next = next.withField(key, value);
      }
    }
    return next;
  }

  List<String> stringsOf(String key) =>
      switch (definition[_keyIn(definition, key)]) {
        final List items => [for (final item in items) item.toString()],
        final String item when item.isNotEmpty => [item],
        _ => const [],
      };

  CustomProxy withValue(String key, Object? value) =>
      copyWith(definition: _withPath(definition, [key], value));
}

/// Per profile, since [target] names a proxy or group that profile defines.
@freezed
abstract class ProxyDialer with _$ProxyDialer {
  const factory ProxyDialer({
    required int profileId,
    required int proxyId,
    required String target,
  }) = _ProxyDialer;
}

@freezed
sealed class CustomIssue with _$CustomIssue {
  const factory CustomIssue.emptyName() = EmptyNameIssue;

  const factory CustomIssue.reservedName(String name) = ReservedNameIssue;

  const factory CustomIssue.duplicateName(String name) = DuplicateNameIssue;

  const factory CustomIssue.coreRejected(String message) = CoreRejectedIssue;

  const factory CustomIssue.missingProxies(List<String> names) =
      MissingProxiesIssue;

  const factory CustomIssue.missingProviders(List<String> names) =
      MissingProvidersIssue;

  const factory CustomIssue.noProxySource() = NoProxySourceIssue;

  const factory CustomIssue.groupLoop(List<String> names) = GroupLoopIssue;

  const factory CustomIssue.invalidEmptyFallback(String name) =
      InvalidEmptyFallbackIssue;

  const factory CustomIssue.invalidFilter(String name, String message) =
      InvalidFilterIssue;

  const factory CustomIssue.invalidPayload(RulePayloadError error) =
      InvalidPayloadIssue;

  const factory CustomIssue.missingRuleSet(String name) = MissingRuleSetIssue;

  const factory CustomIssue.missingSubRule(String name) = MissingSubRuleIssue;

  const factory CustomIssue.missingTarget(String name) = MissingTargetIssue;

  const factory CustomIssue.missingDialer(String name) = MissingDialerIssue;

  const factory CustomIssue.dialerLoop(String proxy, String target) =
      DialerLoopIssue;
}

@freezed
abstract class CustomProfileIssues with _$CustomProfileIssues {
  const factory CustomProfileIssues({
    @Default({}) Map<int, List<CustomIssue>> proxyGroups,
    @Default({}) Map<int, List<CustomIssue>> rules,
    @Default({}) Map<int, List<CustomIssue>> dialers,
    @Default([]) List<CustomIssue> dns,
    @Default([]) List<CustomIssue> ntp,
  }) = _CustomProfileIssues;
}

@freezed
abstract class CustomProfileData with _$CustomProfileData {
  const factory CustomProfileData({
    @Default([]) List<ProxyGroup> proxyGroups,
    @Default({}) Set<String> proxyProviders,
    @Default({}) Set<String> ruleProviders,
    @Default({}) Set<String> ruleTargets,
    @Default({}) Set<String> proxies,
    @Default({}) Map<String, String> dialers,
  }) = _CustomProfileData;
}

final _namedProxies = Expando<Set<String>>();

extension CustomProfileDataExt on CustomProfileData {
  Set<String> get namedProxies => _namedProxies[this] ??= Set.unmodifiable({
    for (final group in proxyGroups)
      for (final name in group.proxies ?? const <String>[])
        if (proxies.contains(name)) name,
  });

  /// A local proxy reaches the config only when a group names it.
  bool isRuleTarget(String? name) =>
      ruleTargets.contains(name) ||
      name == GroupName.GLOBAL.name ||
      namedProxies.contains(name);
}

@freezed
abstract class Sniffer with _$Sniffer {
  const factory Sniffer({
    @Default(false) bool enable,
    @Default(true) @JsonKey(name: 'override-destination') bool overrideDest,
    @Default(true) @JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,
    @Default(true) @JsonKey(name: 'parse-pure-ip') bool parsePureIp,
    @Default([]) @JsonKey(name: 'force-domain') List<String> forceDomain,
    @Default([]) @JsonKey(name: 'skip-domain') List<String> skipDomain,
    @Default([]) @JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,
    @Default([]) @JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,
    @Default({}) Map<String, SnifferConfig> sniff,
  }) = _Sniffer;

  factory Sniffer.fromJson(Map<String, Object?> json) =>
      _$SnifferFromJson(json);

  factory Sniffer.safeSnifferFromJson(Map<String, Object?> json) {
    return decodeSalvaging('sniffer config', json, Sniffer.fromJson);
  }
}

List<String> _formJsonPorts(List? ports) {
  return ports?.map((item) => item.toString()).toList() ?? [];
}

@freezed
abstract class SnifferConfig with _$SnifferConfig {
  const factory SnifferConfig({
    @Default([]) @JsonKey(fromJson: _formJsonPorts) List<String> ports,
    @JsonKey(name: 'override-destination', includeIfNull: false)
    bool? overrideDest,
  }) = _SnifferConfig;

  factory SnifferConfig.fromJson(Map<String, Object?> json) =>
      _$SnifferConfigFromJson(json);
}

const _snifferOverrideKeysJsonKey = 'sniffer-override-keys';

Set<SnifferOverrideKey> _snifferOverrideKeysFromJson(List<Object?> json) => {
  for (final path in json)
    ?SnifferOverrideKey.values.firstWhereOrNull((key) => key.path == path),
};

extension SnifferOverrideExt on Sniffer {
  SnifferConfig sniffOf(SnifferOverrideKey key) =>
      sniff[key.field] ?? const SnifferConfig();

  Sniffer withSniff(SnifferOverrideKey key, SnifferConfig config) =>
      copyWith(sniff: {...sniff, key.field: config});

  // toJson leaves nested models as objects; the fragment is read as plain maps.
  Map<String, Object?> get _json {
    final json = toJson();
    json[SnifferOverrideKey.sniffSection] = {
      for (final key in SnifferOverrideKey.values)
        if (key.parent != null) key.field: sniffOf(key).toJson(),
    };
    return json;
  }

  Map<String, Object?> overrideJson(Set<SnifferOverrideKey> keys) =>
      _overrideJson(_json, SnifferOverrideKey.values, keys);

  String overrideYaml(Set<SnifferOverrideKey> keys) =>
      yaml.encode(overrideJson(keys));

  ({Sniffer sniffer, Set<SnifferOverrideKey> keys}) applyOverrideYaml(
    String content,
  ) {
    final json = _json;
    final keys = _applyOverrideYaml(
      content,
      json: json,
      values: SnifferOverrideKey.values,
      section: 'sniffer',
      normalizeField: (protocol) => protocol.toUpperCase(),
    );
    if (keys == null) {
      return (sniffer: this, keys: const {});
    }
    return (sniffer: Sniffer.fromJson(json), keys: keys);
  }
}

/// mihomo matches sniff protocols case-insensitively, so an overridden
/// protocol replaces the profile's entry whatever its case.
Map<String, dynamic> mergeSnifferOverride(
  Map<String, dynamic> raw,
  Map<String, Object?> override,
) {
  final merged = Map<String, dynamic>.from(raw);
  for (final entry in override.entries) {
    final value = entry.value;
    if (entry.key != SnifferOverrideKey.sniffSection || value is! Map) {
      merged[entry.key] = value;
      continue;
    }
    final overridden = {for (final name in value.keys) '$name'.toUpperCase()};
    merged[entry.key] = {
      for (final current in _rawSniff(raw).entries)
        if (!overridden.contains('${current.key}'.toUpperCase()))
          '${current.key}': current.value,
      ...value,
    };
  }
  return merged;
}

/// mihomo reads the deprecated `sniffing` list only while `sniff` is empty, so
/// its protocols are carried into `sniff` before an override fills it.
Map<Object?, Object?> _rawSniff(Map<String, dynamic> raw) {
  final sniff = raw[SnifferOverrideKey.sniffSection];
  if (sniff is Map && sniff.isNotEmpty) {
    return sniff;
  }
  final sniffing = raw['sniffing'];
  if (sniffing is! List) {
    return const {};
  }
  final ports = raw['port-whitelist'];
  return {
    for (final name in sniffing)
      '$name'.toUpperCase(): {if (ports is List) 'ports': ports},
  };
}

/// The desktop TUN takes only [TunExt.coreJson]; Android's VPN starts from all.
@freezed
abstract class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(appName) String device,
    @Default(TunStack.mips) TunStack stack,
    @JsonKey(name: 'route-address') @Default([]) List<String> routeAddress,
    @JsonKey(fromJson: _mtuFromJson) @Default(defaultTunMtu) int mtu,
    @JsonKey(
      name: 'congestion-controller',
      fromJson: _congestionControllerFromJson,
    )
    @Default(defaultCongestionController)
    String congestionController,
    @JsonKey(name: 'route-exclude-address')
    @Default([])
    List<String> routeExcludeAddress,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);

  factory Tun.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTun;
    }
    return decodeSalvaging('tun config', json, Tun.fromJson);
  }
}

int _mtuFromJson(int value) =>
    value > 0 ? value.clamp(minTunMtu, maxTunMtu) : defaultTunMtu;

String _congestionControllerFromJson(String value) =>
    value.isEmpty ? defaultCongestionController : value;

extension TunExt on Tun {
  List<String> excludedRoutes({required bool bypassPrivateRoute}) => [
    ...routeExcludeAddress,
    if (bypassPrivateRoute) ...privateRouteAddress,
  ];

  Future<List<String>> vpnRouteAddress({
    required bool bypassPrivateRoute,
  }) async {
    final excluded = excludedRoutes(bypassPrivateRoute: bypassPrivateRoute);
    if (routeAddress.isEmpty && excluded.isEmpty) {
      return const [];
    }
    return subtractCidrsTask(routeAddress, excluded, wholeWhenEmpty: true);
  }

  Map<String, Object?> get coreJson {
    final json = toJson();
    return {
      for (final key in const ['enable', 'device', 'stack']) key: json[key],
      'auto-route': true,
    };
  }
}

@freezed
abstract class FallbackFilter with _$FallbackFilter {
  const factory FallbackFilter({
    @Default(true) bool geoip,
    @Default('') @JsonKey(name: 'geoip-code') String geoipCode,
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
    @Default(false) bool enable,
    @Default('') String listen,
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
    @Default(DnsMode.redirHost)
    @JsonKey(name: 'enhanced-mode')
    DnsMode enhancedMode,
    @Default('198.18.0.1/16')
    @JsonKey(name: 'fake-ip-range')
    String fakeIpRange,
    @Default('') @JsonKey(name: 'fake-ip-range6') String fakeIpRange6,
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
    @Default(['https://doh.pub/dns-query', 'tls://223.5.5.5:853'])
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
    return decodeSalvaging('dns config', json, Dns.fromJson);
  }
}

const _dnsOverrideKeysJsonKey = 'dns-override-keys';

Set<DnsOverrideKey> _dnsOverrideKeysFromJson(List<Object?> json) => {
  for (final path in json)
    ?DnsOverrideKey.values.firstWhereOrNull((key) => key.path == path),
};

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

  /// [keepEmpty] writes emptied keys, but the core refuses an empty nameserver.
  Map<String, Object?> overrideJson(
    Set<DnsOverrideKey> keys, {
    bool keepEmpty = false,
  }) => _overrideJson(
    _json,
    DnsOverrideKey.values,
    keys,
    keepEmpty: keepEmpty
        ? keys.difference({DnsOverrideKey.nameserver})
        : const <DnsOverrideKey>{},
  );

  String overrideYaml(Set<DnsOverrideKey> keys) =>
      yaml.encode(overrideJson(keys));

  ({Dns dns, Set<DnsOverrideKey> keys}) applyOverrideYaml(String content) {
    final json = _json;
    final keys = _applyOverrideYaml(
      content,
      json: json,
      values: DnsOverrideKey.values,
      section: 'DNS',
    );
    if (keys == null) {
      return (dns: this, keys: const {});
    }
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

Map<String, Object?> _overrideJson<K extends OverrideKey>(
  Map<String, Object?> json,
  List<K> values,
  Set<K> keys, {
  Set<K> keepEmpty = const {},
}) {
  final result = <String, Object?>{};
  for (final key in values) {
    if (!keys.contains(key)) {
      continue;
    }
    final parent = key.parent;
    final value = parent == null
        ? json[key.path]
        : (json[parent] as Map)[key.field];
    if (_isUnset(value) && !keepEmpty.contains(key)) {
      continue;
    }
    if (parent == null) {
      result[key.path] = value;
      continue;
    }
    final nested =
        result.putIfAbsent(parent, () => <String, Object?>{})
            as Map<String, Object?>;
    nested[key.field] = value;
  }
  return result;
}

bool _isUnset(Object? value) => switch (value) {
  String() => value.isEmpty,
  Iterable() => value.isEmpty,
  Map() => value.isEmpty,
  _ => false,
};

/// Reads an edited override document into [json] and returns the keys it
/// names, which become the override set, or null for an empty document.
/// Throws on a key [values] does not hold; the caller's decode throws on a
/// value the model cannot hold. [normalizeField] spells a nested field the way
/// its key path does.
Set<K>? _applyOverrideYaml<K extends OverrideKey>(
  String content, {
  required Map<String, Object?> json,
  required List<K> values,
  required String section,
  String Function(String field)? normalizeField,
}) {
  final document = _plainYaml(loadYaml(content));
  if (document == null) {
    return null;
  }
  if (document is! Map) {
    throw FormatException('The override must be a map of $section keys');
  }
  final nested = {
    for (final parent in {for (final key in values) ?key.parent})
      parent: Map<String, Object?>.from(json[parent] as Map),
  };
  final keys = <K>{};
  void take(String path, Object? value) {
    final key = values.firstWhereOrNull((key) => key.path == path);
    if (key == null) {
      throw FormatException('Unknown $section key: $path');
    }
    keys.add(key);
    final parent = key.parent;
    if (parent == null) {
      json[path] = value;
    } else {
      nested[parent]![key.field] = value;
    }
  }

  for (final entry in document.entries) {
    final name = entry.key.toString();
    if (!nested.containsKey(name)) {
      take(name, entry.value);
      continue;
    }
    if (entry.value is! Map) {
      throw FormatException('$name must be a map');
    }
    for (final sub in (entry.value as Map).entries) {
      final field = sub.key.toString();
      take('$name.${normalizeField?.call(field) ?? field}', sub.value);
    }
  }
  json.addAll(nested);
  return keys;
}

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
    merged[entry.key] =
        entry.key == DnsOverrideKey.fallbackFilterSection &&
            current is Map &&
            value is Map
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
    return decodeSalvaging('ntp config', json, Ntp.fromJson);
  }
}

const _ntpOverrideKeysJsonKey = 'ntp-override-keys';

Set<NtpOverrideKey> _ntpOverrideKeysFromJson(List<Object?> json) => {
  for (final path in json)
    ?NtpOverrideKey.values.firstWhereOrNull((key) => key.path == path),
};

extension NtpOverrideExt on Ntp {
  Map<String, Object?> overrideJson(Set<NtpOverrideKey> keys) =>
      _overrideJson(toJson(), NtpOverrideKey.values, keys);

  String overrideYaml(Set<NtpOverrideKey> keys) =>
      yaml.encode(overrideJson(keys));

  ({Ntp ntp, Set<NtpOverrideKey> keys}) applyOverrideYaml(String content) {
    final json = toJson();
    final keys = _applyOverrideYaml(
      content,
      json: json,
      values: NtpOverrideKey.values,
      section: 'NTP',
    );
    if (keys == null) {
      return (ntp: this, keys: const {});
    }
    return (ntp: Ntp.fromJson(json), keys: keys);
  }
}

@freezed
abstract class ProfileTun with _$ProfileTun {
  const factory ProfileTun({
    @Default(defaultTunMtu) int mtu,
    @Default(defaultCongestionController)
    @JsonKey(name: 'congestion-controller')
    String congestionController,
    @Default(false) @JsonKey(name: 'strict-route') bool strictRoute,
    @Default([]) @JsonKey(name: 'route-address') List<String> routeAddress,
    @Default([])
    @JsonKey(name: 'route-exclude-address')
    List<String> routeExcludeAddress,
    @Default(defaultDnsHijack)
    @JsonKey(name: 'dns-hijack')
    List<String> dnsHijack,
    @Default(defaultTunUdpTimeout) @JsonKey(name: 'udp-timeout') int udpTimeout,
    @Default(false)
    @JsonKey(name: 'disable-icmp-forwarding')
    bool disableIcmpForwarding,
    @Default(false) bool gso,
    @Default([])
    @JsonKey(name: 'include-interface')
    List<String> includeInterface,
    @Default([])
    @JsonKey(name: 'exclude-interface')
    List<String> excludeInterface,
    @Default([]) @JsonKey(name: 'include-uid') List<int> includeUid,
    @Default([]) @JsonKey(name: 'exclude-uid') List<int> excludeUid,
    @Default([]) @JsonKey(name: 'exclude-src-port') List<int> excludeSrcPort,
    @Default([]) @JsonKey(name: 'exclude-dst-port') List<int> excludeDstPort,
  }) = _ProfileTun;

  factory ProfileTun.fromJson(Map<String, Object?> json) =>
      _$ProfileTunFromJson(json);

  factory ProfileTun.safeFromJson(Map<String, Object?> json) {
    return decodeSalvaging('tun override', json, ProfileTun.fromJson);
  }
}

const _tunOverrideKeysJsonKey = 'tun-override-keys';

Set<TunOverrideKey> _tunOverrideKeysFromJson(List<Object?> json) => {
  for (final path in json)
    ?TunOverrideKey.values.firstWhereOrNull((key) => key.path == path),
};

extension TunOverrideExt on ProfileTun {
  Map<String, Object?> overrideJson(Set<TunOverrideKey> keys) =>
      _overrideJson(toJson(), TunOverrideKey.values, keys);
}

/// Network TUN values changed from their defaults become app-wide overrides.
Map<String, Object?> _withLegacyTunOverride(Map<String, Object?> json) {
  final raw = json['tun'];
  if (json.containsKey(_tunOverrideKeysJsonKey) || raw is! Map) {
    return json;
  }
  final tun = Tun.safeFormJson(Map<String, Object?>.from(raw));
  final override = ProfileTun(
    mtu: tun.mtu,
    congestionController: tun.congestionController,
    strictRoute: raw['strict-route'] == true,
    routeAddress: tun.routeAddress,
    routeExcludeAddress: tun.routeExcludeAddress,
  );
  return {
    ...json,
    'tun-override': override.toJson(),
    _tunOverrideKeysJsonKey: [
      if (tun.mtu != defaultTunMtu) TunOverrideKey.mtu.path,
      if (tun.congestionController != defaultCongestionController)
        TunOverrideKey.congestionController.path,
      if (override.strictRoute) TunOverrideKey.strictRoute.path,
      if (tun.routeAddress.isNotEmpty) TunOverrideKey.routeAddress.path,
      if (tun.routeExcludeAddress.isNotEmpty)
        TunOverrideKey.routeExcludeAddress.path,
    ],
  };
}

@freezed
abstract class ProfileOverrides with _$ProfileOverrides {
  const factory ProfileOverrides({
    @Default(defaultDns) @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
    @Default({})
    @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)
    Set<DnsOverrideKey> dnsOverrideKeys,
    @Default(defaultNtp) @JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,
    @Default({})
    @JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson)
    Set<NtpOverrideKey> ntpOverrideKeys,
    @Default(defaultSniffer)
    @JsonKey(fromJson: Sniffer.safeSnifferFromJson)
    Sniffer sniffer,
    @Default({})
    @JsonKey(
      name: _snifferOverrideKeysJsonKey,
      fromJson: _snifferOverrideKeysFromJson,
    )
    Set<SnifferOverrideKey> snifferOverrideKeys,
    @Default(defaultProfileTun)
    @JsonKey(fromJson: ProfileTun.safeFromJson)
    ProfileTun tun,
    @Default({})
    @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)
    Set<TunOverrideKey> tunOverrideKeys,
    @Default({})
    @JsonKey(name: 'proxy-providers')
    Map<String, ProxyProviderOptions> proxyProviders,
  }) = _ProfileOverrides;

  factory ProfileOverrides.fromJson(Map<String, Object?> json) =>
      _$ProfileOverridesFromJson(json);

  factory ProfileOverrides.safeFromJson(Map<String, Object?> json) {
    return decodeSalvaging(
      'profile overrides',
      json,
      ProfileOverrides.fromJson,
    );
  }
}

@freezed
abstract class ProviderHealthCheck with _$ProviderHealthCheck {
  const factory ProviderHealthCheck({
    String? url,
    int? interval,
    int? timeout,
    bool? lazy,
    @JsonKey(name: 'expected-status') String? expectedStatus,
  }) = _ProviderHealthCheck;

  factory ProviderHealthCheck.fromJson(Map<String, Object?> json) =>
      _$ProviderHealthCheckFromJson(json);
}

@freezed
abstract class ProviderOverride with _$ProviderOverride {
  const factory ProviderOverride({
    @JsonKey(name: 'additional-prefix') String? additionalPrefix,
    @JsonKey(name: 'additional-suffix') String? additionalSuffix,
    bool? udp,
    @JsonKey(name: 'skip-cert-verify') bool? skipCertVerify,
    @JsonKey(name: 'ip-version') IpVersion? ipVersion,
  }) = _ProviderOverride;

  factory ProviderOverride.fromJson(Map<String, Object?> json) =>
      _$ProviderOverrideFromJson(json);
}

/// Keyed in a custom profile's overrides by the provider's name. The update
/// interval stays with the app, which keeps the file the provider reads.
@freezed
abstract class ProxyProviderOptions with _$ProxyProviderOptions {
  const factory ProxyProviderOptions({
    @Default(ProviderHealthCheck())
    @JsonKey(name: 'health-check')
    ProviderHealthCheck healthCheck,
    String? filter,
    @JsonKey(name: 'exclude-filter') String? excludeFilter,
    @Default(ProviderOverride())
    @JsonKey(name: 'override')
    ProviderOverride proxyOverride,

    /// Where the filters list shows the exclude filters among the filters,
    /// which no config carries, as `ProxyProviderFiltersSliver` writes it.
    List<String>? memberLayout,
  }) = _ProxyProviderOptions;

  factory ProxyProviderOptions.fromJson(Map<String, Object?> json) =>
      _$ProxyProviderOptionsFromJson(json);
}

extension ProxyProviderOptionsExt on ProxyProviderOptions {
  /// A health check without a url never runs, so one always carries a url.
  /// A text option added but left empty stays in the form and out of here.
  Map<String, Object?> get definition {
    String? text(String? value) => value?.isNotEmpty == true ? value : null;
    final healthCheck = this.healthCheck.copyWith(
      url: text(this.healthCheck.url),
      expectedStatus: text(this.healthCheck.expectedStatus),
    );
    final proxyOverride = this.proxyOverride.copyWith(
      additionalPrefix: text(this.proxyOverride.additionalPrefix),
      additionalSuffix: text(this.proxyOverride.additionalSuffix),
    );
    return {
      if (healthCheck != const ProviderHealthCheck())
        'health-check': {
          'enable': true,
          'url': healthCheck.url ?? defaultTestUrl,
          'interval': ?healthCheck.interval,
          'timeout': ?healthCheck.timeout,
          'lazy': ?healthCheck.lazy,
          'expected-status': ?healthCheck.expectedStatus,
        },
      'filter': ?filter,
      'exclude-filter': ?excludeFilter,
      if (proxyOverride != const ProviderOverride())
        'override': {
          'additional-prefix': ?proxyOverride.additionalPrefix,
          'additional-suffix': ?proxyOverride.additionalSuffix,
          'udp': ?proxyOverride.udp,
          'skip-cert-verify': ?proxyOverride.skipCertVerify,
          'ip-version': ?proxyOverride.ipVersion?.value,
        },
    };
  }
}

extension ProfileOverridesExt on ProfileOverrides {
  /// A custom profile brings no DNS section of its own, so it runs on
  /// [baselineDnsOverrideKeys], which turn DNS on, unless its own `enable`
  /// turns it off.
  bool get customDnsEnabled =>
      !dnsOverrideKeys.contains(DnsOverrideKey.enable) || dns.enable;

  bool get customNtpEnabled =>
      ntpOverrideKeys.contains(NtpOverrideKey.enable) && ntp.enable;

  bool get customSnifferEnabled =>
      snifferOverrideKeys.contains(SnifferOverrideKey.enable) && sniffer.enable;

  ProfileOverrides overAppTun(ProfileTun tun, Set<TunOverrideKey> keys) {
    final own = this.tun.toJson();
    return copyWith(
      tun: ProfileTun.fromJson({
        ...tun.toJson(),
        for (final key in tunOverrideKeys) key.path: own[key.path],
      }),
      tunOverrideKeys: {...keys, ...tunOverrideKeys},
    );
  }
}

@freezed
abstract class Rule with _$Rule {
  const factory Rule({
    @Default(-1) int id,
    @JsonKey(includeFromJson: false, includeToJson: false) int? profileId,
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
      ruleTarget: RuleTarget.DIRECT.value,
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
        ruleTarget: RuleTarget.DIRECT.value,
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

final class RuleLineException implements Exception {
  final int line;

  const RuleLineException(this.line);
}

String encodeRuleList(Iterable<Rule> rules) {
  return rules.map((rule) => '- ${_ruleScalar(rule.rawValue)}\n').join();
}

String _ruleScalar(String value) {
  if (!value.contains(': ') && !value.contains(' #') && !value.endsWith(':')) {
    return value;
  }
  return "'${value.replaceAll("'", "''")}'";
}

final _rulesHeader = RegExp(r'^rules\s*[:：]$', caseSensitive: false);

List<({int line, Rule rule})> decodeRuleList(
  String content, {
  Iterable<Rule> previous = const [],
}) {
  final unusedIds = <String, List<int>>{};
  for (final rule in previous) {
    unusedIds.putIfAbsent(rule.rawValue, () => []).add(rule.id);
  }
  return [
    for (final (index, line) in content.split('\n').indexed)
      if (line.trim() case final text
          when text.isNotEmpty &&
              !text.startsWith('#') &&
              !_rulesHeader.hasMatch(text))
        (line: index + 1, rule: _ruleAt(_ruleText(text), index + 1, unusedIds)),
  ];
}

String _ruleText(String line) {
  final text = line.startsWith('-') ? line.substring(1).trimLeft() : line;
  if (text.startsWith("'") || text.startsWith('"')) {
    return switch (_loadScalar(text)) {
      final String value => value,
      _ => text,
    };
  }
  final comment = text.indexOf(' #');
  return comment < 0 ? text : text.substring(0, comment).trimRight();
}

Object? _loadScalar(String text) {
  try {
    return loadYaml(text);
  } on YamlException {
    return null;
  }
}

Rule _ruleAt(String value, int line, Map<String, List<int>> unusedIds) {
  final type = value.split(',').first.trim().toUpperCase();
  if (!RuleAction.values.any((action) => action.value == type)) {
    throw RuleLineException(line);
  }
  final rule = Rule.parse(value);
  final ids = unusedIds[rule.rawValue];
  return ids == null || ids.isEmpty ? rule : rule.copyWith(id: ids.removeAt(0));
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
    @Default(15) @JsonKey(name: 'keep-alive-idle') int keepAliveIdle,
    @Default(false) @JsonKey(name: 'disable-keep-alive') bool disableKeepAlive,
    @Default(0) @JsonKey(name: 'routing-mark') int routingMark,
    @Default(true) @JsonKey(name: 'unified-delay') bool unifiedDelay,
    @Default(true) @JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,
    @Default(defaultTun) @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
    @Default(defaultDns) @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
    @Default({})
    @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)
    Set<DnsOverrideKey> dnsOverrideKeys,
    @Default(defaultProfileTun)
    @JsonKey(name: 'tun-override', fromJson: ProfileTun.safeFromJson)
    ProfileTun tunOverride,
    @Default({})
    @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)
    Set<TunOverrideKey> tunOverrideKeys,
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
    @Default('') String secret,
    @Default({}) Map<String, String> hosts,
    @Default(false) @JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,
    @Default(24) @JsonKey(name: 'geo-update-interval') int geoUpdateInterval,
  }) = _PatchClashConfig;

  factory PatchClashConfig.fromJson(Map<String, Object?> json) =>
      _$PatchClashConfigFromJson(
        _withLegacyTunOverride(_withLegacyDnsOverrideKeys(json)),
      );

  factory PatchClashConfig.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultClashConfig;
    }
    return decodeSalvaging('clash config', json, PatchClashConfig.fromJson);
  }
}

extension PatchClashConfigExt on PatchClashConfig {
  UpdateParams toUpdateParams({
    required List<String> authentication,
    required bool skipCertVerify,
  }) {
    return UpdateParams(
      tun: tun,
      authentication: authentication,
      allowLan: allowLan,
      findProcessMode: findProcessMode,
      mode: mode,
      logLevel: logLevel,
      ipv6: ipv6,
      tcpConcurrent: tcpConcurrent,
      externalController: externalController,
      secret: secret,
      unifiedDelay: unifiedDelay,
      mixedPort: mixedPort,
      geoAutoUpdate: geoAutoUpdate,
      geoUpdateInterval: geoUpdateInterval,
      geoXUrl: geoXUrl.raw,
      skipCertVerify: skipCertVerify,
    );
  }

  /// Resets every field [toUpdateParams] patches live, leaving what only a
  /// full setup hands the Core.
  PatchClashConfig get setupOnly => copyWith(
    tun: defaultClashConfig.tun,
    mixedPort: defaultClashConfig.mixedPort,
    allowLan: defaultClashConfig.allowLan,
    findProcessMode: defaultClashConfig.findProcessMode,
    mode: defaultClashConfig.mode,
    logLevel: defaultClashConfig.logLevel,
    ipv6: defaultClashConfig.ipv6,
    tcpConcurrent: defaultClashConfig.tcpConcurrent,
    externalController: defaultClashConfig.externalController,
    secret: defaultClashConfig.secret,
    unifiedDelay: defaultClashConfig.unifiedDelay,
    geoAutoUpdate: defaultClashConfig.geoAutoUpdate,
    geoUpdateInterval: defaultClashConfig.geoUpdateInterval,
    geoXUrl: defaultClashConfig.geoXUrl,
  );

  PatchClashConfig ensureControllerSecret() {
    if (externalController == ExternalControllerStatus.close) {
      return secret.isEmpty ? this : copyWith(secret: '');
    }
    return secret.isEmpty ? copyWith(secret: generateRandomSecret(32)) : this;
  }
}
