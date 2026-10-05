enum YamlKind { scalar, map, list }

/// Where a scalar's completions come from besides [YamlSchema.values].
enum YamlScalar {
  plain,
  rule,
  rulePayload,
  policy,
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
  dns(_dns),
  ntp(_ntp),
  proxy(_proxy),
  provider(_providerFile);

  final YamlSchema root;

  const EditorSchema(this.root);
}

const _str = YamlSchema.scalar();
const _bool = YamlSchema.scalar(['true', 'false']);
const _strList = YamlSchema.list(_str);
const _policy = YamlSchema.of(YamlScalar.policy);
const _headers = YamlSchema.dict(_strList);

const builtinPolicies = ['DIRECT', 'REJECT', 'REJECT-DROP', 'PASS'];

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
  'PROCESS-NAME': 'curl',
  'PROCESS-NAME-REGEX': '.*telegram.*',
  'PROCESS-PATH': '/usr/bin/curl',
  'PROCESS-PATH-REGEX': '.*bin/curl',
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
  'direct',
  'dns',
];

const _proxyCommon = {
  'name': _str,
  'type': YamlSchema.scalar(_proxyTypes),
  'server': _str,
  'port': _str,
  'udp': _bool,
  'ip-version': _ipVersion,
  'interface-name': _str,
  'routing-mark': _str,
  'tfo': _bool,
  'mptcp': _bool,
  'dialer-proxy': _policy,
};

const _tls = {
  'tls': _bool,
  'sni': _str,
  'servername': _str,
  'alpn': YamlSchema.list(YamlSchema.scalar(['h2', 'http/1.1', 'h3'])),
  'skip-cert-verify': _bool,
  'fingerprint': _str,
  'client-fingerprint': _clientFingerprint,
  'certificate': _str,
  'private-key': _str,
  'ech-opts': YamlSchema.map({'enable': _bool, 'config': _str}),
};

const _reality = {
  'reality-opts': YamlSchema.map({
    'public-key': _str,
    'short-id': _str,
    'support-x25519mlkem768': _bool,
  }),
};

const _transport = {
  'network': YamlSchema.scalar(['tcp', 'ws', 'http', 'h2', 'grpc', 'xhttp']),
  'ws-opts': YamlSchema.map({
    'path': _str,
    'headers': YamlSchema.dict(_str),
    'max-early-data': _str,
    'early-data-header-name': _str,
    'v2ray-http-upgrade': _bool,
    'v2ray-http-upgrade-fast-open': _bool,
  }),
  'http-opts': YamlSchema.map({
    'method': YamlSchema.scalar(['GET', 'POST']),
    'path': _strList,
    'headers': _headers,
  }),
  'h2-opts': YamlSchema.map({'host': _strList, 'path': _str}),
  'grpc-opts': YamlSchema.map({'grpc-service-name': _str}),
  'xhttp-opts': YamlSchema.map({
    'path': _str,
    'host': _str,
    'mode': YamlSchema.scalar(['auto', 'packet-up', 'stream-up', 'stream-one']),
    'headers': YamlSchema.dict(_str),
  }),
  'smux': _smux,
};

const _ssCiphers = [
  'aes-128-gcm',
  'aes-192-gcm',
  'aes-256-gcm',
  'chacha20-ietf-poly1305',
  'xchacha20-ietf-poly1305',
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
  'aes-128-cfb',
  'aes-192-cfb',
  'aes-256-cfb',
  'aes-128-ctr',
  'aes-192-ctr',
  'aes-256-ctr',
  'rc4-md5',
  'chacha20-ietf',
  'xchacha20',
  'none',
];

const _proxyVariants = <String, Map<String, YamlSchema>>{
  'ss': {
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
      'kcptun',
    ]),
    'plugin-opts': YamlSchema.map({
      'mode': YamlSchema.scalar(['http', 'tls', 'websocket']),
      'host': _str,
      'path': _str,
      'tls': _bool,
      'skip-cert-verify': _bool,
      'headers': YamlSchema.dict(_str),
      'mux': _bool,
      'password': _str,
      'version': YamlSchema.scalar(['1', '2', '3']),
      'fingerprint': _str,
      'version-hint': YamlSchema.scalar(['tls12', 'tls13']),
      'restls-script': _str,
    }),
    'smux': _smux,
  },
  'ssr': {
    'cipher': YamlSchema.scalar(_ssCiphers),
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
    'uuid': _str,
    'alterId': _str,
    'cipher': YamlSchema.scalar([
      'auto',
      'none',
      'zero',
      'aes-128-gcm',
      'chacha20-poly1305',
    ]),
    'packet-encoding': YamlSchema.scalar(['packetaddr', 'xudp']),
    'global-padding': _bool,
    'authenticated-length': _bool,
    ..._tls,
    ..._reality,
    ..._transport,
  },
  'vless': {
    'uuid': _str,
    'flow': YamlSchema.scalar(['xtls-rprx-vision']),
    'encryption': _str,
    'packet-encoding': YamlSchema.scalar(['packetaddr', 'xudp']),
    ..._tls,
    ..._reality,
    ..._transport,
  },
  'trojan': {
    'password': _str,
    'ss-opts': YamlSchema.map({
      'enabled': _bool,
      'method': YamlSchema.scalar([
        'aes-128-gcm',
        'aes-256-gcm',
        'chacha20-ietf-poly1305',
      ]),
      'password': _str,
    }),
    ..._tls,
    ..._reality,
    ..._transport,
  },
  'anytls': {
    'password': _str,
    'idle-session-check-interval': _str,
    'idle-session-timeout': _str,
    'min-idle-session': _str,
    ..._tls,
  },
  'hysteria2': {
    'ports': _str,
    'password': _str,
    'up': _str,
    'down': _str,
    'obfs': YamlSchema.scalar(['salamander']),
    'obfs-password': _str,
    'hop-interval': _str,
    ..._tls,
  },
  'hysteria': {
    'ports': _str,
    'auth-str': _str,
    'protocol': YamlSchema.scalar(['udp', 'wechat-video', 'faketcp']),
    'obfs': _str,
    'up': _str,
    'down': _str,
    'recv-window-conn': _str,
    'recv-window': _str,
    'disable-mtu-discovery': _bool,
    'fast-open': _bool,
    'hop-interval': _str,
    ..._tls,
  },
  'tuic': {
    'uuid': _str,
    'password': _str,
    'token': _str,
    'ip': _str,
    'heartbeat-interval': _str,
    'disable-sni': _bool,
    'reduce-rtt': _bool,
    'request-timeout': _str,
    'udp-relay-mode': YamlSchema.scalar(['native', 'quic']),
    'congestion-controller': YamlSchema.scalar(['bbr', 'cubic', 'new_reno']),
    'max-udp-relay-packet-size': _str,
    'fast-open': _bool,
    'max-open-streams': _str,
    ..._tls,
  },
  'wireguard': {
    'ip': _str,
    'ipv6': _str,
    'private-key': _str,
    'public-key': _str,
    'pre-shared-key': _str,
    'reserved': _str,
    'mtu': _str,
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
        'reserved': _str,
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
    }),
  },
  'socks5': {
    'username': _str,
    'password': _str,
    'tls': _bool,
    'fingerprint': _str,
    'skip-cert-verify': _bool,
  },
  'http': {
    'username': _str,
    'password': _str,
    'tls': _bool,
    'sni': _str,
    'fingerprint': _str,
    'skip-cert-verify': _bool,
    'headers': YamlSchema.dict(_str),
  },
  'snell': {
    'psk': _str,
    'version': YamlSchema.scalar(['1', '2', '3']),
    'obfs-opts': YamlSchema.map({
      'mode': YamlSchema.scalar(['http', 'tls']),
      'host': _str,
    }),
  },
  'ssh': {
    'username': _str,
    'password': _str,
    'private-key': _str,
    'private-key-passphrase': _str,
    'host-key': _strList,
    'host-key-algorithms': _strList,
  },
  'mieru': {
    'port-range': _str,
    'transport': YamlSchema.scalar(['TCP', 'UDP']),
    'username': _str,
    'password': _str,
    'multiplexing': YamlSchema.scalar([
      'MULTIPLEXING_OFF',
      'MULTIPLEXING_LOW',
      'MULTIPLEXING_MIDDLE',
      'MULTIPLEXING_HIGH',
    ]),
  },
  'direct': {},
  'dns': {},
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

const _groupFilters = {
  'include-all': _bool,
  'include-all-proxies': _bool,
  'include-all-providers': _bool,
  'filter': _str,
  'exclude-filter': _str,
  'exclude-type': _str,
};

const _proxyGroup = YamlSchema.map(
  {
    'name': _str,
    'type': YamlSchema.scalar([
      'select',
      'url-test',
      'fallback',
      'load-balance',
      'relay',
    ]),
    'proxies': YamlSchema.list(_policy),
    'use': YamlSchema.list(YamlSchema.of(YamlScalar.proxyProvider)),
    'url': YamlSchema.scalar(['https://www.gstatic.com/generate_204']),
    'interval': _str,
    'lazy': _bool,
    'timeout': _str,
    'max-failed-times': _str,
    'expected-status': _str,
    ..._groupFilters,
    'disable-udp': _bool,
    'interface-name': _str,
    'routing-mark': _str,
    'hidden': _bool,
    'icon': _str,
  },
  variants: {
    'url-test': {'tolerance': _str},
    'load-balance': {
      'strategy': YamlSchema.scalar([
        'consistent-hashing',
        'round-robin',
        'sticky-sessions',
      ]),
    },
  },
);

const _providerType = YamlSchema.scalar(['http', 'file', 'inline']);

const _proxyProvider = YamlSchema.map({
  'type': _providerType,
  'url': _str,
  'path': _str,
  'interval': _str,
  'proxy': _policy,
  'size-limit': _str,
  'header': _headers,
  'health-check': _healthCheck,
  'override': YamlSchema.map({
    'tfo': _bool,
    'mptcp': _bool,
    'udp': _bool,
    'udp-over-tcp': _bool,
    'up': _str,
    'down': _str,
    'skip-cert-verify': _bool,
    'dialer-proxy': _policy,
    'interface-name': _str,
    'routing-mark': _str,
    'ip-version': _ipVersion,
    'additional-prefix': _str,
    'additional-suffix': _str,
    'proxy-name': YamlSchema.list(
      YamlSchema.map({'pattern': _str, 'target': _str}),
    ),
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
  'proxy': _policy,
  'size-limit': _str,
  'payload': YamlSchema.list(YamlSchema.of(YamlScalar.rulePayload)),
});

const _rules = YamlSchema.list(YamlSchema.of(YamlScalar.rule));

const _dns = YamlSchema.map({
  'enable': _bool,
  'listen': YamlSchema.scalar(['0.0.0.0:1053']),
  'ipv6': _bool,
  'ipv6-timeout': _str,
  'prefer-h3': _bool,
  'cache-algorithm': YamlSchema.scalar(['lru', 'arc']),
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
});

const _tun = YamlSchema.map({
  'enable': _bool,
  'stack': YamlSchema.scalar(['mixed', 'system', 'gvisor']),
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
});

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

const _listener = YamlSchema.map({
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
  ]),
  'port': _str,
  'listen': _str,
  'udp': _bool,
  'rule': YamlSchema.of(YamlScalar.subRule),
  'proxy': _policy,
  'users': YamlSchema.list(
    YamlSchema.map({'username': _str, 'password': _str, 'uuid': _str}),
  ),
  'network': YamlSchema.list(YamlSchema.scalar(['tcp', 'udp'])),
  'target': _str,
  'cipher': YamlSchema.scalar(_ssCiphers),
  'password': _str,
  'certificate': _str,
  'private-key': _str,
});

const clashConfigSchema = YamlSchema.map({
  'mixed-port': _str,
  'port': _str,
  'socks-port': _str,
  'redir-port': _str,
  'tproxy-port': _str,
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
  'global-client-fingerprint': _clientFingerprint,
  'global-ua': _str,
  'keep-alive-interval': _str,
  'keep-alive-idle': _str,
  'disable-keep-alive': _bool,
  'interface-name': _str,
  'routing-mark': _str,
  'etag-support': _bool,
  'external-controller': YamlSchema.scalar(['127.0.0.1:9090']),
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
  'use-hosts': _bool,
  'use-system-hosts': _bool,
  'tls': YamlSchema.map({
    'certificate': _str,
    'private-key': _str,
    'custom-certifactes': _strList,
  }),
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
