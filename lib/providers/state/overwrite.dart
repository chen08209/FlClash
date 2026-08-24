part of '../state.dart';

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
  final proxyGroups = groups ?? const <ProxyGroup>[];
  final proxyNames = <String>[];
  final proxyTypes = <String, String>{};
  for (final proxy in overwrite.proxies) {
    proxyNames.add(proxy.name);
    proxyTypes[proxy.name] = proxy.type;
  }
  final ruleTargets = {
    ...RuleTarget.baseTargets,
    ...proxyNames,
    ...proxyGroups.map((item) => item.name),
  };
  return CustomOverwriteDate(
    loaded: overwrite.loaded && groups != null,
    proxyProviders: overwrite.proxyProviders.toSet(),
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
bool customOverwriteUseIsValid(Ref ref, int profileId, List<String> use) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => !state.loaded || state.proxyProviders.containsAll(use)),
  );
  return valid;
}

@riverpod
bool customOverwriteProxiesIsValid(
  Ref ref,
  int profileId,
  List<String> proxies,
) {
  final valid = ref.watch(
    customOverwriteDateProvider(profileId).select(
      (state) => !state.loaded || state.ruleTargets.containsAll(proxies),
    ),
  );
  return valid;
}

@riverpod
Set<int> invalidProxyGroupIds(Ref ref, int profileId) {
  final overwrite = ref.watch(customOverwriteDateProvider(profileId));
  if (!overwrite.loaded) {
    return const {};
  }
  return {
    for (final proxyGroup in overwrite.proxyGroups)
      if (!overwrite.ruleTargets.containsAll(proxyGroup.proxies ?? const []) ||
          !overwrite.proxyProviders.containsAll(proxyGroup.use ?? const []))
        proxyGroup.id,
  };
}

@Riverpod(name: 'proxyGroupProvider')
class ProxyGroupProvider extends _$ProxyGroupProvider
    with AutoDisposeNotifierMixin {
  @override
  ProxyGroup build() {
    throw StateError('proxyGroupProvider must be overridden before it is read');
  }
}

@Riverpod(name: 'ruleProvider')
class RuleProvider extends _$RuleProvider with AutoDisposeNotifierMixin {
  @override
  Rule build() {
    throw StateError('ruleProvider must be overridden before it is read');
  }
}
