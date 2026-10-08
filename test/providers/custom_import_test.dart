import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

CustomImportApp _app({
  Map<String, String> profiles = const {},
  Set<String> profileLabels = const {},
  Map<String, String> ruleProviders = const {},
  Set<String> ruleProviderLabels = const {},
  List<Map<String, dynamic>> proxies = const [],
  Set<String> groupNames = const {},
}) => (
  profileLabels: {...profileLabels, ...profiles.values},
  profileUrls: profiles,
  ruleProviderLabels: {...ruleProviderLabels, ...ruleProviders.values},
  ruleProviderUrls: ruleProviders,
  proxies: proxies,
  groupNames: groupNames,
);

CustomProfileImport _read(String config, [CustomImportApp? app]) =>
    readCustomProfileImport((bytes: utf8.encode(config), app: app ?? _app()));

Matcher _issue(CustomImportIssue issue, {String? item}) =>
    isA<CustomImportException>()
        .having((error) => error.issue, 'issue', issue)
        .having((error) => error.item, 'item', item ?? anything);

void main() {
  group('proxy providers', () {
    test('uses a provider the app already has under its label', () {
      final config = _read('''
proxy-providers:
  sub:
    type: http
    url: https://example.com/sub
proxy-groups:
  - {name: Proxy, type: select, use: [sub]}
''', _app(profiles: {'https://example.com/sub': 'My sub'}));

      expect(config.proxyProviders, isEmpty);
      expect(config.proxyGroups.single.use, ['My sub']);
    });

    test('moves a new provider off a label the app uses', () {
      final config = _read('''
proxy-providers:
  sub:
    type: http
    url: https://example.com/new
    health-check: {enable: true, url: https://cp.example.com, interval: 300}
    override: {additional-prefix: '[sub] '}
proxy-groups:
  - {name: Proxy, type: select, use: [sub, other]}
''', _app(profileLabels: {'sub'}));

      expect(config.proxyProviders, [
        (label: 'sub(1)', url: 'https://example.com/new', content: ''),
      ]);
      expect(config.proxyGroups.single.use, ['sub(1)', 'other']);
      expect(config.overrides.proxyProviders, {
        'sub(1)': const ProxyProviderOptions(
          healthCheck: ProviderHealthCheck(
            url: 'https://cp.example.com',
            interval: 300,
          ),
          proxyOverride: ProviderOverride(additionalPrefix: '[sub] '),
        ),
      });
    });

    test('adds file providers empty and inline ones with their proxies', () {
      final config = _read('''
proxy-providers:
  local: {type: file, path: ./local.yaml}
  inline:
    type: inline
    payload:
      - {name: A, type: ss, server: a.example.com}
''');

      expect(config.proxyProviders.first, (
        label: 'local',
        url: '',
        content: '',
      ));
      final inline = config.proxyProviders.last;
      expect(inline.label, 'inline');
      expect(inline.url, isEmpty);
      expect(loadYaml(inline.content), {
        'proxies': [
          {'name': 'A', 'type': 'ss', 'server': 'a.example.com'},
        ],
      });
    });

    test('adds one provider for two names sharing a url', () {
      final config = _read('''
proxy-providers:
  a: {type: http, url: https://example.com/sub}
  b: {type: http, url: https://example.com/sub}
proxy-groups:
  - {name: Proxy, type: select, use: [a, b]}
''');

      expect(config.proxyProviders.single.label, 'a');
      expect(config.proxyGroups.single.use, ['a']);
    });

    test('applies merge keys', () {
      final config = _read('''
p: &p
  type: http
  interval: 3600
proxy-providers:
  sub:
    <<: *p
    url: https://example.com/sub
''');

      expect(config.proxyProviders.single.url, 'https://example.com/sub');
    });
  });

  group('rule providers', () {
    test('renames every reference to a moved rule set', () {
      final config = _read(
        '''
rule-providers:
  ads: {type: http, url: https://example.com/ads.yaml, behavior: domain}
  cn: {type: http, url: https://example.com/cn.yaml, behavior: domain}
rules:
  - RULE-SET,ads,REJECT
  - AND,((RULE-SET,ads),(NETWORK,UDP)),REJECT
  - RULE-SET,cn,DIRECT
  - MATCH,DIRECT
dns:
  nameserver-policy:
    rule-set:ads,cn: https://dns.example.com/dns-query
  fake-ip-filter: ['rule-set:ads', '+.lan']
sniffer:
  skip-domain: ['rule-set:cn']
''',
        _app(
          ruleProviders: {'https://example.com/cn.yaml': 'China'},
          ruleProviderLabels: {'ads'},
        ),
      );

      expect(config.ruleProviders, [
        (label: 'ads(1)', url: 'https://example.com/ads.yaml', content: ''),
      ]);
      expect(
        [for (final rule in config.rules) rule.rawValue],
        [
          'RULE-SET,ads(1),REJECT',
          'AND,((RULE-SET,ads(1)),(NETWORK,UDP)),REJECT',
          'RULE-SET,China,DIRECT',
          'MATCH,DIRECT',
        ],
      );
      expect(config.overrides.dns.nameserverPolicy.keys, [
        'rule-set:ads(1),China',
      ]);
      expect(config.overrides.dns.fakeIpFilter, ['rule-set:ads(1)', '+.lan']);
      expect(config.overrides.sniffer.skipDomain, ['rule-set:China']);
      expect(config.overrides.ruleSets, {'ads(1)', 'China'});
    });

    test('adds an inline set with its payload', () {
      final config = _read('''
rule-providers:
  local: {type: file, path: ./local.yaml, behavior: classical}
  inline: {type: inline, behavior: domain, payload: [+.example.com]}
''');

      expect(config.ruleProviders.first.content, isEmpty);
      expect(loadYaml(config.ruleProviders.last.content), {
        'payload': ['+.example.com'],
      });
    });
  });

  group('proxies and groups', () {
    test('keeps a proxy the app holds as it is under the app name', () {
      final config = _read(
        '''
proxies:
  - {name: Hong Kong, type: ss, server: hk.example.com, port: 443}
proxy-groups:
  - {name: Proxy, type: select, proxies: [Hong Kong, DIRECT]}
rules:
  - MATCH,Proxy
''',
        _app(
          proxies: [
            {
              'name': 'HK',
              'type': 'ss',
              'server': 'hk.example.com',
              'port': 443,
            },
          ],
        ),
      );

      expect(config.proxies, isEmpty);
      expect(config.proxyGroups.single.proxies, ['HK', 'DIRECT']);
    });

    test('reads the port a share link writes as text as a number', () {
      final config = _read(
        '''
proxies:
  - {name: Hong Kong, type: ss, server: hk.example.com, port: 443}
''',
        _app(
          proxies: [
            {
              'name': 'HK',
              'type': 'ss',
              'server': 'hk.example.com',
              'port': '443',
            },
          ],
        ),
      );

      expect(config.proxies, isEmpty);
    });

    test('takes a proxy keeping an app proxy name, server and credentials '
        'as that proxy, whatever else a share link changed', () {
      final config = _read(
        '''
proxies:
  - name: HK
    type: trojan
    server: hk.example.com
    port: 443
    password: secret
    sni: hk.example.com
  - {name: SG, type: trojan, server: sg.example.com, port: 443, password: new}
proxy-groups:
  - {name: Proxy, type: select, proxies: [HK, SG]}
''',
        _app(
          proxies: [
            {
              'name': 'HK',
              'type': 'trojan',
              'server': 'hk.example.com',
              'port': '443',
              'password': 'secret',
              'udp': true,
              'skip-cert-verify': false,
            },
            {
              'name': 'SG',
              'type': 'trojan',
              'server': 'sg.example.com',
              'port': '443',
              'password': 'old',
            },
          ],
        ),
      );

      expect([for (final proxy in config.proxies) proxy['name']], ['SG-01']);
      expect(config.proxyGroups.single.proxies, ['HK', 'SG-01']);
    });

    test('gives the dialers proxies carry to the profile', () {
      final config = _read(
        '''
proxies:
  - {name: Hong Kong, type: ss, server: hk.example.com, dialer-proxy: Relay}
  - {name: Relay, type: ss, server: relay.example.com, dialer-proxy: Chain}
proxy-groups:
  - {name: Chain, type: select, proxies: [DIRECT]}
''',
        _app(
          proxies: [
            {
              'name': 'HK',
              'type': 'ss',
              'server': 'hk.example.com',
              'dialer-proxy': 'Old',
            },
          ],
        ),
      );

      expect(config.proxies, [
        {'name': 'Relay', 'type': 'ss', 'server': 'relay.example.com'},
      ]);
      expect(config.dialers, {'HK': 'Relay', 'Relay': 'Chain'});
    });

    test('moves a proxy and a group off the names of app proxies', () {
      final config = _read(
        '''
proxies:
  - {name: HK, type: ss, server: new.example.com, port: 443}
  - {name: SG, type: ss, server: sg.example.com, dialer-proxy: Auto}
proxy-groups:
  - {name: Auto, type: url-test, proxies: [HK]}
  - {name: Proxy, type: select, proxies: [Auto, SG]}
rules:
  - DOMAIN,example.com,Auto
ntp: {enable: true, dialer-proxy: Auto}
''',
        _app(
          proxies: [
            {'name': 'HK', 'type': 'ss', 'server': 'old.example.com'},
            {'name': 'Auto', 'type': 'ss', 'server': 'auto.example.com'},
          ],
        ),
      );

      expect(
        [for (final proxy in config.proxies) proxy['name']],
        ['HK-01', 'SG'],
      );
      expect(config.proxies.last, isNot(contains('dialer-proxy')));
      expect(config.dialers, {'SG': 'Auto-01'});
      expect(
        [for (final group in config.proxyGroups) group.name],
        ['Auto-01', 'Proxy'],
      );
      expect(
        [for (final group in config.proxyGroups) group.proxies],
        [
          ['HK-01'],
          ['Auto-01', 'SG'],
        ],
      );
      expect(config.rules.single.ruleTarget, 'Auto-01');
      expect(config.overrides.ntp.dialerProxy, 'Auto-01');
    });

    test('moves a proxy, not a group, off another profile\'s groups', () {
      final config = _read('''
proxies:
  - {name: Auto, type: ss, server: new.example.com}
proxy-groups:
  - {name: Proxy, type: select, proxies: [Auto]}
rules:
  - MATCH,Proxy
''', _app(groupNames: {'Auto', 'Proxy'}));

      expect([for (final proxy in config.proxies) proxy['name']], ['Auto-01']);
      expect(config.proxyGroups.single.name, 'Proxy');
      expect(config.proxyGroups.single.proxies, ['Auto-01']);
    });

    test('moves a name the file repeats off its first holder', () {
      final config = _read('''
proxies:
  - {name: A, type: ss, server: a.example.com, dialer-proxy: G}
  - {name: A, type: ss, server: b.example.com}
proxy-groups:
  - {name: G, type: select, proxies: [A]}
  - {name: G, type: select, proxies: [DIRECT]}
rules:
  - MATCH,G
''');

      expect(
        [for (final proxy in config.proxies) proxy['name']],
        ['A', 'A-01'],
      );
      expect(
        [for (final group in config.proxyGroups) group.name],
        ['G', 'G-01'],
      );
      expect(config.proxyGroups.first.proxies, ['A']);
      expect(config.dialers, {'A': 'G'});
      expect(config.rules.single.ruleTarget, 'G');
    });

    test(
      'drops include-all-providers and keeps the proxies of include-all',
      () {
        final config = _read('''
proxy-groups:
  - {name: All, type: select, include-all: true}
  - {name: Providers, type: select, include-all-providers: true}
''');

        final [all, providers] = config.proxyGroups;
        expect(all.includeAll, isNull);
        expect(all.includeAllProxies, isTrue);
        expect(all.includeAllProviders, isNull);
        expect(providers.includeAllProviders, isNull);
        expect(providers.includeAllProxies, isNull);
      },
    );

    test('renames the proxies DNS servers dial through', () {
      final config = _read(
        '''
proxies:
  - {name: Auto, type: ss, server: new.example.com}
  - {name: TS, type: tailscale}
dns:
  nameserver:
    - https://dns.example.com/dns-query#Auto
    - tls://1.1.1.1#Auto&h3=true
    - ts://TS
    - https://dns.example.com/dns-query#DIRECT
  nameserver-policy:
    '+.example.com': https://dns.example.com/dns-query#Auto
''',
        _app(
          proxies: [
            {'name': 'Auto', 'type': 'ss', 'server': 'old.example.com'},
            {'name': 'TS', 'type': 'ss', 'server': 'ts.example.com'},
          ],
        ),
      );
      final dns = config.overrides.dns;

      expect(dns.nameserver, [
        'https://dns.example.com/dns-query#Auto-01',
        'tls://1.1.1.1#Auto-01&h3=true',
        'ts://TS-01',
        'https://dns.example.com/dns-query#DIRECT',
      ]);
      expect(dns.nameserverPolicy, {
        '+.example.com': 'https://dns.example.com/dns-query#Auto-01',
      });
    });

    test('leaves ids for the caller to assign', () {
      final config = _read('''
proxy-groups:
  - {name: Proxy, type: select, proxies: [DIRECT]}
rules:
  - MATCH,Proxy
''');

      expect(config.proxyGroups.single.id, 0);
      expect(config.rules.single.id, 0);
    });
  });

  group('overrides', () {
    test('takes the sections the profile can hold', () {
      final config = _read('''
dns:
  enable: true
  enhanced-mode: fake-ip
  nameserver: [https://dns.example.com/dns-query]
  unknown-key: 1
sniffer:
  enable: true
  sniff:
    tls: {ports: [443]}
tun:
  enable: true
  exclude-interface: [docker0]
''');
      final overrides = config.overrides;

      expect(overrides.dnsOverrideKeys, {
        DnsOverrideKey.enable,
        DnsOverrideKey.enhancedMode,
        DnsOverrideKey.nameserver,
      });
      expect(overrides.dns.nameserver, ['https://dns.example.com/dns-query']);
      expect(overrides.snifferOverrideKeys, {
        SnifferOverrideKey.enable,
        SnifferOverrideKey.sniffTls,
      });
      expect(overrides.sniffer.sniff['TLS']?.ports, ['443']);
      expect(overrides.tunOverrideKeys, {TunOverrideKey.excludeInterface});
      expect(overrides.tun.excludeInterface, ['docker0']);
      expect(overrides.ntpOverrideKeys, isEmpty);
    });
  });

  group('refuses', () {
    test('a file that is not a config', () {
      expect(() => _read('- a\n- b\n'), throwsA(_issue(.unreadable)));
      expect(() => _read('name: value\n'), throwsA(_issue(.unreadable)));
      expect(() => _read('proxies: [\n'), throwsA(_issue(.unreadable)));
    });

    test('a rule of a type the app does not know', () {
      expect(
        () => _read('rules:\n  - UNKNOWN,a,DIRECT\n'),
        throwsA(_issue(.ruleType, item: 'UNKNOWN,a,DIRECT')),
      );
    });

    test('a group the app cannot hold, naming it', () {
      expect(
        () => _read('proxy-groups:\n  - {name: Smart, type: smart}\n'),
        throwsA(_issue(.entry, item: 'Smart')),
      );
    });
  });

  group('importing into a custom profile', () {
    const profileId = 1;
    const custom = Profile(
      id: profileId,
      label: 'Custom',
      type: ProfileType.custom,
      autoUpdateDuration: Duration.zero,
    );
    const hongKong = CustomProxy(
      id: 5,
      definition: {'name': 'HK', 'type': 'ss', 'server': 'hk.example.com'},
    );

    late Directory home;
    late db.Database testDatabase;
    late ProviderContainer container;
    late List<String> compiledUrls;

    setUp(() async {
      await AppLocalizations.load(const Locale('en'));
      home = Directory.systemTemp.createTempSync('flclash-custom-import-');
      AppPath.supportDirectory = () async => home;
      AppPath.temporaryDirectory = () async => home;
      AppPath.cacheDirectory = () async => home;
      AppPath.downloadDirectory = () async => home;
      testDatabase = db.Database(NativeDatabase.memory());
      db.database = testDatabase;
      await testDatabase.profiles.put(custom.toCompanion());
      await testDatabase.customProxies.put(hongKong.toCompanion('a0'));
      await testDatabase.proxyGroups.put(
        const ProxyGroup(
          id: 7,
          name: 'Old',
          type: GroupType.Selector,
          proxies: ['HK'],
          order: 'a0',
        ).toCompanion(profileId),
      );
      await testDatabase.rulesDao.putRule(
        const Rule(id: 8, ruleAction: RuleAction.MATCH, ruleTarget: 'Old'),
        profileId: profileId,
      );
      await testDatabase.proxyDialers.put(
        const ProxyDialer(
          profileId: profileId,
          proxyId: 5,
          target: 'Old',
        ).toCompanion(),
      );
      compiledUrls = [];
      final core = _MockCoreHandlerInterface();
      when(() => core.validateConfig(any())).thenAnswer((_) async => '');
      when(() => core.compileRuleSet(any(), url: any(named: 'url'))).thenAnswer(
        (invocation) async {
          compiledUrls.add(invocation.namedArguments[#url] as String);
          return (
            behavior: RuleProviderBehavior.classical,
            format: RuleProviderFormat.text,
          );
        },
      );
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([custom])),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      globalState.container = container;
      container
        ..listen(customProxiesProvider, (_, _) {})
        ..listen(clashProvidersProvider, (_, _) {})
        ..listen(proxyGroupsProvider(profileId), (_, _) {})
        ..listen(profileRulesProvider(profileId), (_, _) {})
        ..listen(proxyDialersProvider(profileId), (_, _) {});
      await pumpEventQueue();
    });

    tearDown(() async {
      container.dispose();
      await testDatabase.close();
      home.deleteSync(recursive: true);
    });

    test('replaces the profile and adds what it brings to the app', () async {
      final action = container.read(profilesActionProvider.notifier);
      final config = await action.readCustomImport(
        profileId,
        utf8.encode('''
proxy-providers:
  local: {type: file, path: ./local.yaml}
rule-providers:
  ads: {type: http, url: https://example.com/ads.txt}
proxies:
  - {name: SG, type: ss, server: sg.example.com, dialer-proxy: HK}
proxy-groups:
  - {name: Proxy, type: select, proxies: [SG, HK], use: [local]}
rules:
  - RULE-SET,ads,REJECT
  - MATCH,Proxy
dns:
  enable: true
'''),
      );

      await action.importCustomProfile(profileId, config);
      await pumpEventQueue();

      final local = container
          .read(profilesProvider)
          .singleWhere((profile) => profile.label == 'local');
      expect(local.type, ProfileType.file);
      expect(local.lastUpdateDate, isNotNull);
      expect(await (await local.file).readAsString(), isEmpty);
      expect(
        [
          for (final provider
              in await testDatabase.clashProvidersDao.query().get())
            (provider.label, provider.url),
        ],
        [('ads', 'https://example.com/ads.txt')],
      );
      expect(compiledUrls, ['https://example.com/ads.txt']);
      final proxies = await testDatabase.customProxiesDao.query().get();
      expect([for (final proxy in proxies) proxy.name], ['HK', 'SG']);
      final groups = await testDatabase.proxyGroupsDao.query(profileId).get();
      expect([for (final group in groups) group.name], ['Proxy']);
      expect(groups.single.proxies, ['SG', 'HK']);
      expect(groups.single.use, ['local']);
      expect(
        [
          for (final rule
              in await testDatabase.rulesDao.queryProfileRules(profileId).get())
            rule.rawValue,
        ],
        ['RULE-SET,ads,REJECT', 'MATCH,Proxy'],
      );
      expect(await testDatabase.proxyDialersDao.query(profileId).get(), [
        ProxyDialer(
          profileId: profileId,
          proxyId: proxies.last.id,
          target: 'HK',
        ),
      ]);
      expect(
        container.read(profileProvider(profileId))?.overrides.dnsOverrideKeys,
        {DnsOverrideKey.enable},
      );
    });

    test('takes an app proxy carrying a dialer for the same proxy and gives '
        'the dialer to the profile', () async {
      await testDatabase.customProxies.put(
        hongKong
            .copyWith(
              definition: {...hongKong.definition, 'dialer-proxy': 'Old'},
            )
            .toCompanion('a0'),
      );
      await pumpEventQueue();
      final action = container.read(profilesActionProvider.notifier);
      final config = await action.readCustomImport(
        profileId,
        utf8.encode('''
proxies:
  - {name: Hong Kong, type: ss, server: hk.example.com, dialer-proxy: Relay}
proxy-groups:
  - {name: Relay, type: select, proxies: [DIRECT]}
  - {name: Proxy, type: select, proxies: [Hong Kong]}
'''),
      );

      await action.importCustomProfile(profileId, config);
      await pumpEventQueue();

      expect(
        [
          for (final proxy in await testDatabase.customProxiesDao.query().get())
            proxy.id,
        ],
        [hongKong.id],
      );
      expect(await testDatabase.proxyDialersDao.query(profileId).get(), [
        ProxyDialer(
          profileId: profileId,
          proxyId: hongKong.id,
          target: 'Relay',
        ),
      ]);
    });

    test('reports what it cannot read in the app language', () async {
      final action = container.read(profilesActionProvider.notifier);

      await expectLater(
        action.readCustomImport(
          profileId,
          utf8.encode('rules:\n  - UNKNOWN,a,DIRECT\n'),
        ),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.failedItem(
              'UNKNOWN,a,DIRECT',
              currentAppLocalizations.ruleTextInvalid,
            ),
          ),
        ),
      );
      await expectLater(
        action.readCustomImport(profileId, utf8.encode('name: value\n')),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.importConfigInvalid,
          ),
        ),
      );
    });
  });
}
