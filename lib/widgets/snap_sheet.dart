import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';
import 'sheet.dart';

/// Receives the sheet's own scroll controller, or null where the sheet has no
/// detents to drag between and the content keeps its own controller.
typedef SnapSheetBuilder =
    Widget Function(BuildContext context, ScrollController? controller);

/// The heights a snap sheet rests at, as a fraction of the space it gets.
const snapSheetDetents = [0.5, 0.9];

final _settleSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 450),
);

/// The default tolerance holds a settle, and the input it blocks, for most of
/// a second after the sheet looks still.
const _settleTolerance = Tolerance(distance: 0.5, velocity: 10);

/// UIScrollView.DecelerationRate.normal, which UIKit projects a release with
/// to choose the detent a sheet comes to rest at.
const _decelerationRate = 0.998;

const _bounceExtent = 120.0;
const _bounceResistance = 6.0;

const _dismissVelocity = 700.0;

/// Wheel events closer together than this are one turn of the wheel, the
/// span Chromium latches a wheel sequence to one scroller for.
const _wheelTurnGap = Duration(milliseconds: 500);

/// Moves an open snap sheet out of the page's way and back: a bottom sheet
/// drops to its shortest detent, a side sheet slides off. Its value is the
/// height a bottom sheet rests at, so the page can keep its content clear;
/// zero for a side sheet, while detached, or once closing.
class SnapSheetController extends ChangeNotifier
    implements ValueListenable<double> {
  SnapSheetController({required TickerProvider vsync})
    : _aside = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 300),
      );

  final AnimationController _aside;
  late final Animation<double> aside = CurvedAnimation(
    parent: _aside,
    curve: Curves.easeInOutCubic,
  );
  _SnapSheetExtent? _extent;
  bool _sideAttached = false;
  double _height = 0;

  @override
  double get value => _height;

  bool get isAttached => _extent != null || _sideAttached;

  void collapse() {
    final extent = _extent;
    if (extent != null) {
      extent.collapse();
    } else if (_sideAttached) {
      _aside.forward();
    }
  }

  void restore() {
    final extent = _extent;
    if (extent != null) {
      extent.restore();
    } else if (_sideAttached) {
      _aside.reverse();
    }
  }

  void attachSide() {
    _sideAttached = true;
    _aside.value = 0;
  }

  void detachSide() => _sideAttached = false;

  @override
  void dispose() {
    _aside.dispose();
    super.dispose();
  }

  void _publish(double height) {
    if (_height == height) {
      return;
    }
    _height = height;
    notifyListeners();
  }
}

class SnapSheetRoute<T> extends PopupRoute<T> {
  SnapSheetRoute({
    required this.builder,
    required this.capturedThemes,
    required this.sheetBarrierColor,
    required this.barrierLabel,
    this.detents = snapSheetDetents,
    this.fitMaxHeight,
    this.collapsedDetent,
    this.initialScrollOffset = 0,
    this.sheetController,
  });

  final SnapSheetBuilder builder;
  final CapturedThemes capturedThemes;
  final Color sheetBarrierColor;
  final List<double> detents;

  /// Set for a sheet that rests at its content's height, up to this fraction
  /// of the space it gets, in place of [detents]. Its content takes the sheet's
  /// scroll controller as the primary one.
  final double? fitMaxHeight;

  /// Below every detent, reached only through [SnapSheetController.collapse];
  /// the page shows through undimmed there.
  final double? collapsedDetent;
  final double initialScrollOffset;
  final SnapSheetController? sheetController;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => collapsedDetent == null ? sheetBarrierColor : null;

  @override
  bool get barrierDismissible => true;

  final _dismissHandler = ValueNotifier<SheetDismissHandler?>(null);

  Future<void> _dismiss() async {
    final handler = _dismissHandler.value;
    if (handler != null) {
      await handler();
    } else {
      await navigator?.maybePop();
    }
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
        ColorTween(
          begin: color.withValues(alpha: 0),
          end: color,
        ).chain(CurveTween(curve: barrierCurve)),
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
    super.dispose();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return capturedThemes.wrap(
      _SnapSheet(
        detents: detents,
        fitMaxHeight: fitMaxHeight,
        collapsedDetent: collapsedDetent,
        initialScrollOffset: initialScrollOffset,
        animation: animation,
        controller: sheetController,
        scrimColor: collapsedDetent == null ? null : sheetBarrierColor,
        dismiss: _dismiss,
        dismissHandler: _dismissHandler,
        builder: builder,
      ),
    );
  }
}

class _SnapSheet extends StatefulWidget {
  const _SnapSheet({
    required this.detents,
    required this.fitMaxHeight,
    required this.collapsedDetent,
    required this.initialScrollOffset,
    required this.animation,
    required this.controller,
    required this.scrimColor,
    required this.dismiss,
    required this.dismissHandler,
    required this.builder,
  });

  final List<double> detents;
  final double? fitMaxHeight;
  final double? collapsedDetent;
  final double initialScrollOffset;
  final Animation<double> animation;
  final SnapSheetController? controller;
  final Color? scrimColor;
  final Future<void> Function() dismiss;
  final ValueNotifier<SheetDismissHandler?> dismissHandler;
  final SnapSheetBuilder builder;

  @override
  State<_SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<_SnapSheet>
    with SingleTickerProviderStateMixin {
  late final _extent = _SnapSheetExtent(
    detents: widget.detents,
    fitsContent: widget.fitMaxHeight != null,
    collapsedDetent: widget.collapsedDetent,
    vsync: this,
    dismiss: widget.dismiss,
    onRest: _publishRest,
  );
  late final _scrollController = _SnapSheetScrollController(
    extent: _extent,
    initialScrollOffset: widget.initialScrollOffset,
  );
  late final _entranceCurve = CurvedAnimation(
    parent: widget.animation,
    curve: Easing.emphasizedDecelerate,
    reverseCurve: Easing.emphasizedAccelerate,
  );
  late final _entrance = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(_entranceCurve);

  bool _keyboardShown = false;
  Duration? _lastWheel;

  @override
  void initState() {
    super.initState();
    widget.controller?._extent = _extent;
    widget.animation.addStatusListener(_handleRouteStatus);
  }

  bool get _closing => switch (widget.animation.status) {
    AnimationStatus.reverse || AnimationStatus.dismissed => true,
    _ => false,
  };

  void _publishRest(double height) {
    if (!_closing) {
      widget.controller?._publish(height);
    }
  }

  void _handleRouteStatus(AnimationStatus status) {
    if (_closing) {
      _extent._stopSettle();
      widget.controller?._publish(0);
    }
  }

  void _handleKeyboard(bool keyboardShown) {
    if (keyboardShown && !_keyboardShown && !_extent.isAtMax) {
      // The scaffold inside shrinks by the keyboard's height, which at the
      // shorter detent can leave no room for the content.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _extent.settleTowards(1);
        }
      });
    }
    _keyboardShown = keyboardShown;
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleRouteStatus);
    final controller = widget.controller;
    if (controller != null && identical(controller._extent, _extent)) {
      controller._extent = null;
    }
    _scrollController.dispose();
    _extent.dispose();
    _entranceCurve.dispose();
    super.dispose();
  }

  ScrollController _createScrollController() {
    return _SnapSheetScrollController(extent: _extent);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _extent.applyDelta(-details.delta.dy);
  }

  void _handleDragEnd(DragEndDetails details) {
    _extent.settleAt(-details.velocity.pixelsPerSecond.dy);
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
      (_) => _extent.settleTowards(event.scrollDelta.dy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor = context.colorScheme.surfaceContainerLow;
    final theme = Theme.of(context);
    final fitMaxHeight = widget.fitMaxHeight;
    Widget content = widget.builder(context, _scrollController);
    if (fitMaxHeight != null) {
      content = SheetScrollScope(
        createController: _createScrollController,
        child: PrimaryScrollController(
          controller: _scrollController,
          automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
          child: content,
        ),
      );
    }
    final scoped = SheetProvider(
      type: SheetType.bottomSheet,
      child: SheetOverhangScope(
        overhang: _extent,
        fitsContent: fitMaxHeight != null,
        child: SheetSettlingScope(
          settling: _extent.settling,
          child: SheetDismissScope(
            handler: widget.dismissHandler,
            child: _KeyboardWatch(onChanged: _handleKeyboard, child: content),
          ),
        ),
      ),
    );
    final sheet = SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _extent.resize(constraints.maxHeight);
          return Align(
            alignment: Alignment.bottomCenter,
            child: ListenableBuilder(
              listenable: _extent,
              builder: (_, child) {
                return SlideTransition(
                  position: _entrance,
                  child: Transform.translate(
                    offset: Offset(0, _extent.overhang),
                    child: fitMaxHeight != null
                        ? child
                        : SizedBox(height: _extent.height, child: child),
                  ),
                );
              },
              child: Listener(
                onPointerSignal: _handlePointerSignal,
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: ClipRSuperellipse(
                    borderRadius: AppRadius.top(AppCorner.xxl),
                    child: Theme(
                      data: theme.copyWith(scaffoldBackgroundColor: sheetColor),
                      child: Material(
                        color: sheetColor,
                        child: fitMaxHeight != null
                            ? _FitSheetBox(
                                extent: _extent,
                                maxHeight: fitMaxHeight * constraints.maxHeight,
                                child: scoped,
                              )
                            : scoped,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    final scrimColor = widget.scrimColor;
    if (scrimColor == null) {
      return sheet;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ListenableBuilder(
            listenable: Listenable.merge([widget.animation, _extent]),
            builder: (_, _) {
              final shown =
                  Curves.ease.transform(widget.animation.value) *
                  _extent.raised;
              return ColoredBox(
                color: scrimColor.withValues(alpha: scrimColor.a * shown),
              );
            },
          ),
        ),
        sheet,
      ],
    );
  }
}

/// Reads the keyboard below the sheet, so its motion rebuilds only this.
class _KeyboardWatch extends StatefulWidget {
  const _KeyboardWatch({required this.onChanged, required this.child});

  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  State<_KeyboardWatch> createState() => _KeyboardWatchState();
}

class _KeyboardWatchState extends State<_KeyboardWatch> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onChanged(MediaQuery.viewInsetsOf(context).bottom > 0);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Where the sheet sits, in pixels off the bottom of the space it was given.
/// Its content is laid out at the height it shows, so every detent can scroll
/// to its end; only a drag below [minPixels] slides it off as [overhang].
class _SnapSheetExtent extends ChangeNotifier
    implements ValueListenable<double> {
  _SnapSheetExtent({
    required this.detents,
    required this.dismiss,
    required this.onRest,
    required TickerProvider vsync,
    this.fitsContent = false,
    this.collapsedDetent,
  }) {
    _settle = AnimationController.unbounded(vsync: vsync)
      ..addListener(() => setPixels(_settle.value))
      ..addStatusListener((status) {
        if (!_settle.isAnimating) {
          settling.value = false;
        }
        if (status == AnimationStatus.completed) {
          setPixels(_settleTarget);
        }
      });
  }

  /// Rest heights as fractions of [_available], shortest first.
  final List<double> detents;

  /// Rests at the content's height alone, which [fitContent] reports.
  final bool fitsContent;

  final double? collapsedDetent;

  final Future<void> Function() dismiss;

  final ValueChanged<double> onRest;

  final settling = ValueNotifier(false);

  late final AnimationController _settle;
  bool _disposed = false;
  double _available = 0;
  double _pixels = 0;
  double _settleFraction = 0;
  double _settleTarget = 0;
  double? _fitHeight;

  double get pixels => _pixels;

  bool get isSettling => _settle.isAnimating;

  List<double> get _stops => fitsContent
      ? [_fitHeight ?? 0]
      : [for (final detent in detents) detent * _available];

  double get minPixels => _stops.first;

  double get maxPixels => _stops.last;

  double get overhang => math.max(minPixels - _pixels, 0);

  double get height => math.max(minPixels, _pixels);

  double get _floorPixels => switch (collapsedDetent) {
    final collapsed? => collapsed * _available,
    null => minPixels,
  };

  /// From 0 at the collapsed height or shortest detent to 1 at the tallest.
  double get raised {
    final range = maxPixels - _floorPixels;
    if (range <= 0) {
      return 1;
    }
    return clampDouble((_pixels - _floorPixels) / range, 0, 1);
  }

  @override
  double get value => overhang;

  bool get isAtMax => _pixels >= maxPixels - precisionErrorTolerance;

  bool get isOpen =>
      isAtMax ||
      (isSettling &&
          _settleFraction * _available >= maxPixels - precisionErrorTolerance);

  /// Rescales silently: the sheet reads [pixels] later in the same build.
  void resize(double available) {
    if (_available == available) {
      return;
    }
    if (fitsContent) {
      _available = available;
      return;
    }
    var fraction = _available == 0 ? detents.first : _pixels / _available;
    if (isSettling) {
      _settle.stop();
      fraction = _settleFraction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          settling.value = isSettling;
        }
      });
    }
    _available = available;
    _pixels = clampDouble(
      fraction * available,
      _collapsed ? _floorPixels : minPixels,
      maxPixels,
    );
    final resting = _pixels;
    // Resized during layout, where the page listening cannot rebuild yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        onRest(resting);
      }
    });
  }

  /// Follows the content's height silently, as [resize] does, unless a drag
  /// holds the sheet elsewhere.
  void fitContent(double height) {
    final previous = _fitHeight;
    if (previous == height) {
      return;
    }
    _fitHeight = height;
    if (isSettling) {
      if ((_settleFraction * _available - (previous ?? 0)).abs() <
          precisionErrorTolerance) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_disposed && isSettling) {
            _settleTo(minPixels);
          }
        });
      }
      return;
    }
    if (previous == null ||
        (_pixels - previous).abs() < precisionErrorTolerance) {
      _pixels = height;
    }
  }

  void applyDelta(double delta) {
    _restoreFraction = null;
    _stopSettle();
    setPixels(_pixels + _withFriction(delta));
  }

  void setPixels(double value) {
    if (value == _pixels) {
      return;
    }
    _pixels = value;
    notifyListeners();
  }

  /// Thins a drag past the tallest detent as smooth_sheets' bouncing does.
  double _withFriction(double delta) {
    if (delta <= 0) {
      return delta;
    }
    var moved = _pixels;
    var consumed = 0.0;
    while (consumed.abs() < delta.abs()) {
      final fragment = clampDouble(delta - consumed, -kTouchSlop, kTouchSlop);
      final next = moved + fragment;
      final past = math.max(next - maxPixels, 0.0);
      final fraction = clampDouble(past / _bounceExtent, 0, 1);
      final friction =
          (1 - math.exp(-_bounceResistance * fraction)) /
          (1 - math.exp(-_bounceResistance));
      moved += fragment * (1 - friction);
      consumed += fragment;
    }
    return moved - _pixels;
  }

  void settleAt(double velocity) {
    final wasCollapsed = _collapsed;
    _collapsed = false;
    if (wasCollapsed && velocity > -_dismissVelocity) {
      _settleTo(_targetFor(velocity), velocity: velocity);
      return;
    }
    if (overhang > 0 &&
        (velocity <= -_dismissVelocity ||
            minPixels - _projected(velocity) >= minPixels / 2)) {
      // Springs back while a guard decides, and leaves from there if it
      // closes, the way UIKit answers a refused swipe.
      _settleTo(minPixels, velocity: velocity);
      unawaited(dismiss());
      return;
    }
    _settleTo(_targetFor(velocity), velocity: velocity);
  }

  void settleTowards(double direction) {
    final target = _nextStop(direction);
    if (isSettling &&
        (target - _settleFraction * _available).abs() <
            precisionErrorTolerance) {
      return;
    }
    _settleTo(target);
  }

  double? _restoreFraction;
  bool _collapsed = false;

  void collapse() {
    _restoreFraction ??= isSettling
        ? _settleFraction
        : (_available == 0 ? null : _pixels / _available);
    _collapsed = true;
    _settleTo(_floorPixels);
  }

  /// Returns to where [collapse] found the sheet, unless a drag moved it since.
  void restore() {
    final fraction = _restoreFraction;
    _restoreFraction = null;
    _collapsed = false;
    if (fraction != null) {
      _settleTo(fraction * _available);
    }
  }

  void _stopSettle() {
    _settle.stop();
    settling.value = false;
  }

  void _settleTo(double target, {double? velocity}) {
    final carried = velocity ?? (isSettling ? _settle.velocity : 0.0);
    _stopSettle();
    _settleFraction = _available == 0 ? 0 : target / _available;
    _settleTarget = target;
    onRest(target);
    final distance = (target - _pixels).abs();
    if (distance < precisionErrorTolerance) {
      setPixels(target);
      return;
    }
    // Past this a critically damped spring overshoots the detent.
    final reach =
        math.sqrt(_settleSpring.stiffness / _settleSpring.mass) * distance;
    _settle.animateWith(
      SpringSimulation(
        _settleSpring,
        _pixels,
        target,
        clampDouble(carried, -reach, reach),
        tolerance: _settleTolerance,
      ),
    );
    settling.value = true;
  }

  @override
  void dispose() {
    _disposed = true;
    _settle.dispose();
    settling.dispose();
    super.dispose();
  }

  double _projected(double velocity) =>
      _pixels + velocity / 1000 * _decelerationRate / (1 - _decelerationRate);

  double _targetFor(double velocity) {
    final projected = _projected(velocity);
    return _stops.reduce(
      (a, b) => (a - projected).abs() <= (b - projected).abs() ? a : b,
    );
  }

  double _nextStop(double direction) {
    final stops = _stops;
    if (direction > 0) {
      return stops.firstWhere(
        (stop) => stop > _pixels + precisionErrorTolerance,
        orElse: () => maxPixels,
      );
    }
    if (direction < 0) {
      return stops.lastWhere(
        (stop) => stop < _pixels - precisionErrorTolerance,
        orElse: () => minPixels,
      );
    }
    return stops.reduce(
      (a, b) => (a - _pixels).abs() <= (b - _pixels).abs() ? a : b,
    );
  }
}

class _SnapSheetScrollController extends ScrollController {
  _SnapSheetScrollController({required this.extent, super.initialScrollOffset});

  final _SnapSheetExtent extent;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SnapSheetScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      initialPixels: initialScrollOffset,
      extent: extent,
    );
  }
}

/// Hands a drag to the sheet while the content sits against the edge the
/// sheet grows from, and keeps it there until release or until the sheet
/// reaches its tallest detent, where the rest of the drag scrolls the content.
/// Once the sheet is on its way to that detent the content scrolls at once.
class _SnapSheetScrollPosition extends ScrollPositionWithSingleContext {
  _SnapSheetScrollPosition({
    required this.extent,
    required super.physics,
    required super.context,
    super.initialPixels,
    super.oldPosition,
  }) {
    extent.settling.addListener(_followSettling);
  }

  final _SnapSheetExtent extent;

  bool _sheetHeld = false;

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

  // A reverse list counts its own axis the other way round from the sheet,
  // so both readings flip with it. Positive means the sheet grows; the map is
  // its own inverse, so it also turns a sheet delta back into a content one.
  double _sheetDelta(double delta) => _isReversed ? delta : -delta;

  double _sheetVelocity(double velocity) => _isReversed ? -velocity : velocity;

  bool _sheetTakes(double sheetDelta) {
    if (_contentScrolled) {
      return false;
    }
    return sheetDelta < 0 || !extent.isOpen;
  }

  @override
  void applyUserOffset(double delta) {
    final sheetDelta = _sheetDelta(delta);
    if (!_sheetHeld && !_sheetTakes(sheetDelta)) {
      super.applyUserOffset(delta);
      return;
    }
    _sheetHeld = true;
    final sheetPart = sheetDelta > 0
        ? math.min(sheetDelta, math.max(extent.maxPixels - extent.pixels, 0.0))
        : sheetDelta;
    extent.applyDelta(sheetPart);
    final rest = sheetDelta - sheetPart;
    if (rest > 0) {
      _sheetHeld = false;
      super.applyUserOffset(_sheetDelta(rest));
    }
  }

  @override
  void pointerScroll(double delta) {
    if (extent.isSettling && !extent.isOpen) {
      return;
    }
    final sheetDelta = -_sheetDelta(delta);
    if (_sheetTakes(sheetDelta)) {
      extent.settleTowards(sheetDelta);
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
    if (_isReversed && grown != 0) {
      final pinned = clampDouble(
        newPosition.pixels - grown,
        newPosition.minScrollExtent,
        newPosition.maxScrollExtent,
      );
      if (pinned != newPosition.pixels) {
        correctPixels(pinned);
        return false;
      }
    }
    return super.correctForNewDimensions(oldPosition, newPosition);
  }

  void _followSettling() {
    if (extent.settling.value) {
      if (activity.runtimeType == IdleScrollActivity) {
        goIdle();
      }
    } else if (activity is _SettlingScrollActivity) {
      goIdle();
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (_sheetHeld && newActivity is! DragScrollActivity) {
      _sheetHeld = false;
      extent.settleTowards(0);
    }
    super.beginActivity(
      newActivity.runtimeType == IdleScrollActivity && extent.settling.value
          ? _SettlingScrollActivity(this)
          : newActivity,
    );
  }

  @override
  void dispose() {
    extent.settling.removeListener(_followSettling);
    super.dispose();
  }

  @override
  void goBallistic(double velocity) {
    if (!_sheetHeld) {
      super.goBallistic(velocity);
      return;
    }
    _sheetHeld = false;
    super.goBallistic(0);
    extent.settleAt(_sheetVelocity(velocity));
  }
}

/// Keeps taps off the rows while the sheet settles, as a fling does.
class _SettlingScrollActivity extends IdleScrollActivity {
  _SettlingScrollActivity(super.delegate);

  @override
  bool get shouldIgnorePointer => true;
}

/// Lays the content out at its own height, up to [maxHeight], and rests the
/// sheet there; a drag past that height stretches the surface below it.
class _FitSheetBox extends SingleChildRenderObjectWidget {
  const _FitSheetBox({
    required this.extent,
    required this.maxHeight,
    required super.child,
  });

  final _SnapSheetExtent extent;
  final double maxHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFitSheetBox(extent: extent, maxHeight: maxHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFitSheetBox renderObject,
  ) {
    renderObject
      ..extent = extent
      ..maxHeight = maxHeight;
  }
}

class _RenderFitSheetBox extends RenderProxyBox {
  _RenderFitSheetBox({
    required _SnapSheetExtent extent,
    required double maxHeight,
  }) : _extent = extent,
       _maxHeight = maxHeight;

  _SnapSheetExtent _extent;

  set extent(_SnapSheetExtent value) {
    if (identical(value, _extent)) {
      return;
    }
    if (attached) {
      _extent.removeListener(markNeedsLayout);
      value.addListener(markNeedsLayout);
    }
    _extent = value;
    markNeedsLayout();
  }

  double _maxHeight;

  set maxHeight(double value) {
    if (value == _maxHeight) {
      return;
    }
    _maxHeight = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _extent.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _extent.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(
      Size(constraints.maxWidth, math.min(_maxHeight, constraints.maxHeight)),
    );
  }

  @override
  void performLayout() {
    final child = this.child!;
    final width = constraints.maxWidth;
    child.layout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        maxHeight: math.min(_maxHeight, constraints.maxHeight),
      ),
      parentUsesSize: true,
    );
    final natural = child.size.height;
    _extent.fitContent(natural);
    final height = constraints.constrainHeight(
      math.max(natural, _extent.height),
    );
    if (height > natural + precisionErrorTolerance) {
      child.layout(
        BoxConstraints.tightFor(width: width, height: height),
        parentUsesSize: true,
      );
    }
    size = Size(width, height);
  }
}
