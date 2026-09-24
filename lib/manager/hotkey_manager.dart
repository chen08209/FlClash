import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rust_api/rust_api.dart';

extension KeyboardModifierExt on KeyboardModifier {
  HotKeyModifier toHotKeyModifier() {
    return switch (this) {
      KeyboardModifier.alt => HotKeyModifier.alt,
      KeyboardModifier.capsLock => HotKeyModifier.capsLock,
      KeyboardModifier.control => HotKeyModifier.control,
      KeyboardModifier.fn => HotKeyModifier.fn,
      KeyboardModifier.meta => HotKeyModifier.meta,
      KeyboardModifier.shift => HotKeyModifier.shift,
    };
  }
}

extension HotKeyActionExt on HotKeyAction {
  HotKeySpec? toHotKeySpec() {
    final key = this.key;
    if (key == null || modifiers.isEmpty) {
      return null;
    }
    return HotKeySpec(
      id: action.index,
      key: key,
      modifiers: [
        for (final modifier in modifiers) modifier.toHotKeyModifier(),
      ],
    );
  }
}

typedef HotKeyRegistrar =
    Future<List<HotKeyFailure>> Function({required List<HotKeySpec> specs});

class HotKeyManager extends ConsumerStatefulWidget {
  final HotKeyRegistrar? registerHotKeys;
  final Stream<int> Function()? hotKeyEventSource;
  final Widget child;

  const HotKeyManager({
    super.key,
    this.registerHotKeys,
    this.hotKeyEventSource,
    required this.child,
  });

  @override
  ConsumerState<HotKeyManager> createState() => _HotKeyManagerState();
}

class _HotKeyManagerState extends ConsumerState<HotKeyManager> {
  StreamSubscription<int>? _eventSubscription;
  Future<void> _pendingUpdate = Future.value();
  late final HotKeyRegistrar _registerHotKeys =
      widget.registerHotKeys ?? setHotKeys;
  late final Stream<int> Function() _hotKeyEvents =
      widget.hotKeyEventSource ?? hotKeyEvents;

  @override
  void initState() {
    super.initState();
    if (ref.read(safeModeProvider)) {
      return;
    }
    _subscribeHotKeyEvents();
    ref.listenManual(hotKeyActionsProvider, (prev, next) {
      if (!hotKeyActionListEquality.equals(prev, next)) {
        _scheduleUpdate();
      }
    }, fireImmediately: true);
    ref.listenManual(hotKeyRecordingProvider, (prev, next) {
      if (prev != next) {
        _scheduleUpdate();
      }
    });
  }

  void _scheduleUpdate() {
    _pendingUpdate = _pendingUpdate.then((_) => _updateHotKeys());
  }

  void _subscribeHotKeyEvents() {
    void warn(Object error) {
      commonPrint.log(
        'hotkey events unavailable: $error',
        logLevel: LogLevel.warning,
      );
    }

    try {
      _eventSubscription = _hotKeyEvents().listen(
        _handleHotKeyEvent,
        onError: warn,
      );
    } on StateError catch (error) {
      warn(error);
    }
  }

  void _handleHotKeyEvent(int id) {
    if (id < 0 || id >= HotAction.values.length) {
      return;
    }
    _handleHotKeyAction(HotAction.values[id]);
  }

  Future<void> _handleHotKeyAction(HotAction action) async {
    final commonAction = ref.read(commonActionProvider.notifier);
    final systemAction = ref.read(systemActionProvider.notifier);
    final setupAction = ref.read(setupActionProvider.notifier);
    switch (action) {
      case HotAction.mode:
        commonAction.updateMode();
      case HotAction.start:
        commonAction.toggleRunning();
      case HotAction.view:
        unawaited(systemAction.updateVisible());
      case HotAction.proxy:
        systemAction.updateSystemProxy();
      case HotAction.tun:
        systemAction.updateTun();
      case HotAction.ruleMode:
        setupAction.changeMode(Mode.rule);
      case HotAction.globalMode:
        setupAction.changeMode(Mode.global);
      case HotAction.directMode:
        setupAction.changeMode(Mode.direct);
      case HotAction.delayTest:
        unawaited(
          ref
              .read(proxiesActionProvider.notifier)
              .delayTestGroups(ref.read(currentGroupsStateProvider).value),
        );
      case HotAction.updateProfiles:
        unawaited(
          globalState.safeRun(
            ref.read(profilesActionProvider.notifier).updateProfiles,
          ),
        );
      case HotAction.copyEnv:
        unawaited(systemAction.copyProxyEnv());
      case HotAction.exit:
        unawaited(systemAction.handleExit());
    }
  }

  /// While the recorder is open nothing is registered, so the OS hands the
  /// recorder a combination that is already bound instead of running it.
  Future<void> _updateHotKeys() async {
    if (!mounted) {
      return;
    }
    final isRecording = ref.read(hotKeyRecordingProvider);
    final specs = [
      if (!isRecording)
        for (final hotKeyAction in ref.read(hotKeyActionsProvider))
          ?hotKeyAction.toHotKeySpec(),
    ];
    final failed = await _register(specs);
    if (!isRecording && mounted) {
      ref.read(hotKeyFailuresProvider.notifier).value = failed;
    }
  }

  Future<Map<HotAction, String>> _register(List<HotKeySpec> specs) async {
    try {
      final failures = await _registerHotKeys(specs: specs);
      final failed = {
        for (final failure in failures)
          if (failure.id >= 0 && failure.id < HotAction.values.length)
            HotAction.values[failure.id]: failure.reason,
      };
      for (final MapEntry(:key, :value) in failed.entries) {
        commonPrint.log(
          'hotkey ${key.name} not registered: $value',
          logLevel: LogLevel.warning,
        );
      }
      return failed;
    } catch (error) {
      commonPrint.log(
        'update hotkeys failed: $error',
        logLevel: LogLevel.warning,
      );
      return {for (final spec in specs) HotAction.values[spec.id]: '$error'};
    }
  }

  Shortcuts _buildCloseShortcuts(Widget child) {
    return Shortcuts(
      shortcuts: {
        controlSingleActivator(LogicalKeyboardKey.keyW):
            const CloseWindowIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const EscapeBackIntent(),
      },
      child: Actions(
        actions: {
          CloseWindowIntent: CallbackAction<CloseWindowIntent>(
            onInvoke: (_) =>
                ref.read(systemActionProvider.notifier).handleClose(false),
          ),
          EscapeBackIntent: CallbackAction<EscapeBackIntent>(
            onInvoke: (_) => globalState.navigatorKey.currentState?.maybePop(),
          ),
          DoNothingIntent: CallbackAction<DoNothingIntent>(
            onInvoke: (_) => null,
          ),
        },
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCloseShortcuts(widget.child);
  }
}
