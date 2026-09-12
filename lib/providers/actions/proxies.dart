part of '../action.dart';

class _DelayTestTarget {
  const _DelayTestTarget({
    required this.proxyName,
    required this.testUrl,
    required this.key,
  });

  final String proxyName;
  final String testUrl;
  final String key;
}

class _DelayTestJob {
  _DelayTestJob(Iterable<String> keys) : held = keys.toSet();

  final Set<String> held;
  bool cancelled = false;
}

@Riverpod(keepAlive: true)
class ProxiesAction extends _$ProxiesAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  final TaskPool _delayTestPool = TaskPool(maxConcurrentDelayTests);

  final List<_DelayTestJob> _delayTestJobs = [];

  final Map<String, String> _pendingSelectedRollback = {};
  final Map<String, Object> _selectionOperations = {};
  int _delayTestGeneration = 0;

  int get delayTestGeneration => _delayTestGeneration;

  @override
  void build() {
    ref.listen(currentProfileIdProvider, (_, _) {
      _selectionOperations.clear();
      _pendingSelectedRollback.clear();
      cancelDelayTests();
    });
    ref.listen(profilesProvider, (previous, next) {
      final id = ref.read(currentProfileIdProvider);
      final before = previous?.getProfile(id)?.selectedMap;
      final after = next.getProfile(id)?.selectedMap;
      _selectionOperations.removeWhere((group, _) {
        if (before?[group] == after?[group]) return false;
        _pendingSelectedRollback.remove(group);
        return true;
      });
    });
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected) {
        cancelDelayTests();
      }
    });
  }

  void cancelDelayTests() {
    _delayTestGeneration++;
    for (final job in _delayTestJobs) {
      job.cancelled = true;
      job.held.clear();
    }
    ref.read(pendingDelayTestsProvider.notifier).clear();
  }

  void updateGroupsDebounce([Duration? duration]) {
    debouncer.call(FunctionTag.updateGroups, updateGroups, duration: duration);
  }

  void changeProxyDebounce(String groupName, String proxyName) {
    _selectionOperations.remove(groupName);
    _pendingSelectedRollback.putIfAbsent(
      groupName,
      () => _currentSelectedName(groupName),
    );
    ref
        .read(profilesActionProvider.notifier)
        .updateCurrentSelectedMap(groupName, proxyName);
    final operation = Object();
    _selectionOperations[groupName] = operation;
    debouncer.call((FunctionTag.changeProxy, groupName), (
      String groupName,
      String proxyName,
    ) async {
      if (!ref.mounted ||
          !identical(_selectionOperations[groupName], operation)) {
        return;
      }
      await changeProxy(groupName: groupName, proxyName: proxyName);
      updateGroupsDebounce();
    }, args: [groupName, proxyName]);
  }

  String _currentSelectedName(String groupName) {
    return ref.read(currentProfileProvider)?.selectedMap[groupName] ?? '';
  }

  Future<void> updateGroups() async {
    try {
      commonPrint.log('updateGroups');
      ref.read(groupsProvider.notifier).value = await retry(
        task: () async {
          final sortType = ref.read(
            proxiesStyleSettingProvider.select((state) => state.sortType),
          );
          final delayMap = ref.read(delayDataSourceProvider);
          final testUrl = ref.read(
            appSettingProvider.select((state) => state.testUrl),
          );
          final selectedMap = ref.read(
            currentProfileProvider.select((state) => state?.selectedMap ?? {}),
          );
          try {
            return await _core.getProxiesGroups(
              selectedMap: selectedMap,
              sortType: sortType,
              delayMap: delayMap,
              defaultTestUrl: testUrl,
            );
          } catch (e) {
            commonPrint.log(
              'updateGroups error: $e',
              logLevel: coreFailureLogLevel(e),
            );
            return [];
          }
        },
        retryIf: (res) => res.isEmpty,
      );
    } catch (e) {
      // The Core failure path already runs inside the retry task above; a
      // throw here only means ref.read hit a disposed container or the
      // groupsProvider write itself failed.
      commonPrint.log(
        'updateGroups failed: $e',
        logLevel: coreFailureLogLevel(e),
      );
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) return;
    ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile == null) return;
    ref
        .read(profilesProvider.notifier)
        .put(currentProfile.copyWith(unfoldSet: value));
  }

  void setDelay(Delay delay) {
    ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  Future<bool> changeProxy({
    required String groupName,
    required String proxyName,
    bool notifyFailure = true,
    bool maintainConnections = true,
    void Function()? checkContinuation,
  }) async {
    checkContinuation?.call();
    final profileId = ref.read(currentProfileIdProvider);
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final rollbackName =
        _pendingSelectedRollback.remove(groupName) ??
        _currentSelectedName(groupName);
    profilesAction.updateCurrentSelectedMap(groupName, proxyName);
    final operation = Object();
    _selectionOperations[groupName] = operation;

    bool isCurrent() {
      if (!ref.mounted ||
          ref.read(currentProfileIdProvider) != profileId ||
          !identical(_selectionOperations[groupName], operation)) {
        return false;
      }
      checkContinuation?.call();
      return true;
    }

    try {
      try {
        final message = await _core.changeProxy(
          ChangeProxyParams(groupName: groupName, proxyName: proxyName),
        );
        if (message.isNotEmpty) throw StateError(message);
      } catch (error) {
        if (!isCurrent()) return false;
        commonPrint.log(
          'changeProxy($groupName -> $proxyName) failed: $error',
          logLevel: coreFailureLogLevel(error),
        );
        profilesAction.updateCurrentSelectedMap(groupName, rollbackName);
        if (notifyFailure) {
          dialogs.showNotifier(
            currentAppLocalizations.changeProxyFailedTip,
            level: MessageLevel.error,
          );
        }
        return false;
      }
      if (!isCurrent()) return false;
      if (maintainConnections) {
        try {
          if (ref.read(appSettingProvider).closeConnections) {
            await _core.closeConnections();
          } else {
            await _core.resetConnections();
          }
        } catch (error) {
          commonPrint.log(
            'changeProxy($groupName -> $proxyName) connection reset failed: $error',
            logLevel: coreFailureLogLevel(error),
          );
        }
      }
      if (!isCurrent()) return false;
      ref.read(checkIpNumProvider.notifier).add();
      return true;
    } finally {
      if (identical(_selectionOperations[groupName], operation)) {
        _selectionOperations.remove(groupName);
      }
    }
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref
              .read(updatingKeysProvider.notifier)
              .start(provider.updatingKey, scope: UpdatingScope.core)
        : null;
    try {
      final message = await _core.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) return message;
      ref
          .read(providersProvider.notifier)
          .setProvider(await _core.getExternalProvider(provider.name));
      return '';
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(provider.updatingKey, operation);
      }
    }
  }

  Future<String> sideLoadExternalProvider(
    ExternalProvider provider,
    String data, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref
              .read(updatingKeysProvider.notifier)
              .start(provider.updatingKey, scope: UpdatingScope.core)
        : null;
    try {
      final message = await _core.sideLoadExternalProvider(
        providerName: provider.name,
        data: data,
      );
      if (message.isNotEmpty) return message;
      ref
          .read(providersProvider.notifier)
          .setProvider(await _core.getExternalProvider(provider.name));
      return '';
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(provider.updatingKey, operation);
      }
    }
  }

  Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) {
    return _runDelayTests([proxy], testUrl);
  }

  Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
    await _runDelayTests(proxies, testUrl);
    ref.read(sortNumProvider.notifier).add();
  }

  List<_DelayTestTarget> _resolveDelayTestTargets(
    List<Proxy> proxies,
    String? testUrl,
  ) {
    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(
      currentProfileProvider.select((state) => state?.selectedMap ?? {}),
    );
    final fallbackTestUrl = ref.read(realTestUrlProvider(testUrl));
    final seen = <String>{};
    final targets = <_DelayTestTarget>[];
    for (final proxy in proxies) {
      final state = computeRealSelectedProxyState(
        proxy.name,
        groups: groups,
        selectedMap: selectedMap,
      );
      if (state.proxyName.isEmpty) {
        continue;
      }
      final currentTestUrl = state.testUrl.takeFirstValid([fallbackTestUrl]);
      final key = delayTestKey(currentTestUrl, state.proxyName);
      if (!seen.add(key)) {
        continue;
      }
      targets.add(
        _DelayTestTarget(
          proxyName: state.proxyName,
          testUrl: currentTestUrl,
          key: key,
        ),
      );
    }
    return targets;
  }

  Future<void> _runDelayTests(List<Proxy> proxies, String? testUrl) async {
    final targets = _resolveDelayTestTargets(proxies, testUrl);
    if (targets.isEmpty) {
      return;
    }
    final pending = ref.read(pendingDelayTestsProvider.notifier);
    final job = _DelayTestJob(targets.map((target) => target.key));
    _delayTestJobs.add(job);
    pending.acquire(job.held);
    try {
      await Future.wait(
        targets.map(
          (target) => _delayTestPool.run(() => _runDelayTest(job, target)),
        ),
      );
    } finally {
      _delayTestJobs.remove(job);
      final abandoned = job.held.toList();
      job.held.clear();
      pending.release(abandoned);
    }
  }

  Future<void> _runDelayTest(_DelayTestJob job, _DelayTestTarget target) async {
    if (job.cancelled) {
      return;
    }
    try {
      final delay = await _core.getDelay(target.testUrl, target.proxyName);
      if (delay != null && !job.cancelled) {
        setDelay(delay);
      }
    } catch (error) {
      if (error is CoreMethodException && error.isCoreUnavailable) {
        job.cancelled = true;
      }
      commonPrint.log(
        'Delay test failed for ${target.proxyName}: $error',
        logLevel: coreFailureLogLevel(error),
      );
    } finally {
      if (job.held.remove(target.key)) {
        ref.read(pendingDelayTestsProvider.notifier).release([target.key]);
      }
    }
  }
}
