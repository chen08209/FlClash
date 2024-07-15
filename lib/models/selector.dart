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
    required bool isInit,
    required bool isStart,
    required SelectedMap selectedMap,
    required num checkIpNum
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
    required ViewMode viewMode,
  }) = _ProfilesSelectorState;
}

@freezed
class ApplicationSelectorState with _$ApplicationSelectorState {
  const factory ApplicationSelectorState({
    String? locale,
    ThemeMode? themeMode,
    int? primaryColor,
  }) = _ApplicationSelectorState;
}

@freezed
class TrayContainerSelectorState with _$TrayContainerSelectorState {
  const factory TrayContainerSelectorState({
    required Mode mode,
    required bool autoLaunch,
    required bool isRun,
    required String? locale,
  }) = _TrayContainerSelectorState;
}

@freezed
class UpdateNavigationsSelector with _$UpdateNavigationsSelector {
  const factory UpdateNavigationsSelector({
    required bool openLogs,
    required bool hasProxies,
  }) = _UpdateNavigationsSelector;
}

@freezed
class HomeSelectorState with _$HomeSelectorState {
  const factory HomeSelectorState({
    required String currentLabel,
    required List<NavigationItem> navigationItems,
    required ViewMode viewMode,
    required String? locale,
  }) = _HomeSelectorState;
}

@freezed
class HomeBodySelectorState with _$HomeBodySelectorState {
  const factory HomeBodySelectorState({
    required List<NavigationItem> navigationItems,
  }) = _HomeBodySelectorState;
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
class ProxyGroupSelectorState with _$ProxyGroupSelectorState {
  const factory ProxyGroupSelectorState({
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
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
    required AccessControl accessControl,
    required bool isAccessControl,
  }) = _PackageListSelectorState;
}


@freezed
class ColumnsSelectorState with _$ColumnsSelectorState {
  const factory ColumnsSelectorState({
    required int columns,
    required ViewMode viewMode,
  }) = _ColumnsSelectorState;
}
