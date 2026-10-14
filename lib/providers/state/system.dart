part of '../state.dart';

@riverpod
UpdateParams updateParams(Ref ref) {
  final bypassPrivateRoute = ref.watch(
    networkSettingProvider.select((state) => state.bypassPrivateRoute),
  );
  final authentication = ref.watch(
    networkSettingProvider.select((state) => state.authentication),
  );
  final checkCertificate = ref.watch(
    appSettingProvider.select((state) => state.checkCertificate),
  );
  return ref.watch(
    patchClashConfigProvider.select(
      (state) => state.toUpdateParams(
        bypassPrivateRoute: bypassPrivateRoute,
        authentication: authentication.credentials,
        skipCertVerify: !checkCertificate,
      ),
    ),
  );
}

@riverpod
({PatchClashConfig patchConfig, bool appendSystemDns}) setupPatch(Ref ref) {
  return (
    patchConfig: ref.watch(
      patchClashConfigProvider.select((state) => state.setupOnly),
    ),
    appendSystemDns: ref.watch(
      networkSettingProvider.select((state) => state.appendSystemDns),
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
  final safeMode = ref.watch(safeModeProvider);
  final hotKeys = _trayHotKeys(ref);

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
    safeMode: safeMode,
    hotKeys: hotKeys,
  );
}

Map<HotAction, HotKeyAction> _trayHotKeys(Ref ref) {
  final failures = ref.watch(hotKeyFailuresProvider);
  return {
    for (final hotKeyAction in ref.watch(hotKeyActionsProvider))
      if (isValidHotKey(hotKeyAction.modifiers, hotKeyAction.key) &&
          !failures.containsKey(hotKeyAction.action))
        hotKeyAction.action: hotKeyAction,
  };
}

/// Measured delays of the proxies the tray lists, by group and then proxy
/// name. Resolved like a proxy card, so a nested group shows its selection.
@riverpod
Map<String, Map<String, int>> trayDelays(Ref ref) {
  final delayMap = ref.watch(delayDataSourceProvider);
  if (delayMap.isEmpty) {
    return const {};
  }
  final groups = ref.watch(currentGroupsStateProvider).value;
  final allGroups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  final defaultTestUrl = ref.watch(
    appSettingProvider.select((state) => state.testUrl),
  );
  final delays = <String, Map<String, int>>{};
  for (final group in groups) {
    final testUrl = group.testUrl.takeFirstValid([defaultTestUrl]);
    final groupDelays = <String, int>{};
    for (final proxy in group.all) {
      final delay = computeProxyDelayState(
        proxyName: proxy.name,
        testUrl: testUrl,
        groups: allGroups,
        selectedMap: selectedMap,
        delayMap: delayMap,
      ).delay;
      if (delay != 0) {
        groupDelays[proxy.name] = delay;
      }
    }
    if (groupDelays.isNotEmpty) {
      delays[group.name] = groupDelays;
    }
  }
  return delays;
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
bool shouldPatchSystemDns(Ref ref) {
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  if (!autoSetSystemDns || ref.watch(safeModeProvider)) {
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
        showStopAction: state.showNotificationStopAction,
        crashlytics: state.crashlytics,
        testUrl: state.testUrl,
        checkCertificate: state.checkCertificate,
      ),
    ),
  );
  final currentProfileName = currentProfile.label;
  final selectedMap = currentProfile.selectedMap;
  final onlyStatisticsProxy = appSetting.onlyStatisticsProxy;
  final crashlytics = appSetting.crashlytics;
  final testUrl = appSetting.testUrl;
  return SharedState(
    currentProfileName: currentProfileName,
    onlyStatisticsProxy: onlyStatisticsProxy,
    showStopAction: appSetting.showStopAction,
    stopText: currentAppLocalizations.stop,
    crashlytics: crashlytics,
    stopTip: currentAppLocalizations.stopVpn,
    startTip: currentAppLocalizations.startVpn,
    localNetworkTip: currentAppLocalizations.localNetworkDeniedTip,
    setupParams: SetupParams(
      selectedMap: selectedMap,
      testUrl: testUrl,
      skipCertVerify: !appSetting.checkCertificate,
    ),
    vpnOptions: ref.watch(vpnOptionsProvider).value,
  );
}

@Riverpod(keepAlive: true)
Future<List<String>> vpnRouteAddress(Ref ref) {
  final routes = ref.watch(
    patchClashConfigProvider.select(
      (state) => Tun(
        routeAddress: state.tun.routeAddress,
        routeExcludeAddress: state.tun.routeExcludeAddress,
      ),
    ),
  );
  final bypassPrivateRoute = ref.watch(
    networkSettingProvider.select((state) => state.bypassPrivateRoute),
  );
  return routes.vpnRouteAddress(bypassPrivateRoute: bypassPrivateRoute);
}

@Riverpod(keepAlive: true)
Future<VpnOptions> vpnOptions(Ref ref) async {
  final networkSetting = ref.watch(
    networkSettingProvider.select(
      (state) => (
        bypassDomain: state.bypassDomain,
        authenticated: state.authentication.credentials.isNotEmpty,
      ),
    ),
  );
  final clashConfig = ref.watch(
    patchClashConfigProvider.select(
      (state) => (tun: state.tun, mixedPort: state.mixedPort),
    ),
  );
  final vpnSetting = ref.watch(vpnSettingProvider);
  final safeMode = ref.watch(safeModeProvider);
  final routeAddress = ref.watch(vpnRouteAddressProvider.future);
  final tun = clashConfig.tun;
  return VpnOptions(
    enable: vpnSetting.enable && !safeMode,
    stack: tun.stack.name,
    // VpnService.setHttpProxy cannot carry credentials, so an authenticated
    // mixed port is left to TUN instead of declared as the system proxy.
    systemProxy:
        vpnSetting.systemProxy && !networkSetting.authenticated && !safeMode,
    port: clashConfig.mixedPort,
    ipv6: vpnSetting.ipv6,
    dnsHijacking: vpnSetting.dnsHijacking,
    accessControlProps: vpnSetting.accessControlProps,
    allowBypass: vpnSetting.allowBypass,
    bypassDomain: networkSetting.bypassDomain,
    routeAddress: await routeAddress,
    mtu: tun.mtu,
    congestionController: tun.congestionController,
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
