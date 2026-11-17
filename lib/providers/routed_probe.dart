import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'app.dart';
import 'core.dart';
import 'route_state.dart';

enum ProbePhase { empty, probing, fresh, failed }

@immutable
class ProbeEntry<V> {
  const ProbeEntry({required this.phase, this.value, this.stamp});

  final ProbePhase phase;
  final V? value;
  final RouteStamp? stamp;

  bool get isLoading => phase == ProbePhase.probing;

  @override
  bool operator ==(Object other) =>
      other is ProbeEntry<V> &&
      other.phase == phase &&
      other.value == value &&
      other.stamp == stamp;

  @override
  int get hashCode => Object.hash(phase, value, stamp);
}

@immutable
class RoutedProbeState<K, V> {
  const RoutedProbeState([this.entries = const {}]);

  final Map<K, ProbeEntry<V>> entries;

  ProbeEntry<V> entryOf(K target) =>
      entries[target] ?? ProbeEntry<V>(phase: ProbePhase.empty);

  V? valueOf(K target) => entries[target]?.value;

  bool isLoading(K target) => entryOf(target).isLoading;

  @override
  bool operator ==(Object other) =>
      other is RoutedProbeState<K, V> && mapEquals(other.entries, entries);

  @override
  int get hashCode => Object.hashAllUnordered(
    entries.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}

/// One probe answer before it is stamped. The counters are the Core's at
/// launch and stay null when the Core gave no answer at all.
class ProbeAnswer<V> {
  const ProbeAnswer({
    this.value,
    this.coreEpoch,
    this.routeVersion,
    this.hits = const [],
    this.timedOut = false,
  });

  final V? value;
  final int? coreEpoch;
  final int? routeVersion;
  final List<RouteHit> hits;
  final bool timedOut;
}

/// Keeps one answer per target and only ever shows one that still describes
/// the current route. A new route version only asks again for the answers
/// whose exits the Core finds moved, and a target asked on its own waits out
/// [throttleDuration] since its last probe. State changes are deferred to a
/// microtask, so a widget may watch a target from its build.
mixin RoutedProbe<K, V>
    on AnyNotifier<RoutedProbeState<K, V>, RoutedProbeState<K, V>> {
  static const _recheckDelays = [
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

  final Map<K, int> _watchers = {};
  final Map<K, _Due> _due = {};
  final Map<K, int> _inFlight = {};
  int _runs = 0;
  final Map<K, RouteState> _staleUnder = {};
  final Set<K> _unverified = {};
  final Map<K, _Landing<V>> _landed = {};
  final Map<K, Timer> _cooling = {};
  final Map<K, ({RouteStamp stamp, int step})> _failures = {};
  final Map<K, Timer> _retries = {};
  final Map<K, int> _launchPicks = {};
  bool _scheduled = false;
  bool _verifying = false;
  bool _reverify = false;
  Timer? _settle;
  Duration _settleLength = Duration.zero;
  RouteState _route = const RouteState();

  /// May also answer targets it was not asked for; a fresh one of those is
  /// taken in place of its own lookup.
  @protected
  Future<Map<K, ProbeAnswer<V>>> probe(K target, RouteState route);

  @protected
  bool isFailure(V value) => false;

  @protected
  bool get recheckFailures => false;

  @protected
  Duration get settleDuration => probeSettleDuration;

  @protected
  Duration get moveSettleDuration => probeMoveSettleDuration;

  @protected
  Duration get throttleDuration => probeThrottleDuration;

  @protected
  Duration get confirmDelay => probeConfirmDelay;

  @protected
  Future<RouteCheck> checkRoutes(List<List<RouteHit>> routes) async =>
      routeCheckOf(
        await ref.read(coreHandlerProvider).api.checkRoutes([
          for (final route in routes) route.map(routeHitDtoOf).toList(),
        ]),
      );

  @protected
  RoutedProbeState<K, V> buildProbe() {
    ref.onDispose(() {
      _settle?.cancel();
      _settle = null;
      for (final timer in [..._cooling.values, ..._retries.values]) {
        timer.cancel();
      }
      _cooling.clear();
      _retries.clear();
    });
    _route = ref.read(routeTrackerProvider);
    ref.listen(routeTrackerProvider, _onRoute);
    ref.listen(appVisibleProvider, (_, visible) {
      if (recheckFailures) {
        for (final MapEntry(key: target, value: failure) in _failures.entries) {
          if (!visible) {
            _retries.remove(target)?.cancel();
            if (_due[target]?.retry != null) _due.remove(target);
          } else if (!_inFlight.containsKey(target) &&
              !_due.containsKey(target) &&
              !_landed.containsKey(target)) {
            _armRetry(target, failure.step);
          }
        }
      }
      if (!visible) {
        return;
      }
      if (_due.isNotEmpty) {
        _schedule();
      }
      if (_unverified.isNotEmpty) {
        unawaited(_verify());
      }
    });
    return RoutedProbeState<K, V>();
  }

  void watch(K target) {
    final count = _watchers[target] ?? 0;
    _watchers[target] = count + 1;
    if (count > 0) {
      return;
    }
    if (_watchers.length == 1) {
      ref.read(routeTrackerProvider.notifier).attach();
    }
    if (_entryOf(target).phase != ProbePhase.fresh &&
        !_landed.containsKey(target)) {
      _mark(target);
    }
  }

  void unwatch(K target) {
    final count = _watchers[target];
    if (count == null) {
      return;
    }
    if (count > 1) {
      _watchers[target] = count - 1;
      return;
    }
    _watchers.remove(target);
    _failures.remove(target);
    _launchPicks.remove(target);
    final retry = _retries.remove(target);
    retry?.cancel();
    final due = _due[target];
    if (due != null && !due.forced) {
      _due.remove(target);
    }
    if (retry != null || due != null && !due.forced) {
      scheduleMicrotask(() => _forget(target));
    }
    if (_watchers.isEmpty && ref.mounted) {
      ref.read(routeTrackerProvider.notifier).detach();
    }
  }

  /// A re-probe dropped before it launched would leave its entry loading
  /// with nothing left to settle it.
  void _forget(K target) {
    if (!ref.mounted ||
        _watchers.containsKey(target) ||
        _due.containsKey(target) ||
        _inFlight.containsKey(target) ||
        _landed.containsKey(target) ||
        !_entryOf(target).isLoading) {
      return;
    }
    state = RoutedProbeState(Map.of(state.entries)..remove(target));
  }

  /// A refresh is the user asking, so it runs for targets nobody watches
  /// too, and waits neither for the route to settle nor for the throttle;
  /// the answer lands in the cache and stays until the route moves.
  void refresh(Iterable<K> targets) {
    for (final target in targets) {
      _mark(target, keepValue: true, forced: true);
    }
  }

  ProbeEntry<V> _entryOf(K target) => state.entryOf(target);

  void _mark(K target, {bool keepValue = false, bool forced = false}) {
    if (_inFlight.containsKey(target)) {
      return;
    }
    final previous = _due[target];
    _due[target] = (
      keepValue: keepValue || (previous?.keepValue ?? false),
      forced: forced || (previous?.forced ?? false),
      supersede: previous?.supersede ?? false,
      settle: false,
      retry: null,
    );
    _schedule();
  }

  void _schedule() {
    if (_scheduled) {
      return;
    }
    _scheduled = true;
    scheduleMicrotask(_launch);
  }

  void _launch() {
    _scheduled = false;
    if (!ref.mounted || !_route.live || !ref.read(appVisibleProvider)) {
      return;
    }
    final route = _route;
    final targets = <K>[];
    final cooled = <K>[];
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    final waiting = <K, _Due>{};
    for (final MapEntry(key: target, value: due) in _due.entries) {
      final wanted = due.forced || _watchers.containsKey(target);
      if (!wanted || (_inFlight.containsKey(target) && !due.supersede)) {
        continue;
      }
      final throttled =
          !due.forced &&
          !due.supersede &&
          due.retry != _Retry.confirm &&
          _cooling.containsKey(target) &&
          _launchPicks[target] == route.picks;
      if ((due.settle && _settle != null) || throttled) {
        waiting[target] = due;
        continue;
      }
      targets.add(target);
      _landed.remove(target);
      _unverified.remove(target);
      _retries.remove(target)?.cancel();
      _launchPicks[target] = route.picks;
      if (due.retry != _Retry.confirm) cooled.add(target);
      if (due.retry == null) {
        entries[target] = ProbeEntry(
          phase: ProbePhase.probing,
          value: due.keepValue ? entries[target]?.value : null,
        );
      }
    }
    _due
      ..clear()
      ..addAll(waiting);
    if (targets.isEmpty) {
      return;
    }
    state = RoutedProbeState(entries);
    final run = ++_runs;
    for (final target in targets) {
      _inFlight[target] = run;
    }
    for (final target in cooled) {
      _cool(target);
    }
    for (final target in targets) {
      unawaited(_run(target, route, run));
    }
  }

  void _cool(K target) {
    _cooling.remove(target)?.cancel();
    if (throttleDuration <= Duration.zero) {
      return;
    }
    _cooling[target] = Timer(throttleDuration, () {
      _cooling.remove(target);
      if (ref.mounted && _due.containsKey(target)) {
        _schedule();
      }
    });
  }

  /// A target a newer route asked again belongs to that run from then on.
  Future<void> _run(K target, RouteState route, int run) async {
    var answers = <K, ProbeAnswer<V>>{};
    try {
      answers = await probe(target, route);
    } catch (error) {
      commonPrint.log(
        'probe failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!ref.mounted || _inFlight[target] != run) {
      return;
    }
    _inFlight.remove(target);
    final current = _route;
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    final answer = answers[target] ?? const ProbeAnswer();
    final stamp = _stampOf(answer, route);
    if (!current.synced || current.hasMovedSince(stamp)) {
      // Stale twice under one route: the Core and host disagree.
      if (_staleUnder[target] != current) {
        _staleUnder[target] = current;
        _invalidate(target, entries);
      } else if (_watchers.containsKey(target)) {
        _show(
          target,
          ProbeEntry(phase: ProbePhase.failed, stamp: stamp),
          entries,
          timedOut: true,
        );
      } else {
        entries.remove(target);
      }
    } else {
      _staleUnder.remove(target);
      final settled = _settledEntry(answer.value, stamp);
      if (stamp.routeVersion == current.routeVersion) {
        _show(target, settled, entries, timedOut: answer.timedOut);
      } else {
        _landed[target] = (entry: settled, timedOut: answer.timedOut);
        _unverified.add(target);
      }
    }
    for (final MapEntry(key: other, value: answer) in answers.entries) {
      final value = answer.value;
      if (other == target || value == null || isFailure(value)) {
        continue;
      }
      final stamp = _stampOf(answer, route);
      if (!current.isFresh(stamp)) {
        continue;
      }
      _inFlight.remove(other);
      _due.remove(other);
      _landed.remove(other);
      _unverified.remove(other);
      _show(
        other,
        ProbeEntry(phase: ProbePhase.fresh, value: value, stamp: stamp),
        entries,
      );
    }
    state = RoutedProbeState(entries);
    if (current.isBehind(stamp)) {
      ref.read(routeTrackerProvider.notifier).resync();
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
    if (_landed.isNotEmpty) {
      unawaited(_verify());
    }
  }

  ProbeEntry<V> _settledEntry(V? value, RouteStamp stamp) {
    final failed = value == null || isFailure(value);
    return ProbeEntry(
      phase: failed ? ProbePhase.failed : ProbePhase.fresh,
      value: value,
      stamp: stamp,
    );
  }

  /// A failure back before its deadline may be the route settling or a
  /// connection something else closed, so it shows once a second one through
  /// the same exits agrees.
  void _show(
    K target,
    ProbeEntry<V> entry,
    Map<K, ProbeEntry<V>> entries, {
    bool timedOut = false,
  }) {
    _retries.remove(target)?.cancel();
    if (entry.phase != ProbePhase.failed) {
      _failures.remove(target);
      entries[target] = entry;
      return;
    }
    if (!_watchers.containsKey(target)) {
      entries[target] = entry;
      return;
    }
    final previous = _failures[target];
    final stamp = entry.stamp!;
    final agrees =
        previous != null &&
        previous.stamp.routeVersion == stamp.routeVersion &&
        _sameExits(previous.stamp.hits, stamp.hits);
    // Step zero waits for confirmation. A displayed failure advances to its next check.
    var step = 0;
    if (timedOut || agrees) {
      entries[target] = entry;
      step = agrees ? min(previous.step + 1, _recheckDelays.length) : 1;
    }
    _failures[target] = (stamp: stamp, step: step);
    _armRetry(target, step);
  }

  void _armRetry(K target, int step) {
    final retry = step == 0 ? _Retry.confirm : _Retry.recheck;
    if (retry == _Retry.recheck && !recheckFailures) return;
    if (recheckFailures && !ref.read(appVisibleProvider)) return;
    final delay = retry == _Retry.confirm
        ? confirmDelay
        : _recheckDelays[step - 1];
    _retries[target] = Timer(delay, () => _retry(target, retry));
  }

  void _retry(K target, _Retry retry) {
    _retries.remove(target);
    if (!ref.mounted ||
        !_watchers.containsKey(target) ||
        _inFlight.containsKey(target) ||
        _due.containsKey(target)) {
      return;
    }
    _due[target] = (
      keepValue: true,
      forced: false,
      supersede: false,
      settle: false,
      retry: retry,
    );
    _schedule();
  }

  void _forgetFailures(K target) {
    _failures.remove(target);
    _retries.remove(target)?.cancel();
  }

  RouteStamp _stampOf(ProbeAnswer<V> answer, RouteState route) => RouteStamp(
    coreEpoch: answer.coreEpoch ?? route.coreEpoch,
    routeVersion: answer.routeVersion ?? route.routeVersion,
    hostEpoch: route.hostEpoch,
    proxied: route.proxied,
    hits: answer.hits,
  );

  void _onRoute(RouteState? previous, RouteState next) {
    _route = next;
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    final resumed = previous != null && next.resumes != previous.resumes;
    final picked = previous != null && next.picks != previous.picks;
    final moved =
        previous != null &&
        (next.coreEpoch != previous.coreEpoch ||
            next.hostEpoch != previous.hostEpoch ||
            next.proxied != previous.proxied);
    for (final MapEntry(key: target, value: landed) in {..._landed}.entries) {
      if (next.hasMovedSince(landed.entry.stamp!)) {
        _invalidate(target, entries);
      }
    }
    if (moved) {
      // A failure waiting for its second attempt has no stamp to go by.
      for (final target in [..._retries.keys]) {
        _invalidate(target, entries);
      }
    } else if (picked) {
      // The user's own switch is no churn: asked now, once past the throttle.
      _settle?.cancel();
      _settle = null;
      final failed = [
        for (final MapEntry(:key, :value) in state.entries.entries)
          if (value.phase == ProbePhase.failed) key,
      ];
      for (final target in {..._retries.keys, ..._inFlight.keys, ...failed}) {
        if (_watchers.containsKey(target)) {
          _forgetFailures(target);
          _due[target] = (
            keepValue: true,
            forced: false,
            supersede: true,
            settle: false,
            retry: null,
          );
        }
      }
    }
    for (final MapEntry(key: target, value: entry) in state.entries.entries) {
      if (_inFlight.containsKey(target)) {
        if (moved) {
          _invalidate(target, entries);
        }
        continue;
      }
      final stamp = entry.stamp;
      if (stamp == null) {
        continue;
      }
      if (next.hasMovedSince(stamp)) {
        _invalidate(target, entries);
      } else if (resumed &&
          entry.phase == ProbePhase.failed &&
          _watchers.containsKey(target)) {
        _due[target] = (
          keepValue: false,
          forced: false,
          supersede: false,
          settle: false,
          retry: null,
        );
      } else if (stamp.routeVersion != next.routeVersion) {
        _unverified.add(target);
      }
    }
    if (moved && _settle != null) {
      _settleWithin(moveSettleDuration);
    }
    if (!mapEquals(entries, state.entries)) {
      state = RoutedProbeState(entries);
    }
    if (_unverified.isNotEmpty) {
      // Checked at once; moves within the window this opens wait for its end.
      if (_settle == null) {
        unawaited(_verify());
      }
      _settleWithin(settleDuration);
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
  }

  /// Answers the route moved under are checked in one call once it settles,
  /// except a fresh landing, which is held back until its own check.
  Future<void> _verify() async {
    if (_verifying) {
      _reverify = true;
      return;
    }
    if (!ref.mounted || !_route.live || !ref.read(appVisibleProvider)) {
      return;
    }
    final stamps = <K, RouteStamp>{};
    for (final target in {..._unverified}) {
      final landed = _landed.containsKey(target);
      if (!landed && _settle != null) {
        continue;
      }
      _unverified.remove(target);
      final stamp = (_landed[target]?.entry ?? state.entries[target])?.stamp;
      if (stamp != null && !_inFlight.containsKey(target)) {
        stamps[target] = stamp;
      }
    }
    if (stamps.isEmpty) {
      return;
    }
    _verifying = true;
    _reverify = false;
    RouteCheck? check;
    try {
      check = await checkRoutes([
        for (final stamp in stamps.values) stamp.hits,
      ]);
    } catch (error) {
      commonPrint.log(
        'route check failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    } finally {
      _verifying = false;
    }
    if (!ref.mounted) {
      return;
    }
    final current = _route;
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    for (final (index, MapEntry(key: target, value: stamp))
        in stamps.entries.indexed) {
      final landing = _landed[target];
      final entry = landing?.entry ?? entries[target];
      if (entry == null ||
          entry.stamp != stamp ||
          _inFlight.containsKey(target)) {
        continue;
      }
      _landed.remove(target);
      if (current.hasMovedSince(stamp)) {
        _invalidate(target, entries);
        continue;
      }
      // An unchanged exit cannot vouch for a failed dial through its front proxy.
      final held =
          check != null &&
          (entry.phase != ProbePhase.failed ||
              stamp.routeVersion ==
                  max(check.routeVersion, current.routeVersion)) &&
          check.coreEpoch == stamp.coreEpoch &&
          index < check.held.length &&
          check.held[index];
      if (!held) {
        _reprobe(target, entries);
        continue;
      }
      final verified = stamp.verifiedAt(
        max(stamp.routeVersion, check.routeVersion),
      );
      final checked = ProbeEntry(
        phase: entry.phase,
        value: entry.value,
        stamp: verified,
      );
      if (landing != null) {
        _show(target, checked, entries, timedOut: landing.timedOut);
      } else {
        entries[target] = checked;
      }
      if (verified.routeVersion != current.routeVersion &&
          verified.routeVersion > stamp.routeVersion) {
        _unverified.add(target);
      }
    }
    if (!mapEquals(entries, state.entries)) {
      state = RoutedProbeState(entries);
    }
    if (check != null &&
        (check.coreEpoch > current.coreEpoch ||
            check.routeVersion > current.routeVersion)) {
      ref.read(routeTrackerProvider.notifier).resync();
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
    if (_reverify) {
      unawaited(_verify());
    } else if (_unverified.isNotEmpty) {
      _settleWithin(settleDuration);
    }
  }

  /// Nothing made before a move stands, so the question waits for the
  /// route to settle and then overtakes any probe still out.
  void _invalidate(K target, Map<K, ProbeEntry<V>> entries) {
    _landed.remove(target);
    _unverified.remove(target);
    _forgetFailures(target);
    if (_watchers.containsKey(target)) {
      entries[target] = ProbeEntry(phase: ProbePhase.probing);
      _due[target] = (
        keepValue: false,
        forced: false,
        supersede: true,
        settle: true,
        retry: null,
      );
      _settleWithin(moveSettleDuration);
    } else {
      _inFlight.remove(target);
      entries.remove(target);
    }
  }

  void _reprobe(K target, Map<K, ProbeEntry<V>> entries) {
    _forgetFailures(target);
    if (_watchers.containsKey(target)) {
      entries[target] = ProbeEntry(phase: ProbePhase.probing);
      _due[target] = (
        keepValue: false,
        forced: false,
        supersede: false,
        settle: false,
        retry: null,
      );
    } else {
      entries.remove(target);
    }
  }

  void _settleWithin(Duration duration) {
    if (_settle != null && _settleLength <= duration) {
      return;
    }
    _settle?.cancel();
    _settleLength = duration;
    _settle = Timer(duration, _settled);
  }

  void _settled() {
    _settle = null;
    if (!ref.mounted) {
      return;
    }
    if (_unverified.isNotEmpty) {
      unawaited(_verify());
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
  }
}

bool _sameExits(List<RouteHit> previous, List<RouteHit> hits) {
  final exits = {for (final hit in previous) hit.host: hit.exit};
  return hits.every((hit) => (exits[hit.host] ?? hit.exit) == hit.exit);
}

/// Both keep the displayed verdict. Only confirmation can skip the throttle.
enum _Retry { confirm, recheck }

typedef _Due = ({
  bool keepValue,
  bool forced,
  bool supersede,
  bool settle,
  _Retry? retry,
});

typedef _Landing<V> = ({ProbeEntry<V> entry, bool timedOut});
