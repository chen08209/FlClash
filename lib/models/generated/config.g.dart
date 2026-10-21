// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Filter _$FilterFromJson(Map<String, dynamic> json) =>
    _Filter(label: json['label'] as String, regex: json['regex'] as String);

Map<String, dynamic> _$FilterToJson(_Filter instance) => <String, dynamic>{
  'label': instance.label,
  'regex': instance.regex,
};

_AppSettingProps _$AppSettingPropsFromJson(
  Map<String, dynamic> json,
) => _AppSettingProps(
  locale: json['locale'] as String?,
  dashboardWidgets: json['dashboardWidgets'] == null
      ? defaultDashboardWidgets
      : dashboardWidgetsFromJson(json['dashboardWidgets'] as List?),
  onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool? ?? false,
  showNotificationStopAction:
      json['showNotificationStopAction'] as bool? ?? true,
  autoLaunch: json['autoLaunch'] as bool? ?? false,
  silentLaunch: json['silentLaunch'] as bool? ?? false,
  autoRun: json['autoRun'] as bool? ?? false,
  openLogs: json['openLogs'] as bool? ?? false,
  closeConnections: json['closeConnections'] as bool? ?? true,
  testUrl: json['testUrl'] as String? ?? defaultTestUrl,
  delayTestTimeout:
      (json['delayTestTimeout'] as num?)?.toInt() ?? defaultDelayTestTimeout,
  tabAnimation:
      $enumDecodeNullable(
        _$TabAnimationEnumMap,
        _readTabAnimation(json, 'tabAnimation'),
      ) ??
      TabAnimation.fade,
  floatingNavigationBar: json['floatingNavigationBar'] as bool? ?? true,
  autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? true,
  sidebarExpanded:
      _readSidebarExpanded(json, 'sidebarExpanded') as bool? ?? true,
  acceptedDisclaimerVersion:
      (json['acceptedDisclaimerVersion'] as num?)?.toInt() ?? 0,
  minimizeOnExit: json['minimizeOnExit'] as bool? ?? true,
  hidden: json['hidden'] as bool? ?? false,
  developerMode: json['developerMode'] as bool? ?? false,
  restoreStrategy:
      $enumDecodeNullable(_$RestoreStrategyEnumMap, json['restoreStrategy']) ??
      RestoreStrategy.compatible,
  showTrayTitle: json['showTrayTitle'] as bool? ?? true,
  monochromeTrayIcon: json['monochromeTrayIcon'] as bool? ?? true,
  checkCertificate: json['checkCertificate'] as bool? ?? true,
  userAgents:
      (_readUserAgents(json, 'userAgents') as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      defaultUserAgents,
  filters:
      (json['filters'] as List<dynamic>?)
          ?.map((e) => Filter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      defaultFilters,
  hideIp: json['hideIp'] as bool? ?? false,
  editorLineWrap: json['editorLineWrap'] as bool? ?? false,
  editorFontSize:
      $enumDecodeNullable(_$EditorFontSizeEnumMap, json['editorFontSize']) ??
      EditorFontSize.standard,
  serviceOrder:
      (json['serviceOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  disabledServices:
      (json['disabledServices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  tableColumnWidths:
      (json['tableColumnWidths'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
        ),
      ) ??
      const {},
);

Map<String, dynamic> _$AppSettingPropsToJson(_AppSettingProps instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'dashboardWidgets': instance.dashboardWidgets
          .map((e) => _$DashboardWidgetEnumMap[e]!)
          .toList(),
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'showNotificationStopAction': instance.showNotificationStopAction,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'autoRun': instance.autoRun,
      'openLogs': instance.openLogs,
      'closeConnections': instance.closeConnections,
      'testUrl': instance.testUrl,
      'delayTestTimeout': instance.delayTestTimeout,
      'tabAnimation': _$TabAnimationEnumMap[instance.tabAnimation]!,
      'floatingNavigationBar': instance.floatingNavigationBar,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'sidebarExpanded': instance.sidebarExpanded,
      'acceptedDisclaimerVersion': instance.acceptedDisclaimerVersion,
      'minimizeOnExit': instance.minimizeOnExit,
      'hidden': instance.hidden,
      'developerMode': instance.developerMode,
      'restoreStrategy': _$RestoreStrategyEnumMap[instance.restoreStrategy]!,
      'showTrayTitle': instance.showTrayTitle,
      'monochromeTrayIcon': instance.monochromeTrayIcon,
      'checkCertificate': instance.checkCertificate,
      'userAgents': instance.userAgents,
      'filters': instance.filters,
      'hideIp': instance.hideIp,
      'editorLineWrap': instance.editorLineWrap,
      'editorFontSize': _$EditorFontSizeEnumMap[instance.editorFontSize]!,
      'serviceOrder': instance.serviceOrder,
      'disabledServices': instance.disabledServices,
      'tableColumnWidths': instance.tableColumnWidths,
    };

const _$TabAnimationEnumMap = {
  TabAnimation.slide: 'slide',
  TabAnimation.fade: 'fade',
};

const _$RestoreStrategyEnumMap = {
  RestoreStrategy.compatible: 'compatible',
  RestoreStrategy.override: 'override',
};

const _$EditorFontSizeEnumMap = {
  EditorFontSize.standard: 'standard',
  EditorFontSize.large: 'large',
  EditorFontSize.extraLarge: 'extraLarge',
};

const _$DashboardWidgetEnumMap = {
  DashboardWidget.currentOutbound: 'currentOutbound',
  DashboardWidget.networkSpeed: 'networkSpeed',
  DashboardWidget.outboundMode: 'outboundMode',
  DashboardWidget.vpnButton: 'vpnButton',
  DashboardWidget.networkTakeover: 'networkTakeover',
  DashboardWidget.serviceStatus: 'serviceStatus',
  DashboardWidget.profiles: 'profiles',
  DashboardWidget.proxyGroups: 'proxyGroups',
  DashboardWidget.connectionStats: 'connectionStats',
  DashboardWidget.intranetIp: 'intranetIp',
  DashboardWidget.memoryInfo: 'memoryInfo',
};

_AccessControlProps _$AccessControlPropsFromJson(Map<String, dynamic> json) =>
    _AccessControlProps(
      enable: json['enable'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$AccessControlModeEnumMap, json['mode']) ??
          AccessControlMode.rejectSelected,
      acceptList:
          (json['acceptList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectList:
          (json['rejectList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort:
          $enumDecodeNullable(_$AccessSortTypeEnumMap, json['sort']) ??
          AccessSortType.none,
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
      isFilterNonInternetApp: json['isFilterNonInternetApp'] as bool? ?? true,
    );

Map<String, dynamic> _$AccessControlPropsToJson(_AccessControlProps instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'mode': _$AccessControlModeEnumMap[instance.mode]!,
      'acceptList': instance.acceptList,
      'rejectList': instance.rejectList,
      'sort': _$AccessSortTypeEnumMap[instance.sort]!,
      'isFilterSystemApp': instance.isFilterSystemApp,
      'isFilterNonInternetApp': instance.isFilterNonInternetApp,
    };

const _$AccessControlModeEnumMap = {
  AccessControlMode.acceptSelected: 'acceptSelected',
  AccessControlMode.rejectSelected: 'rejectSelected',
};

const _$AccessSortTypeEnumMap = {
  AccessSortType.none: 'none',
  AccessSortType.name: 'name',
  AccessSortType.time: 'time',
};

_WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) => _WindowProps(
  width: (json['width'] as num?)?.toDouble() ?? 0,
  height: (json['height'] as num?)?.toDouble() ?? 0,
  top: (json['top'] as num?)?.toDouble(),
  left: (json['left'] as num?)?.toDouble(),
  scale: (json['scale'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WindowPropsToJson(_WindowProps instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'top': instance.top,
      'left': instance.left,
      'scale': instance.scale,
    };

_VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) => _VpnProps(
  enable: json['enable'] as bool? ?? true,
  systemProxy: json['systemProxy'] as bool? ?? true,
  ipv6: json['ipv6'] as bool? ?? false,
  allowBypass: json['allowBypass'] as bool? ?? true,
  dnsHijacking: json['dnsHijacking'] as bool? ?? false,
  accessControlProps: json['accessControlProps'] == null
      ? defaultAccessControlProps
      : AccessControlProps.fromJson(
          json['accessControlProps'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VpnPropsToJson(_VpnProps instance) => <String, dynamic>{
  'enable': instance.enable,
  'systemProxy': instance.systemProxy,
  'ipv6': instance.ipv6,
  'allowBypass': instance.allowBypass,
  'dnsHijacking': instance.dnsHijacking,
  'accessControlProps': instance.accessControlProps,
};

_AuthenticationProps _$AuthenticationPropsFromJson(Map<String, dynamic> json) =>
    _AuthenticationProps(
      enable: json['enable'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );

Map<String, dynamic> _$AuthenticationPropsToJson(
  _AuthenticationProps instance,
) => <String, dynamic>{
  'enable': instance.enable,
  'username': instance.username,
  'password': instance.password,
};

_NetworkProps _$NetworkPropsFromJson(Map<String, dynamic> json) =>
    _NetworkProps(
      systemProxy: json['systemProxy'] as bool? ?? true,
      bypassDomain:
          (json['bypassDomain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultBypassDomain,
      bypassPrivateRoute: json['bypassPrivateRoute'] as bool? ?? true,
      autoSetSystemDns: json['autoSetSystemDns'] as bool? ?? true,
      appendSystemDns: json['appendSystemDns'] as bool? ?? false,
      authentication: json['authentication'] == null
          ? defaultAuthenticationProps
          : AuthenticationProps.fromJson(
              json['authentication'] as Map<String, dynamic>?,
            ),
    );

Map<String, dynamic> _$NetworkPropsToJson(_NetworkProps instance) =>
    <String, dynamic>{
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'bypassPrivateRoute': instance.bypassPrivateRoute,
      'autoSetSystemDns': instance.autoSetSystemDns,
      'appendSystemDns': instance.appendSystemDns,
      'authentication': instance.authentication,
    };

_ProxiesStyleProps _$ProxiesStylePropsFromJson(Map<String, dynamic> json) =>
    _ProxiesStyleProps(
      type:
          $enumDecodeNullable(_$ProxiesTypeEnumMap, json['type']) ??
          ProxiesType.list,
      sortType:
          $enumDecodeNullable(_$ProxiesSortTypeEnumMap, json['sortType']) ??
          ProxiesSortType.none,
      layout:
          $enumDecodeNullable(_$ProxiesLayoutEnumMap, json['layout']) ??
          ProxiesLayout.standard,
      iconStyle: json['iconStyle'] == null
          ? ProxiesIconStyle.filled
          : proxiesIconStyleSafeFromJson(json['iconStyle']),
      cardType: json['cardType'] == null
          ? ProxyCardType.standard
          : proxyCardTypeSafeFromJson(json['cardType']),
      hideTimeoutProxies: json['hideTimeoutProxies'] as bool? ?? false,
    );

Map<String, dynamic> _$ProxiesStylePropsToJson(_ProxiesStyleProps instance) =>
    <String, dynamic>{
      'type': _$ProxiesTypeEnumMap[instance.type]!,
      'sortType': _$ProxiesSortTypeEnumMap[instance.sortType]!,
      'layout': _$ProxiesLayoutEnumMap[instance.layout]!,
      'iconStyle': _$ProxiesIconStyleEnumMap[instance.iconStyle]!,
      'cardType': _$ProxyCardTypeEnumMap[instance.cardType]!,
      'hideTimeoutProxies': instance.hideTimeoutProxies,
    };

const _$ProxiesTypeEnumMap = {ProxiesType.tab: 'tab', ProxiesType.list: 'list'};

const _$ProxiesSortTypeEnumMap = {
  ProxiesSortType.none: 'none',
  ProxiesSortType.delay: 'delay',
  ProxiesSortType.name: 'name',
};

const _$ProxiesLayoutEnumMap = {
  ProxiesLayout.loose: 'loose',
  ProxiesLayout.standard: 'standard',
  ProxiesLayout.tight: 'tight',
};

const _$ProxiesIconStyleEnumMap = {
  ProxiesIconStyle.filled: 'filled',
  ProxiesIconStyle.plain: 'plain',
  ProxiesIconStyle.hidden: 'hidden',
};

const _$ProxyCardTypeEnumMap = {
  ProxyCardType.loose: 'loose',
  ProxyCardType.standard: 'standard',
  ProxyCardType.compact: 'compact',
};

_TextScale _$TextScaleFromJson(Map<String, dynamic> json) => _TextScale(
  enable: json['enable'] as bool? ?? false,
  scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$TextScaleToJson(_TextScale instance) =>
    <String, dynamic>{'enable': instance.enable, 'scale': instance.scale};

_ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) => _ThemeProps(
  primaryColor: (json['primaryColor'] as num?)?.toInt(),
  primaryColors:
      (json['primaryColors'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      defaultPrimaryColors,
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      ThemeMode.system,
  colorStyle:
      $enumDecodeNullable(
        _$ColorStyleEnumMap,
        _readColorStyle(json, 'colorStyle'),
      ) ??
      ColorStyle.vivid,
  pureBlack: json['pureBlack'] as bool? ?? false,
  sidebarBlur: json['sidebarBlur'] as bool? ?? false,
  liquidGlass:
      $enumDecodeNullable(
        _$LiquidGlassModeEnumMap,
        _readLiquidGlass(json, 'liquidGlass'),
      ) ??
      LiquidGlassMode.none,
  textScale: json['textScale'] == null
      ? const TextScale()
      : TextScale.fromJson(json['textScale'] as Map<String, dynamic>),
  fontFamily: json['systemFontFamily'] as String?,
);

Map<String, dynamic> _$ThemePropsToJson(_ThemeProps instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'primaryColors': instance.primaryColors,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'colorStyle': _$ColorStyleEnumMap[instance.colorStyle]!,
      'pureBlack': instance.pureBlack,
      'sidebarBlur': instance.sidebarBlur,
      'liquidGlass': _$LiquidGlassModeEnumMap[instance.liquidGlass]!,
      'textScale': instance.textScale,
      'systemFontFamily': instance.fontFamily,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ColorStyleEnumMap = {
  ColorStyle.vivid: 'vivid',
  ColorStyle.tinted: 'tinted',
  ColorStyle.soft: 'soft',
  ColorStyle.monochrome: 'monochrome',
};

const _$LiquidGlassModeEnumMap = {
  LiquidGlassMode.none: 'none',
  LiquidGlassMode.standard: 'standard',
  LiquidGlassMode.ultra: 'ultra',
};

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  currentProfileId: (json['currentProfileId'] as num?)?.toInt(),
  hotKeyActions:
      (json['hotKeyActions'] as List<dynamic>?)
          ?.map((e) => HotKeyAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  appSettingProps: json['appSettingProps'] == null
      ? defaultAppSettingProps
      : AppSettingProps.safeFromJson(
          json['appSettingProps'] as Map<String, Object?>?,
        ),
  davProps: json['davProps'] == null
      ? null
      : DAVProps.fromJson(json['davProps'] as Map<String, dynamic>),
  networkProps: json['networkProps'] == null
      ? defaultNetworkProps
      : NetworkProps.fromJson(json['networkProps'] as Map<String, dynamic>?),
  vpnProps: json['vpnProps'] == null
      ? defaultVpnProps
      : VpnProps.fromJson(json['vpnProps'] as Map<String, dynamic>?),
  themeProps: ThemeProps.safeFromJson(
    json['themeProps'] as Map<String, Object?>?,
  ),
  proxiesStyleProps: json['proxiesStyleProps'] == null
      ? defaultProxiesStyleProps
      : ProxiesStyleProps.fromJson(
          json['proxiesStyleProps'] as Map<String, dynamic>?,
        ),
  windowProps: json['windowGeometry'] == null
      ? defaultWindowProps
      : WindowProps.fromJson(json['windowGeometry'] as Map<String, dynamic>?),
  patchClashConfig: json['patchClashConfig'] == null
      ? defaultClashConfig
      : PatchClashConfig.fromJson(
          json['patchClashConfig'] as Map<String, dynamic>,
        ),
  excludeSSIDs:
      (json['excludeSSIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'currentProfileId': instance.currentProfileId,
  'hotKeyActions': instance.hotKeyActions,
  'appSettingProps': instance.appSettingProps,
  'davProps': instance.davProps,
  'networkProps': instance.networkProps,
  'vpnProps': instance.vpnProps,
  'themeProps': instance.themeProps,
  'proxiesStyleProps': instance.proxiesStyleProps,
  'windowGeometry': instance.windowProps,
  'patchClashConfig': instance.patchClashConfig,
  'excludeSSIDs': instance.excludeSSIDs,
};
