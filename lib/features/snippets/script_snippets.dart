import 'package:code_forge/code_forge.dart' show CodeForgeSnippet;

const scriptSnippets = [
  CodeForgeSnippet(
    prefix: 'main',
    description: 'const main = (config) => {}',
    body: r'''const main = (config) => {
  $0
  return config;
};''',
  ),
  CodeForgeSnippet(
    prefix: 'addproxy',
    description: 'config.proxies.push',
    body: r'''(config.proxies ??= []).push({
  name: '${1:proxy}',
  type: '${2:ss}',
  server: '${3:server}',
  port: ${4:8388},
  cipher: '${5:aes-128-gcm}',
  password: '${6:password}',
  udp: true,
});$0''',
  ),
  CodeForgeSnippet(
    prefix: 'addgroup',
    description: "config['proxy-groups'].push",
    body: r'''(config['proxy-groups'] ??= []).push({
  name: '${1:Proxy}',
  type: '${2:select}',
  proxies: [${3:'DIRECT'}],
});$0''',
  ),
  CodeForgeSnippet(
    prefix: 'filtergroup',
    description: "proxies.filter → config['proxy-groups']",
    body: r'''(config['proxy-groups'] ??= []).push({
  name: '${1:HK}',
  type: '${2:url-test}',
  proxies: (config.proxies ?? [])
    .filter((proxy) => /${3:hk|hong kong}/i.test(proxy.name))
    .map((proxy) => proxy.name),
  url: 'https://www.gstatic.com/generate_204',
  interval: 300,
});$0''',
  ),
  CodeForgeSnippet(
    prefix: 'addtogroup',
    description: "config['proxy-groups'].find → proxies.unshift",
    body: r'''config['proxy-groups']
  ?.find((group) => group.name === '${1:Proxy}')
  ?.proxies?.unshift('${2:proxy}');$0''',
  ),
  CodeForgeSnippet(
    prefix: 'removegroup',
    description: "config['proxy-groups'].filter",
    body: r'''config['proxy-groups'] = (config['proxy-groups'] ?? []).filter(
  (group) => group.name !== '${1:group}',
);$0''',
  ),
  CodeForgeSnippet(
    prefix: 'renameproxies',
    description: 'proxies.forEach → name',
    body: r'''const renamed = {};
for (const proxy of config.proxies ?? []) {
  const name = proxy.name.replace(/${1:pattern}/, '${2:}');
  renamed[proxy.name] = name;
  proxy.name = name;
}
for (const group of config['proxy-groups'] ?? []) {
  group.proxies = group.proxies?.map((name) => renamed[name] ?? name);
}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'dropproxies',
    description: "proxies.filter + config['proxy-groups']",
    body: r'''const dropped = /${1:expire|traffic}/i;
config.proxies = (config.proxies ?? []).filter(
  (proxy) => !dropped.test(proxy.name),
);
for (const group of config['proxy-groups'] ?? []) {
  group.proxies = group.proxies?.filter((name) => !dropped.test(name));
}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'dialerproxy',
    description: 'proxies.forEach → dialer-proxy',
    body: r'''for (const proxy of config.proxies ?? []) {
  if (/${1:pattern}/i.test(proxy.name)) {
    proxy['dialer-proxy'] = '${2:proxy}';
  }
}$0''',
  ),
  CodeForgeSnippet(
    prefix: 'addprovider',
    description: "config['proxy-providers']",
    body: r'''(config['proxy-providers'] ??= {})['${1:provider}'] = {
  type: 'http',
  url: '${2:https://example.com/subscription}',
  interval: ${3:3600},
  'health-check': {
    enable: true,
    url: 'https://www.gstatic.com/generate_204',
    interval: 300,
  },
};$0''',
  ),
  CodeForgeSnippet(
    prefix: 'addruleprovider',
    description: "config['rule-providers']",
    body: r'''(config['rule-providers'] ??= {})['${1:name}'] = {
  type: 'http',
  behavior: '${2:domain}',
  format: '${3:yaml}',
  url: '${4:https://example.com/rules.yaml}',
  interval: ${5:86400},
};$0''',
  ),
  CodeForgeSnippet(
    prefix: 'prependrule',
    description: 'config.rules.unshift',
    body:
        r'''(config.rules ??= []).unshift('${1:DOMAIN-SUFFIX,example.com,DIRECT}');$0''',
  ),
  CodeForgeSnippet(
    prefix: 'insertrules',
    description: 'config.rules.splice before MATCH',
    body: r'''const rules = (config.rules ??= []);
const matchIndex = rules.findIndex((rule) => rule.startsWith('MATCH'));
rules.splice(matchIndex < 0 ? rules.length : matchIndex, 0,
  '${1:DOMAIN-SUFFIX,example.com,Proxy}',
);$0''',
  ),
  CodeForgeSnippet(
    prefix: 'removerules',
    description: 'config.rules.filter',
    body: r'''config.rules = (config.rules ?? []).filter(
  (rule) => !rule.includes('${1:example.com}'),
);$0''',
  ),
  CodeForgeSnippet(
    prefix: 'setdns',
    description: 'config.dns',
    body: r'''config.dns = {
  ...config.dns,
  enable: true,
  nameserver: ['${1:https://dns.alidns.com/dns-query}'],
};$0''',
  ),
  CodeForgeSnippet(
    prefix: 'nameserverpolicy',
    description: "config.dns['nameserver-policy']",
    body: r'''config.dns = config.dns ?? {};
(config.dns['nameserver-policy'] ??= {})['${1:geosite:cn}'] = [
  '${2:https://dns.alidns.com/dns-query}',
];$0''',
  ),
  CodeForgeSnippet(
    prefix: 'settun',
    description: 'config.tun',
    body: r'''config.tun = {
  ...config.tun,
  enable: true,
  stack: '${1:mixed}',
  'auto-route': true,
  'auto-detect-interface': true,
};$0''',
  ),
  CodeForgeSnippet(
    prefix: 'setsniffer',
    description: 'config.sniffer',
    body: r'''config.sniffer = {
  enable: true,
  sniff: {
    HTTP: { ports: [80, '8080-8880'], 'override-destination': true },
    TLS: { ports: [443, 8443] },
    QUIC: { ports: [443, 8443] },
  },
};$0''',
  ),
  CodeForgeSnippet(
    prefix: 'sethosts',
    description: 'config.hosts',
    body:
        r'''(config.hosts ??= {})['${1:example.com}'] = '${2:127.0.0.1}';$0''',
  ),
];
