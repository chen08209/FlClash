import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller.dart';

import 'models/models.dart';
import 'common/common.dart';

class GlobalState {
  Timer? timer;
  Timer? groupsUpdateTimer;
  var isVpnService = false;
  late PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  PageController? pageController;
  final navigatorKey = GlobalKey<NavigatorState>();
  late AppController appController;
  GlobalKey<CommonScaffoldState> homeScaffoldKey = GlobalKey();
  List<Function> updateFunctionLists = [];

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
    final profilePath = await appPath.getProfilePath(config.currentProfileId);
    await config.currentProfile?.checkAndUpdate();
    final res = await clashCore.updateConfig(
      UpdateConfigParams(
        profilePath: profilePath,
        config: clashConfig,
        params: ConfigExtendedParams(
          isPatch: isPatch,
          isCompatible: config.isCompatible,
          selectedMap: config.currentSelectedMap,
          testUrl: config.testUrl,
        ),
      ),
    );
    if (res.isNotEmpty) throw res;
  }

  updateCoreVersionInfo(AppState appState) {
    appState.versionInfo = clashCore.getVersionInfo();
  }

  Future<void> startSystemProxy({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    if (!globalState.isVpnService && Platform.isAndroid) {
      clashCore.setProps(
        Props(
          accessControl: config.isAccessControl ? config.accessControl : null,
          allowBypass: config.allowBypass,
          systemProxy: config.systemProxy,
        ),
      );
      await proxy?.initService();
    } else {
      await proxyManager.startProxy(
        port: clashConfig.mixedPort,
      );
    }
    startListenUpdate();
    if (Platform.isAndroid) {
      return;
    }
    applyProfile(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    ).then((_) {
      globalState.appController.addCheckIpNumDebounce();
    });
  }

  Future<void> stopSystemProxy() async {
    await proxyManager.stopProxy();
    stopListenUpdate();
  }

  Future applyProfile({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    await updateClashConfig(
      clashConfig: clashConfig,
      config: config,
      isPatch: false,
    );
    clashCore.setProfileName(config.currentProfile?.label ?? '');
    await updateGroups(appState);
  }

  init({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    appState.isInit = clashCore.isInit;
    if (!appState.isInit) {
      if (Platform.isAndroid) {
        clashCore.setProps(
          Props(
            accessControl: config.isAccessControl ? config.accessControl : null,
            allowBypass: config.allowBypass,
            systemProxy: config.systemProxy,
          ),
        );
      }
      appState.isInit = await clashService.init(
        config: config,
        clashConfig: clashConfig,
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
                child: RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
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

  Future<T?> showCommonDialog<T>({
    required Widget child,
  }) async {
    return await showModal<T>(
      context: navigatorKey.currentState!.context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
      ),
      builder: (_) => child,
      filter: filter,
    );
  }

  updateTraffic({
    AppState? appState,
  }) {
    final traffic = clashCore.getTraffic();
    if (Platform.isAndroid && isVpnService == true) {
      proxy?.startForeground(
        title: clashCore.getProfileName(),
        content: "$traffic",
      );
    } else {
      if (appState != null) {
        appState.addTraffic(traffic);
        appState.totalTraffic = clashCore.getTotalTraffic();
      }
    }
  }

  showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
  }) {
    final width = context.width;
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
}

final globalState = GlobalState();
