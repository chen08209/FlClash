import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayManager extends StatefulWidget {
  final Widget child;

  const TrayManager({
    super.key,
    required this.child,
  });

  @override
  State<TrayManager> createState() => _TrayContainerState();
}

class _TrayContainerState extends State<TrayManager> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  _updateSystemTray({
    required bool isStart,
    required Brightness? brightness,
  }) async {
    if (Platform.isLinux) {
      await trayManager.destroy();
    }
    await trayManager.setIcon(
      other.getTrayIconPath(
        isStart: isStart,
        brightness: brightness ??
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
      ),
    );
    if(!Platform.isLinux){
      await trayManager.setToolTip(
        appName,
      );
    }
  }

  _updateTray(TrayState trayState) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Platform.isLinux) {
        _updateSystemTray(
          isStart: trayState.isStart,
          brightness: trayState.brightness,
        );
      }
      List<MenuItem> menuItems = [];
      final showMenuItem = MenuItem(
        label: appLocalizations.show,
        onClick: (_) {
          window?.show();
        },
      );
      menuItems.add(showMenuItem);
      final startMenuItem = MenuItem.checkbox(
        label:
            trayState.isStart ? appLocalizations.stop : appLocalizations.start,
        onClick: (_) async {
          globalState.appController.updateStart();
        },
        checked: false,
      );
      menuItems.add(startMenuItem);
      menuItems.add(MenuItem.separator());
      for (final mode in Mode.values) {
        menuItems.add(
          MenuItem.checkbox(
            label: Intl.message(mode.name),
            onClick: (_) {
              globalState.appController.clashConfig.mode = mode;
            },
            checked: mode == trayState.mode,
          ),
        );
      }
      menuItems.add(MenuItem.separator());
      if (trayState.isStart) {
        menuItems.add(
          MenuItem.checkbox(
            label: appLocalizations.tun,
            onClick: (_) {
              globalState.appController.updateTun();
            },
            checked: trayState.tunEnable,
          ),
        );
        menuItems.add(
          MenuItem.checkbox(
            label: appLocalizations.systemProxy,
            onClick: (_) {
              globalState.appController.updateSystemProxy();
            },
            checked: trayState.systemProxy,
          ),
        );
        menuItems.add(MenuItem.separator());
      }
      final autoStartMenuItem = MenuItem.checkbox(
        label: appLocalizations.autoLaunch,
        onClick: (_) async {
          globalState.appController.updateAutoLaunch();
        },
        checked: trayState.autoLaunch,
      );
      menuItems.add(autoStartMenuItem);
      menuItems.add(MenuItem.separator());
      final exitMenuItem = MenuItem(
        label: appLocalizations.exit,
        onClick: (_) async {
          await globalState.appController.handleExit();
        },
      );
      menuItems.add(exitMenuItem);
      final menu = Menu();
      menu.items = menuItems;
      trayManager.setContextMenu(menu);
      if (Platform.isLinux) {
        _updateSystemTray(
          isStart: trayState.isStart,
          brightness: trayState.brightness,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<AppState, Config, ClashConfig, TrayState>(
      selector: (_, appState, config, clashConfig) => TrayState(
        mode: clashConfig.mode,
        autoLaunch: config.autoLaunch,
        isStart: appState.isStart,
        locale: config.locale,
        systemProxy: config.desktopProps.systemProxy,
        tunEnable: clashConfig.tun.enable,
        brightness: appState.brightness,
      ),
      shouldRebuild: (prev, next) {
        return prev != next;
      },
      builder: (_, state, child) {
        _updateTray(state);
        return child!;
      },
      child: widget.child,
    );
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
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
