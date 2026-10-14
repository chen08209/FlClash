import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'core.dart';
import 'state.dart';

part 'generated/route_state.g.dart';

/// What a probe answer is judged against. Nothing is fresh until the Core's
/// counters have been read, otherwise every answer would fail the epoch
/// check and be asked again forever.
@immutable
class RouteState {
  const RouteState({
    this.coreEpoch = 0,
    this.picksVersion = 0,
    this.picks = const {},
    this.hostEpoch = 0,
    this.proxied = false,
    this.synced = false,
    this.live = false,
    this.resumes = 0,
  });

  final int coreEpoch;
  final int picksVersion;
  final Map<String, String> picks;
  final int hostEpoch;
  final bool proxied;
  final bool synced;
  final bool live;
  final int resumes;

  RouteState copyWith({
    int? coreEpoch,
    int? picksVersion,
    Map<String, String>? picks,
    int? hostEpoch,
    bool? proxied,
    bool? synced,
    bool? live,
    int? resumes,
  }) {
    return RouteState(
      coreEpoch: coreEpoch ?? this.coreEpoch,
      picksVersion: picksVersion ?? this.picksVersion,
      picks: picks ?? this.picks,
      hostEpoch: hostEpoch ?? this.hostEpoch,
      proxied: proxied ?? this.proxied,
      synced: synced ?? this.synced,
      live: live ?? this.live,
      resumes: resumes ?? this.resumes,
    );
  }

  /// A chain stays fresh while every group on it still picks the hop below
  /// it; groups the picks do not name, load balancers among them, cannot
  /// contradict it. An answer with no chain is tied to the selection version
  /// it was made under instead.
  bool isFresh(RouteStamp stamp) {
    if (!synced ||
        stamp.coreEpoch != coreEpoch ||
        stamp.hostEpoch != hostEpoch ||
        stamp.proxied != proxied) {
      return false;
    }
    final chains = stamp.chains;
    if (chains.isEmpty) {
      return stamp.picksVersion == picksVersion;
    }
    for (var i = chains.length - 1; i >= 1; i--) {
      final next = picks[chains[i]];
      if (next != null && next != chains[i - 1]) {
        return false;
      }
    }
    return true;
  }

  bool isBehind(RouteStamp stamp) =>
      stamp.coreEpoch > coreEpoch || stamp.picksVersion > picksVersion;

  @override
  bool operator ==(Object other) =>
      other is RouteState &&
      other.coreEpoch == coreEpoch &&
      other.picksVersion == picksVersion &&
      mapEquals(other.picks, picks) &&
      other.hostEpoch == hostEpoch &&
      other.proxied == proxied &&
      other.synced == synced &&
      other.live == live &&
      other.resumes == resumes;

  @override
  int get hashCode => Object.hash(
    coreEpoch,
    picksVersion,
    Object.hashAllUnordered(
      picks.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    hostEpoch,
    proxied,
    synced,
    live,
    resumes,
  );
}

/// The route a probe answer was produced under: the Core's counters when it
/// started, the host's when it was sent, and the chain it went through.
@immutable
class RouteStamp {
  const RouteStamp({
    required this.coreEpoch,
    required this.picksVersion,
    required this.hostEpoch,
    required this.proxied,
    this.chains = const [],
  });

  final int coreEpoch;
  final int picksVersion;
  final int hostEpoch;
  final bool proxied;
  final List<String> chains;

  @override
  bool operator ==(Object other) =>
      other is RouteStamp &&
      other.coreEpoch == coreEpoch &&
      other.picksVersion == picksVersion &&
      other.hostEpoch == hostEpoch &&
      other.proxied == proxied &&
      listEquals(other.chains, chains);

  @override
  int get hashCode => Object.hash(
    coreEpoch,
    picksVersion,
    hostEpoch,
    proxied,
    Object.hashAll(chains),
  );
}

@Riverpod(keepAlive: true)
class RouteTracker extends _$RouteTracker {
  static const _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
  ];

  int _watchers = 0;
  int _generation = 0;
  bool _syncing = false;
  bool _resubscribe = false;
  Timer? _retry;
  int _failures = 0;

  @override
  RouteState build() {
    ref.onDispose(_cancelRetry);
    ref.listen(isStartProvider, (_, _) => _scheduleSyncProxied());
    ref.listen(suspendProvider, (_, _) => _scheduleSyncProxied());
    ref.listen(initProvider, (_, _) => _subscribe());
    ref.listen(appVisibleProvider, (_, visible) {
      if (visible) {
        _subscribe();
      } else if (_watchers > 0) {
        _unsubscribe();
      }
    });
    ref.listen(coreStatusProvider, (_, status) {
      if (status == CoreStatus.connected) {
        _subscribe();
      } else {
        _dropSync();
      }
    });
    return RouteState(proxied: _proxied);
  }

  bool get _proxied => ref.read(isStartProvider) && !ref.read(suspendProvider);

  bool get _ready =>
      _watchers > 0 &&
      ref.read(appVisibleProvider) &&
      ref.read(initProvider) &&
      ref.read(coreStatusProvider) == CoreStatus.connected;

  void attach() {
    if (++_watchers == 1) {
      _subscribe();
    }
  }

  void detach() {
    if (_watchers == 0) {
      return;
    }
    if (--_watchers == 0) {
      _unsubscribe();
    }
  }

  /// Reads the Core's counters again; a cache asks for this when an answer
  /// carries a newer epoch than the state, which means an event was missed.
  void resync() => _subscribe();

  void applySnapshot(RouteSnapshot snapshot) {
    state = state.copyWith(
      coreEpoch: snapshot.coreEpoch,
      picksVersion: snapshot.picksVersion,
      picks: snapshot.picks,
      hostEpoch: state.synced ? state.hostEpoch : state.hostEpoch + 1,
      synced: true,
      live: true,
    );
  }

  void bumpHostEpoch() {
    state = state.copyWith(hostEpoch: state.hostEpoch + 1);
  }

  void markResumed() {
    state = state.copyWith(resumes: state.resumes + 1);
  }

  /// Deferred because both are computed: unwatched, they go stale, and the
  /// widget that next reads one recomputes it from initState or build.
  void _scheduleSyncProxied() {
    scheduleMicrotask(() {
      if (ref.mounted) {
        _syncProxied();
      }
    });
  }

  void _syncProxied() {
    final proxied = _proxied;
    if (proxied != state.proxied) {
      state = state.copyWith(proxied: proxied);
    }
  }

  Future<void> _subscribe() async {
    _retry?.cancel();
    if (!_ready) {
      return;
    }
    if (_syncing) {
      _resubscribe = true;
      return;
    }
    _syncing = true;
    _resubscribe = false;
    final generation = ++_generation;
    RouteSnapshot? snapshot;
    try {
      snapshot = await ref.read(coreHandlerProvider).watchRoute(true);
    } catch (error) {
      commonPrint.log(
        'watchRoute failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    } finally {
      _syncing = false;
    }
    if (!ref.mounted) {
      return;
    }
    if (generation == _generation) {
      if (snapshot != null) {
        _failures = 0;
        applySnapshot(snapshot);
      } else if (!_resubscribe) {
        _retryLater();
      }
    }
    if (_resubscribe) {
      unawaited(_subscribe());
    }
  }

  void _retryLater() {
    final delay = _retryDelays[_failures.clamp(0, _retryDelays.length - 1)];
    _failures++;
    _retry = Timer(delay, () => unawaited(_subscribe()));
  }

  void _cancelRetry() {
    _retry?.cancel();
    _retry = null;
    _failures = 0;
  }

  /// Deferred because a widget releases its target from dispose.
  void _unsubscribe() {
    _cancelRetry();
    final generation = ++_generation;
    scheduleMicrotask(() {
      if (ref.mounted && generation == _generation && state.live) {
        state = state.copyWith(live: false);
      }
    });
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    unawaited(
      ref.read(coreHandlerProvider).watchRoute(false).catchError((
        Object error,
      ) {
        commonPrint.log(
          'watchRoute release failed: $error',
          logLevel: coreFailureLogLevel(error),
        );
        return null;
      }),
    );
  }

  void _dropSync() {
    _cancelRetry();
    _generation++;
    if (state.synced || state.live) {
      state = state.copyWith(synced: false, live: false);
    }
  }
}
