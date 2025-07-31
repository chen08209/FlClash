import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';

part 'generated/state.g.dart';

@riverpod
Config configState(Ref ref) {
  final themeProps = ref.watch(themeSettingProvider);
  final patchClashConfig = ref.watch(patchClashConfigProvider);
  final appSetting = ref.watch(appSettingProvider);
  final profiles = ref.watch(profilesProvider);
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final overrideDns = ref.watch(overrideDnsProvider);
  final networkProps = ref.watch(networkSettingProvider);
  final vpnProps = ref.watch(vpnSettingProvider);
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final scriptProps = ref.watch(scriptStateProvider);
  final hotKeyActions = ref.watch(hotKeyActionsProvider);
  final dav = ref.watch(appDAVSettingProvider);
  final windowProps = ref.watch(windowSettingProvider);
  return Config(
    dav: dav,
    windowProps: windowProps,
    hotKeyActions: hotKeyActions,
    scriptProps: scriptProps,
    proxiesStyle: proxiesStyle,
    vpnProps: vpnProps,
    networkProps: networkProps,
    overrideDns: overrideDns,
    currentProfileId: currentProfileId,
    profiles: profiles,
    appSetting: appSetting,
    themeProps: themeProps,
    patchClashConfig: patchClashConfig,
  );
}

@riverpod
GroupsState currentGroupsState(Ref ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final groups = ref.watch(groupsProvider);
  return GroupsState(
    value: switch (mode) {
      Mode.direct => [],
      Mode.global => groups.toList(),
      Mode.rule =>
        groups
            .where((item) => item.hidden == false)
            .where((element) => element.name != GroupName.GLOBAL.name)
            .toList(),
    },
  );
}

@riverpod
NavigationItemsState navigationItemsState(Ref ref) {
  final openLogs = ref.watch(appSettingProvider).openLogs;
  final hasProfiles = ref.watch(
    profilesProvider.select((state) => state.isNotEmpty),
  );
  final hasProxies = ref.watch(
    currentGroupsStateProvider.select((state) => state.value.isNotEmpty),
  );
  final isInit = ref.watch(initProvider);
  return NavigationItemsState(
    value: navigation.getItems(
      openLogs: openLogs,
      hasProxies: !isInit ? hasProfiles : hasProxies,
    ),
  );
}

@riverpod
NavigationItemsState currentNavigationItemsState(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final navigationItemsState = ref.watch(navigationItemsStateProvider);
  final navigationItemMode = switch (viewWidth <= maxMobileWidth) {
    true => NavigationItemMode.mobile,
    false => NavigationItemMode.desktop,
  };
  return NavigationItemsState(
    value: navigationItemsState.value
        .where((element) => element.modes.contains(navigationItemMode))
        .toList(),
  );
}

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
      ),
    ),
  );
}

@riverpod
ProxyState proxyState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final vm2 = ref.watch(
    networkSettingProvider.select(
      (state) => VM2(a: state.systemProxy, b: state.bypassDomain),
    ),
  );
  final mixedPort = ref.watch(
    patchClashConfigProvider.select((state) => state.mixedPort),
  );
  return ProxyState(
    isStart: isStart,
    systemProxy: vm2.a,
    bassDomain: vm2.b,
    port: mixedPort,
  );
}

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final networkProps = ref.watch(networkSettingProvider);
  final clashConfig = ref.watch(patchClashConfigProvider);
  final appSetting = ref.watch(appSettingProvider);
  final groups = ref.watch(currentGroupsStateProvider).value;
  final brightness = ref.watch(systemBrightnessProvider);

  final selectedMap = ref.watch(selectedMapProvider);

  return TrayState(
    mode: clashConfig.mode,
    port: clashConfig.mixedPort,
    autoLaunch: appSetting.autoLaunch,
    systemProxy: networkProps.systemProxy,
    tunEnable: clashConfig.tun.enable,
    isStart: isStart,
    locale: appSetting.locale,
    brightness: brightness,
    groups: groups,
    selectedMap: selectedMap,
  );
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
NavigationState navigationState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final navigationItems = ref.watch(currentNavigationItemsStateProvider).value;
  final viewMode = ref.watch(viewModeProvider);
  final locale = ref.watch(appSettingProvider).locale;
  final index = navigationItems.lastIndexWhere(
    (element) => element.label == pageLabel,
  );
  final currentIndex = index == -1 ? 0 : index;
  return NavigationState(
    pageLabel: pageLabel,
    navigationItems: navigationItems,
    viewMode: viewMode,
    locale: locale,
    currentIndex: currentIndex,
  );
}

@riverpod
double contentWidth(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final sideWidth = ref.watch(sideWidthProvider);
  return viewWidth - sideWidth;
}

@riverpod
DashboardState dashboardState(Ref ref) {
  final dashboardWidgets = ref.watch(
    appSettingProvider.select((state) => state.dashboardWidgets),
  );
  final contentWidth = ref.watch(contentWidthProvider);
  return DashboardState(
    dashboardWidgets: dashboardWidgets,
    contentWidth: contentWidth,
  );
}

@riverpod
ProxiesActionsState proxiesActionsState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final hasProviders = ref.watch(
    providersProvider.select((state) => state.isNotEmpty),
  );
  final type = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.type),
  );
  return ProxiesActionsState(
    pageLabel: pageLabel,
    hasProviders: hasProviders,
    type: type,
  );
}

@riverpod
StartButtonSelectorState startButtonSelectorState(Ref ref) {
  final isInit = ref.watch(initProvider);
  final hasProfile = ref.watch(
    profilesProvider.select((state) => state.isNotEmpty),
  );
  return StartButtonSelectorState(isInit: isInit, hasProfile: hasProfile);
}

@riverpod
ProfilesSelectorState profilesSelectorState(Ref ref) {
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final profiles = ref.watch(profilesProvider);
  final columns = ref.watch(
    contentWidthProvider.select((state) => utils.getProfilesColumns(state)),
  );
  return ProfilesSelectorState(
    profiles: profiles,
    currentProfileId: currentProfileId,
    columns: columns,
  );
}

@riverpod
GroupsState filterGroupsState(Ref ref, String query) {
  final currentGroups = ref.watch(currentGroupsStateProvider);
  if (query.isEmpty) {
    return currentGroups;
  }
  final lowQuery = query.toLowerCase();
  final groups = currentGroups.value
      .map((group) {
        return group.copyWith(
          all: group.all
              .where((proxy) => proxy.name.toLowerCase().contains(lowQuery))
              .toList(),
        );
      })
      .where((group) => group.all.isNotEmpty)
      .toList();
  return GroupsState(value: groups);
}

@riverpod
ProxiesListState proxiesListState(Ref ref) {
  final query = ref.watch(queryProvider(QueryTag.proxies));
  final currentGroups = ref.watch(filterGroupsStateProvider(query));
  final currentUnfoldSet = ref.watch(unfoldSetProvider);
  final cardType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.cardType),
  );

  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxiesListState(
    groups: currentGroups.value,
    currentUnfoldSet: currentUnfoldSet,
    proxyCardType: cardType,
    columns: columns,
  );
}

@riverpod
ProxiesTabState proxiesTabState(Ref ref) {
  final query = ref.watch(queryProvider(QueryTag.proxies));
  final currentGroups = ref.watch(filterGroupsStateProvider(query));
  final currentGroupName = ref.watch(
    currentProfileProvider.select((state) => state?.currentGroupName),
  );
  final cardType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.cardType),
  );
  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxiesTabState(
    groups: currentGroups.value,
    currentGroupName: currentGroupName,
    proxyCardType: cardType,
    columns: columns,
  );
}

@riverpod
bool isStart(Ref ref) {
  return ref.watch(runTimeProvider.select((state) => state != null));
}

@riverpod
VM2<List<String>, String?> proxiesTabControllerState(Ref ref) {
  return ref.watch(
    proxiesTabStateProvider.select(
      (state) => VM2(
        a: state.groups.map((group) => group.name).toList(),
        b: state.currentGroupName,
      ),
    ),
  );
}

@riverpod
ProxyGroupSelectorState proxyGroupSelectorState(
  Ref ref,
  String groupName,
  String query,
) {
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final group = ref.watch(
    currentGroupsStateProvider.select(
      (state) => state.value.getGroup(groupName),
    ),
  );
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(getProxiesColumnsProvider);
  final lowQuery = query.toLowerCase();
  final proxies =
      group?.all.where((item) {
        return item.name.toLowerCase().contains(lowQuery);
      }).toList() ??
      [];
  return ProxyGroupSelectorState(
    testUrl: group?.testUrl,
    proxiesSortType: proxiesStyle.sortType,
    proxyCardType: proxiesStyle.cardType,
    sortNum: sortNum,
    groupType: group?.type ?? GroupType.Selector,
    proxies: proxies,
    columns: columns,
  );
}

@riverpod
PackageListSelectorState packageListSelectorState(Ref ref) {
  final packages = ref.watch(packagesProvider);
  final accessControl = ref.watch(
    vpnSettingProvider.select((state) => state.accessControl),
  );
  return PackageListSelectorState(
    packages: packages,
    accessControl: accessControl,
  );
}

@riverpod
MoreToolsSelectorState moreToolsSelectorState(Ref ref) {
  final viewMode = ref.watch(viewModeProvider);
  final navigationItems = ref.watch(
    navigationItemsStateProvider.select((state) {
      return state.value.where((element) {
        final isMore = element.modes.contains(NavigationItemMode.more);
        final isDesktop = element.modes.contains(NavigationItemMode.desktop);
        if (isMore && !isDesktop) return true;
        if (viewMode != ViewMode.mobile || !isMore) {
          return false;
        }
        return true;
      }).toList();
    }),
  );

  return MoreToolsSelectorState(navigationItems: navigationItems);
}

@riverpod
bool isCurrentPage(
  Ref ref,
  PageLabel pageLabel, {
  bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
}) {
  final currentPageLabel = ref.watch(currentPageLabelProvider);
  if (pageLabel == currentPageLabel) {
    return true;
  }
  if (handler != null) {
    final viewMode = ref.watch(viewModeProvider);
    return handler(currentPageLabel, viewMode);
  }
  return false;
}

@riverpod
String getRealTestUrl(Ref ref, [String? testUrl]) {
  final currentTestUrl = ref.watch(appSettingProvider).testUrl;
  return testUrl.getSafeValue(currentTestUrl);
}

@riverpod
int? getDelay(Ref ref, {required String proxyName, String? testUrl}) {
  final currentTestUrl = ref.watch(getRealTestUrlProvider(testUrl));
  final proxyState = ref.watch(realSelectedProxyStateProvider(proxyName));
  final delay = ref.watch(
    delayDataSourceProvider.select((state) {
      final delayMap = state[proxyState.testUrl.getSafeValue(currentTestUrl)];
      return delayMap?[proxyState.proxyName];
    }),
  );

  return delay;
}

@riverpod
SelectedMap selectedMap(Ref ref) {
  final selectedMap = ref.watch(
    currentProfileProvider.select((state) => state?.selectedMap ?? {}),
  );
  return selectedMap;
}

@riverpod
Set<String> unfoldSet(Ref ref) {
  final unfoldSet = ref.watch(
    currentProfileProvider.select((state) => state?.unfoldSet ?? {}),
  );
  return unfoldSet;
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
Profile? currentProfile(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return ref.watch(
    profilesProvider.select((state) => state.getProfile(profileId)),
  );
}

@riverpod
int getProxiesColumns(Ref ref) {
  final contentWidth = ref.watch(contentWidthProvider);
  final proxiesLayout = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.layout),
  );
  return utils.getProxiesColumns(contentWidth, proxiesLayout);
}

@riverpod
SelectedProxyState realSelectedProxyState(Ref ref, String proxyName) {
  final groups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  return computeRealSelectedProxyState(
    proxyName,
    groups: groups,
    selectedMap: selectedMap,
  );
}

@riverpod
String? getProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(
    selectedMapProvider.select((state) => state[groupName]),
  );
  return proxyName;
}

@riverpod
String? getSelectedProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(getProxyNameProvider(groupName));
  final group = ref.watch(
    groupsProvider.select((state) => state.getGroup(groupName)),
  );
  return group?.getCurrentSelectedName(proxyName ?? '');
}

@riverpod
String getProxyDesc(Ref ref, Proxy proxy) {
  final groupTypeNamesList = GroupType.values.map((e) => e.name).toList();
  if (!groupTypeNamesList.contains(proxy.type)) {
    return proxy.type;
  } else {
    final groups = ref.watch(groupsProvider);
    final index = groups.indexWhere((element) => element.name == proxy.name);
    if (index == -1) return proxy.type;
    final state = ref.watch(realSelectedProxyStateProvider(proxy.name));
    return "${proxy.type}(${state.proxyName.isNotEmpty ? state.proxyName : '*'})";
  }
}

@riverpod
OverrideData? getProfileOverrideData(Ref ref, String profileId) {
  return ref.watch(
    profilesProvider.select(
      (state) => state.getProfile(profileId)?.overrideData,
    ),
  );
}

@riverpod
VM2? layoutChange(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final textScale = ref.watch(
    themeSettingProvider.select((state) => state.textScale),
  );
  return VM2(a: viewWidth, b: textScale);
}

@riverpod
VM2<int, bool> checkIp(Ref ref) {
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsDetection = ref.watch(
    dashboardStateProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.networkDetection),
    ),
  );
  return VM2(a: checkIpNum, b: containsDetection);
}

@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final vm2 = ref.watch(
    themeSettingProvider.select(
      (state) => VM2(a: state.primaryColor, b: state.schemeVariant),
    ),
  );
  if (color == null && (ignoreConfig == true || vm2.a == null)) {
    // if (globalState.corePalette != null) {
    //   return globalState.corePalette!.toColorScheme(brightness: brightness);
    // }
    return ColorScheme.fromSeed(
      seedColor:
          globalState.corePalette
              ?.toColorScheme(brightness: brightness)
              .primary ??
          globalState.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: vm2.b,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(vm2.a!),
    brightness: brightness,
    dynamicSchemeVariant: vm2.b,
  );
}

@riverpod
VM3<String?, String?, Dns?> needSetup(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  final content = ref.watch(
    scriptStateProvider.select((state) => state.currentScript?.content),
  );
  final overrideDns = ref.watch(overrideDnsProvider);
  final dns = overrideDns == true
      ? ref.watch(patchClashConfigProvider.select((state) => state.dns))
      : null;
  return VM3(a: profileId, b: content, c: dns);
}

@riverpod
Brightness currentBrightness(Ref ref) {
  final themeMode = ref.watch(
    themeSettingProvider.select((state) => state.themeMode),
  );
  final systemBrightness = ref.watch(systemBrightnessProvider);
  return switch (themeMode) {
    ThemeMode.system => systemBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}

@riverpod
VM2<bool, bool> autoSetSystemDnsState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final realTunEnable = ref.watch(realTunEnableProvider);
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  return VM2(a: isStart ? realTunEnable : false, b: autoSetSystemDns);
}

@riverpod
VM3<bool, int, ProxiesSortType> needUpdateGroups(Ref ref) {
  final isProxies = ref.watch(
    currentPageLabelProvider.select((state) => state == PageLabel.proxies),
  );
  final sortNum = ref.watch(sortNumProvider);
  final sortType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.sortType),
  );
  return VM3(a: isProxies, b: sortNum, c: sortType);
}

@riverpod
AndroidState androidState(Ref ref) {
  final currentProfileName = ref.watch(
    currentProfileProvider.select((state) => state?.label ?? ''),
  );
  final onlyStatisticsProxy = ref.watch(
    appSettingProvider.select((state) => state.onlyStatisticsProxy),
  );
  ref.watch((appSettingProvider).select((state) => state.locale));
  return AndroidState(
    currentProfileName: currentProfileName,
    onlyStatisticsProxy: onlyStatisticsProxy,
    stopText: appLocalizations.stop,
  );
}

@riverpod
class Query extends _$Query {
  @override
  String build(QueryTag id) =>
      ref.watch(queryMapProvider.select((state) => state[id] ?? ''));
}
