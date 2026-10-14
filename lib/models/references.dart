/// `test/models/references_test.dart` fails when the core reads a rule set or
/// proxy name somewhere this file does not.
library;

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

import 'clash_config.dart';
import 'profile.dart';

String _decodedOrSelf(String text) {
  try {
    return Uri.decodeComponent(text);
  } on ArgumentError {
    return text;
  } on FormatException {
    return text;
  }
}

const _proxyHostSchemes = {'ts', 'tailscale', 'et', 'easytier'};

(int, int)? _proxyHostRange(String head) {
  final separator = head.indexOf('://');
  if (separator <= 0 ||
      !_proxyHostSchemes.contains(head.substring(0, separator).toLowerCase())) {
    return null;
  }
  final start = separator + 3;
  final end = head.indexOf(RegExp('[/?]'), start);
  return (start, end < 0 ? head.length : end);
}

/// Mirrors mihomo's parseNameServer, which decodes the fragment before it
/// splits it: the last part without `=` names the proxy a server dials
/// through, and a ts or et server's host is a proxy.
List<String> dnsServerProxies(String server) {
  final hash = server.indexOf('#');
  final head = hash < 0 ? server : server.substring(0, hash);
  String? dialer;
  if (hash >= 0) {
    for (final part in _decodedOrSelf(server.substring(hash + 1)).split('&')) {
      if (!part.contains('=')) {
        dialer = part;
      }
    }
  }
  return [
    if (_proxyHostRange(head) case (final start, final end) when end > start)
      _decodedOrSelf(head.substring(start, end)),
    if (dialer != null && dialer.isNotEmpty) dialer,
  ];
}

/// The app splits a policy's servers on these and mihomo decodes them back.
/// It splits on `&` and `=` only after decoding, so no escape keeps those.
String _fragmentName(String name) => name
    .replaceAll('%', '%25')
    .replaceAll(' ', '%20')
    .replaceAll(',', '%2C')
    .replaceAll(';', '%3B');

String renamedDnsServer(String server, Map<String, String> names) {
  final hash = server.indexOf('#');
  var head = hash < 0 ? server : server.substring(0, hash);
  if (_proxyHostRange(head) case (final start, final end)) {
    if (names[_decodedOrSelf(head.substring(start, end))] case final name?) {
      head = head.replaceRange(start, end, name);
    }
  }
  if (hash < 0) {
    return head;
  }
  final parts = [
    for (final part in server.substring(hash + 1).split('&'))
      part.contains('=')
          ? part
          : switch (names[_decodedOrSelf(part)]) {
              final String name => _fragmentName(name),
              null => part,
            },
  ];
  return '$head#${parts.join('&')}';
}

List<String> _policyServers(String value) =>
    switch (value.splitByMultipleSeparators) {
      final List<String> parts => parts,
      _ => [value],
    };

String _renamedPolicyServers(String value, Map<String, String> names) {
  final servers = _policyServers(value);
  final renamed = [
    for (final server in servers) renamedDnsServer(server, names),
  ];
  return const ListEquality<String>().equals(servers, renamed)
      ? value
      : renamed.join(', ');
}

const _ruleSetPrefix = 'rule-set:';

/// mihomo reads `rule-set:a,b` up to a second colon, the prefix in any case,
/// except a policy key naming one set, which it takes whole.
(int, int)? _ruleSetRange(String entry, {bool policyKey = false}) {
  if (!entry.toLowerCase().startsWith(_ruleSetPrefix)) {
    return null;
  }
  const start = _ruleSetPrefix.length;
  if (policyKey && !entry.contains(',', start)) {
    return (start, entry.length);
  }
  final colon = entry.indexOf(':', start);
  return (start, colon < 0 ? entry.length : colon);
}

List<String> _ruleSetsIn(String entry, {bool policyKey = false}) =>
    switch (_ruleSetRange(entry, policyKey: policyKey)) {
      (final start, final end) => entry.substring(start, end).split(','),
      null => const [],
    };

String _renamedRuleSetsIn(
  String entry,
  Map<String, String> names, {
  bool policyKey = false,
}) {
  final range = _ruleSetRange(entry, policyKey: policyKey);
  if (range == null) {
    return entry;
  }
  final (start, end) = range;
  return entry.replaceRange(
    start,
    end,
    [
      for (final name in entry.substring(start, end).split(','))
        names[name] ?? name,
    ].join(','),
  );
}

final _nestedRuleSet = RegExp(
  r'(\(\s*RULE-SET\s*,\s*)([^,()]+?)(\s*[,)])',
  caseSensitive: false,
);

final _leadingRuleSet = RegExp(
  r'^(\s*RULE-SET\s*,\s*)([^,]+?)(\s*(?:,|$))',
  caseSensitive: false,
);

String _renamedRuleText(String text, Map<String, String> names) {
  String rename(Match match) =>
      '${match[1]}${names[match[2]] ?? match[2]}${match[3]}';
  return text
      .replaceFirstMapped(_leadingRuleSet, rename)
      .replaceAllMapped(_nestedRuleSet, rename);
}

extension RuleReferences on Rule {
  /// mihomo's ProviderNames: an undeclared one rejects the whole config.
  List<String> get ruleSets => switch (ruleAction) {
    RuleAction.RULE_SET => [?ruleProvider],
    _ when ruleAction.nestsRules => [
      for (final match in _nestedRuleSet.allMatches(content ?? '')) match[2]!,
    ],
    _ => const [],
  };

  Rule renamedRuleSets(Map<String, String> names) {
    final content = this.content;
    return switch (ruleAction) {
      RuleAction.RULE_SET => copyWith(
        ruleProvider: names[ruleProvider] ?? ruleProvider,
      ),
      _ when ruleAction.nestsRules && content != null => copyWith(
        content: content.replaceAllMapped(
          _nestedRuleSet,
          (match) => '${match[1]}${names[match[2]] ?? match[2]}${match[3]}',
        ),
      ),
      _ => this,
    };
  }
}

extension ProxyGroupReferences on ProxyGroup {
  ProxyGroup renamedProxies(Map<String, String> names) => copyWith(
    proxies: switch (proxies) {
      final proxies? => [for (final name in proxies) names[name] ?? name],
      null => null,
    },
    defaultSelected: names[defaultSelected] ?? defaultSelected,
    emptyFallback: names[emptyFallback] ?? emptyFallback,
  );
}

extension ProfileOverridesReferences on ProfileOverrides {
  List<(DnsOverrideKey, List<String>)> get _serverLists => [
    (DnsOverrideKey.defaultNameserver, dns.defaultNameserver),
    (DnsOverrideKey.nameserver, dns.nameserver),
    (DnsOverrideKey.fallback, dns.fallback),
    (DnsOverrideKey.proxyServerNameserver, dns.proxyServerNameserver),
    (DnsOverrideKey.directNameserver, dns.directNameserver),
  ];

  List<(DnsOverrideKey, Map<String, String>)> get _policies => [
    (DnsOverrideKey.nameserverPolicy, dns.nameserverPolicy),
    (
      DnsOverrideKey.proxyServerNameserverPolicy,
      dns.proxyServerNameserverPolicy,
    ),
  ];

  List<(SnifferOverrideKey, List<String>)> get _snifferMatchers => [
    (SnifferOverrideKey.forceDomain, sniffer.forceDomain),
    (SnifferOverrideKey.skipDomain, sniffer.skipDomain),
    (SnifferOverrideKey.skipSrcAddress, sniffer.skipSrcAddress),
    (SnifferOverrideKey.skipDstAddress, sniffer.skipDstAddress),
  ];

  /// mihomo refuses the whole config for a rule set it lacks.
  Set<String> get ruleSets {
    final filterAsRules =
        dnsOverrideKeys.contains(DnsOverrideKey.fakeIpFilterMode) &&
        dns.fakeIpFilterMode == FakeIpFilterMode.rule;
    return {
      for (final (key, policy) in _policies)
        if (dnsOverrideKeys.contains(key))
          for (final domain in policy.keys)
            ..._ruleSetsIn(domain, policyKey: true),
      if (dnsOverrideKeys.contains(DnsOverrideKey.fakeIpFilter))
        for (final entry in dns.fakeIpFilter)
          ...filterAsRules
              ? Rule.parse(entry, id: 0).ruleSets
              : _ruleSetsIn(entry),
      for (final (key, entries) in _snifferMatchers)
        if (snifferOverrideKeys.contains(key))
          for (final entry in entries) ..._ruleSetsIn(entry),
    };
  }

  Set<String> get dnsProxies => {
    for (final (key, servers) in _serverLists)
      if (dnsOverrideKeys.contains(key))
        for (final server in servers) ...dnsServerProxies(server),
    for (final (key, policy) in _policies)
      if (dnsOverrideKeys.contains(key))
        for (final value in policy.values)
          for (final server in _policyServers(value))
            ...dnsServerProxies(server),
  };

  String? get ntpProxy =>
      ntpOverrideKeys.contains(NtpOverrideKey.dialerProxy) &&
          ntp.dialerProxy.isNotEmpty
      ? ntp.dialerProxy
      : null;

  ProfileOverrides renamedProxies(Map<String, String> names) {
    List<String> servers(List<String> list) => [
      for (final server in list) renamedDnsServer(server, names),
    ];
    Map<String, String> policy(Map<String, String> map) => {
      for (final MapEntry(:key, :value) in map.entries)
        key: _renamedPolicyServers(value, names),
    };
    return copyWith(
      dns: dns.copyWith(
        defaultNameserver: servers(dns.defaultNameserver),
        nameserver: servers(dns.nameserver),
        fallback: servers(dns.fallback),
        proxyServerNameserver: servers(dns.proxyServerNameserver),
        directNameserver: servers(dns.directNameserver),
        nameserverPolicy: policy(dns.nameserverPolicy),
        proxyServerNameserverPolicy: policy(dns.proxyServerNameserverPolicy),
      ),
      ntp: ntp.copyWith(dialerProxy: names[ntp.dialerProxy] ?? ntp.dialerProxy),
    );
  }

  ProfileOverrides renamedRuleSets(Map<String, String> names) {
    Map<String, String> policy(Map<String, String> map) => {
      for (final MapEntry(:key, :value) in map.entries)
        _renamedRuleSetsIn(key, names, policyKey: true): value,
    };
    List<String> entries(List<String> list) => [
      for (final entry in list) _renamedRuleSetsIn(entry, names),
    ];
    return copyWith(
      dns: dns.copyWith(
        nameserverPolicy: policy(dns.nameserverPolicy),
        proxyServerNameserverPolicy: policy(dns.proxyServerNameserverPolicy),
        fakeIpFilter: [
          for (final entry in dns.fakeIpFilter)
            _renamedRuleText(_renamedRuleSetsIn(entry, names), names),
        ],
      ),
      sniffer: sniffer.copyWith(
        forceDomain: entries(sniffer.forceDomain),
        skipDomain: entries(sniffer.skipDomain),
        skipSrcAddress: entries(sniffer.skipSrcAddress),
        skipDstAddress: entries(sniffer.skipDstAddress),
      ),
    );
  }

  ProfileOverrides renamedProxyProviders(Map<String, String> names) => copyWith(
    proxyProviders: {
      for (final MapEntry(:key, :value) in proxyProviders.entries)
        names[key] ?? key: value,
    },
  );
}

extension ProfileReferences on Profile {
  /// A pick follows only where the group's own list in [members] names it,
  /// since a provider can bring a proxy of the same name.
  Profile renamedPicks(
    Map<String, String> names, {
    required Map<String, List<String>> members,
    bool groups = false,
  }) {
    String keyOf(String name) => groups ? names[name] ?? name : name;
    return copyWith(
      selectedMap: {
        for (final MapEntry(:key, :value) in selectedMap.entries)
          keyOf(key): (members[key]?.contains(value) ?? false)
              ? names[value] ?? value
              : value,
      },
      currentGroupName: switch (currentGroupName) {
        final name? => keyOf(name),
        null => null,
      },
      unfoldSet: {for (final name in unfoldSet) keyOf(name)},
    );
  }
}

Set<String> proxyNamesInUse(
  Set<String> names, {
  required Iterable<ProxyGroup> groups,
  required Iterable<String> ruleTargets,
  required Iterable<String> dialerTargets,
  required ProfileOverrides overrides,
}) => names.intersection({
  for (final group in groups) ...[...?group.proxies, ?group.defaultSelected],
  ...ruleTargets,
  ...dialerTargets,
  ...overrides.dnsProxies,
  ?overrides.ntpProxy,
});
