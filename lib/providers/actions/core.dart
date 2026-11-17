part of '../action.dart';

@Riverpod(keepAlive: true)
class CoreAction extends _$CoreAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  int _requestedRestartRevision = 0;
  Future<bool>? _restartOperation;

  @override
  void build() {}

  Future<void> initCore() async {
    final isInit =
        (await _core.api.engineStatus()).state != EngineState.created;
    await _loadCapabilities();

    final version = ref.read(versionProvider);
    if (!isInit) {
      await _core.init(version);
    } else {
      await ref.read(proxiesActionProvider.notifier).updateGroups();
      await ref.read(providersProvider.notifier).syncProviders();
    }
  }

  Future<void> _loadCapabilities() async {
    try {
      final capabilities = await _core.api.getCapabilities();
      ref.read(coreCapabilitiesStateProvider.notifier).value = capabilities;
    } catch (error) {
      commonPrint.log(
        'core capabilities unavailable: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  Future<void> startCore() async {
    ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    try {
      final result = await startLifecycle();
      await _applyLifecycleResult(result);
    } catch (error) {
      _markStopped(error);
      dialogs.showBanner(
        ref.read(coreStopReasonProvider) ?? '',
        level: BannerLevel.error,
      );
    }
  }

  void _markStopped(Object error) {
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    final reason = userFacingErrorMessage(error, currentAppLocalizations);
    ref.read(coreStopReasonProvider.notifier).value = reason.isEmpty
        ? null
        : reason;
  }

  @protected
  Future<CoreLifecycleResult> startLifecycle() {
    return _core.start();
  }

  @protected
  Future<CoreLifecycleResult> restartLifecycle() {
    return _core.restart();
  }

  // Nothing in lib/ calls CoreController.stop(); only close() (app exit)
  // supersedes a start/restart. statusFirst lets _onCrash catch a crash
  // during initCore itself (it early-returns unless status is connected).
  Future<bool> _applyLifecycleResult(
    CoreLifecycleResult result, {
    bool statusFirst = false,
  }) async {
    if (result.outcome == CoreLifecycleOutcome.superseded) {
      return false;
    }
    if (statusFirst) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await initCore();
    } else {
      await initCore();
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    }
    if (ref.read(patchClashConfigProvider).mitm.enable) {
      unawaited(ref.read(mitmTrustStateProvider.notifier).refresh());
    }
    return true;
  }

  Future<void> closeConnection(int id) async {
    await _core.api.closeConnections(ids: [id]);
  }

  Future<void> closeConnections() async {
    await _core.api.closeConnections();
  }

  Future<void> reportNetworkChange() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    try {
      await _core.api.updateNetwork(interfaceChanged: true);
    } catch (error) {
      commonPrint.log(
        'reportNetworkChange error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  Future<void> forceGc() async {
    await _core.api.releaseMemory();
  }

  Future<void> crash() async {
    await _core.api.debugCrash();
  }

  Future<bool> restartCore() {
    _requestedRestartRevision++;
    final activeOperation = _restartOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = _runRestartWorker();
    _restartOperation = operation;
    return operation;
  }

  Future<bool> _runRestartWorker() async {
    final setup = ref.read(setupActionProvider.notifier);
    var authorizedNow = false;
    try {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      authorizedNow = await setup._authorizeTunBeforeRestart();
      final result = await restartLifecycle();
      if (!await _applyLifecycleResult(result, statusFirst: true)) {
        return false;
      }

      var appliedRevision = 0;
      var applied = true;
      while (appliedRevision < _requestedRestartRevision) {
        final revision = _requestedRestartRevision;
        if (ref.read(setupActionProvider.notifier).wantsRunning) {
          applied = await ref
              .read(setupActionProvider.notifier)
              .setRunning(true, initialize: true);
        } else {
          applied = await ref
              .read(setupActionProvider.notifier)
              .applyProfile(force: true);
        }
        appliedRevision = revision;
      }
      return applied;
    } catch (error) {
      if (authorizedNow) {
        setup._forgetTunAuthorization();
      }
      _markStopped(error);
      rethrow;
    } finally {
      _restartOperation = null;
    }
  }
}
