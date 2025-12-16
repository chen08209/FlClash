// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharedState _$SharedStateFromJson(Map<String, dynamic> json) => _SharedState(
  setupParams: json['setupParams'] == null
      ? null
      : SetupParams.fromJson(json['setupParams'] as Map<String, dynamic>),
  vpnOptions: json['vpnOptions'] == null
      ? null
      : VpnOptions.fromJson(json['vpnOptions'] as Map<String, dynamic>),
  stopTip: json['stopTip'] as String,
  startTip: json['startTip'] as String,
  currentProfileName: json['currentProfileName'] as String,
  stopText: json['stopText'] as String,
  onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool,
  crashlytics: json['crashlytics'] as bool,
);

Map<String, dynamic> _$SharedStateToJson(_SharedState instance) =>
    <String, dynamic>{
      'setupParams': instance.setupParams,
      'vpnOptions': instance.vpnOptions,
      'stopTip': instance.stopTip,
      'startTip': instance.startTip,
      'currentProfileName': instance.currentProfileName,
      'stopText': instance.stopText,
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'crashlytics': instance.crashlytics,
    };
