import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

part 'generated/app.g.dart';

@Riverpod(keepAlive: true)
class AuthorizedTunEnable extends _$AuthorizedTunEnable
    with AutoDisposeNotifierMixin {
  @override
  TunAuthorizationState build() {
    return TunAuthorizationState.none;
  }
}

@Riverpod(keepAlive: true)
class Logs extends _$Logs with AutoDisposeNotifierMixin {
  @override
  FixedList<Log> build() {
    return FixedList(0);
  }

  void add(Log value) {
    if (!ref.mounted) {
      return;
    }
    this.value = state.copyWith()..add(value);
  }

  Future<bool> exportLogs() async {
    final logString = await encodeLogsTask(value.list);
    final tempFilePath = await appPath.tempFilePath;
    final file = File(tempFilePath);
    await file.safeWriteAsString(logString);
    bool res = false;
    res = await picker.saveFileWithPath(utils.logFile, tempFilePath) != null;
    return res;
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

  Future<void> syncProviders() async {
    value = await coreController.getExternalProviders();
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
    return const Traffic();
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

  void toPage(PageLabel pageLabel) {
    value = pageLabel;
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
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
    return const SystemUiOverlayStyle();
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
class Items extends _$Items with AutoDisposeNotifierMixin {
  @override
  Set<dynamic> build(String key) {
    return {};
  }
}

@riverpod
class Item extends _$Item with AutoDisposeNotifierMixin {
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
  static const _timeoutDisplayDelay = Duration(seconds: 2);

  bool? _preIsStart;
  CancelToken? _cancelToken;
  Timer? _timeoutTimer;
  int _checkVersion = 0;

  @override
  NetworkDetectionState build() {
    ref.onDispose(() {
      _resetCheckSession(null);
    });
    return const NetworkDetectionState(isLoading: true, ipInfo: null);
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
    final cancelToken = CancelToken();
    final version = _resetCheckSession(cancelToken);
    commonPrint.log('checkIp start');
    state = state.copyWith(isLoading: true, ipInfo: null);
    _preIsStart = isStart;
    final res = await request.checkIp(cancelToken: cancelToken);
    commonPrint.log('checkIp res: $res');

    if (!ref.mounted ||
        version != _checkVersion ||
        cancelToken != _cancelToken) {
      return;
    }
    final ipInfo = res.data;
    if (ipInfo == null) {
      _delayTimeoutDisplay(version);
      return;
    }
    state = state.copyWith(isLoading: false, ipInfo: ipInfo);
  }

  int _resetCheckSession(CancelToken? cancelToken) {
    _cancelTimeoutTimer();
    final version = ++_checkVersion;
    final previousCancelToken = _cancelToken;
    _cancelToken = cancelToken;
    previousCancelToken?.cancel();
    return version;
  }

  void _delayTimeoutDisplay(int version) {
    _cancelTimeoutTimer();
    _timeoutTimer = Timer(_timeoutDisplayDelay, () {
      _timeoutTimer = null;
      if (!ref.mounted || version != _checkVersion || state.ipInfo != null) {
        return;
      }
      state = state.copyWith(isLoading: false, ipInfo: null);
    });
  }

  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }
}

@Riverpod(keepAlive: true)
class CurrentSSID extends _$CurrentSSID with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return null;
  }
}

@Riverpod(keepAlive: true)
class BatteryOptimizationDisable extends _$BatteryOptimizationDisable
    with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
class LocationPermissions extends _$LocationPermissions
    with AutoDisposeNotifierMixin {
  @override
  WifiSsidPermission build() {
    return WifiSsidPermission.denied;
  }
}

List<Override> buildAppStateOverrides(AppState appState) {
  return [
    initProvider.overrideWithBuild((_, _) => appState.isInit),
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
    authorizedTunEnableProvider.overrideWithBuild(
      (_, _) => appState.authorizedTunEnable,
    ),
    systemUiOverlayStyleStateProvider.overrideWithBuild(
      (_, _) => appState.systemUiOverlayStyle,
    ),
    coreStatusProvider.overrideWithBuild((_, _) => appState.coreStatus),
  ];
}
