import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';
import 'common.dart';
import 'core.dart';
import 'profile.dart';

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
    @Default({}) Map<QueryTag, String> queryMap,
    @Default({}) Map<String, dynamic> selectedItemMap,
    @Default({}) Map<String, Set<dynamic>> selectedItemsMap,
    @Default(CoreStatus.connecting) CoreStatus coreStatus,
    @Default({}) Map<String, bool> updatingMap,
  }) = _AppState;
}

@freezed
abstract class RunningState with _$RunningState {
  const factory RunningState({
    @Default([]) List<Profile> profiles,
    @Default([]) List<Script> scripts,
    @Default([]) List<Rule> rules,
  }) = _RunningState;
}

extension AppStateExt on AppState {
  ViewMode get viewMode => utils.getViewMode(viewSize.width);

  bool get isStart => runTime != null;
}
