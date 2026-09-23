part of '../action.dart';

@Riverpod(keepAlive: true)
class ClashProvidersAction extends _$ClashProvidersAction {
  @override
  void build() {}

  void putProvider(ClashProvider provider, {ClashProvider? previous}) {
    ref.read(clashProvidersProvider(provider.kind).notifier).put(provider);
    if (previous != null && previous.fileName != provider.fileName) {
      unawaited(_clearCache(previous));
    }
    unawaited(
      _applyIfReferenced(provider.kind, {provider.label, ?previous?.label}),
    );
  }

  void delProvider(ClashProvider provider) {
    ref.read(clashProvidersProvider(provider.kind).notifier).del(provider.id);
    unawaited(_clearCache(provider));
    unawaited(_applyIfReferenced(provider.kind, {provider.label}));
  }

  Future<void> _clearCache(ClashProvider provider) async {
    await File(await provider.path).safeDelete();
  }

  Future<void> _applyIfReferenced(ProviderKind kind, Set<String> labels) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || profile.overwriteType != OverwriteType.custom) {
      return;
    }
    final referenced = switch (kind) {
      ProviderKind.proxy =>
        (await database.proxyGroupsDao.query(profile.id).get()).any(
          (group) => group.use?.any(labels.contains) ?? false,
        ),
      ProviderKind.rule =>
        (await database.rulesDao.queryProfileCustomRules(profile.id).get()).any(
          (rule) =>
              rule.ruleAction == RuleAction.RULE_SET &&
              labels.contains(rule.ruleProvider),
        ),
    };
    if (!referenced) {
      return;
    }
    ref.read(setupActionProvider.notifier).applyProfileDebounce(silence: true);
  }
}
