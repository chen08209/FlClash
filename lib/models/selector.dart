import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/selector.freezed.dart';

@freezed
abstract class VM2<A, B> with _$VM2<A, B> {
  const factory VM2({required A a, required B b}) = _VM2;
}

@freezed
abstract class VM3<A, B, C> with _$VM3<A, B, C> {
  const factory VM3({required A a, required B b, required C c}) = _VM3;
}

@freezed
abstract class VM4<A, B, C, D> with _$VM4<A, B, C, D> {
  const factory VM4(A a, B b, C c, D d) = _VM4;
}

@freezed
abstract class VM5<A, B, C, D, E> with _$VM5<A, B, C, D, E> {
  const factory VM5({
    required A a,
    required B b,
    required C c,
    required D d,
    required E e,
  }) = _VM5;
}

@freezed
abstract class StartButtonSelectorState with _$StartButtonSelectorState {
  const factory StartButtonSelectorState({
    required bool isInit,
    required bool hasProfile,
  }) = _StartButtonSelectorState;
}

@freezed
abstract class ProfilesSelectorState with _$ProfilesSelectorState {
  const factory ProfilesSelectorState({
    required List<Profile> profiles,
    required String? currentProfileId,
    required int columns,
  }) = _ProfilesSelectorState;
}

@freezed
abstract class NetworkDetectionState with _$NetworkDetectionState {
  const factory NetworkDetectionState({
    required bool isLoading,
    required IpInfo? ipInfo,
  }) = _NetworkDetectionState;
}

@freezed
abstract class TrayState with _$TrayState {
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
    required Map<String, String> selectedMap,
    required bool showTrayTitle,
  }) = _TrayState;
}

@freezed
abstract class TrayTitleState with _$TrayTitleState {
  const factory TrayTitleState({
    required Traffic traffic,
    required bool showTrayTitle,
  }) = _TrayTitleState;
}

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    required PageLabel pageLabel,
    required List<NavigationItem> navigationItems,
    required ViewMode viewMode,
    required String? locale,
    required int currentIndex,
  }) = _NavigationState;
}

@freezed
abstract class GroupsState with _$GroupsState {
  const factory GroupsState({required List<Group> value}) = _GroupsState;
}

@freezed
abstract class NavigationItemsState with _$NavigationItemsState {
  const factory NavigationItemsState({required List<NavigationItem> value}) =
      _NavigationItemsState;
}

@freezed
abstract class ProxiesListState with _$ProxiesListState {
  const factory ProxiesListState({
    required List<Group> groups,
    required Set<String> currentUnfoldSet,
    required ProxyCardType proxyCardType,
    required int columns,
  }) = _ProxiesListState;
}

@freezed
abstract class ProxiesTabState with _$ProxiesTabState {
  const factory ProxiesTabState({
    required List<Group> groups,
    required String? currentGroupName,
    required ProxyCardType proxyCardType,
    required int columns,
  }) = _ProxiesTabState;
}

@freezed
abstract class ProxyGroupSelectorState with _$ProxyGroupSelectorState {
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
abstract class MoreToolsSelectorState with _$MoreToolsSelectorState {
  const factory MoreToolsSelectorState({
    required List<NavigationItem> navigationItems,
  }) = _MoreToolsSelectorState;
}

@freezed
abstract class PackageListSelectorState with _$PackageListSelectorState {
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

    return list.sorted((a, b) {
      final isSelectA = selectedList.contains(a.packageName);
      final isSelectB = selectedList.contains(b.packageName);

      if (isSelectA != isSelectB) {
        return isSelectA ? -1 : 1;
      }
      return switch (sort) {
        AccessSortType.none => 0,
        AccessSortType.name => a.label.compareTo(b.label),
        AccessSortType.time => b.lastUpdateTime.compareTo(a.lastUpdateTime),
      };
    });
  }
}

@freezed
abstract class ProxiesListHeaderSelectorState
    with _$ProxiesListHeaderSelectorState {
  const factory ProxiesListHeaderSelectorState({
    required double offset,
    required int currentIndex,
  }) = _ProxiesListHeaderSelectorState;
}

@freezed
abstract class ProxiesActionsState with _$ProxiesActionsState {
  const factory ProxiesActionsState({
    required PageLabel pageLabel,
    required ProxiesType type,
    required bool hasProviders,
  }) = _ProxiesActionsState;
}

@freezed
abstract class ProxyState with _$ProxyState {
  const factory ProxyState({
    required bool isStart,
    required bool systemProxy,
    required List<String> bassDomain,
    required int port,
  }) = _ProxyState;
}

@freezed
abstract class ClashConfigState with _$ClashConfigState {
  const factory ClashConfigState({
    required bool overrideDns,
    required ClashConfig clashConfig,
    required OverrideData overrideData,
    required RouteMode routeMode,
  }) = _ClashConfigState;
}

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required List<DashboardWidget> dashboardWidgets,
    required double contentWidth,
  }) = _DashboardState;
}

@freezed
abstract class SelectedProxyState with _$SelectedProxyState {
  const factory SelectedProxyState({
    required String proxyName,
    @Default(false) bool group,
    String? testUrl,
  }) = _SelectedProxyState;
}

@freezed
abstract class VpnState with _$VpnState {
  const factory VpnState({
    required TunStack stack,
    required VpnProps vpnProps,
  }) = _VpnState;
}

@freezed
abstract class ProfileOverrideModel with _$ProfileOverrideModel {
  const factory ProfileOverrideModel({
    @Default(ClashConfigSnippet()) ClashConfigSnippet snippet,
    @Default({}) Set<String> selectedRules,
    OverrideData? overrideData,
  }) = _ProfileOverrideModel;
}

@freezed
abstract class SetupState with _$SetupState {
  const factory SetupState({
    required String? profileId,
    required int? profileLastUpdateDate,
    required OverwriteType overwriteType,
    required List<Rule> addedRules,
    required String? scriptContent,
    required bool overrideDns,
    required Dns dns,
  }) = _SetupState;
}

extension SetupStateExt on SetupState {
  bool needSetup(SetupState? lastSetupState) {
    if (lastSetupState == null) {
      return true;
    }
    if (profileId != lastSetupState.profileId) {
      return true;
    }
    if (profileLastUpdateDate != lastSetupState.profileLastUpdateDate) {
      return true;
    }
    if (overwriteType != lastSetupState.overwriteType) {
      if (!ruleListEquality.equals(addedRules, lastSetupState.addedRules) ||
          scriptContent != lastSetupState.scriptContent) {
        return true;
      }
    } else {
      if (overwriteType == OverwriteType.script) {
        if (scriptContent != lastSetupState.scriptContent) {
          return true;
        }
      }
      if (overwriteType == OverwriteType.standard) {
        if (!ruleListEquality.equals(addedRules, lastSetupState.addedRules)) {
          return true;
        }
      }
    }
    if (overrideDns != lastSetupState.overrideDns) {
      return true;
    }
    if (overrideDns == true && dns != lastSetupState.dns) {
      return true;
    }
    return false;
  }
}
