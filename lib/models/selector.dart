import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'config.dart';
import 'navigation.dart';
import 'package.dart';
import 'profile.dart';
import 'proxy.dart';

part 'generated/selector.freezed.dart';

@freezed
class StartButtonSelectorState with _$StartButtonSelectorState {
  const factory StartButtonSelectorState({
    required bool isInit,
    required bool hasProfile,
  }) = _StartButtonSelectorState;
}

@freezed
class UpdateCurrentDelaySelectorState with _$UpdateCurrentDelaySelectorState {
  const factory UpdateCurrentDelaySelectorState({
    required String? currentProxyName,
    required bool isCurrent,
    required int? delay,
    required bool isInit,
  }) = _UpdateCurrentDelaySelectorState;
}

@freezed
class NetworkDetectionSelectorState with _$NetworkDetectionSelectorState {
  const factory NetworkDetectionSelectorState({
    required String? currentProxyName,
    required int? delay,
    required bool isInit,
  }) = _NetworkDetectionSelectorState;
}

@freezed
class ProfilesSelectorState with _$ProfilesSelectorState {
  const factory ProfilesSelectorState({
    required List<Profile> profiles,
    required String? currentProfileId,
  }) = _ProfilesSelectorState;
}

@freezed
class PackageListSelectorState with _$PackageListSelectorState {
  const factory PackageListSelectorState({
    required AccessControl accessControl,
    required List<Package> packages,
  }) = _PackageListSelectorState;
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
class HomeLayoutSelectorState with _$HomeLayoutSelectorState{
  const factory HomeLayoutSelectorState({
    required List<NavigationItem> navigationItems,
    required int currentIndex,
  })=_HomeLayoutSelectorState;
}

@freezed
class TrayContainerSelectorState with _$TrayContainerSelectorState{
  const factory TrayContainerSelectorState({
    required Mode mode,
    required bool autoLaunch,
    required bool isRun,
    required String? locale,
  })=_TrayContainerSelectorState;
}

@freezed
class UpdateNavigationsSelector with _$UpdateNavigationsSelector{
  const factory UpdateNavigationsSelector({
    required bool openLogs,
    required bool hasProxies,
  }) = _UpdateNavigationsSelector;
}

@freezed
class HomeCommonScaffoldSelectorState with _$HomeCommonScaffoldSelectorState {
  const factory HomeCommonScaffoldSelectorState({
    required String currentLabel,
    required String? locale,
  }) = _HomeCommonScaffoldSelectorState;
}

@freezed
class HomeNavigationSelectorState with _$HomeNavigationSelectorState{
  const factory HomeNavigationSelectorState({
    required int currentIndex,
    required String? locale,
  }) = _HomeNavigationSelectorState;
}

@freezed
class ProxiesSelectorState with _$ProxiesSelectorState{
  const factory ProxiesSelectorState({
    required int currentIndex,
    required List<Group> groups,
  }) = _ProxiesSelectorState;
}

@freezed
class ProxiesCardSelectorState with _$ProxiesCardSelectorState{
  const factory ProxiesCardSelectorState({
    required String? currentGroupName,
    required String? currentProxyName,
  }) = _ProxiesCardSelectorState;
}
