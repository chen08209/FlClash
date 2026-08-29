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

  test(
    'clashConfigTask parses core config data off the main isolate',
    () async {
      final configMap = <String, dynamic>{
        'proxies': [
          {'name': 'Alpha', 'type': 'ss'},
          {'name': 'Beta', 'type': 'vmess'},
        ],
        'proxy-groups': [
          {
            'name': 'Auto',
            'type': 'url-test',
            'proxies': ['Alpha', 'Beta'],
          },
        ],
        'rules': ['DOMAIN,example.com,Auto'],
        'proxy-providers': {
          'provider': {'type': 'http'},
        },
        'rule-providers': {
          'ruleSet': {'type': 'http'},
        },
        'sub-rules': {'nested': []},
      };

      final clashConfig = await clashConfigTask(configMap);

      expect(clashConfig.proxies.map((item) => item.name), ['Alpha', 'Beta']);
      expect(clashConfig.proxyGroups.single.type, GroupType.URLTest);
      expect(clashConfig.rules.single.ruleTarget, 'Auto');
      expect(clashConfig.rules.single.content, 'example.com');
      expect(clashConfig.proxyProviders, ['provider']);
      expect(clashConfig.ruleProviders, ['ruleSet']);
      expect(clashConfig.subRules, ['nested']);
      expect(clashConfig.proxyTypeMap, {
        'Alpha': 'ss',
        'Beta': 'vmess',
        'Auto': 'url-test',
      });
    },
  );

  test('buildClashConfig indexes group types by their clash value', () {
    final clashConfig = buildClashConfig(<String, dynamic>{
      'proxies': [
        {'name': 'Alpha', 'type': 'ss'},
      ],
      'proxy-groups': [
        {
          'name': 'Fallback',
          'type': 'fallback',
          'proxies': ['Alpha'],
        },
      ],
    });

    expect(clashConfig.proxyTypeMap, {'Alpha': 'ss', 'Fallback': 'fallback'});
    expect(clashConfig.rules, isEmpty);
  });

  test('toGroupsTask leaves the source proxy map untouched', () async {
    final proxies = <String, dynamic>{
      'Selector': {
        'name': 'Selector',
        'type': 'Selector',
        'all': ['Beta'],
      },
      'Beta': {'name': 'Beta', 'type': 'Direct'},
    };
    final state = ComputeGroupsState(
      proxiesData: ProxiesData(all: const ['Selector'], proxies: proxies),
      sortType: ProxiesSortType.none,
      delayMap: const {},
      selectedMap: const {},
      defaultTestUrl: '',
    );

    await buildGroups(state);
    await buildGroups(state);

    expect(proxies['Selector']['all'], ['Beta']);
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
      final config = loadYaml(result.yaml) as YamlMap;

      expect(result.md5, hasLength(32));
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

  // The core re-reads these two keys out of the generated config on every
  // profile apply and adopts whatever it finds, so a subscription that ships
  // them would otherwise decide whether GEO databases auto-update — including
  // switching the updater back on after the user turned it off.
  test(
    'makeRealProfileTask lets the app setting own the geo updater',
    () async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        await encodeJSONTask({
          'geo-auto-update': true,
          'geo-update-interval': 6,
        }),
      );

      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 11,
          rawConfig: rawConfig,
          realPatchConfig: const PatchClashConfig(
            geoAutoUpdate: false,
            geoUpdateInterval: 48,
          ),
          overrideDns: false,
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
        ),
      );
      final config = loadYaml(result.yaml) as YamlMap;

      expect(config['geo-auto-update'], false);
      expect(config['geo-update-interval'], 48);
    },
  );

  test('makeRealProfileTask overrides DNS and explicit custom data', () async {
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
    final config = loadYaml(result.yaml) as YamlMap;

    expect(config['dns']['enable'], true);
    expect(config['dns']['nameserver'], isNot(contains('system://')));
    expect(config['proxy-groups'], hasLength(1));
    expect(config['rules'], ['DOMAIN,custom.example,DIRECT']);
  });

  test('makeRealProfileTask keeps the DNS keys it cannot edit', () async {
    final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
      await encodeJSONTask({
        'interface-name': 'en0',
        'dns': {
          'enable': false,
          'direct-nameserver': ['223.5.5.5'],
          'proxy-server-nameserver-policy': {
            'www.example.com': ['8.8.8.8'],
          },
          'nameserver': ['9.9.9.9'],
        },
        'proxy-providers': {
          'first': {'type': 'http', 'url': 'https://example.com/shared.yaml'},
          'second': {'type': 'http', 'url': 'https://example.com/shared.yaml'},
        },
      }),
    );

    final result = await makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: '/profiles',
        profileId: 13,
        rawConfig: rawConfig,
        realPatchConfig: const PatchClashConfig(),
        overrideDns: false,
        appendSystemDns: false,
        proxyGroups: const [],
        rules: const [],
        addedRules: const [],
        defaultUA: 'FlClash-Test',
      ),
    );
    final config = loadYaml(result.yaml) as YamlMap;

    expect(config['interface-name'], 'en0');
    expect(config['dns']['direct-nameserver'], ['223.5.5.5']);
    expect(config['dns']['proxy-server-nameserver-policy'], {
      'www.example.com': ['8.8.8.8'],
    });
    expect(config['dns']['nameserver'], isNot(contains('system://')));
    expect(
      config['proxy-providers']['first']['path'],
      isNot(config['proxy-providers']['second']['path']),
    );
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
}
