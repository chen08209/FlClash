import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/selector.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'core.dart';

part 'generated/app.freezed.dart';

typedef DelayMap = Map<String, Map<String, int?>>;

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    @Default(false) bool isInit,
    @Default(false) bool backBlock,
    @Default(PageLabel.dashboard) PageLabel pageLabel,
    @Default([]) List<Package> packages,
    @Default(0) int sortNum,
    required Size viewSize,
    @Default(0) double sideWidth,
    @Default({}) DelayMap delayMap,
    @Default([]) List<Group> groups,
    @Default(0) int checkIpNum,
    required Brightness brightness,
    int? runTime,
    @Default([]) List<ExternalProvider> providers,
    String? localIp,
    required FixedList<TrackerInfo> requests,
    required int version,
    required FixedList<Log> logs,
    required FixedList<Traffic> traffics,
    required Traffic totalTraffic,
    @Default(false) bool realTunEnable,
    @Default(false) bool loading,
    required SystemUiOverlayStyle systemUiOverlayStyle,
    ProfileOverrideModel? profileOverrideModel,
    @Default({}) Map<QueryTag, String> queryMap,
    @Default(CoreStatus.connecting) CoreStatus coreStatus,
  }) = _AppState;
}

extension AppStateExt on AppState {
  ViewMode get viewMode => utils.getViewMode(viewSize.width);

  bool get isStart => runTime != null;
}
