import 'dart:io';

import 'package:fl_clash/common/iterable.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tray_manager/tray_manager.dart';

import 'app_localizations.dart';
import 'constant.dart';
import 'system.dart';
import 'window.dart';

class Tray {
  String get trayIconSuffix {
    return system.isWindows ? 'ico' : 'png';
  }

  String getTryIcon({required bool isStart, required bool tunEnable}) {
    if (system.isMacOS || !isStart) {
      return 'assets/images/icon/status_1.$trayIconSuffix';
    }
    if (!tunEnable) {
      return 'assets/images/icon/status_2.$trayIconSuffix';
    }
    return 'assets/images/icon/status_3.$trayIconSuffix';
  }

  Future _updateSystemTray({
    bool force = false,
    required bool isStart,
    required bool tunEnable,
  }) async {
    if (Platform.isLinux || force) {
      await trayManager.destroy();
    }
    await trayManager.setIcon(
      getTryIcon(isStart: isStart, tunEnable: tunEnable),
      isTemplate: true,
    );
    if (!Platform.isLinux) {
      await trayManager.setToolTip(appName);
    }
  }

  Future<void> update({
    required TrayState trayState,
    bool focus = false,
  }) async {
    if (system.isAndroid) {
      return;
    }
    if (!system.isLinux) {
      await _updateSystemTray(
        isStart: trayState.isStart,
        tunEnable: trayState.tunEnable,
        force: focus,
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
      label: trayState.isStart ? appLocalizations.stop : appLocalizations.start,
      onClick: (_) async {
        globalState.appController.updateStart();
      },
      checked: false,
    );
    menuItems.add(startMenuItem);
    if (system.isMacOS) {
      final speedStatistics = MenuItem.checkbox(
        label: appLocalizations.speedStatistics,
        onClick: (_) async {
          globalState.appController.updateSpeedStatistics();
        },
        checked: trayState.showTrayTitle,
      );
      menuItems.add(speedStatistics);
    }
    menuItems.add(MenuItem.separator());
    for (final mode in Mode.values) {
      menuItems.add(
        MenuItem.checkbox(
          label: Intl.message(mode.name),
          onClick: (_) {
            globalState.appController.changeMode(mode);
          },
          checked: mode == trayState.mode,
        ),
      );
    }
    menuItems.add(MenuItem.separator());
    if (system.isMacOS) {
      for (final group in trayState.groups) {
        List<MenuItem> subMenuItems = [];
        for (final proxy in group.all) {
          subMenuItems.add(
            MenuItem.checkbox(
              label: proxy.name,
              checked:
                  globalState.getSelectedProxyName(group.name) == proxy.name,
              onClick: (_) {
                final appController = globalState.appController;
                appController.updateCurrentSelectedMap(group.name, proxy.name);
                appController.changeProxy(
                  groupName: group.name,
                  proxyName: proxy.name,
                );
              },
            ),
          );
        }
        menuItems.add(
          MenuItem.submenu(
            label: group.name,
            submenu: Menu(items: subMenuItems),
          ),
        );
      }
      if (trayState.groups.isNotEmpty) {
        menuItems.add(MenuItem.separator());
      }
    }
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
    final copyEnvVarMenuItem = MenuItem(
      label: appLocalizations.copyEnvVar,
      onClick: (_) async {
        await _copyEnv(trayState.port);
      },
    );
    menuItems.add(autoStartMenuItem);
    menuItems.add(copyEnvVarMenuItem);
    menuItems.add(MenuItem.separator());
    final exitMenuItem = MenuItem(
      label: appLocalizations.exit,
      onClick: (_) async {
        await globalState.appController.handleExit();
      },
    );
    menuItems.add(exitMenuItem);
    final menu = Menu(items: menuItems);
    await trayManager.setContextMenu(menu);
    if (system.isLinux) {
      await _updateSystemTray(
        isStart: trayState.isStart,
        tunEnable: trayState.tunEnable,
        force: focus,
      );
    }
    updateTrayTitle(
      showTrayTitle: trayState.showTrayTitle,
      traffic: globalState.appState.traffics.list.safeLast(Traffic()),
    );
  }

  Future<void> updateTrayTitle({
    required bool showTrayTitle,
    required Traffic traffic,
  }) async {
    if (!system.isMacOS) {
      return;
    }
    if (!showTrayTitle) {
      await trayManager.setTitle('');
    } else {
      await trayManager.setTitle(traffic.trayTitle);
    }
  }

  Future<void> _copyEnv(int port) async {
    final url = 'http://127.0.0.1:$port';

    final cmdline = system.isWindows
        ? 'set \$env:all_proxy=$url'
        : 'export all_proxy=$url';

    await Clipboard.setData(ClipboardData(text: cmdline));
  }
}

final tray = system.isDesktop ? Tray() : null;
