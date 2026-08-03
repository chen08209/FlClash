import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';
import 'database.dart';

part 'generated/state.g.dart';

@riverpod
GroupsState currentGroupsState(Ref ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final groups = ref.watch(
    groupsProvider.select(
      (state) => state.map((item) {
        return item.copyWith(
          now: '',
          all: item.all.map((proxy) => proxy.copyWith(now: '')).toList(),
        );
      }),
    ),
  );
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
  final openLogs = ref.watch(
    appSettingProvider.select((state) => state.openLogs),
  );
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
        geoAutoUpdate: state.geoAutoUpdate,
        geoUpdateInterval: state.geoUpdateInterval,
      ),
    ),
  );
}

@riverpod
ProxyState proxyState(Ref ref) {
  final suspend = ref.watch(suspendProvider);
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final vm2 = ref.watch(
    networkSettingProvider.select(
      (state) => VM2(state.systemProxy, state.bypassDomain),
    ),
  );
  final mixedPort = ref.watch(
    patchClashConfigProvider.select((state) => state.mixedPort),
  );
  return ProxyState(
    isStart: suspend ? false : isStart,
    systemProxy: vm2.a,
    bassDomain: vm2.b,
    port: mixedPort,
  );
}

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final systemProxy = ref.watch(
    networkSettingProvider.select((state) => state.systemProxy),
  );
  final clashConfigVm3 = ref.watch(
    patchClashConfigProvider.select(
      (state) => VM3(state.mode, state.mixedPort, state.tun.enable),
    ),
  );
  final appSettingVm3 = ref.watch(
    appSettingProvider.select(
      (state) => VM3(state.autoLaunch, state.locale, state.showTrayTitle),
    ),
  );
  final groups = ref.watch(currentGroupsStateProvider).value;
  final brightness = ref.watch(systemBrightnessProvider);
  final selectedMap = ref.watch(selectedMapProvider);

  return TrayState(
    mode: clashConfigVm3.a,
    port: clashConfigVm3.b,
    autoLaunch: appSettingVm3.a,
    systemProxy: systemProxy,
    tunEnable: clashConfigVm3.c,
    isStart: isStart,
    locale: appSettingVm3.b,
    brightness: brightness,
    groups: groups,
    selectedMap: selectedMap,
    showTrayTitle: appSettingVm3.c,
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
NavigationState navigationState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final navigationItems = ref.watch(currentNavigationItemsStateProvider).value;
  final viewMode = ref.watch(viewModeProvider);
  final locale = ref.watch(
    appSettingProvider.select((state) => state.locale),
  );
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
ProfilesState profilesState(Ref ref) {
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final profiles = ref.watch(profilesProvider);
  final columns = ref.watch(
    contentWidthProvider.select((state) => utils.getProfilesColumns(state)),
  );
  return ProfilesState(
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
  return currentGroups.copyWith(value: groups);
}

@riverpod
ProxiesListState proxiesListState(Ref ref) {
  final query = ref.watch(queryProvider(QueryTag.proxies));
  final currentGroups = ref.watch(filterGroupsStateProvider(query));
  final currentUnfoldSet = ref.watch(unfoldSetProvider);
  final cardType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.cardType),
  );

  final columns = ref.watch(proxiesColumnsProvider);
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
  final columns = ref.watch(proxiesColumnsProvider);
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
        state.groups.map((group) => group.name).toList(),
        state.currentGroupName,
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
  final proxiesStyle = ref.watch(
    proxiesStyleSettingProvider.select(
      (state) => VM2(state.sortType, state.cardType),
    ),
  );
  final group = ref.watch(
    currentGroupsStateProvider.select(
      (state) => state.value.getGroup(groupName),
    ),
  );
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(proxiesColumnsProvider);
  final lowQuery = query.toLowerCase();
  final proxies =
      group?.all.where((item) {
        return item.name.toLowerCase().contains(lowQuery);
      }).toList() ??
      [];
  return ProxyGroupSelectorState(
    testUrl: group?.testUrl,
    proxiesSortType: proxiesStyle.a,
    proxyCardType: proxiesStyle.b,
    sortNum: sortNum,
    groupType: group?.type ?? GroupType.Selector,
    proxies: proxies,
    columns: columns,
  );
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
MoreToolsSelectorState moreToolsSelectorState(Ref ref) {
  final viewMode = ref.watch(viewModeProvider);
  final navigationItems = ref
      .watch(
        navigationItemsStateProvider.select((state) {
          return VM(
            state.value.where((element) {
              final isMore = element.modes.contains(NavigationItemMode.more);
              final isDesktop = element.modes.contains(
                NavigationItemMode.desktop,
              );
              if (isMore && !isDesktop) return true;
              if (viewMode != ViewMode.mobile || !isMore) {
                return false;
              }
              return true;
            }).toList(),
          );
        }),
      )
      .a;

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
String realTestUrl(Ref ref, [String? testUrl]) {
  final currentTestUrl = ref.watch(
    appSettingProvider.select((state) => state.testUrl),
  );
  return testUrl.takeFirstValid([currentTestUrl]);
}

@riverpod
int? delay(Ref ref, {required String proxyName, String? testUrl}) {
  final currentTestUrl = ref.watch(realTestUrlProvider(testUrl));
  final proxyState = ref.watch(realSelectedProxyStateProvider(proxyName));
  final effectiveTestUrl = proxyState.testUrl.takeFirstValid([currentTestUrl]);
  final effectiveProxyName = proxyState.proxyName;
  return ref.watch(
    delayDataSourceProvider.select(
      (state) => state[effectiveTestUrl]?[effectiveProxyName],
    ),
  );
}

@riverpod
Map<String, String> selectedMap(Ref ref) {
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
int proxiesColumns(Ref ref) {
  final contentWidth = ref.watch(contentWidthProvider);
  final proxiesLayout = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.layout),
  );
  return utils.getProxiesColumns(contentWidth, proxiesLayout);
}

@riverpod
Map<String, SelectedProxyState> realSelectedProxyStateMap(Ref ref) {
  final groups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  final map = <String, SelectedProxyState>{};
  for (final group in groups) {
    map.putIfAbsent(
      group.name,
      () => computeRealSelectedProxyState(
        group.name,
        groups: groups,
        selectedMap: selectedMap,
      ),
    );
    for (final proxy in group.all) {
      map.putIfAbsent(
        proxy.name,
        () => computeRealSelectedProxyState(
          proxy.name,
          groups: groups,
          selectedMap: selectedMap,
        ),
      );
    }
  }
  return map;
}

@riverpod
SelectedProxyState realSelectedProxyState(Ref ref, String proxyName) {
  return ref.watch(
    realSelectedProxyStateMapProvider.select(
      (state) =>
          state[proxyName] ?? SelectedProxyState(proxyName: proxyName),
    ),
  );
}

@riverpod
String? proxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(
    selectedMapProvider.select((state) => state[groupName]),
  );
  return proxyName;
}

@riverpod
String? selectedProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(proxyNameProvider(groupName));
  final group = ref.watch(
    groupsProvider.select((state) => state.getGroup(groupName)),
  );
  return group?.getCurrentSelectedName(proxyName ?? '');
}

@riverpod
String proxyDesc(Ref ref, Proxy proxy) {
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
VM3<bool, int, bool> checkIp(Ref ref) {
  final isInit = ref.watch(initProvider);
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsDetection = ref.watch(
    dashboardStateProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.networkDetection),
    ),
  );
  return VM3(isInit, checkIpNum, containsDetection);
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
      (state) => VM2(state.primaryColor, state.schemeVariant),
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
  final tunEnable = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.enable),
  );
  final authorizationState = ref.watch(authorizedTunEnableProvider);
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  final effectiveTunEnable =
      tunEnable && authorizationState == TunAuthorizationState.authorized;
  return VM2(isStart ? effectiveTunEnable : false, autoSetSystemDns);
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
  return VM3(isProxies, sortNum, sortType);
}

@riverpod
SharedState sharedState(Ref ref) {
  ref.watch((appSettingProvider).select((state) => state.locale));
  final currentProfileVM2 = ref.watch(
    currentProfileProvider.select(
      (state) => VM2(state?.label ?? '', state?.selectedMap ?? {}),
    ),
  );
  final appSettingVM3 = ref.watch(
    appSettingProvider.select(
      (state) =>
          VM3(state.onlyStatisticsProxy, state.crashlytics, state.testUrl),
    ),
  );
  final bypassDomain = ref.watch(
    networkSettingProvider.select((state) => state.bypassDomain),
  );
  final clashConfigVM2 = ref.watch(
    patchClashConfigProvider.select(
      (state) => VM2(state.tun.stack.name, state.mixedPort),
    ),
  );
  final vpnSetting = ref.watch(
    vpnSettingProvider.select(
      (state) => (
        enable: state.enable,
        systemProxy: state.systemProxy,
        ipv6: state.ipv6,
        dnsHijacking: state.dnsHijacking,
        accessControlProps: state.accessControlProps,
        allowBypass: state.allowBypass,
      ),
    ),
  );
  final currentProfileName = currentProfileVM2.a;
  final selectedMap = currentProfileVM2.b;
  final onlyStatisticsProxy = appSettingVM3.a;
  final crashlytics = appSettingVM3.b;
  final testUrl = appSettingVM3.c;
  final stack = clashConfigVM2.a;
  final port = clashConfigVM2.b;
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
double overlayTopOffset(Ref ref) {
  final isMobileView = ref.watch(isMobileViewProvider);
  final version = ref.watch(versionProvider);
  ref.watch(viewSizeProvider);
  double top = kHeaderHeight;
  if ((version <= 10 || !isMobileView) && system.isMacOS || !system.isDesktop) {
    top = 0;
  }
  return kToolbarHeight + top;
}

@riverpod
Profile? profile(Ref ref, int? profileId) {
  return ref.watch(
    profilesProvider.select((state) => state.getProfile(profileId)),
  );
}

@riverpod
OverwriteType overwriteType(Ref ref, int? profileId) {
  return ref.watch(
    profileProvider(
      profileId,
    ).select((state) => state?.overwriteType ?? OverwriteType.standard),
  );
}

@riverpod
Future<ClashConfig> clashConfig(Ref ref, int profileId) async {
  final configMap = await coreController.getConfig(profileId);
  final clashConfig = ClashConfig.fromJson(configMap);
  final Map<String, String> proxyTypeMap = {};
  for (final proxy in clashConfig.proxies) {
    proxyTypeMap[proxy.name] = proxy.type;
  }
  for (final proxyGroup in clashConfig.proxyGroups) {
    proxyTypeMap[proxyGroup.name] = proxyGroup.type.value;
  }
  return clashConfig.copyWith(proxyTypeMap: proxyTypeMap);
}

@riverpod
CustomOverwriteDate customOverwriteDate(Ref ref, int profileId) {
  final vm3 = ref.watch(
    clashConfigProvider(profileId).select((state) {
      return VM3(
        state.value?.proxies ?? [],
        state.value?.subRules ?? [],
        state.value?.proxyProviders ?? [],
      );
    }),
  );
  final proxies = vm3.a;
  final subRules = vm3.b.toSet();
  final proxyProviders = vm3.c.toSet();
  final proxyGroups =
      ref
          .watch(
            proxyGroupsProvider(profileId).select((state) {
              return VM(state.value);
            }),
          )
          .a ??
      [];
  final ruleTargets = {
    ...RuleTarget.baseTargets,
    ...proxies.map((item) => item.name),
    ...proxyGroups.map((item) => item.name),
  };
  return CustomOverwriteDate(
    proxyProviders: proxyProviders,
    proxies: proxies,
    proxyGroups: proxyGroups,
    ruleTargets: ruleTargets,
    subRules: subRules,
  );
}

@riverpod
bool customOverwriteTargetIsValid(Ref ref, int profileId, String? target) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.ruleTargets.contains(target)),
  );
  return valid;
}

@riverpod
bool customOverwriteProxyProviderIsValid(
  Ref ref,
  int profileId,
  String? providerName,
) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.proxyProviders.contains(providerName)),
  );
  return valid;
}

@riverpod
bool customOverwriteUseIsValid(Ref ref, int profileId, List<String> use) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.proxyProviders.containsAll(use)),
  );
  return valid;
}

@riverpod
bool customOverwriteProxiesIsValid(
  Ref ref,
  int profileId,
  List<String> proxies,
) {
  final valid = ref.watch(
    customOverwriteDateProvider(
      profileId,
    ).select((state) => state.ruleTargets.containsAll(proxies)),
  );
  return valid;
}

@riverpod
bool customOverwriteGroupIsValid(
  Ref ref,
  int profileId,
  ProxyGroup proxyGroup,
) {
  final proxies = proxyGroup.proxies ?? [];
  final use = proxyGroup.use ?? [];
  final valid = ref.watch(
    customOverwriteDateProvider(profileId).select(
      (state) =>
          state.ruleTargets.containsAll(proxies) &&
          state.proxyProviders.containsAll(use),
    ),
  );
  return valid;
}

@riverpod
Future<SetupState> setupState(Ref ref, int? profileId) async {
  final profile = ref.watch(profileProvider(profileId));
  final scriptId = profile?.scriptId;
  final profileLastUpdateDate = profile?.lastUpdateDate?.millisecondsSinceEpoch;
  final overwriteType = profile?.overwriteType ?? OverwriteType.standard;
  final dns = ref.watch(patchClashConfigProvider.select((state) => state.dns));
  final overrideDns = ref.watch(overrideDnsProvider);
  List<ProxyGroup> proxyGroups = [];
  List<Rule> rules = [];
  List<Rule> addedRules = [];
  Script? script;
  if (profileId != null) {
    if (overwriteType == OverwriteType.standard) {
      addedRules = await database.rulesDao.queryAddedRules(profileId).get();
    } else if (overwriteType == OverwriteType.script) {
      script = scriptId == null
          ? null
          : await database.scriptsDao.get(scriptId).getSingleOrNull();
    } else {
      rules = await database.rulesDao.queryProfileCustomRules(profileId).get();
      proxyGroups = await database.proxyGroupsDao.query(profileId).get();
    }
  }
  return SetupState(
    rules: rules,
    proxyGroups: proxyGroups,
    profileId: profileId,
    profileLastUpdateDate: profileLastUpdateDate,
    overwriteType: overwriteType,
    addedRules: addedRules,
    script: script,
    overrideDns: overrideDns,
    dns: dns,
  );
}

@riverpod
class AccessControlState extends _$AccessControlState
    with AutoDisposeNotifierMixin {
  @override
  AccessControlProps build() => const AccessControlProps();
}

@Riverpod(name: 'proxyGroupProvider')
class ProxyGroupProvider extends _$ProxyGroupProvider
    with AutoDisposeNotifierMixin {
  @override
  ProxyGroup build() {
    throw 'Initialization proxyGroupProvider error';
  }
}

@Riverpod(name: 'ruleProvider')
class RuleProvider extends _$RuleProvider with AutoDisposeNotifierMixin {
  @override
  Rule build() {
    return throw 'Initialization RuleProvider error';
  }
}

@riverpod
bool suspend(Ref ref) {
  final currentSSID = ref.watch(currentSSIDProvider);
  final excludeSSIDs = ref.watch(excludeSSIDsProvider);
  return excludeSSIDs.contains(currentSSID);
}
