part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  Future<void> deleteProfile(int id) async {
    await ref.read(profilesProvider.notifier).del(id);
    await clearEffect(id);
    final currentProfileId = ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        ref.read(currentProfileIdProvider.notifier).value = null;
        unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
      }
    }
  }

  Future<String> validateConfigWithData(String data) async {
    return _core.validateConfigWithData(data);
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type != ProfileType.url) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<List<Profile>> providerUsers(Profile profile) async {
    if (profile.type == ProfileType.custom) {
      return const [];
    }
    final users = await ref
        .read(clashProvidersActionProvider.notifier)
        .profilesReferencing(ProviderKind.proxy, profile.realLabel);
    return [
      for (final user in users)
        if (user.id != profile.id) user,
    ];
  }

  /// Where a profile's own group takes a name, the name stands for that group.
  Future<List<Profile>> proxyUsers(Set<String> names) async {
    final (ruleTargets, dialerTargets) = await (
      database.rulesDao.targetsNaming(names),
      database.proxyDialersDao.targetsNaming(names),
    ).wait;
    final users = <Profile>[];
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type != ProfileType.custom) {
        continue;
      }
      final groups = await database.proxyGroupsDao.query(profile.id).get();
      final inUse = proxyNamesInUse(
        names.difference({for (final group in groups) group.name}),
        groups: groups,
        ruleTargets: ruleTargets[profile.id] ?? const {},
        dialerTargets: dialerTargets[profile.id] ?? const {},
        overrides: profile.overrides,
      );
      if (inUse.isNotEmpty) {
        users.add(profile);
      }
    }
    return users;
  }

  Future<Set<String>> groupsInUse(int profileId, Set<int> groupIds) async {
    final groups = await database.proxyGroupsDao.query(profileId).get();
    final names = {
      for (final group in groups)
        if (groupIds.contains(group.id)) group.name,
    };
    final (ruleTargets, dialerTargets) = await (
      database.rulesDao.targetsNaming(names),
      database.proxyDialersDao.targetsNaming(names),
    ).wait;
    return proxyNamesInUse(
      names,
      groups: groups.where((group) => !groupIds.contains(group.id)),
      ruleTargets: ruleTargets[profileId] ?? const {},
      dialerTargets: dialerTargets[profileId] ?? const {},
      overrides:
          ref.read(profilesProvider).getProfile(profileId)?.overrides ??
          const ProfileOverrides(),
    );
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type != ProfileType.url) continue;
      await updateProfile(profile, showLoading: true);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      ref.read(profilesProvider.notifier).put(profile);
      final newProfile = await profile.update(
        validate: (path) => _core.validateProfile(path),
      );
      ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      } else {
        final label = ref
            .read(profilesProvider.notifier)
            .labeled(newProfile)
            .realLabel;
        unawaited(
          ref.read(clashProvidersActionProvider.notifier).applyIfReferenced(
            ProviderKind.proxy,
            {label},
            force: true,
          ),
        );
      }
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: platformFile.name,
        ).saveFile(bytes, validate: (path) => _core.validateProfile(path));
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  int addCustomProfile(String label) {
    final profile = Profile.custom(label: label);
    putProfile(profile);
    return profile.id;
  }

  Future<CustomProfileImport> readCustomImport(
    int profileId,
    Uint8List bytes,
  ) async {
    final profiles = ref.read(profilesProvider);
    final (ruleProviders, proxies, groupNames) = await (
      database.clashProvidersDao.query().get(),
      database.customProxiesDao.query().get(),
      database.proxyGroupsDao.names(except: profileId).get(),
    ).wait;
    final CustomImportApp app = (
      profileLabels: {
        for (final profile in profiles) ...[profile.label, profile.realLabel],
      },
      profileUrls: {
        for (final profile in profiles)
          if (profile.type == ProfileType.url) profile.url: profile.realLabel,
      },
      ruleProviderLabels: {
        for (final provider in ruleProviders) provider.label,
      },
      ruleProviderUrls: {
        for (final provider in ruleProviders)
          if (provider.isRemote) provider.url: provider.label,
      },
      proxies: [for (final proxy in proxies) proxy.definition],
      groupNames: groupNames.toSet(),
    );
    try {
      return await compute(readCustomProfileImport, (bytes: bytes, app: app));
    } on CustomImportException catch (error) {
      final appLocalizations = currentAppLocalizations;
      throw MessageException(switch (error.issue) {
        CustomImportIssue.unreadable => appLocalizations.importConfigInvalid,
        CustomImportIssue.ruleType => appLocalizations.failedItem(
          error.item,
          appLocalizations.ruleTextInvalid,
        ),
        CustomImportIssue.entry => appLocalizations.failedItem(
          error.item,
          error.detail,
        ),
      });
    }
  }

  /// [config] replaces what [profileId] holds. The providers it adds are saved
  /// before the groups and rules naming them, and loaded afterwards; the
  /// future completes once they have loaded.
  Future<void> importCustomProfile(int profileId, CustomProfileImport config) {
    final profiles = ref.read(profilesProvider.notifier);
    final clashProviders = ref.read(clashProvidersProvider.notifier);
    final loads = <({String label, Future<void> Function() load})>[];
    for (final (:label, :url, :content) in config.proxyProviders) {
      final profile = Profile.normal(label: label, url: url);
      profiles.put(profile);
      loads.add((
        label: label,
        load: url.isNotEmpty
            ? () => updateProfile(profile, showLoading: true)
            : () async => profiles.put(
                await profile.saveFile(
                  utf8.encode(content),
                  validate: (path) => _core.validateProfile(path),
                ),
              ),
      ));
    }
    for (final (:label, :url, :content) in config.ruleProviders) {
      final provider = ClashProvider.create(label: label, url: url);
      clashProviders.put(provider);
      loads.add((
        label: label,
        load: url.isNotEmpty
            ? () => ref
                  .read(resourcesActionProvider.notifier)
                  .updateRuleProvider(provider)
            : () => ref
                  .read(clashProvidersActionProvider.notifier)
                  .putProvider(provider, content: utf8.encode(content)),
      ));
    }
    final customProxies = ref.read(customProxiesProvider.notifier);
    customProxies.putAll([
      for (final definition in config.proxies)
        CustomProxy.fromDefinition(definition),
    ]);
    final proxyIds = {
      for (final proxy in customProxies.value) proxy.name: proxy.id,
    };
    ref.read(proxyGroupsProvider(profileId).notifier).setAll([
      for (final group in config.proxyGroups) group.copyWith(id: snowflake.id),
    ]);
    ref.read(profileRulesProvider(profileId).notifier).setAll([
      for (final rule in config.rules) rule.copyWith(id: snowflake.id),
    ]);
    ref.read(proxyDialersProvider(profileId).notifier).setAll({
      for (final MapEntry(:key, :value) in config.dialers.entries)
        ?proxyIds[key]: value,
    });
    profiles.updateProfile(
      profileId,
      (profile) => profile.copyWith(overrides: config.overrides),
    );
    return globalState.batchRun(
      loads,
      (item) => item.load(),
      label: (item) => item.label,
      concurrency: maxConcurrentImports,
      tag: null,
    );
  }

  void _showProfiles() {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
  }

  Future<void> addProfileFromLink(String link, {String? label}) async {
    _showProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => link.isShareLink
          ? _fromShareLinks(Profile.normal(label: label), [link])
          : _download(Profile.normal(label: label, url: link)),
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  /// Ids are taken up front so the list keeps the order of [links]; the share
  /// links among them make up one profile, in the place of the first.
  Future<void> addProfilesFromLinks(List<String> links) async {
    _showProfiles();
    final shareLinks = [
      for (final link in links)
        if (link.isShareLink) link,
    ];
    await globalState.batchRun(
      [
        for (final link in links)
          if (!link.isShareLink)
            (profile: Profile.normal(url: link), shareLinks: const <String>[])
          else if (link == shareLinks.first)
            (profile: Profile.normal(), shareLinks: shareLinks),
      ],
      (item) async => putProfile(
        await (item.shareLinks.isEmpty
            ? _download(item.profile)
            : _fromShareLinks(item.profile, item.shareLinks)),
      ),
      label: (item) => item.shareLinks.firstOrNull ?? item.profile.url,
      concurrency: maxConcurrentImports,
      tag: LoadingTag.profiles,
    );
  }

  Future<Profile> _download(Profile profile) {
    return profile.update(validate: (path) => _core.validateProfile(path));
  }

  Future<Profile> _fromShareLinks(Profile profile, List<String> links) async {
    final appLocalizations = currentAppLocalizations;
    final decoded = await _core.decodeShareLinks(links);
    final taken = {...reservedProxyNames};
    final proxies = <Map<String, dynamic>>[];
    for (final (index, definitions) in decoded.indexed) {
      if (definitions.isEmpty) {
        throw MessageException(
          links.length == 1
              ? appLocalizations.shareLinksInvalid
              : appLocalizations.shareLinkUnreadable(links[index]),
        );
      }
      for (final definition in definitions) {
        final name = freeProxyName(linkProxyName(definition), taken);
        proxies.add({...definition, 'name': name});
      }
    }
    final first = proxies.first['name'] as String;
    final label = proxies.length == 1
        ? first
        : appLocalizations.proxiesProfileLabel(first, proxies.length);
    final config = await encodeYamlTask({'proxies': proxies});
    return profile
        .copyWith(label: profile.label.takeFirstValid([label]))
        .saveFile(
          utf8.encode(config),
          validate: (path) => _core.validateConfig(path),
        );
  }

  void setProfileAndAutoApply(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFromLink(url));
  }

  void reorder(List<Profile> profiles) {
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    try {
      final error = await _core.clearEffect(profileId);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    } catch (error) {
      commonPrint.log(
        'clearEffect($profileId) failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}
