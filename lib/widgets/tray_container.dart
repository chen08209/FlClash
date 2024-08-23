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
  var isTrayInit = false;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  _updateOtherTray() async {
    if (isTrayInit == false) {
      await trayManager.setIcon(
        other.getTrayIconPath(),
      );
      await trayManager.setToolTip(
        appName,
      );
      isTrayInit = true;
    }
  }

  _updateLinuxTray() async {
    await trayManager.destroy();
    await trayManager.setIcon(
      other.getTrayIconPath(),
    );
    await trayManager.setToolTip(
      appName,
    );
  }

  updateMenu(TrayContainerSelectorState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Platform.isLinux) {
        _updateOtherTray();
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
        label: state.isStart ? appLocalizations.stop : appLocalizations.start,
        onClick: (_) async {
          globalState.appController.updateStatus(!state.isStart);
        },
        checked: false,
      );
      menuItems.add(startMenuItem);
      menuItems.add(MenuItem.separator());
      // for (final group in state.groups) {
      //   List<MenuItem> subMenuItems = [];
      //   final isCurrentGroup = group.name == state.currentGroupName;
      //   for (final proxy in group.all) {
      //     final isCurrentProxy = proxy.name == state.currentProxyName;
      //     subMenuItems.add(
      //       MenuItem.checkbox(
      //           label: proxy.name,
      //           checked: isCurrentGroup && isCurrentProxy,
      //           onClick: (_) {
      //             final config = globalState.appController.config;
      //             config.currentProfile?.groupName = group.name;
      //             config.currentProfile?.proxyName = proxy.name;
      //             config.update();
      //             globalState.appController.changeProxy();
      //           }),
      //     );
      //   }
      //   menuItems.add(
      //     MenuItem.submenu(
      //       label: group.name,
      //       submenu: Menu(
      //         items: subMenuItems,
      //       ),
      //     ),
      //   );
      // }
      // if (state.groups.isNotEmpty) {
      //   menuItems.add(MenuItem.separator());
      // }
      for (final mode in Mode.values) {
        menuItems.add(
          MenuItem.checkbox(
            label: Intl.message(mode.name),
            onClick: (_) {
              globalState.appController.clashConfig.mode = mode;
            },
            checked: mode == state.mode,
          ),
        );
      }
      menuItems.add(MenuItem.separator());

      if (state.isStart) {
        menuItems.add(
          MenuItem.checkbox(
            label: appLocalizations.tun,
            onClick: (_) {
              final clashConfig = globalState.appController.clashConfig;
              clashConfig.tun =
                  clashConfig.tun.copyWith(enable: !state.tunEnable);
            },
            checked: state.tunEnable,
          ),
        );
        menuItems.add(
          MenuItem.checkbox(
            label: appLocalizations.systemProxy,
            onClick: (_) {
              final config = globalState.appController.config;
              config.desktopProps =
                  config.desktopProps.copyWith(systemProxy: !state.systemProxy);
            },
            checked: state.systemProxy,
          ),
        );
        menuItems.add(MenuItem.separator());
      }

      final autoStartMenuItem = MenuItem.checkbox(
        label: appLocalizations.autoLaunch,
        onClick: (_) async {
          globalState.appController.config.autoLaunch =
              !globalState.appController.config.autoLaunch;
        },
        checked: state.autoLaunch,
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
        _updateLinuxTray();
      }
    });
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
      builder: (_, state, child) {
        updateMenu(state);
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
