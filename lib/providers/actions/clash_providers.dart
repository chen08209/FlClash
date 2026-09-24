part of '../action.dart';

@Riverpod(keepAlive: true)
class ClashProvidersAction extends _$ClashProvidersAction {
  @override
  void build() {}

  /// Returns who blocks a rename: users whose subscription has the new label.
  Future<List<Profile>> putProvider(
    ClashProvider provider, {
    ClashProvider? previous,
    List<int>? content,
  }) async {
    var renameIn = const <Profile>[];
    if (previous != null && previous.label != provider.label) {
      renameIn = await profilesUsing(previous);
      final conflicts = await profilesDefining(
        provider.kind,
        provider.label,
        renameIn,
      );
      if (conflicts.isNotEmpty) {
        return conflicts;
      }
    }
    if (content != null) {
      await provider.saveContent(content);
    }
    ref
        .read(clashProvidersProvider(provider.kind).notifier)
        .put(provider, renameIn: renameIn.map((profile) => profile.id));
    if (previous != null && previous.fileName != provider.fileName) {
      unawaited(_clearCache(previous));
    }
    unawaited(
      _applyIfReferenced(provider.kind, {provider.label, ?previous?.label}),
    );
    return const [];
  }

  Future<List<Profile>> delProvider(ClashProvider provider) async {
    final users = await profilesUsing(provider);
    if (users.isEmpty) {
      ref.read(clashProvidersProvider(provider.kind).notifier).del(provider.id);
      unawaited(_clearCache(provider));
    }
    return users;
  }

  /// Any overwrite counts: a profile back on custom uses its groups again.
  Future<List<Profile>> profilesUsing(ClashProvider provider) async {
    final shadowedByProfile =
        provider.kind == ProviderKind.proxy &&
        ref.read(profileProvidersProvider).containsKey(provider.label);
    if (shadowedByProfile) {
      return const [];
    }
    return profilesReferencing(provider.kind, provider.label);
  }

  /// A name a profile's own subscription defines resolves there, so only the
  /// rest reach a profile or an app-level provider of that name.
  Future<List<Profile>> profilesReferencing(
    ProviderKind kind,
    String name,
  ) async {
    final ids = switch (kind) {
      ProviderKind.proxy => await database.proxyGroupsDao.profileIdsUsing(name),
      ProviderKind.rule =>
        await database.rulesDao.profileIdsUsingCustomRuleProvider(name),
    };
    final candidates = [
      for (final profile in ref.read(profilesProvider))
        if (ids.contains(profile.id)) profile,
    ];
    final defining = await profilesDefining(kind, name, candidates);
    return [
      for (final profile in candidates)
        if (!defining.contains(profile)) profile,
    ];
  }

  Future<List<Profile>> profilesDefining(
    ProviderKind kind,
    String name,
    Iterable<Profile> profiles,
  ) async {
    final defining = <Profile>[];
    for (final profile in profiles) {
      if ((await _subscriptionProviders(profile.id, kind)).contains(name)) {
        defining.add(profile);
      }
    }
    return defining;
  }

  /// Unreadable counts as defining nothing, keeping deletes on the safe side.
  Future<Set<String>> _subscriptionProviders(
    int profileId,
    ProviderKind kind,
  ) async {
    final Map<String, dynamic> config;
    try {
      config = await ref.read(coreHandlerProvider).getConfig(profileId);
    } catch (e) {
      commonPrint.log(
        'read providers of profile $profileId: $e',
        logLevel: LogLevel.warning,
      );
      return const {};
    }
    final section =
        config[switch (kind) {
          ProviderKind.proxy => 'proxy-providers',
          ProviderKind.rule => 'rule-providers',
        }];
    return section is Map ? {for (final key in section.keys) '$key'} : const {};
  }

  Future<void> _clearCache(ClashProvider provider) async {
    await File(await provider.path).safeDelete();
  }

  Future<bool> _isReferenced(
    int profileId,
    ProviderKind kind,
    Set<String> labels,
  ) async {
    return switch (kind) {
      ProviderKind.proxy =>
        (await database.proxyGroupsDao.query(profileId).get()).any(
          (group) => group.use?.any(labels.contains) ?? false,
        ),
      ProviderKind.rule =>
        (await database.rulesDao.queryProfileCustomRules(profileId).get()).any(
          (rule) =>
              rule.ruleAction == RuleAction.RULE_SET &&
              labels.contains(rule.ruleProvider),
        ),
    };
  }

  Future<void> _applyIfReferenced(ProviderKind kind, Set<String> labels) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null ||
        profile.overwriteType != OverwriteType.custom ||
        !await _isReferenced(profile.id, kind, labels)) {
      return;
    }
    ref.read(setupActionProvider.notifier).applyProfileDebounce(silence: true);
  }
}
