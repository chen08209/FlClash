import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/proxy_sync.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:riverpod/riverpod.dart';

enum MacOSControlWidgetAction {
  start('start'),
  stop('stop'),
  refreshProfile('refreshProfile');

  final String value;

  const MacOSControlWidgetAction(this.value);

  static MacOSControlWidgetAction? fromValue(String? value) {
    return switch (value) {
      'start' => MacOSControlWidgetAction.start,
      'stop' => MacOSControlWidgetAction.stop,
      'refreshProfile' => MacOSControlWidgetAction.refreshProfile,
      _ => null,
    };
  }
}

class MacOSControlWidgetManager {
  final MethodChannel _channel;
  final Future<void> Function(ProxyState proxyState) _syncProxy;
  final Future<void> Function(ProviderContainer container)
  _refreshCurrentProfile;
  ProviderSubscription<int?>? _runTimeSubscription;
  ProviderSubscription<Profile?>? _currentProfileSubscription;
  ProviderContainer? _container;
  Future<void> _pendingOperation = Future.value();
  Timer? _pendingActionPoller;

  MacOSControlWidgetManager({
    MethodChannel channel = const MethodChannel(
      '$packageName/macos_control_widget',
    ),
    Future<void> Function(ProxyState proxyState) syncProxy = syncSystemProxy,
    Future<void> Function(ProviderContainer container)? refreshCurrentProfile,
  }) : _channel = channel,
       _syncProxy = syncProxy,
       _refreshCurrentProfile =
           refreshCurrentProfile ?? _defaultRefreshCurrentProfile;

  Future<void> init(ProviderContainer container) async {
    _container = container;
    _channel.setMethodCallHandler(_handleMethodCall);
    _runTimeSubscription?.close();
    _runTimeSubscription = container.listen<int?>(
      runTimeProvider,
      (_, next) => unawaited(syncWidgetStatus(running: next != null)),
      fireImmediately: true,
    );
    _currentProfileSubscription?.close();
    _currentProfileSubscription = container.listen<Profile?>(
      currentProfileProvider,
      (_, next) => unawaited(syncWidgetStatus(profile: next)),
      fireImmediately: true,
    );
    _pendingActionPoller?.cancel();
    _pendingActionPoller = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(performPendingAction()),
    );
    await performPendingAction();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) {
    return switch (call.method) {
      'performPendingAction' => performPendingAction(),
      'showWindowFromNative' => window?.show() ?? Future<void>.value(),
      _ => throw MissingPluginException(),
    };
  }

  Future<void> performPendingAction() {
    _pendingOperation = _pendingOperation.catchError((_) {}).then((_) async {
      final pendingAction = await _invokePendingAction();
      final action = MacOSControlWidgetAction.fromValue(pendingAction);
      if (action == null) {
        return;
      }
      await performAction(action);
    });
    return _pendingOperation;
  }

  Future<String?> _invokePendingAction() async {
    try {
      return await _channel.invokeMethod<String>('getPendingAction');
    } on MissingPluginException catch (error) {
      commonPrint.log('macOS control widget channel is not ready: $error');
      return null;
    }
  }

  Future<void> performAction(MacOSControlWidgetAction action) async {
    final container = _container;
    if (container == null) {
      return;
    }
    if (action == MacOSControlWidgetAction.refreshProfile) {
      await _refreshCurrentProfile(container);
      await syncWidgetStatus();
      return;
    }
    final running = action == MacOSControlWidgetAction.start;
    await container
        .read(setupActionProvider.notifier)
        .setRunning(
          running,
          initialize: running && !container.read(initProvider),
        );
    await _syncProxy(container.read(proxyStateProvider));
    await setRunningState(running);
  }

  Future<void> syncWidgetStatus({bool? running, Profile? profile}) async {
    final container = _container;
    if (container == null) {
      return;
    }
    final currentProfile = profile ?? container.read(currentProfileProvider);
    final isRunning = running ?? container.read(runTimeProvider) != null;
    try {
      await _channel.invokeMethod<void>('setWidgetStatus', {
        'running': isRunning,
        'profileId': currentProfile?.id,
        'profileName': currentProfile?.realLabel ?? '',
        'hasProfile': currentProfile != null,
      });
    } on MissingPluginException catch (error) {
      commonPrint.log('macOS control widget channel is not ready: $error');
    }
  }

  Future<void> setRunningState(bool running) async {
    try {
      await _channel.invokeMethod<void>('setRunningState', {
        'running': running,
      });
    } on MissingPluginException catch (error) {
      commonPrint.log('macOS control widget channel is not ready: $error');
    }
  }

  Future<bool> isSilentLaunchRequested() async {
    return await _channel.invokeMethod<bool>('isSilentLaunchRequested') ??
        false;
  }

  Future<void> allowWindowPresentation() async {
    await _channel.invokeMethod<void>('allowWindowPresentation');
  }

  void dispose() {
    _pendingActionPoller?.cancel();
    _pendingActionPoller = null;
    _runTimeSubscription?.close();
    _runTimeSubscription = null;
    _currentProfileSubscription?.close();
    _currentProfileSubscription = null;
    _container = null;
    _channel.setMethodCallHandler(null);
  }
}

Future<void> _defaultRefreshCurrentProfile(ProviderContainer container) async {
  final profile = container.read(currentProfileProvider);
  if (profile == null || profile.type == ProfileType.file) {
    return;
  }
  await container.read(profilesActionProvider.notifier).updateProfile(profile);
}

final macOSControlWidgetManager = MacOSControlWidgetManager();
