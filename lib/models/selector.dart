import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/selector.freezed.dart';

@freezed
class VM2<A, B> with _$VM2<A, B> {
  const factory VM2({
    required A a,
    required B b,
  }) = _VM2;
}

@freezed
class VM3<A, B, C> with _$VM3<A, B, C> {
  const factory VM3({
    required A a,
    required B b,
    required C c,
  }) = _VM3;
}

@freezed
class VM4<A, B, C, D> with _$VM4<A, B, C, D> {
  const factory VM4({
    required A a,
    required B b,
    required C c,
    required D d,
  }) = _VM4;
}

@freezed
class VM5<A, B, C, D, E> with _$VM5<A, B, C, D, E> {
  const factory VM5({
    required A a,
    required B b,
    required C c,
    required D d,
    required E e,
  }) = _VM5;
}

@freezed
class StartButtonSelectorState with _$StartButtonSelectorState {
  const factory StartButtonSelectorState({
    required bool isInit,
    required bool hasProfile,
  }) = _StartButtonSelectorState;
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
    required bool isLoading,
    required IpInfo? ipInfo,
  }) = _NetworkDetectionState;
}

@freezed
class TrayState with _$TrayState {
  const factory TrayState({
    required Mode mode,
    required int port,
    required bool autoLaunch,
    required bool systemProxy,
    required bool tunEnable,
    required bool isStart,
    required String? locale,
    required Brightness? brightness,
    required List<Group> groups,
    required SelectedMap selectedMap,
  }) = _TrayState;
}

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required PageLabel pageLabel,
    required List<NavigationItem> navigationItems,
    required ViewMode viewMode,
    required String? locale,
    required int currentIndex,
  }) = _NavigationState;
}

@freezed
class GroupsState with _$GroupsState {
  const factory GroupsState({
    required List<Group> value,
  }) = _GroupsState;
}

@freezed
class NavigationItemsState with _$NavigationItemsState {
  const factory NavigationItemsState({
    required List<NavigationItem> value,
  }) = _NavigationItemsState;
}

@freezed
class ProxiesListState with _$ProxiesListState {
  const factory ProxiesListState({
    required List<Group> groups,
    required Set<String> currentUnfoldSet,
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required int columns,
  }) = _ProxiesListState;
}

@freezed
class ProxiesTabState with _$ProxiesTabState {
  const factory ProxiesTabState({
    required List<Group> groups,
    required String? currentGroupName,
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required int columns,
  }) = _ProxiesTabState;
}

@freezed
class ProxyGroupSelectorState with _$ProxyGroupSelectorState {
  const factory ProxyGroupSelectorState({
    required String? testUrl,
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
  }) = _PackageListSelectorState;
}

extension PackageListSelectorStateExt on PackageListSelectorState {
  List<Package> get list {
    final isFilterSystemApp = accessControl.isFilterSystemApp;
    final isFilterNonInternetApp = accessControl.isFilterNonInternetApp;
    return packages
        .where(
          (item) =>
              (isFilterSystemApp ? item.system == false : true) &&
              (isFilterNonInternetApp ? item.internet == true : true),
        )
        .toList();
  }

  List<Package> getSortList(List<String> selectedList) {
    final sort = accessControl.sort;
    return list.sorted(
      (a, b) {
        return switch (sort) {
          AccessSortType.none => 0,
          AccessSortType.name => utils.sortByChar(
              utils.getPinyin(a.label),
              utils.getPinyin(b.label),
            ),
          AccessSortType.time => b.lastUpdateTime.compareTo(a.lastUpdateTime),
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
    required PageLabel pageLabel,
    required ProxiesType type,
    required bool hasProviders,
  }) = _ProxiesActionsState;
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
class ClashConfigState with _$ClashConfigState {
  const factory ClashConfigState({
    required bool overrideDns,
    required ClashConfig clashConfig,
    required OverrideData overrideData,
    required RouteMode routeMode,
  }) = _ClashConfigState;
}

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    required List<DashboardWidget> dashboardWidgets,
    required double viewWidth,
  }) = _DashboardState;
}

@freezed
class ProxyCardState with _$ProxyCardState {
  const factory ProxyCardState({
    required String proxyName,
    String? testUrl,
  }) = _ProxyCardState;
}

@freezed
class VpnState with _$VpnState {
  const factory VpnState({
    required TunStack stack,
    required VpnProps vpnProps,
  }) = _VpnState;
}

@freezed
class ProfileOverrideStateModel with _$ProfileOverrideStateModel {
  const factory ProfileOverrideStateModel({
    ClashConfigSnippet? snippet,
    required Set<String> selectedRules,
    OverrideData? overrideData,
  }) = _ProfileOverrideStateModel;
}
