import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/plugins/vpn.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'controller.dart';
import 'models/models.dart';

class GlobalState {
  Timer? timer;
  Timer? groupsUpdateTimer;
  var isVpnService = false;
  late PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  PageController? pageController;
  late Measure measure;
  DateTime? startTime;
  final navigatorKey = GlobalKey<NavigatorState>();
  late AppController appController;
  GlobalKey<CommonScaffoldState> homeScaffoldKey = GlobalKey();
  List<Function> updateFunctionLists = [];

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  startListenUpdate() {
    if (timer != null && timer!.isActive == true) return;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      for (final function in updateFunctionLists) {
        function();
      }
    });
  }

  stopListenUpdate() {
    if (timer == null || timer?.isActive == false) return;
    timer?.cancel();
  }

  Future<void> updateClashConfig({
    required ClashConfig clashConfig,
    required Config config,
    bool isPatch = true,
  }) async {
    await config.currentProfile?.checkAndUpdate();
    final res = await clashCore.updateConfig(
      UpdateConfigParams(
        profileId: config.currentProfileId ?? "",
        config: clashConfig,
        params: ConfigExtendedParams(
          isPatch: isPatch,
          isCompatible: true,
          selectedMap: config.currentSelectedMap,
          overrideDns: config.overrideDns,
          testUrl: config.appSetting.testUrl,
        ),
      ),
    );
    if (res.isNotEmpty) throw res;
  }

  updateCoreVersionInfo(AppState appState) {
    appState.versionInfo = clashCore.getVersionInfo();
  }

  handleStart() async {
    clashCore.start();
    if (globalState.isVpnService) {
      await vpn?.startVpn();
      startListenUpdate();
      return;
    }
    startTime ??= DateTime.now();
    await service?.init();
    startListenUpdate();
  }

  updateStartTime() {
    startTime = clashCore.getRunTime();
  }

  Future handleStop() async {
    clashCore.stop();
    if (Platform.isAndroid) {
      clashCore.stopTun();
    }
    await service?.destroy();
    startTime = null;
    stopListenUpdate();
  }

  Future applyProfile({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    clashCore.requestGc();
    await updateClashConfig(
      clashConfig: clashConfig,
      config: config,
      isPatch: false,
    );
    await updateGroups(appState);
    await updateProviders(appState);
  }

  updateProviders(AppState appState) async {
    appState.providers = await clashCore.getExternalProviders();
  }

  init({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    appState.isInit = clashCore.isInit;
    if (!appState.isInit) {
      appState.isInit = await clashService.init(
        config: config,
        clashConfig: clashConfig,
      );
    }
    if (Platform.isAndroid && !isVpnService) {
      clashCore.setState(
        CoreState(
          enable: config.vpnProps.enable,
          accessControl: config.isAccessControl ? config.accessControl : null,
          ipv6: config.vpnProps.ipv6,
          allowBypass: config.vpnProps.allowBypass,
          systemProxy: config.vpnProps.systemProxy,
          onlyProxy: config.appSetting.onlyProxy,
          bypassDomain: config.networkProps.bypassDomain,
          routeAddress: clashConfig.routeAddress,
          currentProfileName:
              config.currentProfile?.label ?? config.currentProfileId ?? "",
        ),
      );
    }
    updateCoreVersionInfo(appState);
  }

  Future<void> updateGroups(AppState appState) async {
    appState.groups = await clashCore.getProxiesGroups();
  }

  showMessage({
    required String title,
    required InlineSpan message,
    Function()? onTab,
    String? confirmText,
  }) {
    showCommonDialog(
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
                  ),
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: onTab ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: Text(confirmText ?? appLocalizations.confirm),
              )
            ],
          );
        },
      ),
    );
  }

  changeProxy({
    required Config config,
    required String groupName,
    required String proxyName,
  }) {
    clashCore.changeProxy(
      ChangeProxyParams(
        groupName: groupName,
        proxyName: proxyName,
      ),
    );
    if (config.appSetting.closeConnections) {
      clashCore.closeConnections();
    }
  }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    bool dismissible = true,
  }) async {
    return await showModal<T>(
      context: navigatorKey.currentState!.context,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
        barrierDismissible: dismissible,
      ),
      builder: (_) => child,
      filter: filter,
    );
  }

  updateTraffic({
    AppFlowingState? appFlowingState,
  }) {
    final traffic = clashCore.getTraffic();
    if (Platform.isAndroid && isVpnService == true) {
      vpn?.startForeground(
        title: clashCore.getCurrentProfileName(),
        content: "$traffic",
      );
    } else {
      if (appFlowingState != null) {
        appFlowingState.addTraffic(traffic);
        appFlowingState.totalTraffic = clashCore.getTotalTraffic();
      }
    }
  }

  showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
  }) {
    final width = context.viewWidth;
    EdgeInsets margin;
    if (width < 600) {
      margin = const EdgeInsets.only(
        bottom: 16,
        right: 16,
        left: 16,
      );
    } else {
      margin = EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: width - 316,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: action,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        margin: margin,
      ),
    );
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
  }) async {
    try {
      final res = await futureFunction();
      return res;
    } catch (e) {
      showMessage(
        title: title ?? appLocalizations.tip,
        message: TextSpan(
          text: e.toString(),
        ),
      );
      return null;
    }
  }

  openUrl(String url) {
    showMessage(
      message: TextSpan(text: url),
      title: appLocalizations.externalLink,
      confirmText: appLocalizations.go,
      onTab: () {
        launchUrl(Uri.parse(url));
      },
    );
  }

  Future _updateSystemTray({
    required Brightness? brightness,
    bool force = false,
  }) async {
    if (Platform.isAndroid) {
      return;
    }
    if (Platform.isLinux || force) {
      await trayManager.destroy();
    }
    await trayManager.setIcon(
      other.getTrayIconPath(
        brightness: brightness ??
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
      ),
      isTemplate: true,
    );
    if (!Platform.isLinux) {
      await trayManager.setToolTip(
        appName,
      );
    }
  }

  updateTray({
    required AppState appState,
    required AppFlowingState appFlowingState,
    required Config config,
    required ClashConfig clashConfig,
    bool focus = false,
  }) async {
    if (!Platform.isLinux) {
      await _updateSystemTray(
        brightness: appState.brightness,
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
      label: appFlowingState.isStart
          ? appLocalizations.stop
          : appLocalizations.start,
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
          checked: mode == clashConfig.mode,
        ),
      );
    }
    menuItems.add(MenuItem.separator());
    if (appFlowingState.isStart) {
      menuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.tun,
          onClick: (_) {
            globalState.appController.updateTun();
          },
          checked: clashConfig.tun.enable,
        ),
      );
      menuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.systemProxy,
          onClick: (_) {
            globalState.appController.updateSystemProxy();
          },
          checked: config.networkProps.systemProxy,
        ),
      );
      menuItems.add(MenuItem.separator());
    }
    final autoStartMenuItem = MenuItem.checkbox(
      label: appLocalizations.autoLaunch,
      onClick: (_) async {
        globalState.appController.updateAutoLaunch();
      },
      checked: config.appSetting.autoLaunch,
    );
    menuItems.add(autoStartMenuItem);

    if (Platform.isWindows) {
      final adminAutoStartMenuItem = MenuItem.checkbox(
        label: appLocalizations.adminAutoLaunch,
        onClick: (_) async {
          globalState.appController.updateAdminAutoLaunch();
        },
        checked: config.appSetting.adminAutoLaunch,
      );
      menuItems.add(adminAutoStartMenuItem);
    }
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
    if (Platform.isLinux) {
      await _updateSystemTray(
        brightness: appState.brightness,
        force: focus,
      );
    }
  }
}

final globalState = GlobalState();
