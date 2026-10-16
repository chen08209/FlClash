enum YamlKind { scalar, map, list }

/// Where a scalar's completions come from besides [YamlSchema.values].
enum YamlScalar {
  plain,
  rule,
  rulePayload,
  policy,

  /// A policy the core looks up once the config is loaded, when GLOBAL exists.
  outbound,
  proxyProvider,
  ruleProvider,
  subRule,
}

/// The part of the mihomo configuration the editor completes against. A map
/// lists its [fields], plus [variants] keyed by the value of its `type`; a map
/// with free keys and a list both describe their members with [entry].
class YamlSchema {
  final YamlKind kind;
  final Map<String, YamlSchema> fields;
  final Map<String, Map<String, YamlSchema>> variants;
  final YamlSchema? entry;
  final List<String> values;
  final YamlScalar scalar;

  const YamlSchema.scalar([this.values = const []])
    : kind = YamlKind.scalar,
      fields = const {},
      variants = const {},
      entry = null,
      scalar = YamlScalar.plain;

  const YamlSchema.of(this.scalar, [this.values = const []])
    : kind = YamlKind.scalar,
      fields = const {},
      variants = const {},
      entry = null;

  const YamlSchema.map(this.fields, {this.variants = const {}})
    : kind = YamlKind.map,
      entry = null,
      values = const [],
      scalar = YamlScalar.plain;

  const YamlSchema.dict(YamlSchema this.entry)
    : kind = YamlKind.map,
      fields = const {},
      variants = const {},
      values = const [],
      scalar = YamlScalar.plain;

  const YamlSchema.list(YamlSchema this.entry)
    : kind = YamlKind.list,
      fields = const {},
      variants = const {},
      values = const [],
      scalar = YamlScalar.plain;

  String get hint => switch (kind) {
    YamlKind.map => '{…}',
    YamlKind.list => '[…]',
    YamlKind.scalar when values.length > 3 =>
      '${values.take(3).join(' | ')} | …',
    YamlKind.scalar => values.join(' | '),
  };

  /// The fields of a map whose `type` is [type], all variants when unknown.
  Map<String, YamlSchema> fieldsFor(String? type) {
    if (variants.isEmpty) {
      return fields;
    }
    final variant = variants[type];
    return {
      ...fields,
      if (variant != null)
        ...variant
      else
        for (final fields in variants.values) ...fields,
    };
  }
}

enum EditorSchema {
  config(clashConfigSchema),
  dns(_dns, 'dns'),
  ntp(_ntp, 'ntp'),
  sniffer(_sniffer, 'sniffer'),
  proxy(_proxy),
  proxyGroup(_customProxyGroup, 'proxy-groups'),
  rules(_rules),
  shareLinks(_str),
  provider(_providerFile);

  final YamlSchema root;

  /// The configuration key that holds this part, which a pasted fragment may
  /// still carry.
  final String? section;

  const EditorSchema(this.root, [this.section]);
}

const _str = YamlSchema.scalar();
const _bool = YamlSchema.scalar(['true', 'false']);
const _strList = YamlSchema.list(_str);
const _policy = YamlSchema.of(YamlScalar.policy);
const _outbound = YamlSchema.of(YamlScalar.outbound);
const _headers = YamlSchema.dict(_strList);

const ruleTypes = {
  'DOMAIN': 'example.com',
  'DOMAIN-SUFFIX': 'example.com',
  'DOMAIN-KEYWORD': 'example',
  'DOMAIN-WILDCARD': '*.example.com',
  'DOMAIN-REGEX': r'^.*\.example\.com$',
  'GEOSITE': 'cn',
  'IP-CIDR': '192.168.0.0/16',
  'IP-CIDR6': 'fc00::/7',
  'IP-SUFFIX': '8.8.8.8/24',
  'IP-ASN': '13335',
  'GEOIP': 'CN',
  'SRC-GEOIP': 'CN',
  'SRC-IP-ASN': '13335',
  'SRC-IP-CIDR': '192.168.1.0/24',
  'SRC-IP-SUFFIX': '192.168.1.1/24',
  'DST-PORT': '443',
  'SRC-PORT': '7777',
  'IN-PORT': '7890',
  'IN-TYPE': 'SOCKS/HTTP',
  'IN-USER': 'user',
  'IN-NAME': 'listener',
  'REMATCH-NAME': 'rematch',
  'PROCESS-NAME': 'curl',
  'PROCESS-NAME-REGEX': '.*telegram.*',
  'PROCESS-NAME-WILDCARD': '*telegram*',
  'PROCESS-PATH': '/usr/bin/curl',
  'PROCESS-PATH-REGEX': '.*bin/curl',
  'PROCESS-PATH-WILDCARD': '/usr/bin/*',
  'UID': '1001',
  'NETWORK': 'udp',
  'DSCP': '4',
  'RULE-SET': 'provider',
  'SUB-RULE': '(NETWORK,tcp)',
  'AND': '((DOMAIN,…),(NETWORK,udp))',
  'OR': '((DOMAIN,…),(NETWORK,udp))',
  'NOT': '((DOMAIN,…))',
  'MATCH': '',
};

/// Rules that take the options after their policy.
const noResolveRuleTypes = {
  'IP-CIDR',
  'IP-CIDR6',
  'IP-SUFFIX',
  'IP-ASN',
  'GEOIP',
  'RULE-SET',
};

const rulePayloadValues = {
  'GEOSITE': [
    'cn',
    'geolocation-!cn',
    'geolocation-cn',
    'private',
    'category-ads-all',
    'gfw',
    'google',
    'youtube',
    'github',
    'microsoft',
    'apple',
    'openai',
    'anthropic',
    'telegram',
    'twitter',
    'facebook',
    'netflix',
    'spotify',
    'steam',
    'tiktok',
    'bilibili',
  ],
  'GEOIP': [
    'CN',
    'private',
    'LAN',
    'telegram',
    'google',
    'netflix',
    'facebook',
    'twitter',
    'cloudflare',
  ],
  'SRC-GEOIP': ['CN', 'private', 'LAN'],
  'NETWORK': ['tcp', 'udp'],
  'IN-TYPE': [
    'HTTP',
    'HTTPS',
    'SOCKS4',
    'SOCKS5',
    'REDIR',
    'TPROXY',
    'TUN',
    'INNER',
    'SOCKS',
    'SHADOWSOCKS',
    'SNELL',
    'VMESS',
    'VLESS',
    'TROJAN',
    'TUNNEL',
    'TUIC',
    'HYSTERIA2',
    'ANYTLS',
    'MIERU',
    'SUDOKU',
    'TRUSTTUNNEL',
    'SHADOWQUIC',
  ],
};

const ruleOptions = ['no-resolve', 'src'];

const _nameserver = YamlSchema.list(
  YamlSchema.scalar([
    'https://dns.alidns.com/dns-query',
    'https://doh.pub/dns-query',
    'https://dns.google/dns-query',
    'https://cloudflare-dns.com/dns-query',
    'tls://dns.alidns.com',
    'tls://1.1.1.1',
    'quic://dns.adguard-dns.com',
    '223.5.5.5',
    '119.29.29.29',
    '8.8.8.8',
    '1.1.1.1',
    'system',
    'dhcp://en0',
  ]),
);

const _clientFingerprint = YamlSchema.scalar([
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
]);

const _ipVersion = YamlSchema.scalar([
  'dual',
  'ipv4',
  'ipv6',
  'ipv4-prefer',
  'ipv6-prefer',
]);

const _smux = YamlSchema.map({
  'enabled': _bool,
  'protocol': YamlSchema.scalar(['smux', 'yamux', 'h2mux']),
  'max-connections': _str,
  'min-streams': _str,
  'max-streams': _str,
  'padding': _bool,
  'statistic': _bool,
  'only-tcp': _bool,
  'brutal-opts': YamlSchema.map({'enabled': _bool, 'up': _str, 'down': _str}),
});

const _congestionController = YamlSchema.scalar([
  'bbr',
  'cubic',
  'new_reno',
  'bbr_meta_v1',
  'bbr_meta_v2',
]);

const _bbrProfile = YamlSchema.scalar([
  'conservative',
  'standard',
  'aggressive',
]);

const _ech = YamlSchema.map({
  'enable': _bool,
  'config': _str,
  'query-server-name': _str,
});

const _ipStack = YamlSchema.map({
  'mode': YamlSchema.scalar(['auto', 'gvisor', 'mips']),
  'congestion-controller': YamlSchema.scalar(['cubic', 'reno', 'bbr', 'bbr3']),
});

const _sudokuMultiplex = YamlSchema.scalar(['off', 'auto', 'on']);

const _sudokuHttpMaskMode = YamlSchema.scalar([
  'legacy',
  'stream',
  'poll',
  'auto',
  'ws',
]);

const _openvpnCiphers = [
  'AES-128-GCM',
  'AES-192-GCM',
  'AES-256-GCM',
  'AES-128-CBC',
  'AES-192-CBC',
  'AES-256-CBC',
  'CHACHA20-POLY1305',
];

const _proxyTypes = [
  'ss',
  'ssr',
  'vmess',
  'vless',
  'trojan',
  'anytls',
  'hysteria2',
  'hysteria',
  'tuic',
  'wireguard',
  'socks5',
  'http',
  'snell',
  'ssh',
  'mieru',
  'easytier',
  'shadowquic',
  'gost-relay',
  'sudoku',
  'masque',
  'trusttunnel',
  'openvpn',
  'tailscale',
  'zerotier',
  'direct',
  'dns',
  'reject',
  'rematch',
];

const _proxyCommon = {'name': _str, 'type': YamlSchema.scalar(_proxyTypes)};

const _server = {'server': _str, 'port': _str};

const _dial = {
  'ip-version': _ipVersion,
  'interface-name': _str,
  'routing-mark': _str,
  'dialer-proxy': _outbound,
};

/// Only the types that hand these to their dialer list them.
const _tcpDial = {'tfo': _bool, 'mptcp': _bool, ..._dial};

const _tls = {
  'alpn': YamlSchema.list(YamlSchema.scalar(['h2', 'http/1.1', 'h3'])),
  'skip-cert-verify': _bool,
  'name-cert-verify': _str,
  'fingerprint': _str,
  'certificate': _str,
  'private-key': _str,
  'ech-opts': _ech,
};

/// vmess and vless switch TLS on with `tls` and name the server `servername`,
/// where the types that always use TLS call it `sni`.
const _optionalTls = {
  'tls': _bool,
  'servername': _str,
  'client-fingerprint': _clientFingerprint,
  ..._tls,
};

const _sniTls = {'sni': _str, ..._tls};

const _tlsLayers = {
  'shadow-tls-opts': YamlSchema.map({
    'password': _str,
    'version': YamlSchema.scalar(['1', '2', '3']),
  }),
  'restls-opts': YamlSchema.map({
    'password': _str,
    'version-hint': YamlSchema.scalar(['tls12', 'tls13']),
    'restls-script': _str,
  }),
  'jls-opts': YamlSchema.map({'username': _str, 'password': _str}),
};

const _reality = {
  'reality-opts': YamlSchema.map({
    'public-key': _str,
    'short-id': _str,
    'support-x25519mlkem768': _bool,
  }),
};

const _wsOpts = YamlSchema.map({
  'path': _str,
  'headers': YamlSchema.dict(_str),
  'max-early-data': _str,
  'early-data-header-name': _str,
  'v2ray-http-upgrade': _bool,
  'v2ray-http-upgrade-fast-open': _bool,
});

const _httpOpts = YamlSchema.map({
  'method': YamlSchema.scalar(['GET', 'POST']),
  'path': _strList,
  'headers': _headers,
});

const _h2Opts = YamlSchema.map({'host': _strList, 'path': _str});

const _grpcOpts = YamlSchema.map({
  'grpc-service-name': _str,
  'grpc-user-agent': _str,
  'ping-interval': _str,
  'max-connections': _str,
  'min-streams': _str,
  'max-streams': _str,
});

const _mkcpOpts = YamlSchema.map(_mkcpFields);

const _mkcpFields = {
  'mtu': _str,
  'tti': _str,
  'uplink-capacity': _str,
  'downlink-capacity': _str,
  'congestion': _bool,
  'write-buffer': _str,
  'read-buffer': _str,
  'seed': _str,
  'header': YamlSchema.scalar([
    'none',
    'srtp',
    'utp',
    'wechat-video',
    'dtls',
    'wireguard',
  ]),
};

const _vmessTransport = {
  'network': YamlSchema.scalar([
    'tcp',
    'ws',
    'http',
    'h2',
    'grpc',
    'mekya',
    'mkcp',
  ]),
  'ws-opts': _wsOpts,
  'http-opts': _httpOpts,
  'h2-opts': _h2Opts,
  'grpc-opts': _grpcOpts,
  'mkcp-opts': _mkcpOpts,
  'mekya-opts': YamlSchema.map({
    'url': _str,
    'h2-pool-size': _str,
    'max-write-delay': _str,
    'max-request-size': _str,
    'polling-interval-initial': _str,
    'max-write-size': _str,
    'max-write-duration-ms': _str,
    'max-simultaneous-write-connection': _str,
    'packet-writing-buffer': _str,
    'kcp': _mkcpOpts,
  }),
  'smux': _smux,
};

const _vlessTransport = {
  'network': YamlSchema.scalar(['tcp', 'ws', 'http', 'h2', 'grpc', 'xhttp']),
  'ws-opts': _wsOpts,
  'http-opts': _httpOpts,
  'h2-opts': _h2Opts,
  'grpc-opts': _grpcOpts,
  'xhttp-opts': YamlSchema.map({
    'path': _str,
    'host': _str,
    'mode': YamlSchema.scalar(['auto', 'packet-up', 'stream-up', 'stream-one']),
    'headers': YamlSchema.dict(_str),
    'no-grpc-header': _bool,
    'x-padding-bytes': _str,
    'x-padding-obfs-mode': _bool,
    'x-padding-key': _str,
    'x-padding-header': _str,
    'x-padding-placement': YamlSchema.scalar([
      'queryInHeader',
      'header',
      'cookie',
      'query',
    ]),
    'x-padding-method': YamlSchema.scalar(['repeat-x', 'tokenish']),
    'uplink-http-method': _str,
    'session-placement': _xhttpPlacement,
    'session-key': _str,
    'session-table': YamlSchema.scalar([
      'uuid',
      'number',
      'hex',
      'HEX',
      'alphabet',
      'Alphabet',
      'ALPHABET',
      'base36',
      'BASE36',
      'Base62',
    ]),
    'session-length': _str,
    'seq-placement': _xhttpPlacement,
    'seq-key': _str,
    'uplink-data-placement': YamlSchema.scalar(['body', 'header', 'cookie']),
    'uplink-data-key': _str,
    'uplink-chunk-size': _str,
    'sc-max-each-post-bytes': _str,
    'sc-min-posts-interval-ms': _str,
    'reuse-settings': _xhttpReuse,
    'download-settings': YamlSchema.map({
      ..._server,
      'path': _str,
      'host': _str,
      'headers': YamlSchema.dict(_str),
      'reuse-settings': _xhttpReuse,
      ..._optionalTls,
      ..._tlsLayers,
      ..._reality,
    }),
  }),
  'smux': _smux,
};

const _xhttpPlacement = YamlSchema.scalar([
  'path',
  'query',
  'header',
  'cookie',
]);

const _xhttpReuse = YamlSchema.map({
  'max-concurrency': _str,
  'max-connections': _str,
  'c-max-reuse-times': _str,
  'h-max-request-times': _str,
  'h-max-reusable-secs': _str,
  'h-keep-alive-period': _str,
});

const _trojanTransport = {
  'network': YamlSchema.scalar(['tcp', 'ws', 'grpc']),
  'ws-opts': _wsOpts,
  'grpc-opts': _grpcOpts,
  'smux': _smux,
};

const _aeadCiphers = [
  'aes-128-gcm',
  'aes-192-gcm',
  'aes-256-gcm',
  'chacha20-ietf-poly1305',
  'xchacha20-ietf-poly1305',
];

const _ssCiphers = [
  ..._aeadCiphers,
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
  ..._streamCiphers,
];

/// ShadowsocksR takes stream ciphers only.
const _streamCiphers = [
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

const _kcptunFields = {
  'key': _str,
  'crypt': YamlSchema.scalar([
    'aes',
    'aes-128',
    'aes-192',
    'aes-128-gcm',
    'salsa20',
    'blowfish',
    'twofish',
    'cast5',
    '3des',
    'tea',
    'xtea',
    'xor',
    'none',
    'null',
  ]),
  'conn': _str,
  'autoexpire': _str,
  'scavengettl': _str,
  'mtu': _str,
  'ratelimit': _str,
  'sndwnd': _str,
  'rcvwnd': _str,
  'datashard': _str,
  'parityshard': _str,
  'dscp': _str,
  'nocomp': _bool,
  'acknodelay': _bool,
  'nodelay': _str,
  'interval': _str,
  'resend': _str,
  'nc': _str,
  'sockbuf': _str,
  'smuxver': YamlSchema.scalar(['1', '2']),
  'smuxbuf': _str,
  'framesize': _str,
  'streambuf': _str,
  'keepalive': _str,
};

const _pluginTls = {
  'skip-cert-verify': _bool,
  'name-cert-verify': _str,
  'certificate': _str,
  'private-key': _str,
};

const _tlsMirrorTime = YamlSchema.map({
  'base-nanoseconds': _str,
  'uniform-random-multiplier-nanoseconds': _str,
});

/// The ss plugins and snell obfs modes shadow-tls, restls and jls read these.
const _tlsLayerOpts = {
  'username': _str,
  'password': _str,
  'version': YamlSchema.scalar(['1', '2', '3']),
  'fingerprint': _str,
  'version-hint': YamlSchema.scalar(['tls12', 'tls13']),
  'restls-script': _str,
};

const _proxyVariants = <String, Map<String, YamlSchema>>{
  'ss': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'cipher': YamlSchema.scalar(_ssCiphers),
    'password': _str,
    'udp-over-tcp': _bool,
    'udp-over-tcp-version': YamlSchema.scalar(['1', '2']),
    'client-fingerprint': _clientFingerprint,
    'plugin': YamlSchema.scalar([
      'obfs',
      'v2ray-plugin',
      'gost-plugin',
      'shadow-tls',
      'restls',
      'jls',
      'kcptun',
    ]),
    'plugin-opts': YamlSchema.map({
      'mode': YamlSchema.scalar([
        'http',
        'tls',
        'websocket',
        'normal',
        'fast',
        'fast2',
        'fast3',
        'manual',
      ]),
      'host': _str,
      'path': _str,
      'tls': _bool,
      'headers': YamlSchema.dict(_str),
      'mux': _bool,
      'v2ray-http-upgrade': _bool,
      'v2ray-http-upgrade-fast-open': _bool,
      'alpn': _strList,
      'ech-opts': _ech,
      ..._pluginTls,
      ..._tlsLayerOpts,
      ..._kcptunFields,
    }),
    'smux': _smux,
  },
  'ssr': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'cipher': YamlSchema.scalar(_streamCiphers),
    'password': _str,
    'obfs': YamlSchema.scalar([
      'plain',
      'http_simple',
      'http_post',
      'random_head',
      'tls1.2_ticket_auth',
      'tls1.2_ticket_fastauth',
    ]),
    'obfs-param': _str,
    'protocol': YamlSchema.scalar([
      'origin',
      'auth_sha1_v4',
      'auth_aes128_md5',
      'auth_aes128_sha1',
      'auth_chain_a',
      'auth_chain_b',
    ]),
    'protocol-param': _str,
  },
  'vmess': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'uuid': _str,
    'alterId': _str,
    'cipher': YamlSchema.scalar([
      'auto',
      'none',
      'zero',
      'aes-128-gcm',
      'chacha20-poly1305',
      'aes-128-cfb',
    ]),
    'packet-encoding': YamlSchema.scalar(['packetaddr', 'xudp']),
    'global-padding': _bool,
    'authenticated-length': _bool,
    ..._optionalTls,
    ..._tlsLayers,
    ..._reality,
    'tlsmirror-opts': YamlSchema.map({
      'primary-key': _str,
      'explicit-nonce-ciphersuites': _strList,
      'defer-instance-derived-write-time': _tlsMirrorTime,
      'transport-layer-padding': YamlSchema.map({'enabled': _bool}),
      'connection-enrolment': YamlSchema.map({
        'primary-ingress-outbound': _str,
        'primary-egress-outbound': _str,
      }),
      'embedded-traffic-generator': YamlSchema.map({
        'steps': YamlSchema.list(
          YamlSchema.map({
            'name': _str,
            'host': _str,
            'path': _str,
            'method': _str,
            'headers': YamlSchema.list(
              YamlSchema.map({'name': _str, 'value': _str, 'values': _strList}),
            ),
            'next-step': YamlSchema.list(
              YamlSchema.map({'weight': _str, 'goto-location': _str}),
            ),
            'connection-ready': _bool,
            'connection-recall-exit': _bool,
            'wait-time': _tlsMirrorTime,
            'h2-do-not-wait-for-download-finish': _bool,
          }),
        ),
      }),
      'sequence-watermarking-enabled': _bool,
    }),
    ..._vmessTransport,
  },
  'vless': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'uuid': _str,
    'flow': YamlSchema.scalar(['xtls-rprx-vision']),
    'encryption': _str,
    'packet-encoding': YamlSchema.scalar(['packetaddr', 'xudp']),
    ..._optionalTls,
    ..._tlsLayers,
    ..._reality,
    ..._vlessTransport,
  },
  'trojan': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'password': _str,
    'ss-opts': YamlSchema.map({
      'enabled': _bool,
      'method': YamlSchema.scalar(_aeadCiphers),
      'password': _str,
    }),
    'client-fingerprint': _clientFingerprint,
    ..._sniTls,
    ..._tlsLayers,
    ..._reality,
    ..._trojanTransport,
  },
  'anytls': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'password': _str,
    'idle-session-check-interval': _str,
    'idle-session-timeout': _str,
    'min-idle-session': _str,
    'client-metadata': _str,
    'disable-reuse': _bool,
    'client-fingerprint': _clientFingerprint,
    ..._sniTls,
    ..._tlsLayers,
  },
  'hysteria2': {
    ..._server,
    ..._dial,
    'ports': _str,
    'password': _str,
    'up': _str,
    'down': _str,
    'obfs': YamlSchema.scalar(['salamander', 'gecko']),
    'obfs-password': _str,
    'obfs-min-packet-size': _str,
    'obfs-max-packet-size': _str,
    'hop-interval': _str,
    'bbr-profile': _bbrProfile,
    'cwnd': _str,
    'udp-mtu': _str,
    'handshake-timeout': _str,
    'initial-stream-receive-window': _str,
    'max-stream-receive-window': _str,
    'initial-connection-receive-window': _str,
    'max-connection-receive-window': _str,
    'realm-opts': YamlSchema.map({
      'enable': _bool,
      'server-url': _str,
      'token': _str,
      'realm-id': _str,
      'stun-servers': _strList,
      'sni': _str,
      'alpn': _strList,
      'fingerprint': _str,
      ..._pluginTls,
    }),
    ..._sniTls,
  },
  'hysteria': {
    ..._server,
    ..._dial,
    'ports': _str,
    'auth-str': _str,
    'auth': _str,
    'protocol': YamlSchema.scalar(['udp', 'wechat-video', 'faketcp']),
    'obfs': _str,
    'up': _str,
    'down': _str,
    'recv-window-conn': _str,
    'recv-window': _str,
    'disable-mtu-discovery': _bool,
    'fast-open': _bool,
    'hop-interval': _str,
    ..._sniTls,
  },
  'tuic': {
    ..._server,
    ..._dial,
    'uuid': _str,
    'password': _str,
    'token': _str,
    'ip': _str,
    'heartbeat-interval': _str,
    'disable-sni': _bool,
    'reduce-rtt': _bool,
    'request-timeout': _str,
    'udp-relay-mode': YamlSchema.scalar(['native', 'quic']),
    'congestion-controller': _congestionController,
    'bbr-profile': _bbrProfile,
    'max-udp-relay-packet-size': _str,
    'fast-open': _bool,
    'max-open-streams': _str,
    'cwnd': _str,
    'recv-window-conn': _str,
    'recv-window': _str,
    'disable-mtu-discovery': _bool,
    'max-datagram-frame-size': _str,
    'udp-over-stream': _bool,
    'udp-over-stream-version': YamlSchema.scalar(['1', '2']),
    ..._sniTls,
  },
  'wireguard': {
    ..._server,
    'udp': _bool,
    ..._dial,
    'ip': _str,
    'ipv6': _str,
    'private-key': _str,
    'public-key': _str,
    'pre-shared-key': _str,
    'reserved': _strList,
    'mtu': _str,
    'workers': _str,
    'refresh-server-ip-interval': _str,
    'ip-stack': _ipStack,
    'allowed-ips': _strList,
    'persistent-keepalive': _str,
    'remote-dns-resolve': _bool,
    'dns': _strList,
    'peers': YamlSchema.list(
      YamlSchema.map({
        'server': _str,
        'port': _str,
        'public-key': _str,
        'pre-shared-key': _str,
        'reserved': _strList,
        'allowed-ips': _strList,
      }),
    ),
    'amnezia-wg-option': YamlSchema.map({
      'jc': _str,
      'jmin': _str,
      'jmax': _str,
      's1': _str,
      's2': _str,
      'h1': _str,
      'h2': _str,
      'h3': _str,
      'h4': _str,
      'version': _str,
      's3': _str,
      's4': _str,
      'i1': _str,
      'i2': _str,
      'i3': _str,
      'i4': _str,
      'i5': _str,
      'header-protection-key': _str,
      'content-padding-addition': _str,
      'rekey-after-time': _str,
      'rekey-timeout': _str,
      'reject-after-time': _str,
      'keepalive-timeout': _str,
      'max-handshake-attempts': _str,
      'random-trailers': _bool,
      'disable-cookies': _bool,
    }),
  },
  'socks5': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'username': _str,
    'password': _str,
    'tls': _bool,
    'fingerprint': _str,
    'skip-cert-verify': _bool,
    'name-cert-verify': _str,
    'certificate': _str,
    'private-key': _str,
  },
  'http': {
    ..._server,
    ..._tcpDial,
    'username': _str,
    'password': _str,
    'tls': _bool,
    'sni': _str,
    'fingerprint': _str,
    'skip-cert-verify': _bool,
    'name-cert-verify': _str,
    'certificate': _str,
    'private-key': _str,
    'headers': YamlSchema.dict(_str),
  },
  'snell': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'psk': _str,
    'version': YamlSchema.scalar(['1', '2', '3', '4', '5']),
    'reuse': _bool,
    'client-fingerprint': _clientFingerprint,
    'obfs-opts': YamlSchema.map({
      'mode': YamlSchema.scalar(['http', 'tls', 'shadow-tls', 'restls', 'jls']),
      'host': _str,
      'alpn': _strList,
      ..._pluginTls,
      ..._tlsLayerOpts,
    }),
  },
  'ssh': {
    ..._server,
    ..._tcpDial,
    'username': _str,
    'password': _str,
    'private-key': _str,
    'private-key-passphrase': _str,
    'host-key': _strList,
    'host-key-algorithms': _strList,
  },
  'mieru': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'port-range': _str,
    'transport': YamlSchema.scalar(['TCP', 'UDP']),
    'username': _str,
    'password': _str,
    'multiplexing': YamlSchema.scalar([
      'MULTIPLEXING_DEFAULT',
      'MULTIPLEXING_OFF',
      'MULTIPLEXING_LOW',
      'MULTIPLEXING_MIDDLE',
      'MULTIPLEXING_HIGH',
    ]),
    'handshake-mode': YamlSchema.scalar([
      'HANDSHAKE_DEFAULT',
      'HANDSHAKE_STANDARD',
      'HANDSHAKE_NO_WAIT',
    ]),
    'traffic-pattern': _str,
  },
  'easytier': {
    'udp': _bool,
    ..._dial,
    'network-name': _str,
    'network-secret': _str,
    'hostname': _str,
    'ipv4': _str,
    'dhcp': _bool,
    'peers': _strList,
    'listeners': _strList,
    'no-listener': _bool,
    'mapped-listeners': _strList,
    'exit-nodes': _strList,
    'proxy-networks': _strList,
    'instance-name': _str,
    'state-dir': _str,
    'accept-dns': _bool,
    'enable-exit-node': _bool,
    'enable-encryption': _bool,
    'encryption-algorithm': _str,
    'private-mode': _bool,
    'latency-first': _bool,
    'disable-p2p': _bool,
    'enable-kcp-proxy': _bool,
    'disable-kcp-input': _bool,
    'enable-quic-proxy': _bool,
    'disable-quic-input': _bool,
    'mtu': _str,
    'tld-dns-zone': _str,
    'secure-mode': _bool,
    'local-private-key': _str,
    'local-public-key': _str,
  },
  'shadowquic': {
    ..._server,
    ..._dial,
    'username': _str,
    'password': _str,
    'sni': _str,
    'alpn': _strList,
    'quic-versions': YamlSchema.list(YamlSchema.scalar(['v1', 'v2'])),
    'udp-over-stream': _bool,
    'zero-rtt': _bool,
    'disable-mtu-discovery': _bool,
    'congestion-controller': _congestionController,
    'bbr-profile': _bbrProfile,
    'cwnd': _str,
    'up': _str,
    'down': _str,
    'keep-alive-interval': _str,
    'recv-window-conn': _str,
    'recv-window': _str,
    'max-datagram-frame-size': _str,
    'max-open-streams': _str,
  },
  'gost-relay': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'username': _str,
    'password': _str,
    'forward': _bool,
    'mux': _bool,
    'tls': _bool,
    'sni': _str,
    'skip-cert-verify': _bool,
    'name-cert-verify': _str,
    'fingerprint': _str,
    'certificate': _str,
    'private-key': _str,
    'client-fingerprint': _clientFingerprint,
  },
  'sudoku': {
    ..._server,
    ..._tcpDial,
    'key': _str,
    'aead-method': YamlSchema.scalar([
      'aes-128-gcm',
      'chacha20-poly1305',
      'none',
    ]),
    'padding-min': _str,
    'padding-max': _str,
    'table-type': YamlSchema.scalar([
      'prefer_ascii',
      'prefer_entropy',
      'up_ascii_down_entropy',
      'up_entropy_down_ascii',
    ]),
    'custom-table': _str,
    'custom-tables': _strList,
    'enable-pure-downlink': _bool,
    'multiplex': _sudokuMultiplex,
    'http-mask': _bool,
    'http-mask-mode': _sudokuHttpMaskMode,
    'http-mask-tls': _bool,
    'http-mask-host': _str,
    'path-root': _str,
    'httpmask': YamlSchema.map({
      'disable': _bool,
      'mode': _sudokuHttpMaskMode,
      'tls': _bool,
      'host': _str,
      'path-root': _str,
      'multiplex': _sudokuMultiplex,
    }),
  },
  'masque': {
    ..._server,
    'udp': _bool,
    ..._dial,
    'private-key': _str,
    'public-key': _str,
    'ip': _str,
    'ipv6': _str,
    'uri': _str,
    'sni': _str,
    'skip-cert-verify': _bool,
    'network': YamlSchema.scalar(['h2', 'h3-l4proxy']),
    'congestion-controller': _congestionController,
    'bbr-profile': _bbrProfile,
    'cwnd': _str,
    'mtu': _str,
    'handshake-timeout': _str,
    'ip-stack': _ipStack,
    'remote-dns-resolve': _bool,
    'dns': _strList,
  },
  'trusttunnel': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'username': _str,
    'password': _str,
    'sni': _str,
    'alpn': _strList,
    'skip-cert-verify': _bool,
    'name-cert-verify': _str,
    'fingerprint': _str,
    'certificate': _str,
    'private-key': _str,
    'client-fingerprint': _clientFingerprint,
    'ech-opts': _ech,
    'quic': _bool,
    'congestion-controller': _congestionController,
    'bbr-profile': _bbrProfile,
    'cwnd': _str,
    'health-check': _bool,
    'max-connections': _str,
    'min-streams': _str,
    'max-streams': _str,
  },
  'openvpn': {
    ..._server,
    'udp': _bool,
    ..._tcpDial,
    'proto': YamlSchema.scalar(['udp', 'tcp']),
    'dev': YamlSchema.scalar(['tun']),
    'ca': _str,
    'cert': _str,
    'key': _str,
    'tls-auth': _str,
    'tls-crypt': _str,
    'tls-crypt-v2': _str,
    'key-direction': YamlSchema.scalar(['0', '1']),
    'username': _str,
    'password': _str,
    'cipher': YamlSchema.scalar(_openvpnCiphers),
    'data-ciphers': YamlSchema.list(YamlSchema.scalar(_openvpnCiphers)),
    'data-ciphers-fallback': YamlSchema.scalar(_openvpnCiphers),
    'auth': YamlSchema.scalar(['MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512']),
    'comp-lzo': YamlSchema.scalar(['yes', 'adaptive']),
    'peer-info': YamlSchema.dict(_str),
    'ping': _str,
    'ping-restart': _str,
    'tran-window': _str,
    'handshake-timeout': _str,
    'mtu': _str,
    'ip-stack': _ipStack,
    'remote-dns-resolve': _bool,
    'dns': _strList,
  },
  'tailscale': {
    'udp': _bool,
    ..._dial,
    'hostname': _str,
    'auth-key': _str,
    'control-url': _str,
    'state-dir': _str,
    'ephemeral': _bool,
    'accept-routes': _bool,
    'exit-node': _str,
    'exit-node-allow-lan-access': _bool,
  },
  'zerotier': {
    'udp': _bool,
    ..._dial,
    'network': _str,
    'state-dir': _str,
    'identity-secret': _str,
    'planet': _str,
    'orbit': YamlSchema.list(YamlSchema.map({'world': _str, 'seed': _str})),
    'mtu': _str,
    'physical-mtu': _str,
    'primary-port': _str,
    'secondary-port': _str,
    'low-bandwidth': _bool,
    'encrypted-hello': _bool,
    'tcp-fallback-mode': YamlSchema.scalar(['auto', 'force', 'disable']),
    'tcp-fallback-relay': _str,
    'remote-trace-target': _str,
    'remote-trace-level': _str,
    'ip-stack': _ipStack,
    'remote-dns-resolve': _bool,
    'dns': _strList,
  },
  'direct': {
    'tfo': _bool,
    'mptcp': _bool,
    'ip-version': _ipVersion,
    'interface-name': _str,
    'routing-mark': _str,
  },
  'dns': {},
  'reject': {},
  'rematch': {
    'target-rematch-name': _str,
    'target-sub-rule': YamlSchema.of(YamlScalar.subRule),
  },
};

const _proxy = YamlSchema.map(_proxyCommon, variants: _proxyVariants);

const _healthCheck = YamlSchema.map({
  'enable': _bool,
  'url': YamlSchema.scalar(['https://www.gstatic.com/generate_204']),
  'interval': _str,
  'timeout': _str,
  'lazy': _bool,
  'expected-status': _str,
});

const _proxyGroupFields = {
  'name': _str,
  'type': YamlSchema.scalar(['select', 'url-test', 'fallback', 'load-balance']),
  'proxies': YamlSchema.list(_policy),
  'use': YamlSchema.list(YamlSchema.of(YamlScalar.proxyProvider)),
  'use-position': YamlSchema.dict(_str),
  'url': YamlSchema.scalar(['https://www.gstatic.com/generate_204']),
  'interval': _str,
  'lazy': _bool,
  'timeout': _str,
  'max-failed-times': _str,
  'empty-fallback': _policy,
  'expected-status': _str,
  'filter': _str,
  'exclude-filter': _str,
  'exclude-type': _str,
  'disable-udp': _bool,
  'hidden': _bool,
  'icon': _str,
};

const _proxyGroupVariants = {
  'select': {'default-selected': _policy},
  'url-test': {'tolerance': _str},
  'load-balance': {
    'strategy': YamlSchema.scalar([
      'consistent-hashing',
      'round-robin',
      'sticky-sessions',
    ]),
    'hash-key': YamlSchema.scalar(['in-user']),
  },
};

const _proxyGroup = YamlSchema.map({
  ..._proxyGroupFields,
  'include-all': _bool,
  'include-all-proxies': _bool,
  'include-all-providers': _bool,
}, variants: _proxyGroupVariants);

const _customProxyGroup = YamlSchema.map(
  _proxyGroupFields,
  variants: _proxyGroupVariants,
);

const _providerType = YamlSchema.scalar(['http', 'file', 'inline']);

const _proxyProvider = YamlSchema.map({
  'type': _providerType,
  'url': _str,
  'path': _str,
  'interval': _str,
  'proxy': _outbound,
  'dialer-proxy': _outbound,
  'size-limit': _str,
  'header': _headers,
  'age-secret-key': _str,
  'health-check': _healthCheck,
  'override': YamlSchema.map({
    'tfo': _bool,
    'mptcp': _bool,
    'udp': _bool,
    'udp-over-tcp': _bool,
    'up': _str,
    'down': _str,
    'skip-cert-verify': _bool,
    'name-cert-verify': _str,
    'dialer-proxy': _outbound,
    'interface-name': _str,
    'routing-mark': _str,
    'ip-version': _ipVersion,
    'additional-prefix': _str,
    'additional-suffix': _str,
    'proxy-name': YamlSchema.list(
      YamlSchema.map({'pattern': _str, 'target': _str}),
    ),
    'override-expr': _strList,
  }),
  'filter': _str,
  'exclude-filter': _str,
  'exclude-type': _str,
  'payload': YamlSchema.list(_proxy),
});

const _ruleProvider = YamlSchema.map({
  'type': _providerType,
  'behavior': YamlSchema.scalar(['domain', 'ipcidr', 'classical']),
  'format': YamlSchema.scalar(['yaml', 'text', 'mrs']),
  'url': _str,
  'path': _str,
  'interval': _str,
  'proxy': _outbound,
  'size-limit': _str,
  'header': _headers,
  'path-in-bundle': _str,
  'payload': YamlSchema.list(YamlSchema.of(YamlScalar.rulePayload)),
});

const _rules = YamlSchema.list(YamlSchema.of(YamlScalar.rule));

const _dns = YamlSchema.map({
  'enable': _bool,
  'listen': YamlSchema.scalar(['0.0.0.0:1053']),
  'listen-routing-mark': _str,
  'ipv6': _bool,
  'ipv6-timeout': _str,
  'prefer-h3': _bool,
  'cache-algorithm': YamlSchema.scalar(['lru', 'arc']),
  'cache-max-size': _str,
  'use-hosts': _bool,
  'use-system-hosts': _bool,
  'respect-rules': _bool,
  'enhanced-mode': YamlSchema.scalar(['fake-ip', 'redir-host', 'normal']),
  'fake-ip-range': YamlSchema.scalar(['198.18.0.1/16']),
  'fake-ip-range6': _str,
  'fake-ip-filter': _strList,
  'fake-ip-filter-mode': YamlSchema.scalar(['blacklist', 'whitelist', 'rule']),
  'fake-ip-ttl': _str,
  'default-nameserver': _nameserver,
  'nameserver': _nameserver,
  'fallback': _nameserver,
  'fallback-lazy-query': _bool,
  'proxy-server-nameserver': _nameserver,
  'direct-nameserver': _nameserver,
  'direct-nameserver-follow-policy': _bool,
  'nameserver-policy': YamlSchema.dict(_nameserver),
  'proxy-server-nameserver-policy': YamlSchema.dict(_nameserver),
  'fallback-filter': YamlSchema.map({
    'geoip': _bool,
    'geoip-code': YamlSchema.scalar(['CN']),
    'geosite': _strList,
    'ipcidr': _strList,
    'domain': _strList,
  }),
});

const _ntp = YamlSchema.map({
  'enable': _bool,
  'write-to-system': _bool,
  'server': YamlSchema.scalar(['time.apple.com', 'ntp.aliyun.com']),
  'port': _str,
  'interval': _str,
  'dialer-proxy': _outbound,
});

const _tun = YamlSchema.map({'enable': _bool, ..._tunFields});

const _tunFields = {
  'stack': YamlSchema.scalar(['mixed', 'system', 'gvisor', 'mips']),
  'device': _str,
  'dns-hijack': YamlSchema.list(YamlSchema.scalar(['any:53', 'tcp://any:53'])),
  'auto-route': _bool,
  'auto-redirect': _bool,
  'auto-detect-interface': _bool,
  'strict-route': _bool,
  'mtu': _str,
  'gso': _bool,
  'gso-max-size': _str,
  'udp-timeout': _str,
  'endpoint-independent-nat': _bool,
  'disable-icmp-forwarding': _bool,
  'iproute2-table-index': _str,
  'iproute2-rule-index': _str,
  'route-address': _strList,
  'route-exclude-address': _strList,
  'route-address-set': YamlSchema.list(YamlSchema.of(YamlScalar.ruleProvider)),
  'route-exclude-address-set': YamlSchema.list(
    YamlSchema.of(YamlScalar.ruleProvider),
  ),
  'include-interface': _strList,
  'exclude-interface': _strList,
  'include-uid': _strList,
  'include-uid-range': _strList,
  'exclude-uid': _strList,
  'exclude-uid-range': _strList,
  'include-android-user': _strList,
  'include-package': _strList,
  'exclude-package': _strList,
  'inet6-address': _strList,
  'inet4-route-address': _strList,
  'inet6-route-address': _strList,
  'inet4-route-exclude-address': _strList,
  'inet6-route-exclude-address': _strList,
  'loopback-address': _strList,
  'auto-redirect-input-mark': _str,
  'auto-redirect-output-mark': _str,
  'auto-redirect-iproute2-fallback-rule-index': _str,
  'exclude-src-port': _strList,
  'exclude-src-port-range': _strList,
  'exclude-dst-port': _strList,
  'exclude-dst-port-range': _strList,
  'include-mac-address': _strList,
  'exclude-mac-address': _strList,
  'icmp-timeout': _str,
  'congestion-controller': YamlSchema.scalar(['cubic', 'reno', 'bbr', 'bbr3']),
  'file-descriptor': _str,
  'recvmsgx': _bool,
  'sendmsgx': _bool,
};

const _sniffPorts = YamlSchema.map({
  'ports': _strList,
  'override-destination': _bool,
});

const _sniffer = YamlSchema.map({
  'enable': _bool,
  'force-dns-mapping': _bool,
  'parse-pure-ip': _bool,
  'override-destination': _bool,
  'sniff': YamlSchema.map({
    'HTTP': _sniffPorts,
    'TLS': _sniffPorts,
    'QUIC': _sniffPorts,
  }),
  'force-domain': _strList,
  'skip-domain': _strList,
  'skip-src-address': _strList,
  'skip-dst-address': _strList,
});

const _serverTls = {
  'certificate': _str,
  'private-key': _str,
  'client-auth-type': YamlSchema.scalar([
    'request',
    'require-any',
    'verify-if-given',
    'require-and-verify',
  ]),
  'client-auth-cert': _str,
  'ech-key': _str,
};

const _listenerUsers = YamlSchema.list(
  YamlSchema.map({'username': _str, 'password': _str}),
);

const _listenerUserDict = YamlSchema.dict(_str);

const _fallbackLimit = YamlSchema.map({
  'after-bytes': _str,
  'bytes-per-sec': _str,
  'burst-bytes-per-sec': _str,
});

const _realityConfig = YamlSchema.map({
  'dest': _str,
  'private-key': _str,
  'short-id': _strList,
  'server-names': _strList,
  'max-time-difference': _str,
  'proxy': _outbound,
  'limit-fallback-upload': _fallbackLimit,
  'limit-fallback-download': _fallbackLimit,
});

const _muxOption = YamlSchema.map({
  'padding': _bool,
  'brutal': YamlSchema.map({'enabled': _bool, 'up': _str, 'down': _str}),
});

const _shadowTlsHandshake = YamlSchema.map({'dest': _str, 'proxy': _outbound});

const _listenerTlsLayers = {
  'shadow-tls': YamlSchema.map({
    'enable': _bool,
    'version': YamlSchema.scalar(['1', '2', '3']),
    'password': _str,
    'users': YamlSchema.list(YamlSchema.map({'name': _str, 'password': _str})),
    'handshake': _shadowTlsHandshake,
    'handshake-for-server-name': YamlSchema.dict(_shadowTlsHandshake),
    'strict-mode': _bool,
    'wildcard-sni': YamlSchema.scalar(['authed', 'all', 'off']),
  }),
  'res-tls': YamlSchema.map({
    'enable': _bool,
    'dest': _str,
    'password': _str,
    'restls-script': _str,
    'min-record-len': _str,
    'rate-limit': _str,
    'proxy': _outbound,
  }),
  'jls-config': YamlSchema.map({
    'enable': _bool,
    'users': _listenerUsers,
    'sni': _str,
    'dest': _str,
    'alpn': _strList,
    'proxy': _outbound,
    'rate-limit': _str,
  }),
};

const _v2rayListener = {
  'ws-path': _str,
  'grpc-service-name': _str,
  ..._serverTls,
  ..._listenerTlsLayers,
  'reality-config': _realityConfig,
  'mux-option': _muxOption,
};

const _mkcpConfig = YamlSchema.map({'enable': _bool, ..._mkcpFields});

const _listener = YamlSchema.map(
  {
    'name': _str,
    'type': YamlSchema.scalar([
      'mixed',
      'socks',
      'http',
      'redir',
      'tproxy',
      'tun',
      'tunnel',
      'shadowsocks',
      'vmess',
      'vless',
      'trojan',
      'tuic',
      'hysteria2',
      'anytls',
      'mieru',
      'snell',
      'hysteria2-realm',
      'shadowquic',
      'sudoku',
      'trusttunnel',
    ]),
    'port': _str,
    'listen': _str,
    'routing-mark': _str,
    'rule': YamlSchema.of(YamlScalar.subRule),
    'proxy': _outbound,
  },
  variants: {
    'mixed': {
      'users': _listenerUsers,
      'udp': _bool,
      ..._serverTls,
      'reality-config': _realityConfig,
    },
    'socks': {
      'users': _listenerUsers,
      'udp': _bool,
      ..._serverTls,
      'reality-config': _realityConfig,
    },
    'http': {
      'users': _listenerUsers,
      ..._serverTls,
      'reality-config': _realityConfig,
    },
    'redir': {},
    'tproxy': {'udp': _bool},
    'tun': {'inet4-address': _strList, ..._tunFields},
    'tunnel': {
      'network': YamlSchema.list(YamlSchema.scalar(['tcp', 'udp'])),
      'target': _str,
    },
    'shadowsocks': {
      'password': _str,
      'cipher': YamlSchema.scalar(_ssCiphers),
      'udp': _bool,
      'mux-option': _muxOption,
      ..._listenerTlsLayers,
      'simple-obfs': YamlSchema.map({
        'enable': _bool,
        'mode': YamlSchema.scalar(['http', 'tls']),
      }),
      'kcp-tun': YamlSchema.map({
        'enable': _bool,
        'mode': YamlSchema.scalar(['normal', 'fast', 'fast2', 'fast3']),
        ..._kcptunFields,
      }),
    },
    'snell': {
      'psk': _str,
      'version': YamlSchema.scalar(['1', '2', '3', '4', '5']),
      'udp': _bool,
      'obfs-opts': YamlSchema.map({
        'mode': YamlSchema.scalar(['http', 'tls']),
        'host': _str,
      }),
      ..._listenerTlsLayers,
    },
    'vmess': {
      'users': YamlSchema.list(
        YamlSchema.map({'username': _str, 'uuid': _str, 'alterId': _str}),
      ),
      ..._v2rayListener,
      'tlsmirror-config': YamlSchema.map({
        'primary-key': _str,
        'dest': _str,
        'proxy': _outbound,
        'explicit-nonce-ciphersuites': _strList,
        'defer-instance-derived-write-time': _tlsMirrorTime,
        'transport-layer-padding': YamlSchema.map({'enabled': _bool}),
        'connection-enrolment': YamlSchema.map({
          'primary-ingress-outbound': _str,
          'primary-egress-outbound': _str,
        }),
        'sequence-watermarking-enabled': _bool,
      }),
      'mekya-config': YamlSchema.map({
        'enable': _bool,
        'url': _str,
        'h2-pool-size': _str,
        'max-write-delay': _str,
        'max-request-size': _str,
        'polling-interval-initial': _str,
        'max-write-size': _str,
        'max-write-duration-ms': _str,
        'max-simultaneous-write-connection': _str,
        'packet-writing-buffer': _str,
        'kcp': _mkcpConfig,
      }),
      'mkcp-config': _mkcpConfig,
    },
    'vless': {
      'users': YamlSchema.list(
        YamlSchema.map({
          'username': _str,
          'uuid': _str,
          'flow': YamlSchema.scalar(['xtls-rprx-vision']),
        }),
      ),
      'decryption': _str,
      'allow-insecure': _bool,
      ..._v2rayListener,
      'xhttp-config': YamlSchema.map({
        'path': _str,
        'host': _str,
        'mode': YamlSchema.scalar([
          'auto',
          'packet-up',
          'stream-up',
          'stream-one',
        ]),
        'no-sse-header': _bool,
        'x-padding-bytes': _str,
        'x-padding-obfs-mode': _bool,
        'x-padding-key': _str,
        'x-padding-header': _str,
        'x-padding-placement': _str,
        'x-padding-method': YamlSchema.scalar(['repeat-x', 'tokenish']),
        'uplink-http-method': _str,
        'session-placement': _xhttpPlacement,
        'session-key': _str,
        'seq-placement': _xhttpPlacement,
        'seq-key': _str,
        'uplink-data-placement': YamlSchema.scalar([
          'body',
          'header',
          'cookie',
        ]),
        'uplink-data-key': _str,
        'uplink-chunk-size': _str,
        'sc-stream-up-server-secs': _str,
        'sc-max-buffered-posts': _str,
        'sc-max-each-post-bytes': _str,
      }),
    },
    'trojan': {
      'users': _listenerUsers,
      'allow-insecure': _bool,
      ..._v2rayListener,
      'ss-option': YamlSchema.map({
        'enabled': _bool,
        'method': YamlSchema.scalar(_aeadCiphers),
        'password': _str,
      }),
    },
    'hysteria2': {
      'users': _listenerUserDict,
      'obfs': YamlSchema.scalar(['salamander', 'gecko']),
      'obfs-password': _str,
      'obfs-min-packet-size': _str,
      'obfs-max-packet-size': _str,
      ..._serverTls,
      'alpn': _strList,
      'up': _str,
      'down': _str,
      'ignore-client-bandwidth': _bool,
      'masquerade': _str,
      'max-idle-time': _str,
      'cwnd': _str,
      'bbr-profile': _bbrProfile,
      'udp-mtu': _str,
      'mux-option': _muxOption,
      'initial-stream-receive-window': _str,
      'max-stream-receive-window': _str,
      'initial-connection-receive-window': _str,
      'max-connection-receive-window': _str,
      'realm-opts': YamlSchema.map({
        'enable': _bool,
        'server-url': _str,
        'token': _str,
        'realm-id': _str,
        'stun-servers': _strList,
        'sni': _str,
        'alpn': _strList,
        'fingerprint': _str,
        'proxy': _outbound,
        ..._pluginTls,
      }),
    },
    'hysteria2-realm': {
      'token': _str,
      'max-realms': _str,
      'max-realms-per-ip': _str,
      'trusted-proxy-header': _str,
      'realm-name-pattern': _str,
      ..._serverTls,
      'alpn': _strList,
    },
    'tuic': {
      'token': _strList,
      'users': _listenerUserDict,
      ..._serverTls,
      'alpn': _strList,
      'congestion-controller': _congestionController,
      'bbr-profile': _bbrProfile,
      'cwnd': _str,
      'max-idle-time': _str,
      'authentication-timeout': _str,
      'max-udp-relay-packet-size': _str,
      'mux-option': _muxOption,
    },
    'shadowquic': {
      'users': _listenerUsers,
      'jls-upstream': YamlSchema.map({
        'addr': _str,
        'sni': _str,
        'proxy': _outbound,
        'rate-limit': _str,
      }),
      'alpn': _strList,
      'quic-versions': YamlSchema.list(YamlSchema.scalar(['v1', 'v2'])),
      'zero-rtt': _bool,
      'congestion-controller': _congestionController,
      'bbr-profile': _bbrProfile,
      'cwnd': _str,
      'up': _str,
      'down': _str,
      'ignore-client-bandwidth': _bool,
      'max-idle-time': _str,
      'max-datagram-frame-size': _str,
      'recv-window-conn': _str,
      'recv-window': _str,
      'disable-mtu-discovery': _bool,
      'mux-option': _muxOption,
    },
    'anytls': {
      'users': _listenerUserDict,
      ..._serverTls,
      ..._listenerTlsLayers,
      'allow-insecure': _bool,
      'padding-scheme': _str,
    },
    'mieru': {
      'transport': YamlSchema.scalar(['TCP', 'UDP']),
      'users': _listenerUserDict,
      'traffic-pattern': _str,
      'user-hint-is-mandatory': _bool,
    },
    'sudoku': {
      'key': _str,
      'aead-method': YamlSchema.scalar([
        'aes-128-gcm',
        'chacha20-poly1305',
        'none',
      ]),
      'padding-min': _str,
      'padding-max': _str,
      'handshake-timeout': _str,
      'table-type': YamlSchema.scalar([
        'prefer_ascii',
        'prefer_entropy',
        'up_ascii_down_entropy',
        'up_entropy_down_ascii',
      ]),
      'custom-table': _str,
      'custom-tables': _strList,
      'enable-pure-downlink': _bool,
      'disable-http-mask': _bool,
      'http-mask-mode': _sudokuHttpMaskMode,
      'path-root': _str,
      'fallback': _str,
      'httpmask': YamlSchema.map({
        'disable': _bool,
        'mode': _sudokuHttpMaskMode,
        'path-root': _str,
      }),
      'mux-option': _muxOption,
    },
    'trusttunnel': {
      'users': _listenerUsers,
      ..._serverTls,
      'network': YamlSchema.list(YamlSchema.scalar(['tcp', 'udp'])),
      'congestion-controller': _congestionController,
      'bbr-profile': _bbrProfile,
      'cwnd': _str,
    },
  },
);

const clashConfigSchema = YamlSchema.map({
  'mixed-port': _str,
  'port': _str,
  'socks-port': _str,
  'redir-port': _str,
  'tproxy-port': _str,
  'ss-config': _str,
  'vmess-config': _str,
  'inbound-tfo': _bool,
  'inbound-mptcp': _bool,
  'allow-lan': _bool,
  'bind-address': YamlSchema.scalar(['*']),
  'lan-allowed-ips': _strList,
  'lan-disallowed-ips': _strList,
  'authentication': _strList,
  'skip-auth-prefixes': _strList,
  'mode': YamlSchema.scalar(['rule', 'global', 'direct']),
  'log-level': YamlSchema.scalar([
    'info',
    'warning',
    'error',
    'debug',
    'silent',
  ]),
  'ipv6': _bool,
  'unified-delay': _bool,
  'tcp-concurrent': _bool,
  'find-process-mode': YamlSchema.scalar(['strict', 'always', 'off']),
  'global-ua': _str,
  'keep-alive-interval': _str,
  'keep-alive-idle': _str,
  'disable-keep-alive': _bool,
  'interface-name': _str,
  'routing-mark': _str,
  'etag-support': _bool,
  'external-controller': YamlSchema.scalar(['127.0.0.1:9090']),
  'external-controller-routing-mark': _str,
  'external-controller-cors': YamlSchema.map({
    'allow-origins': _strList,
    'allow-private-network': _bool,
  }),
  'secret': _str,
  'external-ui': _str,
  'external-ui-name': _str,
  'external-ui-url': _str,
  'external-doh-server': _str,
  'profile': YamlSchema.map({'store-selected': _bool, 'store-fake-ip': _bool}),
  'geodata-mode': _bool,
  'geodata-loader': YamlSchema.scalar(['memconservative', 'standard']),
  'geosite-matcher': YamlSchema.scalar(['succinct', 'mph']),
  'geo-auto-update': _bool,
  'geo-update-interval': _str,
  'geox-url': YamlSchema.map({
    'geoip': _str,
    'geosite': _str,
    'mmdb': _str,
    'asn': _str,
  }),
  'hosts': YamlSchema.dict(_str),
  'tls': YamlSchema.map({..._serverTls, 'custom-certifactes': _strList}),
  'experimental': YamlSchema.map({
    'quic-go-disable-gso': _bool,
    'quic-go-disable-ecn': _bool,
    'dialer-ip4p-convert': _bool,
  }),
  'dns': _dns,
  'tun': _tun,
  'sniffer': _sniffer,
  'ntp': _ntp,
  'listeners': YamlSchema.list(_listener),
  'tunnels': YamlSchema.list(
    YamlSchema.map({
      'network': YamlSchema.list(YamlSchema.scalar(['tcp', 'udp'])),
      'address': _str,
      'target': _str,
      'proxy': _outbound,
    }),
  ),
  'tuic-server': YamlSchema.map({
    'enable': _bool,
    'listen': _str,
    'token': _strList,
    'users': YamlSchema.dict(_str),
    'certificate': _str,
    'private-key': _str,
    'alpn': _strList,
    'congestion-controller': _congestionController,
    'cwnd': _str,
    'max-idle-time': _str,
    'authentication-timeout': _str,
    'max-udp-relay-packet-size': _str,
  }),
  'iptables': YamlSchema.map({
    'enable': _bool,
    'inbound-interface': _str,
    'bypass': _strList,
    'dns-redirect': _bool,
  }),
  'proxies': YamlSchema.list(_proxy),
  'proxy-groups': YamlSchema.list(_proxyGroup),
  'proxy-providers': YamlSchema.dict(_proxyProvider),
  'rule-providers': YamlSchema.dict(_ruleProvider),
  'rules': _rules,
  'sub-rules': YamlSchema.dict(_rules),
});

const _providerFile = YamlSchema.map({
  'proxies': YamlSchema.list(_proxy),
  'payload': YamlSchema.list(YamlSchema.of(YamlScalar.rulePayload)),
});
