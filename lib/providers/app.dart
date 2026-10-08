import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@Riverpod(keepAlive: true)
bool safeMode(Ref ref) => safeModeBuild;

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
    return FixedList(maxLogsLength);
  }

  void add(Log value) {
    if (!ref.mounted) {
      return;
    }
    this.value = state.append(value);
  }

  Future<bool> exportLogs() async {
    final logString = await encodeLogsTask(value.list);
    final tempFilePath = await appPath.tempFilePath;
    final file = File(tempFilePath);
    await file.safeWriteAsString(logString);
    bool res = false;
    res = await picker.saveFileWithPath(logFileName, tempFilePath) != null;
    return res;
  }
}

@Riverpod(keepAlive: true)
class Requests extends _$Requests with AutoDisposeNotifierMixin {
  @override
  FixedList<TrackerInfo> build() {
    return FixedList(maxRequestsLength);
  }

  void addRequest(TrackerInfo value) {
    if (!ref.mounted) {
      return;
    }
    this.value = state.append(value);
  }
}

@Riverpod(keepAlive: true)
class DnsQueries extends _$DnsQueries with AutoDisposeNotifierMixin {
  @override
  FixedList<DnsQuery> build() {
    return FixedList(maxDnsQueriesLength);
  }

  void addQuery(DnsQuery value) {
    if (!ref.mounted) {
      return;
    }
    this.value = state.append(value);
  }
}

@Riverpod(keepAlive: true)
class DnsQueryCount extends _$DnsQueryCount with AutoDisposeNotifierMixin {
  @override
  int build() {
    return 0;
  }
}

@Riverpod(keepAlive: true)
class RequestCount extends _$RequestCount with AutoDisposeNotifierMixin {
  @override
  int build() {
    return 0;
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
    value = await ref.read(coreHandlerProvider).getExternalProviders();
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
    return FixedList(trafficSampleLength);
  }

  void addTraffic(Traffic value) {
    if (!ref.mounted) {
      return;
    }
    this.value = state.append(value);
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
class LoadedLocale extends _$LoadedLocale with AutoDisposeNotifierMixin {
  @override
  Locale? build() {
    return null;
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

/// What the running Android service was started with: it builds the tunnel
/// once, so a later change waits for a restart.
@Riverpod(keepAlive: true)
class RunningVpnOptions extends _$RunningVpnOptions
    with AutoDisposeNotifierMixin {
  @override
  VpnOptions? build() {
    return null;
  }
}

/// False while the window is hidden or the Android activity is in the
/// background; work that only feeds the UI waits for it to come back.
@Riverpod(keepAlive: true)
class AppVisible extends _$AppVisible with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return true;
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

/// Whether the native window currently draws a backdrop behind the content.
@Riverpod(keepAlive: true)
class WindowBlur extends _$WindowBlur with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
double viewWidth(Ref ref) {
  return ref.watch(viewSizeProvider).width;
}

@Riverpod(keepAlive: true)
ViewMode viewMode(Ref ref) {
  return getViewMode(ref.watch(viewWidthProvider));
}

@Riverpod(keepAlive: true)
bool isMobileView(Ref ref) {
  return ref.watch(viewModeProvider) == ViewMode.mobile;
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
  DelayMap? _owned;
  DelayMap? _published;

  @override
  DelayMap build() {
    return {};
  }

  void setDelay(Delay delay) {
    setDelays([delay]);
  }

  /// Publishes a live view, so a dependent that keeps the map must copy it.
  void setDelays(Iterable<Delay> delays) {
    final delayMap = _ownedDelayMap();
    var changed = false;
    for (final delay in delays) {
      if (delayMap[delay.url]?[delay.name] == delay.value) {
        continue;
      }
      (delayMap[delay.url] ??= {})[delay.name] = delay.value;
      changed = true;
    }
    if (changed) {
      value = _published = UnmodifiableMapView(delayMap);
    }
  }

  DelayMap _ownedDelayMap() {
    final owned = _owned;
    if (owned != null && identical(state, _published)) {
      return owned;
    }
    return _owned = {
      for (final entry in state.entries) entry.key: {...entry.value},
    };
  }
}

@Riverpod(keepAlive: true)
class PendingDelayTests extends _$PendingDelayTests
    with AutoDisposeNotifierMixin {
  final Map<String, int> _holds = {};
  final Map<String, int> _runs = {};
  final Map<String, DelayTestPhase> _phases = {};

  @override
  Map<String, DelayTestPhase> build() {
    return const <String, DelayTestPhase>{};
  }

  /// [finished] keys had started, so they give up their run as well as their
  /// hold; [released] keys never started.
  void apply({
    Iterable<String> acquired = const [],
    Iterable<String> started = const [],
    Iterable<String> finished = const [],
    Iterable<String> released = const [],
  }) {
    final touched = <String>{};
    for (final key in acquired) {
      _holds[key] = (_holds[key] ?? 0) + 1;
      touched.add(key);
    }
    for (final key in started) {
      if (_holds.containsKey(key)) {
        _runs[key] = (_runs[key] ?? 0) + 1;
        touched.add(key);
      }
    }
    for (final key in finished) {
      _decrement(_runs, key);
      _decrement(_holds, key);
      touched.add(key);
    }
    for (final key in released) {
      _decrement(_holds, key);
      touched.add(key);
    }
    var changed = false;
    for (final key in touched) {
      final phase = !_holds.containsKey(key)
          ? null
          : _runs.containsKey(key)
          ? DelayTestPhase.running
          : DelayTestPhase.queued;
      if (_phases[key] == phase) {
        continue;
      }
      if (phase == null) {
        _phases.remove(key);
      } else {
        _phases[key] = phase;
      }
      changed = true;
    }
    if (changed) {
      _publish();
    }
  }

  void clear() {
    if (_holds.isEmpty) {
      return;
    }
    _holds.clear();
    _runs.clear();
    _phases.clear();
    _publish();
  }

  void _decrement(Map<String, int> counts, String key) {
    final count = counts[key];
    if (count == null) {
      return;
    }
    if (count > 1) {
      counts[key] = count - 1;
    } else {
      counts.remove(key);
    }
  }

  // A copy per publish would make a run over n nodes O(n²). The view is live,
  // so a dependent selects what it needs instead of keeping the map.
  void _publish() {
    value = UnmodifiableMapView(_phases);
  }
}

@Riverpod(keepAlive: true)
class DelayTestingGroups extends _$DelayTestingGroups
    with AutoDisposeNotifierMixin {
  @override
  Set<String> build() {
    return const <String>{};
  }

  bool start(String groupName) {
    if (value.contains(groupName)) {
      return false;
    }
    value = {...value, groupName};
    return true;
  }

  void stop(String groupName) {
    if (!value.contains(groupName)) {
      return;
    }
    value = {...value}..remove(groupName);
  }
}

@Riverpod(keepAlive: true)
class HotKeyFailures extends _$HotKeyFailures with AutoDisposeNotifierMixin {
  @override
  Map<HotAction, String> build() {
    return const {};
  }
}

@Riverpod(keepAlive: true)
class HotKeyRecording extends _$HotKeyRecording with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
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
    ref.onDispose(() {
      _timer?.cancel();
    });
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

@Riverpod(keepAlive: true)
class UpdatingKeys extends _$UpdatingKeys {
  final _operations = <String, Set<int>>{};
  final _scopes = <String, UpdatingScope>{};
  int _operation = 0;

  @override
  Set<String> build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected) {
        _discardScope(UpdatingScope.core);
      }
    });
    return const <String>{};
  }

  int start(String key, {UpdatingScope scope = UpdatingScope.local}) {
    final operation = ++_operation;
    _operations.putIfAbsent(key, () => <int>{}).add(operation);
    _scopes[key] = scope;
    if (!state.contains(key)) {
      state = {...state, key};
    }
    return operation;
  }

  void stop(String key, int operation) {
    final operations = _operations[key];
    if (operations == null) {
      return;
    }
    operations.remove(operation);
    if (operations.isNotEmpty) {
      return;
    }
    _discard([key]);
  }

  void stopKeys(Iterable<String> keys) {
    _discard(keys.toList());
  }

  UpdatingScope? scopeOf(String key) => _scopes[key];

  void _discardScope(UpdatingScope scope) {
    _discard(state.where((key) => _scopes[key] == scope).toList());
  }

  void _discard(List<String> keys) {
    if (keys.isEmpty) {
      return;
    }
    for (final key in keys) {
      _operations.remove(key);
      _scopes.remove(key);
    }
    final next = state.where((key) => !keys.contains(key)).toSet();
    if (next.length == state.length) {
      return;
    }
    state = next;
  }
}

@riverpod
bool isUpdating(Ref ref, String name) {
  return ref.watch(updatingKeysProvider).contains(name);
}

@Riverpod(keepAlive: true)
class CurrentSSID extends _$CurrentSSID with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return null;
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
