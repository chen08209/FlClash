// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config()
  ..profiles = (json['profiles'] as List<dynamic>?)
          ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      []
  ..currentProfileId = json['currentProfileId'] as String?
  ..autoLaunch = json['autoLaunch'] as bool? ?? false
  ..silentLaunch = json['silentLaunch'] as bool? ?? false
  ..autoRun = json['autoRun'] as bool? ?? false
  ..themeMode = $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      ThemeMode.system
  ..openLogs = json['openLogs'] as bool? ?? false
  ..locale = json['locale'] as String?
  ..primaryColor = (json['primaryColor'] as num?)?.toInt()
  ..proxiesSortType =
      $enumDecodeNullable(_$ProxiesSortTypeEnumMap, json['proxiesSortType']) ??
          ProxiesSortType.none
  ..isMinimizeOnExit = json['isMinimizeOnExit'] as bool? ?? true
  ..isAccessControl = json['isAccessControl'] as bool? ?? false
  ..accessControl =
      AccessControl.fromJson(json['accessControl'] as Map<String, dynamic>)
  ..dav = json['dav'] == null
      ? null
      : DAV.fromJson(json['dav'] as Map<String, dynamic>)
  ..isAnimateToPage = json['isAnimateToPage'] as bool? ?? true
  ..isCompatible = json['isCompatible'] as bool? ?? true
  ..autoCheckUpdate = json['autoCheckUpdate'] as bool? ?? true
  ..allowBypass = json['allowBypass'] as bool? ?? true
  ..systemProxy = json['systemProxy'] as bool? ?? true
  ..proxiesType =
      $enumDecodeNullable(_$ProxiesTypeEnumMap, json['proxiesType']) ??
          ProxiesType.tab
  ..proxyCardType =
      $enumDecodeNullable(_$ProxyCardTypeEnumMap, json['proxyCardType']) ??
          ProxyCardType.expand
  ..proxiesColumns = (json['proxiesColumns'] as num?)?.toInt() ?? 2;

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'profiles': instance.profiles,
      'currentProfileId': instance.currentProfileId,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'autoRun': instance.autoRun,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'openLogs': instance.openLogs,
      'locale': instance.locale,
      'primaryColor': instance.primaryColor,
      'proxiesSortType': _$ProxiesSortTypeEnumMap[instance.proxiesSortType]!,
      'isMinimizeOnExit': instance.isMinimizeOnExit,
      'isAccessControl': instance.isAccessControl,
      'accessControl': instance.accessControl,
      'dav': instance.dav,
      'isAnimateToPage': instance.isAnimateToPage,
      'isCompatible': instance.isCompatible,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'allowBypass': instance.allowBypass,
      'systemProxy': instance.systemProxy,
      'proxiesType': _$ProxiesTypeEnumMap[instance.proxiesType]!,
      'proxyCardType': _$ProxyCardTypeEnumMap[instance.proxyCardType]!,
      'proxiesColumns': instance.proxiesColumns,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ProxiesSortTypeEnumMap = {
  ProxiesSortType.none: 'none',
  ProxiesSortType.delay: 'delay',
  ProxiesSortType.name: 'name',
};

const _$ProxiesTypeEnumMap = {
  ProxiesType.tab: 'tab',
  ProxiesType.expansion: 'expansion',
};

const _$ProxyCardTypeEnumMap = {
  ProxyCardType.expand: 'expand',
  ProxyCardType.shrink: 'shrink',
};

_$AccessControlImpl _$$AccessControlImplFromJson(Map<String, dynamic> json) =>
    _$AccessControlImpl(
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
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
    );

Map<String, dynamic> _$$AccessControlImplToJson(_$AccessControlImpl instance) =>
    <String, dynamic>{
      'mode': _$AccessControlModeEnumMap[instance.mode]!,
      'acceptList': instance.acceptList,
      'rejectList': instance.rejectList,
      'isFilterSystemApp': instance.isFilterSystemApp,
    };

const _$AccessControlModeEnumMap = {
  AccessControlMode.acceptSelected: 'acceptSelected',
  AccessControlMode.rejectSelected: 'rejectSelected',
};

_$PropsImpl _$$PropsImplFromJson(Map<String, dynamic> json) => _$PropsImpl(
      accessControl: json['accessControl'] == null
          ? null
          : AccessControl.fromJson(
              json['accessControl'] as Map<String, dynamic>),
      allowBypass: json['allowBypass'] as bool?,
      systemProxy: json['systemProxy'] as bool?,
    );

Map<String, dynamic> _$$PropsImplToJson(_$PropsImpl instance) =>
    <String, dynamic>{
      'accessControl': instance.accessControl,
      'allowBypass': instance.allowBypass,
      'systemProxy': instance.systemProxy,
    };
