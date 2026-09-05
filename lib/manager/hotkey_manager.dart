import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
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

class HotKeyManager extends ConsumerStatefulWidget {
  final Widget child;

  const HotKeyManager({super.key, required this.child});

  @override
  ConsumerState<HotKeyManager> createState() => _HotKeyManagerState();
}

class _HotKeyManagerState extends ConsumerState<HotKeyManager> {
  StreamSubscription<int>? _eventSubscription;
  Future<void> _pendingUpdate = Future.value();

  @override
  void initState() {
    super.initState();
    _subscribeHotKeyEvents();
    ref.listenManual(hotKeyActionsProvider, (prev, next) {
      if (!hotKeyActionListEquality.equals(prev, next)) {
        _pendingUpdate = _pendingUpdate.then(
          (_) => _updateHotKeys(hotKeyActions: next),
        );
      }
    }, fireImmediately: true);
  }

  void _subscribeHotKeyEvents() {
    void warn(Object error) {
      commonPrint.log(
        'hotkey events unavailable: $error',
        logLevel: LogLevel.warning,
      );
    }

    try {
      _eventSubscription = hotKeyEvents().listen(
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
    }
  }

  Future<void> _updateHotKeys({
    required List<HotKeyAction> hotKeyActions,
  }) async {
    final specs = [
      for (final hotKeyAction in hotKeyActions) ?hotKeyAction.toHotKeySpec(),
    ];
    try {
      final failures = await setHotKeys(specs: specs);
      for (final failure in failures) {
        commonPrint.log(
          'hotkey ${HotAction.values[failure.id].name} not registered: '
          '${failure.reason}',
          logLevel: LogLevel.warning,
        );
      }
    } catch (error) {
      commonPrint.log(
        'update hotkeys failed: $error',
        logLevel: LogLevel.warning,
      );
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
