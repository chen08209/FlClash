import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayManager extends ConsumerStatefulWidget {
  final Widget child;

  const TrayManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<TrayManager> createState() => _TrayContainerState();
}

class _TrayContainerState extends ConsumerState<TrayManager> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    ref.listenManual(
      trayStateProvider,
      (prev, next) {
        if (prev != next) {
          globalState.appController.updateTray();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onTrayIconRightMouseDown() {
    // ignore: deprecated_member_use
    trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    render?.active();
    super.onTrayMenuItemClick(menuItem);
  }

  @override
  onTrayIconMouseDown() {
    window?.show();
  }

  @override
  dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
