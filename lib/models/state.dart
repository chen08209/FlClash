import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'app.dart';
import 'clash_config.dart';
import 'common.dart';
import 'core.dart';
import 'profile.dart';

part 'generated/state.freezed.dart';
part 'generated/state.g.dart';

@freezed
abstract class SelectValue<T> with _$SelectValue<T> {
  const factory SelectValue(T value) = _SelectValue;
}

@freezed
abstract class CommonMessage with _$CommonMessage {
  const factory CommonMessage({
    required String id,
    required String text,
    @Default(MessageLevel.info) MessageLevel level,
    @Default(Duration(seconds: 3)) Duration duration,
    MessageActionState? actionState,
  }) = _CommonMessage;
}

@freezed
abstract class MessageActionState with _$MessageActionState {
  const factory MessageActionState({
    required String actionText,
    required VoidCallback action,
  }) = _MessageActionState;
}

@freezed
abstract class ProfilesState with _$ProfilesState {
  const factory ProfilesState({
    required List<Profile> profiles,
    required int? currentProfileId,
  }) = _ProfilesState;
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
    @Default(false) bool suspended,
    required List<Group> groups,
    required Map<String, String> selectedMap,
    required bool showTrayTitle,
    @Default(true) bool monochromeTrayIcon,
    required bool safeMode,
    @Default({}) Map<HotAction, HotKeyAction> hotKeys,
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
  }) = _ProxiesListState;
}

@freezed
abstract class ProxiesTabState with _$ProxiesTabState {
  const factory ProxiesTabState({
    required List<Group> groups,
    required String? currentGroupName,
    required ProxyCardType proxyCardType,
  }) = _ProxiesTabState;
}

@freezed
abstract class ProxiesTabControllerState with _$ProxiesTabControllerState {
  const factory ProxiesTabControllerState({
    required List<String> groupNames,
    required String? currentGroupName,
  }) = _ProxiesTabControllerState;
}

@freezed
abstract class MoreToolsSelectorState with _$MoreToolsSelectorState {
  const factory MoreToolsSelectorState({
    required List<NavigationItem> navigationItems,
  }) = _MoreToolsSelectorState;
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
abstract class ThemeColorsSelectorState with _$ThemeColorsSelectorState {
  const factory ThemeColorsSelectorState({
    required int? primaryColor,
    required List<int> primaryColors,
    required ColorStyle colorStyle,
    required bool isDefault,
  }) = _ThemeColorsSelectorState;
}

@freezed
abstract class SystemProxySelectorState with _$SystemProxySelectorState {
  const factory SystemProxySelectorState({
    required bool systemProxy,
    required List<String> bypassDomain,
  }) = _SystemProxySelectorState;
}

@freezed
abstract class CurrentProfileSelectorState with _$CurrentProfileSelectorState {
  const factory CurrentProfileSelectorState({
    required String label,
    required Map<String, String> selectedMap,
  }) = _CurrentProfileSelectorState;
}

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required List<DashboardWidget> dashboardWidgets,
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
abstract class SharedState with _$SharedState {
  const factory SharedState({
    SetupParams? setupParams,
    VpnOptions? vpnOptions,
    required String stopTip,
    required String startTip,
    required String localNetworkTip,
    required String currentProfileName,
    required String stopText,
    required bool onlyStatisticsProxy,
    @Default(true) bool showStopAction,
  }) = _SharedState;

  factory SharedState.fromJson(Map<String, Object?> json) =>
      _$SharedStateFromJson(json);
}

extension SharedStateExt on SharedState {
  SharedState get needSyncSharedState => copyWith(setupParams: null);
}

@freezed
abstract class ComputeGroupsState with _$ComputeGroupsState {
  const factory ComputeGroupsState({
    required ProxiesData proxiesData,
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
  }) = _ComputeGroupsState;
}

@freezed
abstract class MakeRealProfileState with _$MakeRealProfileState {
  const factory MakeRealProfileState({
    required String profilesPath,
    required int profileId,
    required Map<String, dynamic> rawConfig,
    required PatchClashConfig realPatchConfig,
    @Default(ProfileOverrides()) ProfileOverrides overrides,
    @Default(false) bool bypassPrivateRoute,

    /// Set for a subscription, whose own DNS values an emptied entry replaces.
    @Default(false) bool keepEmptyDnsOverrides,
    required bool appendSystemDns,
    required List<ProxyGroup> proxyGroups,
    required List<Rule> rules,
    required List<Rule> addedRules,
    required String defaultUA,
    @Default([]) List<String> authentication,
    @Default({}) Map<String, dynamic> injectedProxyProviders,
    @Default({}) Map<String, dynamic> injectedRuleProviders,
    String? matchTarget,
    @Default(false) bool safeMode,
  }) = _MakeRealProfileState;
}

@freezed
abstract class MigrationData with _$MigrationData {
  const factory MigrationData({
    Map<String, Object?>? configMap,
    @Default([]) List<Rule> rules,
    @Default([]) List<Script> scripts,
    @Default([]) List<Profile> profiles,
    @Default([]) List<DisabledRule> disabledRules,
    @Default([]) List<ProxyGroup> proxyGroups,
    @Default([]) List<ClashProvider> clashProviders,
    @Default([]) List<CustomProxy> customProxies,
    @Default([]) List<ProxyDialer> proxyDialers,
  }) = _MigrationData;
}

@freezed
abstract class SetupState with _$SetupState {
  const factory SetupState({
    required int? profileId,
    required int? profileLastUpdateDate,
    required ProfileType profileType,
    required ExtendType extendType,
    required List<Rule> rules,
    required List<ProxyGroup> proxyGroups,
    required List<Rule> addedRules,
    required Script? script,
    required ProfileOverrides overrides,
    @Default([]) List<ClashProvider> clashProviders,
    @Default({}) Map<String, int> profileProviders,
    @Default([]) List<CustomProxy> appProxies,
    @Default({}) Map<int, String> proxyDialers,
    String? matchTarget,
  }) = _SetupState;
}
