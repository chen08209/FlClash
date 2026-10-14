import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

final _source = File('core/Clash.Meta/config/config.go').readAsStringSync();

List<String> _firstArguments(String function) => [
  for (final match in RegExp(
    '(?<!func )\\b$function\\(([^,]+),',
  ).allMatches(_source))
    match[1]!.trim(),
];

ProfileOverrides _dns(Dns dns, DnsOverrideKey key) =>
    ProfileOverrides(dns: dns, dnsOverrideKeys: {key});

ProfileOverrides _sniffer(Sniffer sniffer, SnifferOverrideKey key) =>
    ProfileOverrides(sniffer: sniffer, snifferOverrideKeys: {key});

/// A rule set named `x` in each place the core reads one from.
final _ruleSetSites = {
  'cfg.NameServerPolicy': _dns(
    const Dns(nameserverPolicy: {'rule-set:x': '1.1.1.1'}),
    DnsOverrideKey.nameserverPolicy,
  ),
  'cfg.ProxyServerNameserverPolicy': _dns(
    const Dns(proxyServerNameserverPolicy: {'RULE-SET:x': '1.1.1.1'}),
    DnsOverrideKey.proxyServerNameserverPolicy,
  ),
  'cfg.FakeIPFilter': _dns(
    const Dns(fakeIpFilter: ['rule-set:x']),
    DnsOverrideKey.fakeIpFilter,
  ),
  'snifferRaw.ForceDomain': _sniffer(
    const Sniffer(forceDomain: ['rule-set:x']),
    SnifferOverrideKey.forceDomain,
  ),
  'snifferRaw.SkipDomain': _sniffer(
    const Sniffer(skipDomain: ['rule-set:x']),
    SnifferOverrideKey.skipDomain,
  ),
  'snifferRaw.SkipSrcAddress': _sniffer(
    const Sniffer(skipSrcAddress: ['rule-set:x']),
    SnifferOverrideKey.skipSrcAddress,
  ),
  'snifferRaw.SkipDstAddress': _sniffer(
    const Sniffer(skipDstAddress: ['rule-set:x']),
    SnifferOverrideKey.skipDstAddress,
  ),
};

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
  group('the core reads names only where the references read them', () {
    test('every function taking the rule sets is one the sites cover', () {
      expect(
        {
          for (final match in RegExp(
            r'func (\w+)\([^)]*ruleProviders map\[string\]P\.RuleProvider',
          ).allMatches(_source))
            match[1]!,
        },
        {
          'parseSubRules',
          'parseRules',
          'parseNameServerPolicy',
          'parseDNS',
          'parseFakeIPRules',
          'parseSniffer',
          'parseIPCIDR',
          'parseDomain',
          'parseIPRuleSet',
          'parseDomainRuleSet',
        },
      );
    });

    test('each place a rule set is read from is one ruleSets reads', () {
      final sites = {
        for (final function in [
          'parseDomain',
          'parseIPCIDR',
          'parseNameServerPolicy',
          'parseFakeIPRules',
        ])
          ..._firstArguments(function),
      };
      expect(sites, _ruleSetSites.keys.toSet());
      // Rules carry their own RULE-SET names; sub-rules a custom profile
      // never writes.
      expect(_firstArguments('parseRules'), ['rawCfg.Rule', 'rawRules']);
      for (final MapEntry(key: site, value: overrides)
          in _ruleSetSites.entries) {
        expect(overrides.ruleSets, {'x'}, reason: site);
        expect(overrides.renamedRuleSets({'x': 'y'}).ruleSets, {
          'y',
        }, reason: site);
      }
    });

    test('each server list is one dnsProxies reads, and NTP the only other '
        'dialer a section names', () {
      expect(_firstArguments('parseNameServer').toSet(), {
        ..._serverSites.keys,
      });
      for (final MapEntry(key: site, value: overrides)
          in _serverSites.entries) {
        expect(overrides.dnsProxies, {'x'}, reason: site);
        expect(overrides.renamedProxies({'x': 'y'}).dnsProxies, {
          'y',
        }, reason: site);
      }
      expect(RegExp(r'DialerProxy\s+string').allMatches(_source), hasLength(2));
      const ntp = ProfileOverrides(
        ntp: Ntp(dialerProxy: 'x'),
        ntpOverrideKeys: {NtpOverrideKey.dialerProxy},
      );
      expect(ntp.ntpProxy, 'x');
      expect(ntp.renamedProxies({'x': 'y'}).ntpProxy, 'y');
    });
  });

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
