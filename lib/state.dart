import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';
import 'common/common.dart';

class GlobalState {
  Timer? timer;
  Timer? currentDelayTimer;
  Function? updateCurrentDelayDebounce;
  PageController? pageController;
  final navigatorKey = GlobalKey<NavigatorState>();
  final Map<int, String?> packageNameMap = {};
  GlobalKey<CommonScaffoldState> homeScaffoldKey = GlobalKey();
  List<Function> updateFunctionLists = [];
  List<NavigationItem> currentNavigationItems = [];
  bool updatePackagesLock = false;

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

  Future<String> updateClashConfig({
    required ClashConfig clashConfig,
    required Config config,
    bool isPatch = true,
  }) async {
    final profilePath = await appPath.getProfilePath(config.currentProfileId);
    debugPrint("update config");
    return clashCore.updateConfig(UpdateConfigParams(
      profilePath: profilePath,
      config: clashConfig,
      isPatch: isPatch,
    ));
  }

  updateCoreVersionInfo(AppState appState) {
    appState.versionInfo = clashCore.getVersionInfo();
  }

  Future<void> startSystemProxy({
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    final args =
        config.isAccessControl ? json.encode(config.accessControl) : null;
    await proxyManager.startProxy(
      port: clashConfig.mixedPort,
      args: args,
    );
    startListenUpdate();
  }

  Future<void> stopSystemProxy() async {
    await proxyManager.stopProxy();
    stopListenUpdate();
  }

  void updateCurrentDelay(
    String? proxyName,
  ) {
    updateCurrentDelayDebounce ??= debounce<Function(String?)>((proxyName) {
      if (proxyName != null) {
        clashCore.delay(
          proxyName,
        );
      }
    });
    updateCurrentDelayDebounce!([proxyName]);
  }

  applyProfile({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    final res = await updateClashConfig(
      clashConfig: clashConfig,
      config: config,
      isPatch: false,
    );
    if (res.isNotEmpty) return Result.error(message: res);
    await updateGroups(appState);
    changeProxy(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
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
    if (!appState.isInit) return;
    await applyProfile(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
    updateCoreVersionInfo(appState);
  }

  changeProxy({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) {
    final currentGroupName =
        appState.getCurrentGroupName(config.currentGroupName, clashConfig.mode);
    final currentProxyName =
        appState.getCurrentProxyName(config.currentProxyName, clashConfig.mode);
    if (config.profiles.isEmpty || currentProxyName == null) {
      stopSystemProxy();
      return;
    }
    if (currentGroupName == null) return;
    final groupIndex = appState.groups.indexWhere(
      (element) => element.name == currentGroupName,
    );
    if (groupIndex == -1) return;
    final proxyIndex = appState.groups[groupIndex].all.indexWhere(
      (element) => element.name == currentProxyName,
    );
    if (proxyIndex == -1) return;
    clashCore.changeProxy(
      ChangeProxyParams(
        groupName: currentGroupName,
        proxyName: currentProxyName,
      ),
    );
  }

  updatePackages(AppState appState) async {
    if (appState.packages.isEmpty && updatePackagesLock == false) {
      updatePackagesLock = true;
      appState.packages = await app?.getPackages() ?? [];
      updatePackagesLock = false;
    }
  }

  updateNavigationItems({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) {
    final hasGroups = appState.getCurrentGroups(clashConfig.mode).isNotEmpty;
    final hasProfile = config.profiles.isNotEmpty;
    appState.navigationItems = navigation.getItems(
      openLogs: config.openLogs,
      hasProxies: hasGroups && hasProfile,
    );
  }

  Future<void> updateGroups(AppState appState) async {
    appState.groups = await clashCore.getProxiesGroups();
  }

  showMessage({
    required String title,
    required InlineSpan message,
    Function()? onTab,
  }) {
    showCommonDialog(
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 300,
              child: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: onTab ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: Text(appLocalizations.confirm),
              )
            ],
          );
        },
      ),
    );
  }

  showCommonDialog<T>({
    required Widget child,
  }) async {
    return await showModal<T>(
      context: navigatorKey.currentState!.context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
      ),
      builder: (_) => child,
      filter: appConstant.filter,
    );
  }

  checkUpdate(Function()? onTab) async {
    final result = await Request.checkForUpdate();
    if (result.type == ResultType.success) {
      showMessage(
        title: appLocalizations.discovery,
        message: TextSpan(
          text: result.data,
        ),
        onTab: onTab,
      );
    }
  }

  updateTraffic({
    AppState? appState,
    required Config config,
  }) {
    final traffic = clashCore.getTraffic();
    if (appState != null) {
      appState.addTraffic(traffic);
    }
    if (Platform.isAndroid) {
      final currentProfile = config.currentProfile;
      if (currentProfile == null) return;
      proxyManager.startForeground(
        title: currentProfile.label ?? currentProfile.id,
        content: "$traffic",
      );
    }
  }
}

final globalState = GlobalState();
