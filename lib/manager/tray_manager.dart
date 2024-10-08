import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_ext/window_ext.dart';

class TrayManager extends StatefulWidget {
  final Widget child;

  const TrayManager({
    super.key,
    required this.child,
  });

  @override
  State<TrayManager> createState() => _TrayContainerState();
}

class _TrayContainerState extends State<TrayManager>
    with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Selector4<AppState, AppFlowingState, Config, ClashConfig, TrayState>(
      selector: (_, appState, appFlowingState, config, clashConfig) =>
          TrayState(
        mode: clashConfig.mode,
        adminAutoLaunch: config.appSetting.adminAutoLaunch,
        autoLaunch: config.appSetting.autoLaunch,
        isStart: appFlowingState.isStart,
        locale: config.appSetting.locale,
        systemProxy: config.desktopProps.systemProxy,
        tunEnable: clashConfig.tun.enable,
        brightness: appState.brightness,
      ),
      shouldRebuild: (prev, next) {
        return prev != next;
      },
      builder: (_, state, child) {
        globalState.appController.updateTray();
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
