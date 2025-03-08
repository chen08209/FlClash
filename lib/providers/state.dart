import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';

part 'generated/state.g.dart';

@riverpod
GroupsState currentGroupsState(Ref ref) {
  final mode =
      ref.watch(patchClashConfigProvider.select((state) => state.mode));
  final groups = ref.watch(groupsProvider);
  return GroupsState(
    value: switch (mode) {
      Mode.direct => [],
      Mode.global => groups.toList(),
      Mode.rule => groups
          .where((item) => item.hidden == false)
          .where((element) => element.name != GroupName.GLOBAL.name)
          .toList(),
    },
  );
}

@riverpod
NavigationItemsState navigationsState(Ref ref) {
  final openLogs = ref.watch(appSettingProvider).openLogs;
  final hasProxies = ref.watch(
      currentGroupsStateProvider.select((state) => state.value.isNotEmpty));
  return NavigationItemsState(
    value: navigation.getItems(
      openLogs: openLogs,
      hasProxies: hasProxies,
    ),
  );
}

@riverpod
NavigationItemsState currentNavigationsState(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final navigationItemsState = ref.watch(navigationsStateProvider);
  final navigationItemMode = switch (viewWidth <= maxMobileWidth) {
    true => NavigationItemMode.mobile,
    false => NavigationItemMode.desktop,
  };
  return NavigationItemsState(
    value: navigationItemsState.value
        .where(
          (element) => element.modes.contains(navigationItemMode),
        )
        .toList(),
  );
}

@riverpod
CoreState coreState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final currentProfile = ref.watch(currentProfileProvider);
  final onlyStatisticsProxy = ref.watch(appSettingProvider).onlyStatisticsProxy;
  return CoreState(
    vpnProps: vpnProps,
    onlyStatisticsProxy: onlyStatisticsProxy,
    currentProfileName: currentProfile?.label ?? currentProfile?.id ?? "",
  );
}

@riverpod
ClashConfigState clashConfigState(Ref ref) {
  final clashConfig = ref.watch(patchClashConfigProvider);
  final overrideDns = ref.watch(overrideDnsProvider);
  return ClashConfigState(
    overrideDns: overrideDns,
    clashConfig: clashConfig,
  );
}

@riverpod
ProxyState proxyState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final vm2 = ref.watch(networkSettingProvider.select(
    (state) => VM2(
      a: state.systemProxy,
      b: state.bypassDomain,
    ),
  ));
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
  final clashConfig = ref.watch(
    patchClashConfigProvider,
  );
  final appSetting = ref.watch(
    appSettingProvider,
  );
  final groups = ref.watch(
    groupsProvider,
  );
  final brightness = ref.watch(
    appBrightnessProvider,
  );

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

  return VpnState(
    stack: stack,
    vpnProps: vpnProps,
  );
}

@riverpod
HomeState homeState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final navigationItems = ref.watch(currentNavigationsStateProvider).value;
  final viewMode = ref.watch(viewWidthProvider.notifier).viewMode;
  final locale = ref.watch(appSettingProvider).locale;
  return HomeState(
    pageLabel: pageLabel,
    navigationItems: navigationItems,
    viewMode: viewMode,
    locale: locale,
  );
}

@riverpod
DashboardState dashboardState(Ref ref) {
  final dashboardWidgets =
      ref.watch(appSettingProvider.select((state) => state.dashboardWidgets));
  final viewWidth = ref.watch(viewWidthProvider);
  return DashboardState(
    dashboardWidgets: dashboardWidgets,
    viewWidth: viewWidth,
  );
}

@riverpod
ProxiesActionsState proxiesActionsState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final hasProviders = ref.watch(providersProvider.select(
    (state) => state.isNotEmpty,
  ));
  final type = ref.watch(proxiesStyleSettingProvider.select(
    (state) => state.type,
  ));
  return ProxiesActionsState(
    pageLabel: pageLabel,
    hasProviders: hasProviders,
    type: type,
  );
}

@riverpod
StartButtonSelectorState startButtonSelectorState(Ref ref) {
  final isInit = ref.watch(initProvider);
  final hasProfile =
      ref.watch(profilesProvider.select((state) => state.isNotEmpty));
  return StartButtonSelectorState(
    isInit: isInit,
    hasProfile: hasProfile,
  );
}

@riverpod
ProfilesSelectorState profilesSelectorState(Ref ref) {
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final profiles = ref.watch(profilesProvider);
  final columns = ref.watch(
      viewWidthProvider.select((state) => other.getProfilesColumns(state)));
  return ProfilesSelectorState(
    profiles: profiles,
    currentProfileId: currentProfileId,
    columns: columns,
  );
}

@riverpod
ProxiesListSelectorState proxiesListSelectorState(Ref ref) {
  final groupNames = ref.watch(currentGroupsStateProvider.select((state) {
    return state.value.map((e) => e.name).toList();
  }));
  final currentUnfoldSet = ref.watch(unfoldSetProvider);
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxiesListSelectorState(
    groupNames: groupNames,
    currentUnfoldSet: currentUnfoldSet,
    proxiesSortType: proxiesStyle.sortType,
    proxyCardType: proxiesStyle.cardType,
    sortNum: sortNum,
    columns: columns,
  );
}

@riverpod
ProxiesSelectorState proxiesSelectorState(Ref ref) {
  final groupNames = ref.watch(
    currentGroupsStateProvider.select(
      (state) {
        return state.value.map((e) => e.name).toList();
      },
    ),
  );
  final currentGroupName = ref.watch(currentProfileProvider.select(
    (state) => state?.currentGroupName,
  ));
  return ProxiesSelectorState(
    groupNames: groupNames,
    currentGroupName: currentGroupName,
  );
}

@riverpod
GroupNamesState groupNamesState(Ref ref) {
  return GroupNamesState(
    groupNames: ref.watch(
      currentGroupsStateProvider.select(
        (state) {
          return state.value.map((e) => e.name).toList();
        },
      ),
    ),
  );
}

@riverpod
ProxyGroupSelectorState proxyGroupSelectorState(Ref ref, String groupName) {
  final proxiesStyle = ref.watch(
    proxiesStyleSettingProvider,
  );
  final group = ref.watch(
    currentGroupsStateProvider.select(
      (state) => state.value.getGroup(groupName),
    ),
  );
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxyGroupSelectorState(
    testUrl: group?.testUrl,
    proxiesSortType: proxiesStyle.sortType,
    proxyCardType: proxiesStyle.cardType,
    sortNum: sortNum,
    groupType: group?.type ?? GroupType.Selector,
    proxies: group?.all ?? [],
    columns: columns,
  );
}

@riverpod
PackageListSelectorState packageListSelectorState(Ref ref) {
  final packages = ref.watch(packagesProvider);
  final accessControl =
      ref.watch(vpnSettingProvider.select((state) => state.accessControl));
  return PackageListSelectorState(
    packages: packages,
    accessControl: accessControl,
  );
}

@riverpod
MoreToolsSelectorState moreToolsSelectorState(Ref ref) {
  final viewMode = ref.watch(viewWidthProvider.notifier).viewMode;
  final navigationItems = ref.watch(navigationsStateProvider.select((state) {
    return state.value.where((element) {
      final isMore = element.modes.contains(NavigationItemMode.more);
      final isDesktop = element.modes.contains(NavigationItemMode.desktop);
      if (isMore && !isDesktop) return true;
      if (viewMode != ViewMode.mobile || !isMore) {
        return false;
      }
      return true;
    }).toList();
  }));

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
    final viewMode = ref.watch(viewWidthProvider.notifier).viewMode;
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
int? getDelay(
  Ref ref, {
  required String proxyName,
  String? testUrl,
}) {
  final currentTestUrl = ref.watch(getRealTestUrlProvider(testUrl));
  final proxyCardState = ref.watch(
    getProxyCardStateProvider(
      proxyName,
    ),
  );
  final delay = ref.watch(
    delayDataSourceProvider.select(
      (state) {
        final delayMap =
            state[proxyCardState.testUrl.getSafeValue(currentTestUrl)];
        return delayMap?[proxyCardState.proxyName];
      },
    ),
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
    hotKeyActionsProvider.select(
      (state) {
        final index = state.indexWhere((item) => item.action == hotAction);
        return index != -1
            ? state[index]
            : HotKeyAction(
                action: hotAction,
              );
      },
    ),
  );
}

@riverpod
Profile? currentProfile(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return ref
      .watch(profilesProvider.select((state) => state.getProfile(profileId)));
}

@riverpod
int getProxiesColumns(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final proxiesLayout =
      ref.watch(proxiesStyleSettingProvider.select((state) => state.layout));
  return other.getProxiesColumns(viewWidth, proxiesLayout);
}

ProxyCardState _getProxyCardState(
  List<Group> groups,
  SelectedMap selectedMap,
  ProxyCardState proxyDelayState,
) {
  if (proxyDelayState.proxyName.isEmpty) return proxyDelayState;
  final index =
      groups.indexWhere((element) => element.name == proxyDelayState.proxyName);
  if (index == -1) return proxyDelayState;
  final group = groups[index];
  final currentSelectedName = group
      .getCurrentSelectedName(selectedMap[proxyDelayState.proxyName] ?? '');
  return _getProxyCardState(
    groups,
    selectedMap,
    proxyDelayState.copyWith(
      proxyName: currentSelectedName,
      testUrl: group.testUrl,
    ),
  );
}

@riverpod
ProxyCardState getProxyCardState(Ref ref, String proxyName) {
  final groups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  return _getProxyCardState(
      groups, selectedMap, ProxyCardState(proxyName: proxyName));
}

@riverpod
String? getProxyName(Ref ref, String groupName) {
  final proxyName =
      ref.watch(selectedMapProvider.select((state) => state[groupName]));
  return proxyName;
}

@riverpod
String? getSelectedProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(getProxyNameProvider(groupName));
  final group = ref.watch(
    groupsProvider.select(
      (state) => state.getGroup(groupName),
    ),
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
    final state = ref.watch(getProxyCardStateProvider(proxy.name));
    return "${proxy.type}(${state.proxyName.isNotEmpty ? state.proxyName : '*'})";
  }
}
