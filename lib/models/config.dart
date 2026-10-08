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

const defaultFilters = [
  Filter(
    label: 'Hong Kong',
    regex: r'(?i)🇭🇰|港|(?<![a-z])hk(?![a-z])|hong\s*kong',
  ),
  Filter(
    label: 'Taiwan',
    regex: r'(?i)🇹🇼|台湾|台灣|台北|新北|彰化|(?<![a-z])tw(?![a-z])|taiwan',
  ),
  Filter(
    label: 'Japan',
    regex: r'(?i)🇯🇵|日本|东京|東京|大阪|埼玉|(?<![a-z])jp(?![a-z])|japan|tokyo|osaka',
  ),
  Filter(
    label: 'Singapore',
    regex: r'(?i)🇸🇬|新加坡|狮城|獅城|(?<![a-z])sg(?![a-z])|singapore',
  ),
  Filter(
    label: 'United States',
    regex:
        r'(?i)🇺🇸|美国|美國|美西|美东|美東|洛杉矶|圣何塞|西雅图|硅谷|纽约'
        r'|(?<![a-z])usa?(?![a-z])|united\s*states',
  ),
  Filter(
    label: 'South Korea',
    regex: r'(?i)🇰🇷|韩国|韓國|首尔|首爾|(?<![a-z])kr(?![a-z])|korea|seoul',
  ),
  Filter(
    label: 'United Kingdom',
    regex:
        r'(?i)🇬🇧|英国|英國|伦敦|倫敦|(?<![a-z])(uk|gb)(?![a-z])'
        r'|united\s*kingdom|britain|london',
  ),
  Filter(
    label: 'Remaining Traffic',
    regex: r'(?i)剩余|剩餘|已用|流量\s*[:：]|traffic|remaining',
  ),
  Filter(label: 'Expiry Date', regex: r'(?i)到期|过期|過期|有效期|expir'),
  Filter(label: 'Traffic Reset', regex: r'(?i)重置|reset'),
  Filter(
    label: 'Website & Notices',
    regex:
        r'(?i)官网|官網|网址|網址|域名|公告|套餐|客服|群组|群組|频道|頻道'
        r'|website|telegram|(?<![a-z])tg(?![a-z])',
  ),
];

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

const _retiredDashboardWidgets = {'overrideDnsButton', 'overrideNtpButton'};

List<DashboardWidget> dashboardWidgetsFromJson(
  List<dynamic>? dashboardWidgets,
) {
  return dashboardWidgets
          ?.where((e) => !_retiredDashboardWidgets.contains(e))
          .map(
            (e) => e == _legacyOutboundModeV2
                ? DashboardWidget.outboundMode
                : $enumDecode(_$DashboardWidgetEnumMap, e),
          )
          .toSet()
          .toList() ??
      defaultDashboardWidgets;
}

Object? _readSidebarExpanded(Map<dynamic, dynamic> json, String key) {
  return json.containsKey(key) ? json[key] : json['showLabel'];
}

Object? _readTabAnimation(Map<dynamic, dynamic> json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  }
  return json['isAnimateToPage'] == false ? TabAnimation.fade.name : null;
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
abstract class Filter with _$Filter {
  const factory Filter({required String label, required String regex}) =
      _Filter;

  factory Filter.fromJson(Map<String, Object?> json) => _$FilterFromJson(json);
}

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: dashboardWidgetsFromJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool onlyStatisticsProxy,
    @Default(true) bool showNotificationStopAction,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool autoRun,
    @Default(false) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(defaultTestUrl) String testUrl,
    @Default(TabAnimation.slide)
    @JsonKey(readValue: _readTabAnimation)
    TabAnimation tabAnimation,
    @Default(true) bool floatingNavigationBar,
    @Default(true) bool autoCheckUpdate,
    @Default(true)
    @JsonKey(readValue: _readSidebarExpanded)
    bool sidebarExpanded,
    @Default(0) int acceptedDisclaimerVersion,
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
    @Default(defaultFilters) List<Filter> filters,
    @Default(false) bool hideIp,
    @Default(false) bool editorLineWrap,
    @Default(EditorFontSize.standard) EditorFontSize editorFontSize,
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
    return decodeSalvaging('app settings', json, AppSettingProps.fromJson);
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
  bool get hasPackages => acceptList.isNotEmpty || rejectList.isNotEmpty;

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
    double? scale,
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
    @Default(false) bool bypassPrivateRoute,
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
    @Default(ProxyCardType.shrink) ProxyCardType cardType,
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
    // `fontFamily` held the names of a removed enum, which old configs may
    // still carry.
    @JsonKey(name: 'systemFontFamily') String? fontFamily,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    return decodeSalvaging('theme settings', json, ThemeProps.fromJson);
  }
}

@freezed
abstract class Config with _$Config {
  const factory Config({
    int? currentProfileId,
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

  factory Config.fromJson(Map<String, Object?> json) =>
      decodeSalvaging('config', json, Config.strictFromJson);

  factory Config.strictFromJson(Map<String, Object?> json) =>
      _withLegacyOverrideDns(
        _$ConfigFromJson(_withLegacyRouteMode(json)),
        json,
      );

  factory Config.realFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return Config(
        themeProps: defaultThemeProps,
        hotKeyActions: defaultHotKeyActions,
      );
    }
    return Config.fromJson(json);
  }
}

const _legacyOverrideDnsKey = 'overrideDns';

/// An off `overrideDns` left a profile's own DNS section alone.
Config _withLegacyOverrideDns(Config config, Map<String, Object?> json) {
  if (!json.containsKey(_legacyOverrideDnsKey)) {
    return config;
  }
  final keys = json[_legacyOverrideDnsKey] == true
      ? config.patchClashConfig.dnsOverrideKeys.intersection(
          DnsOverrideKey.normalProfileKeys,
        )
      : <DnsOverrideKey>{};
  return config.copyWith.patchClashConfig(dnsOverrideKeys: keys);
}

Map<String, Object?> _withLegacyRouteMode(Map<String, Object?> json) {
  final network = json['networkProps'];
  if (network is! Map ||
      network['routeMode'] != 'bypassPrivate' ||
      network.containsKey('bypassPrivateRoute')) {
    return json;
  }
  final clash = json['patchClashConfig'];
  final tun = clash is Map ? clash['tun'] : null;
  return {
    ...json,
    'networkProps': {
      ...Map<String, Object?>.from(network),
      'bypassPrivateRoute': true,
    },
    if (clash is Map && tun is Map)
      'patchClashConfig': {
        ...Map<String, Object?>.from(clash),
        'tun': {...Map<String, Object?>.from(tun), 'route-address': <String>[]},
      },
  };
}
