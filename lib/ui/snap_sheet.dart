import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/scroll_behavior.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';
import 'sheet.dart';
import 'sheet_navigator.dart';

/// Receives the sheet's own scroll controller, or null where the sheet has no
/// detents to drag between and the content keeps its own controller.
typedef SnapSheetBuilder =
    Widget Function(BuildContext context, ScrollController? controller);

/// The heights a snap sheet rests at, as a fraction of the space it gets.
const snapSheetDetents = [9 / 16, 0.9];

/// UIKit's presentation spring, mass 3 and stiffness 1000, which iOS 27 runs
/// critically damped for every move of a sheet.
const _stiffness = 1000 / 3;

final _omega = math.sqrt(_stiffness);

/// A sheet thrown at its detent overshoots it slightly on iOS.
const _thrownRatio = 0.8;
const _fullThrow = 0.3;
const _hardestThrow = 0.75;

/// UIScrollView.DecelerationRate.fast, which iOS projects a release with.
const _projectionTime = 0.99 / (1 - 0.99) / 1000;

const _settleTolerance = Tolerance(distance: 0.5, velocity: 10);

const _peakEase = 120.0;

/// [_settleTolerance] for a sheet about 500 pixels tall, in UIKit's 0.5 s.
const _presentationTolerance = Tolerance(distance: 0.001, velocity: 0.02);

/// Wheel events closer together than this are one turn of the wheel, the
/// span Chromium latches a wheel sequence to one scroller for.
const _wheelTurnGap = Duration(milliseconds: 500);

class SnapSheetRoute<T> extends PopupRoute<T> with SheetCoverRouteMixin<T> {
  SnapSheetRoute({
    required this.builder,
    required this.sheetBarrierColor,
    required this.barrierLabel,
    this.detents = snapSheetDetents,
    this.fitsContent = false,
    this.initialScrollOffset = 0,
  });

  final SnapSheetBuilder builder;
  final Color sheetBarrierColor;
  final List<double> detents;

  final bool fitsContent;

  final double initialScrollOffset;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => sheetBarrierColor;

  @override
  bool get barrierDismissible => true;

  final _dismissHandler = ValueNotifier<SheetDismissHandler?>(null);

  final _coveringSheet = ValueNotifier<SnapSheetRoute<dynamic>?>(null);

  double _closingVelocity = 0;

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    super.didChangeNext(nextRoute);
    _coveringSheet.value = nextRoute is SnapSheetRoute ? nextRoute : null;
  }

  Future<void> _dismiss() async {
    final handler = _dismissHandler.value;
    if (handler != null) {
      await handler();
    } else {
      await navigator?.maybePop();
    }
  }

  void _drag(double value) => controller!.value = value;

  void _restore(double velocity) {
    controller!.animateWith(_presentation(1, velocity));
  }

  /// Springs back while a guard decides, and leaves from there with
  /// [velocity] if the sheet closes now, the way UIKit answers a swipe.
  void _close(double velocity) {
    _restore(0);
    _closingVelocity = velocity;
    SchedulerBinding.instance.addPostFrameCallback((_) => _closingVelocity = 0);
    unawaited(_dismiss());
  }

  _SheetSpring _presentation(double target, double velocity) {
    final from = controller!.value;
    final launch = _launch(target - from, velocity, overshoots: false);
    return _SheetSpring(
      from: from,
      to: target,
      velocity: launch.velocity,
      ratio: launch.ratio,
      tolerance: _presentationTolerance,
    );
  }

  @override
  Simulation createSimulation({required bool forward}) {
    final velocity = forward ? 0.0 : _closingVelocity;
    _closingVelocity = 0;
    return _presentation(forward ? 1 : 0, velocity);
  }

  @override
  Widget buildModalBarrier() {
    void onDismiss() => unawaited(_dismiss());
    final color = barrierColor;
    if (color == null || color.a == 0 || offstage) {
      return ModalBarrier(
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        onDismiss: onDismiss,
      );
    }
    return AnimatedModalBarrier(
      color: animation!.drive(
        ColorTween(begin: color.withValues(alpha: 0), end: color),
      ),
      dismissible: barrierDismissible,
      semanticsLabel: barrierLabel,
      barrierSemanticsDismissible: semanticsDismissible,
      onDismiss: onDismiss,
    );
  }

  @override
  void dispose() {
    _dismissHandler.dispose();
    _coveringSheet.dispose();
    super.dispose();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ElevatedSurfaceTheme(child: _SnapSheet(route: this));
  }
}

/// A throw away from the target is dropped, as UIKit drops it.
({double velocity, double ratio}) _launch(
  double distance,
  double velocity, {
  required bool overshoots,
}) {
  if (distance == 0 || velocity == 0 || velocity.sign != distance.sign) {
    return (velocity: 0, ratio: 1);
  }
  final reach = _omega * distance.abs();
  final strength = velocity.abs() / reach;
  if (!overshoots) {
    return (velocity: velocity.sign * math.min(strength, 1) * reach, ratio: 1);
  }
  return (
    velocity: velocity.sign * math.min(strength, _hardestThrow) * reach,
    ratio: 1 - (1 - _thrownRatio) * math.min(strength / _fullThrow, 1),
  );
}

/// max(x, 0) with its corner rounded over [-width, width], never below it.
double _rounded(double x, double width) {
  if (x >= width) {
    return x;
  }
  if (x <= -width) {
    return 0;
  }
  final reach = x + width;
  return reach * reach / (4 * width);
}

/// SpringSimulation picks its solution by the sign of a discriminant that a
/// critically damped spring leaves to rounding.
class _SheetSpring extends Simulation {
  _SheetSpring({
    required double from,
    required this.to,
    required double velocity,
    required this.ratio,
    super.tolerance,
  }) : _start = from - to,
       _velocity = velocity;

  final double to;
  final double ratio;
  final double _start;
  final double _velocity;

  late final double _damped = _omega * math.sqrt(1 - ratio * ratio);

  double _offset(double time) {
    if (ratio >= 1) {
      return (_start + (_velocity + _omega * _start) * time) *
          math.exp(-_omega * time);
    }
    final sine = (_velocity + ratio * _omega * _start) / _damped;
    return math.exp(-ratio * _omega * time) *
        (_start * math.cos(_damped * time) + sine * math.sin(_damped * time));
  }

  /// Lands exactly on [to], which an AnimationController would otherwise
  /// stop a tolerance short of.
  @override
  double x(double time) => isDone(time) ? to : to + _offset(time);

  @override
  double dx(double time) {
    if (ratio >= 1) {
      return (_velocity - _omega * (_velocity + _omega * _start) * time) *
          math.exp(-_omega * time);
    }
    final sine = (_velocity + ratio * _omega * _start) / _damped;
    final decay = ratio * _omega;
    return math.exp(-decay * time) *
        ((sine * _damped - decay * _start) * math.cos(_damped * time) -
            (_start * _damped + decay * sine) * math.sin(_damped * time));
  }

  @override
  bool isDone(double time) =>
      nearZero(_offset(time), tolerance.distance) &&
      nearZero(dx(time), tolerance.velocity);
}

sealed class _Activity {
  const _Activity();
}

class _Resting extends _Activity {
  const _Resting(this.stop);

  final int stop;
}

class _Holding extends _Activity {
  _Holding(this.height, {required this.dragged});

  double height;
  final bool dragged;
}

/// An offset from the detent, which carries the sheet along as it moves.
class _Settling extends _Activity {
  _Settling(this.stop, this.offset, this.velocity, this.ratio);

  final int stop;
  double offset;
  double velocity;
  final double ratio;
}

/// Heights are shown above the keyboard, which raises the sheet's foot, and
/// layout resolves the detents every frame; a drag below the shortest detent
/// moves the route's presentation, which the barrier follows too.
class _SheetModel extends ChangeNotifier {
  _SheetModel({required this.route, required TickerProvider vsync})
    : detents = route.detents,
      fitsContent = route.fitsContent {
    _ticker = vsync.createTicker(_tick);
    route.animation!.addListener(_syncLift);
  }

  final SnapSheetRoute<dynamic> route;
  final List<double> detents;
  final bool fitsContent;

  late final Ticker _ticker;
  Duration? _lastTick;
  bool _disposed = false;
  bool _openPending = false;

  final settling = ValueNotifier(false);
  final open = ValueNotifier(false);

  /// How far a drag has pulled the sheet down, for a footer that stays put.
  final lift = ValueNotifier(0.0);
  bool _liftFollows = false;

  double _available = 0;
  double _keyboard = 0;

  /// Infinite while the content fills the height it was laid out within.
  double _fitHeight = double.infinity;
  double _filledRoom = 0;
  double? _measureRoom;
  double _contentRoom = 0;
  double _contentLimit = 0;
  double contentHeight = 0;
  _RenderSheetContent? _content;

  _Activity _activity = const _Resting(0);

  Animation<double> get _presentation => route.animation!;

  bool get _closing => _presentation.status == AnimationStatus.reverse;

  /// The tallest detent, lifted by the keyboard up to a peek below the top.
  double get _top {
    final peak = math.max(_available - stackedSheetPeek, 0.0);
    final tallest = detents.last * _available;
    final room = clampDouble(peak - tallest, 0, _peakEase);
    return peak - _rounded(peak - tallest - _keyboard, room);
  }

  /// A fit sheet follows its content up to each detent but never rests below
  /// the shortest one; each keeps what it shows above the keyboard.
  List<double> get _stops {
    final shortest = detents.first * _available;
    final top = _top;
    return [
      for (final fraction in detents)
        math.max(_stopFor(fraction * _available, shortest, top), _keyboard) -
            _keyboard,
    ];
  }

  double _stopFor(double detent, double shortest, double top) {
    final rest = clampDouble(_fitHeight, shortest, detent);
    final blank = rest - math.min(_fitHeight, rest);
    return math.min(top, rest + _rounded(_keyboard - blank, blank / 2));
  }

  double get minHeight => _stops.first;

  double get maxHeight => _stops.last;

  double get height => _heightIn(_stops);

  double _heightIn(List<double> stops) => switch (_activity) {
    _Resting(:final stop) => stops[stop],
    _Holding(:final height) => clampDouble(height, stops.first, stops.last),
    _Settling(:final stop, :final offset) => stops[stop] + offset,
  };

  bool get isSettling => _activity is _Settling;

  bool get isOpen {
    final stops = _stops;
    final height = switch (_activity) {
      _Resting(:final stop) || _Settling(:final stop) => stops[stop],
      _Holding(:final height) => height,
    };
    return height >= stops.last - precisionErrorTolerance;
  }

  /// A sheet at rest measures its content up to its detent, which finds the
  /// content however it changes; a moving one lays it out at what it shows.
  double beginLayout(double available, double keyboard) {
    _available = available;
    _keyboard = keyboard;
    final stops = _stops;
    final height = _heightIn(stops);
    final measured = switch (_activity) {
      _ when height >= stops.last - precisionErrorTolerance =>
        detents.length - 1,
      _Resting(:final stop) => stop,
      _ => null,
    };
    _contentRoom = measured == null || !fitsContent
        ? math.max(height, stops.first)
        : math.max(
            math.min(detents[measured] * available, _top - keyboard),
            height,
          );
    if (!fitsContent || !_isShortOfLimit) {
      _contentLimit = _contentRoom;
    }
    return _contentLimit;
  }

  /// Short content lays out the same within its room and the limit it had.
  bool get _isShortOfLimit =>
      contentHeight <
      math.min(_contentRoom, _contentLimit) - precisionErrorTolerance;

  bool releaseLimit() {
    if (_contentLimit == _contentRoom || _isShortOfLimit) {
      return false;
    }
    _contentLimit = _contentRoom;
    return true;
  }

  bool fitContent() {
    final limit = _contentLimit;
    final fills = contentHeight >= limit - precisionErrorTolerance;
    final fit = !fills
        ? contentHeight
        : _fitHeight >= limit - precisionErrorTolerance
        ? _fitHeight
        : double.infinity;
    return _refit(fit);
  }

  double get _tallestRoom =>
      math.min(detents.last * _available, _top - _keyboard);

  /// Content taller than the detent the sheet rests at is measured up to the
  /// tallest one before the sheet moves, so a release lands where it ends.
  void _measureBeforeMoving() {
    final room = _tallestRoom;
    if (!fitsContent ||
        _fitHeight.isFinite ||
        _contentLimit >= room - precisionErrorTolerance ||
        _filledRoom >= room - precisionErrorTolerance) {
      return;
    }
    _measureRoom = room;
  }

  void _measured(double natural, double room) {
    final fills = natural >= room - precisionErrorTolerance;
    _refit(fills ? double.infinity : natural);
    if (fills) {
      _filledRoom = room;
    }
  }

  bool _refit(double fit) {
    if (fit == _fitHeight) {
      return false;
    }
    _filledRoom = 0;
    final shown = height;
    _fitHeight = fit;
    _keepSettlingFrom(shown);
    return true;
  }

  void _keepSettlingFrom(double shown) {
    final activity = _activity;
    if (activity is! _Settling) {
      return;
    }
    final offset = shown - _stops[activity.stop];
    final launch = _launch(-offset, activity.velocity, overshoots: true);
    _activity = _Settling(activity.stop, offset, launch.velocity, launch.ratio);
  }

  void endLayout() {
    _syncLift();
    _syncOpen();
  }

  void _syncLift() {
    if (_closing) {
      return;
    }
    lift.value = _liftFollows
        ? (1 - _presentation.value) * (minHeight + _keyboard)
        : 0;
  }

  void _syncOpen() {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      open.value = isOpen;
      return;
    }
    if (_openPending || open.value == isOpen) {
      return;
    }
    _openPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _openPending = false;
      if (!_disposed) {
        open.value = isOpen;
      }
    });
  }

  void _changed() {
    notifyListeners();
    _syncOpen();
  }

  void _hold({required bool dragged}) {
    final activity = _activity;
    if (activity is _Holding && activity.dragged == dragged) {
      return;
    }
    final height = this.height;
    _stopTicker();
    _activity = _Holding(height, dragged: dragged);
    if (dragged) {
      _measureBeforeMoving();
    }
  }

  /// Returns how much of [delta], positive to grow, the sheet took: what is
  /// left past the tallest detent goes to the content.
  double dragBy(double delta) {
    // A drag the pop caught mid-gesture would hold the route from leaving.
    if (_closing) {
      return delta;
    }
    _hold(dragged: true);
    final held = _activity as _Holding;
    final stops = _stops;
    held.height = clampDouble(held.height, stops.first, stops.last);
    final extent = stops.first + _keyboard;
    var rest = delta;
    if (rest < 0) {
      final shrink = math.max(rest, math.min(stops.first - held.height, 0.0));
      held.height += shrink;
      rest -= shrink;
      if (rest < 0 && extent > 0) {
        _liftFollows = true;
        route._drag(math.max(_presentation.value + rest / extent, 0));
        rest = 0;
      }
    } else if (rest > 0) {
      final shown = _presentation.value;
      if (shown < 1 && extent > 0) {
        final restored = math.min(rest / extent, 1 - shown);
        route._drag(shown + restored);
        rest -= restored * extent;
      }
      final grow = math.min(rest, math.max(stops.last - held.height, 0.0));
      held.height += grow;
      rest -= grow;
    }
    _changed();
    return delta - rest;
  }

  void dragEnd(double velocity) {
    final activity = _activity;
    if (activity is! _Holding || !activity.dragged) {
      return;
    }
    if (_closing) {
      _hold(dragged: false);
      return;
    }
    final stops = _stops;
    final shown = _presentation.value;
    final extent = stops.first + _keyboard;
    final position = shown < 1 ? extent * shown : _keyboard + activity.height;
    final projected = position + velocity * _projectionTime;
    var target = -1;
    var distance = projected.abs();
    for (final (index, stop) in stops.indexed) {
      final away = (stop + _keyboard - projected).abs();
      if (away < distance) {
        distance = away;
        target = index;
      }
    }
    if (target < 0) {
      _closeAt(velocity, extent);
    } else if (shown < 1) {
      _rest(0);
      route._restore(extent > 0 ? velocity / extent : 0);
    } else {
      _settleTo(target, velocity);
    }
  }

  void _closeAt(double velocity, double extent) {
    if (_presentation.value >= 1 &&
        height > minHeight + precisionErrorTolerance) {
      _settleTo(0, 0);
    } else {
      _rest(0);
    }
    route._close(extent > 0 ? velocity / extent : 0);
  }

  void settleTowards(double direction) {
    final stops = _stops;
    final height = _heightIn(stops);
    var target = 0;
    if (direction > 0) {
      target = stops.indexWhere(
        (stop) => stop > height + precisionErrorTolerance,
      );
      if (target < 0) {
        target = stops.length - 1;
      }
    } else if (direction < 0) {
      target = math.max(
        stops.lastIndexWhere((stop) => stop < height - precisionErrorTolerance),
        0,
      );
    }
    final current = switch (_activity) {
      _Resting(:final stop) || _Settling(:final stop) => stop,
      _Holding() => null,
    };
    if (current != null && stops[current] == stops[target]) {
      return;
    }
    _settleTo(target, 0);
  }

  void _settleTo(int stop, double velocity) {
    final stops = _stops;
    final offset = _heightIn(stops) - stops[stop];
    if (offset.abs() < _settleTolerance.distance &&
        velocity.abs() < _settleTolerance.velocity) {
      _rest(stop);
      return;
    }
    final launch = _launch(-offset, velocity, overshoots: true);
    _activity = _Settling(stop, offset, launch.velocity, launch.ratio);
    _measureBeforeMoving();
    settling.value = true;
    if (!_ticker.isActive) {
      _lastTick = SchedulerBinding.instance.currentSystemFrameTimeStamp;
      _ticker.start();
    }
    _changed();
  }

  void _tick(Duration _) {
    final activity = _activity;
    if (activity is! _Settling) {
      _stopTicker();
      return;
    }
    // Timed from the frame the settle began in, so its first frame moves.
    final now = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    final time =
        (now - (_lastTick ?? now)).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastTick = now;
    final spring = _SheetSpring(
      from: activity.offset,
      to: 0,
      velocity: activity.velocity,
      ratio: activity.ratio,
      tolerance: _settleTolerance,
    );
    if (spring.isDone(time)) {
      _rest(activity.stop);
      return;
    }
    activity
      ..offset = spring.x(time)
      ..velocity = spring.dx(time);
    _changed();
  }

  void _rest(int stop) {
    _stopTicker();
    _activity = _Resting(stop);
    _changed();
  }

  void _stopTicker() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _lastTick = null;
    settling.value = false;
  }

  void stop() {
    if (_activity is _Settling) {
      _hold(dragged: false);
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    route.animation!.removeListener(_syncLift);
    _ticker.dispose();
    settling.dispose();
    open.dispose();
    lift.dispose();
    super.dispose();
  }
}

class _SnapSheet extends StatefulWidget {
  const _SnapSheet({required this.route});

  final SnapSheetRoute<dynamic> route;

  @override
  State<_SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<_SnapSheet>
    with SingleTickerProviderStateMixin {
  late final _model = _SheetModel(route: widget.route, vsync: this);
  late final _scrollController = _SheetScrollController(
    model: _model,
    initialScrollOffset: widget.route.initialScrollOffset,
  );

  Duration? _lastWheel;

  @override
  void initState() {
    super.initState();
    widget.route.animation!.addStatusListener(_handleRouteStatus);
  }

  void _handleRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      _model.stop();
    }
  }

  @override
  void dispose() {
    widget.route.animation!.removeStatusListener(_handleRouteStatus);
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  ScrollController _createScrollController({double initialScrollOffset = 0}) {
    return _SheetScrollController(
      model: _model,
      initialScrollOffset: initialScrollOffset,
    );
  }

  /// Sees the events the content scrolls with too, so a turn the content
  /// started never moves the sheet, and no turn moves it past one detent.
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) {
      return;
    }
    final last = _lastWheel;
    _lastWheel = event.timeStamp;
    if (last != null && event.timeStamp - last < _wheelTurnGap) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (_) => _model.settleTowards(event.scrollDelta.dy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final sheetColor = SurfaceLevel.page.colorOf(context.colorScheme);
    final theme = Theme.of(context);
    Widget content = route.builder(context, _scrollController);
    if (route.fitsContent) {
      content = PrimaryScrollController(
        controller: _scrollController,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: content,
      );
    }
    final sheet = Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onVerticalDragUpdate: (details) =>
            _model.dragBy(-details.primaryDelta!),
        onVerticalDragEnd: (details) =>
            _model.dragEnd(-(details.primaryVelocity ?? 0)),
        onVerticalDragCancel: () => _model.dragEnd(0),
        child: ClipRSuperellipse(
          borderRadius: AppRadius.top(AppCorner.xxl),
          child: Theme(
            data: theme.copyWith(scaffoldBackgroundColor: sheetColor),
            child: Material(
              color: sheetColor,
              child: _SheetContent(
                model: _model,
                child: _WithoutKeyboard(
                  child: SheetProvider(
                    type: SheetType.bottomSheet,
                    child: SheetOverhangScope(
                      overhang: _model.lift,
                      fitsContent: route.fitsContent,
                      child: SheetDismissScope(
                        handler: route._dismissHandler,
                        child: SheetScrollScope(
                          createController: _createScrollController,
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      bottom: false,
      child: _KeyboardViewport(
        model: _model,
        child: RepaintBoundary(child: sheet),
      ),
    );
  }
}

/// The sheet makes room for the keyboard itself, so nothing inside it does.
/// Only this rebuilds with the keyboard; the content keeps its widgets.
class _WithoutKeyboard extends StatelessWidget {
  const _WithoutKeyboard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).removeViewInsets(removeBottom: true),
      child: child,
    );
  }
}

class _KeyboardViewport extends StatelessWidget {
  const _KeyboardViewport({required this.model, required this.child});

  final _SheetModel model;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = model.route;
    return _SheetViewport(
      model: model,
      keyboard: MediaQuery.viewInsetsOf(context).bottom,
      presentation: route.animation!,
      cover: route.secondaryAnimation!,
      covering: route._coveringSheet,
      child: child,
    );
  }
}

/// The keyboard, the presentation and a sheet over this one move the sheet as
/// it is painted; only its height lays it out.
class _SheetViewport extends SingleChildRenderObjectWidget {
  const _SheetViewport({
    required this.model,
    required this.keyboard,
    required this.presentation,
    required this.cover,
    required this.covering,
    required super.child,
  });

  final _SheetModel model;
  final double keyboard;
  final Animation<double> presentation;
  final Animation<double> cover;
  final ValueListenable<SnapSheetRoute<dynamic>?> covering;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSheetViewport(
      model: model,
      keyboard: keyboard,
      presentation: presentation,
      cover: cover,
      covering: covering,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSheetViewport renderObject,
  ) {
    renderObject
      ..model = model
      ..keyboard = keyboard
      ..presentation = presentation
      ..cover = cover
      ..covering = covering;
  }
}

class _RenderSheetViewport extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSheetViewport({
    required _SheetModel model,
    required double keyboard,
    required Animation<double> presentation,
    required Animation<double> cover,
    required ValueListenable<SnapSheetRoute<dynamic>?> covering,
  }) : _model = model,
       _keyboard = keyboard,
       _presentation = presentation,
       _cover = cover,
       _covering = covering;

  _SheetModel _model;
  double _keyboard;
  Animation<double> _presentation;
  Animation<double> _cover;
  ValueListenable<SnapSheetRoute<dynamic>?> _covering;

  final _layer = LayerHandle<TransformLayer>();
  double _shown = 0;

  set model(_SheetModel value) {
    if (identical(value, _model)) {
      return;
    }
    if (attached) {
      _model.removeListener(markNeedsLayout);
      value.addListener(markNeedsLayout);
    }
    _model = value;
    markNeedsLayout();
  }

  set keyboard(double value) {
    if (value == _keyboard) {
      return;
    }
    _keyboard = value;
    markNeedsLayout();
  }

  set presentation(Animation<double> value) {
    if (identical(value, _presentation)) {
      return;
    }
    if (attached) {
      _presentation.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _presentation = value;
    markNeedsPaint();
  }

  set cover(Animation<double> value) {
    if (identical(value, _cover)) {
      return;
    }
    if (attached) {
      _cover.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _cover = value;
    markNeedsPaint();
  }

  set covering(ValueListenable<SnapSheetRoute<dynamic>?> value) {
    if (identical(value, _covering)) {
      return;
    }
    if (attached) {
      _covering.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _covering = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _model.addListener(markNeedsLayout);
    _presentation.addListener(markNeedsPaint);
    _cover.addListener(markNeedsPaint);
    _covering.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _model.removeListener(markNeedsLayout);
    _presentation.removeListener(markNeedsPaint);
    _cover.removeListener(markNeedsPaint);
    _covering.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _layer.layer = null;
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    var limit = _model.beginLayout(size.height, _keyboard);
    final content = _model._content;
    // The limit reaches the content outside its constraints, which may not
    // have changed.
    if (content != null &&
        (content._limit != limit || _model._measureRoom != null)) {
      invokeLayoutCallback<BoxConstraints>((_) => content.markNeedsLayout());
    }
    var height = _model.height;
    _layoutSheet(height);
    if (content != null && _model.releaseLimit()) {
      limit = _model._contentLimit;
      invokeLayoutCallback<BoxConstraints>((_) => content.markNeedsLayout());
      _layoutSheet(height);
    }
    // Within the limit only the sheet around the content needs a new layout.
    if (_model.fitsContent) {
      _model.fitContent();
      final fitted = _model.height;
      if (fitted != height && fitted <= limit) {
        height = fitted;
        _layoutSheet(height);
      }
    }
    _model.endLayout();
  }

  /// Never tight, so a change in the content's height reaches this layout.
  void _layoutSheet(double height) {
    _shown = height;
    child?.layout(
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height,
      ),
      parentUsesSize: true,
    );
  }

  Matrix4 get _transform {
    final sheet = math.max(_shown, _model.minHeight) + _keyboard;
    final cover = _covering.value == null ? 0.0 : _cover.value;
    final scale = 1 - (1 - stackedSheetScale) * cover;
    final below = math.max(_model.minHeight - _shown, 0.0);
    final top =
        size.height -
        sheet +
        below +
        (1 - _presentation.value) * sheet -
        stackedSheetPeek * cover;
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(size.width / 2 * (1 - scale), top, 0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) {
      _layer.layer = null;
      return;
    }
    _layer.layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: _layer.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    // A mouse may hit test between frames, before the sheet is laid out.
    if (child == null || !child.hasSize) {
      return false;
    }
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, position) => child.hitTest(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }
}

/// The surface fills what the content leaves, the keyboard's part included.
class _SheetContent extends SingleChildRenderObjectWidget {
  const _SheetContent({required this.model, required super.child});

  final _SheetModel model;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSheetContent(model);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSheetContent renderObject,
  ) {
    renderObject.model = model;
  }
}

class _RenderSheetContent extends RenderProxyBox {
  _RenderSheetContent(this._model);

  _SheetModel _model;
  double? _limit;

  _SheetModel get model => _model;

  set model(_SheetModel value) {
    if (identical(value, _model)) {
      return;
    }
    if (attached) {
      _release();
      value._content = this;
    }
    _model = value;
    markNeedsLayout();
  }

  void _release() {
    if (identical(_model._content, this)) {
      _model._content = null;
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _model._content = this;
  }

  @override
  void detach() {
    _release();
    super.detach();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final limit = _limit = model._contentLimit;
    final child = this.child;
    if (child != null) {
      final room = model._measureRoom;
      if (room != null) {
        model._measureRoom = null;
        child.layout(
          BoxConstraints(minWidth: width, maxWidth: width, maxHeight: room),
          parentUsesSize: true,
        );
        model._measured(child.size.height, room);
      }
      child.layout(
        model.fitsContent
            ? BoxConstraints(minWidth: width, maxWidth: width, maxHeight: limit)
            : BoxConstraints(
                maxWidth: width,
                minHeight: limit,
                maxHeight: limit,
              ),
        parentUsesSize: true,
      );
      model.contentHeight = child.size.height;
    }
    size = constraints.biggest;
  }
}

class _SheetScrollController extends ScrollController
    with SheetScrollController {
  _SheetScrollController({required this.model, super.initialScrollOffset});

  final _SheetModel model;

  @override
  ValueListenable<bool> get sheetOpen => model.open;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SheetScrollPosition(
      physics: _SheetContentPhysics(parent: physics),
      context: context,
      oldPosition: oldPosition,
      initialPixels: initialScrollOffset,
      model: model,
    );
  }
}

class _SheetScrollPosition extends ScrollPositionWithSingleContext
    with ScrubbableScrollPosition {
  _SheetScrollPosition({
    required this.model,
    required super.physics,
    required super.context,
    super.initialPixels,
    super.oldPosition,
  }) {
    model.settling.addListener(_followSettling);
  }

  final _SheetModel model;

  bool get _isDragged => activity is DragScrollActivity;

  bool get _isReversed => axisDirectionIsReversed(axisDirection);

  /// Whether the content has left the edge it shows at the top of the sheet.
  /// A reverse list reaches that edge at its maximum offset, not its minimum.
  bool get _contentScrolled {
    if (!hasContentDimensions) {
      return false;
    }
    return _isReversed
        ? pixels < maxScrollExtent - precisionErrorTolerance
        : pixels > minScrollExtent + precisionErrorTolerance;
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final atEdge = !_contentScrolled;
    return _SheetContentDrag(
      this,
      super.drag(details, dragCancelCallback),
      startedAtEdge: atEdge,
    );
  }

  @override
  void pointerScroll(double delta) {
    if (model.isSettling && !model.isOpen) {
      return;
    }
    final grow = _isReversed ? -delta : delta;
    if (!isScrubbing && !_contentScrolled && (grow < 0 || !model.isOpen)) {
      model.settleTowards(grow);
      return;
    }
    super.pointerScroll(delta);
  }

  /// Keeps a reverse list, which hangs from its bottom, fixed to the top
  /// edge as the sheet resizes.
  @override
  bool correctForNewDimensions(
    ScrollMetrics oldPosition,
    ScrollMetrics newPosition,
  ) {
    final grown = newPosition.viewportDimension - oldPosition.viewportDimension;
    var pixels = newPosition.pixels;
    if (_isReversed && grown != 0) {
      pixels = clampDouble(
        pixels - grown,
        newPosition.minScrollExtent,
        newPosition.maxScrollExtent,
      );
    }
    final corrected = physics.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition.copyWith(pixels: pixels),
      isScrolling: activity!.isScrolling,
      velocity: activity!.velocity,
    );
    if (corrected == newPosition.pixels) {
      return true;
    }
    correctPixels(corrected);
    return false;
  }

  void _followSettling() {
    if (model.settling.value) {
      if (activity.runtimeType == IdleScrollActivity) {
        goIdle();
      }
    } else if (activity is _SettlingScrollActivity) {
      goIdle();
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    super.beginActivity(
      newActivity.runtimeType == IdleScrollActivity && model.settling.value
          ? _SettlingScrollActivity(this)
          : newActivity,
    );
  }

  @override
  void dispose() {
    model.settling.removeListener(_followSettling);
    super.dispose();
  }
}

/// As UIKit's prefersScrollingExpandsWhenScrolledToEdge: a drag up grows the
/// sheet and then scrolls the content in one gesture; a drag down takes the
/// sheet only when it began with the content at its top.
class _SheetContentDrag implements Drag {
  _SheetContentDrag(
    this._position,
    this._content, {
    required this.startedAtEdge,
  });

  final _SheetScrollPosition _position;
  final Drag _content;
  final bool startedAtEdge;

  bool _sheetHeld = false;

  _SheetModel get _sheet => _position.model;

  @override
  void update(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    if (delta == 0 || _position.isScrubbing) {
      _content.update(details);
      return;
    }
    final grow = -delta;
    if (grow > 0) {
      if (!_sheetHeld && (_position._contentScrolled || _sheet.isOpen)) {
        _content.update(details);
        return;
      }
      _sheetHeld = true;
      final rest = grow - _sheet.dragBy(grow);
      if (rest > precisionErrorTolerance) {
        _sheetHeld = false;
        _content.update(
          DragUpdateDetails(
            sourceTimeStamp: details.sourceTimeStamp,
            delta: Offset(0, -rest),
            primaryDelta: -rest,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          ),
        );
      }
      return;
    }
    if (!_sheetHeld && (!startedAtEdge || _position._contentScrolled)) {
      _content.update(details);
      return;
    }
    _sheetHeld = true;
    _sheet.dragBy(grow);
  }

  @override
  void end(DragEndDetails details) {
    if (!_sheetHeld) {
      _content.end(details);
      _sheet.dragEnd(0);
      return;
    }
    _content.end(
      DragEndDetails(
        primaryVelocity: 0,
        globalPosition: details.globalPosition,
      ),
    );
    _sheet.dragEnd(-(details.primaryVelocity ?? 0));
  }

  @override
  void cancel() {
    _content.cancel();
    _sheet.dragEnd(0);
  }
}

/// Keeps a drag that grows the sheet alive once the content fits its viewport.
class _SheetContentPhysics extends ScrollPhysics {
  const _SheetContentPhysics({super.parent});

  @override
  _SheetContentPhysics applyTo(ScrollPhysics? ancestor) {
    return _SheetContentPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return (position is _SheetScrollPosition && position._isDragged) ||
        super.shouldAcceptUserOffset(position);
  }
}

/// Keeps taps off the rows while the sheet settles, as a fling does.
class _SettlingScrollActivity extends IdleScrollActivity {
  _SettlingScrollActivity(super.delegate);

  @override
  bool get shouldIgnorePointer => true;
}
