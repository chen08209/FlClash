import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeyManager extends StatelessWidget {
  final Widget child;

  const HotKeyManager({
    super.key,
    required this.child,
  });

  _handleHotKeyAction(HotAction action) async {
    switch (action) {
      case HotAction.mode:
        globalState.appController.updateMode();
      case HotAction.start:
        globalState.appController.updateStart();
      case HotAction.view:
        globalState.appController.updateVisible();
      case HotAction.proxy:
        globalState.appController.updateSystemProxy();
      case HotAction.tun:
        globalState.appController.updateTun();
    }
  }

  _updateHotKeys({
    required List<HotKeyAction> hotKeyActions,
  }) async {
    await hotKeyManager.unregisterAll();
    final hotkeyActionHandles = hotKeyActions.where(
      (hotKeyAction) {
        return hotKeyAction.key != null && hotKeyAction.modifiers.isNotEmpty;
      },
    ).map<Future>(
      (hotKeyAction) async {
        final modifiers = hotKeyAction.modifiers
            .map((item) => item.toHotKeyModifier())
            .toList();
        final hotKey = HotKey(
          key: PhysicalKeyboardKey(hotKeyAction.key!),
          modifiers: modifiers,
        );
        return await hotKeyManager.register(
          hotKey,
          keyDownHandler: (_) {
            _handleHotKeyAction(hotKeyAction.action);
          },
        );
      },
    );
    await Future.wait(hotkeyActionHandles);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        ref.listenManual(
          hotKeyActionsProvider,
          (prev, next) {
            if (!hotKeyActionListEquality.equals(prev, next)) {
              _updateHotKeys(hotKeyActions: next);
            }
          },
          fireImmediately: true,
        );
        return child!;
      },
      child: child,
    );
  }
}
