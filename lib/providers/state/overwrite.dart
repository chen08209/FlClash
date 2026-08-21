part of '../state.dart';

@riverpod
CustomOverwriteDate customOverwriteDate(Ref ref, int profileId) {
  final overwrite = ref.watch(
    clashConfigProvider(profileId).select((state) {
      return CustomOverwriteSelectorState(
        proxies: state.value?.proxies ?? [],
        subRules: state.value?.subRules ?? [],
        proxyProviders: state.value?.proxyProviders ?? [],
      );
    }),
  );
  final proxies = overwrite.proxies;
  final subRules = overwrite.subRules.toSet();
  final proxyProviders = overwrite.proxyProviders.toSet();
  final proxyGroups =
      ref
          .watch(
            proxyGroupsProvider(profileId).select((state) {
              return SelectValue(state.value);
            }),
          )
          .value ??
      [];
  final ruleTargets = {
    ...RuleTarget.baseTargets,
    ...proxies.map((item) => item.name),
    ...proxyGroups.map((item) => item.name),
  };
  return CustomOverwriteDate(
    proxyProviders: proxyProviders,
    proxies: proxies,
    proxyGroups: proxyGroups,
    ruleTargets: ruleTargets,
    subRules: subRules,
  );
}

@riverpod
bool customOverwriteTargetIsValid(Ref ref, int profileId, String? target) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.ruleTargets.contains(target)),
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
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.proxyProviders.contains(providerName)),
  );
  return valid;
}

@riverpod
bool customOverwriteUseIsValid(Ref ref, int profileId, List<String> use) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.proxyProviders.containsAll(use)),
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
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.ruleTargets.containsAll(proxies)),
  );
  return valid;
}

@riverpod
Set<int> invalidProxyGroupIds(Ref ref, int profileId) {
  final overwrite = ref.watch(customOverwriteDateProvider(profileId));
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
