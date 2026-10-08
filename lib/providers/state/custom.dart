part of '../state.dart';

@riverpod
Set<String> appProviderNames(Ref ref, ProviderKind kind) {
  return switch (kind) {
    ProviderKind.proxy =>
      ref
          .watch(
            profileProvidersProvider.select(
              (state) => SelectValue(state.keys.toSet()),
            ),
          )
          .value,
    ProviderKind.rule =>
      ref
          .watch(
            clashProvidersProvider.select(
              (state) => SelectValue({
                for (final provider in state.value ?? const <ClashProvider>[])
                  provider.label,
              }),
            ),
          )
          .value,
  };
}

/// Null until every source loads, so no check reads a loading one as empty.
@riverpod
CustomProfileData? customProfileData(Ref ref, int profileId) {
  final groups = ref
      .watch(
        proxyGroupsProvider(profileId).select((state) {
          return SelectValue(state.value);
        }),
      )
      .value;
  final appProxies = ref.watch(customProxiesProvider).value;
  final profileDialers = ref.watch(proxyDialersProvider(profileId)).value;
  final ruleProvidersLoaded = ref.watch(
    clashProvidersProvider.select((state) => state.hasValue),
  );
  final proxyProviders = ref.watch(
    appProviderNamesProvider(ProviderKind.proxy),
  );
  final ruleProviders = ref.watch(appProviderNamesProvider(ProviderKind.rule));
  if (groups == null ||
      appProxies == null ||
      profileDialers == null ||
      !ruleProvidersLoaded) {
    return null;
  }
  return CustomProfileData(
    proxyProviders: proxyProviders,
    ruleProviders: ruleProviders,
    proxyGroups: groups,
    ruleTargets: {
      ...RuleTarget.baseTargets,
      ...groups.map((item) => item.name),
    },
    proxies: {for (final proxy in appProxies) proxy.name},
    dialers: {
      for (final proxy in appProxies) proxy.name: ?profileDialers[proxy.id],
    },
  );
}

@riverpod
bool customProfileTargetIsValid(Ref ref, int profileId, String? target) {
  return ref.watch(
    customProfileDataProvider(
      profileId,
    ).select((state) => state == null || _isRuleLineTarget(state, target)),
  );
}

/// A rule line joins its fields with commas, so the core reads a name holding
/// one as cut short.
bool _isRuleLineTarget(CustomProfileData data, String? target) =>
    data.isRuleTarget(target) && !target!.contains(',');

@riverpod
bool customProfileProxyProviderIsValid(
  Ref ref,
  int profileId,
  String? providerName,
) {
  return ref.watch(
    customProfileDataProvider(
      profileId,
    ).select((state) => state?.proxyProviders.contains(providerName) ?? true),
  );
}

@riverpod
bool customProfileRuleProviderIsValid(
  Ref ref,
  int profileId,
  String? providerName,
) {
  return ref.watch(
    customProfileDataProvider(
      profileId,
    ).select((state) => state?.ruleProviders.contains(providerName) ?? true),
  );
}

/// Names the core registers before any proxy is parsed, so neither a proxy nor
/// a group can take one.
const reservedProxyNames = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'COMPATIBLE',
  'PASS',
  'PASS-RULE',
};

/// A group may take GLOBAL to stand in for the core's own selector, while a
/// proxy of that name is shadowed by the selector.
const reservedCustomProxyNames = {...reservedProxyNames, 'GLOBAL'};

Duration? _noRetry(int retryCount, Object error) => null;

const _definitionEquality = DeepCollectionEquality();

/// Lives with the list, as a verdict can rest on a file such as an ssh key.
@riverpod
Map<Map<String, dynamic>, String> customProxyVerdicts(Ref ref) => LinkedHashMap(
  equals: _definitionEquality.equals,
  hashCode: _definitionEquality.hash,
);

@Riverpod(retry: _noRetry)
Future<Map<int, String>> customProxyCoreErrors(Ref ref) async {
  final proxies = ref
      .watch(
        customProxiesProvider.select(
          (state) => SelectValue(state.value ?? const <CustomProxy>[]),
        ),
      )
      .value;
  final verdicts = ref.watch(customProxyVerdictsProvider);
  if (proxies.isEmpty) {
    return const {};
  }
  final unchecked = [
    for (final proxy in proxies)
      if (!verdicts.containsKey(proxy.definition)) proxy.definition,
  ];
  if (unchecked.isNotEmpty) {
    final results = await ref
        .read(coreHandlerProvider)
        .validateProxies(unchecked);
    for (final (index, message) in results.indexed) {
      verdicts[unchecked[index]] = message;
    }
  }
  return {
    for (final proxy in proxies)
      if (verdicts[proxy.definition] case final message?
          when message.isNotEmpty)
        proxy.id: message,
  };
}

@riverpod
Map<int, List<CustomIssue>> customProxyListIssues(Ref ref) {
  final proxies =
      ref.watch(customProxiesProvider).value ?? const <CustomProxy>[];
  final coreErrors =
      ref.watch(customProxyCoreErrorsProvider).value ?? const <int, String>{};
  final groupNames =
      ref.watch(customGroupNamesProvider).value ?? const <String>{};
  final byName = <String, List<CustomProxy>>{};
  for (final proxy in proxies) {
    byName.putIfAbsent(proxy.name, () => []).add(proxy);
  }
  return {
    for (final proxy in proxies)
      if (customProxyIssues(
            proxy,
            proxies: byName[proxy.name]!,
            groupNames: groupNames,
            coreError: coreErrors[proxy.id],
          )
          case final issues when issues.isNotEmpty)
        proxy.id: issues,
  };
}

/// [groupNames] are every custom profile's: a proxy and a group of one name
/// would stand for each other in the profiles naming the proxy.
List<CustomIssue> customProxyIssues(
  CustomProxy proxy, {
  required Iterable<CustomProxy> proxies,
  required Set<String> groupNames,
  String? coreError,
}) {
  final name = proxy.name;
  return [
    if (name.isEmpty)
      const CustomIssue.emptyName()
    else if (reservedCustomProxyNames.contains(name))
      CustomIssue.reservedName(name)
    else if (groupNames.contains(name) ||
        proxies.any((item) => item.id != proxy.id && item.name == name))
      CustomIssue.duplicateName(name),
    if (coreError != null) CustomIssue.coreRejected(coreError),
  ];
}

List<CustomProxy> importedCustomProxies(
  List<Map<String, dynamic>> definitions, {
  required Iterable<CustomProxy> existing,
  required Set<String> groupNames,
}) {
  final taken = {
    ...reservedCustomProxyNames,
    ...groupNames,
    ...existing.map((proxy) => proxy.name),
  };
  return [
    for (final definition in definitions)
      CustomProxy.fromDefinition({
        ...definition,
        'name': freeProxyName(linkProxyName(definition), taken),
      }),
  ];
}

typedef ShareLinkLine = ({int line, String link, CustomProxy? kept});

/// A line that repeats a proxy's own link keeps that proxy as it is, since a
/// link carries fewer fields than the mapping.
class ShareLinkEdit {
  final List<CustomProxy> previous;
  final List<String> links;
  final List<ShareLinkLine> lines;

  const ShareLinkEdit._(this.previous, this.links, this.lines);

  factory ShareLinkEdit.read(
    String text, {
    required List<CustomProxy> previous,
    required List<String> links,
  }) {
    final unused = <String, List<CustomProxy>>{};
    for (final (index, proxy) in previous.indexed) {
      if (links[index].isNotEmpty) {
        unused.putIfAbsent(links[index], () => []).add(proxy);
      }
    }
    final lines = <ShareLinkLine>[];
    for (final (index, line) in text.split('\n').indexed) {
      final link = line.trim();
      if (link.isEmpty) {
        continue;
      }
      final matches = unused[link];
      lines.add((
        line: index + 1,
        link: link,
        kept: matches == null || matches.isEmpty ? null : matches.removeAt(0),
      ));
    }
    return ShareLinkEdit._(previous, links, lines);
  }

  static String textOf(List<String> links) =>
      links.where((link) => link.isNotEmpty).join('\n');

  List<ShareLinkLine> get pending =>
      lines.where((line) => line.kept == null).toList();

  /// A proxy named after one the edit dropped takes over its id, so each
  /// profile's dialer for it stays.
  List<CustomProxy> apply(
    Map<int, List<Map<String, dynamic>>> decoded, {
    required Set<String> groupNames,
  }) {
    final keptIds = {for (final line in lines) ?line.kept?.id};
    final dropped = <String, CustomProxy>{
      for (final (index, proxy) in previous.indexed)
        if (links[index].isNotEmpty && !keptIds.contains(proxy.id))
          proxy.name: proxy,
    };
    final taken = {
      ...reservedCustomProxyNames,
      ...groupNames,
      for (final (index, proxy) in previous.indexed)
        if (links[index].isEmpty) proxy.name,
      for (final line in lines) ?line.kept?.name,
    };
    final edited = <CustomProxy>[];
    for (final line in lines) {
      final kept = line.kept;
      if (kept != null) {
        edited.add(kept);
        continue;
      }
      for (final definition in decoded[line.line] ?? const []) {
        final base = linkProxyName(definition);
        final replaced = taken.contains(base) ? null : dropped.remove(base);
        final name = freeProxyName(base, taken);
        edited.add(
          CustomProxy.fromDefinition({
            ...definition,
            'name': name,
          }, id: replaced?.id),
        );
      }
    }
    final following = <int?, List<CustomProxy>>{};
    int? anchor;
    for (final (index, proxy) in previous.indexed) {
      if (links[index].isEmpty) {
        following.putIfAbsent(anchor, () => []).add(proxy);
      } else if (keptIds.contains(proxy.id)) {
        anchor = proxy.id;
      }
    }
    return [
      ...?following[null],
      for (final proxy in edited) ...[proxy, ...?following[proxy.id]],
    ];
  }
}

// mihomo names the links without a fragment "", -01, -02 and so on.
final _unnamedLinkPattern = RegExp(r'^(-\d+)?$');

String linkProxyName(Map<String, dynamic> definition) {
  final name = definition['name']?.toString().trim() ?? '';
  if (!_unnamedLinkPattern.hasMatch(name)) {
    return name;
  }
  return definition['server']?.toString() ?? definition['type'].toString();
}

String _numberedName(String base, int index) =>
    '$base-${index.toString().padLeft(2, '0')}';

String freeProxyName(String base, Set<String> taken) {
  var name = base;
  for (var index = 1; !taken.add(name); index++) {
    name = _numberedName(base, index);
  }
  return name;
}

final _numberSuffix = RegExp(r'-\d{2,}$');

String copiedProxyName(String name, Set<String> taken) {
  final base = name.replaceFirst(_numberSuffix, '');
  var index = 1;
  while (!taken.add(_numberedName(base, index))) {
    index++;
  }
  return _numberedName(base, index);
}

/// The groups [group] reaches back to itself through, or null when it is not
/// on a loop; mihomo refuses the whole config for one.
List<String>? proxyGroupLoop(ProxyGroup group, Iterable<ProxyGroup> groups) =>
    _loopFrom(group.name, {
      for (final item in groups)
        if (item.id != group.id) item.name: item.proxies ?? const <String>[],
      group.name: group.proxies ?? const <String>[],
    });

List<String>? _loopFrom(String start, Map<String, List<String>> members) {
  final visited = <String>{};
  List<String>? walk(String name, List<String> path) {
    for (final next in members[name] ?? const <String>[]) {
      if (next == start) {
        return [...path, next];
      }
      if (!members.containsKey(next) || !visited.add(next)) {
        continue;
      }
      final loop = walk(next, [...path, next]);
      if (loop != null) {
        return loop;
      }
    }
    return null;
  }

  return walk(start, [start]);
}

/// Tarjan's components of [edges], numbered as they close, so an edge never
/// leads to a component numbered higher than its own.
List<int> _componentsOf(List<List<int>> edges) {
  final index = List.filled(edges.length, -1);
  final low = List.filled(edges.length, 0);
  final component = List.filled(edges.length, -1);
  final stack = <int>[];
  var visited = 0;
  var closed = 0;
  void connect(int node) {
    index[node] = low[node] = visited++;
    stack.add(node);
    for (final next in edges[node]) {
      if (index[next] == -1) {
        connect(next);
        low[node] = min(low[node], low[next]);
      } else if (component[next] == -1) {
        low[node] = min(low[node], index[next]);
      }
    }
    if (low[node] != index[node]) {
      return;
    }
    int item;
    do {
      item = stack.removeLast();
      component[item] = closed;
    } while (item != node);
    closed++;
  }

  for (var node = 0; node < edges.length; node++) {
    if (index[node] == -1) {
      connect(node);
    }
  }
  return component;
}

Set<String> _namesOnLoops(Map<String, List<String>> members) {
  final names = members.keys.toList();
  final ids = {for (final (index, name) in names.indexed) name: index};
  final edges = [
    for (final name in names) [for (final item in members[name]!) ?ids[item]],
  ];
  final component = _componentsOf(edges);
  final sizes = <int, int>{};
  for (final item in component) {
    sizes.update(item, (size) => size + 1, ifAbsent: () => 1);
  }
  return {
    for (final (index, name) in names.indexed)
      if (sizes[component[index]]! > 1 || edges[index].contains(index)) name,
  };
}

/// [target] and what under it leads back to [proxy], through a group's own
/// list, include-all where no filter narrows it, or an app proxy's entry in
/// [dialers]; empty when the dial does not loop. What filters and providers
/// pick is left to the core, which fails a dial that comes back to its dialer.
Set<String> dialerLoop(
  String target,
  Iterable<ProxyGroup> groups, {
  required String proxy,
  Map<String, String> dialers = const {},
}) => dialerLoopsOf(groups, proxy: proxy, dialers: dialers)(target);

bool _takesInEveryProxy(ProxyGroup group) =>
    (group.includeAll == true || group.includeAllProxies == true) &&
    (group.filter ?? '').isEmpty &&
    (group.excludeFilter ?? '').isEmpty &&
    (group.excludeType ?? '').isEmpty;

/// [dialerLoop] for any target of [proxy], finding what reaches it once.
Set<String> Function(String target) dialerLoopsOf(
  Iterable<ProxyGroup> groups, {
  required String proxy,
  Map<String, String> dialers = const {},
}) => _DialerGraph(groups, dialers).loopsOf(proxy);

class _DialerGraph {
  final declared = <String>{};
  final chained = <String, String>{};
  final members = <String, List<String>>{};
  final groupNames = <String>{};
  final takingEveryProxy = <String>{};
  final parents = <String, List<String>>{};

  _DialerGraph(Iterable<ProxyGroup> groups, Map<String, String> dialers) {
    for (final group in groups) {
      declared.addAll(group.proxies ?? const <String>[]);
    }
    for (final MapEntry(key: name, value: dialer) in dialers.entries) {
      if (declared.contains(name)) {
        chained[name] = dialer;
        members[name] = [dialer];
      }
    }
    for (final group in groups) {
      final takesAll = _takesInEveryProxy(group);
      members[group.name] = [...?group.proxies, if (takesAll) ...chained.keys];
      groupNames.add(group.name);
      if (takesAll) {
        takingEveryProxy.add(group.name);
      } else {
        takingEveryProxy.remove(group.name);
      }
    }
    for (final MapEntry(key: name, value: items) in members.entries) {
      for (final item in items) {
        parents.putIfAbsent(item, () => []).add(name);
      }
    }
  }

  /// The proxy's own dialer is the dial being checked, never a way back; a
  /// proxy without one is still taken in by every include-all group.
  Set<String> Function(String target) loopsOf(String proxy) {
    if (!declared.contains(proxy)) {
      return (_) => const {};
    }
    final passesThrough = groupNames.contains(proxy);
    final takenIn = !chained.containsKey(proxy);
    final reaching = <String>{};
    final pending = [...?parents[proxy], if (takenIn) ...takingEveryProxy];
    while (pending.isNotEmpty) {
      final name = pending.removeLast();
      if ((passesThrough || name != proxy) && reaching.add(name)) {
        pending.addAll(parents[name] ?? const []);
      }
    }
    return (target) {
      if (target == proxy) {
        return {proxy};
      }
      final loop = <String>{};
      void walk(String name) {
        if (!reaching.contains(name) || !loop.add(name)) {
          return;
        }
        for (final next in members[name] ?? const <String>[]) {
          walk(next);
        }
        if (takenIn && takingEveryProxy.contains(name)) {
          walk(proxy);
        }
      }

      walk(target);
      return loop;
    };
  }
}

/// Every dial of [dialers] at once: those that loop, and the groups each
/// loop passes through, from reachability between the graph's components
/// rather than one walk per dial.
class _DialLoops {
  final looping = <String>{};
  final throughGroups = <String, List<CustomIssue>>{};

  _DialLoops(Iterable<ProxyGroup> groups, Map<String, String> dialers) {
    final graph = _DialerGraph(groups, dialers);
    final dials = [
      for (final MapEntry(key: proxy, value: target) in dialers.entries)
        if (graph.declared.contains(proxy)) (proxy: proxy, target: target),
    ];
    if (dials.isEmpty) {
      return;
    }
    final ids = <String, int>{};
    for (final MapEntry(key: name, value: items) in graph.members.entries) {
      for (final item in [name, ...items]) {
        ids.putIfAbsent(item, () => ids.length);
      }
    }
    final edges = List.generate(ids.length, (_) => <int>[]);
    for (final MapEntry(key: name, value: items) in graph.members.entries) {
      edges[ids[name]!].addAll([for (final item in items) ids[item]!]);
    }
    final component = _componentsOf(edges);
    final count = component.fold(0, (count, item) => max(count, item + 1));
    final nodes = List.generate(count, (_) => <int>[]);
    for (final (node, item) in component.indexed) {
      nodes[item].add(node);
    }
    final words = (dials.length + 31) >> 5;
    final reaches = List.generate(count, (_) => Uint32List(words));
    final reachedFrom = List.generate(count, (_) => Uint32List(words));
    bool has(Uint32List bits, int dial) =>
        bits[dial >> 5] & (1 << (dial & 31)) != 0;
    void add(Uint32List bits, int dial) => bits[dial >> 5] |= 1 << (dial & 31);
    void merge(Uint32List into, Uint32List from) {
      for (var word = 0; word < words; word++) {
        into[word] |= from[word];
      }
    }

    for (final (dial, (:proxy, :target)) in dials.indexed) {
      add(reaches[component[ids[proxy]!]], dial);
      final node = ids[target];
      if (target != proxy && node != null) {
        add(reachedFrom[component[node]], dial);
      }
    }
    for (var item = 0; item < count; item++) {
      for (final node in nodes[item]) {
        for (final next in edges[node]) {
          if (component[next] != item) {
            merge(reaches[item], reaches[component[next]]);
          }
        }
      }
    }
    for (var item = count - 1; item >= 0; item--) {
      for (final node in nodes[item]) {
        for (final next in edges[node]) {
          if (component[next] != item) {
            merge(reachedFrom[component[next]], reachedFrom[item]);
          }
        }
      }
    }
    for (final (dial, (:proxy, :target)) in dials.indexed) {
      final node = ids[target];
      if (target == proxy ||
          node != null && has(reaches[component[node]], dial)) {
        looping.add(proxy);
      }
    }
    for (final name in graph.groupNames) {
      final node = ids[name]!;
      final item = component[node];
      final onLoop = nodes[item].length > 1 || edges[node].contains(node);
      for (final (dial, (:proxy, :target)) in dials.indexed) {
        final through = target == proxy
            ? name == proxy
            : (name == proxy ? onLoop : has(reaches[item], dial)) &&
                  has(reachedFrom[item], dial);
        if (through) {
          throughGroups
              .putIfAbsent(name, () => [])
              .add(CustomIssue.dialerLoop(proxy, target));
        }
      }
    }
  }
}

final _profileDialLoops = Expando<_DialLoops>();

_DialLoops _dialLoopsIn(CustomProfileData data) =>
    _profileDialLoops[data] ??= _DialLoops(data.proxyGroups, data.dialers);

/// Drops a dialer that leads back to its proxy, since mihomo would follow
/// that loop on every dial.
List<Map<String, dynamic>> appProxiesPayload(
  Iterable<CustomProxy> proxies, {
  required Map<int, String> dialers,
  required List<ProxyGroup> groups,
}) {
  final named = {for (final group in groups) ...?group.proxies};
  final chain = {
    for (final proxy in proxies)
      if (named.contains(proxy.name)) proxy.name: ?dialers[proxy.id],
  };
  final looping = _DialLoops(groups, chain).looping;
  final payload = <Map<String, dynamic>>[];
  for (final proxy in proxies) {
    if (!named.contains(proxy.name)) {
      continue;
    }
    final dialer = chain[proxy.name];
    if (dialer != null && !looping.contains(proxy.name)) {
      payload.add({...proxy.definition, 'dialer-proxy': dialer});
      continue;
    }
    if (dialer != null) {
      commonPrint.log(
        'Dropped the dialer of ${proxy.name}: $dialer leads back to it',
        logLevel: LogLevel.warning,
      );
    }
    payload.add({...proxy.definition}..remove('dialer-proxy'));
  }
  return payload;
}

List<CustomIssue> proxyDialerIssues(
  CustomProxy proxy,
  String? target,
  CustomProfileData data,
) {
  if (target == null) {
    return const [];
  }
  if (!data.isRuleTarget(target)) {
    return [CustomIssue.missingDialer(target)];
  }
  final loops = data.dialers[proxy.name] == target
      ? _dialLoopsIn(data).looping.contains(proxy.name)
      : dialerLoop(
          target,
          data.proxyGroups,
          proxy: proxy.name,
          dialers: data.dialers,
        ).isNotEmpty;
  if (loops) {
    return [CustomIssue.dialerLoop(proxy.name, target)];
  }
  return const [];
}

/// What a stored group's check reads of the profile, once for all its groups.
class _StoredGroups {
  final groups = Set<ProxyGroup>.identity();
  final nameCounts = <String, int>{};
  final members = <String, List<String>>{};
  late final Set<String> looping;
  late final Map<String, List<CustomIssue>> dialerLoops;

  _StoredGroups(CustomProfileData data) {
    for (final group in data.proxyGroups) {
      groups.add(group);
      nameCounts.update(group.name, (count) => count + 1, ifAbsent: () => 1);
      members[group.name] = group.proxies ?? const <String>[];
    }
    looping = _namesOnLoops(members);
    dialerLoops = _dialLoopsIn(data).throughGroups;
  }
}

final _storedGroups = Expando<_StoredGroups>();

List<CustomIssue> proxyGroupIssues(ProxyGroup group, CustomProfileData data) {
  final name = group.name;
  final proxies = group.proxies ?? const <String>[];
  final use = group.use ?? const <String>[];
  final hasSource =
      proxies.isNotEmpty ||
      use.isNotEmpty ||
      group.includeAll == true ||
      group.includeAllProxies == true ||
      group.includeAllProviders == true;
  final missingProxies = [
    for (final item in proxies)
      if (!data.ruleTargets.contains(item) && !data.proxies.contains(item))
        item,
  ];
  final emptyFallback = group.emptyFallback ?? '';
  // The core takes only a proxy here, never a group, and refuses the whole
  // config otherwise.
  final invalidEmptyFallback =
      emptyFallback.isNotEmpty && !reservedProxyNames.contains(emptyFallback);
  final missingProviders = use
      .where((item) => !data.proxyProviders.contains(item))
      .toList();
  final stored = _storedGroups[data] ??= _StoredGroups(data);
  final List<String>? loop;
  final bool takenName;
  final List<CustomIssue> dialerLoops;
  // Moving a stored group last changes what a name stands for only when
  // another group shares it.
  if (stored.groups.contains(group) && stored.nameCounts[name] == 1) {
    loop = stored.looping.contains(name)
        ? _loopFrom(name, stored.members)
        : null;
    takenName = data.proxies.contains(name);
    dialerLoops = stored.dialerLoops[name] ?? const [];
  } else {
    final groups = [
      for (final item in data.proxyGroups)
        if (item.id != group.id) item,
      group,
    ];
    loop = proxyGroupLoop(group, data.proxyGroups);
    takenName =
        data.proxies.contains(name) ||
        data.proxyGroups.any(
          (item) => item.id != group.id && item.name == name,
        );
    dialerLoops =
        _DialLoops(groups, data.dialers).throughGroups[name] ?? const [];
  }
  return [
    if (name.isEmpty)
      const CustomIssue.emptyName()
    else if (reservedProxyNames.contains(name))
      CustomIssue.reservedName(name)
    else if (takenName)
      CustomIssue.duplicateName(name),
    if (!hasSource) const CustomIssue.noProxySource(),
    if (missingProxies.isNotEmpty) CustomIssue.missingProxies(missingProxies),
    if (missingProviders.isNotEmpty)
      CustomIssue.missingProviders(missingProviders),
    if (loop != null) CustomIssue.groupLoop(loop),
    ...dialerLoops,
    if (invalidEmptyFallback) CustomIssue.invalidEmptyFallback(emptyFallback),
  ];
}

List<CustomIssue> customRuleIssues(Rule rule, CustomProfileData data) {
  final payloadError = rule.payloadError;
  if (payloadError != null) {
    return [CustomIssue.invalidPayload(payloadError)];
  }
  final ruleSets = rule.ruleAction == RuleAction.RULE_SET
      ? [rule.ruleProvider ?? '']
      : rule.ruleSets;
  for (final ruleSet in ruleSets) {
    if (!data.ruleProviders.contains(ruleSet)) {
      return [CustomIssue.missingRuleSet(ruleSet)];
    }
  }
  final target = rule.realTarget;
  if (rule.ruleAction == RuleAction.SUB_RULE) {
    return [CustomIssue.missingSubRule(target ?? '')];
  }
  return _isRuleLineTarget(data, target)
      ? const []
      : [CustomIssue.missingTarget(target ?? '')];
}

@riverpod
CustomProfileIssues customProfileIssues(Ref ref, int profileId) {
  final data = ref.watch(customProfileDataProvider(profileId));
  final appProxies =
      ref.watch(customProxiesProvider).value ?? const <CustomProxy>[];
  final rules =
      ref.watch(profileRulesProvider(profileId)).value ?? const <Rule>[];
  final overrides = ref.watch(
    profileProvider(
      profileId,
    ).select((profile) => profile?.overrides ?? const ProfileOverrides()),
  );
  if (data == null) {
    return const CustomProfileIssues();
  }
  final missingDnsProxies = [
    if (overrides.customDnsEnabled)
      for (final name in overrides.dnsProxies)
        if (!data.isRuleTarget(name)) name,
  ];
  Map<int, List<CustomIssue>> collect<T>(
    Iterable<T> items,
    int Function(T item) idOf,
    List<CustomIssue> Function(T item) issuesOf,
  ) {
    return {
      for (final item in items)
        if (issuesOf(item) case final issues when issues.isNotEmpty)
          idOf(item): issues,
    };
  }

  return CustomProfileIssues(
    proxyGroups: collect(
      data.proxyGroups,
      (item) => item.id,
      (item) => proxyGroupIssues(item, data),
    ),
    rules: collect(
      rules,
      (item) => item.id,
      (item) => customRuleIssues(item, data),
    ),
    dialers: collect(
      appProxies.where((item) => data.namedProxies.contains(item.name)),
      (item) => item.id,
      (item) => proxyDialerIssues(item, data.dialers[item.name], data),
    ),
    dns: [
      if (missingDnsProxies.isNotEmpty)
        CustomIssue.missingProxies(missingDnsProxies),
    ],
    ntp: [
      if (overrides.ntpProxy case final name?
          when overrides.customNtpEnabled && !data.isRuleTarget(name))
        CustomIssue.missingDialer(name),
    ],
  );
}

@Riverpod(name: 'proxyGroupProvider')
class ProxyGroupProvider extends _$ProxyGroupProvider
    with AutoDisposeNotifierMixin {
  @override
  ProxyGroup build() {
    throw StateError('proxyGroupProvider must be overridden before it is read');
  }
}

@Riverpod(name: 'customProxyProvider')
class CustomProxyProvider extends _$CustomProxyProvider
    with AutoDisposeNotifierMixin {
  @override
  CustomProxy build() {
    throw StateError(
      'customProxyProvider must be overridden before it is read',
    );
  }
}

@Riverpod(name: 'proxyProviderOptionsProvider')
class ProxyProviderOptionsProvider extends _$ProxyProviderOptionsProvider
    with AutoDisposeNotifierMixin {
  @override
  ProxyProviderOptions build() {
    throw StateError(
      'proxyProviderOptionsProvider must be overridden before it is read',
    );
  }
}

@Riverpod(name: 'ruleProvider')
class RuleProvider extends _$RuleProvider with AutoDisposeNotifierMixin {
  @override
  Rule build() {
    throw StateError('ruleProvider must be overridden before it is read');
  }
}
