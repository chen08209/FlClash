import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/plugins/vpn.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  final safeMessageOffsetNotifier = ValueNotifier(Offset.zero);
  final navigatorKey = GlobalKey<NavigatorState>();
  late AppController appController;
  GlobalKey<CommonScaffoldState> homeScaffoldKey = GlobalKey();
  List<Function> updateFunctionLists = [];
  bool lastTunEnable = false;
  int? lastProfileModified;

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

  Future<void> initCore({
    required AppState appState,
    required ClashConfig clashConfig,
    required Config config,
  }) async {
    await globalState.init(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
    await applyProfile(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
  }

  Future<void> updateClashConfig({
    required AppState appState,
    required ClashConfig clashConfig,
    required Config config,
    bool isPatch = true,
  }) async {
    await config.currentProfile?.checkAndUpdate();
    final useClashConfig = clashConfig.copyWith();
    if (clashConfig.tun.enable != lastTunEnable &&
        lastTunEnable == false &&
        !Platform.isAndroid) {
      final code = await system.authorizeCore();
      switch (code) {
        case AuthorizeCode.none:
          break;
        case AuthorizeCode.success:
          lastTunEnable = useClashConfig.tun.enable;
          await restartCore(
            appState: appState,
            clashConfig: clashConfig,
            config: config,
          );
          return;
        case AuthorizeCode.error:
          useClashConfig.tun = useClashConfig.tun.copyWith(
            enable: false,
          );
      }
    }
    if (config.appSetting.openLogs) {
      clashCore.startLog();
    } else {
      clashCore.stopLog();
    }
    final res = await clashCore.updateConfig(
      UpdateConfigParams(
        profileId: config.currentProfileId ?? "",
        config: useClashConfig,
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
    lastTunEnable = useClashConfig.tun.enable;
    lastProfileModified = await config.getCurrentProfile()?.profileLastModified;
  }

  handleStart() async {
    await clashCore.startListener();
    if (globalState.isVpnService) {
      await vpn?.startVpn();
      startListenUpdate();
      return;
    }
    startTime ??= DateTime.now();
    await service?.init();
    startListenUpdate();
  }

  restartCore({
    required AppState appState,
    required ClashConfig clashConfig,
    required Config config,
    bool isPatch = true,
  }) async {
    await clashService?.startCore();
    await initCore(
      appState: appState,
      clashConfig: clashConfig,
      config: config,
    );
    if (isStart) {
      await handleStart();
    }
  }

  updateStartTime() {
    startTime = clashLib?.getRunTime();
  }

  Future handleStop() async {
    startTime = null;
    await clashCore.stopListener();
    clashLib?.stopTun();
    await service?.destroy();
    stopListenUpdate();
  }

  Future applyProfile({
    required AppState appState,
    required Config config,
    required ClashConfig clashConfig,
  }) async {
    clashCore.requestGc();
    await updateClashConfig(
      appState: appState,
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
    appState.isInit = await clashCore.isInit;
    if (!appState.isInit) {
      appState.isInit = await clashCore.init(
        config: config,
        clashConfig: clashConfig,
      );
      clashLib?.setState(
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
  }) async {
    await clashCore.changeProxy(
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
    required Config config,
    AppFlowingState? appFlowingState,
  }) async {
    final onlyProxy = config.appSetting.onlyProxy;
    final traffic = await clashCore.getTraffic(onlyProxy);
    if (Platform.isAndroid && isVpnService == true) {
      vpn?.startForeground(
        title: clashLib?.getCurrentProfileName() ?? "",
        content: "$traffic",
      );
    } else {
      if (appFlowingState != null) {
        appFlowingState.addTraffic(traffic);
        appFlowingState.totalTraffic =
            await clashCore.getTotalTraffic(onlyProxy);
      }
    }
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
  }) async {
    try {
      final res = await futureFunction();
      return res;
    } catch (e) {
      showNotifier(e.toString());
      return null;
    }
  }

  showNotifier(String text) {
    navigatorKey.currentContext?.showNotifier(text);
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
