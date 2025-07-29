// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingPropsImpl _$$AppSettingPropsImplFromJson(
        Map<String, dynamic> json) =>
    _$AppSettingPropsImpl(
      locale: json['locale'] as String?,
      dashboardWidgets: json['dashboardWidgets'] == null
          ? defaultDashboardWidgets
          : dashboardWidgetsSafeFormJson(json['dashboardWidgets'] as List?),
      onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool? ?? false,
      autoLaunch: json['autoLaunch'] as bool? ?? false,
      silentLaunch: json['silentLaunch'] as bool? ?? false,
      autoRun: json['autoRun'] as bool? ?? false,
      openLogs: json['openLogs'] as bool? ?? false,
      closeConnections: json['closeConnections'] as bool? ?? true,
      testUrl: json['testUrl'] as String? ?? defaultTestUrl,
      isAnimateToPage: json['isAnimateToPage'] as bool? ?? true,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? true,
      showLabel: json['showLabel'] as bool? ?? false,
      disclaimerAccepted: json['disclaimerAccepted'] as bool? ?? false,
      minimizeOnExit: json['minimizeOnExit'] as bool? ?? true,
      hidden: json['hidden'] as bool? ?? false,
      developerMode: json['developerMode'] as bool? ?? false,
      recoveryStrategy: $enumDecodeNullable(
              _$RecoveryStrategyEnumMap, json['recoveryStrategy']) ??
          RecoveryStrategy.compatible,
    );

Map<String, dynamic> _$$AppSettingPropsImplToJson(
        _$AppSettingPropsImpl instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'dashboardWidgets': instance.dashboardWidgets
          .map((e) => _$DashboardWidgetEnumMap[e]!)
          .toList(),
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'autoRun': instance.autoRun,
      'openLogs': instance.openLogs,
      'closeConnections': instance.closeConnections,
      'testUrl': instance.testUrl,
      'isAnimateToPage': instance.isAnimateToPage,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'showLabel': instance.showLabel,
      'disclaimerAccepted': instance.disclaimerAccepted,
      'minimizeOnExit': instance.minimizeOnExit,
      'hidden': instance.hidden,
      'developerMode': instance.developerMode,
      'recoveryStrategy': _$RecoveryStrategyEnumMap[instance.recoveryStrategy]!,
    };

const _$RecoveryStrategyEnumMap = {
  RecoveryStrategy.compatible: 'compatible',
  RecoveryStrategy.override: 'override',
};

const _$DashboardWidgetEnumMap = {
  DashboardWidget.networkSpeed: 'networkSpeed',
  DashboardWidget.outboundModeV2: 'outboundModeV2',
  DashboardWidget.outboundMode: 'outboundMode',
  DashboardWidget.trafficUsage: 'trafficUsage',
  DashboardWidget.networkDetection: 'networkDetection',
  DashboardWidget.tunButton: 'tunButton',
  DashboardWidget.vpnButton: 'vpnButton',
  DashboardWidget.systemProxyButton: 'systemProxyButton',
  DashboardWidget.intranetIp: 'intranetIp',
  DashboardWidget.memoryInfo: 'memoryInfo',
};

_$AccessControlImpl _$$AccessControlImplFromJson(Map<String, dynamic> json) =>
    _$AccessControlImpl(
      enable: json['enable'] as bool? ?? false,
      mode: $enumDecodeNullable(_$AccessControlModeEnumMap, json['mode']) ??
          AccessControlMode.rejectSelected,
      acceptList: (json['acceptList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectList: (json['rejectList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort: $enumDecodeNullable(_$AccessSortTypeEnumMap, json['sort']) ??
          AccessSortType.none,
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
      isFilterNonInternetApp: json['isFilterNonInternetApp'] as bool? ?? true,
    );

Map<String, dynamic> _$$AccessControlImplToJson(_$AccessControlImpl instance) =>
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

_$WindowPropsImpl _$$WindowPropsImplFromJson(Map<String, dynamic> json) =>
    _$WindowPropsImpl(
      width: (json['width'] as num?)?.toDouble() ?? 750,
      height: (json['height'] as num?)?.toDouble() ?? 600,
      top: (json['top'] as num?)?.toDouble(),
      left: (json['left'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WindowPropsImplToJson(_$WindowPropsImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'top': instance.top,
      'left': instance.left,
    };

_$VpnPropsImpl _$$VpnPropsImplFromJson(Map<String, dynamic> json) =>
    _$VpnPropsImpl(
      enable: json['enable'] as bool? ?? true,
      systemProxy: json['systemProxy'] as bool? ?? true,
      ipv6: json['ipv6'] as bool? ?? false,
      allowBypass: json['allowBypass'] as bool? ?? true,
      accessControl: json['accessControl'] == null
          ? defaultAccessControl
          : AccessControl.fromJson(
              json['accessControl'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VpnPropsImplToJson(_$VpnPropsImpl instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'systemProxy': instance.systemProxy,
      'ipv6': instance.ipv6,
      'allowBypass': instance.allowBypass,
      'accessControl': instance.accessControl,
    };

_$NetworkPropsImpl _$$NetworkPropsImplFromJson(Map<String, dynamic> json) =>
    _$NetworkPropsImpl(
      systemProxy: json['systemProxy'] as bool? ?? true,
      bypassDomain: (json['bypassDomain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultBypassDomain,
      routeMode: $enumDecodeNullable(_$RouteModeEnumMap, json['routeMode']) ??
          RouteMode.config,
      autoSetSystemDns: json['autoSetSystemDns'] as bool? ?? true,
    );

Map<String, dynamic> _$$NetworkPropsImplToJson(_$NetworkPropsImpl instance) =>
    <String, dynamic>{
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'routeMode': _$RouteModeEnumMap[instance.routeMode]!,
      'autoSetSystemDns': instance.autoSetSystemDns,
    };

const _$RouteModeEnumMap = {
  RouteMode.bypassPrivate: 'bypassPrivate',
  RouteMode.config: 'config',
};

_$ProxiesStyleImpl _$$ProxiesStyleImplFromJson(Map<String, dynamic> json) =>
    _$ProxiesStyleImpl(
      type: $enumDecodeNullable(_$ProxiesTypeEnumMap, json['type']) ??
          ProxiesType.tab,
      sortType:
          $enumDecodeNullable(_$ProxiesSortTypeEnumMap, json['sortType']) ??
              ProxiesSortType.none,
      layout: $enumDecodeNullable(_$ProxiesLayoutEnumMap, json['layout']) ??
          ProxiesLayout.standard,
      iconStyle:
          $enumDecodeNullable(_$ProxiesIconStyleEnumMap, json['iconStyle']) ??
              ProxiesIconStyle.standard,
      cardType: $enumDecodeNullable(_$ProxyCardTypeEnumMap, json['cardType']) ??
          ProxyCardType.expand,
      iconMap: (json['iconMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$$ProxiesStyleImplToJson(_$ProxiesStyleImpl instance) =>
    <String, dynamic>{
      'type': _$ProxiesTypeEnumMap[instance.type]!,
      'sortType': _$ProxiesSortTypeEnumMap[instance.sortType]!,
      'layout': _$ProxiesLayoutEnumMap[instance.layout]!,
      'iconStyle': _$ProxiesIconStyleEnumMap[instance.iconStyle]!,
      'cardType': _$ProxyCardTypeEnumMap[instance.cardType]!,
      'iconMap': instance.iconMap,
    };

const _$ProxiesTypeEnumMap = {
  ProxiesType.tab: 'tab',
  ProxiesType.list: 'list',
};

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
  ProxiesIconStyle.standard: 'standard',
  ProxiesIconStyle.none: 'none',
  ProxiesIconStyle.icon: 'icon',
};

const _$ProxyCardTypeEnumMap = {
  ProxyCardType.expand: 'expand',
  ProxyCardType.shrink: 'shrink',
  ProxyCardType.min: 'min',
};

_$TextScaleImpl _$$TextScaleImplFromJson(Map<String, dynamic> json) =>
    _$TextScaleImpl(
      enable: json['enable'] as bool? ?? false,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$TextScaleImplToJson(_$TextScaleImpl instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'scale': instance.scale,
    };

_$ThemePropsImpl _$$ThemePropsImplFromJson(Map<String, dynamic> json) =>
    _$ThemePropsImpl(
      primaryColor: (json['primaryColor'] as num?)?.toInt(),
      primaryColors: (json['primaryColors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          defaultPrimaryColors,
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.dark,
      schemeVariant: $enumDecodeNullable(
              _$DynamicSchemeVariantEnumMap, json['schemeVariant']) ??
          DynamicSchemeVariant.content,
      pureBlack: json['pureBlack'] as bool? ?? false,
      textScale: json['textScale'] == null
          ? const TextScale()
          : TextScale.fromJson(json['textScale'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ThemePropsImplToJson(_$ThemePropsImpl instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'primaryColors': instance.primaryColors,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'schemeVariant': _$DynamicSchemeVariantEnumMap[instance.schemeVariant]!,
      'pureBlack': instance.pureBlack,
      'textScale': instance.textScale,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DynamicSchemeVariantEnumMap = {
  DynamicSchemeVariant.tonalSpot: 'tonalSpot',
  DynamicSchemeVariant.fidelity: 'fidelity',
  DynamicSchemeVariant.monochrome: 'monochrome',
  DynamicSchemeVariant.neutral: 'neutral',
  DynamicSchemeVariant.vibrant: 'vibrant',
  DynamicSchemeVariant.expressive: 'expressive',
  DynamicSchemeVariant.content: 'content',
  DynamicSchemeVariant.rainbow: 'rainbow',
  DynamicSchemeVariant.fruitSalad: 'fruitSalad',
};

_$ScriptPropsImpl _$$ScriptPropsImplFromJson(Map<String, dynamic> json) =>
    _$ScriptPropsImpl(
      currentId: json['currentId'] as String?,
      scripts: (json['scripts'] as List<dynamic>?)
              ?.map((e) => Script.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ScriptPropsImplToJson(_$ScriptPropsImpl instance) =>
    <String, dynamic>{
      'currentId': instance.currentId,
      'scripts': instance.scripts,
    };

_$ConfigImpl _$$ConfigImplFromJson(Map<String, dynamic> json) => _$ConfigImpl(
      appSetting: json['appSetting'] == null
          ? defaultAppSettingProps
          : AppSettingProps.safeFromJson(
              json['appSetting'] as Map<String, Object?>?),
      profiles: (json['profiles'] as List<dynamic>?)
              ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hotKeyActions: (json['hotKeyActions'] as List<dynamic>?)
              ?.map((e) => HotKeyAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentProfileId: json['currentProfileId'] as String?,
      overrideDns: json['overrideDns'] as bool? ?? false,
      dav: json['dav'] == null
          ? null
          : DAV.fromJson(json['dav'] as Map<String, dynamic>),
      networkProps: json['networkProps'] == null
          ? defaultNetworkProps
          : NetworkProps.fromJson(
              json['networkProps'] as Map<String, dynamic>?),
      vpnProps: json['vpnProps'] == null
          ? defaultVpnProps
          : VpnProps.fromJson(json['vpnProps'] as Map<String, dynamic>?),
      themeProps:
          ThemeProps.safeFromJson(json['themeProps'] as Map<String, Object?>?),
      proxiesStyle: json['proxiesStyle'] == null
          ? defaultProxiesStyle
          : ProxiesStyle.fromJson(
              json['proxiesStyle'] as Map<String, dynamic>?),
      windowProps: json['windowProps'] == null
          ? defaultWindowProps
          : WindowProps.fromJson(json['windowProps'] as Map<String, dynamic>?),
      patchClashConfig: json['patchClashConfig'] == null
          ? defaultClashConfig
          : ClashConfig.fromJson(
              json['patchClashConfig'] as Map<String, dynamic>),
      scriptProps: json['scriptProps'] == null
          ? const ScriptProps()
          : ScriptProps.fromJson(json['scriptProps'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ConfigImplToJson(_$ConfigImpl instance) =>
    <String, dynamic>{
      'appSetting': instance.appSetting,
      'profiles': instance.profiles,
      'hotKeyActions': instance.hotKeyActions,
      'currentProfileId': instance.currentProfileId,
      'overrideDns': instance.overrideDns,
      'dav': instance.dav,
      'networkProps': instance.networkProps,
      'vpnProps': instance.vpnProps,
      'themeProps': instance.themeProps,
      'proxiesStyle': instance.proxiesStyle,
      'windowProps': instance.windowProps,
      'patchClashConfig': instance.patchClashConfig,
      'scriptProps': instance.scriptProps,
    };
