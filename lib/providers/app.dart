import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/app_icon.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@Riverpod(keepAlive: true)
bool safeMode(Ref ref) => safeModeBuild;

@Riverpod(keepAlive: true)
AppIconSource? packageIconSource(Ref ref) => app ?? DesktopAppIconSource();

/// The `user:password` this app's own requests present to the Core's proxy
/// listeners; the Core never intercepts a request that carries it.
@Riverpod(keepAlive: true)
String hostCredential(Ref ref) => '';

/// Android: su is there and granted FlClash's last request.
@Riverpod(keepAlive: true)
Future<bool> rootAccess(Ref ref) async {
  if (!system.isAndroid || app == null) {
    return false;
  }
  return app!.hasRootAccess();
}

@Riverpod(keepAlive: true)
class AuthorizedTunEnable extends _$AuthorizedTunEnable
    with AutoDisposeNotifierMixin {
  @override
  TunAuthorizationState build() {
    return TunAuthorizationState.none;
  }
}

/// Never saved, so the next launch tries TUN again.
@Riverpod(keepAlive: true)
class TunDisabledThisRun extends _$TunDisabledThisRun
    with AutoDisposeNotifierMixin {
  @override
  bool build() => false;
}

@Riverpod(keepAlive: true)
class UpdateDownloadState extends _$UpdateDownloadState
    with AutoDisposeNotifierMixin {
  @override
  UpdateDownload? build() => null;
}

@Riverpod(keepAlive: true)
class CoreCapabilitiesState extends _$CoreCapabilitiesState
    with AutoDisposeNotifierMixin {
  @override
  CoreCapabilities build() => const CoreCapabilities.everything();
}

/// The warnings of the config the Core last set up; they end with the Core.
@Riverpod(keepAlive: true)
class ConfigWarningsState extends _$ConfigWarningsState
    with AutoDisposeNotifierMixin {
  @override
  List<ConfigWarning> build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected && state.isNotEmpty) {
        state = const [];
      }
    });
    return const [];
  }

  void report(List<ConfigWarning> warnings) {
    if (ref.read(coreStatusProvider) == CoreStatus.disconnected) {
      return;
    }
    state = warnings;
  }
}

@riverpod
List<ConfigWarning> liveConfigWarnings(Ref ref) {
  final openLogs = ref.watch(
    appSettingProvider.select((settings) => settings.openLogs),
  );
  return openLogs
      ? ref.watch(configWarningsStateProvider.select((items) => items.warnings))
      : const [];
}

@Riverpod(keepAlive: true)
class CoreStopReason extends _$CoreStopReason with AutoDisposeNotifierMixin {
  @override
  String? build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.disconnected) {
        state = null;
      }
    });
    return null;
  }
}

@Riverpod(keepAlive: true)
class ServiceFaults extends _$ServiceFaults with AutoDisposeNotifierMixin {
  @override
  List<ServiceFault> build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected && state.isNotEmpty) {
        state = const [];
      }
    });
    return const [];
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
  ConnectionLog build() {
    return ConnectionLog(maxRequestsLength);
  }

  void _apply(ConnectionLog Function(ConnectionLog log) change) {
    if (!ref.mounted) {
      return;
    }
    value = change(state);
  }

  void addRequests(Iterable<TrackerInfo> values) =>
      _apply((log) => log.open(values));

  void updateTraffic(Map<int, RequestTraffic> traffic) =>
      _apply((log) => log.updateTraffic(traffic));

  void close(
    Iterable<int> ids, {
    DateTime? at,
    Map<int, ConnectionEnd> ends = const {},
  }) => _apply((log) => log.close(ids, at ?? DateTime.now(), ends: ends));

  void closeAll({DateTime? at}) =>
      _apply((log) => log.closeAll(at ?? DateTime.now()));

  void startOver() => _apply((log) => ConnectionLog(log.closedCapacity));

  /// False, writing nothing, once a new log has replaced [lineage].
  bool sync(
    List<TrackerInfo> open, {
    required DateTime requestedAt,
    required Object lineage,
  }) => _applyWithin(lineage, (log) => log.sync(open, requestedAt));

  bool poll(
    ConnectionPoll poll, {
    required DateTime requestedAt,
    required Object lineage,
  }) => _applyWithin(lineage, (log) => log.poll(poll, requestedAt));

  bool _applyWithin(
    Object lineage,
    ConnectionLog Function(ConnectionLog log) change,
  ) {
    if (!ref.mounted || !identical(state.lineage, lineage)) {
      return false;
    }
    value = change(state);
    return true;
  }
}

@Riverpod(keepAlive: true)
class DnsQueries extends _$DnsQueries with AutoDisposeNotifierMixin {
  @override
  FixedList<DnsQuery> build() {
    return FixedList(maxDnsQueriesLength);
  }

  void addQueries(Iterable<DnsQuery> values) {
    if (!ref.mounted) {
      return;
    }
    value = state.appendAll(values);
  }

  void startOver() {
    if (!ref.mounted) {
      return;
    }
    value = FixedList(state.maxLength);
  }
}

Duration? _noRetry(int retryCount, Object error) => null;

/// The rules the Core routes by, each named as a request names its rule;
/// listed again once a config is applied or the Core connects, never retried
/// before that.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<RuleTable> activeRules(Ref ref) {
  ref.listen(coreStatusProvider, (previous, next) {
    if (next == CoreStatus.connected && previous != CoreStatus.connected) {
      ref.invalidateSelf();
    }
  });
  return ref.read(coreHandlerProvider).api.getRules();
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
    value = await ref.read(coreHandlerProvider).api.getExternalProviders();
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

/// The opacity the sidebar keeps its own color at over the backdrop the native
/// window draws behind the content, or null while it draws none.
@Riverpod(keepAlive: true)
class WindowBlur extends _$WindowBlur with AutoDisposeNotifierMixin {
  @override
  double? build() {
    return null;
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

/// How many Core sessions have ended; each session numbers its connections
/// and requests from one again.
@Riverpod(keepAlive: true)
class EndedCoreSessions extends _$EndedCoreSessions {
  @override
  int build() {
    ref.listen(coreStatusProvider, (previous, next) {
      if (previous == CoreStatus.connected && next != CoreStatus.connected) {
        state++;
      }
    });
    return 0;
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
