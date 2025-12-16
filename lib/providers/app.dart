import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class RealTunEnable extends _$RealTunEnable with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
class Logs extends _$Logs with AutoDisposeNotifierMixin {
  @override
  FixedList<Log> build() {
    return FixedList(0);
  }

  void addLog(Log value) {
    this.value = state.copyWith()..add(value);
  }
}

@Riverpod(keepAlive: true)
class Requests extends _$Requests with AutoDisposeNotifierMixin {
  @override
  FixedList<TrackerInfo> build() {
    return FixedList(0);
  }

  void addRequest(TrackerInfo value) {
    this.value = state.copyWith()..add(value);
  }
}

@Riverpod(keepAlive: true)
class Providers extends _$Providers with AutoDisposeNotifierMixin {
  @override
  List<ExternalProvider> build() {
    return [];
  }

  void setProvider(ExternalProvider? provider) {
    if (provider == null) return;
    final index = value.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    final newState = List<ExternalProvider>.from(value)..[index] = provider;
    value = newState;
  }
}

@Riverpod(keepAlive: true)
class Packages extends _$Packages with AutoDisposeNotifierMixin {
  @override
  List<Package> build() {
    return [];
  }
}

@Riverpod(keepAlive: true)
class SystemBrightness extends _$SystemBrightness
    with AutoDisposeNotifierMixin {
  @override
  Brightness build() {
    return Brightness.dark;
  }
}

@Riverpod(keepAlive: true)
class Traffics extends _$Traffics with AutoDisposeNotifierMixin {
  @override
  FixedList<Traffic> build() {
    return FixedList(0);
  }

  void addTraffic(Traffic value) {
    this.value = state.copyWith()..add(value);
  }

  void clear() {
    value = state.copyWith()..clear();
  }
}

@Riverpod(keepAlive: true)
class TotalTraffic extends _$TotalTraffic with AutoDisposeNotifierMixin {
  @override
  Traffic build() {
    return Traffic();
  }
}

@Riverpod(keepAlive: true)
class LocalIp extends _$LocalIp with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return null;
  }
}

@Riverpod(keepAlive: true)
class RunTime extends _$RunTime with AutoDisposeNotifierMixin {
  @override
  int? build() {
    return null;
  }
}

@Riverpod(keepAlive: true)
class ViewSize extends _$ViewSize with AutoDisposeNotifierMixin {
  @override
  Size build() {
    return Size.zero;
  }
}

@Riverpod(keepAlive: true)
class SideWidth extends _$SideWidth with AutoDisposeNotifierMixin {
  @override
  double build() {
    return 0;
  }
}

@Riverpod(keepAlive: true)
double viewWidth(Ref ref) {
  return ref.watch(viewSizeProvider).width;
}

@Riverpod(keepAlive: true)
ViewMode viewMode(Ref ref) {
  return utils.getViewMode(ref.watch(viewWidthProvider));
}

@Riverpod(keepAlive: true)
bool isMobileView(Ref ref) {
  return ref.watch(viewModeProvider) == ViewMode.mobile;
}

@Riverpod(keepAlive: true)
double viewHeight(Ref ref) {
  return ref.watch(viewSizeProvider).height;
}

@Riverpod(keepAlive: true)
class Init extends _$Init with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
class CurrentPageLabel extends _$CurrentPageLabel
    with AutoDisposeNotifierMixin {
  @override
  PageLabel build() {
    return PageLabel.dashboard;
  }
}

@Riverpod(keepAlive: true)
class SortNum extends _$SortNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return 0;
  }

  int add() => state++;
}

@Riverpod(keepAlive: true)
class CheckIpNum extends _$CheckIpNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return 0;
  }

  int add() => state++;
}

@Riverpod(keepAlive: true)
class BackBlock extends _$BackBlock with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
class Version extends _$Version with AutoDisposeNotifierMixin {
  @override
  int build() {
    return 0;
  }
}

@Riverpod(keepAlive: true)
class Groups extends _$Groups with AutoDisposeNotifierMixin {
  @override
  List<Group> build() {
    return [];
  }
}

@Riverpod(keepAlive: true)
class DelayDataSource extends _$DelayDataSource with AutoDisposeNotifierMixin {
  @override
  DelayMap build() {
    return {};
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

@Riverpod(keepAlive: true)
class SystemUiOverlayStyleState extends _$SystemUiOverlayStyleState
    with AutoDisposeNotifierMixin {
  @override
  SystemUiOverlayStyle build() {
    return SystemUiOverlayStyle();
  }
}

@Riverpod(name: 'coreStatusProvider', keepAlive: true)
class _CoreStatus extends _$CoreStatus with AutoDisposeNotifierMixin {
  @override
  CoreStatus build() {
    return CoreStatus.disconnected;
  }
}

@riverpod
class Query extends _$Query with AutoDisposeNotifierMixin {
  @override
  String build(QueryTag tag) {
    return '';
  }
}

@Riverpod(keepAlive: true)
class Loading extends _$Loading with AutoDisposeNotifierMixin {
  DateTime? _start;
  Timer? _timer;

  @override
  bool build(LoadingTag tag) {
    return false;
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
}

@riverpod
class SelectedItems extends _$SelectedItems with AutoDisposeNotifierMixin {
  @override
  Set<dynamic> build(String key) {
    return {};
  }
}

@riverpod
class SelectedItem extends _$SelectedItem with AutoDisposeNotifierMixin {
  @override
  dynamic build(String key) {
    return null;
  }
}

@riverpod
class IsUpdating extends _$IsUpdating with AutoDisposeNotifierMixin {
  @override
  bool build(String name) {
    return false;
  }
}

@Riverpod(keepAlive: true)
class NetworkDetection extends _$NetworkDetection
    with AutoDisposeNotifierMixin {
  bool? _preIsStart;
  CancelToken? _cancelToken;
  int _startMillisecondsEpoch = 0;

  @override
  NetworkDetectionState build() {
    return NetworkDetectionState(isLoading: true, ipInfo: null);
  }

  void startCheck() {
    debouncer.call(FunctionTag.checkIp, () {
      _checkIp();
    }, duration: commonDuration);
  }

  Future<void> _checkIp() async {
    final isInit = ref.read(initProvider);
    if (!isInit) {
      return;
    }
    final isStart = ref.read(isStartProvider);
    if (!isStart && _preIsStart == false && state.ipInfo != null) {
      return;
    }
    final millisecondsEpoch = DateTime.now().millisecondsSinceEpoch;
    _startMillisecondsEpoch = millisecondsEpoch;
    final runTime = millisecondsEpoch + 1;
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    commonPrint.log('checkIp start');
    state = state.copyWith(isLoading: true, ipInfo: null);
    _preIsStart = isStart;
    final res = await request.checkIp(cancelToken: _cancelToken);
    commonPrint.log('checkIp res: $res');
    if (res.isError && runTime > _startMillisecondsEpoch) {
      state = state.copyWith(isLoading: true, ipInfo: null);
      return;
    }
    final ipInfo = res.data;
    if (ipInfo == null) {
      return;
    }
    state = state.copyWith(isLoading: false, ipInfo: ipInfo);
  }
}

List<Override> buildAppStateOverrides(AppState appState) {
  return [
    initProvider.overrideWithBuild((_, _) => appState.isInit),
    backBlockProvider.overrideWithBuild((_, _) => appState.backBlock),
    currentPageLabelProvider.overrideWithBuild((_, _) => appState.pageLabel),
    packagesProvider.overrideWithBuild((_, _) => appState.packages),
    sortNumProvider.overrideWithBuild((_, _) => appState.sortNum),
    viewSizeProvider.overrideWithBuild((_, _) => appState.viewSize),
    sideWidthProvider.overrideWithBuild((_, _) => appState.sideWidth),
    delayDataSourceProvider.overrideWithBuild((_, _) => appState.delayMap),
    groupsProvider.overrideWithBuild((_, _) => appState.groups),
    checkIpNumProvider.overrideWithBuild((_, _) => appState.checkIpNum),
    systemBrightnessProvider.overrideWithBuild((_, _) => appState.brightness),
    runTimeProvider.overrideWithBuild((_, _) => appState.runTime),
    providersProvider.overrideWithBuild((_, _) => appState.providers),
    localIpProvider.overrideWithBuild((_, _) => appState.localIp),
    requestsProvider.overrideWithBuild((_, _) => appState.requests),
    versionProvider.overrideWithBuild((_, _) => appState.version),
    logsProvider.overrideWithBuild((_, _) => appState.logs),
    trafficsProvider.overrideWithBuild((_, _) => appState.traffics),
    totalTrafficProvider.overrideWithBuild((_, _) => appState.totalTraffic),
    realTunEnableProvider.overrideWithBuild((_, _) => appState.realTunEnable),
    systemUiOverlayStyleStateProvider.overrideWithBuild(
      (_, _) => appState.systemUiOverlayStyle,
    ),
    coreStatusProvider.overrideWithBuild((_, _) => appState.coreStatus),
  ];
}
