import 'package:code_forge/code_forge.dart' show CodeForgeSnippet;

// Prefixes are what the editor treats as one word: letters, digits and `_`.
const clashSnippets = [
  ..._generalSnippets,
  ..._proxySnippets,
  ..._groupSnippets,
  ..._providerSnippets,
  ..._ruleSnippets,
];

const _generalSnippets = [
  CodeForgeSnippet(
    prefix: 'general',
    description: 'general',
    body: r'''mixed-port: ${1:7890}
allow-lan: ${2:false}
bind-address: '*'
mode: ${3:rule}
log-level: ${4:info}
ipv6: ${5:false}
unified-delay: true
tcp-concurrent: true
find-process-mode: ${6:strict}
global-client-fingerprint: chrome$0''',
  ),
  CodeForgeSnippet(
    prefix: 'externalcontroller',
    description: 'external-controller',
    body: r'''external-controller: ${1:127.0.0.1:9090}
secret: ${2:secret}
external-ui: ${3:ui}
external-ui-url: ${4:https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'profile',
    description: 'profile',
    body: r'''profile:
  store-selected: true
  store-fake-ip: ${1:true}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'geox',
    description: 'geodata · geox-url',
    body: r'''geodata-mode: ${1:true}
geo-auto-update: true
geo-update-interval: ${2:24}
geox-url:
  geoip: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat
  geosite: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
  mmdb: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb
  asn: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb$0''',
  ),
  CodeForgeSnippet(
    prefix: 'hosts',
    description: 'hosts',
    body: r'''hosts:
  ${1:example.com}: ${2:127.0.0.1}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'tun',
    description: 'tun',
    body: r'''tun:
  enable: true
  stack: ${1:mixed}
  dns-hijack:
    - any:53
    - tcp://any:53
  auto-route: true
  auto-redirect: ${2:false}
  auto-detect-interface: true
  strict-route: ${3:false}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'dns',
    description: 'dns · fake-ip',
    body: r'''dns:
  enable: true
  ipv6: ${1:false}
  enhanced-mode: ${2:fake-ip}
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*.lan'
    - '+.local'
  default-nameserver:
    - ${3:223.5.5.5}
  nameserver:
    - ${4:https://dns.alidns.com/dns-query}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'dnssplit',
    description: 'dns · nameserver-policy',
    body: r'''dns:
  enable: true
  enhanced-mode: ${1:fake-ip}
  fake-ip-range: 198.18.0.1/16
  respect-rules: true
  default-nameserver:
    - 223.5.5.5
  proxy-server-nameserver:
    - ${2:https://dns.alidns.com/dns-query}
  nameserver:
    - ${3:https://dns.google/dns-query}
  nameserver-policy:
    'geosite:${4:cn}':
      - ${5:https://dns.alidns.com/dns-query}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'nameserverpolicy',
    description: 'dns · nameserver-policy entry',
    body: r''''${1:geosite:cn}':
  - ${2:https://dns.alidns.com/dns-query}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'sniffer',
    description: 'sniffer',
    body: r'''sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  sniff:
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
    TLS:
      ports: [443, 8443]
    QUIC:
      ports: [443, 8443]
  skip-domain:
    - ${1:Mijia Cloud}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ntp',
    description: 'ntp',
    body: r'''ntp:
  enable: true
  write-to-system: false
  server: ${1:time.apple.com}
  port: 123
  interval: ${2:30}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'listener',
    description: 'listeners · mixed',
    body: r'''- name: ${1:mixed-in}
  type: ${2:mixed}
  port: ${3:7891}
  listen: ${4:0.0.0.0}
  udp: true
  proxy: ${5:DIRECT}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'tunnel',
    description: 'tunnels',
    body: r'''- network: [tcp, udp]
  address: ${1:127.0.0.1:6553}
  target: ${2:8.8.8.8:53}
  proxy: ${3:proxy}$0''',
  ),
];

const _proxySnippets = [
  CodeForgeSnippet(
    prefix: 'ss',
    description: 'proxies · ss',
    body: r'''- name: ${1:ss}
  type: ss
  server: ${2:server}
  port: ${3:8388}
  cipher: ${4:aes-128-gcm}
  password: ${5:password}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ss2022',
    description: 'proxies · ss 2022',
    body: r'''- name: ${1:ss2022}
  type: ss
  server: ${2:server}
  port: ${3:8388}
  cipher: ${4:2022-blake3-aes-128-gcm}
  password: ${5:base64-key}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ssobfs',
    description: 'proxies · ss obfs',
    body: r'''- name: ${1:ss-obfs}
  type: ss
  server: ${2:server}
  port: ${3:8388}
  cipher: ${4:aes-128-gcm}
  password: ${5:password}
  udp: true
  plugin: obfs
  plugin-opts:
    mode: ${6:tls}
    host: ${7:bing.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ssr',
    description: 'proxies · ssr',
    body: r'''- name: ${1:ssr}
  type: ssr
  server: ${2:server}
  port: ${3:443}
  cipher: ${4:chacha20-ietf}
  password: ${5:password}
  obfs: ${6:tls1.2_ticket_auth}
  protocol: ${7:auth_sha1_v4}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'vmess',
    description: 'proxies · vmess ws tls',
    body: r'''- name: ${1:vmess}
  type: vmess
  server: ${2:server}
  port: ${3:443}
  uuid: ${4:uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  servername: ${5:example.com}
  network: ws
  ws-opts:
    path: ${6:/}
    headers:
      Host: ${7:example.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'vmessgrpc',
    description: 'proxies · vmess grpc tls',
    body: r'''- name: ${1:vmess-grpc}
  type: vmess
  server: ${2:server}
  port: ${3:443}
  uuid: ${4:uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  servername: ${5:example.com}
  network: grpc
  grpc-opts:
    grpc-service-name: ${6:grpc}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'vless',
    description: 'proxies · vless reality',
    body: r'''- name: ${1:vless}
  type: vless
  server: ${2:server}
  port: ${3:443}
  uuid: ${4:uuid}
  network: tcp
  udp: true
  tls: true
  flow: xtls-rprx-vision
  servername: ${5:www.microsoft.com}
  reality-opts:
    public-key: ${6:public-key}
    short-id: ${7:short-id}
  client-fingerprint: chrome$0''',
  ),
  CodeForgeSnippet(
    prefix: 'vlessws',
    description: 'proxies · vless ws tls',
    body: r'''- name: ${1:vless-ws}
  type: vless
  server: ${2:server}
  port: ${3:443}
  uuid: ${4:uuid}
  udp: true
  tls: true
  servername: ${5:example.com}
  network: ws
  ws-opts:
    path: ${6:/}
    headers:
      Host: ${7:example.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'trojan',
    description: 'proxies · trojan',
    body: r'''- name: ${1:trojan}
  type: trojan
  server: ${2:server}
  port: ${3:443}
  password: ${4:password}
  sni: ${5:example.com}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'trojanws',
    description: 'proxies · trojan ws',
    body: r'''- name: ${1:trojan-ws}
  type: trojan
  server: ${2:server}
  port: ${3:443}
  password: ${4:password}
  sni: ${5:example.com}
  udp: true
  network: ws
  ws-opts:
    path: ${6:/}
    headers:
      Host: ${7:example.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'anytls',
    description: 'proxies · anytls',
    body: r'''- name: ${1:anytls}
  type: anytls
  server: ${2:server}
  port: ${3:443}
  password: ${4:password}
  sni: ${5:example.com}
  client-fingerprint: chrome
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'hysteria',
    description: 'proxies · hysteria',
    body: r'''- name: ${1:hysteria}
  type: hysteria
  server: ${2:server}
  port: ${3:443}
  auth-str: ${4:password}
  up: ${5:30 Mbps}
  down: ${6:200 Mbps}
  sni: ${7:example.com}
  protocol: udp$0''',
  ),
  CodeForgeSnippet(
    prefix: 'hysteria2',
    description: 'proxies · hysteria2',
    body: r'''- name: ${1:hysteria2}
  type: hysteria2
  server: ${2:server}
  port: ${3:443}
  password: ${4:password}
  sni: ${5:example.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'tuic',
    description: 'proxies · tuic v5',
    body: r'''- name: ${1:tuic}
  type: tuic
  server: ${2:server}
  port: ${3:443}
  uuid: ${4:uuid}
  password: ${5:password}
  sni: ${6:example.com}
  alpn: [h3]
  udp-relay-mode: native
  congestion-controller: bbr$0''',
  ),
  CodeForgeSnippet(
    prefix: 'wireguard',
    description: 'proxies · wireguard',
    body: r'''- name: ${1:wireguard}
  type: wireguard
  server: ${2:server}
  port: ${3:51820}
  ip: ${4:172.16.0.2}
  private-key: ${5:private-key}
  public-key: ${6:public-key}
  allowed-ips: ['0.0.0.0/0']
  mtu: 1280
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'snell',
    description: 'proxies · snell',
    body: r'''- name: ${1:snell}
  type: snell
  server: ${2:server}
  port: ${3:44046}
  psk: ${4:psk}
  version: ${5:3}
  obfs-opts:
    mode: ${6:tls}
    host: ${7:bing.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ssh',
    description: 'proxies · ssh',
    body: r'''- name: ${1:ssh}
  type: ssh
  server: ${2:server}
  port: ${3:22}
  username: ${4:root}
  password: ${5:password}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'http',
    description: 'proxies · http',
    body: r'''- name: ${1:http}
  type: http
  server: ${2:127.0.0.1}
  port: ${3:8080}
  username: ${4:username}
  password: ${5:password}
  tls: ${6:false}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'socks5',
    description: 'proxies · socks5',
    body: r'''- name: ${1:socks5}
  type: socks5
  server: ${2:127.0.0.1}
  port: ${3:1080}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'direct',
    description: 'proxies · direct with interface',
    body: r'''- name: ${1:direct-out}
  type: direct
  interface-name: ${2:en0}
  udp: true$0''',
  ),
  CodeForgeSnippet(
    prefix: 'dialerproxy',
    description: 'proxies · dialer-proxy chain',
    body: r'dialer-proxy: ${1:proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'smux',
    description: 'proxies · smux',
    body: r'''smux:
  enabled: true
  protocol: ${1:h2mux}
  max-connections: 4
  min-streams: 4
  padding: true$0''',
  ),
];

const _groupSnippets = [
  CodeForgeSnippet(
    prefix: 'select',
    description: 'proxy-groups · select',
    body: r'''- name: ${1:Proxy}
  type: select
  proxies:
    - ${2:DIRECT}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'urltest',
    description: 'proxy-groups · url-test',
    body: r'''- name: ${1:Auto}
  type: url-test
  proxies:
    - ${2:proxy}
  url: https://www.gstatic.com/generate_204
  interval: ${3:300}
  tolerance: ${4:50}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'fallback',
    description: 'proxy-groups · fallback',
    body: r'''- name: ${1:Fallback}
  type: fallback
  proxies:
    - ${2:proxy}
  url: https://www.gstatic.com/generate_204
  interval: ${3:300}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'loadbalance',
    description: 'proxy-groups · load-balance',
    body: r'''- name: ${1:Balance}
  type: load-balance
  strategy: ${2:consistent-hashing}
  proxies:
    - ${3:proxy}
  url: https://www.gstatic.com/generate_204
  interval: ${4:300}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'relay',
    description: 'proxy-groups · relay',
    body: r'''- name: ${1:Relay}
  type: relay
  proxies:
    - ${2:first}
    - ${3:second}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'filtergroup',
    description: 'proxy-groups · include-all + filter',
    body: r'''- name: ${1:HK}
  type: ${2:url-test}
  include-all: true
  filter: ${3:(?i)hk|hong kong}
  url: https://www.gstatic.com/generate_204
  interval: ${4:300}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'providergroup',
    description: 'proxy-groups · use providers',
    body: r'''- name: ${1:Provider}
  type: ${2:select}
  use:
    - ${3:provider}$0''',
  ),
];

const _providerSnippets = [
  CodeForgeSnippet(
    prefix: 'proxyprovider',
    description: 'proxy-providers · http',
    body: r'''${1:provider}:
  type: http
  url: ${2:https://example.com/subscription}
  path: ./proxy_providers/${3:provider}.yaml
  interval: ${4:3600}
  health-check:
    enable: true
    url: https://www.gstatic.com/generate_204
    interval: 300$0''',
  ),
  CodeForgeSnippet(
    prefix: 'fileprovider',
    description: 'proxy-providers · file',
    body: r'''${1:local}:
  type: file
  path: ${2:./proxies.yaml}
  health-check:
    enable: true
    url: https://www.gstatic.com/generate_204
    interval: 300$0''',
  ),
  CodeForgeSnippet(
    prefix: 'override',
    description: 'proxy-providers · override',
    body: r'''override:
  additional-prefix: '${1:[provider] }'
  udp: true
  skip-cert-verify: ${2:false}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'ruleprovider',
    description: 'rule-providers · http',
    body: r'''${1:name}:
  type: http
  behavior: ${2:domain}
  format: ${3:yaml}
  url: ${4:https://example.com/rules.yaml}
  interval: ${5:86400}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'mrsprovider',
    description: 'rule-providers · mrs',
    body: r'''${1:geosite-cn}:
  type: http
  behavior: ${2:domain}
  format: mrs
  url: ${3:https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/geo/geosite/cn.mrs}
  interval: ${4:86400}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'inlineprovider',
    description: 'rule-providers · inline',
    body: r'''${1:name}:
  type: inline
  behavior: ${2:classical}
  payload:
    - ${3:DOMAIN-SUFFIX,example.com}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'subrules',
    description: 'sub-rules',
    body: r'''sub-rules:
  ${1:rule1}:
    - ${2:DOMAIN-SUFFIX,example.com,DIRECT}
    - MATCH,${3:Proxy}$0''',
  ),
];

const _ruleSnippets = [
  CodeForgeSnippet(
    prefix: 'domain',
    description: 'rules · DOMAIN',
    body: r'- DOMAIN,${1:www.example.com},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'domainsuffix',
    description: 'rules · DOMAIN-SUFFIX',
    body: r'- DOMAIN-SUFFIX,${1:example.com},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'domainkeyword',
    description: 'rules · DOMAIN-KEYWORD',
    body: r'- DOMAIN-KEYWORD,${1:example},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'domainregex',
    description: 'rules · DOMAIN-REGEX',
    body: r'- DOMAIN-REGEX,${1:^abc.*\.com},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'geosite',
    description: 'rules · GEOSITE',
    body: r'- GEOSITE,${1:cn},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'geoip',
    description: 'rules · GEOIP',
    body: r'- GEOIP,${1:CN},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'ipcidr',
    description: 'rules · IP-CIDR',
    body: r'- IP-CIDR,${1:192.168.0.0/16},${2:DIRECT},no-resolve$0',
  ),
  CodeForgeSnippet(
    prefix: 'ipcidr6',
    description: 'rules · IP-CIDR6',
    body: r'- IP-CIDR6,${1:2620:0:2d0:200::7/32},${2:DIRECT},no-resolve$0',
  ),
  CodeForgeSnippet(
    prefix: 'ipasn',
    description: 'rules · IP-ASN',
    body: r'- IP-ASN,${1:13335},${2:Proxy},no-resolve$0',
  ),
  CodeForgeSnippet(
    prefix: 'srcipcidr',
    description: 'rules · SRC-IP-CIDR',
    body: r'- SRC-IP-CIDR,${1:192.168.1.201/32},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'dstport',
    description: 'rules · DST-PORT',
    body: r'- DST-PORT,${1:80},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'srcport',
    description: 'rules · SRC-PORT',
    body: r'- SRC-PORT,${1:7777},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'inport',
    description: 'rules · IN-PORT',
    body: r'- IN-PORT,${1:7890},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'processname',
    description: 'rules · PROCESS-NAME',
    body: r'- PROCESS-NAME,${1:curl},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'processpath',
    description: 'rules · PROCESS-PATH',
    body: r'- PROCESS-PATH,${1:/usr/bin/curl},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'network',
    description: 'rules · NETWORK',
    body: r'- NETWORK,${1:udp},${2:DIRECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'ruleset',
    description: 'rules · RULE-SET',
    body: r'- RULE-SET,${1:name},${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'ruleand',
    description: 'rules · AND',
    body:
        r'- AND,((${1:DOMAIN-SUFFIX,example.com}),(${2:NETWORK,udp})),${3:REJECT}$0',
  ),
  CodeForgeSnippet(
    prefix: 'ruleor',
    description: 'rules · OR',
    body:
        r'- OR,((${1:DOMAIN-SUFFIX,example.com}),(${2:DOMAIN-SUFFIX,example.org})),${3:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'rulenot',
    description: 'rules · NOT',
    body: r'- NOT,((${1:GEOIP,CN})),${2:Proxy}$0',
  ),
  CodeForgeSnippet(
    prefix: 'subrule',
    description: 'rules · SUB-RULE',
    body: r'- SUB-RULE,(${1:NETWORK,tcp}),${2:rule1}$0',
  ),
  CodeForgeSnippet(
    prefix: 'reject',
    description: 'rules · REJECT',
    body: r'- ${1:DOMAIN-SUFFIX},${2:ads.example.com},REJECT$0',
  ),
  CodeForgeSnippet(
    prefix: 'match',
    description: 'rules · MATCH',
    body: r'- MATCH,${1:Proxy}$0',
  ),
];
