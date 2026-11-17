import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

ProfileOverrides _dns(Dns dns, DnsOverrideKey key) =>
    ProfileOverrides(dns: dns, dnsOverrideKeys: {key});

/// A server dialing through a proxy named `x` in each list the core reads.
final _serverSites = {
  'cfg.NameServer': _dns(
    const Dns(nameserver: ['1.1.1.1#x']),
    DnsOverrideKey.nameserver,
  ),
  'cfg.Fallback': _dns(
    const Dns(fallback: ['1.1.1.1#x']),
    DnsOverrideKey.fallback,
  ),
  'cfg.ProxyServerNameserver': _dns(
    const Dns(proxyServerNameserver: ['1.1.1.1#x']),
    DnsOverrideKey.proxyServerNameserver,
  ),
  'cfg.DirectNameServer': _dns(
    const Dns(directNameserver: ['1.1.1.1#x']),
    DnsOverrideKey.directNameserver,
  ),
  'cfg.DefaultNameserver': _dns(
    const Dns(defaultNameserver: ['1.1.1.1#x']),
    DnsOverrideKey.defaultNameserver,
  ),
  'servers': _dns(
    const Dns(nameserverPolicy: {'+.example.com': '8.8.8.8, 1.1.1.1#x'}),
    DnsOverrideKey.nameserverPolicy,
  ),
};

void main() {
  group('DNS servers', () {
    test('name the last fragment part without a value, decoded, and a ts or '
        'et host', () {
      expect(dnsServerProxies('1.1.1.1'), isEmpty);
      expect(dnsServerProxies('tls://1.1.1.1#a&ecs=1.2.3.4/24&b'), ['b']);
      expect(dnsServerProxies('1.1.1.1#Proxy%201'), ['Proxy 1']);
      expect(dnsServerProxies('1.1.1.1#'), isEmpty);
      expect(dnsServerProxies('ts://Tail#Out'), ['Tail', 'Out']);
      expect(dnsServerProxies('EasyTier://net/path'), ['net']);
    });

    test('a renamed proxy is escaped where the app splits a policy', () {
      const overrides = ProfileOverrides(
        dns: Dns(nameserverPolicy: {'+.a.com': '1.1.1.1#Old, 8.8.8.8'}),
        dnsOverrideKeys: {DnsOverrideKey.nameserverPolicy},
      );
      final renamed = overrides.renamedProxies({'Old': 'New, Proxy;1'});

      expect(renamed.dns.nameserverPolicy, {
        '+.a.com': '1.1.1.1#New%2C%20Proxy%3B1, 8.8.8.8',
      });
      expect(renamed.dnsProxies, {'New, Proxy;1'});
      expect(renamed.renamedProxies({'New, Proxy;1': 'Old'}), overrides);
    });

    test('a server written to the profile but turned off names nothing', () {
      final overrides = _serverSites['cfg.NameServer']!;
      expect(overrides.copyWith(dnsOverrideKeys: {}).dnsProxies, isEmpty);
      expect(
        overrides.copyWith(ntpOverrideKeys: {}, ntp: const Ntp()).ntpProxy,
        isNull,
      );
    });
  });

  group('rule sets', () {
    test('a policy key with a comma lists sets up to a second colon, one '
        'without names its set whole', () {
      const overrides = ProfileOverrides(
        dns: Dns(
          nameserverPolicy: {
            'rule-set:a,b:c': '1.1.1.1',
            'rule-set:d:e': '1.1.1.1',
            'geosite:cn': '1.1.1.1',
          },
        ),
        dnsOverrideKeys: {DnsOverrideKey.nameserverPolicy},
      );

      expect(overrides.ruleSets, {'a', 'b', 'd:e'});
      expect(
        overrides.renamedRuleSets({'a': 'A', 'd:e': 'D'}).dns.nameserverPolicy,
        {
          'rule-set:A,b:c': '1.1.1.1',
          'rule-set:D': '1.1.1.1',
          'geosite:cn': '1.1.1.1',
        },
      );
    });

    test('fake-ip-filter reads rules in rule mode and renames either '
        'form', () {
      const overrides = ProfileOverrides(
        dns: Dns(
          fakeIpFilter: [
            'RULE-SET,a,fake-ip',
            'AND,((RULE-SET,b),(NETWORK,UDP)),real-ip',
            'rule-set:c',
            '+.example.com',
          ],
          fakeIpFilterMode: FakeIpFilterMode.rule,
        ),
        dnsOverrideKeys: {
          DnsOverrideKey.fakeIpFilter,
          DnsOverrideKey.fakeIpFilterMode,
        },
      );

      expect(overrides.ruleSets, {'a', 'b'});
      expect(
        overrides
            .copyWith(dnsOverrideKeys: {DnsOverrideKey.fakeIpFilter})
            .ruleSets,
        {'c'},
      );
      final renamed = overrides.renamedRuleSets({'a': 'A', 'b': 'B', 'c': 'C'});
      expect(renamed.dns.fakeIpFilter, [
        'RULE-SET,A,fake-ip',
        'AND,((RULE-SET,B),(NETWORK,UDP)),real-ip',
        'rule-set:C',
        '+.example.com',
      ]);
      expect(
        renamed.renamedRuleSets({'A': 'a', 'B': 'b', 'C': 'c'}),
        overrides,
      );
    });

    test('a nested set and a provider rename only the rule sets named', () {
      final rule = Rule.parse('OR,((RULE-SET,a),(RULE-SET,ab)),DIRECT', id: 1);
      expect(rule.ruleSets, ['a', 'ab']);
      expect(
        rule.renamedRuleSets({'a': 'z'}).content,
        '((RULE-SET,z),(RULE-SET,ab))',
      );
    });
  });

  test('a group renames members whatever their characters', () {
    const group = ProxyGroup(
      id: 1,
      name: 'Parent',
      type: GroupType.Selector,
      proxies: ['x', ',', 'say "hi"', r'back\slash'],
      defaultSelected: ',',
    );
    final names = {',': 'Z', 'say "hi"': 'Q"', r'back\slash': 'B'};

    final renamed = group.renamedProxies(names);
    expect(renamed.proxies, ['x', 'Z', 'Q"', 'B']);
    expect(renamed.defaultSelected, 'Z');
  });

  test('picks follow a rename only where the group lists the name', () {
    const profile = Profile(
      id: 1,
      label: 'Custom',
      autoUpdateDuration: Duration.zero,
      selectedMap: {'Auto': 'HK', 'Pool': 'HK', 'Old': 'US'},
      currentGroupName: 'Old',
      unfoldSet: {'Old', 'Auto'},
    );
    const members = {
      'Auto': ['HK', 'Old'],
      'Pool': <String>[],
      'Old': ['US'],
    };

    final proxy = profile.renamedPicks({'HK': 'HK2'}, members: members);
    expect(proxy.selectedMap, {'Auto': 'HK2', 'Pool': 'HK', 'Old': 'US'});
    expect(proxy.currentGroupName, 'Old');

    final group = profile
        .copyWith(selectedMap: {'Auto': 'Old', 'Old': 'US'})
        .renamedPicks({'Old': 'New'}, members: members, groups: true);
    expect(group.selectedMap, {'Auto': 'New', 'New': 'US'});
    expect(group.currentGroupName, 'New');
    expect(group.unfoldSet, {'New', 'Auto'});
  });

  test('a name is in use wherever one profile names it', () {
    Set<String> inUse({
      List<ProxyGroup> groups = const [],
      List<String> ruleTargets = const [],
      List<String> dialerTargets = const [],
      ProfileOverrides overrides = const ProfileOverrides(),
    }) => proxyNamesInUse(
      {'x', 'y'},
      groups: groups,
      ruleTargets: ruleTargets,
      dialerTargets: dialerTargets,
      overrides: overrides,
    );

    expect(inUse(), isEmpty);
    expect(
      inUse(
        groups: const [
          ProxyGroup(
            id: 1,
            name: 'G',
            type: GroupType.Selector,
            defaultSelected: 'y',
          ),
        ],
      ),
      {'y'},
    );
    expect(inUse(ruleTargets: ['x']), {'x'});
    expect(inUse(dialerTargets: ['y']), {'y'});
    expect(inUse(overrides: _serverSites['cfg.NameServer']!), {'x'});
  });
}
