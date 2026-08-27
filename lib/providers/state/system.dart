part of '../state.dart';

@riverpod
UpdateParams updateParams(Ref ref) {
  final routeMode = ref.watch(
    networkSettingProvider.select((state) => state.routeMode),
  );
  return ref.watch(
    patchClashConfigProvider.select(
      (state) => UpdateParams(
        tun: state.tun.getRealTun(routeMode),
        allowLan: state.allowLan,
        findProcessMode: state.findProcessMode,
        mode: state.mode,
        logLevel: state.logLevel,
        ipv6: state.ipv6,
        tcpConcurrent: state.tcpConcurrent,
        externalController: state.externalController,
        unifiedDelay: state.unifiedDelay,
        mixedPort: state.mixedPort,
        geoAutoUpdate: state.geoAutoUpdate,
        geoUpdateInterval: state.geoUpdateInterval,
      ),
    ),
  );
}

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final systemProxy = ref.watch(
    networkSettingProvider.select((state) => state.systemProxy),
  );
  final clashConfig = ref.watch(
    patchClashConfigProvider.select(
      (state) => (
        mode: state.mode,
        mixedPort: state.mixedPort,
        tunEnable: state.tun.enable,
      ),
    ),
  );
  final appSetting = ref.watch(
    appSettingProvider.select(
      (state) =>
          (autoLaunch: state.autoLaunch, showTrayTitle: state.showTrayTitle),
    ),
  );
  final groups = ref.watch(currentGroupsStateProvider).value;
  final selectedMap = ref.watch(selectedMapProvider);

  return TrayState(
    mode: clashConfig.mode,
    port: clashConfig.mixedPort,
    autoLaunch: appSetting.autoLaunch,
    systemProxy: systemProxy,
    tunEnable: clashConfig.tunEnable,
    isStart: isStart,
    groups: groups,
    selectedMap: selectedMap,
    showTrayTitle: appSetting.showTrayTitle,
  );
}

@riverpod
TrayTitleState trayTitleState(Ref ref) {
  final showTrayTitle = ref.watch(
    appSettingProvider.select((state) => state.showTrayTitle),
  );
  final traffic = ref.watch(
    trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
  );
  return TrayTitleState(showTrayTitle: showTrayTitle, traffic: traffic);
}

@riverpod
VpnState vpnState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final stack = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.stack),
  );
  return VpnState(stack: stack, vpnProps: vpnProps);
}

@riverpod
PackageListSelectorState packageListSelectorState(Ref ref) {
  final packages = ref.watch(packagesProvider);
  final accessControlProps = ref.watch(
    vpnSettingProvider.select((state) => state.accessControlProps),
  );
  return PackageListSelectorState(
    packages: packages,
    accessControlProps: accessControlProps,
  );
}

@riverpod
HotKeyAction getHotKeyAction(Ref ref, HotAction hotAction) {
  return ref.watch(
    hotKeyActionsProvider.select((state) {
      final index = state.indexWhere((item) => item.action == hotAction);
      return index != -1 ? state[index] : HotKeyAction(action: hotAction);
    }),
  );
}

@riverpod
({bool isInit, int checkIpNum, bool containsDetection}) checkIp(Ref ref) {
  final isInit = ref.watch(initProvider);
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsDetection = ref.watch(
    dashboardStateProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.networkDetection),
    ),
  );
  return (
    isInit: isInit,
    checkIpNum: checkIpNum,
    containsDetection: containsDetection,
  );
}

@riverpod
bool shouldPatchSystemDns(Ref ref) {
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  if (!autoSetSystemDns) {
    return false;
  }
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final tunEnable = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.enable),
  );
  final authorizationState = ref.watch(authorizedTunEnableProvider);
  return isStart &&
      tunEnable &&
      authorizationState == TunAuthorizationState.authorized;
}

@riverpod
SharedState sharedState(Ref ref) {
  ref.watch(loadedLocaleProvider);
  final currentProfile = ref.watch(
    currentProfileProvider.select(
      (state) => CurrentProfileSelectorState(
        label: state?.label ?? '',
        selectedMap: state?.selectedMap ?? {},
      ),
    ),
  );
  final appSetting = ref.watch(
    appSettingProvider.select(
      (state) => (
        onlyStatisticsProxy: state.onlyStatisticsProxy,
        crashlytics: state.crashlytics,
        testUrl: state.testUrl,
      ),
    ),
  );
  final bypassDomain = ref.watch(
    networkSettingProvider.select((state) => state.bypassDomain),
  );
  final clashConfig = ref.watch(
    patchClashConfigProvider.select(
      (state) => (stack: state.tun.stack.name, mixedPort: state.mixedPort),
    ),
  );
  final vpnSetting = ref.watch(vpnSettingProvider);
  final currentProfileName = currentProfile.label;
  final selectedMap = currentProfile.selectedMap;
  final onlyStatisticsProxy = appSetting.onlyStatisticsProxy;
  final crashlytics = appSetting.crashlytics;
  final testUrl = appSetting.testUrl;
  final stack = clashConfig.stack;
  final port = clashConfig.mixedPort;
  return SharedState(
    currentProfileName: currentProfileName,
    onlyStatisticsProxy: onlyStatisticsProxy,
    stopText: currentAppLocalizations.stop,
    crashlytics: crashlytics,
    stopTip: currentAppLocalizations.stopVpn,
    startTip: currentAppLocalizations.startVpn,
    setupParams: SetupParams(selectedMap: selectedMap, testUrl: testUrl),
    vpnOptions: VpnOptions(
      enable: vpnSetting.enable,
      stack: stack,
      systemProxy: vpnSetting.systemProxy,
      port: port,
      ipv6: vpnSetting.ipv6,
      dnsHijacking: vpnSetting.dnsHijacking,
      accessControlProps: vpnSetting.accessControlProps,
      allowBypass: vpnSetting.allowBypass,
      bypassDomain: bypassDomain,
    ),
  );
}

@riverpod
class AccessControlState extends _$AccessControlState
    with AutoDisposeNotifierMixin {
  @override
  AccessControlProps build() => const AccessControlProps();
}

@riverpod
bool suspend(Ref ref) {
  final currentSSID = ref.watch(currentSSIDProvider);
  final excludeSSIDs = ref.watch(excludeSSIDsProvider);
  return excludeSSIDs.contains(currentSSID);
}
