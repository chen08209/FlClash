import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class Logs extends _$Logs with AutoDisposeNotifierMixin {
  @override
  FixedList<Log> build() {
    return globalState.appState.logs;
  }

  addLog(Log value) {
    state = state.copyWith()..add(value);
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      logs: value,
    );
  }
}

@riverpod
class Requests extends _$Requests with AutoDisposeNotifierMixin {
  @override
  FixedList<Connection> build() {
    return globalState.appState.requests;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      requests: value,
    );
  }

  addRequest(Connection value) {
    state = state.copyWith()..add(value);
  }
}

@riverpod
class Providers extends _$Providers with AutoDisposeNotifierMixin {
  @override
  List<ExternalProvider> build() {
    return globalState.appState.providers;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      providers: value,
    );
  }

  setProvider(ExternalProvider? provider) {
    if (provider == null) return;
    final index = state.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    state = List.from(state)..[index] = provider;
  }
}

@riverpod
class Packages extends _$Packages with AutoDisposeNotifierMixin {
  @override
  List<Package> build() {
    return globalState.appState.packages;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      packages: value,
    );
  }
}

@riverpod
class AppBrightness extends _$AppBrightness with AutoDisposeNotifierMixin {
  @override
  Brightness? build() {
    return globalState.appState.brightness;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      brightness: value,
    );
  }

  setState(Brightness? value) {
    state = value;
  }
}

@riverpod
class Traffics extends _$Traffics with AutoDisposeNotifierMixin {
  @override
  FixedList<Traffic> build() {
    return globalState.appState.traffics;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      traffics: value,
    );
  }

  addTraffic(Traffic value) {
    state = state.copyWith()..add(value);
  }

  clear() {
    state = state.copyWith()..clear();
  }
}

@riverpod
class TotalTraffic extends _$TotalTraffic with AutoDisposeNotifierMixin {
  @override
  Traffic build() {
    return globalState.appState.totalTraffic;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      totalTraffic: value,
    );
  }
}

@riverpod
class LocalIp extends _$LocalIp with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return globalState.appState.localIp;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      localIp: value,
    );
  }

  @override
  set state(String? value) {
    super.state = value;
    globalState.appState = globalState.appState.copyWith(
      localIp: state,
    );
  }
}

@riverpod
class RunTime extends _$RunTime with AutoDisposeNotifierMixin {
  @override
  int? build() {
    return globalState.appState.runTime;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      runTime: value,
    );
  }

  bool get isStart {
    return state != null;
  }
}

@riverpod
class ViewSize extends _$ViewSize with AutoDisposeNotifierMixin {
  @override
  Size build() {
    return globalState.appState.viewSize;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      viewSize: value,
    );
  }

  ViewMode get viewMode => utils.getViewMode(state.width);

  bool get isMobileView => viewMode == ViewMode.mobile;
}

@riverpod
double viewWidth(Ref ref) {
  return ref.watch(viewSizeProvider).width;
}

@riverpod
ViewMode viewMode(Ref ref) {
  return utils.getViewMode(ref.watch(viewWidthProvider));
}

@riverpod
bool isMobileView(Ref ref) {
  return ref.watch(viewModeProvider) == ViewMode.mobile;
}

@riverpod
double viewHeight(Ref ref) {
  return ref.watch(viewSizeProvider).height;
}

@riverpod
class Init extends _$Init with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.isInit;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      isInit: value,
    );
  }
}

@riverpod
class CurrentPageLabel extends _$CurrentPageLabel
    with AutoDisposeNotifierMixin {
  @override
  PageLabel build() {
    return globalState.appState.pageLabel;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      pageLabel: value,
    );
  }
}

@riverpod
class SortNum extends _$SortNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.sortNum;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      sortNum: value,
    );
  }

  add() => state++;
}

@riverpod
class CheckIpNum extends _$CheckIpNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.checkIpNum;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      checkIpNum: value,
    );
  }

  add() => state++;
}

@riverpod
class Version extends _$Version with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.version;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      version: value,
    );
  }
}

@riverpod
class Groups extends _$Groups with AutoDisposeNotifierMixin {
  @override
  List<Group> build() {
    return globalState.appState.groups;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      groups: value,
    );
  }
}

@riverpod
class DelayDataSource extends _$DelayDataSource with AutoDisposeNotifierMixin {
  @override
  DelayMap build() {
    return globalState.appState.delayMap;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      delayMap: value,
    );
  }

  setDelay(Delay delay) {
    if (state[delay.url]?[delay.name] != delay.value) {
      final DelayMap newDelayMap = Map.from(state);
      if (newDelayMap[delay.url] == null) {
        newDelayMap[delay.url] = {};
      }
      newDelayMap[delay.url]![delay.name] = delay.value;
      state = newDelayMap;
    }
  }
}

@riverpod
class NeedApply extends _$NeedApply with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.needApply;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      needApply: value,
    );
  }
}
