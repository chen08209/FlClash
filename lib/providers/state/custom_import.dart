part of '../state.dart';

/// An empty [url] is a local provider, saved with [content].
typedef ImportedProvider = ({String label, String url, String content});

typedef CustomImportApp = ({
  Set<String> profileLabels,
  Map<String, String> profileUrls,
  Set<String> ruleProviderLabels,
  Map<String, String> ruleProviderUrls,
  List<Map<String, dynamic>> proxies,
  Set<String> groupNames,
});

enum CustomImportIssue { unreadable, ruleType, entry }

final class CustomImportException implements Exception {
  final CustomImportIssue issue;
  final String item;
  final String detail;

  const CustomImportException(this.issue, {this.item = '', this.detail = ''});

  @override
  String toString() => 'CustomImportException(${issue.name}, $item, $detail)';
}

/// What a config brings to a custom profile, its names moved off the app's:
/// a provider whose url the app has is used under the app's label, a proxy
/// the app holds unchanged under the app's name, one keeping an app proxy's
/// name, server and credentials as that proxy, and any other name the app
/// already uses takes a free one, with every reference to it following.
/// A name the config repeats keeps its references on its first holder.
///
/// Groups and rules carry id 0, since snowflake ids made on another isolate
/// can repeat the UI isolate's.
class CustomProfileImport {
  final List<ImportedProvider> proxyProviders;
  final List<ImportedProvider> ruleProviders;
  final List<Map<String, dynamic>> proxies;
  final Map<String, String> dialers;
  final List<ProxyGroup> proxyGroups;
  final List<Rule> rules;
  final ProfileOverrides overrides;

  const CustomProfileImport({
    required this.proxyProviders,
    required this.ruleProviders,
    required this.proxies,
    required this.dialers,
    required this.proxyGroups,
    required this.rules,
    required this.overrides,
  });
}

const _importedSections = [
  'proxies',
  'proxy-groups',
  'proxy-providers',
  'rule-providers',
  'rules',
  'dns',
  'ntp',
  'sniffer',
];

CustomProfileImport readCustomProfileImport(
  ({Uint8List bytes, CustomImportApp app}) input,
) {
  final Object? document;
  try {
    document = loadPlainYaml(utf8.decode(input.bytes));
  } on FormatException {
    throw const CustomImportException(CustomImportIssue.unreadable);
  }
  if (document is! Map<String, Object?> ||
      !_importedSections.any(document.containsKey)) {
    throw const CustomImportException(CustomImportIssue.unreadable);
  }
  final app = input.app;
  final proxyProviders = _importProviders(
    document['proxy-providers'],
    labels: app.profileLabels,
    urls: app.profileUrls,
    payloadKey: 'proxies',
  );
  final ruleProviders = _importProviders(
    document['rule-providers'],
    labels: app.ruleProviderLabels,
    urls: app.ruleProviderUrls,
    payloadKey: 'payload',
  );
  final groups = [
    for (final item in _listOf(document['proxy-groups']))
      if (item is Map) Map<String, Object?>.from(item),
  ];
  final proxies = _importProxies(
    [
      for (final item in _listOf(document['proxies']))
        if (item is Map) Map<String, dynamic>.from(item),
    ],
    groups: groups,
    existing: app.proxies,
    groupNames: app.groupNames,
  );
  final ruleSets = ruleProviders.names;
  return CustomProfileImport(
    proxyProviders: proxyProviders.added,
    ruleProviders: ruleProviders.added,
    proxies: proxies.added,
    dialers: proxies.dialers,
    proxyGroups: [
      for (final (index, group) in groups.indexed)
        _importGroup(
          group,
          name: proxies.importedGroupNames[index],
          names: proxies.names,
          use: proxyProviders.names,
        ),
    ],
    rules: [
      for (final item in _listOf(document['rules']))
        _importRule(item.toString(), names: proxies.names, ruleSets: ruleSets),
    ],
    overrides: _importOverrides(
      document,
      names: proxies.names,
      ruleSets: ruleSets,
      proxyProviders: _proxyProvidersOptions(
        document['proxy-providers'],
        proxyProviders.names,
      ),
    ),
  );
}

List<Object?> _listOf(Object? value) => value is List ? value : const [];

Map<String, Object?>? _mapOf(Object? value) =>
    value is Map ? Map<String, Object?>.from(value) : null;

String _nameOf(Map<String, Object?> item) => item['name']?.toString() ?? '';

({Map<String, String> names, List<ImportedProvider> added}) _importProviders(
  Object? section, {
  required Set<String> labels,
  required Map<String, String> urls,
  required String payloadKey,
}) {
  final taken = {...labels};
  final byUrl = {...urls};
  final names = <String, String>{};
  final added = <ImportedProvider>[];
  for (final MapEntry(:key, :value) in (_mapOf(section) ?? const {}).entries) {
    final provider = _mapOf(value);
    if (provider == null || key.trim().isEmpty) {
      continue;
    }
    final type = provider['type']?.toString();
    final url = type == 'http' ? provider['url']?.toString().trim() ?? '' : '';
    var label = url.isEmpty ? null : byUrl[url];
    if (label == null) {
      label = uniqueLabelFor(key, fallback: key, taken: taken.contains);
      taken.add(label);
      if (url.isNotEmpty) {
        byUrl[url] = label;
      }
      final payload = provider['payload'];
      added.add((
        label: label,
        url: url,
        content: type == 'inline' && payload is List
            ? yaml.encode({payloadKey: payload})
            : '',
      ));
    }
    names[key] = label;
  }
  return (names: names, added: added);
}

Map<String, ProxyProviderOptions> _proxyProvidersOptions(
  Object? section,
  Map<String, String> names,
) {
  final options = <String, ProxyProviderOptions>{};
  for (final MapEntry(:key, :value) in (_mapOf(section) ?? const {}).entries) {
    final label = names[key];
    final provider = _mapOf(value);
    if (label == null || provider == null) {
      continue;
    }
    final providerOptions = _proxyProviderOptions(key, provider);
    if (providerOptions != const ProxyProviderOptions()) {
      options[label] = providerOptions;
    }
  }
  return options;
}

Map<String, Object?> _stringified(
  Map<String, Object?> json,
  Iterable<String> keys,
) => {
  ...json,
  for (final key in keys)
    if (json[key] case final value? when value is! String)
      key: value.toString(),
};

T _decodeEntry<T>(String item, T Function() decode) {
  try {
    return decode();
  } catch (error) {
    throw CustomImportException(
      CustomImportIssue.entry,
      item: item,
      detail: compactError(error),
    );
  }
}

ProxyProviderOptions _proxyProviderOptions(
  String name,
  Map<String, Object?> provider,
) {
  final healthCheck = _mapOf(provider['health-check']);
  final proxyOverride = _mapOf(provider['override']);
  final json = _stringified(
    {
      if (healthCheck != null && healthCheck['enable'] == true)
        'health-check': _stringified(healthCheck, const [
          'url',
          'expected-status',
        ]),
      'filter': ?provider['filter'],
      'exclude-filter': ?provider['exclude-filter'],
      if (proxyOverride != null)
        'override': _stringified(proxyOverride, const [
          'additional-prefix',
          'additional-suffix',
          'ip-version',
        ]),
    },
    const ['filter', 'exclude-filter'],
  );
  return _decodeEntry(name, () => ProxyProviderOptions.fromJson(json));
}

Map<String, dynamic> _withoutName(Map<String, dynamic> definition) =>
    {...definition}..remove('name');

/// Each profile picks a proxy's dialer, so the proxy keeps none of its own.
Map<String, dynamic> _withoutDialer(Map<String, dynamic> definition) =>
    {...definition}..remove('dialer-proxy');

Object? _weaklyTyped(Object? value) => switch (value) {
  final Map map => {
    for (final MapEntry(:key, :value) in map.entries)
      key.toString(): _weaklyTyped(value),
  },
  final List list => [for (final item in list) _weaklyTyped(item)],
  final num number => number.toString(),
  _ => value,
};

Object? _comparable(Map<String, dynamic> definition) =>
    _weaklyTyped(_withoutName(_withoutDialer(definition)));

List<Object?>? _identityOf(Map<String, dynamic> definition) {
  final proxy = CustomProxy(id: 0, definition: definition);
  final server = proxy.server;
  if (server == null || server.isEmpty || proxy.credentials.isEmpty) {
    return null;
  }
  return [
    proxy.name,
    proxy.type,
    server,
    proxy.port,
    for (final credential in proxy.credentials)
      definition[credential.name]?.toString(),
  ];
}

/// Proxies and groups share one namespace in mihomo, and in a custom profile
/// that namespace takes in the app's proxies, so a group is moved off an app
/// proxy's name as a proxy is, and a proxy off other profiles' [groupNames].
({
  Map<String, String> names,
  List<String> importedGroupNames,
  List<Map<String, dynamic>> added,
  Map<String, String> dialers,
})
_importProxies(
  List<Map<String, dynamic>> proxies, {
  required List<Map<String, Object?>> groups,
  required List<Map<String, dynamic>> existing,
  required Set<String> groupNames,
}) {
  const equality = DeepCollectionEquality();
  final held = LinkedHashMap<Object?, String>(
    equals: equality.equals,
    hashCode: equality.hash,
  );
  final identities = HashSet<List<Object?>>(
    equals: equality.equals,
    hashCode: equality.hash,
  );
  for (final definition in existing) {
    final name = _nameOf(definition);
    if (name.isNotEmpty) {
      held.putIfAbsent(_comparable(definition), () => name);
      if (_identityOf(definition) case final identity?) {
        identities.add(identity);
      }
    }
  }
  final existingNames = {for (final item in existing) _nameOf(item)};
  final kept = {
    for (final proxy in proxies)
      if (!existingNames.contains(_nameOf(proxy)) &&
          !groupNames.contains(_nameOf(proxy)))
        _nameOf(proxy),
    for (final group in groups)
      if (!existingNames.contains(_nameOf(group))) _nameOf(group),
  };
  final taken = {
    ...reservedProxyNames,
    ...existingNames,
    ...groupNames,
    ...kept,
  };
  final used = <String>{};
  String freeName(String name) =>
      kept.contains(name) && used.add(name) ? name : freeProxyName(name, taken);
  final names = <String, String>{};
  final proxyNames = <String>[];
  final added = <Map<String, dynamic>>[];
  for (final proxy in proxies) {
    final name = _nameOf(proxy);
    final definition = _withoutDialer(proxy);
    final String imported;
    if (held[_comparable(definition)] case final same?) {
      imported = same;
    } else if (identities.contains(_identityOf(definition))) {
      imported = name;
    } else {
      imported = freeName(name);
      added.add({...definition, 'name': imported});
    }
    names.putIfAbsent(name, () => imported);
    proxyNames.add(imported);
  }
  final importedGroupNames = <String>[];
  for (final group in groups) {
    final imported = freeName(_nameOf(group));
    names.putIfAbsent(_nameOf(group), () => imported);
    importedGroupNames.add(imported);
  }
  final dialers = {
    for (final (index, proxy) in proxies.indexed)
      if (proxy['dialer-proxy']?.toString() case final dialer?
          when dialer.isNotEmpty)
        proxyNames[index]: names[dialer] ?? dialer,
  };
  return (
    names: names,
    importedGroupNames: importedGroupNames,
    added: added,
    dialers: dialers,
  );
}

List<String> _renamedList(Object? value, Map<String, String> names) => {
  for (final item in _listOf(value)) names[item.toString()] ?? item.toString(),
}.toList();

ProxyGroup _importGroup(
  Map<String, Object?> group, {
  required String name,
  required Map<String, String> names,
  required Map<String, String> use,
}) {
  final json = _stringified(
    {
      // A custom profile has no include-all-providers, so include-all keeps
      // only its proxies.
      for (final MapEntry(:key, :value) in group.entries)
        if (key != 'include-all' && key != 'include-all-providers') key: value,
      if (group['include-all'] == true) 'include-all-proxies': true,
      'id': 0,
      'name': name,
      if (group.containsKey('proxies'))
        'proxies': _renamedList(group['proxies'], names),
      if (group.containsKey('use')) 'use': _renamedList(group['use'], use),
      if (group['default-selected'] case final Object selected)
        'default-selected': names[selected.toString()] ?? selected.toString(),
    },
    const [
      'url',
      'filter',
      'exclude-filter',
      'exclude-type',
      'expected-status',
      'hash-key',
      'empty-fallback',
      'icon',
    ],
  );
  return _decodeEntry(_nameOf(group), () => ProxyGroup.fromJson(json));
}

Rule _importRule(
  String value, {
  required Map<String, String> names,
  required Map<String, String> ruleSets,
}) {
  final type = value.split(',').first.trim().toUpperCase();
  if (!RuleAction.values.any((action) => action.value == type)) {
    throw CustomImportException(CustomImportIssue.ruleType, item: value);
  }
  final rule = Rule.parse(value, id: 0).renamedRuleSets(ruleSets);
  return rule.copyWith(ruleTarget: names[rule.ruleTarget] ?? rule.ruleTarget);
}

/// Leaves out what [keys] cannot hold, which the override decoders refuse.
Map<String, Object?> _knownKeys<K extends OverrideKey>(
  Map<String, Object?> section,
  List<K> keys, {
  String Function(String field)? normalizeField,
}) {
  final paths = {for (final key in keys) key.path};
  final parents = {for (final key in keys) ?key.parent};
  final known = <String, Object?>{};
  for (final MapEntry(:key, :value) in section.entries) {
    if (!parents.contains(key)) {
      if (paths.contains(key)) {
        known[key] = value;
      }
    } else if (value is Map) {
      known[key] = {
        for (final MapEntry(key: field, :value) in value.entries)
          if (paths.contains('$key.${normalizeField?.call('$field') ?? field}'))
            '$field': value,
      };
    }
  }
  return known;
}

ProfileOverrides _importOverrides(
  Map<String, Object?> document, {
  required Map<String, String> names,
  required Map<String, String> ruleSets,
  required Map<String, ProxyProviderOptions> proxyProviders,
}) {
  var overrides = ProfileOverrides(proxyProviders: proxyProviders);
  if (_mapOf(document['dns']) case final dns?) {
    final known = _knownKeys(dns, DnsOverrideKey.values);
    final result = _decodeEntry(
      'DNS',
      () => overrides.dns.applyOverrideYaml(yaml.encode(known)),
    );
    overrides = overrides.copyWith(
      dns: result.dns,
      dnsOverrideKeys: result.keys,
    );
  }
  if (_mapOf(document['ntp']) case final ntp?) {
    final known = _knownKeys(ntp, NtpOverrideKey.values);
    final result = _decodeEntry(
      'NTP',
      () => overrides.ntp.applyOverrideYaml(yaml.encode(known)),
    );
    overrides = overrides.copyWith(
      ntp: result.ntp,
      ntpOverrideKeys: result.keys,
    );
  }
  if (_mapOf(document['sniffer']) case final sniffer?) {
    final known = _knownKeys(
      sniffer,
      SnifferOverrideKey.values,
      normalizeField: (field) => field.toUpperCase(),
    );
    final result = _decodeEntry(
      'Sniffer',
      () => overrides.sniffer.applyOverrideYaml(yaml.encode(known)),
    );
    overrides = overrides.copyWith(
      sniffer: result.sniffer,
      snifferOverrideKeys: result.keys,
    );
  }
  if (_mapOf(document['tun']) case final tun?) {
    final known = _knownKeys(tun, TunOverrideKey.values);
    overrides = overrides.copyWith(
      tun: _decodeEntry('TUN', () => ProfileTun.fromJson(known)),
      tunOverrideKeys: {
        for (final key in TunOverrideKey.values)
          if (known.containsKey(key.path)) key,
      },
    );
  }
  Map<String, String> changed(Map<String, String> names) => {
    for (final MapEntry(:key, :value) in names.entries)
      if (key != value) key: value,
  };
  return overrides
      .renamedProxies(changed(names))
      .renamedRuleSets(changed(ruleSets));
}
