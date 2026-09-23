import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'generated/config.freezed.dart';
part 'generated/config.g.dart';

const defaultBypassDomain = [
  '*zhihu.com',
  '*zhimg.com',
  '*jd.com',
  '100ime-iat-api.xfyun.cn',
  '*360buyimg.com',
  'localhost',
  '*.local',
  '127.*',
  '10.*',
  '172.16.*',
  '172.17.*',
  '172.18.*',
  '172.19.*',
  '172.2*',
  '172.30.*',
  '172.31.*',
  '192.168.*',
];

const defaultUserAgents = ['clash-verge/v2.4.2', 'ClashforWindows/0.19.23'];

const defaultAppSettingProps = AppSettingProps();
const defaultVpnProps = VpnProps();
const defaultAuthenticationProps = AuthenticationProps();
const defaultNetworkProps = NetworkProps();
const defaultProxiesStyleProps = ProxiesStyleProps();
const defaultWindowProps = WindowProps();
const defaultAccessControlProps = AccessControlProps();
const defaultThemeProps = ThemeProps(primaryColor: defaultPrimaryColor);

HotKeyAction _defaultHotKeyAction(HotAction action, PhysicalKeyboardKey key) {
  return HotKeyAction(
    action: action,
    key: key.usbHidUsage,
    modifiers: const {KeyboardModifier.control, KeyboardModifier.alt},
  );
}

// Windows reports AltGr as Ctrl+Alt, and every letter is an AltGr character
// on some layout (@ on German Q, ś on Polish S), so a default there would fire
// while the user types.
final List<HotKeyAction> defaultHotKeyActions = system.isWindows
    ? const []
    : [
        _defaultHotKeyAction(HotAction.view, PhysicalKeyboardKey.keyV),
        _defaultHotKeyAction(HotAction.start, PhysicalKeyboardKey.keyS),
        _defaultHotKeyAction(HotAction.mode, PhysicalKeyboardKey.keyM),
        _defaultHotKeyAction(HotAction.proxy, PhysicalKeyboardKey.keyP),
        _defaultHotKeyAction(HotAction.delayTest, PhysicalKeyboardKey.keyD),
      ];

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.networkSpeed,
  DashboardWidget.systemProxyButton,
  DashboardWidget.tunButton,
  DashboardWidget.outboundMode,
  DashboardWidget.networkDetection,
  DashboardWidget.trafficUsage,
  DashboardWidget.intranetIp,
];

const _legacyOutboundModeV2 = 'outboundModeV2';

List<DashboardWidget> dashboardWidgetsSafeFormJson(
  List<dynamic>? dashboardWidgets,
) {
  return decodeOrRestoreDefault(
    'dashboard widgets',
    () =>
        dashboardWidgets
            ?.map(
              (e) => e == _legacyOutboundModeV2
                  ? DashboardWidget.outboundMode
                  : $enumDecode(_$DashboardWidgetEnumMap, e),
            )
            .toSet()
            .toList() ??
        defaultDashboardWidgets,
    () => defaultDashboardWidgets,
  );
}

Object? _readSidebarExpanded(Map<dynamic, dynamic> json, String key) {
  return json.containsKey(key) ? json[key] : json['showLabel'];
}

Object? _readUserAgents(Map<dynamic, dynamic> json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  }
  final legacy = json['customUserAgent'];
  if (legacy is! String) {
    return null;
  }
  final custom = legacy.trim();
  if (custom.isEmpty || defaultUserAgents.contains(custom)) {
    return null;
  }
  return [...defaultUserAgents, custom];
}

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool onlyStatisticsProxy,
    @Default(true) bool showNotificationStopAction,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool autoRun,
    @Default(false) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(defaultTestUrl) String testUrl,
    @Default(true) bool isAnimateToPage,
    @Default(true) bool autoCheckUpdate,
    @Default(true)
    @JsonKey(readValue: _readSidebarExpanded)
    bool sidebarExpanded,
    @Default(false) bool disclaimerAccepted,
    @Default(false) bool crashlyticsTip,
    @Default(false) bool crashlytics,
    @Default(true) bool minimizeOnExit,
    @Default(false) bool hidden,
    @Default(false) bool developerMode,
    @Default(RestoreStrategy.compatible) RestoreStrategy restoreStrategy,
    @Default(true) bool showTrayTitle,
    @Default(true) bool checkCertificate,
    @Default(defaultUserAgents)
    @JsonKey(readValue: _readUserAgents)
    List<String> userAgents,
    @Default(false) bool hideIp,
    @Default([]) List<String> serviceOrder,
    @Default([]) List<String> disabledServices,
    String? currentService,
  }) = _AppSettingProps;

  factory AppSettingProps.fromJson(Map<String, Object?> json) =>
      _$AppSettingPropsFromJson(json);

  factory AppSettingProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultAppSettingProps;
    }
    return decodeOrRestoreDefault(
      'app settings',
      () => AppSettingProps.fromJson(json),
      () => defaultAppSettingProps,
    );
  }
}

@freezed
abstract class AccessControlProps with _$AccessControlProps {
  const factory AccessControlProps({
    @Default(false) bool enable,
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode,
    @Default([]) List<String> acceptList,
    @Default([]) List<String> rejectList,
    @Default(AccessSortType.none) AccessSortType sort,
    @Default(true) bool isFilterSystemApp,
    @Default(true) bool isFilterNonInternetApp,
  }) = _AccessControlProps;

  factory AccessControlProps.fromJson(Map<String, Object?> json) =>
      _$AccessControlPropsFromJson(json);
}

extension AccessControlPropsExt on AccessControlProps {
  List<String> get currentList => switch (mode) {
    AccessControlMode.acceptSelected => acceptList,
    AccessControlMode.rejectSelected => rejectList,
  };

  AccessControlProps copyWithNewList(List<String> value) => switch (mode) {
    AccessControlMode.acceptSelected => copyWith(acceptList: value),
    AccessControlMode.rejectSelected => copyWith(rejectList: value),
  };
}

@freezed
abstract class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(0) double width,
    @Default(0) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

extension WindowPropsExt on WindowProps {
  Size get _size => Size(width, height);

  Size get size => _size.isEmpty ? const Size(680, 580) : _size;
}

@freezed
abstract class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(true) bool systemProxy,
    @Default(false) bool ipv6,
    @Default(true) bool allowBypass,
    @Default(false) bool dnsHijacking,
    @Default(defaultAccessControlProps) AccessControlProps accessControlProps,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultVpnProps : _$VpnPropsFromJson(json);
}

@freezed
abstract class AuthenticationProps with _$AuthenticationProps {
  const factory AuthenticationProps({
    @Default(false) bool enable,
    @Default('') String username,
    @Default('') String password,
  }) = _AuthenticationProps;

  factory AuthenticationProps.fromJson(Map<String, Object?>? json) =>
      json == null
      ? defaultAuthenticationProps
      : _$AuthenticationPropsFromJson(json);
}

extension AuthenticationPropsExt on AuthenticationProps {
  List<String> get credentials =>
      enable && username.isNotEmpty ? ['$username:$password'] : [];
}

@freezed
abstract class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(true) bool systemProxy,
    @Default(defaultBypassDomain) List<String> bypassDomain,
    @Default(RouteMode.config) RouteMode routeMode,
    @Default(true) bool autoSetSystemDns,
    @Default(false) bool appendSystemDns,
    @Default(defaultAuthenticationProps) AuthenticationProps authentication,
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

/// Reads the styles named `standard`, `icon` and `none` before they became
/// [ProxiesIconStyle.filled], [ProxiesIconStyle.plain] and
/// [ProxiesIconStyle.hidden].
ProxiesIconStyle proxiesIconStyleSafeFromJson(Object? iconStyle) {
  return switch (iconStyle) {
    'filled' || 'standard' => ProxiesIconStyle.filled,
    'plain' || 'icon' => ProxiesIconStyle.plain,
    'hidden' || 'none' => ProxiesIconStyle.hidden,
    _ => ProxiesIconStyle.filled,
  };
}

@freezed
abstract class ProxiesStyleProps with _$ProxiesStyleProps {
  const factory ProxiesStyleProps({
    @Default(ProxiesType.tab) ProxiesType type,
    @Default(ProxiesSortType.none) ProxiesSortType sortType,
    @Default(ProxiesLayout.standard) ProxiesLayout layout,
    @Default(ProxiesIconStyle.filled)
    @JsonKey(fromJson: proxiesIconStyleSafeFromJson)
    ProxiesIconStyle iconStyle,
    @Default(ProxyCardType.expand) ProxyCardType cardType,
    @Default(false) bool hideTimeoutProxies,
  }) = _ProxiesStyleProps;

  factory ProxiesStyleProps.fromJson(Map<String, Object?>? json) => json == null
      ? defaultProxiesStyleProps
      : _$ProxiesStylePropsFromJson(json);
}

@freezed
abstract class TextScale with _$TextScale {
  const factory TextScale({
    @Default(false) bool enable,
    @Default(1.0) double scale,
  }) = _TextScale;

  factory TextScale.fromJson(Map<String, Object?> json) =>
      _$TextScaleFromJson(json);
}

@freezed
abstract class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor,
    @Default(defaultPrimaryColors) List<int> primaryColors,
    @Default(ThemeMode.dark) ThemeMode themeMode,
    @Default(DynamicSchemeVariant.content) DynamicSchemeVariant schemeVariant,
    @Default(false) bool pureBlack,
    @Default(true) bool sidebarBlur,
    @Default(TextScale()) TextScale textScale,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    return decodeOrRestoreDefault(
      'theme settings',
      () => ThemeProps.fromJson(json),
      () => defaultThemeProps,
    );
  }
}

@freezed
abstract class Config with _$Config {
  const factory Config({
    int? currentProfileId,
    @Default(false) bool overrideDns,
    @Default(false) bool overrideNtp,
    @Default([]) List<HotKeyAction> hotKeyActions,
    @JsonKey(fromJson: AppSettingProps.safeFromJson)
    @Default(defaultAppSettingProps)
    AppSettingProps appSettingProps,
    DAVProps? davProps,
    @Default(defaultNetworkProps) NetworkProps networkProps,
    @Default(defaultVpnProps) VpnProps vpnProps,
    @JsonKey(fromJson: ThemeProps.safeFromJson) required ThemeProps themeProps,
    @Default(defaultProxiesStyleProps) ProxiesStyleProps proxiesStyleProps,
    @Default(defaultWindowProps) WindowProps windowProps,
    @Default(defaultClashConfig) PatchClashConfig patchClashConfig,
    @Default([]) List<String> excludeSSIDs,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);

  factory Config.realFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return Config(
        themeProps: defaultThemeProps,
        hotKeyActions: defaultHotKeyActions,
      );
    }
    return _$ConfigFromJson(json);
  }
}
