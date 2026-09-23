import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'app.dart';
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
    this.picksVersion,
    this.chains = const [],
  });

  final V? value;
  final int? coreEpoch;
  final int? picksVersion;
  final List<String> chains;
}

/// Keeps one answer per target and only ever shows one that still describes
/// the current route. State changes are deferred to a microtask, so a widget
/// may watch a target from its build.
mixin RoutedProbe<K, V>
    on AnyNotifier<RoutedProbeState<K, V>, RoutedProbeState<K, V>> {
  final Map<K, int> _watchers = {};
  final Map<K, ({bool keepValue, bool forced, bool supersede})> _due = {};
  final Map<K, int> _inFlight = {};
  int _runs = 0;
  final Map<K, RouteState> _staleUnder = {};
  bool _scheduled = false;
  RouteState _route = const RouteState();

  /// May also answer targets it was not asked for; a fresh one of those is
  /// taken in place of its own lookup.
  @protected
  Future<Map<K, ProbeAnswer<V>>> probe(List<K> targets, RouteState route);

  @protected
  bool get batched => false;

  @protected
  bool isFailure(V value) => false;

  @protected
  RoutedProbeState<K, V> buildProbe() {
    _route = ref.read(routeTrackerProvider);
    ref.listen(routeTrackerProvider, _onRoute);
    ref.listen(appVisibleProvider, (_, visible) {
      if (visible && _due.isNotEmpty) {
        _schedule();
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
    final phase = _entryOf(target).phase;
    if (phase == ProbePhase.empty || phase == ProbePhase.failed) {
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
    if (_due[target]?.forced != true) {
      _due.remove(target);
    }
    if (_watchers.isEmpty && ref.mounted) {
      ref.read(routeTrackerProvider.notifier).detach();
    }
  }

  void retry(K target) {
    if (_entryOf(target).phase == ProbePhase.failed) {
      _mark(target);
    }
  }

  /// A refresh is the user asking, so it runs for targets nobody watches
  /// too; the answer lands in the cache and stays until the route moves.
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
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    for (final MapEntry(key: target, value: due) in _due.entries) {
      final wanted = due.forced || _watchers.containsKey(target);
      if (!wanted || (_inFlight.containsKey(target) && !due.supersede)) {
        continue;
      }
      targets.add(target);
      entries[target] = ProbeEntry(
        phase: ProbePhase.probing,
        value: due.keepValue ? entries[target]?.value : null,
      );
    }
    _due.clear();
    if (targets.isEmpty) {
      return;
    }
    state = RoutedProbeState(entries);
    final run = ++_runs;
    for (final target in targets) {
      _inFlight[target] = run;
    }
    if (batched) {
      unawaited(_run(targets, route, run));
    } else {
      for (final target in targets) {
        unawaited(_run([target], route, run));
      }
    }
  }

  /// A target a newer route asked again belongs to that run from then on.
  Future<void> _run(List<K> targets, RouteState route, int run) async {
    var answers = <K, ProbeAnswer<V>>{};
    try {
      answers = await probe(targets, route);
    } catch (error) {
      commonPrint.log(
        'probe failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!ref.mounted) {
      return;
    }
    final owned = [
      for (final target in targets)
        if (_inFlight[target] == run) target,
    ];
    if (owned.isEmpty) {
      return;
    }
    owned.forEach(_inFlight.remove);
    final current = _route;
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    var behind = false;
    for (final target in owned) {
      final answer = answers[target] ?? const ProbeAnswer();
      final stamp = _stampOf(answer, route);
      if (!current.isFresh(stamp)) {
        behind = behind || current.isBehind(stamp);
        // A second stale answer under the same route means the Core and the
        // host disagree about it; asking again would loop until it moves.
        if (_staleUnder[target] != current) {
          _staleUnder[target] = current;
          _invalidate(target, entries);
        } else if (_watchers.containsKey(target)) {
          entries[target] = ProbeEntry(phase: ProbePhase.failed, stamp: stamp);
        } else {
          entries.remove(target);
        }
        continue;
      }
      _staleUnder.remove(target);
      final value = answer.value;
      final failed = value == null || isFailure(value);
      entries[target] = ProbeEntry(
        phase: failed ? ProbePhase.failed : ProbePhase.fresh,
        value: value,
        stamp: stamp,
      );
    }
    for (final MapEntry(key: target, value: answer) in answers.entries) {
      final value = answer.value;
      if (targets.contains(target) || value == null || isFailure(value)) {
        continue;
      }
      final stamp = _stampOf(answer, route);
      if (!current.isFresh(stamp)) {
        continue;
      }
      _inFlight.remove(target);
      _due.remove(target);
      entries[target] = ProbeEntry(
        phase: ProbePhase.fresh,
        value: value,
        stamp: stamp,
      );
    }
    state = RoutedProbeState(entries);
    if (behind) {
      ref.read(routeTrackerProvider.notifier).resync();
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
  }

  RouteStamp _stampOf(ProbeAnswer<V> answer, RouteState route) => RouteStamp(
    coreEpoch: answer.coreEpoch ?? route.coreEpoch,
    picksVersion: answer.picksVersion ?? route.picksVersion,
    hostEpoch: route.hostEpoch,
    proxied: route.proxied,
    chains: answer.chains,
  );

  void _onRoute(RouteState? previous, RouteState next) {
    _route = next;
    final entries = Map<K, ProbeEntry<V>>.of(state.entries);
    final resumed = previous != null && next.resumes != previous.resumes;
    // Picks flip whenever any url-test or fallback group re-picks, often
    // faster than a probe finishes; restarting on them would never let one
    // land. An answer's chain tells when it went through a group that moved.
    final moved =
        previous != null &&
        (next.coreEpoch != previous.coreEpoch ||
            next.hostEpoch != previous.hostEpoch ||
            next.proxied != previous.proxied);
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
      if (!next.isFresh(stamp)) {
        _invalidate(target, entries);
      } else if (resumed &&
          entry.phase == ProbePhase.failed &&
          _watchers.containsKey(target)) {
        _due[target] = (keepValue: false, forced: false, supersede: false);
      }
    }
    if (!mapEquals(entries, state.entries)) {
      state = RoutedProbeState(entries);
    }
    if (_due.isNotEmpty) {
      _schedule();
    }
  }

  /// A stale entry is asked again while someone watches it and forgotten
  /// otherwise; either way its old value is never shown.
  void _invalidate(K target, Map<K, ProbeEntry<V>> entries) {
    if (_watchers.containsKey(target)) {
      entries[target] = ProbeEntry(phase: ProbePhase.probing);
      _due[target] = (keepValue: false, forced: false, supersede: true);
    } else {
      _inFlight.remove(target);
      entries.remove(target);
    }
  }
}
