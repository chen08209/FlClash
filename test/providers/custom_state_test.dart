import 'dart:async';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_profiles.dart';

class _TestClashProviders extends ClashProviders {
  final List<ClashProvider> initial;

  _TestClashProviders(this.initial);

  @override
  Stream<List<ClashProvider>> build() => Stream.value(initial);
}

class _TestCustomProxies extends CustomProxies {
  final Stream<List<CustomProxy>> proxies;

  _TestCustomProxies([List<CustomProxy> initial = const []])
    : proxies = Stream.value(initial);

  _TestCustomProxies.pending(Future<List<CustomProxy>> initial)
    : proxies = Stream.fromFuture(initial);

  @override
  Stream<List<CustomProxy>> build() => proxies;
}

class _TestProxyDialers extends ProxyDialers {
  final Map<int, String> initial;

  _TestProxyDialers([this.initial = const {}]);

  @override
  Stream<Map<int, String>> build(int profileId) => Stream.value(initial);
}

class _TestProfileRules extends ProfileRules {
  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(const []);
}

class _TestProxyGroups extends ProxyGroups {
  final Stream<List<ProxyGroup>> groups;

  _TestProxyGroups(List<ProxyGroup> initial) : groups = Stream.value(initial);

  _TestProxyGroups.pending(Future<List<ProxyGroup>> initial)
    : groups = Stream.fromFuture(initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => groups;

  @override
  void order(int oldIndex, int newIndex) {}
}

const profileId = 1;

Set<int> _invalidGroupIds(ProviderContainer container) => container
    .read(customProfileIssuesProvider(profileId))
    .proxyGroups
    .keys
    .toSet();

Future<void> _loadSources(ProviderContainer container) async {
  await container.read(proxyGroupsProvider(profileId).future);
  await container.read(customProxiesProvider.future);
  await container.read(proxyDialersProvider(profileId).future);
  await container.read(clashProvidersProvider.future);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const proxyGroup = ProxyGroup(
    id: 7,
    profileId: profileId,
    name: 'Group',
    type: GroupType.Selector,
    proxies: ['Known'],
    use: ['provider'],
  );

  test('validity stays quiet until the groups load', () async {
    final groups = Completer<List<ProxyGroup>>();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
        customProxiesProvider.overrideWith(_TestCustomProxies.new),
        proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups.pending(groups.future),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customProfileDataProvider(profileId), (_, _) {});

    expect(container.read(customProfileDataProvider(profileId)), isNull);
    expect(_invalidGroupIds(container), isEmpty);
    expect(
      container.read(customProfileTargetIsValidProvider(profileId, 'Gone')),
      true,
    );

    groups.complete([proxyGroup]);
    await _loadSources(container);

    expect(container.read(customProfileDataProvider(profileId)), isNotNull);
    expect(_invalidGroupIds(container), {7});
    expect(
      container.read(customProfileTargetIsValidProvider(profileId, 'Group')),
      true,
    );
    expect(
      container.read(customProfileTargetIsValidProvider(profileId, 'Gone')),
      false,
    );
  });

  test('validity stays quiet until the app proxies load', () async {
    final proxies = Completer<List<CustomProxy>>();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
        customProxiesProvider.overrideWith(
          () => _TestCustomProxies.pending(proxies.future),
        ),
        proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups([proxyGroup.copyWith(use: null)]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customProfileDataProvider(profileId), (_, _) {});
    await container.read(proxyGroupsProvider(profileId).future);
    await container.read(clashProvidersProvider.future);

    expect(container.read(customProfileDataProvider(profileId)), isNull);
    expect(_invalidGroupIds(container), isEmpty);

    proxies.complete([
      const CustomProxy(id: 1, definition: {'name': 'Known', 'type': 'socks5'}),
    ]);
    await container.read(customProxiesProvider.future);

    expect(container.read(customProfileDataProvider(profileId)), isNotNull);
    expect(_invalidGroupIds(container), isEmpty);
  });

  test('an app proxy is a valid member and a subscription profile a valid '
      'provider, a custom profile is neither', () async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            Profile.normal(label: 'Subscription'),
            Profile.custom(label: 'Mine'),
          ]),
        ),
        clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
        customProxiesProvider.overrideWith(
          () => _TestCustomProxies([
            const CustomProxy(
              id: 1,
              definition: {'name': 'Home', 'type': 'socks5'},
            ),
          ]),
        ),
        proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups([
            proxyGroup.copyWith(proxies: ['Home'], use: ['Subscription']),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customProfileDataProvider(profileId), (_, _) {});
    await container.read(proxyGroupsProvider(profileId).future);
    await container.read(clashProvidersProvider.future);
    await container.read(customProxiesProvider.future);

    expect(_invalidGroupIds(container), isEmpty);
    expect(
      container.read(
        customProfileProxyProviderIsValidProvider(profileId, 'Home'),
      ),
      false,
    );
    expect(
      proxyGroupIssues(
        proxyGroup.copyWith(proxies: ['Mine']),
        container.read(customProfileDataProvider(profileId))!,
      ),
      [
        const CustomIssue.missingProxies(['Mine']),
        const CustomIssue.missingProviders(['provider']),
      ],
    );
    expect(
      proxyGroupIssues(
        proxyGroup.copyWith(proxies: null, use: ['Subscription']),
        container.read(customProfileDataProvider(profileId))!,
      ),
      isEmpty,
    );
    expect(
      proxyGroupIssues(
        proxyGroup.copyWith(proxies: null, use: ['Mine']),
        container.read(customProfileDataProvider(profileId))!,
      ),
      [
        const CustomIssue.missingProviders(['Mine']),
      ],
    );
    expect(
      container.read(appProviderNamesProvider(ProviderKind.rule)),
      isEmpty,
    );
  });

  test('the app proxies report the names they share', () async {
    CustomProxy proxy(int id, String name) =>
        CustomProxy(id: id, definition: {'name': name, 'type': 'socks5'});
    final container = ProviderContainer(
      overrides: [
        customProxiesProvider.overrideWith(
          () => _TestCustomProxies([
            proxy(1, 'Same'),
            proxy(2, 'Same'),
            proxy(3, 'Other'),
            proxy(4, 'Group'),
          ]),
        ),
        customProxyCoreErrorsProvider.overrideWith((_) async => {}),
        customGroupNamesProvider.overrideWith(
          (_) => Stream.value(const {'Group'}),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customProxyListIssuesProvider, (_, _) {});
    await container.read(customProxiesProvider.future);
    await container.read(customProxyCoreErrorsProvider.future);
    await container.read(customGroupNamesProvider.future);

    expect(container.read(customProxyListIssuesProvider).keys, {1, 2, 4});
  });

  test(
    'loaded groups report the groups that reference missing names',
    () async {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
          customProxiesProvider.overrideWith(_TestCustomProxies.new),
          proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
          proxyGroupsProvider.overrideWith2(
            (_) => _TestProxyGroups([proxyGroup]),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(customProfileDataProvider(profileId), (_, _) {});
      await _loadSources(container);

      expect(container.read(customProfileDataProvider(profileId)), isNotNull);
      expect(_invalidGroupIds(container), {7});
      expect(
        container.read(
          customProfileProxyProviderIsValidProvider(profileId, 'provider'),
        ),
        false,
      );
    },
  );

  test('DNS servers and the NTP dialer name a proxy the profile has, while '
      'their sections are on', () async {
    const overrides = ProfileOverrides(
      dns: Dns(
        nameserver: ['1.1.1.1#Group', '8.8.8.8#Gone'],
        nameserverPolicy: {'+.lan': '1.1.1.1#DIRECT, 9.9.9.9#Away'},
      ),
      dnsOverrideKeys: {
        DnsOverrideKey.nameserver,
        DnsOverrideKey.nameserverPolicy,
      },
      ntp: Ntp(enable: true, dialerProxy: 'Gone'),
      ntpOverrideKeys: {NtpOverrideKey.enable, NtpOverrideKey.dialerProxy},
    );
    ProviderContainer containerFor(ProfileOverrides overrides) {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(
            () => TestProfiles([
              Profile(
                id: profileId,
                type: ProfileType.custom,
                autoUpdateDuration: Duration.zero,
                overrides: overrides,
              ),
            ]),
          ),
          clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
          customProxiesProvider.overrideWith(_TestCustomProxies.new),
          proxyDialersProvider.overrideWith2((_) => _TestProxyDialers()),
          proxyGroupsProvider.overrideWith2(
            (_) => _TestProxyGroups([proxyGroup]),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(customProfileIssuesProvider(profileId), (_, _) {});
      return container;
    }

    var container = containerFor(overrides);
    await _loadSources(container);
    var issues = container.read(customProfileIssuesProvider(profileId));
    expect(issues.dns, [
      const CustomIssue.missingProxies(['Gone', 'Away']),
    ]);
    expect(issues.ntp, [const CustomIssue.missingDialer('Gone')]);

    container = containerFor(
      overrides.copyWith(
        dns: overrides.dns.copyWith(enable: false),
        dnsOverrideKeys: {...overrides.dnsOverrideKeys, DnsOverrideKey.enable},
        ntp: overrides.ntp.copyWith(enable: false),
      ),
    );
    await _loadSources(container);
    issues = container.read(customProfileIssuesProvider(profileId));
    expect(issues.dns, isEmpty);
    expect(issues.ntp, isEmpty);
  });

  test('dialers resolve per profile and count only for the app proxies a group '
      'names', () async {
    CustomProxy proxy(int id, String name) =>
        CustomProxy(id: id, definition: {'name': name, 'type': 'ss'});
    const landing = ProxyGroup(
      id: 7,
      profileId: profileId,
      name: 'Landing',
      type: GroupType.Selector,
      proxies: ['Home', 'Work', 'Loop'],
    );
    const relay = ProxyGroup(
      id: 8,
      profileId: profileId,
      name: 'Relay',
      type: GroupType.Selector,
      proxies: ['DIRECT'],
    );
    Future<ProviderContainer> build(List<ProxyGroup> groups) async {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          clashProvidersProvider.overrideWith(() => _TestClashProviders([])),
          profileRulesProvider.overrideWith2((_) => _TestProfileRules()),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(groups)),
          customProxiesProvider.overrideWith(
            () => _TestCustomProxies([
              proxy(1, 'Home'),
              proxy(2, 'Work'),
              proxy(3, 'Loop'),
            ]),
          ),
          proxyDialersProvider.overrideWith2(
            (_) => _TestProxyDialers({1: 'Gone', 2: 'Relay', 3: 'Landing'}),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(customProfileIssuesProvider(profileId), (_, _) {});
      await _loadSources(container);
      return container;
    }

    final using = await build([landing, relay]);

    expect(using.read(customProfileDataProvider(profileId))!.dialers, {
      'Home': 'Gone',
      'Work': 'Relay',
      'Loop': 'Landing',
    });
    expect(using.read(customProfileIssuesProvider(profileId)).dialers, {
      1: [const CustomIssue.missingDialer('Gone')],
      3: [const CustomIssue.dialerLoop('Loop', 'Landing')],
    });

    final unused = await build([
      landing.copyWith(proxies: ['DIRECT']),
      relay,
    ]);

    expect(
      unused.read(customProfileIssuesProvider(profileId)).dialers,
      isEmpty,
    );
  });

  group('dialers', () {
    const landing = ProxyGroup(
      id: 3,
      name: 'Landing',
      type: GroupType.Selector,
      proxies: ['Home'],
    );
    const relay = ProxyGroup(
      id: 4,
      name: 'Relay',
      type: GroupType.Selector,
      proxies: ['Node'],
    );
    const outer = ProxyGroup(
      id: 5,
      name: 'Outer',
      type: GroupType.Selector,
      proxies: ['Relay', 'Landing'],
    );
    const home = CustomProxy(id: 9, definition: {'name': 'Home', 'type': 'ss'});
    const profileData = CustomProfileData(
      proxyGroups: [landing, relay],
      ruleTargets: {'DIRECT', 'Node', 'Landing', 'Relay'},
      proxies: {'Home', 'Work', 'Loop'},
      dialers: {'Home': 'Relay'},
    );

    test('a dial loops only through groups that reach the proxy', () {
      const groups = [landing, relay, outer];
      Set<String> loop(String target) =>
          dialerLoop(target, groups, proxy: 'Home');
      expect(loop('Relay'), isEmpty);
      expect(loop('Node'), isEmpty);
      expect(loop('Landing'), {'Landing'});
      expect(loop('Outer'), {'Outer', 'Landing'});
      expect(dialerLoop('Landing', groups, proxy: 'Work'), isEmpty);
    });

    test('a dial loops through the dialers of the proxies on its way', () {
      const groups = [
        ProxyGroup(
          id: 6,
          name: 'Exit',
          type: GroupType.Selector,
          proxies: ['Home', 'Work', 'Edge'],
        ),
      ];
      Set<String> loop(String target, Map<String, String> dialers) =>
          dialerLoop(target, groups, proxy: 'Home', dialers: dialers);
      expect(loop('Home', const {}), {'Home'});
      expect(loop('Work', const {'Work': 'Edge'}), isEmpty);
      expect(loop('Work', const {'Work': 'Home'}), {'Work'});
      expect(loop('Work', const {'Work': 'Edge', 'Edge': 'Exit'}), {
        'Work',
        'Edge',
        'Exit',
      });
      expect(
        loop('Work', const {'Work': 'Home', 'Home': 'Edge', 'Gone': 'Home'}),
        {'Work'},
      );
      expect(loop('Work', const {'Work': 'Away', 'Away': 'Home'}), isEmpty);
    });

    test('include-all-proxies takes in only the proxies a group declares', () {
      const all = ProxyGroup(
        id: 6,
        name: 'All',
        type: GroupType.Selector,
        includeAllProxies: true,
      );
      const exit = ProxyGroup(
        id: 7,
        name: 'Exit',
        type: GroupType.Selector,
        proxies: ['Work'],
      );
      expect(dialerLoop('All', [all], proxy: 'Home'), isEmpty);
      expect(dialerLoop('All', [all, landing], proxy: 'Home'), {'All'});
      expect(
        dialerLoop('Relay', [all, landing, relay], proxy: 'Home'),
        isEmpty,
      );
      expect(
        dialerLoop(
          'Exit',
          [exit, all, landing],
          proxy: 'Home',
          dialers: const {'Work': 'All'},
        ),
        {'Exit', 'Work', 'All'},
      );
    });

    test('what a filter picks is left to the core', () {
      const all = ProxyGroup(
        id: 6,
        name: 'All',
        type: GroupType.Selector,
        includeAllProxies: true,
      );
      for (final group in [
        all.copyWith(filter: '(?i)hk'),
        all.copyWith(excludeFilter: 'Home'),
        all.copyWith(excludeType: 'Shadowsocks'),
      ]) {
        expect(dialerLoop('All', [group, landing], proxy: 'Home'), isEmpty);
      }
      expect(
        dialerLoop('Landing', [
          landing.copyWith(excludeFilter: 'Home'),
        ], proxy: 'Home'),
        {'Landing'},
      );
    });

    test('a dialer must exist and must not lead back', () {
      expect(proxyDialerIssues(home, 'Relay', profileData), isEmpty);
      expect(
        proxyDialerIssues(
          home,
          'Work',
          profileData.copyWith(
            proxyGroups: [
              landing.copyWith(proxies: ['Home', 'Work']),
            ],
          ),
        ),
        isEmpty,
      );
      expect(proxyDialerIssues(home, 'Work', profileData), [
        const CustomIssue.missingDialer('Work'),
      ]);
      expect(proxyDialerIssues(home, 'Gone', profileData), [
        const CustomIssue.missingDialer('Gone'),
      ]);
      expect(proxyDialerIssues(home, 'Landing', profileData), [
        const CustomIssue.dialerLoop('Home', 'Landing'),
      ]);
    });

    test('a group edit that closes a dialer loop is flagged on the group', () {
      expect(proxyGroupIssues(relay, profileData), isEmpty);
      expect(
        proxyGroupIssues(
          relay.copyWith(proxies: ['Node', 'Landing']),
          profileData,
        ),
        [const CustomIssue.dialerLoop('Home', 'Relay')],
      );
    });

    test('groups sharing a name each loop through their own members', () {
      const looping = ProxyGroup(
        id: 6,
        name: 'Twin',
        type: GroupType.Selector,
        proxies: ['Home'],
      );
      const plain = ProxyGroup(
        id: 7,
        name: 'Twin',
        type: GroupType.Selector,
        proxies: ['DIRECT'],
      );
      final data = profileData.copyWith(
        proxyGroups: [looping, plain],
        dialers: {'Home': 'Twin'},
      );
      const issue = CustomIssue.dialerLoop('Home', 'Twin');
      expect(proxyGroupIssues(looping, data), contains(issue));
      expect(proxyGroupIssues(plain, data), isNot(contains(issue)));
    });

    test('the payload declares the named proxies with the profile dialers only '
        'and drops a looping one', () {
      const work = CustomProxy(
        id: 10,
        definition: {'name': 'Work', 'type': 'ss', 'dialer-proxy': 'Node'},
      );
      const unnamed = CustomProxy(
        id: 12,
        definition: {'name': 'Unnamed', 'type': 'ss'},
      );
      final payload = appProxiesPayload(
        [home, work, unnamed],
        dialers: {9: 'Landing'},
        groups: [
          landing.copyWith(proxies: ['Home', 'Work']),
          relay,
        ],
      );
      expect(payload, [
        home.definition,
        {'name': 'Work', 'type': 'ss'},
      ]);
      expect(
        appProxiesPayload(
          [home, work],
          dialers: {9: 'Work', 10: 'Home'},
          groups: [
            landing.copyWith(proxies: ['Home', 'Work']),
          ],
        ),
        [
          home.definition,
          {'name': 'Work', 'type': 'ss'},
        ],
      );
      expect(
        appProxiesPayload(
          [home],
          dialers: {9: 'Relay'},
          groups: const [landing, relay],
        ),
        [
          {'name': 'Home', 'type': 'ss', 'dialer-proxy': 'Relay'},
        ],
      );
    });

    test('include-all-proxies declares no app proxy of its own and drops a '
        'dialer it loops back through', () {
      const unnamed = CustomProxy(
        id: 12,
        definition: {'name': 'Unnamed', 'type': 'ss'},
      );
      const all = ProxyGroup(
        id: 6,
        name: 'All',
        type: GroupType.Selector,
        includeAllProxies: true,
      );
      expect(
        appProxiesPayload(
          [home, unnamed],
          dialers: {9: 'All', 12: 'Relay'},
          groups: const [all, landing],
        ),
        [home.definition],
      );
      expect(
        const CustomProfileData(
          proxyGroups: [all, landing],
          proxies: {'Home', 'Unnamed'},
        ).namedProxies,
        {'Home'},
      );
    });
  });

  group('issues', () {
    const profileData = CustomProfileData(
      proxyGroups: [
        ProxyGroup(id: 1, name: 'A', type: GroupType.Selector, proxies: ['B']),
        ProxyGroup(id: 2, name: 'B', type: GroupType.Selector, proxies: ['A']),
      ],
      ruleTargets: {'DIRECT', 'REJECT', 'Node', 'A', 'B'},
    );

    test('a group that reaches itself names the loop', () {
      expect(proxyGroupIssues(profileData.proxyGroups.first, profileData), [
        const CustomIssue.groupLoop(['A', 'B', 'A']),
      ]);
    });

    test('a group without members or providers is refused', () {
      const group = ProxyGroup(id: 3, name: 'C', type: GroupType.Selector);
      expect(proxyGroupIssues(group, profileData), [
        const CustomIssue.noProxySource(),
      ]);
      expect(
        proxyGroupIssues(group.copyWith(includeAllProxies: true), profileData),
        isEmpty,
      );
      final providers = group.copyWith(includeAllProviders: true);
      final subscribed = profileData.copyWith(proxyProviders: const {'Sub'});
      expect(proxyGroupIssues(providers, subscribed), [
        const CustomIssue.noProxySource(),
      ]);
      expect(
        proxyGroupIssues(
          providers,
          subscribed.copyWith(
            proxyGroups: [
              ...subscribed.proxyGroups,
              const ProxyGroup(
                id: 4,
                name: 'D',
                type: GroupType.Selector,
                use: ['Sub'],
              ),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('a group cannot take a local proxy\'s name, named here or not', () {
      const data = CustomProfileData(
        ruleTargets: {'DIRECT'},
        proxies: {'Home'},
      );
      const group = ProxyGroup(
        id: 3,
        name: 'Home',
        type: GroupType.Selector,
        proxies: ['DIRECT'],
      );
      expect(proxyGroupIssues(group, data), [
        const CustomIssue.duplicateName('Home'),
      ]);
      expect(proxyGroupIssues(group.copyWith(name: 'Away'), data), isEmpty);
    });

    test('a group cannot take another group\'s or a built-in name', () {
      const group = ProxyGroup(
        id: 3,
        name: 'A',
        type: GroupType.Selector,
        proxies: ['DIRECT', 'Gone'],
      );
      expect(proxyGroupIssues(group, profileData), [
        const CustomIssue.duplicateName('A'),
        const CustomIssue.missingProxies(['Gone']),
      ]);
      expect(
        proxyGroupIssues(group.copyWith(name: 'DIRECT'), profileData).first,
        const CustomIssue.reservedName('DIRECT'),
      );
    });

    test('empty-fallback takes a built-in or a proxy a group names', () {
      const group = ProxyGroup(
        id: 3,
        name: 'C',
        type: GroupType.Selector,
        proxies: ['Node'],
      );
      final data = profileData.copyWith(
        proxyGroups: [
          ...profileData.proxyGroups,
          group.copyWith(id: 4, name: 'D', proxies: ['Home']),
        ],
        proxies: const {'Home', 'Spare'},
      );
      for (final name in ['COMPATIBLE', 'PASS', 'Home']) {
        expect(
          proxyGroupIssues(group.copyWith(emptyFallback: name), data),
          isEmpty,
          reason: name,
        );
      }
      for (final name in ['A', 'Node', 'Gone', 'Spare']) {
        expect(proxyGroupIssues(group.copyWith(emptyFallback: name), data), [
          CustomIssue.invalidEmptyFallback(name),
        ], reason: name);
      }
    });

    test('a logic rule needs every rule set it nests', () {
      final data = profileData.copyWith(ruleProviders: const {'Ads'});
      final rule = Rule.parse(
        'OR,((RULE-SET,Ads),(AND,((RULE-SET,Gone),(NETWORK,UDP)))),DIRECT',
        id: 1,
      );
      expect(customRuleIssues(rule, data), [
        const CustomIssue.missingRuleSet('Gone'),
      ]);
      expect(
        customRuleIssues(rule, data.copyWith(ruleProviders: {'Ads', 'Gone'})),
        isEmpty,
      );
    });

    test('a SUB-RULE has no sub-rules to point at', () {
      expect(
        customRuleIssues(
          Rule.parse('SUB-RULE,(NETWORK,tcp),nested', id: 1),
          profileData,
        ),
        [const CustomIssue.missingSubRule('nested')],
      );
    });

    test('a rule may target a local proxy once a group declares it', () {
      const data = CustomProfileData(
        proxyGroups: [
          ProxyGroup(
            id: 1,
            name: 'G',
            type: GroupType.Selector,
            proxies: ['Home'],
          ),
        ],
        ruleTargets: {'DIRECT', 'G'},
        proxies: {'Home', 'Spare'},
      );
      expect(customRuleIssues(Rule.parse('MATCH,Home', id: 1), data), isEmpty);
      expect(customRuleIssues(Rule.parse('MATCH,Spare', id: 2), data), [
        const CustomIssue.missingTarget('Spare'),
      ]);
    });

    test('a proxy cannot take GLOBAL, which a group may', () {
      const proxy = CustomProxy(id: 1, definition: {'name': 'GLOBAL'});
      expect(
        customProxyIssues(proxy, proxies: const [proxy], groupNames: const {}),
        [const CustomIssue.reservedName('GLOBAL')],
      );
      const group = ProxyGroup(
        id: 3,
        name: 'GLOBAL',
        type: GroupType.Selector,
        proxies: ['DIRECT'],
      );
      expect(proxyGroupIssues(group, profileData), isEmpty);
    });

    test('a rule may target the GLOBAL the core adds, which a group may not '
        'hold', () {
      expect(
        customRuleIssues(Rule.parse('MATCH,GLOBAL', id: 1), profileData),
        isEmpty,
      );
      const group = ProxyGroup(
        id: 3,
        name: 'G',
        type: GroupType.Selector,
        proxies: ['GLOBAL'],
      );
      expect(proxyGroupIssues(group, profileData), [
        const CustomIssue.missingProxies(['GLOBAL']),
      ]);
    });

    test('a rule cannot target a name holding a comma', () {
      final data = profileData.copyWith(ruleTargets: {'DIRECT', 'A,B'});
      const rule = Rule(id: 1, ruleAction: RuleAction.MATCH, ruleTarget: 'A,B');
      expect(customRuleIssues(rule, data), [
        const CustomIssue.missingTarget('A,B'),
      ]);
    });

    test('custom proxies report names and core errors together', () {
      const first = CustomProxy(id: 1, definition: {'name': 'X'});
      const second = CustomProxy(id: 2, definition: {'name': 'X'});
      expect(
        customProxyIssues(
          first,
          proxies: const [first, second],
          groupNames: const {},
          coreError: 'missing type',
        ),
        [
          const CustomIssue.duplicateName('X'),
          const CustomIssue.coreRejected('missing type'),
        ],
      );
    });
  });

  test('customProxyTypes lists every type the core parses', () {
    final source = File('core/Clash.Meta/adapter/parser.go').readAsStringSync();
    expect(customProxyTypes, [
      for (final match in RegExp(
        r'^\tcase "([^"]+)":',
        multiLine: true,
      ).allMatches(source))
        match.group(1)!,
    ]);
  });

  group('proxy fields follow the option structs of the core', () {
    const root = 'core/Clash.Meta/adapter';
    final structs = {
      for (final file in Directory(
        '$root/outbound',
      ).listSync().whereType<File>())
        if (!file.path.endsWith('_test.go'))
          for (final match in RegExp(
            r'^type (\w+) struct \{\n([\s\S]*?)\n\}',
            multiLine: true,
          ).allMatches(file.readAsStringSync()))
            match.group(1)!: match.group(2)!,
    };
    final keyPattern = RegExp(r'proxy:"([^",]+)(,omitempty)?"');
    final typePattern = RegExp(
      r'^\t\w+\s+(\S+)\s+`proxy:"([^",]+)',
      multiLine: true,
    );
    final embeddedPattern = RegExp(r'^\t(\w+Option)$', multiLine: true);
    final bodies = {
      for (final match in RegExp(
        r'^\tcase "([^"]+)":\n\t\t\w+ := &outbound\.(\w+)\{',
        multiLine: true,
      ).allMatches(File('$root/parser.go').readAsStringSync()))
        match.group(1)!: [
          structs[match.group(2)]!,
          for (final embedded in embeddedPattern.allMatches(
            structs[match.group(2)]!,
          ))
            if (embedded.group(1) != 'BasicOption') structs[embedded.group(1)]!,
          structs['BasicOption']!,
        ].join('\n'),
    };
    Set<String> keysIn(String body, {bool required = false}) => {
      for (final match in keyPattern.allMatches(body))
        if (match.group(1) != '-' && (!required || match.group(2) == null))
          match.group(1)!,
    };
    Set<String> keysOf(String type, {bool required = false}) =>
        keysIn(bodies[type]!, required: required);

    test('every type the core parses has its struct', () {
      expect(bodies.keys, customProxyTypes);
    });

    test('a plugin offers only the plugin-opts keys it reads', () {
      List<ProxyField> optionsOf(String plugin) => CustomProxy(
        id: 0,
        definition: {'type': 'ss', 'plugin': plugin},
      ).options;
      expect(optionsOf('kcptun'), contains(ProxyField.pluginMode));
      expect(optionsOf('kcptun'), isNot(contains(ProxyField.pluginHost)));
      expect(optionsOf('shadow-tls'), contains(ProxyField.pluginHost));
      expect(optionsOf('shadow-tls'), isNot(contains(ProxyField.pluginMode)));
    });

    test('the form asks for the credentials each struct reads', () {
      const credentials = {'username', 'password', 'uuid'};
      for (final type in customProxyTypes) {
        expect(
          {
            for (final field in CustomProxy(
              id: 0,
              definition: {'type': type},
            ).credentials)
              field.path.single,
          },
          keysOf(type).intersection(credentials),
          reason: type,
        );
      }
    });

    test('the required keys are the ones each struct requires', () {
      for (final type in customProxyTypes) {
        expect(
          CustomProxy(id: 0, definition: {'type': type}).requiredKeys,
          keysOf(type, required: true).difference({'name'}),
          reason: type,
        );
      }
    });

    test('the form always shows every key a struct requires', () {
      // A PEM block does not fit a form row, and the form has no row for a
      // zerotier network yet.
      const notInForm = {
        'openvpn': {'ca'},
        'zerotier': {'network'},
      };
      for (final type in customProxyTypes) {
        final proxy = CustomProxy(id: 0, definition: {'type': type});
        expect(
          {for (final field in proxy.fields) field.path.single},
          containsAll(
            proxy.requiredKeys.difference({
              'server',
              'port',
              ...?notInForm[type],
            }),
          ),
          reason: type,
        );
      }
    });

    test('every field and option is a key its struct reads', () {
      for (final type in customProxyTypes) {
        final definitions = [
          {'type': type, 'plugin': 'obfs', 'obfs': 'salamander'},
          for (final network in CustomProxy(
            id: 0,
            definition: {'type': type},
          ).choicesOf(ProxyField.network))
            {'type': type, 'network': network},
        ];
        for (final definition in definitions) {
          final proxy = CustomProxy(id: 0, definition: definition);
          for (final field in [...proxy.fields, ...proxy.options]) {
            var body = bodies[type]!;
            for (final key in field.path) {
              expect(keysIn(body), contains(key), reason: '$type $field');
              final nested =
                  structs[[
                    for (final match in typePattern.allMatches(body))
                      if (match.group(2) == key) match.group(1)!,
                  ].first];
              if (nested == null) {
                break;
              }
              body = nested;
            }
            if (field.kind == ProxyFieldKind.choice) {
              expect(
                proxy.choicesOf(field),
                isNotEmpty,
                reason: '$type $field',
              );
            }
          }
        }
      }
    });

    test('every choice the form offers is a value the core names', () {
      final sources = [
        for (final directory in [
          'adapter',
          'component',
          'constant',
          'transport',
        ])
          for (final file in Directory(
            'core/Clash.Meta/$directory',
          ).listSync(recursive: true).whereType<File>())
            if (file.path.endsWith('.go') && !file.path.endsWith('_test.go'))
              file.readAsStringSync().toLowerCase(),
      ].join('\n');
      // These fields take their values from modules outside the submodule.
      const elsewhere = {
        'ss': {ProxyField.cipher},
        'vmess': {ProxyField.cipher},
        'hysteria2': {ProxyField.obfs},
      };
      for (final type in customProxyTypes) {
        final proxy = CustomProxy(id: 0, definition: {'type': type});
        for (final field in ProxyField.values) {
          if (elsewhere[type]?.contains(field) ?? false) {
            continue;
          }
          for (final choice in proxy.choicesOf(field)) {
            expect(
              sources,
              contains('"${choice.toLowerCase()}"'),
              reason: '$type $field $choice',
            );
          }
        }
      }
    });
  });

  test('a nested field adds and drops the maps that hold it, in any case the '
      'core reads', () {
    const proxy = CustomProxy(
      id: 0,
      definition: {'type': 'vless', 'network': 'ws'},
    );
    final withHost = proxy.withField(ProxyField.wsHost, 'cdn.example');

    expect(withHost.definition['ws-opts'], {
      'headers': {'Host': 'cdn.example'},
    });
    expect(withHost.valueOf(ProxyField.wsHost), 'cdn.example');
    expect(
      withHost.withField(ProxyField.wsHost, null).definition,
      proxy.definition,
    );

    const lower = CustomProxy(
      id: 0,
      definition: {
        'type': 'vless',
        'network': 'ws',
        'ws-opts': {
          'headers': {'host': 'a.example'},
        },
      },
    );
    expect(lower.valueOf(ProxyField.wsHost), 'a.example');
    expect(
      lower.withField(ProxyField.wsHost, 'b.example').definition['ws-opts'],
      {
        'headers': {'host': 'b.example'},
      },
    );
  });

  test('a changed value drops the options only the old one made available', () {
    const proxy = CustomProxy(
      id: 0,
      definition: {
        'type': 'vless',
        'network': 'ws',
        'ws-opts': {
          'path': '/a',
          'headers': {'Host': 'a.example'},
          'max-early-data': 2048,
        },
      },
    );

    expect(proxy.withField(ProxyField.network, 'grpc').definition, {
      'type': 'vless',
      'network': 'grpc',
      'ws-opts': {'max-early-data': 2048},
    });
    expect(
      const CustomProxy(
        id: 0,
        definition: {
          'type': 'hysteria2',
          'obfs': 'salamander',
          'obfs-password': 'pw',
        },
      ).withField(ProxyField.obfs, null).definition,
      {'type': 'hysteria2'},
    );
  });

  test('a new type keeps what it reads alike and starts from the values '
      'nearly every server takes', () {
    const proxy = CustomProxy(
      id: 0,
      definition: {
        'name': 'a',
        'type': 'ss',
        'cipher': 'aes-256-gcm',
        'password': 'pw',
        'udp-over-tcp': true,
      },
    );

    final vmess = proxy.withType('vmess');
    expect(vmess.definition, {
      'name': 'a',
      'type': 'vmess',
      'cipher': 'auto',
      'alterId': 0,
    });
    expect(vmess.definition.keys.first, 'name');
    expect(vmess.withType('ss').definition, {'name': 'a', 'type': 'ss'});
    expect(
      proxy
          .withField(ProxyField.cipher, 'aes-128-gcm')
          .withType('vmess')
          .definition['cipher'],
      'aes-128-gcm',
    );
    expect(proxy.withType('trojan').definition, {
      'name': 'a',
      'type': 'trojan',
      'password': 'pw',
    });
    expect(proxy.withType('ss'), same(proxy));
  });

  test('imported links take names no proxy holds yet', () {
    final proxies = importedCustomProxies(
      [
        {'name': 'Home', 'type': 'ss', 'server': 'a.example'},
        {'name': '', 'type': 'vless', 'server': 'b.example'},
        {'name': '-01', 'type': 'vless', 'server': 'b.example'},
        {'name': 'DIRECT', 'type': 'trojan', 'server': 'c.example'},
        {'name': 'GLOBAL', 'type': 'trojan', 'server': 'd.example'},
      ],
      existing: const [
        CustomProxy(id: 1, definition: {'name': 'Home', 'type': 'ss'}),
      ],
      groupNames: const {'b.example'},
    );

    expect(proxies.map((proxy) => proxy.name), [
      'Home-01',
      'b.example-01',
      'b.example-02',
      'DIRECT-01',
      'GLOBAL-01',
    ]);
    expect(proxies.map((proxy) => proxy.server), [
      'a.example',
      'b.example',
      'b.example',
      'c.example',
      'd.example',
    ]);
    expect(proxies.map((proxy) => proxy.id).toSet(), hasLength(5));
  });

  test('a link edit keeps what the old link could not carry', () {
    const previous = {
      'name': 'A',
      'type': 'vmess',
      'server': 'a',
      'udp': true,
      'tfo': true,
      'ws-opts': {'path': '/old', 'max-early-data': 2048},
    };
    const linked = {
      'name': 'A',
      'type': 'vmess',
      'server': 'a',
      'udp': true,
      'ws-opts': {'path': '/old'},
    };

    expect(
      withUnlinkedFields(
        const {
          'name': 'A',
          'type': 'vmess',
          'server': 'b',
          'ws-opts': {'path': '/new'},
        },
        previous: previous,
        linked: linked,
      ),
      {
        'name': 'A',
        'type': 'vmess',
        'server': 'b',
        'tfo': true,
        'ws-opts': {'path': '/new', 'max-early-data': 2048},
      },
    );
    expect(
      withUnlinkedFields(
        const {'name': 'A', 'type': 'trojan', 'server': 'b'},
        previous: previous,
        linked: linked,
      ),
      {'name': 'A', 'type': 'trojan', 'server': 'b'},
    );
  });

  group('share link edit', () {
    const a = CustomProxy(
      id: 1,
      definition: {'name': 'A', 'type': 'ss', 'server': 'a'},
    );
    const w = CustomProxy(
      id: 2,
      definition: {'name': 'W', 'type': 'wireguard'},
    );
    const b = CustomProxy(
      id: 3,
      definition: {'name': 'B', 'type': 'trojan', 'server': 'b'},
    );
    const previous = [a, w, b];
    const links = ['ss://a#A', '', 'trojan://b#B'];

    ShareLinkEdit read(String text) =>
        ShareLinkEdit.read(text, previous: previous, links: links);

    test('an untouched text keeps every proxy as it is', () {
      final edit = read(ShareLinkEdit.textOf(links));

      expect(ShareLinkEdit.textOf(links), 'ss://a#A\ntrojan://b#B');
      expect(edit.pending, isEmpty);
      expect(edit.apply(const {}, groupNames: const {}), previous);
    });

    test('edited lines land in text order, a proxy with no link after the '
        'proxy it followed', () {
      final edit = read('trojan://b#B\n\nss://a2#A\nss://c\ntrojan://b#B');

      expect(edit.pending.map((line) => line.line), [3, 4, 5]);
      final proxies = edit.apply(groupNames: const {}, {
        3: [
          {'name': 'A', 'type': 'ss', 'server': 'a2'},
        ],
        4: [
          {'name': '', 'type': 'ss', 'server': 'c'},
        ],
        5: [
          {'name': 'B', 'type': 'trojan', 'server': 'b'},
        ],
      });

      expect(proxies.map((proxy) => proxy.name), ['W', 'B', 'A', 'c', 'B-01']);
      expect(proxies.take(3).map((proxy) => proxy.id), [2, 3, 1]);
      expect(proxies[2].server, 'a2');
      expect(proxies.skip(3).map((proxy) => proxy.id), everyElement(isNot(1)));
    });

    test('a new line takes no group\'s name', () {
      final proxies = read('ss://a#A\ntrojan://b#B\nss://g#G').apply(
        {
          3: [
            {'name': 'G', 'type': 'ss', 'server': 'g'},
          ],
        },
        groupNames: const {'G'},
      );

      expect(proxies.map((proxy) => proxy.name), ['A', 'W', 'B', 'G-01']);
    });

    test('a replaced proxy keeps the options it listed without a value', () {
      final listed = CustomProxy(
        id: 1,
        definition: {...a.definition, 'udp-over-tcp': true},
        emptyOptions: const {ProxyField.plugin, ProxyField.udpOverTcp},
      );
      final edit = ShareLinkEdit.read(
        'ss://a2#A\ntrojan://b#B',
        previous: [listed, w, b],
        links: links,
      );
      expect(edit.droppedLinks, {1: 'ss://a#A'});
      final proxies = edit.apply(
        groupNames: const {},
        linked: {1: a.definition},
        {
          1: [
            {'name': 'A', 'type': 'ss', 'server': 'a2'},
          ],
        },
      );

      final replaced = proxies.singleWhere((proxy) => proxy.name == 'A');
      expect(replaced.id, 1);
      expect(replaced.definition, {
        'name': 'A',
        'type': 'ss',
        'server': 'a2',
        'udp-over-tcp': true,
      });
      expect(replaced.emptyOptions, {ProxyField.plugin});
    });

    test('a removed line drops its proxy and leaves the rest', () {
      expect(read('trojan://b#B').apply(const {}, groupNames: const {}), [
        w,
        b,
      ]);
    });
  });

  test('proxy providers are the subscription profiles and rule providers the '
      'app ones', () async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            Profile.normal(label: 'Home'),
            Profile.normal(label: 'Shared'),
            Profile.custom(label: 'Mine'),
          ]),
        ),
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(const [
            ClashProvider(
              id: 11,
              label: 'Home',
              behavior: RuleProviderBehavior.domain,
              format: RuleProviderFormat.text,
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    for (final kind in ProviderKind.values) {
      container.listen(appProviderNamesProvider(kind), (_, _) {});
    }
    await container.read(clashProvidersProvider.future);

    expect(container.read(appProviderNamesProvider(ProviderKind.proxy)), {
      'Home',
      'Shared',
    });
    expect(container.read(appProviderNamesProvider(ProviderKind.rule)), {
      'Home',
    });
  });
}
