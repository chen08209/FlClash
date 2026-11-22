import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/banner.dart';

class CoreManager extends ConsumerStatefulWidget {
  final Widget child;

  /// Whether the connection feed stops being read while the app is out of
  /// sight. The platform decides when this is null.
  final bool? pausesInBackground;

  const CoreManager({
    super.key,
    required this.child,
    @visibleForTesting this.pausesInBackground,
  });

  @override
  ConsumerState<CoreManager> createState() => _CoreContainerState();
}

class _CoreContainerState extends ConsumerState<CoreManager>
    with WidgetsBindingObserver {
  CoreController get _core => ref.read(coreHandlerProvider);

  late final CounterDemand _demand = ref.read(connectionBookProvider).demand;

  final _feeds = <String, StreamSubscription<Object?>>{};
  StreamSubscription<String>? _crashes;
  bool _away = false;

  bool get _pausesInBackground => widget.pausesInBackground ?? system.isAndroid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _demand.addListener(_syncConnectionCounters);
    _crashes = _core.crashes.listen(_onCrash);
    ref.read(updatingActionProvider.notifier);
    // A rejected profile stays selected on purpose: silently reverting to
    // the previous one hides the error and looks like the switch was lost.
    ref.listenManual(currentProfileIdProvider, (prev, next) {
      if (prev == next) return;
      runAfterFrame(() {
        unawaited(ref.read(setupActionProvider.notifier).fullSetup());
      });
    });
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) {
        ref.read(setupActionProvider.notifier).updateConfigDebounce();
      }
    });
    ref.listenManual(setupPatchProvider, (prev, next) {
      if (prev != next) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    });
    ref.listenManual(globalRulesProvider, (prev, next) {
      if (prev?.value != null && next.hasValue) {
        ref.read(setupActionProvider.notifier).applyIfGlobalRulesUsed();
      }
    });
    ref.listenManual(
      patchClashConfigProvider.select((state) => state.mitm.enable),
      (prev, next) {
        if (prev == false && next) {
          unawaited(ref.read(mitmModulesActionProvider.notifier).autoUpdate());
        }
      },
    );
    ref.listenManual(mitmModulesProvider, (prev, next) {
      if (prev?.value != null &&
          next.hasValue &&
          ref.read(patchClashConfigProvider).mitm.enable) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    });
    ref.listenManual(appSettingProvider.select((state) => state.openLogs), (
      prev,
      next,
    ) {
      if (prev != next) {
        _syncLogFeed();
      }
    });
    ref.listenManual(coreStatusProvider, (prev, next) {
      if (next == CoreStatus.connected && prev != CoreStatus.connected) {
        _openFeeds();
      } else if (next != CoreStatus.connected) {
        _closeFeeds();
      }
      if (prev == CoreStatus.connected && next != CoreStatus.connected) {
        ref.read(requestsProvider.notifier).closeAll();
      }
    }, fireImmediately: true);
  }

  void _feed<T>(String name, Stream<T> stream, void Function(T value) onData) {
    unawaited(_feeds.remove(name)?.cancel());
    _feeds[name] = stream.listen(
      (value) {
        if (mounted) {
          onData(value);
        }
      },
      onError: (Object error) => commonPrint.log(
        '$name feed: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      ),
    );
  }

  void _openFeeds() {
    _closeFeeds();
    final api = _core.api;
    ref.read(connectionBookProvider).clear();
    ref.read(requestsProvider.notifier).startOver();
    ref.read(dnsQueriesProvider.notifier).startOver();
    _feed('dns', api.watchDns(), (entries) {
      ref
          .read(dnsQueriesProvider.notifier)
          .addQueries(entries.map(dnsQueryOf).toList());
      ref
          .read(dnsQueryCountProvider.notifier)
          .update((count) => count + entries.length);
    });
    _sync
      ..reset()
      ..onApplied = _resyncState
      ..onHeldPicks = _writeState;
    _feed('events', api.watchEvents(delays: true, state: true), (events) {
      events.forEach(_onEvent);
    });
    unawaited(_resyncState());
    _feed('engine', api.watchEngineStatus(), _onEngineStatus);
    _openConnections();
    _feed('proxies', api.watchProxies(), (_) {
      ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
    });
    _syncLogFeed();
  }

  /// Kept for the session: a new watch's snapshot misses what closed meanwhile.
  void _openConnections() {
    _feed(
      'connections',
      _core.api.watchConnections(maxBatchMs: 250, counters: false),
      _onConnections,
    );
    if (_away) {
      _feeds['connections']?.pause();
    }
    _syncConnectionCounters();
  }

  void _syncConnectionCounters() {
    if (!_feeds.containsKey('connections') ||
        _demand.wanted == _feeds.containsKey('counters')) {
      return;
    }
    if (!_demand.wanted) {
      unawaited(_feeds.remove('counters')?.cancel());
      return;
    }
    _feed(
      'counters',
      _core.api.watchConnections(maxBatchMs: 250, counters: true),
      _onCounters,
    );
    if (_away) {
      _feeds['counters']?.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final away =
        _pausesInBackground &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);
    if (away == _away) {
      return;
    }
    _away = away;
    for (final name in const ['connections', 'counters']) {
      if (away) {
        _feeds[name]?.pause();
      } else {
        _feeds[name]?.resume();
      }
    }
  }

  void _closeFeeds() {
    for (final feed in _feeds.values) {
      unawaited(feed.cancel());
    }
    _feeds.clear();
  }

  void _syncLogFeed() {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    if (ref.read(appSettingProvider).openLogs) {
      _feed('logs', _core.api.watchLogs(), (entries) {
        entries.map(logOf).forEach(_onLog);
      });
    } else {
      unawaited(_feeds.remove('logs')?.cancel());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _demand.removeListener(_syncConnectionCounters);
    unawaited(_crashes?.cancel());
    _closeFeeds();
    super.dispose();
  }

  void _onEvent(CoreEventDto event) {
    switch (event) {
      case DelayEvent(:final result):
        ref.read(proxiesActionProvider.notifier).setDelay(delayOf(result));
      case ResourceUpdateEvent(
        kind: ResourceKind.geo,
        :final name,
        :final phase,
        :final error,
      ):
        ref
            .read(geoResourceActionProvider.notifier)
            .handleCoreUpdate(name, phase, error);
      case ResourceUpdateEvent(kind: ResourceKind.mitmModule):
        ref.invalidate(mitmModuleStatusProvider);
      case ResourceUpdateEvent(
        :final name,
        phase: ResourcePhase.updated || ResourcePhase.unchanged,
      ):
        unawaited(_onLoaded(name));
      case ResourceUpdateEvent():
        break;
      case final StateChangedEvent event:
        _writeState(_sync.take(event));
      case DialerLoopEvent(:final name):
        _onDialerLoop(name);
      case final ScriptNotificationEvent notice:
        _onScriptNotification(notice);
      case EventsResynced():
        unawaited(_onResynced());
        unawaited(_resyncState());
      case UnknownCoreEvent():
        break;
    }
  }

  Future<void> _onResynced() async {
    ref.read(geoResourceActionProvider.notifier).forgetUpdates();
    ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
    await ref.read(providersProvider.notifier).syncProviders();
  }

  CoreStateSync get _sync => ref.read(coreStateSyncProvider);

  Future<void> _resyncState() async {
    if (!mounted) {
      return;
    }
    final generation = _sync.resync();
    try {
      final state = await _core.api.general();
      if (mounted) {
        _writeState(_sync.settle(generation, state));
      }
    } catch (error) {
      if (error is CoreMethodException && error.code == 'conflict') {
        // No config applied yet; the baseline after the first apply follows.
        return;
      }
      commonPrint.log(
        'config.general: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  void _writeState(List<StateWrite> writes) {
    for (final write in writes) {
      switch (write) {
        case SelectionWrite(:final group, :final proxy):
          final profileId =
              _sync.profileId ?? ref.read(currentProfileIdProvider);
          if (profileId != null) {
            ref
                .read(profilesActionProvider.notifier)
                .setSelection(profileId, group, proxy);
          }
        case GeneralWrite(:final change):
          ref.read(setupActionProvider.notifier).adoptCoreGeneral(change);
      }
    }
  }

  void _onConnections(ConnectionUpdate update) {
    final change = ref.read(connectionBookProvider).apply(update);
    final requests = ref.read(requestsProvider.notifier);
    if (change.opened.isNotEmpty) {
      requests.addRequests(change.opened);
      ref
          .read(requestCountProvider.notifier)
          .update((count) => count + change.opened.length);
    }
    if (change.counters.isNotEmpty) {
      requests.updateTraffic(change.counters);
    }
    if (change.closed.isNotEmpty) {
      requests.close(change.closed, ends: change.ended);
    }
  }

  void _onCounters(ConnectionUpdate update) {
    final counters = ref.read(connectionBookProvider).countersOf(update);
    if (counters.isNotEmpty) {
      ref.read(requestsProvider.notifier).updateTraffic(counters);
    }
  }

  Future<void> _onLoaded(String providerName) async {
    final provider = await _core.api.getExternalProvider(providerName);
    if (!mounted) {
      return;
    }
    ref.read(providersProvider.notifier).setProvider(provider);
  }

  void _onLog(Log log) {
    ref.read(logsProvider.notifier).add(log);
    if (log.logLevel == LogLevel.error) {
      throttler.call(
        FunctionTag.coreErrorNotifier,
        () => dialogs.showBanner(log.payload, level: BannerLevel.error),
        duration: const Duration(seconds: 3),
        fire: true,
      );
    }
  }

  void _onEngineStatus(EngineStatus status) {
    ref.read(serviceFaultsProvider.notifier).value = status.faults;
    final tunFault = status.faults
        .where((fault) => fault.service == FaultService.tun)
        .firstOrNull;
    final tunDisabled = ref.read(tunDisabledThisRunProvider.notifier);
    if (tunFault == null ||
        system.isAndroid ||
        tunDisabled.value ||
        !ref.read(patchClashConfigProvider).tun.enable) {
      return;
    }
    tunDisabled.value = true;
    dialogs.showBanner(
      '${currentAppLocalizations.tunStartFailed}\n${tunFault.reasonLabel}',
      level: BannerLevel.error,
    );
  }

  void _onDialerLoop(String proxyName) {
    throttler.call(
      FunctionTag.dialerLoopNotifier,
      () => dialogs.showBanner(
        currentAppLocalizations.dialerProxyLoopStopped(proxyName),
        level: BannerLevel.error,
      ),
      duration: const Duration(seconds: 3),
      fire: true,
    );
  }

  void _onScriptNotification(ScriptNotificationEvent notice) {
    if (notice.text.isEmpty ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final link = scriptNotificationLink(notice.url);
    throttler.call(
      FunctionTag.scriptNotification,
      () => dialogs.showBanner(
        currentAppLocalizations.scriptNotification(notice.script, notice.text),
        onTap: link == null
            ? null
            : () => unawaited(dialogs.openUrl(link.toString())),
      ),
      duration: const Duration(seconds: 1),
      fire: true,
    );
  }

  void _onCrash(String message) {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    ref.read(coreStopReasonProvider.notifier).value = message;
    ref.read(setupActionProvider.notifier).onCoreLost();
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      dialogs.showBanner(message, level: BannerLevel.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Uri? scriptNotificationLink(String url) {
  final link = Uri.tryParse(url);
  return link != null &&
          (link.isScheme('http') || link.isScheme('https')) &&
          link.host.isNotEmpty
      ? link
      : null;
}
