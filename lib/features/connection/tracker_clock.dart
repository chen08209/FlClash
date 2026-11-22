import 'dart:async';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'tracker_texts.dart';

/// Ticks each second for the open connections shown under it, and only while
/// one of them is built, its page shows and the app is in the foreground.
class TrackerClock extends StatefulWidget {
  final Widget child;

  const TrackerClock({super.key, required this.child});

  static Listenable? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_TrackerClockScope>()?.clock;

  @override
  State<TrackerClock> createState() => _TrackerClockState();
}

class _TrackerClockState extends State<TrackerClock>
    with WidgetsBindingObserver {
  final _clock = _SecondClock();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _clock.resumed = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clock.shown = TickerMode.valuesOf(context).enabled;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _clock.resumed = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _TrackerClockScope(clock: _clock, child: widget.child);
}

class _TrackerClockScope extends InheritedWidget {
  final _SecondClock clock;

  const _TrackerClockScope({required this.clock, required super.child});

  @override
  bool updateShouldNotify(_TrackerClockScope oldWidget) => false;
}

class _SecondClock implements Listenable {
  final _ticks = StaggeredNotifier();
  Timer? _timer;
  var _shown = true;
  var _resumed = true;

  set shown(bool value) => _set(() => _shown = value);

  set resumed(bool value) => _set(() => _resumed = value);

  void _set(VoidCallback change) {
    final was = _timer != null;
    change();
    _update();
    if (!was && _timer != null) {
      _ticks.notify();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _ticks.addListener(listener);
    _update();
  }

  @override
  void removeListener(VoidCallback listener) {
    _ticks.removeListener(listener);
    _update();
  }

  void _update() {
    if (_ticks.hasListeners && _shown && _resumed) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => _ticks.notify(),
      );
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _ticks.dispose();
  }
}

class TrackerLifetime extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final Widget Function(String lifetime) builder;

  const TrackerLifetime({
    super.key,
    required this.trackerInfo,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final clock = trackerInfo.isActive ? TrackerClock.of(context) : null;
    if (clock == null) {
      return builder(trackerLifetimeText(trackerInfo, DateTime.now()));
    }
    return ListenableBuilder(
      listenable: clock,
      builder: (_, _) =>
          builder(trackerLifetimeText(trackerInfo, DateTime.now())),
    );
  }
}
