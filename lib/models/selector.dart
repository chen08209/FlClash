import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/selector.freezed.dart';

@freezed
class StartButtonSelectorState with _$StartButtonSelectorState {
  const factory StartButtonSelectorState({
    required bool isInit,
    required bool hasProfile,
  }) = _StartButtonSelectorState;
}

@freezed
class CheckIpSelectorState with _$CheckIpSelectorState {
  const factory CheckIpSelectorState({
    required String? currentProfileId,
    required SelectedMap selectedMap,
  }) = _CheckIpSelectorState;
}

@freezed
class NetworkDetectionSelectorState with _$NetworkDetectionSelectorState {
  const factory NetworkDetectionSelectorState({
    required String? currentProxyName,
    required int? delay,
  }) = _NetworkDetectionSelectorState;
}

@freezed
class ProfilesSelectorState with _$ProfilesSelectorState {
  const factory ProfilesSelectorState({
    required List<Profile> profiles,
    required String? currentProfileId,
    required int columns,
  }) = _ProfilesSelectorState;
}

@freezed
class NetworkDetectionState with _$NetworkDetectionState {
  const factory NetworkDetectionState({
    required bool isTesting,
    required IpInfo? ipInfo,
  }) = _NetworkDetectionState;
}

@freezed
class ApplicationSelectorState with _$ApplicationSelectorState {
  const factory ApplicationSelectorState({
    required String? locale,
    required ThemeMode? themeMode,
    required int? primaryColor,
    required bool prueBlack,
    required FontFamily fontFamily,
  }) = _ApplicationSelectorState;
}

@freezed
class TrayState with _$TrayState {
  const factory TrayState({
    required Mode mode,
    required bool autoLaunch,
    required bool adminAutoLaunch,
    required bool systemProxy,
    required bool tunEnable,
    required bool isStart,
    required String? locale,
    required Brightness? brightness,
  }) = _TrayState;
}

@freezed
class UpdateNavigationsSelector with _$UpdateNavigationsSelector {
  const factory UpdateNavigationsSelector({
    required bool openLogs,
    required bool hasProxies,
  }) = _UpdateNavigationsSelector;
}

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required String currentLabel,
    required List<NavigationItem> navigationItems,
    required ViewMode viewMode,
    required String? locale,
  }) = _HomeState;
}

@freezed
class ProxiesCardSelectorState with _$ProxiesCardSelectorState {
  const factory ProxiesCardSelectorState({
    required bool isSelected,
  }) = _ProxiesCardSelectorState;
}

@freezed
class ProxiesSelectorState with _$ProxiesSelectorState {
  const factory ProxiesSelectorState({
    required List<String> groupNames,
    required String? currentGroupName,
  }) = _ProxiesSelectorState;
}

@freezed
class ProxiesListSelectorState with _$ProxiesListSelectorState {
  const factory ProxiesListSelectorState({
    required List<String> groupNames,
    required Set<String> currentUnfoldSet,
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required int columns,
  }) = _ProxiesListSelectorState;
}

@freezed
class ProxyGroupSelectorState with _$ProxyGroupSelectorState {
  const factory ProxyGroupSelectorState({
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required GroupType groupType,
    required List<Proxy> proxies,
    required int columns,
  }) = _ProxyGroupSelectorState;
}

@freezed
class MoreToolsSelectorState with _$MoreToolsSelectorState {
  const factory MoreToolsSelectorState({
    required List<NavigationItem> navigationItems,
  }) = _MoreToolsSelectorState;
}

@freezed
class PackageListSelectorState with _$PackageListSelectorState {
  const factory PackageListSelectorState({
    required List<Package> packages,
    required AccessControl accessControl,
    required bool isAccessControl,
  }) = _PackageListSelectorState;
}

extension PackageListSelectorStateExt on PackageListSelectorState {
  List<Package> getList(List<String> selectedList) {
    final isFilterSystemApp = accessControl.isFilterSystemApp;
    final sort = accessControl.sort;
    return packages
        .where((item) => isFilterSystemApp ? item.isSystem == false : true)
        .sorted(
      (a, b) {
        return switch (sort) {
          AccessSortType.none => 0,
          AccessSortType.name => other.sortByChar(
              other.getPinyin(a.label),
              other.getPinyin(b.label),
            ),
          AccessSortType.time =>
            a.firstInstallTime.compareTo(b.firstInstallTime),
        };
      },
    ).sorted(
      (a, b) {
        final isSelectA = selectedList.contains(a.packageName);
        final isSelectB = selectedList.contains(b.packageName);
        if (isSelectA && isSelectB) return 0;
        if (isSelectA) return -1;
        if (isSelectB) return 1;
        return 0;
      },
    );
  }
}

@freezed
class ProxiesListHeaderSelectorState with _$ProxiesListHeaderSelectorState {
  const factory ProxiesListHeaderSelectorState({
    required double offset,
    required int currentIndex,
  }) = _ProxiesListHeaderSelectorState;
}

@freezed
class ProxiesActionsState with _$ProxiesActionsState {
  const factory ProxiesActionsState({
    required bool isCurrent,
    required bool hasProvider,
  }) = _ProxiesActionsState;
}

@freezed
class AutoLaunchState with _$AutoLaunchState {
  const factory AutoLaunchState({
    required bool isAutoLaunch,
    required bool isAdminAutoLaunch,
  }) = _AutoLaunchState;
}

@freezed
class ProxyState with _$ProxyState {
  const factory ProxyState({
    required bool isStart,
    required bool systemProxy,
    required List<String> bassDomain,
    required int port,
  }) = _ProxyState;
}

@freezed
class HttpOverridesState with _$HttpOverridesState {
  const factory HttpOverridesState({
    required bool isStart,
    required int port,
  }) = _HttpOverridesState;
}

@freezed
class ClashConfigState with _$ClashConfigState {
  const factory ClashConfigState({
    required int mixedPort,
    required bool allowLan,
    required bool ipv6,
    required bool overrideDns,
    required String geodataLoader,
    required LogLevel logLevel,
    required String externalController,
    required Mode mode,
    required FindProcessMode findProcessMode,
    required int keepAliveInterval,
    required bool unifiedDelay,
    required bool tcpConcurrent,
    required HostsMap hosts,
    required Tun tun,
    required Dns dns,
    required GeoXMap geoXUrl,
    required List<String> rules,
    required String? globalRealUa,
  }) = _ClashConfigState;
}

@freezed
class VPNState with _$VPNState {
  const factory VPNState({
    required AccessControl? accessControl,
    required TunStack stack,
    required VpnProps vpnProps,
  }) = _VPNState;
}
