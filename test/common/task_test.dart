import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

int _double(int value) => value * 2;

void main() {
  test('encoding helpers round-trip structured data', () async {
    final encoded = await encodeJSONTask({
      'name': 'FlClash',
      'values': [1, true, null],
    });
    final decoded = await decodeJSONTask<Map<String, dynamic>>(encoded);

    expect(decoded['name'], 'FlClash');
    expect(decoded['values'], [1, true, null]);
    expect(await encodeYamlTask({'enabled': true}), contains('enabled: true'));
    expect(await encodeMD5Task('abc'), '900150983cd24fb0d6963f7d28e17f72');
  });

  test('toGroupsTask converts, selects, and sorts core proxy data', () async {
    final proxies = <String, dynamic>{
      'Selector': {
        'name': 'Selector',
        'type': 'Selector',
        'now': 'Beta',
        'all': ['Zulu', 'Beta', 'missing'],
      },
      'Direct': {'name': 'Direct', 'type': 'Direct'},
      'Zulu': {'name': 'Zulu', 'type': 'Direct'},
      'Beta': {'name': 'Beta', 'type': 'Direct'},
    };
    final groups = await toGroupsTask(
      ComputeGroupsState(
        proxiesData: ProxiesData(
          all: const ['Selector', 'Direct'],
          proxies: proxies,
        ),
        sortType: ProxiesSortType.name,
        delayMap: const {},
        selectedMap: const {'Selector': 'Beta'},
        defaultTestUrl: 'https://example.com/generate_204',
      ),
    );

    expect(groups, hasLength(1));
    expect(groups.single.name, 'Selector');
    expect(groups.single.all.map((proxy) => proxy.name), ['Beta', 'Zulu']);
  });

  test('toGroupsTask returns empty data without proxies', () async {
    final groups = await toGroupsTask(
      const ComputeGroupsState(
        proxiesData: ProxiesData(proxies: {}, all: []),
        sortType: ProxiesSortType.none,
        delayMap: {},
        selectedMap: {},
        defaultTestUrl: '',
      ),
    );

    expect(groups, isEmpty);
  });

  test(
    'makeRealProfileTask normalizes runtime config and added rules',
    () async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        await encodeJSONTask({
          'dns': {
            'enable': true,
            'nameserver': ['1.1.1.1'],
          },
          'sniffer': {
            'sniff': {
              'HTTP': {
                'ports': [80, '443'],
              },
            },
          },
          'proxy-providers': {
            'remote': {'type': 'http', 'url': 'https://example.com/proxy.yaml'},
            'file': {'type': 'file', 'path': './local.yaml'},
          },
          'rule-providers': {
            'remote': {'type': 'http', 'url': 'https://example.com/rule.yaml'},
          },
          'rules': ['DOMAIN,existing.example,DIRECT', 'MATCH,Original'],
        }),
      );
      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 7,
          rawConfig: rawConfig,
          realPatchConfig: const PatchClashConfig(
            mixedPort: 7893,
            port: 7890,
            socksPort: 7891,
            redirPort: 7892,
            tproxyPort: 7894,
            allowLan: true,
            ipv6: true,
            hosts: {'router.local': '192.168.1.1,192.168.1.2'},
          ),
          overrideDns: false,
          appendSystemDns: true,
          proxyGroups: const [],
          replaceProxyGroups: false,
          chainProxyGroupName: 'Chain Proxy',
          chainProxyEnabled: false,
          savedProxies: const [],
          rules: const [],
          addedRules: const [
            Rule(
              ruleAction: RuleAction.DOMAIN_SUFFIX,
              content: 'added.example',
              ruleTarget: 'MATCH',
            ),
          ],
          defaultUA: 'FlClash-Test',
        ),
      );
      final config = loadYaml(result.a) as YamlMap;

      expect(result.b, hasLength(32));
      expect(config['mixed-port'], 7893);
      expect(config['allow-lan'], true);
      expect(config['global-ua'], 'FlClash-Test');
      expect(config['profile']['store-selected'], false);
      expect(
        config['dns']['nameserver'],
        containsAll(['1.1.1.1', 'system://']),
      );
      expect(config['hosts']['router.local'], ['192.168.1.1', '192.168.1.2']);
      expect(config['sniffer']['sniff']['HTTP']['ports'], ['80', '443']);
      expect(
        config['proxy-providers']['remote']['path'],
        startsWith('/profiles/providers/7/proxies/'),
      );
      expect(
        config['rule-providers']['remote']['path'],
        startsWith('/profiles/providers/7/rules/'),
      );
      expect(config['rules'], [
        'DOMAIN-SUFFIX,added.example,Original',
        'DOMAIN,existing.example,DIRECT',
        'MATCH,Original',
      ]);
    },
  );

  test('makeRealProfileTask replaces DNS and explicit custom data', () async {
    final result = await makeRealProfileTask(
      const MakeRealProfileState(
        profilesPath: '/profiles',
        profileId: 9,
        rawConfig: {},
        realPatchConfig: PatchClashConfig(),
        overrideDns: true,
        appendSystemDns: false,
        proxyGroups: [
          ProxyGroup(
            id: 1,
            name: 'Select',
            type: GroupType.Selector,
            proxies: ['DIRECT'],
          ),
        ],
        replaceProxyGroups: true,
        chainProxyGroupName: 'Chain Proxy',
        chainProxyEnabled: false,
        savedProxies: [],
        rules: [
          Rule(
            ruleAction: RuleAction.DOMAIN,
            content: 'custom.example',
            ruleTarget: 'DIRECT',
          ),
        ],
        addedRules: [],
        defaultUA: 'Fallback-UA',
      ),
    );
    final config = loadYaml(result.a) as YamlMap;

    expect(config['dns']['enable'], true);
    expect(config['dns']['nameserver'], contains('system://'));
    expect(config['proxy-groups'], hasLength(1));
    expect(config['rules'], ['DOMAIN,custom.example,DIRECT']);
  });

  test('log and list tasks produce stable mapped output', () async {
    final logs = [
      const Log(
        logLevel: LogLevel.info,
        payload: 'first',
        dateTime: '2026-07-26 10:00:00',
      ),
      const Log(
        logLevel: LogLevel.error,
        payload: 'second',
        dateTime: '2026-07-26 10:00:01',
      ),
    ];

    final encoded = await encodeLogsTask(logs);

    expect(encoded, contains('first'));
    expect(encoded, contains('\n'));
    expect(await mapListTask([1, 2, 3], _double), [2, 4, 6]);
  });
  chainProxyTests();
}

void chainProxyTests() {
  group('applyProxyGroups', () {
    test('converts a relay group to an isolated dialer-proxy chain', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'entry', 'type': 'ss', 'server': 'entry.example'},
          {'name': 'exit', 'type': 'vmess', 'server': 'exit.example'},
        ],
      };
      const chain = ProxyGroup(
        id: 42,
        name: 'Chain',
        type: GroupType.Relay,
        proxies: ['entry', 'exit'],
      );

      applyProxyGroups(rawConfig, [chain]);

      final proxies = rawConfig['proxies'] as List<dynamic>;
      expect(proxies, hasLength(4));
      expect(proxies[0]['name'], 'entry');
      expect(proxies[1]['name'], 'exit');
      expect(proxies[2], {
        'name': 'Chain · 1. entry',
        'type': 'ss',
        'server': 'entry.example',
      });
      expect(proxies[3], {
        'name': 'Chain · entry → exit',
        'type': 'vmess',
        'server': 'exit.example',
        'dialer-proxy': 'Chain · 1. entry',
      });
      expect(rawConfig['proxy-groups'], [
        {
          'name': '__FLCLASH_CHAIN_PROXY__',
          'type': 'select',
          'proxies': ['DIRECT', 'Chain · entry → exit'],
        },
      ]);
    });

    test('rejects chains with fewer than two proxies', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'only', 'type': 'ss'},
        ],
      };
      const chain = ProxyGroup(
        id: 1,
        name: 'Invalid',
        type: GroupType.Relay,
        proxies: ['only'],
      );

      expect(() => applyProxyGroups(rawConfig, [chain]), throwsArgumentError);
    });

    test('rejects chain entries missing from the profile', () {
      final rawConfig = <dynamic, dynamic>{'proxies': <dynamic>[]};
      const chain = ProxyGroup(
        id: 1,
        name: 'Invalid',
        type: GroupType.Relay,
        proxies: ['missing', 'also-missing'],
      );

      expect(() => applyProxyGroups(rawConfig, [chain]), throwsArgumentError);
    });

    test('builds a chain from manually configured SOCKS5 and HTTP nodes', () {
      final rawConfig = <dynamic, dynamic>{'proxies': <dynamic>[]};
      const chain = ProxyGroup(
        id: 7,
        name: 'Manual chain',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(
            type: 'socks5',
            server: 'entry.example',
            port: 1080,
            username: 'entry-user',
            password: 'entry-pass',
          ),
          ChainProxyNode(type: 'http', server: 'exit.example', port: 8080),
        ],
      );

      applyProxyGroups(rawConfig, [chain]);

      expect(rawConfig['proxies'], [
        {
          'name': 'Manual chain · 1. SOCKS5 entry.example:1080',
          'type': 'socks5',
          'server': 'entry.example',
          'port': 1080,
          'username': 'entry-user',
          'password': 'entry-pass',
        },
        {
          'name':
              'Manual chain · SOCKS5 entry.example:1080 → HTTP exit.example:8080',
          'type': 'http',
          'server': 'exit.example',
          'port': 8080,
          'dialer-proxy': 'Manual chain · 1. SOCKS5 entry.example:1080',
        },
      ]);
    });

    test(
      'keeps subscription groups when adding a chain outside custom mode',
      () {
        final rawConfig = <dynamic, dynamic>{
          'proxies': [
            {'name': 'entry', 'type': 'ss'},
            {'name': 'exit', 'type': 'vmess'},
          ],
          'proxy-groups': [
            {
              'name': 'Subscription group',
              'type': 'select',
              'proxies': ['entry'],
            },
          ],
        };
        const chain = ProxyGroup(
          id: 8,
          name: 'Chain',
          type: GroupType.Relay,
          proxies: ['entry', 'exit'],
        );

        applyProxyGroups(rawConfig, [chain], replaceProxyGroups: false);

        expect(rawConfig['proxy-groups'], [
          {
            'name': 'Subscription group',
            'type': 'select',
            'proxies': ['entry'],
          },
          {
            'name': '__FLCLASH_CHAIN_PROXY__',
            'type': 'select',
            'proxies': ['DIRECT', 'Chain · entry → exit'],
          },
        ]);
      },
    );

    test('collects multiple saved routes into one fixed group', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'A', 'type': 'ss'},
          {'name': 'B', 'type': 'vmess'},
          {'name': 'C', 'type': 'trojan'},
        ],
      };
      const chains = [
        ProxyGroup(
          id: 1,
          name: 'Route 1',
          type: GroupType.Relay,
          proxies: ['A', 'B'],
        ),
        ProxyGroup(
          id: 2,
          name: 'Route 2',
          type: GroupType.Relay,
          proxies: ['A', 'C'],
        ),
      ];

      applyProxyGroups(rawConfig, chains, chainProxyGroupName: '链式代理');

      expect(rawConfig['proxy-groups'], [
        {
          'name': '链式代理',
          'type': 'select',
          'proxies': ['DIRECT', 'Route 1 · A → B', 'Route 2 · A → C'],
        },
      ]);
    });

    test('creates the fixed chain group before any route is saved', () {
      final rawConfig = <dynamic, dynamic>{};

      final rules = applyProxyGroups(
        rawConfig,
        const [],
        chainProxyGroupName: '链式代理',
      );

      expect(rawConfig['proxy-groups'], [
        {
          'name': '链式代理',
          'type': 'select',
          'proxies': ['DIRECT'],
        },
      ]);
      expect(rules, ['MATCH,链式代理']);
    });

    test('does not expose saved chains while chain proxy support is off', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'entry', 'type': 'ss'},
          {'name': 'exit', 'type': 'vmess'},
        ],
        'proxy-groups': [
          {
            'name': 'Subscription group',
            'type': 'select',
            'proxies': ['entry'],
          },
        ],
      };
      const chain = ProxyGroup(
        id: 3,
        name: 'Saved route',
        type: GroupType.Relay,
        proxies: ['entry', 'exit'],
      );

      applyProxyGroups(
        rawConfig,
        [chain],
        replaceProxyGroups: false,
        chainProxyEnabled: false,
      );

      expect(rawConfig['proxies'], hasLength(2));
      expect(rawConfig['proxy-groups'], [
        {
          'name': 'Subscription group',
          'type': 'select',
          'proxies': ['entry'],
        },
      ]);
    });

    test('routes the final MATCH through the fixed chain group', () {
      final rawConfig = <dynamic, dynamic>{
        'proxy-groups': [
          {
            'name': 'Main',
            'type': 'select',
            'proxies': ['Node A'],
          },
        ],
      };

      final rules = applyProxyGroups(
        rawConfig,
        const [],
        rules: const ['DOMAIN,example.com,DIRECT', 'MATCH,Main'],
        replaceProxyGroups: false,
      );

      expect(rawConfig['proxy-groups'], [
        {
          'name': 'Main',
          'type': 'select',
          'proxies': ['Node A'],
        },
        {
          'name': '__FLCLASH_CHAIN_PROXY__',
          'type': 'select',
          'proxies': ['Main'],
        },
      ]);
      expect(rules, [
        'DOMAIN,example.com,DIRECT',
        'MATCH,__FLCLASH_CHAIN_PROXY__',
      ]);
    });

    test('does not duplicate a chain option already in the MATCH selector', () {
      final rawConfig = <dynamic, dynamic>{};
      const mainGroup = ProxyGroup(
        id: 12,
        name: 'Main',
        type: GroupType.Selector,
        proxies: ['Node A', 'Chain Proxy'],
      );

      applyProxyGroups(
        rawConfig,
        const [mainGroup],
        rules: const ['MATCH,Main'],
      );

      final groups = rawConfig['proxy-groups'] as List<dynamic>;
      expect((groups.first as ProxyGroup).proxies, ['Node A', 'Chain Proxy']);
    });

    test('reuses a saved HTTPS proxy in a chain', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'Exit', 'type': 'vmess'},
        ],
      };
      const savedProxy = SavedProxy(
        id: 99,
        name: 'Office gateway',
        type: 'https',
        server: 'gateway.example',
        port: 443,
        username: 'user',
        password: 'pass',
      );
      const chain = ProxyGroup(
        id: 9,
        name: 'Office route',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(type: 'saved', savedProxyId: 99),
          ChainProxyNode(type: 'existing', proxy: 'Exit'),
        ],
      );

      applyProxyGroups(rawConfig, [chain], savedProxies: [savedProxy]);

      final proxies = rawConfig['proxies'] as List<dynamic>;
      expect(proxies[1], {
        'name': 'Office route · 1. Office gateway (HTTPS gateway.example:443)',
        'type': 'http',
        'server': 'gateway.example',
        'port': 443,
        'tls': true,
        'username': 'user',
        'password': 'pass',
      });
      expect(proxies[2]['dialer-proxy'], proxies[1]['name']);
      expect(rawConfig['proxy-groups'][0]['proxies'], [
        'DIRECT',
        'Office route · Office gateway (HTTPS gateway.example:443) → Exit',
      ]);
    });

    test('builds and orders a three-hop chain', () {
      final rawConfig = <dynamic, dynamic>{
        'proxies': [
          {'name': 'Entry', 'type': 'ss'},
          {'name': 'Exit', 'type': 'vmess'},
        ],
      };
      const savedProxy = SavedProxy(
        id: 77,
        name: 'Middle gateway',
        type: 'socks5',
        server: 'middle.example',
        port: 1080,
      );
      const chain = ProxyGroup(
        id: 11,
        name: 'Three hop',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(type: 'existing', proxy: 'Entry'),
          ChainProxyNode(type: 'saved', savedProxyId: 77),
          ChainProxyNode(type: 'existing', proxy: 'Exit'),
        ],
      );

      applyProxyGroups(rawConfig, [chain], savedProxies: [savedProxy]);

      final proxies = rawConfig['proxies'] as List<dynamic>;
      expect(proxies[2]['name'], 'Three hop · 1. Entry');
      expect(proxies[3]['dialer-proxy'], 'Three hop · 1. Entry');
      expect(
        proxies[4]['dialer-proxy'],
        'Three hop · 2. Middle gateway (SOCKS5 middle.example:1080)',
      );
      expect(rawConfig['proxy-groups'][0]['proxies'], [
        'DIRECT',
        'Three hop · Entry → Middle gateway '
            '(SOCKS5 middle.example:1080) → Exit',
      ]);
    });

    test('rejects a chain that references a missing saved proxy', () {
      final rawConfig = <dynamic, dynamic>{};
      const chain = ProxyGroup(
        id: 10,
        name: 'Invalid saved route',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(type: 'saved', savedProxyId: 404),
          ChainProxyNode(type: 'saved', savedProxyId: 405),
        ],
      );

      expect(() => applyProxyGroups(rawConfig, [chain]), throwsArgumentError);
    });

    test(
      'supports a direct final MATCH target without mutating input rules',
      () {
        final rawConfig = <dynamic, dynamic>{};
        const inputRules = ['MATCH,DIRECT'];

        final rules = applyProxyGroups(rawConfig, const [], rules: inputRules);

        expect(inputRules, ['MATCH,DIRECT']);
        expect(rules, ['MATCH,__FLCLASH_CHAIN_PROXY__']);
        expect(rawConfig['proxy-groups'], [
          {
            'name': '__FLCLASH_CHAIN_PROXY__',
            'type': 'select',
            'proxies': ['DIRECT'],
          },
        ]);
      },
    );

    test('preserves a computed group as the default chain option', () {
      final rawConfig = <dynamic, dynamic>{
        'proxy-groups': [
          {
            'name': 'Automatic',
            'type': 'url-test',
            'proxies': ['Node A'],
          },
        ],
      };

      final rules = applyProxyGroups(
        rawConfig,
        const [],
        rules: const ['MATCH,Automatic'],
        replaceProxyGroups: false,
      );

      expect(rules, ['MATCH,__FLCLASH_CHAIN_PROXY__']);
      expect(rawConfig['proxy-groups'][1]['proxies'], ['Automatic']);
    });

    test('builds isolated provider nodes with dialer chaining', () {
      final rawConfig = <dynamic, dynamic>{
        'proxy-providers': {
          'remote-a': {'type': 'http', 'url': 'https://a.example/proxies'},
          'remote-b': {'type': 'file', 'path': './b.yaml'},
        },
      };
      const chain = ProxyGroup(
        id: 21,
        name: 'Provider route',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(
            type: 'existing',
            proxy: 'Entry',
            provider: 'remote-a',
          ),
          ChainProxyNode(type: 'existing', proxy: 'Exit', provider: 'remote-b'),
        ],
      );

      applyProxyGroups(rawConfig, const [chain]);

      final providers = rawConfig['proxy-providers'] as Map<dynamic, dynamic>;
      expect(providers['__FLCLASH_CHAIN_PROVIDER_21_0']['filter'], r'^Entry$');
      expect(providers['__FLCLASH_CHAIN_PROVIDER_21_0']['override'], {
        'additional-prefix': 'Provider route · 1. ',
        'additional-suffix': ' (remote-a)',
      });
      expect(providers['__FLCLASH_CHAIN_PROVIDER_21_1']['override'], {
        'additional-prefix': 'Provider route · Entry (remote-a) → ',
        'additional-suffix': ' (remote-b)',
        'dialer-proxy': 'Provider route · 1. Entry (remote-a)',
      });
      expect(rawConfig['proxy-groups'][0]['proxies'], [
        'DIRECT',
        'Provider route · Entry (remote-a) → Exit (remote-b)',
      ]);
    });

    test('rejects a profile using the reserved internal group name', () {
      final rawConfig = <dynamic, dynamic>{
        'proxy-groups': [
          {
            'name': '__FLCLASH_CHAIN_PROXY__',
            'type': 'select',
            'proxies': ['DIRECT'],
          },
        ],
      };

      expect(
        () => applyProxyGroups(rawConfig, const [], replaceProxyGroups: false),
        throwsArgumentError,
      );
    });

    test('rejects a profile using a generated provider name', () {
      final rawConfig = <dynamic, dynamic>{
        'proxy-providers': {
          'remote': {'type': 'file', 'path': './remote.yaml'},
          '__FLCLASH_CHAIN_PROVIDER_21_0': {
            'type': 'file',
            'path': './reserved.yaml',
          },
        },
      };
      const chain = ProxyGroup(
        id: 21,
        name: 'Provider route',
        type: GroupType.Relay,
        chainNodes: [
          ChainProxyNode(type: 'existing', proxy: 'Entry', provider: 'remote'),
          ChainProxyNode(type: 'existing', proxy: 'Exit', provider: 'remote'),
        ],
      );

      expect(
        () => applyProxyGroups(rawConfig, const [chain]),
        throwsArgumentError,
      );
    });
  });
}
