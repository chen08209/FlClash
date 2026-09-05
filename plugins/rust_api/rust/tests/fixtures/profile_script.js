/**
 * A profile overwrite script written for this test suite. It does the work a
 * real overwrite does — drop subscription notices, canonicalise node names,
 * group by region, rate and dedicated line, build policy groups and rules,
 * merge DNS — so the engine is measured against how such scripts are written
 * rather than against a checklist of language features.
 */

const REGIONS = [
  { name: '香港', flag: '🇭🇰', pattern: /🇭🇰|香港|(?<![A-Za-z])HKG?(?![A-Za-z])|hong\s*kong/iu },
  { name: '日本', flag: '🇯🇵', pattern: /🇯🇵|日本|东京|大阪|(?<![A-Za-z])JPN?(?![A-Za-z])|japan/iu },
  {
    name: '美国',
    flag: '🇺🇸',
    pattern: /🇺🇸|美国|洛杉矶|纽约|(?<![A-Za-z])USA?(?![A-Za-z])|united\s*states/iu,
  },
  { name: '新加坡', flag: '🇸🇬', pattern: /🇸🇬|新加坡|狮城|(?<![A-Za-z])SGP?(?![A-Za-z])|singapore/iu },
  { name: '台湾', flag: '🇹🇼', pattern: /🇹🇼|台湾|台北|(?<![A-Za-z])TWN?(?![A-Za-z])|taiwan/iu },
  { name: '韩国', flag: '🇰🇷', pattern: /🇰🇷|韩国|首尔|(?<![A-Za-z])(?:KR|KOR)(?![A-Za-z])|korea/iu },
  { name: '英国', flag: '🇬🇧', pattern: /🇬🇧|英国|伦敦|(?<![A-Za-z])(?:UK|GBR)(?![A-Za-z])|britain/iu },
];

const OTHER = { name: '其他', flag: '🏳️' };

const SERVICES = [
  { name: 'AI', rules: ['DOMAIN-SUFFIX,ai.example.com', 'DOMAIN-KEYWORD,inference'] },
  { name: 'Media', rules: ['DOMAIN-SUFFIX,media.example.com', 'DOMAIN-SUFFIX,video.example.net'] },
  {
    name: 'Social',
    rules: ['DOMAIN-SUFFIX,social.example.com', 'IP-CIDR,198.51.100.0/24,no-resolve'],
  },
  { name: 'Download', rules: ['DOMAIN-SUFFIX,dl.example.com', 'PROCESS-NAME,downloader'] },
];

const PREFIX_RULES = ['RULE-SET,private,直连', 'RULE-SET,cn,直连'];

// A subscription sells its notices as nodes: expiry, quota, the operator's
// homepage. They resolve to nothing, so they never belong in a policy group.
const NOTICE = /官网|流量|到期|剩余|订阅|群组|https?:\/\//iu;

// The multiplier a provider bills the node at, written either as a suffix
// ("2x", "×3") or spelled out ("倍率:0.5").
const RATE = /(?:(?<suffix>\d+(?:\.\d+)?)\s*[xX×✕])|(?:倍率[:：]\s*(?<spelled>\d+(?:\.\d+)?))/u;

const PREMIUM = ['IEPL', 'IPLC', '专线'];

const SELECT = '手动选择';
const AUTO = '自动选择';
const DIRECT = '直连';
const LINE = '专线';
const TEST_URL = 'http://example.com/generate_204';

const DNS_DEFAULTS = {
  enable: true,
  ipv6: false,
  'enhanced-mode': 'fake-ip',
  'fake-ip-range': '198.18.0.1/16',
};

const DIRECT_DOMAINS = ['+.example.cn', '+.internal'];
const DIRECT_DNS = 'system://';

function regionOf(name) {
  return REGIONS.find((region) => region.pattern.test(name)) ?? OTHER;
}

function rateOf(name) {
  const found = name.match(RATE);
  const value = found?.groups?.suffix ?? found?.groups?.spelled;
  return value === undefined ? 1 : Number(value);
}

function policyGroup({ name, proxies, type = 'select', ...extra }) {
  return { name, type, proxies, ...extra };
}

function urlTest(name, proxies, extra = {}) {
  return policyGroup({ name, proxies, type: 'url-test', url: TEST_URL, interval: 300, ...extra });
}

function main(config) {
  if (!Array.isArray(config.proxies) || config.proxies.length === 0) {
    throw new Error('profile carries no proxies');
  }
  if (!config.proxies.every((proxy) => typeof proxy?.name === 'string')) {
    throw new Error('every proxy needs a name');
  }

  const counters = new Map();
  const renamed = new Map();
  const rates = new Map();
  const byRegion = new Map();
  const proxies = [];
  const dialable = [];
  const premium = [];

  for (const proxy of config.proxies) {
    if (NOTICE.test(proxy.name)) continue;

    const region = regionOf(proxy.name);
    const rate = rateOf(proxy.name);
    const index = (counters.get(region.name) ?? 0) + 1;
    counters.set(region.name, index);

    const ordinal = String(index).padStart(2, '0');
    const suffix = rate === 1 ? '' : ` | ${rate}x`;
    const name = `${region.flag} ${region.name} ${ordinal}${suffix}`;

    renamed.set(proxy.name, name);
    rates.set(name, rate);
    if (!byRegion.has(region.name)) byRegion.set(region.name, []);
    byRegion.get(region.name).push(name);
    if ((proxy.type ?? '').toLowerCase() !== 'direct') dialable.push(name);
    if (PREMIUM.some((tag) => proxy.name.toUpperCase().includes(tag))) premium.push(name);
    proxies.push({ ...proxy, name });
  }

  const names = proxies.map((proxy) => proxy.name);

  // A chain whose exit was one of the dropped notices would fail to load.
  for (const proxy of proxies) {
    if (proxy['dialer-proxy'] === undefined) continue;
    const next = renamed.get(proxy['dialer-proxy']);
    if (next === undefined) {
      delete proxy['dialer-proxy'];
    } else {
      proxy['dialer-proxy'] = next;
    }
  }

  const regionGroups = [...REGIONS, OTHER]
    .filter((region) => byRegion.has(region.name))
    .map((region) =>
      urlTest(`${region.flag} ${region.name}`, byRegion.get(region.name), { tolerance: 50 }),
    );
  const regionNames = regionGroups.map((group) => group.name);

  const providers = Object.keys(config['proxy-providers'] ?? {});
  const use = providers.length > 0 ? { use: providers } : {};

  const entryGroups = [
    policyGroup({ name: SELECT, proxies: [AUTO, ...regionNames, DIRECT, ...names] }),
    urlTest(AUTO, dialable, use),
  ];

  const serviceGroups = SERVICES.map((service) =>
    policyGroup({ name: service.name, proxies: [SELECT, AUTO, ...regionNames, DIRECT] }),
  );

  const lineGroups = premium.length > 0 ? [policyGroup({ name: LINE, proxies: premium })] : [];

  const graded = names.some((name) => rates.get(name) !== 1);
  const rateGroups = !graded
    ? []
    : Object.entries({ 低倍率: (rate) => rate < 1, 高倍率: (rate) => rate > 1 })
        .map(([label, matches]) => [label, names.filter((name) => matches(rates.get(name)))])
        .filter(([, members]) => members.length > 0)
        .map(([label, members]) => policyGroup({ name: label, proxies: members }));

  const seenRules = new Set();
  const rules = [
    ...PREFIX_RULES,
    ...SERVICES.flatMap((service) => service.rules.map((rule) => `${rule},${service.name}`)),
    `GEOIP,CN,${DIRECT}`,
    `MATCH,${SELECT}`,
  ].filter((rule) => {
    const key = rule.split(',').slice(0, 2).join(',');
    if (seenRules.has(key)) return false;
    seenRules.add(key);
    return true;
  });

  const dns = Object.assign({}, DNS_DEFAULTS, config.dns ?? {}, {
    'nameserver-policy': {
      ...(config.dns?.['nameserver-policy'] ?? {}),
      ...Object.fromEntries(DIRECT_DOMAINS.map((domain) => [domain, DIRECT_DNS])),
    },
  });

  console.log(`kept ${names.length} nodes across ${regionNames.join(', ')}`);

  return {
    ...config,
    proxies,
    'proxy-groups': [...entryGroups, ...serviceGroups, ...lineGroups, ...regionGroups, ...rateGroups],
    rules,
    dns,
  };
}
