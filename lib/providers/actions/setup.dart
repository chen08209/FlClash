part of '../action.dart';

enum _SetupTaskResult { completed, handoffToCoreRestart, failed }

typedef _SetupInputs = (
  SetupState,
  PatchClashConfig,
  NetworkProps,
  SetupParams,
);

typedef BuiltProfile = ({
  String yaml,
  String md5,
  ConfigCounts counts,
  SetupBase? base,
});

class _RunRequest {
  final bool running;
  final bool initialize;

  /// Adopts a run the Android service has, config and groups alike.
  final bool resume;
  final DateTime? previousStartTime;

  const _RunRequest({
    required this.running,
    required this.initialize,
    required this.resume,
    required this.previousStartTime,
  });
}

@Riverpod(keepAlive: true)
class SetupAction extends _$SetupAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  Timer? _runtimeTimer;
  final _setupScheduler = SerialTaskScheduler();
  final _listenerScheduler = SerialTaskScheduler();
  _RunRequest? _latestRunRequest;
  Future<void>? _initialRun;
  DateTime? _startTime;
  var _resumeOnRestart = false;
  ({String digest, Set<String> names})? _outboundNames;
  _SetupInputs? _appliedInputs;
  var _lastPushDuration = Duration.zero;
  var _pendingForceApply = false;

  Future<void> _loadConfigWarnings() async {
    try {
      final warnings = await _core.getConfigWarnings();
      ref.read(configWarningsStateProvider.notifier).report(warnings);
    } catch (error) {
      commonPrint.log(
        'config warnings unavailable: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  @override
  void build() {
    ref.onDispose(_stopRuntimeTicker);
    ref.listen(appVisibleProvider, (_, _) => _syncRuntimeTicker());
    ref.listen(
      appSettingProvider.select((state) => state.showTrayTitle),
      (_, _) => _syncRuntimeTicker(),
    );
  }

  bool get _isTrafficShown =>
      ref.read(appVisibleProvider) ||
      (system.isMacOS &&
          !ref.read(safeModeProvider) &&
          ref.read(appSettingProvider).showTrayTitle);

  SetupParams get _setupParams => SetupParams(
    selectedMap: ref.read(selectedMapProvider),
    options: ref.read(coreOptionsProvider),
    host: hostSettingsOf(
      ref.read(patchClashConfigProvider),
      credential: ref.read(hostCredentialProvider),
      safeMode: ref.read(safeModeProvider),
    ),
  );

  // The selection reaches the Core through changeProxy and the host settings
  // through a patch, not through an apply.
  SetupParams get _appliedParams =>
      _setupParams.copyWith(selectedMap: const {}, host: null);

  Future<bool> fullSetup() async {
    if (!ref.read(initProvider)) return true;
    ref.read(proxiesActionProvider.notifier).cancelDelayTests();
    ref.read(delayDataSourceProvider.notifier).value = {};
    final setupResult = applyProfile(force: true);
    ref.read(logsProvider.notifier).value = FixedList(maxLogsLength);
    ref.read(requestsProvider.notifier).value = ConnectionLog(
      maxRequestsLength,
    );
    ref.read(dnsQueriesProvider.notifier).value = FixedList(
      maxDnsQueriesLength,
    );
    ref.read(dnsQueryCountProvider.notifier).value = 0;
    ref.read(requestCountProvider.notifier).value = 0;
    try {
      return await setupResult;
    } catch (e, s) {
      commonPrint.log('fullSetup ===> ${compactError(e)}, $s');
      return false;
    }
  }

  void _setLocalRunning(bool running) {
    _stopRuntimeTicker();
    if (!running) {
      _startTime = null;
      ref.read(commonActionProvider.notifier).setTrafficFeed(false);
      debouncer.cancel(FunctionTag.applyProfile);
      _pendingForceApply = false;
      _updateRunTime();
      return;
    }

    _startTime ??= clock.now();
    _updateRunTime();
    _syncRuntimeTicker();
  }

  void _syncRuntimeTicker() {
    final shown = _startTime != null && _isTrafficShown;
    ref.read(commonActionProvider.notifier).setTrafficFeed(shown);
    if (!shown) {
      _stopRuntimeTicker();
      return;
    }
    if (_runtimeTimer != null) {
      return;
    }
    _refreshRunningState();
    _runtimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshRunningState(),
    );
  }

  void _stopRuntimeTicker() {
    _runtimeTimer?.cancel();
    _runtimeTimer = null;
  }

  void _refreshRunningState() {
    _updateRunTime();
  }

  void _updateRunTime() {
    final startTime = _startTime;
    ref.read(runTimeProvider.notifier).value = startTime == null
        ? null
        : clock.now().millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
  }

  @protected
  Future<DateTime?> serviceStartTime() async => service?.getRunTime();

  Future<void> initStatus() async {
    if (_initialRun == null) {
      await _restoreStatus();
    }
    Future<void>? joined;
    while (!identical(joined, _initialRun)) {
      joined = _initialRun;
      await joined;
    }
  }

  Future<void> _restoreStatus() async {
    final startTime = await serviceStartTime();
    final running = startTime?.isBeforeNow ?? false;
    final digest = running ? await preferences.getAppliedConfigMd5() : null;
    if (_initialRun != null) {
      return;
    }
    _startTime = startTime;
    if (running) {
      globalState.lastConfigMd5 = digest;
      await _run(true, initialize: true, resume: true);
    } else if (ref.read(appSettingProvider).autoRun) {
      await setRunning(true, initialize: true);
    } else {
      await globalState.safeRun(() => applyProfile(force: true));
    }
  }

  bool get wantsRunning => ref.read(isStartProvider) || _resumeOnRestart;

  /// The lost session gets no stop; work begun for the old run stops counting.
  void onCoreLost() {
    if (_startTime == null) {
      return;
    }
    _resumeOnRestart = true;
    _latestRunRequest = null;
    _setLocalRunning(false);
    ref.read(runningVpnOptionsProvider.notifier).value = null;
  }

  void resumeOnRestart() {
    _resumeOnRestart = true;
  }

  Future<bool> setRunning(bool running, {bool initialize = false}) {
    if (running && !initialize && !ref.read(initProvider)) {
      return Future.value(true);
    }
    return _run(running, initialize: running && initialize);
  }

  Future<bool> _run(
    bool running, {
    required bool initialize,
    bool resume = false,
  }) {
    final request = _RunRequest(
      running: running,
      initialize: initialize,
      resume: resume,
      previousStartTime: _startTime,
    );
    _latestRunRequest = request;
    _resumeOnRestart = false;
    _setLocalRunning(running);
    final task = running ? _start(request) : _stop(request);
    if (initialize || _initialRun != null && !ref.read(initProvider)) {
      // The caller reports the outcome. Bootstrap waits for the transition to settle.
      _initialRun = task.then<void>((_) {}, onError: (Object _) {});
    }
    return task;
  }

  Future<bool> _start(_RunRequest request) async {
    if (request.initialize) {
      var applied = false;
      try {
        applied = await applyProfile(
          force: !request.resume,
          preloadInvoke: () => _startCoreRunning(request),
        );
      } catch (error) {
        if (_isCurrent(request)) {
          dialogs.showBanner(
            userFacingErrorMessage(error, currentAppLocalizations),
            level: BannerLevel.error,
          );
        }
      }
      if (!applied && _isCurrent(request)) {
        await globalState.safeRun(() => setRunning(false));
      }
      return applied;
    }

    try {
      await _startCoreRunning(request);
    } catch (_) {
      _rollbackRunning(request);
      rethrow;
    }
    final applied = await inputsApplied();
    if (_isCurrent(request) && !applied) {
      applyProfileDebounce(force: true, silence: true);
    }
    return true;
  }

  Future<void> _startCoreRunning(_RunRequest request) async {
    try {
      await _setCoreRunning(request);
    } catch (error) {
      if (_isCurrent(request) || !_isUnanswered(error)) {
        rethrow;
      }
    }
  }

  Future<bool> _stop(_RunRequest request) async {
    (Object, StackTrace)? unanswered;
    try {
      await _setCoreRunning(request);
    } catch (error, stackTrace) {
      if (!_isUnanswered(error)) {
        _rollbackRunning(request);
        rethrow;
      }
      unanswered = (error, stackTrace);
    }
    if (!_isCurrent(request)) {
      return true;
    }
    resetCoreTraffic();
    ref.read(trafficsProvider.notifier).clear();
    ref.read(totalTrafficProvider.notifier).value = const Traffic();
    // A silent Core is gone or hung; running again would proxy traffic to it.
    if (unanswered case (final error, final stackTrace)) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    return true;
  }

  Future<void> _setCoreRunning(_RunRequest request) {
    return _listenerScheduler.run(() async {
      if (!_isCurrent(request) ||
          request.running && ref.read(suspendProvider) ||
          ref.read(safeModeProvider)) {
        return;
      }
      await _setListening(request.running);
    });
  }

  Future<void> _setListening(bool running) async {
    final vpnOptions = await ref.read(vpnOptionsProvider.future);
    try {
      await setCoreRunning(running);
    } catch (error) {
      if (_isUnanswered(error)) {
        ref.read(runningVpnOptionsProvider.notifier).value = null;
      }
      rethrow;
    }
    ref.read(runningVpnOptionsProvider.notifier).value = running
        ? vpnOptions
        : null;
  }

  bool _isUnanswered(Object error) =>
      isUnansweredCoreError(error) ||
      error is CoreMethodException && error.code == 'service_refused';

  /// An excluded SSID parks the listener without ending the run.
  void syncSuspend() {
    debouncer.call(FunctionTag.suspend, () {
      return _listenerScheduler.run(() async {
        if (!ref.read(isStartProvider) || ref.read(safeModeProvider)) {
          return;
        }
        try {
          await _setListening(!ref.read(suspendProvider));
        } catch (error) {
          if (!_isUnanswered(error)) {
            rethrow;
          }
        }
      });
    });
  }

  Future<void> restartVpn() async {
    if (!ref.read(isStartProvider)) {
      return;
    }
    await setRunning(false);
    await setRunning(true);
  }

  void _rollbackRunning(_RunRequest request) {
    if (!_isCurrent(request)) {
      return;
    }
    _startTime = request.previousStartTime;
    _setLocalRunning(!request.running);
  }

  bool _isCurrent(_RunRequest request) => identical(_latestRunRequest, request);

  Future<void> updateConfigDebounce() async {
    ref.read(coreStateSyncProvider).patchScheduled();
    debouncer.call(FunctionTag.updateConfig, updateConfig);
  }

  @protected
  Future<void> setCoreRunning(bool running) {
    return running ? _core.startListener() : _core.stopListener();
  }

  @protected
  void resetCoreTraffic() {
    _core.api.resetTraffic();
  }

  @visibleForTesting
  Future<void> updateConfig() async {
    await globalState.safeRun(() async {
      final patchConfig = ref.read(patchClashConfigProvider);
      final shouldContinueSetup = await requestAdmin(patchConfig.tun.enable);
      if (!shouldContinueSetup) {
        await _restartCoreAfterAuthorization();
        return;
      }
      final networkSetting = ref.read(networkSettingProvider);
      final sync = ref.read(coreStateSyncProvider);
      final token = sync.patchStarted();
      final seq = await _core.updateConfig(
        configPatchOf(
          _effectivePatchConfig(patchConfig),
          authentication: networkSetting.authentication.credentials,
          hostCredential: ref.read(hostCredentialProvider),
          options: ref.read(coreOptionsProvider),
        ),
      );
      sync.patched(token, seq);
    });
  }

  @protected
  Duration get minApplyDebounce => const Duration(seconds: 2);

  /// A push held up by a rule-set download or a Core timeout says little
  /// about the load, yet would hold back every apply after it.
  @protected
  Duration get maxApplyDebounce => const Duration(seconds: 10);

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    _pendingForceApply |= force;
    debouncer.call(
      FunctionTag.applyProfile,
      (silence) {
        final force = _pendingForceApply;
        _pendingForceApply = false;
        applyProfile(silence: silence, force: force);
      },
      args: [silence],
      duration: Duration(
        microseconds: _lastPushDuration.inMicroseconds.clamp(
          minApplyDebounce.inMicroseconds,
          maxApplyDebounce.inMicroseconds,
        ),
      ),
    );
  }

  void adoptCoreGeneral(GeneralChange change) {
    if (Mode.values.asNameMap()[change.mode] case final mode?
        when mode != ref.read(patchClashConfigProvider).mode) {
      changeMode(mode);
    }
    final mixedPort = change.mixedPort;
    final refusedPort = mixedPort != null && !isUsableMixedPort(mixedPort);
    final keptPort = ref.read(patchClashConfigProvider).mixedPort;
    if (mixedPort != null && !refusedPort && mixedPort != keptPort) {
      commonPrint.log('mixed-port $keptPort -> $mixedPort from the Core');
    }
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final overrides = state.generalOverrideKeys;
      return state.copyWith(
        logLevel:
            LogLevel.values.asNameMap()[change.logLevel] ?? state.logLevel,
        allowLan: change.allowLan ?? state.allowLan,
        mixedPort: refusedPort ? state.mixedPort : mixedPort ?? state.mixedPort,
        findProcessMode: switch (change.findProcessMode) {
          null => state.findProcessMode,
          final name =>
            FindProcessMode.values.asNameMap()[name] ?? FindProcessMode.strict,
        },
        ipv6: overrides.contains(GeneralOverrideKey.ipv6)
            ? change.ipv6 ?? state.ipv6
            : state.ipv6,
        tcpConcurrent: overrides.contains(GeneralOverrideKey.tcpConcurrent)
            ? change.tcpConcurrent ?? state.tcpConcurrent
            : state.tcpConcurrent,
      );
    });
    if (refusedPort) {
      dialogs.showMixedPortReset(mixedPort, keptPort);
      updateConfigDebounce();
    }
  }

  void changeMode(Mode mode) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(GroupName.GLOBAL.name);
    }
  }

  /// For leaving an editor: a profile whose inputs match the config the Core
  /// already runs is not rebuilt, which on a large profile takes a while.
  void autoApplyProfile() {
    runAfterFrame(() async {
      if (!await inputsApplied()) {
        await applyProfile();
      }
    });
  }

  void applyIfGlobalRulesUsed() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || profile.type == ProfileType.custom) {
      return;
    }
    applyProfileDebounce(silence: true);
  }

  /// Whether the Core runs what the current profile and settings make now.
  Future<bool> inputsApplied() async {
    final applied = _appliedInputs;
    if (applied == null) {
      return false;
    }
    final profileId = ref.read(currentProfileIdProvider);
    final SetupState setupState;
    try {
      setupState = await ref.read(setupStateProvider(profileId).future);
    } catch (_) {
      return false;
    }
    return applied ==
        (
          setupState,
          _effectivePatchConfig(ref.read(patchClashConfigProvider)),
          ref.read(networkSettingProvider),
          _appliedParams,
        );
  }

  // False means building the profile, the config write, or the Core setup
  // step failed; a profile that fails to build is still pushed to the Core
  // as the empty config so it never keeps serving the previous one.
  // authorizeCore failures still throw.
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final result = await _runSetup(
      force: force,
      silence: silence,
      preloadInvoke: preloadInvoke,
    );
    return result != _SetupTaskResult.failed;
  }

  Future<_SetupTaskResult> _runSetup({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final result = await _setupScheduler.run(() {
      return _setupConfig(
        force: force,
        silence: silence,
        preloadInvoke: preloadInvoke,
        onUpdated: () async {
          await ref.read(proxiesActionProvider.notifier).updateGroups();
          await ref.read(providersProvider.notifier).syncProviders();
        },
      );
    });
    if (result != _SetupTaskResult.handoffToCoreRestart) {
      return result;
    }
    // Release the current serial task before restartCore reapplies the profile.
    final restarted = await _restartCoreAfterAuthorization();
    return restarted ? _SetupTaskResult.completed : _SetupTaskResult.failed;
  }

  Future<bool> _restartCoreAfterAuthorization() async {
    try {
      return await ref.read(coreActionProvider.notifier).restartCore();
    } catch (_) {
      _forgetTunAuthorization();
      rethrow;
    }
  }

  /// A restart asks first, as [_setupConfig] would before handing off to it:
  /// the apply inside the restart must not hand off to the restart it runs in.
  /// Returns whether it was granted now.
  Future<bool> _authorizeTunBeforeRestart() async {
    return !await requestAdmin(ref.read(patchClashConfigProvider).tun.enable);
  }

  void _forgetTunAuthorization() {
    ref.read(authorizedTunEnableProvider.notifier).value =
        TunAuthorizationState.none;
  }

  /// With a base, [BuiltProfile.yaml] is only the overlay the Core applies.
  Future<BuiltProfile> getProfile({
    required SetupState setupState,
    required PatchClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    final defaultUA = globalState.packageInfo.ua;
    final networkSetting = ref.read(
      networkSettingProvider.select(
        (state) => (
          appendSystemDns: state.appendSystemDns,
          bypassPrivateRoute: state.bypassPrivateRoute,
          authentication: state.authentication,
        ),
      ),
    );
    final appendSystemDns = networkSetting.appendSystemDns;
    final isCustom = setupState.profileType == ProfileType.custom;
    final scriptContent = isCustom ? null : await setupState.script?.content;
    final hasScript = scriptContent?.isNotEmpty == true;
    final profileBase = profileId != null && !isCustom && !hasScript
        ? await _core.getProfileBase(profileId)
        : null;
    Map<String, dynamic> rawConfig = isCustom
        ? {
            'proxies': appProxiesPayload(
              setupState.appProxies,
              dialers: setupState.proxyDialers,
              groups: setupState.proxyGroups,
            ),
          }
        : profileBase?.base.config ??
              (profileId == null ? {} : await _core.readConfig(profileId));
    final proxyGroups = isCustom ? setupState.proxyGroups : <ProxyGroup>[];
    final rules = isCustom ? setupState.rules : <Rule>[];
    if (hasScript) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
    }
    final directory = await appPath.profilesPath;
    final hasCustomExit =
        setupState.addedRules.any((rule) => rule.customExit) ||
        setupState.mitmModules.any((module) => module.policies.isNotEmpty);
    final injected = await _resolveInjectedProviders(
      setupState,
      proxyGroups: proxyGroups,
      rules: rules,
    );
    final res = await makeRealProfileTask(
      MakeRealProfileState(
        rules: rules,
        proxyGroups: proxyGroups,
        injectedProxyProviders: injected.proxies,
        injectedRuleProviders: injected.rules,
        profilesPath: directory,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: patchConfig,
        overrides: setupState.overrides,
        bypassPrivateRoute: networkSetting.bypassPrivateRoute,
        appendSystemDns: appendSystemDns,
        addedRules: setupState.addedRules,
        defaultUA: defaultUA,
        authentication: networkSetting.authentication.credentials,
        exitTargets: setupState.exitTargets,
        outboundNames: switch ((profileId, profileBase)) {
          (final id?, final base?) when hasCustomExit => await _outboundNamesOf(
            id,
            base.base.digest,
          ),
          _ => null,
        },
        defaultExitTarget: profileBase == null
            ? null
            : lastMatchTarget(profileBase.base.matchRules),
        safeMode: ref.read(safeModeProvider),
        mitmModules: setupState.mitmModules,
        keepOverlay: profileBase != null,
      ),
    );
    if (profileBase == null) {
      return (yaml: res.yaml, md5: res.md5, counts: res.counts, base: null);
    }
    final (:base, :path) = profileBase;
    return (
      yaml: res.yaml,
      md5: '${res.md5}${base.digest}'.toMd5(),
      counts: (
        groups: res.counts.groups + base.proxyGroups,
        proxies: res.counts.proxies + base.proxies,
        rules: res.counts.rules + base.rules,
      ),
      base: SetupBase(path: path, overlay: res.overlay ?? const {}),
    );
  }

  Future<Set<String>> _outboundNamesOf(int profileId, String digest) async {
    final cached = _outboundNames;
    if (cached != null && cached.digest == digest) {
      return cached.names;
    }
    final outbounds = await _core.getProfileOutbounds(profileId);
    final names = outboundNamesOf(outbounds);
    _outboundNames = (digest: digest, names: names);
    return names;
  }

  /// Only what the custom profile actually references is injected, so an
  /// app-level provider costs nothing in the profiles that never name it.
  Future<({Map<String, dynamic> proxies, Map<String, dynamic> rules})>
  _resolveInjectedProviders(
    SetupState setupState, {
    required List<ProxyGroup> proxyGroups,
    required List<Rule> rules,
  }) async {
    final usedProxyProviders = <String>{
      for (final proxyGroup in proxyGroups) ...?proxyGroup.use,
    };
    final usedRuleProviders = <String>{
      for (final rule in rules) ...rule.ruleSets,
      if (setupState.profileType == ProfileType.custom)
        ...setupState.overrides.ruleSets,
    };
    if (usedProxyProviders.isEmpty && usedRuleProviders.isEmpty) {
      return (
        proxies: const <String, dynamic>{},
        rules: const <String, dynamic>{},
      );
    }
    final options = setupState.overrides.proxyProviders;
    final proxies = <String, dynamic>{};
    for (final entry in setupState.profileProviders.entries) {
      if (!usedProxyProviders.contains(entry.key)) {
        continue;
      }
      proxies[entry.key] = {
        'type': 'file',
        'path': await appPath.getProfilePath(entry.value.toString()),
        ...?options[entry.key]?.definition,
      };
    }
    final clashProvidersAction = ref.read(
      clashProvidersActionProvider.notifier,
    );
    final ruleProviders = <String, dynamic>{};
    for (final provider in setupState.clashProviders) {
      if (!usedRuleProviders.contains(provider.label)) {
        continue;
      }
      final prepared = await clashProvidersAction.prepare(provider);
      ruleProviders[prepared.label] = prepared.definition(
        await prepared.corePath,
      );
    }
    return (proxies: proxies, rules: ruleProviders);
  }

  Future<String> getProfileWithId(int profileId) async {
    try {
      final setupState = await ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = ref.read(patchClashConfigProvider);
      final res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
      return switch (res.base) {
        final base? => await _core.buildProfile(base),
        null => res.yaml,
      };
    } catch (e) {
      dialogs.showBanner(e.toString(), level: BannerLevel.error);
    }
    return '';
  }

  PatchClashConfig _effectivePatchConfig(PatchClashConfig patchConfig) {
    if (ref.read(safeModeProvider)) {
      return patchConfig.copyWith(
        tun: patchConfig.tun.copyWith(enable: false),
        externalController: ExternalControllerStatus.close,
      );
    }
    final authorized =
        ref.read(authorizedTunEnableProvider) ==
        TunAuthorizationState.authorized;
    return patchConfig.copyWith(
      tun: patchConfig.tun.copyWith(
        enable:
            patchConfig.tun.enable &&
            authorized &&
            !ref.read(tunDisabledThisRunProvider),
      ),
      externalController: effectiveControllerOf(patchConfig, safeMode: false),
    );
  }

  /// An apply carries the host settings; a resume that applies nothing sends
  /// them too, for a Core that started from params saved before they did, and
  /// the options, which hand the CA trust a native start checked back to the
  /// app's own check.
  Future<void> _patchHostSettings(PatchClashConfig config) async {
    try {
      await _core.updateConfig(
        ConfigPatch(
          externalController: config.externalController.value,
          secret: config.secret,
          externalControllerCors: controllerCorsOf(
            config.externalControllerCors,
          ),
          hostCredential: ref.read(hostCredentialProvider),
          options: coreOptionsArgOf(ref.read(coreOptionsProvider)),
        ),
      );
    } catch (error) {
      commonPrint.log(
        'host settings: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  @protected
  Future<AuthorizeCode> authorizeCore() {
    return system.authorizeCore();
  }

  /// Android's TUN comes from VpnService or the root mode, never from the
  /// app's TUN setting, which a desktop backup can still carry there.
  @protected
  bool get tunNeedsAuthorization => system.isDesktop;

  @visibleForTesting
  Future<bool> requestAdmin(bool enableTun) async {
    if (!enableTun ||
        !tunNeedsAuthorization ||
        ref.read(safeModeProvider) ||
        ref.read(tunDisabledThisRunProvider)) {
      return true;
    }
    final authorizationState = ref.read(authorizedTunEnableProvider);
    if (authorizationState != TunAuthorizationState.none) {
      return true;
    }

    final authorizationNotifier = ref.read(
      authorizedTunEnableProvider.notifier,
    );
    authorizationNotifier.value = TunAuthorizationState.unauthorized;

    final code = await authorizeCore();

    switch (code) {
      case AuthorizeCode.success:
        authorizationNotifier.value = TunAuthorizationState.authorized;
        return false;
      case AuthorizeCode.none:
        authorizationNotifier.value = TunAuthorizationState.authorized;
        return true;
      case AuthorizeCode.error:
        authorizationNotifier.value = TunAuthorizationState.none;
        ref.read(tunDisabledThisRunProvider.notifier).value = true;
        dialogs.showBanner(
          currentAppLocalizations.tunAuthorizationFailed,
          level: BannerLevel.error,
        );
        return true;
    }
  }

  /// An empty profile list is left alone: it is the first-run state, and it is
  /// what the profile stream holds before its first emission.
  @visibleForTesting
  Profile? recoverMissingProfile() {
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId == null) return null;
    final profiles = ref.read(profilesProvider);
    if (profiles.isEmpty) return null;
    final fallback = profiles.first;
    commonPrint.log(
      'profile $profileId is missing, falling back to ${fallback.id}',
      logLevel: LogLevel.warning,
    );
    ref.read(currentProfileIdProvider.notifier).value = fallback.id;
    return fallback;
  }

  Future<_SetupTaskResult> _setupConfig({
    bool force = false,
    bool silence = false,
    Future<void> Function()? preloadInvoke,
    FutureOr Function()? onUpdated,
  }) async {
    var profile = ref.read(currentProfileProvider) ?? recoverMissingProfile();
    // A refresh failure is surfaced by safeRun; setup keeps the old profile.
    final nextProfile = await globalState.safeRun(
      () => profile?.checkAndUpdateAndCopy(
        validate: (path, key) => _core.validateProfile(path, key),
      ),
    );
    if (nextProfile != null) {
      profile = nextProfile;
      ref.read(profilesProvider.notifier).put(nextProfile);
    }
    commonPrint.log('setup ===> ${profile?.realLabel}');
    final patchConfig = ref.read(patchClashConfigProvider);
    final shouldContinueSetup = await requestAdmin(patchConfig.tun.enable);
    if (!shouldContinueSetup) {
      return _SetupTaskResult.handoffToCoreRestart;
    }
    final pushWatch = Stopwatch()..start();
    final realPatchConfig = _effectivePatchConfig(patchConfig);
    final networkSetting = ref.read(networkSettingProvider);
    SetupState? setupState;
    final realProfile = await globalState.safeRun(() async {
      final state = await ref.read(setupStateProvider(profile?.id).future);
      setupState = state;
      return getProfile(setupState: state, patchConfig: realPatchConfig);
    }, title: 'build profile');
    final profileFailed = realProfile == null;
    final setupParams = _setupParams.copyWith(base: realProfile?.base);
    final inputs = switch (setupState) {
      final state? when !profileFailed => (
        state,
        realPatchConfig,
        networkSetting,
        _appliedParams,
      ),
      _ => null,
    };
    final yamlString = realProfile?.yaml ?? '';
    final yamlMd5 = realProfile?.md5 ?? '';
    if (!profileFailed && yamlMd5 == globalState.lastConfigMd5 && !force) {
      _appliedInputs = inputs;
      globalState.lastConfigCounts = realProfile.counts;
      await preloadInvoke?.call();
      await _loadConfigWarnings();
      await _patchHostSettings(realPatchConfig);
      return _SetupTaskResult.completed;
    }
    // Go answers a config it rejects by running its built-in default, which
    // has no proxies, so until this push succeeds no applied config is known.
    _appliedInputs = null;
    globalState.lastConfigMd5 = null;
    globalState.lastConfigCounts = null;
    if (system.isAndroid) {
      await ref.read(vpnOptionsProvider.future);
      await preferences.saveShareState(ref.read(sharedStateProvider));
      await preferences.saveAppliedConfigMd5(null);
    }
    // Recaptured so _start's catch can roll back after safeRun swallows it.
    (Object, StackTrace)? handoffFailure;
    var setupFailed = false;
    await globalState.loadingRun(
      () async {
        try {
          if (setupParams.base == null) {
            final configFilePath = await appPath.configFilePath;
            await File(configFilePath).writeAsStringAtomically(yamlString);
          }
          final profileId = profile?.id;
          if (profileId != null) {
            // A Core that ran elevated may have left these root-owned; it
            // reclaims them once it runs elevated again, so the config goes on.
            try {
              await appPath.ensureProviderDirs(profileId);
            } on FileSystemException catch (error) {
              commonPrint.log(
                'provider directories unavailable: ${compactError(error)}',
                logLevel: LogLevel.warning,
              );
            }
          }
          final sync = ref.read(coreStateSyncProvider);
          int? appliedProfileId;
          sync.applyStarted();
          try {
            await _core.setupConfig(
              params: setupParams,
              preloadInvoke: preloadInvoke,
            );
            appliedProfileId = profileId;
          } on CoreMethodException catch (error) {
            if (error.code != 'config_rejected') {
              rethrow;
            }
            await _loadConfigWarnings();
            globalState.lastConfigCounts = configCountsOf(const {});
            await globalState.safeRun(() => onUpdated?.call());
            throw MessageException(error.message);
          } finally {
            sync.applyEnded(appliedProfileId);
          }
        } catch (e, s) {
          setupFailed = true;
          if (preloadInvoke != null) {
            handoffFailure = (e, s);
          }
          rethrow;
        }
        await _loadConfigWarnings();
        globalState.lastConfigMd5 = yamlMd5;
        ref.invalidate(activeRulesProvider);
        globalState.lastConfigCounts =
            realProfile?.counts ?? configCountsOf(const {});
        _appliedInputs = inputs;
        if (system.isAndroid) {
          await preferences.saveAppliedConfigMd5(yamlMd5);
        }
        await onUpdated?.call();
      },
      silence: true,
      tag: !silence ? LoadingTag.proxies : null,
    );
    _lastPushDuration = pushWatch.elapsed;
    if (handoffFailure != null) {
      Error.throwWithStackTrace(handoffFailure!.$1, handoffFailure!.$2);
    }
    if (setupFailed || profileFailed) {
      return _SetupTaskResult.failed;
    }
    return _SetupTaskResult.completed;
  }
}
