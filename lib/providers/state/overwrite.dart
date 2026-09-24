part of '../state.dart';

@riverpod
Set<String> appProviderLabels(Ref ref, ProviderKind kind) {
  if (!feature.customProviders) {
    return const {};
  }
  return ref
      .watch(
        clashProvidersProvider(kind).select(
          (state) => SelectValue({
            for (final provider in state.value ?? const <ClashProvider>[])
              provider.label,
          }),
        ),
      )
      .value;
}

/// Selectable in every profile, so valid next to the names its own config has.
@riverpod
Set<String> appProviderNames(Ref ref, ProviderKind kind) {
  if (!feature.customProviders) {
    return const {};
  }
  final labels = ref.watch(appProviderLabelsProvider(kind));
  if (kind == ProviderKind.rule) {
    return labels;
  }
  return {...ref.watch(profileProvidersProvider).keys, ...labels};
}

/// A name the subscription defines is its own, and a profile beats an app one.
@riverpod
Map<String, ProviderSource> providerSources(
  Ref ref,
  int profileId,
  ProviderKind kind,
) {
  if (!feature.customProviders) {
    return const {};
  }
  final subscription = ref
      .watch(
        clashConfigProvider(profileId).select(
          (state) => SelectValue(switch (kind) {
            ProviderKind.proxy => state.value?.proxyProviders,
            ProviderKind.rule => state.value?.ruleProviders,
          }),
        ),
      )
      .value;
  final profiles = kind == ProviderKind.proxy
      ? ref.watch(profileProvidersProvider).keys
      : const <String>[];
  return {
    for (final name in ref.watch(appProviderLabelsProvider(kind)))
      name: ProviderSource.app,
    for (final name in profiles) name: ProviderSource.profile,
    for (final name in subscription ?? const <String>[])
      name: ProviderSource.subscription,
  };
}

@riverpod
CustomOverwriteDate customOverwriteDate(Ref ref, int profileId) {
  final overwrite = ref.watch(
    clashConfigProvider(profileId).select((state) {
      final clashConfig = state.value;
      return CustomOverwriteSelectorState(
        loaded: clashConfig != null,
        proxies: clashConfig?.proxies ?? const [],
        subRules: clashConfig?.subRules ?? const [],
        proxyProviders: clashConfig?.proxyProviders ?? const [],
        ruleProviders: clashConfig?.ruleProviders ?? const [],
      );
    }),
  );
  final groups = ref
      .watch(
        proxyGroupsProvider(profileId).select((state) {
          return SelectValue(state.value);
        }),
      )
      .value;
  final customProxies = feature.customProxies
      ? ref
            .watch(
              customProxiesProvider(profileId).select((state) {
                return SelectValue(state.value);
              }),
            )
            .value
      : const <CustomProxy>[];
  final proxyGroups = groups ?? const <ProxyGroup>[];
  final proxyNames = <String>[];
  final proxyTypes = <String, String>{};
  if (customProxies?.isNotEmpty == true) {
    for (final proxy in customProxies!) {
      proxyNames.add(proxy.name);
      proxyTypes[proxy.name] = proxy.type;
    }
  } else {
    for (final proxy in overwrite.proxies) {
      proxyNames.add(proxy.name);
      proxyTypes[proxy.name] = proxy.type;
    }
  }
  final ruleTargets = {
    ...RuleTarget.baseTargets,
    ...proxyNames,
    ...proxyGroups.map((item) => item.name),
  };
  return CustomOverwriteDate(
    loaded: overwrite.loaded && groups != null && customProxies != null,
    proxyProviders: {
      ...overwrite.proxyProviders,
      ...ref.watch(appProviderNamesProvider(ProviderKind.proxy)),
    },
    ruleProviders: {
      ...overwrite.ruleProviders,
      ...ref.watch(appProviderNamesProvider(ProviderKind.rule)),
    },
    proxyNames: proxyNames,
    proxyTypes: proxyTypes,
    proxyGroups: proxyGroups,
    ruleTargets: ruleTargets,
    subRules: overwrite.subRules.toSet(),
  );
}

@riverpod
bool customOverwriteTargetIsValid(Ref ref, int profileId, String? target) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => !state.loaded || state.ruleTargets.contains(target)),
  );
  return valid;
}

@riverpod
bool customOverwriteProxyProviderIsValid(
  Ref ref,
  int profileId,
  String? providerName,
) {
  final valid = ref.watch(
    customOverwriteDateProvider(profileId).select(
      (state) => !state.loaded || state.proxyProviders.contains(providerName),
    ),
  );
  return valid;
}

@riverpod
bool customOverwriteRuleProviderIsValid(
  Ref ref,
  int profileId,
  String? providerName,
) {
  final valid = ref.watch(
    customOverwriteDateProvider(profileId).select(
      (state) => !state.loaded || state.ruleProviders.contains(providerName),
    ),
  );
  return valid;
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

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Future<Map<int, String>> customProxyCoreErrors(Ref ref, int profileId) async {
  final proxies = ref
      .watch(
        customProxiesProvider(
          profileId,
        ).select((state) => SelectValue(state.value ?? const <CustomProxy>[])),
      )
      .value;
  if (proxies.isEmpty) {
    return const {};
  }
  final results = await ref.read(coreHandlerProvider).validateProxies([
    for (final proxy in proxies) proxy.definition,
  ]);
  return {
    for (final (index, message) in results.indexed)
      if (message.isNotEmpty) proxies[index].id: message,
  };
}

@riverpod
List<ProxyGroup> effectiveProxyGroups(Ref ref, int profileId) {
  final groups = ref.watch(
    customOverwriteDateProvider(profileId).select((state) => state.proxyGroups),
  );
  if (groups.isNotEmpty) {
    return groups;
  }
  return ref
      .watch(
        clashConfigProvider(profileId).select(
          (state) =>
              SelectValue(state.value?.proxyGroups ?? const <ProxyGroup>[]),
        ),
      )
      .value;
}

List<OverwriteIssue> customProxyIssues(
  CustomProxy proxy, {
  required Iterable<CustomProxy> proxies,
  required Iterable<ProxyGroup> proxyGroups,
  String? coreError,
}) {
  final name = proxy.name;
  return [
    if (name.isEmpty)
      const OverwriteIssue.emptyName()
    else if (reservedProxyNames.contains(name))
      OverwriteIssue.reservedName(name)
    else if (proxies.any((item) => item.id != proxy.id && item.name == name) ||
        proxyGroups.any((item) => item.name == name))
      OverwriteIssue.duplicateName(name),
    if (coreError != null) OverwriteIssue.coreRejected(coreError),
  ];
}

/// The groups [group] reaches back to itself through, or null when it is not
/// on a loop; mihomo refuses the whole config for one.
List<String>? proxyGroupLoop(ProxyGroup group, Iterable<ProxyGroup> groups) {
  final members = {
    for (final item in groups)
      if (item.id != group.id) item.name: item.proxies ?? const <String>[],
    group.name: group.proxies ?? const <String>[],
  };
  final visited = <String>{};
  List<String>? walk(String name, List<String> path) {
    for (final next in members[name] ?? const <String>[]) {
      if (next == group.name) {
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

  return walk(group.name, [group.name]);
}

List<OverwriteIssue> proxyGroupIssues(
  ProxyGroup group,
  CustomOverwriteDate overwrite,
) {
  final name = group.name;
  final proxies = group.proxies ?? const <String>[];
  final use = group.use ?? const <String>[];
  final hasSource =
      proxies.isNotEmpty ||
      use.isNotEmpty ||
      group.includeAll == true ||
      group.includeAllProxies == true ||
      group.includeAllProviders == true;
  final missingProxies = overwrite.loaded
      ? proxies.where((item) => !overwrite.ruleTargets.contains(item)).toList()
      : const <String>[];
  final missingProviders = overwrite.loaded
      ? use.where((item) => !overwrite.proxyProviders.contains(item)).toList()
      : const <String>[];
  final loop = proxyGroupLoop(group, overwrite.proxyGroups);
  return [
    if (name.isEmpty)
      const OverwriteIssue.emptyName()
    else if (reservedProxyNames.contains(name))
      OverwriteIssue.reservedName(name)
    else if (overwrite.proxyNames.contains(name) ||
        overwrite.proxyGroups.any(
          (item) => item.id != group.id && item.name == name,
        ))
      OverwriteIssue.duplicateName(name),
    if (!hasSource) const OverwriteIssue.noProxySource(),
    if (missingProxies.isNotEmpty)
      OverwriteIssue.missingProxies(missingProxies),
    if (missingProviders.isNotEmpty)
      OverwriteIssue.missingProviders(missingProviders),
    if (loop != null) OverwriteIssue.groupLoop(loop),
  ];
}

List<OverwriteIssue> customRuleIssues(
  Rule rule,
  CustomOverwriteDate overwrite,
) {
  final payloadError = rule.payloadError;
  if (payloadError != null) {
    return [OverwriteIssue.invalidPayload(payloadError)];
  }
  if (!overwrite.loaded) {
    return const [];
  }
  final ruleProvider = rule.ruleProvider;
  if (rule.ruleAction == RuleAction.RULE_SET &&
      !overwrite.ruleProviders.contains(ruleProvider)) {
    return [OverwriteIssue.missingRuleSet(ruleProvider ?? '')];
  }
  final target = rule.realTarget;
  if (rule.ruleAction == RuleAction.SUB_RULE) {
    return overwrite.subRules.contains(target)
        ? const []
        : [OverwriteIssue.missingSubRule(target ?? '')];
  }
  return overwrite.ruleTargets.contains(target)
      ? const []
      : [OverwriteIssue.missingTarget(target ?? '')];
}

@riverpod
CustomOverwriteIssues customOverwriteIssues(Ref ref, int profileId) {
  final overwrite = ref.watch(customOverwriteDateProvider(profileId));
  final proxies = feature.customProxies
      ? ref.watch(customProxiesProvider(profileId)).value ??
            const <CustomProxy>[]
      : const <CustomProxy>[];
  final coreErrors = feature.customProxies
      ? ref.watch(customProxyCoreErrorsProvider(profileId)).value ??
            const <int, String>{}
      : const <int, String>{};
  final rules =
      ref.watch(profileCustomRulesProvider(profileId)).value ?? const <Rule>[];
  final proxyGroups = ref.watch(effectiveProxyGroupsProvider(profileId));
  final subscriptionGroups = proxies.isNotEmpty && overwrite.proxyGroups.isEmpty
      ? proxyGroups
      : const <ProxyGroup>[];
  final subscriptionProviders = ref
      .watch(
        clashConfigProvider(profileId).select((state) {
          final clashConfig = state.value;
          return SelectValue({
            ...?clashConfig?.proxyProviders,
            ...?clashConfig?.ruleProviders,
          });
        }),
      )
      .value;
  final appProviders = {
    ...ref.watch(appProviderNamesProvider(ProviderKind.proxy)),
    ...ref.watch(appProviderNamesProvider(ProviderKind.rule)),
  };
  Map<int, List<OverwriteIssue>> collect<T>(
    Iterable<T> items,
    int Function(T item) idOf,
    List<OverwriteIssue> Function(T item) issuesOf,
  ) {
    return {
      for (final item in items)
        if (issuesOf(item) case final issues when issues.isNotEmpty)
          idOf(item): issues,
    };
  }

  return CustomOverwriteIssues(
    proxies: collect(
      proxies,
      (item) => item.id,
      (item) => customProxyIssues(
        item,
        proxies: proxies,
        proxyGroups: proxyGroups,
        coreError: coreErrors[item.id],
      ),
    ),
    proxyGroups: collect(
      overwrite.proxyGroups,
      (item) => item.id,
      (item) => proxyGroupIssues(item, overwrite),
    ),
    rules: collect(
      rules,
      (item) => item.id,
      (item) => customRuleIssues(item, overwrite),
    ),
    general: [
      ?subscriptionGroupsIssue(
        subscriptionGroups,
        targets: overwrite.ruleTargets,
      ),
      for (final name in appProviders.intersection(subscriptionProviders))
        OverwriteIssue.providerShadowed(name),
    ],
  );
}

/// Custom proxies replace the profile's own, while an empty custom group list
/// keeps the profile's groups, which may still name the proxies left out.
OverwriteIssue? subscriptionGroupsIssue(
  Iterable<ProxyGroup> groups, {
  required Set<String> targets,
}) {
  final groupNames = {for (final group in groups) group.name};
  final missing = {
    for (final group in groups)
      for (final name in group.proxies ?? const <String>[])
        if (!targets.contains(name) && !groupNames.contains(name)) name,
  };
  if (missing.isEmpty) {
    return null;
  }
  return OverwriteIssue.subscriptionGroupMissingProxies(missing.toList());
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

@Riverpod(name: 'ruleProvider')
class RuleProvider extends _$RuleProvider with AutoDisposeNotifierMixin {
  @override
  Rule build() {
    throw StateError('ruleProvider must be overridden before it is read');
  }
}
