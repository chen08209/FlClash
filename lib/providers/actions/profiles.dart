part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  final Set<int> _freeNodesAutoUpdatingIds = {};
  final Set<int> _freeNodesAutoPreferringIds = {};

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

  Future<bool> selectProfile(int profileId) async {
    final currentProfileId = ref.read(currentProfileIdProvider);
    final profile = ref.read(profilesProvider).getProfile(profileId);
    if (profile == null || currentProfileId == profileId) return false;
    ref.read(currentProfileIdProvider.notifier).value = profileId;
    if (shouldCheckFreeNodesAutoUpdateOnProfileSelection(
      currentProfileId: currentProfileId,
      selectedProfileId: profileId,
      isFreeNodesProfile: profile.isFreeNodesProfile,
      autoUpdate: profile.autoUpdate,
    )) {
      try {
        await _autoUpdateFreeNodesProfile(profile);
        return true;
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
    return false;
  }

  Future<bool> checkFreeNodesProfileAutoUpdateIfNeeded(int profileId) async {
    final profile = ref.read(profilesProvider).getProfile(profileId);
    if (profile == null || !profile.isFreeNodesProfile || !profile.autoUpdate) {
      return false;
    }
    await _autoUpdateFreeNodesProfile(profile);
    return true;
  }

  Future<void> deleteProfile(int id) async {
    final profile = ref.read(profilesProvider).getProfile(id);
    if (profile?.isFreeNodesProfile == true) return;
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
        ref.read(setupActionProvider.notifier).setRunning(false);
      }
    }
  }

  Future<void> autoUpdateProfiles({bool includeFreeNodes = true}) async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      if (profile.isFreeNodesProfile) {
        if (!includeFreeNodes) continue;
        try {
          await _autoUpdateFreeNodesProfile(profile);
        } catch (e) {
          commonPrint.log(e.toString(), logLevel: LogLevel.warning);
        }
        continue;
      }
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> _putProfileAndPersist(Profile profile) async {
    await ref.read(profilesProvider.notifier).putAndWait(profile);
  }

  void _setFreeNodesProgress(FreeNodesProgress progress) {
    if (!ref.mounted) return;
    ref.read(freeNodesFetchProgressProvider.notifier).value = progress;
  }

  Future<Profile> _updateFreeNodesProfile(
    Profile profile, {
    Set<String>? sourceIds,
    bool silent = false,
    String? runningOperation,
  }) async {
    final startedAt = DateTime.now();
    if (!silent) {
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: runningOperation ?? '开始获取节点',
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          startedAt: startedAt,
        ),
      );
    }
    try {
      return await freeNodesService.updateProfile(
        profile,
        sourceIds: sourceIds,
        onPartialProfile: silent
            ? null
            : (partialProfile) async {
                if (!ref.mounted) return;
                await _putProfileAndPersist(partialProfile);
              },
        onProgress: silent
            ? null
            : (progress) {
                _setFreeNodesProgress(
                  runningOperation == null
                      ? progress.copyWith(
                          startedAt: startedAt,
                          finishedAt: progress.done || progress.error
                              ? DateTime.now()
                              : null,
                        )
                      : buildFreeNodesAutoUpdateFetchProgress(
                          progress: progress,
                          runningOperation: runningOperation,
                          startedAt: startedAt,
                          proxyCount: profile.subscriptionInfo?.total ?? 0,
                        ),
                );
              },
      );
    } catch (e) {
      if (!silent) {
        _setFreeNodesProgress(
          FreeNodesProgress(
            operation: e.toString(),
            error: true,
            startedAt: startedAt,
            finishedAt: DateTime.now(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _autoUpdateFreeNodesProfile(Profile profile) async {
    if (!_freeNodesAutoUpdatingIds.add(profile.id)) {
      if (!ref.mounted) return;
      final currentProgress = ref.read(freeNodesFetchProgressProvider);
      _setFreeNodesProgress(
        buildFreeNodesAutoUpdateRunningProgress(
          proxyCount: profile.subscriptionInfo?.total ?? 0,
          currentProgress: currentProgress,
          preserveTerminalProgress: true,
        ),
      );
      return;
    }
    final startedAt = DateTime.now();
    if (!ref.mounted) {
      _freeNodesAutoUpdatingIds.remove(profile.id);
      return;
    }
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final resumeSession = await freeNodesService.getInterruptedFetchSession(
        profile,
      );
      final file = await profile.existingFile;
      final fileExists = await file.exists();
      final dueSourceIds = await freeNodesService.getDueSourceIds();
      if (!ref.mounted) return;
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: fileExists,
        hasLastUpdateDate: profile.lastUpdateDate != null,
        hasDueSources: dueSourceIds.isNotEmpty,
        hasInterruptedSession: resumeSession != null,
      );
      if (!decision.shouldUpdate) {
        final visibleDelay = remainingFreeNodesAutoUpdateVisibleDelay(
          startedAt: startedAt,
        );
        if (visibleDelay > Duration.zero) {
          await Future<void>.delayed(visibleDelay);
        }
        if (!ref.mounted) return;
        _setFreeNodesProgress(
          buildFreeNodesAutoUpdateNoopProgress(
            proxyCount: profile.subscriptionInfo?.total ?? 0,
            startedAt: startedAt,
          ),
        );
        if (shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: profile.id == ref.read(currentProfileIdProvider),
          shouldUpdate: decision.shouldUpdate,
          hasLoadedGroups: ref.read(groupsProvider).isNotEmpty,
        )) {
          await _applyFreeNodesProfileIfCurrent(profile);
        }
        return;
      }
      final sourceIds =
          resumeSession?.sourceIds ??
          (decision.kind == FreeNodesAutoUpdateKind.dueSources
              ? dueSourceIds
              : null);
      final runningOperation = resumeSession == null
          ? decision.operation
          : '正在继续上次获取';
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: runningOperation,
          completed: resumeSession?.completedSources ?? 0,
          total: resumeSession?.sourceIds.length ?? sourceIds?.length ?? 0,
          successfulSources: resumeSession?.successfulSources ?? 0,
          failedSources: resumeSession?.failedSources ?? 0,
          proxyCount:
              resumeSession?.proxyCount ?? profile.subscriptionInfo?.total ?? 0,
          startedAt: startedAt,
        ),
      );
      await updateProfile(
        profile,
        freeNodeSourceIds: sourceIds,
        silentFreeNodes: false,
        freeNodesRunningOperation: runningOperation,
      );
    } finally {
      _freeNodesAutoUpdatingIds.remove(profile.id);
      if (ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            false;
      }
    }
  }

  Future<void> _applyFreeNodesProfileIfCurrent(Profile profile) async {
    if (!ref.mounted) return;
    if (profile.id != ref.read(currentProfileIdProvider)) return;
    await ref
        .read(setupActionProvider.notifier)
        .applyProfile(silence: true, force: true);
  }

  Future<bool> _autoPreferFreeNodesAfterFetch(
    Profile profile, {
    bool silent = false,
  }) async {
    final preferenceState = await freeNodesService.getPreferenceState();
    if (!preferenceState.autoPrefer) return false;
    if (await freeNodesService.wasAutoPreferredToday()) return false;
    if (!_freeNodesAutoPreferringIds.add(profile.id)) return false;
    try {
      if (await freeNodesService.wasAutoPreferredToday()) return false;
      await preferFreeNodesProfile(
        profile,
        deleteExpiredGroups: preferenceState.deleteExpiredOnPrefer,
      );
      await freeNodesService.markAutoPreferredToday();
      return true;
    } catch (e) {
      commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      if (!silent) {
        _setFreeNodesProgress(
          FreeNodesProgress(operation: e.toString(), error: true),
        );
      }
      return false;
    } finally {
      _freeNodesAutoPreferringIds.remove(profile.id);
    }
  }

  Future<bool> ensureFreeNodesProfile({
    bool update = true,
    bool normalizeExisting = false,
  }) async {
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    if (current == null && await preferences.getBool(freeNodesDisabledKey)) {
      await preferences.setBool(freeNodesDisabledKey, false);
    }
    var profile = current ?? freeNodesService.createProfile();
    if (current == null) {
      await _putProfileAndPersist(profile);
    } else if (normalizeExisting) {
      final normalizedProfile = await freeNodesService.normalizeExistingProfile(
        profile,
      );
      if (normalizedProfile != null) {
        profile = normalizedProfile;
        await _putProfileAndPersist(profile);
      }
    }
    final currentProfileId = ref.read(currentProfileIdProvider);
    final hasCurrentProfile =
        currentProfileId != null &&
        ref.read(profilesProvider).any((item) => item.id == currentProfileId);
    if (!hasCurrentProfile) {
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
    }
    if (!update || !profile.autoUpdate) return false;
    if (_freeNodesAutoUpdatingIds.contains(profile.id)) return true;
    final resumeSession = await freeNodesService.getInterruptedFetchSession(
      profile,
    );
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    _setFreeNodesProgress(
      buildFreeNodesAutoUpdateStartProgress(
        firstLaunch: current == null,
        resuming: resumeSession != null,
        proxyCount:
            resumeSession?.proxyCount ?? profile.subscriptionInfo?.total ?? 0,
      ),
    );
    unawaited(
      _autoUpdateFreeNodesProfile(profile).catchError((e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }),
    );
    return true;
  }

  Future<bool> resumeInterruptedFreeNodesIfNeeded() async {
    final profile = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    if (profile == null || !profile.autoUpdate) return false;
    final session = await freeNodesService.getInterruptedFetchSession(profile);
    if (session == null) return false;
    if (_freeNodesAutoUpdatingIds.contains(profile.id)) return true;
    _setFreeNodesProgress(
      FreeNodesProgress(
        operation: '等待继续上次获取',
        completed: session.completedSources,
        total: session.sourceIds.length,
        successfulSources: session.successfulSources,
        failedSources: session.failedSources,
        proxyCount: session.proxyCount,
      ),
    );
    unawaited(
      _autoUpdateFreeNodesProfile(profile).catchError((e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }),
    );
    return true;
  }

  Future<void> updateFreeNodesProfile({bool showLoading = false}) async {
    await preferences.setBool(freeNodesDisabledKey, false);
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    final profile = current ?? freeNodesService.createProfile();
    final previousCurrentProfileId = ref.read(currentProfileIdProvider);
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
    try {
      final resumeSession = await freeNodesService.getInterruptedFetchSession(
        profile,
      );
      await updateProfile(
        profile,
        showLoading: showLoading,
        freeNodeSourceIds: resumeSession?.sourceIds,
        freeNodesRunningOperation: resumeSession == null ? null : '正在继续上次获取',
      );
    } catch (_) {
      if (current == null && ref.mounted) {
        ref.read(currentProfileIdProvider.notifier).value =
            previousCurrentProfileId;
      }
      rethrow;
    }
  }

  Future<void> removeFreeNodesProfile({bool update = true}) async {
    await preferences.setBool(freeNodesDisabledKey, false);
    final profile =
        ref
            .read(profilesProvider)
            .firstWhereOrNull((profile) => profile.isFreeNodesProfile) ??
        freeNodesService.createProfile();
    if (!ref.read(profilesProvider).any((item) => item.id == profile.id)) {
      await _putProfileAndPersist(profile);
    }
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
    if (!update) {
      _setFreeNodesProgress(
        const FreeNodesProgress(operation: '已恢复', done: true),
      );
      return;
    }
    await updateProfile(profile, showLoading: true);
  }

  Future<FreeNodesPreferResult> preferFreeNodesProfile(
    Profile profile, {
    bool? deleteExpiredGroups,
  }) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.preferProfile(
        profile,
        deleteExpiredGroups: deleteExpiredGroups,
      );
      final savedProfile = result.profile;
      if (savedProfile != null) {
        await _putProfileAndPersist(savedProfile);
        if (profile.id == ref.read(currentProfileIdProvider)) {
          await _applyFreeNodesProfileIfCurrent(savedProfile);
        }
      }
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: result.removedCount > 0
              ? '已优选，删除 ${result.removedCount} 个超时节点'
              : '已优选，已整合优选节点',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<FreeNodesGroupEditResult> preferFreeNodesGroup(
    Profile profile,
    String groupName,
  ) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.preferGroup(profile, groupName);
      await _saveFreeNodesGroupEdit(profile, result);
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: '已优选 $groupName',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<FreeNodesGroupEditResult> deleteFreeNodesDateGroup(
    Profile profile,
    String groupName,
  ) async {
    ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
    try {
      final result = await freeNodesService.deleteDateGroup(profile, groupName);
      await _saveFreeNodesGroupEdit(profile, result);
      _setFreeNodesProgress(
        FreeNodesProgress(
          operation: '已移入优选节点 ${result.affectedCount} 个节点',
          proxyCount: result.afterCount,
          done: true,
        ),
      );
      return result;
    } finally {
      ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<void> _saveFreeNodesGroupEdit(
    Profile profile,
    FreeNodesGroupEditResult result,
  ) async {
    final savedProfile = result.profile;
    if (savedProfile == null) return;
    await _putProfileAndPersist(savedProfile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      await _applyFreeNodesProfileIfCurrent(savedProfile);
    }
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file || profile.isFreeNodesProfile) {
        continue;
      }
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
    Set<String>? freeNodeSourceIds,
    bool silentFreeNodes = false,
    String? freeNodesRunningOperation,
  }) async {
    final showUpdating =
        showLoading || (profile.isFreeNodesProfile && !silentFreeNodes);
    try {
      if (showUpdating && ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = true;
      }
      if (shouldPersistProfileBeforeRemoteUpdate(profile)) {
        await _putProfileAndPersist(profile);
      }
      if (!ref.mounted) return;
      final newProfile = profile.isFreeNodesProfile
          ? await _updateFreeNodesProfile(
              profile,
              sourceIds: freeNodeSourceIds,
              silent: silentFreeNodes,
              runningOperation: freeNodesRunningOperation,
            )
          : await profile.update();
      if (!ref.mounted) return;
      await _putProfileAndPersist(newProfile);
      if (!ref.mounted) return;
      if (profile.isFreeNodesProfile) {
        final didAutoPrefer = await _autoPreferFreeNodesAfterFetch(
          newProfile,
          silent: silentFreeNodes,
        );
        if (!ref.mounted) return;
        if (!didAutoPrefer) {
          await _applyFreeNodesProfileIfCurrent(newProfile);
        }
      } else if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    } finally {
      if (showUpdating && ref.mounted) {
        ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            false;
      }
    }
  }

  Future<void> addFreeNodesProfile() async {
    await preferences.setBool(freeNodesDisabledKey, false);
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final current = ref
        .read(profilesProvider)
        .firstWhereOrNull((profile) => profile.isFreeNodesProfile);
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        final target = current ?? freeNodesService.createProfile();
        return _updateFreeNodesProfile(target);
      },
      title: freeNodesProfileLabel,
    );
    if (profile != null) {
      await _putProfileAndPersist(profile);
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
      final didAutoPrefer = await _autoPreferFreeNodesAfterFetch(profile);
      if (!didAutoPrefer) {
        await _applyFreeNodesProfileIfCurrent(profile);
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
        return Profile.normal(label: platformFile.name).saveFile(bytes);
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) putProfile(profile);
  }

  Future<void> addProfileFormURL(String url, {String sourceUrl = ''}) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(url: url).copyWith(sourceUrl: sourceUrl).update();
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) putProfile(profile);
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
    addProfileFormURL(url);
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
    final error = await coreController.clearEffect(profileId);
    if (error.isNotEmpty) {
      commonPrint.log(error, logLevel: LogLevel.warning);
    }
  }
}
