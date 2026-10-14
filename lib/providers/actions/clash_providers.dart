part of '../action.dart';

@Riverpod(keepAlive: true)
class ClashProvidersAction extends _$ClashProvidersAction {
  @override
  void build() {}

  CoreController get _core => ref.read(coreHandlerProvider);

  Future<ClashProvider> putProvider(
    ClashProvider provider, {
    ClashProvider? previous,
    List<int>? content,
    bool refresh = false,
  }) async {
    final before = await _stored(provider.id);
    final download =
        provider.isRemote &&
        (refresh || provider.fileName != previous?.fileName);
    final compiled = switch (content) {
      final content? => await _compileContent(provider, content),
      null when download => await _compile(provider, download: true),
      null => provider,
    };
    final latest = before == null ? null : await _stored(provider.id);
    if (before != null &&
        (latest == null || latest.fileName != before.fileName)) {
      if (latest?.fileName != compiled.fileName) {
        unawaited(_clearCache(compiled));
      }
      return latest ?? compiled;
    }
    final next = switch ((before, latest)) {
      (final before?, final latest?) => latest.copyWith(
        label: compiled.label == before.label ? latest.label : compiled.label,
        url: compiled.url,
        behavior: compiled.behavior,
        format: compiled.format,
      ),
      _ => compiled,
    };
    ref.read(clashProvidersProvider.notifier).put(next);
    if (previous != null && previous.fileName != next.fileName) {
      unawaited(_clearCache(previous));
    }
    unawaited(
      applyIfReferenced(ProviderKind.rule, {
        next.label,
        ?previous?.label,
      }, force: content != null || download),
    );
    return next;
  }

  /// Downloads outlast edits, so a result lands on the set as it is by then.
  Future<ClashProvider?> _stored(int id) async {
    final rows =
        ref.read(clashProvidersProvider).value ??
        await database.clashProvidersDao.query().get();
    return rows.where((item) => item.id == id).firstOrNull;
  }

  Future<ClashProvider> _compile(
    ClashProvider provider, {
    bool download = false,
  }) async {
    // Made here, or a Core running as root would create it as its own.
    await File(await provider.path).parent.create(recursive: true);
    final info = await _core.compileRuleSet(
      provider.fileName,
      url: download ? provider.url : '',
    );
    final next = provider.withInfo(info);
    if (!next.isCompiled) {
      await File(await next.compiledPath).safeDelete();
    }
    return next;
  }

  Future<ClashProvider> _compileContent(
    ClashProvider provider,
    List<int> content,
  ) async {
    final stagedName = '${provider.fileName}.new';
    final staged = await appPath.getProviderCachePath(stagedName);
    try {
      await File(staged).safeWriteAsBytes(content);
      final next = provider.withInfo(await _core.compileRuleSet(stagedName));
      if (next.isCompiled) {
        await File('$staged.mrs').rename(await next.compiledPath);
      } else {
        await File(await next.compiledPath).safeDelete();
      }
      await File(staged).rename(await next.path);
      return next;
    } finally {
      await File(staged).safeDelete();
      await File('$staged.mrs').safeDelete();
    }
  }

  /// A subscription's set can share the name, so match by path.
  Future<ClashProvider?> remoteProviderOf(ExternalProvider external) async {
    final path = external.path;
    if (external.type != 'Rule' ||
        external.vehicleType != 'File' ||
        path == null) {
      return null;
    }
    for (final provider in await database.clashProvidersDao.query().get()) {
      if (provider.isRemote && await provider.corePath == path) {
        return provider;
      }
    }
    return null;
  }

  /// Returns false when the set changed shape, which only a reapply loads.
  Future<bool> syncRemote(ClashProvider provider) async {
    final next = await _compile(provider, download: true);
    if (next == provider) {
      return true;
    }
    await database.clashProviders.put(next.toCompanion());
    unawaited(applyIfReferenced(ProviderKind.rule, {next.label}, force: true));
    return false;
  }

  /// Backups leave remote sets out and older sets have no mrs yet.
  Future<ClashProvider> prepare(ClashProvider provider) async {
    if (await File(await provider.corePath).exists()) {
      return provider;
    }
    try {
      final next = await _compile(
        provider,
        download:
            provider.isRemote && !await File(await provider.path).exists(),
      );
      if (next != provider) {
        await database.clashProviders.put(next.toCompanion());
      }
      return next;
    } catch (e) {
      commonPrint.log(
        'prepare rule set ${provider.label}: $e',
        logLevel: LogLevel.warning,
      );
      return provider;
    }
  }

  void delProvider(ClashProvider provider) {
    ref.read(clashProvidersProvider.notifier).del(provider.id);
    unawaited(_clearCache(provider));
  }

  Future<List<Profile>> profilesUsing(ClashProvider provider) {
    return profilesReferencing(ProviderKind.rule, provider.label);
  }

  Future<List<Profile>> profilesReferencing(
    ProviderKind kind,
    String name,
  ) async {
    final ids = switch (kind) {
      ProviderKind.proxy => await database.proxyGroupsDao.profileIdsUsing(name),
      ProviderKind.rule => await database.rulesDao.profileIdsUsingRuleProvider(
        name,
      ),
    };
    return [
      for (final profile in ref.read(profilesProvider))
        if (ids.contains(profile.id) ||
            kind == ProviderKind.rule &&
                profile.type == ProfileType.custom &&
                profile.overrides.ruleSets.contains(name))
          profile,
    ];
  }

  Future<void> _clearCache(ClashProvider provider) async {
    await File(await provider.path).safeDelete();
    await File(await provider.compiledPath).safeDelete();
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
        (ref
                    .read(profilesProvider)
                    .getProfile(profileId)
                    ?.overrides
                    .ruleSets
                    .any(labels.contains) ??
                false) ||
            (await database.rulesDao.queryProfileRules(profileId).get()).any(
              (rule) => rule.ruleSets.any(labels.contains),
            ),
    };
  }

  /// [force] reapplies a provider whose content changed under the same path,
  /// which leaves the generated config unchanged.
  Future<void> applyIfReferenced(
    ProviderKind kind,
    Set<String> labels, {
    bool force = false,
  }) => _applyIf(
    (profileId) => _isReferenced(profileId, kind, labels),
    force: force,
  );

  Future<void> applyIfProxiesNamed(Set<String> names) => _applyIf(
    (profileId) async => (await database.proxyGroupsDao.query(profileId).get())
        .any((group) => group.proxies?.any(names.contains) ?? false),
  );

  Future<void> _applyIf(
    Future<bool> Function(int profileId) isReferenced, {
    bool force = false,
  }) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null ||
        profile.type != ProfileType.custom ||
        !await isReferenced(profile.id)) {
      return;
    }
    ref
        .read(setupActionProvider.notifier)
        .applyProfileDebounce(silence: true, force: force);
  }
}
