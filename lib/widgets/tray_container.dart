import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayContainer extends StatefulWidget {
  final Widget child;

  const TrayContainer({
    super.key,
    required this.child,
  });

  @override
  State<TrayContainer> createState() => _TrayContainerState();
}

class _TrayContainerState extends State<TrayContainer> with TrayListener {

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<AppState, Config, ClashConfig, TrayContainerSelectorState>(
      selector: (_, appState, config, clashConfig) =>
          TrayContainerSelectorState(
        mode: clashConfig.mode,
        autoLaunch: config.autoLaunch,
        isStart: appState.isStart,
        locale: config.locale,
        systemProxy: config.desktopProps.systemProxy,
        tunEnable: clashConfig.tun.enable,
      ),
      shouldRebuild: (prev,next){
        if(prev != next){
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
