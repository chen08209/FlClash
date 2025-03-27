import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'core.dart';

part 'generated/app.freezed.dart';

typedef DelayMap = Map<String, Map<String, int?>>;

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(false) bool isInit,
    @Default(PageLabel.dashboard) PageLabel pageLabel,
    @Default([]) List<Package> packages,
    @Default(ColorSchemes()) ColorSchemes colorSchemes,
    @Default(0) int sortNum,
    required double viewWidth,
    @Default({}) DelayMap delayMap,
    @Default([]) List<Group> groups,
    @Default(0) int checkIpNum,
    Brightness? brightness,
    int? runTime,
    @Default([]) List<ExternalProvider> providers,
    String? localIp,
    required FixedList<Connection> requests,
    required int version,
    required FixedList<Log> logs,
    required FixedList<Traffic> traffics,
    required Traffic totalTraffic,
  }) = _AppState;
}

extension AppStateExt on AppState {
  ViewMode get viewMode => other.getViewMode(viewWidth);

  bool get isStart => runTime != null;
}
