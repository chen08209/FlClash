import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class RealTunEnable extends _$RealTunEnable with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.realTunEnable;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(realTunEnable: value);
  }
}

@riverpod
class Logs extends _$Logs with AutoDisposeNotifierMixin {
  @override
  FixedList<Log> build() {
    return globalState.appState.logs;
  }

  void addLog(Log value) {
    this.value = state.copyWith()..add(value);
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(logs: value);
  }
}

@riverpod
class Requests extends _$Requests with AutoDisposeNotifierMixin {
  @override
  FixedList<TrackerInfo> build() {
    return globalState.appState.requests;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(requests: value);
  }

  void addRequest(TrackerInfo value) {
    this.value = state.copyWith()..add(value);
  }
}

@riverpod
class Providers extends _$Providers with AnyNotifierMixin {
  @override
  List<ExternalProvider> get value => globalState.appState.providers;

  @override
  List<ExternalProvider> build() {
    return globalState.appState.providers;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(providers: value);
  }

  void setProvider(ExternalProvider? provider) {
    if (!ref.mounted) {
      return;
    }
    if (provider == null) return;
    final index = value.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    final newState = List<ExternalProvider>.from(value)..[index] = provider;
    value = newState;
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
    globalState.appState = globalState.appState.copyWith(packages: value);
  }
}

@riverpod
class SystemBrightness extends _$SystemBrightness
    with AutoDisposeNotifierMixin {
  @override
  Brightness build() {
    return globalState.appState.brightness;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(brightness: value);
  }

  void setState(Brightness value) {
    this.value = value;
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
    globalState.appState = globalState.appState.copyWith(traffics: value);
  }

  void addTraffic(Traffic value) {
    this.value = state.copyWith()..add(value);
  }

  void clear() {
    value = state.copyWith()..clear();
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
    globalState.appState = globalState.appState.copyWith(totalTraffic: value);
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
    globalState.appState = globalState.appState.copyWith(localIp: value);
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
    globalState.appState = globalState.appState.copyWith(runTime: value);
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
    globalState.appState = globalState.appState.copyWith(viewSize: value);
  }
}

@riverpod
class SideWidth extends _$SideWidth with AutoDisposeNotifierMixin {
  @override
  double build() {
    return globalState.appState.sideWidth;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(sideWidth: value);
  }
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
    globalState.appState = globalState.appState.copyWith(isInit: value);
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
    globalState.appState = globalState.appState.copyWith(pageLabel: value);
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
    globalState.appState = globalState.appState.copyWith(sortNum: value);
  }

  int add() => state++;
}

@riverpod
class CheckIpNum extends _$CheckIpNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.checkIpNum;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(checkIpNum: value);
  }

  int add() => state++;
}

@riverpod
class BackBlock extends _$BackBlock with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.backBlock;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(backBlock: value);
  }
}

@riverpod
class Loading extends _$Loading with AutoDisposeNotifierMixin {
  DateTime? _start;
  Timer? _timer;

  @override
  bool build() {
    return globalState.appState.loading;
  }

  void start() {
    _timer?.cancel();
    _timer = null;
    _start = DateTime.now();
    value = true;
  }

  Future<void> stop() async {
    if (_start == null) {
      value = false;
      return;
    }
    final startedAt = _start!;
    final elapsed = DateTime.now().difference(_start!).inMilliseconds;
    const minDuration = 1000;
    if (elapsed >= minDuration) {
      value = false;
      return;
    }
    _timer = Timer(Duration(milliseconds: minDuration - elapsed), () {
      if (_start != startedAt) {
        return;
      }
      value = false;
    });
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(loading: value);
  }
}

@riverpod
class Version extends _$Version with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.version;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(version: value);
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
    globalState.appState = globalState.appState.copyWith(groups: value);
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
    globalState.appState = globalState.appState.copyWith(delayMap: value);
  }

  void setDelay(Delay delay) {
    if (state[delay.url]?[delay.name] != delay.value) {
      final DelayMap newDelayMap = Map.from(state);
      if (newDelayMap[delay.url] == null) {
        newDelayMap[delay.url] = {};
      }
      newDelayMap[delay.url]![delay.name] = delay.value;
      value = newDelayMap;
    }
  }
}

@riverpod
class SystemUiOverlayStyleState extends _$SystemUiOverlayStyleState
    with AutoDisposeNotifierMixin {
  @override
  SystemUiOverlayStyle build() {
    return globalState.appState.systemUiOverlayStyle;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      systemUiOverlayStyle: value,
    );
  }
}

@riverpod
class ProfileOverrideState extends _$ProfileOverrideState
    with AutoDisposeNotifierMixin {
  @override
  ProfileOverrideModel? build() {
    return globalState.appState.profileOverrideModel;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      profileOverrideModel: value,
    );
  }

  void updateState(
    ProfileOverrideModel? Function(ProfileOverrideModel? state) builder,
  ) {
    final value = builder(state);
    if (value == null) {
      return;
    }
    this.value = value;
  }
}

@Riverpod(name: 'coreStatusProvider')
class _CoreStatus extends _$CoreStatus with AutoDisposeNotifierMixin {
  @override
  CoreStatus build() {
    return globalState.appState.coreStatus;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(coreStatus: value);
  }
}

@riverpod
class Query extends _$Query with AutoDisposeNotifierMixin {
  late final QueryTag _tag;

  @override
  String build(QueryTag tag) {
    _tag = tag;
    return globalState.appState.queryMap[tag] ?? '';
  }

  @override
  onUpdate(value) {
    final newMap = Map<QueryTag, String>.from(globalState.appState.queryMap)
      ..[_tag] = value;
    globalState.appState = globalState.appState.copyWith(queryMap: newMap);
  }
}

@riverpod
class SelectedItems extends _$SelectedItems with AutoDisposeNotifierMixin {
  late final String _key;

  @override
  Set<String> build(String key) {
    _key = key;
    return globalState.appState.selectedItemsMap[_key] ?? {};
  }

  @override
  onUpdate(value) {
    final newMap = globalState.appState.selectedItemsMap.copyWitUpdate(
      key,
      value.isEmpty ? null : value,
    );
    globalState.appState = globalState.appState.copyWith(
      selectedItemsMap: newMap,
    );
  }
}

@riverpod
class SelectedItem extends _$SelectedItem with AutoDisposeNotifierMixin {
  late final String _key;

  @override
  String build(String key) {
    _key = key;
    return globalState.appState.selectedItemMap[_key] ?? '';
  }

  @override
  onUpdate(value) {
    final newMap = globalState.appState.selectedItemMap.copyWitUpdate(
      key,
      value.isEmpty ? null : value,
    );
    globalState.appState = globalState.appState.copyWith(
      selectedItemMap: newMap,
    );
  }
}
