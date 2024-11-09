import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
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
        systemProxy: config.networkProps.systemProxy,
        tunEnable: clashConfig.tun.enable,
        brightness: appState.brightness,
      ),
      shouldRebuild: (prev, next) {
        if (prev != next) {
          globalState.appController.updateTray();
        }
        return prev != next;
      },
      builder: (_, state, child) {
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
