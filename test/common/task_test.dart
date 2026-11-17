import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('encoding helpers round-trip structured data', () async {
    final encoded = jsonEncode({
      'name': 'FlClash',
      'values': [1, true, null],
    });
    final decoded = await decodeJSONTask<Map<String, dynamic>>(encoded);

    expect(decoded['name'], 'FlClash');
    expect(decoded['values'], [1, true, null]);
    expect(await encodeYamlTask({'enabled': true}), contains('enabled: true'));
  });

  test('a proxy name holding control characters stays readable YAML', () {
    const name = 'HK \x1b[31m\x00\x7f\r ';
    final encoded = yaml.encode({
      'proxies': [
        {'name': name},
      ],
      'proxy-groups': [
        {
          'name': 'G',
          'proxies': [name],
        },
      ],
    });

    expect(encoded, isNot(contains('\x1b')));
    final config = loadYaml(encoded) as YamlMap;
    expect(config['proxies'].first['name'], name);
    expect(config['proxy-groups'].first['proxies'], [name]);
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
    },
  );

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
        jsonEncode({
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
          appendSystemDns: true,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [
            Rule(
              ruleAction: RuleAction.DOMAIN_SUFFIX,
              content: 'added.example',
              ruleTarget: 'MATCH',
              customExit: true,
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
      expect(result.counts, (groups: 0, proxies: 0, rules: 3));
    },
  );

  test('lastMatchTarget reads the last MATCH rule that names a target', () {
    expect(
      lastMatchTarget(['MATCH,A', 'DOMAIN,x.test,B', 'match,C', 'MATCH,']),
      'C',
    );
    expect(lastMatchTarget(['DOMAIN,x.test,B']), isNull);
  });

  group('custom exits', () {
    Rule exitRule(String content, String exit) => Rule(
      ruleAction: RuleAction.DOMAIN_SUFFIX,
      content: content,
      ruleTarget: exit,
      customExit: true,
    );

    Future<List<Object?>> addedRulesOf({
      List<String> groups = const [],
      Map<String, String> exitTargets = const {},
      Set<String>? outboundNames,
      String? defaultExitTarget,
      List<Rule>? addedRules,
    }) async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        jsonEncode({
          'proxies': [
            {'name': 'HK', 'type': 'ss'},
          ],
          'proxy-groups': [
            for (final name in ['Proxy', ...groups])
              {'name': name, 'type': 'select'},
          ],
          'rules': ['DOMAIN,existing.example,DIRECT', 'MATCH,Proxy'],
        }),
      );
      final real = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 7,
          rawConfig: rawConfig,
          realPatchConfig: const PatchClashConfig(),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules:
              addedRules ??
              [exitRule('a.example', 'Media'), exitRule('b.example', 'AI')],
          defaultUA: 'FlClash-Test',
          exitTargets: exitTargets,
          outboundNames: outboundNames,
          defaultExitTarget: defaultExitTarget,
        ),
      );
      final rules = (loadYaml(real.yaml) as YamlMap)['rules'] as List;
      return rules.take(rules.length - 2).toList();
    }

    test('go where each is mapped', () async {
      expect(await addedRulesOf(exitTargets: {'Media': 'HK', 'AI': 'DIRECT'}), [
        'DOMAIN-SUFFIX,a.example,HK',
        'DOMAIN-SUFFIX,b.example,DIRECT',
      ]);
    });

    test('go by default where the last MATCH rule goes', () async {
      expect(await addedRulesOf(exitTargets: {'AI': 'HK'}), [
        'DOMAIN-SUFFIX,a.example,Proxy',
        'DOMAIN-SUFFIX,b.example,HK',
      ]);
    });

    test('take a group of their name only while left on default', () async {
      expect(
        await addedRulesOf(groups: ['Media', 'AI'], exitTargets: {'AI': 'HK'}),
        ['DOMAIN-SUFFIX,a.example,Media', 'DOMAIN-SUFFIX,b.example,HK'],
      );
    });

    test('fall back in the same order from a target that is gone', () async {
      expect(
        await addedRulesOf(
          groups: ['AI'],
          exitTargets: {'Media': 'Gone', 'AI': 'Gone'},
        ),
        ['DOMAIN-SUFFIX,a.example,Proxy', 'DOMAIN-SUFFIX,b.example,AI'],
      );
    });

    test('read the outbounds and default given for a merged profile', () async {
      expect(
        await addedRulesOf(
          outboundNames: {'US'},
          defaultExitTarget: 'US',
          exitTargets: {'AI': 'HK'},
        ),
        ['DOMAIN-SUFFIX,a.example,US', 'DOMAIN-SUFFIX,b.example,US'],
      );
    });

    test('leave a rule that names its target alone', () async {
      expect(
        await addedRulesOf(
          addedRules: const [
            Rule(
              ruleAction: RuleAction.DOMAIN,
              content: 'c.example',
              ruleTarget: 'Media',
            ),
          ],
          exitTargets: {'Media': 'HK'},
        ),
        ['DOMAIN,c.example,Media'],
      );
    });
  });

  group('module exits', () {
    const module = MitmModuleSource(
      content: '''
[Rule]
DOMAIN,a.example,Media
DOMAIN,b.example,PROXY
RULE-SET,https://example.com/ai.list,AI,no-resolve
DOMAIN,c.example,REJECT
''',
    );

    List<Object?> moduleRulesOf(YamlMap config) =>
        (config['rules'] as List).take(4).toList();

    Future<YamlMap> normal(Map<String, String> exitTargets) async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        jsonEncode({
          'proxies': [
            {'name': 'HK', 'type': 'ss'},
          ],
          'proxy-groups': [
            for (final name in ['Proxy', 'Media'])
              {'name': name, 'type': 'select'},
          ],
          'rules': ['MATCH,Proxy'],
        }),
      );
      final real = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 7,
          rawConfig: rawConfig,
          realPatchConfig: const PatchClashConfig(mitm: Mitm(enable: true)),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
          exitTargets: exitTargets,
          mitmModules: const [module],
        ),
      );
      return loadYaml(real.yaml) as YamlMap;
    }

    test('go to a group of their name, then where MATCH goes', () async {
      final config = await normal(const {});
      final rules = moduleRulesOf(config);
      expect(rules.take(2), [
        'DOMAIN,a.example,Media',
        'DOMAIN,b.example,Proxy',
      ]);
      expect('${rules[2]}', matches(r'^RULE-SET,mitm-\w+,Proxy,no-resolve$'));
      expect(rules[3], 'DOMAIN,c.example,REJECT');
      final set = '${rules[2]}'.split(',')[1];
      expect(
        (config['rule-providers'] as YamlMap)[set]['url'],
        'https://example.com/ai.list',
      );
    });

    test(
      'go where the profile maps them, and back from a target gone',
      () async {
        final rules = moduleRulesOf(
          await normal({'PROXY': 'HK', 'AI': 'DIRECT', 'Media': 'Gone'}),
        );
        expect(rules[0], 'DOMAIN,a.example,Media');
        expect(rules[1], 'DOMAIN,b.example,HK');
        expect('${rules[2]}', endsWith(',DIRECT,no-resolve'));
      },
    );

    test('read an attached rule set where it is, not confined', () async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        jsonEncode({
          'rules': ['MATCH,DIRECT'],
        }),
      );
      final real = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 7,
          rawConfig: rawConfig,
          realPatchConfig: const PatchClashConfig(mitm: Mitm(enable: true)),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
          mitmModules: const [
            MitmModuleSource(
              content: '[Rule]\nDOMAIN-SET,reject.conf,REJECT\n',
              resources: {'reject.conf': 'ab12.conf'},
            ),
          ],
        ),
      );
      final config = loadYaml(real.yaml) as YamlMap;
      final set = '${(config['rules'] as List).first}'.split(',')[1];
      expect(Map.of((config['rule-providers'] as YamlMap)[set] as YamlMap), {
        'type': 'file',
        'behavior': 'domain',
        'format': 'domain-set',
        'path': 'mitm/resources/ab12.conf',
      });
    });

    test('in a custom profile go to its own groups', () async {
      final real = await makeRealProfileTask(
        const MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 9,
          rawConfig: {},
          realPatchConfig: PatchClashConfig(mitm: Mitm(enable: true)),
          appendSystemDns: false,
          proxyGroups: [
            ProxyGroup(
              id: 1,
              name: 'Media',
              type: GroupType.Selector,
              proxies: ['DIRECT'],
            ),
            ProxyGroup(
              id: 2,
              name: 'Select',
              type: GroupType.Selector,
              proxies: ['DIRECT'],
            ),
          ],
          rules: [Rule(ruleAction: RuleAction.MATCH, ruleTarget: 'Select')],
          addedRules: [],
          defaultUA: 'FlClash-Test',
          exitTargets: {'AI': 'Media'},
          mitmModules: [module],
        ),
      );
      final rules = moduleRulesOf(loadYaml(real.yaml) as YamlMap);
      expect(rules[0], 'DOMAIN,a.example,Media');
      expect(rules[1], 'DOMAIN,b.example,Select');
      expect('${rules[2]}', endsWith(',Media,no-resolve'));
    });
  });

  // The core re-reads these two keys out of the generated config on every
  // profile apply and adopts whatever it finds, so a subscription that ships
  // them would otherwise decide whether GEO databases auto-update — including
  // switching the updater back on after the user turned it off.
  test(
    'makeRealProfileTask lets the app setting own the geo updater',
    () async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        jsonEncode({'geo-auto-update': true, 'geo-update-interval': 6}),
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

  // A profile-shipped loopback skip-auth-prefixes would bypass the credentials.
  test('makeRealProfileTask lets the app own local authentication', () async {
    final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
      jsonEncode({
        'authentication': ['subscription:injected'],
        'skip-auth-prefixes': ['127.0.0.1/32'],
      }),
    );
    final state = MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 12,
      rawConfig: rawConfig,
      realPatchConfig: const PatchClashConfig(),
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
      authentication: const ['user:pass'],
    );

    final enabled = await makeRealProfileTask(state);
    final enabledConfig = loadYaml(enabled.yaml) as YamlMap;
    expect(enabledConfig['authentication'], ['user:pass']);
    expect(enabledConfig['skip-auth-prefixes'], isEmpty);

    final disabled = await makeRealProfileTask(
      state.copyWith(authentication: const []),
    );
    final disabledConfig = loadYaml(disabled.yaml) as YamlMap;
    expect(disabledConfig['authentication'], isEmpty);
    expect(disabledConfig['skip-auth-prefixes'], isEmpty);
  });

  test('makeRealProfileTask overrides DNS and explicit custom data', () async {
    final result = await makeRealProfileTask(
      const MakeRealProfileState(
        profilesPath: '/profiles',
        profileId: 9,
        rawConfig: {},
        realPatchConfig: PatchClashConfig(),
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
    expect(config['proxy-groups'][0].keys, ['name', 'type', 'proxies']);
    expect(config['proxy-groups'][0]['type'], 'select');
    expect(config['rules'], ['DOMAIN,custom.example,DIRECT']);
  });

  test('makeRealProfileTask keeps the DNS keys it cannot edit', () async {
    final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
      jsonEncode({
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
        appendSystemDns: false,
        proxyGroups: const [],
        rules: const [],
        addedRules: const [],
        defaultUA: 'FlClash-Test',
      ),
    );
    final config = loadYaml(result.yaml) as YamlMap;

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

  test('makeRealProfileTask keeps safe mode off the host', () async {
    Future<YamlMap> build({required bool safeMode}) async {
      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 14,
          rawConfig: {
            'dns': {'enable': true, 'listen': '0.0.0.0:53'},
            'ntp': {'enable': true, 'write-to-system': true},
          },
          realPatchConfig: const PatchClashConfig(),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
          safeMode: safeMode,
        ),
      );
      return loadYaml(result.yaml) as YamlMap;
    }

    final normal = await build(safeMode: false);
    expect(normal['dns']['listen'], '0.0.0.0:53');
    expect(normal['ntp']['write-to-system'], true);

    final safe = await build(safeMode: true);
    expect(safe['dns']['listen'], '');
    expect(safe['ntp']['write-to-system'], false);
    expect(safe['ntp']['enable'], true);
  });

  test(
    'makeRealProfileTask does not let a profile open a controller',
    () async {
      for (final safeMode in [false, true]) {
        final result = await makeRealProfileTask(
          MakeRealProfileState(
            profilesPath: '/profiles',
            profileId: 14,
            rawConfig: {
              'external-controller': '0.0.0.0:9090',
              'secret': 'from-the-profile',
              'external-controller-tls': '0.0.0.0:9443',
              'external-controller-unix': '/tmp/victim',
              'external-controller-pipe': r'\\.\pipe\mihomo',
            },
            realPatchConfig: const PatchClashConfig(),
            appendSystemDns: false,
            proxyGroups: const [],
            rules: const [],
            addedRules: const [],
            defaultUA: 'FlClash-Test',
            safeMode: safeMode,
          ),
        );
        final config = loadYaml(result.yaml) as YamlMap;

        expect(config['external-controller-tls'], '');
        expect(config['external-controller-unix'], '');
        expect(config['external-controller-pipe'], '');
        expect(config['external-controller'], '');
        expect(config['secret'], '');
      }
    },
  );

  test(
    'makeRealProfileTask writes the app secret over the profile one',
    () async {
      Future<YamlMap> build(PatchClashConfig realPatchConfig) async {
        final result = await makeRealProfileTask(
          MakeRealProfileState(
            profilesPath: '/profiles',
            profileId: 14,
            rawConfig: {'secret': 'from-the-profile'},
            realPatchConfig: realPatchConfig,
            appendSystemDns: false,
            proxyGroups: const [],
            rules: const [],
            addedRules: const [],
            defaultUA: 'FlClash-Test',
          ),
        );
        return loadYaml(result.yaml) as YamlMap;
      }

      final open = await build(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
          secret: 'from-the-app',
        ),
      );
      expect(open['external-controller'], '127.0.0.1:9090');
      expect(open['secret'], 'from-the-app');

      final closed = await build(const PatchClashConfig());
      expect(closed['secret'], '');
      final missingSecret = await build(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
        ),
      );
      expect(missingSecret['external-controller'], '');
    },
  );

  test(
    'profile listeners and host changes are disabled only in safe mode',
    () async {
      for (final safeMode in [false, true]) {
        final result = await makeRealProfileTask(
          MakeRealProfileState(
            profilesPath: '/profiles',
            profileId: 14,
            rawConfig: {
              'listeners': [
                {'type': 'mixed', 'name': 'extra', 'port': 1234},
                {'type': 'tun', 'name': 'extra-tun', 'auto-route': true},
              ],
              'tunnels': [
                {
                  'network': ['tcp'],
                  'address': '0.0.0.0:1234',
                  'target': 'example.test:443',
                },
              ],
              'ss-config': 'ss://cipher:password@:1234',
              'vmess-config': 'vmess://uuid@:1234',
              'tuic-server': {'enable': true, 'listen': '0.0.0.0:1234'},
              'iptables': {'enable': true, 'dns-redirect': true},
              'dns': {'enable': true, 'listen': '0.0.0.0:53'},
              'ntp': {'enable': true, 'write-to-system': true},
            },
            realPatchConfig: const PatchClashConfig(
              externalController: ExternalControllerStatus.open,
              secret: 'from-the-app',
            ),
            appendSystemDns: false,
            proxyGroups: const [],
            rules: const [],
            addedRules: const [],
            defaultUA: 'FlClash-Test',
            safeMode: safeMode,
          ),
        );
        final config = loadYaml(result.yaml) as YamlMap;
        if (safeMode) {
          expect(config['listeners'], isEmpty);
          expect(config['tunnels'], isEmpty);
          expect(config['ss-config'], '');
          expect(config['vmess-config'], '');
          expect(config['tuic-server']['enable'], false);
          expect(config['iptables']['enable'], false);
          expect(config['dns']['listen'], '');
          expect(config['ntp']['write-to-system'], false);
        } else {
          expect(config['listeners'], [
            {'type': 'mixed', 'name': 'extra', 'port': 1234},
            {'type': 'tun', 'name': 'extra-tun', 'auto-route': true},
          ]);
          expect(config['tunnels'], [
            {
              'network': ['tcp'],
              'address': '0.0.0.0:1234',
              'target': 'example.test:443',
            },
          ]);
          expect(config['ss-config'], 'ss://cipher:password@:1234');
          expect(config['vmess-config'], 'vmess://uuid@:1234');
          expect(config['tuic-server'], {
            'enable': true,
            'listen': '0.0.0.0:1234',
          });
          expect(config['iptables'], {'enable': true, 'dns-redirect': true});
          expect(config['dns']['listen'], '0.0.0.0:53');
          expect(config['ntp']['write-to-system'], true);
        }
        expect(config['external-controller'], safeMode ? '' : '127.0.0.1:9090');
      }
    },
  );

  test('iptables interface names cannot add command arguments', () async {
    for (final interfaceName in ['br-lan.10', 'lo -M /tmp/extra']) {
      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 14,
          rawConfig: {
            'iptables': {
              'enable': true,
              'inbound-interface': interfaceName,
              'bypass': ['192.168.0.0/16'],
            },
          },
          realPatchConfig: const PatchClashConfig(),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
        ),
      );
      final config = loadYaml(result.yaml) as YamlMap;
      expect(
        config['iptables'],
        interfaceName == 'br-lan.10'
            ? {
                'enable': true,
                'inbound-interface': interfaceName,
                'bypass': ['192.168.0.0/16'],
              }
            : {'enable': false},
      );
    }
  });

  group('makeRealProfileTask interface-name mode', () {
    Future<YamlMap> runWith(PatchClashConfig realPatchConfig) async {
      final rawConfig = await decodeJSONTask<Map<String, dynamic>>(
        jsonEncode({'interface-name': 'en0'}),
      );

      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 13,
          rawConfig: rawConfig,
          realPatchConfig: realPatchConfig,
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
        ),
      );
      return loadYaml(result.yaml) as YamlMap;
    }

    // Default mode, so a subscription value must not survive into the
    // generated config.
    test('clear forces interface-name empty', () async {
      final config = await runWith(const PatchClashConfig());

      expect(config['interface-name'], '');
    });

    test('follow leaves the profile value untouched', () async {
      final config = await runWith(
        const PatchClashConfig(interfaceNameMode: InterfaceNameMode.follow),
      );

      expect(config['interface-name'], 'en0');
    });

    test('custom writes the configured interface name', () async {
      final config = await runWith(
        const PatchClashConfig(
          interfaceNameMode: InterfaceNameMode.custom,
          interfaceName: 'eth0',
        ),
      );

      expect(config['interface-name'], 'eth0');
    });
  });

  group('makeRealProfileTask network settings', () {
    Future<YamlMap> runWith(
      PatchClashConfig realPatchConfig,
      Map<String, dynamic> rawConfig, {
      List<MitmModuleSource> mitmModules = const [],
    }) async {
      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 14,
          rawConfig: await decodeJSONTask<Map<String, dynamic>>(
            jsonEncode(rawConfig),
          ),
          realPatchConfig: realPatchConfig,
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
          mitmModules: mitmModules,
        ),
      );
      return loadYaml(result.yaml) as YamlMap;
    }

    test('tun takes its stack from the settings and the rest from the '
        'profile', () async {
      final config = await runWith(
        const PatchClashConfig(tun: Tun(stack: TunStack.gvisor, mtu: 1400)),
        {
          'tun': {
            'stack': 'system',
            'mtu': 1500,
            'strict-route': true,
            'udp-timeout': 60,
          },
        },
      );
      final tun = config['tun'] as YamlMap;

      expect(tun['stack'], 'gvisor');
      expect(tun['auto-route'], true);
      expect(tun['mtu'], 1500);
      expect(tun['strict-route'], true);
      expect(tun.containsKey('congestion-controller'), isFalse);
      expect(tun['udp-timeout'], 60);
    });

    test('tun detects the outbound interface over the profile', () async {
      final config = await runWith(const PatchClashConfig(), {
        'tun': {'auto-detect-interface': false},
      });
      final tun = config['tun'] as YamlMap;

      expect(tun['auto-detect-interface'], true);
    });

    test('outbound settings start at the core defaults', () async {
      final config = await runWith(const PatchClashConfig(), {
        'routing-mark': 1,
      });

      expect(config['keep-alive-idle'], 15);
      expect(config['routing-mark'], 0);
    });

    test('set outbound values replace the profile ones', () async {
      final config = await runWith(
        const PatchClashConfig(routingMark: 6666, disableKeepAlive: true),
        {'routing-mark': 1, 'disable-keep-alive': false},
      );

      expect(config['routing-mark'], 6666);
      expect(config['disable-keep-alive'], true);
    });

    test('the mitm section is the app setting, never the profile', () async {
      final config = await runWith(
        const PatchClashConfig(mitm: Mitm(enable: true, hostname: ['a.com'])),
        {
          'mitm': {
            'enable': true,
            'hostname': ['*'],
            'url-rewrite': ['^http://x _ reject'],
          },
        },
      );
      final mitm = config['mitm'] as YamlMap;

      expect(mitm['enable'], isTrue);
      expect(mitm['hostname'], ['a.com']);
      expect(mitm['url-rewrite'], isEmpty);
      expect(mitm['decrypt-tls'], isFalse);
      expect(mitm, isNot(contains('trusted-fingerprint')));
    });

    test('HTTPS is decrypted with the CA the device trusts', () async {
      final config = await runWith(
        const PatchClashConfig(
          mitm: Mitm(enable: true, trustedFingerprint: 'AB:CD'),
        ),
        const {},
      );
      final mitm = config['mitm'] as YamlMap;

      expect(mitm['decrypt-tls'], isTrue);
      expect(mitm['ca-fingerprint'], 'AB:CD');
    });

    test('modules join the mitm lists and lead the rules', () async {
      final config = await runWith(
        const PatchClashConfig(
          mitm: Mitm(enable: true, hostname: ['-own.example.com']),
        ),
        {
          'rules': ['MATCH,DIRECT'],
        },
        mitmModules: const [
          MitmModuleSource(
            content: '''
#!arguments=Host:module.example.com
[MITM]
hostname = %APPEND% {{{Host}}}
[URL Rewrite]
^https://module _ reject
[Rule]
DOMAIN-SUFFIX,ads.example.com,REJECT
''',
            arguments: {'Host': '*.example.com'},
          ),
        ],
      );
      final mitm = config['mitm'] as YamlMap;

      expect(mitm['hostname'], ['-own.example.com', '*.example.com']);
      expect(mitm['url-rewrite'], ['^https://module _ reject']);
      expect(config['rules'], [
        'DOMAIN-SUFFIX,ads.example.com,REJECT',
        'MATCH,DIRECT',
      ]);
    });

    test('a profile cannot turn MITM on while the app has it off', () async {
      final config = await runWith(const PatchClashConfig(), {
        'mitm': {
          'enable': true,
          'hostname': ['*'],
        },
      });

      expect((config['mitm'] as YamlMap)['enable'], isFalse);
      expect((config['mitm'] as YamlMap)['hostname'], isEmpty);
    });
  });

  group('makeRealProfileTask legacy provider file migration', () {
    late Directory tempDir;
    const url = 'https://example.com/proxy.yaml';
    const name = 'remote';

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('task_test_providers');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<({String legacyPath, String newPath})> runMigration() async {
      final providerDir = join(
        tempDir.path,
        providersDirectoryName,
        '17',
        proxiesProviderDirectoryName,
      );
      final legacyPath = join(providerDir, url.toMd5());
      final newPath = join(providerDir, '$name@$url'.toMd5());

      final result = await makeRealProfileTask(
        MakeRealProfileState(
          profilesPath: tempDir.path,
          profileId: 17,
          rawConfig: {
            'proxy-providers': {
              name: {'type': 'http', 'url': url},
            },
          },
          realPatchConfig: const PatchClashConfig(),
          appendSystemDns: false,
          proxyGroups: const [],
          rules: const [],
          addedRules: const [],
          defaultUA: 'FlClash-Test',
        ),
      );
      final config = loadYaml(result.yaml) as YamlMap;
      expect(config['proxy-providers'][name]['path'], newPath);
      return (legacyPath: legacyPath, newPath: newPath);
    }

    test('renames a file cached under the legacy url-only key', () async {
      final providerDir = join(
        tempDir.path,
        providersDirectoryName,
        '17',
        proxiesProviderDirectoryName,
      );
      await Directory(providerDir).create(recursive: true);
      final legacyFile = File(join(providerDir, url.toMd5()));
      await legacyFile.writeAsString('cached-provider-data');

      final paths = await runMigration();

      expect(File(paths.newPath).existsSync(), isTrue);
      expect(await File(paths.newPath).readAsString(), 'cached-provider-data');
      expect(File(paths.legacyPath).existsSync(), isFalse);
    });

    test('is a no-op when no legacy file exists', () async {
      final paths = await runMigration();

      expect(File(paths.legacyPath).existsSync(), isFalse);
      expect(File(paths.newPath).existsSync(), isFalse);
    });
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
  });
}
