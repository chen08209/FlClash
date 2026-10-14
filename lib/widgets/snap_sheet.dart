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
import 'sheet_navigator.dart';

/// Receives the sheet's own scroll controller, or null where the sheet has no
/// detents to drag between and the content keeps its own controller.
typedef SnapSheetBuilder =
    Widget Function(BuildContext context, ScrollController? controller);

/// The heights a snap sheet rests at, as a fraction of the space it gets.
const snapSheetDetents = [9 / 16, 0.9];

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

class SnapSheetRoute<T> extends PopupRoute<T> with SheetCoverRouteMixin<T> {
  SnapSheetRoute({
    required this.builder,
    required this.capturedThemes,
    required this.sheetBarrierColor,
    required this.barrierLabel,
    this.detents = snapSheetDetents,
    this.transition = SheetTransition.slide,
    this.fitsContent = false,
    this.initialScrollOffset = 0,
  });

  final SnapSheetBuilder builder;
  final CapturedThemes capturedThemes;
  final Color sheetBarrierColor;
  final List<double> detents;
  final SheetTransition transition;

  final bool fitsContent;

  final double initialScrollOffset;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => sheetBarrierColor;

  @override
  bool get barrierDismissible => true;

  final _dismissHandler = ValueNotifier<SheetDismissHandler?>(null);

  /// A drag below the shortest detent, as a fraction of that detent.
  final _pulledDown = ValueNotifier(0.0);

  final _coveringSheet = ValueNotifier<SnapSheetRoute<dynamic>?>(null);

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
    _pulledDown.dispose();
    _coveringSheet.dispose();
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
        transition: transition,
        fitsContent: fitsContent,
        initialScrollOffset: initialScrollOffset,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        pulledDown: _pulledDown,
        coveringSheet: _coveringSheet,
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
    required this.transition,
    required this.fitsContent,
    required this.initialScrollOffset,
    required this.animation,
    required this.secondaryAnimation,
    required this.pulledDown,
    required this.coveringSheet,
    required this.dismiss,
    required this.dismissHandler,
    required this.builder,
  });

  final List<double> detents;
  final SheetTransition transition;
  final bool fitsContent;
  final double initialScrollOffset;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final ValueNotifier<double> pulledDown;
  final ValueListenable<SnapSheetRoute<dynamic>?> coveringSheet;
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
    fitsContent: widget.fitsContent,
    vsync: this,
    dismiss: widget.dismiss,
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

  /// Keeps pace with the entrance of the sheet covering this one.
  late final _coverCurve = CurvedAnimation(
    parent: widget.secondaryAnimation,
    curve: Easing.emphasizedDecelerate,
    reverseCurve: Easing.emphasizedAccelerate,
  );
  final _surfaceClaimed = ValueNotifier(false);

  bool get _stacks => widget.transition == SheetTransition.stack;

  bool _keyboardShown = false;
  Duration? _lastWheel;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_handleRouteStatus);
    _extent.addListener(_reportPulledDown);
  }

  void _reportPulledDown() {
    final shortest = _extent.minPixels;
    widget.pulledDown.value = shortest > 0 ? _extent.overhang / shortest : 0;
  }

  bool get _closing => switch (widget.animation.status) {
    AnimationStatus.reverse || AnimationStatus.dismissed => true,
    _ => false,
  };

  void _handleRouteStatus(AnimationStatus status) {
    if (_closing) {
      _extent._stopSettle();
    }
  }

  void _handleKeyboard(bool keyboardShown) {
    if (keyboardShown && !_keyboardShown) {
      // The scaffold inside shrinks by the keyboard's height, which at the
      // shorter detent can leave no room for the content.
      if (_extent.isAtMax) {
        _extent.holdAtMax();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _extent.settleTowards(1);
          }
        });
      }
    }
    _keyboardShown = keyboardShown;
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleRouteStatus);
    _scrollController.dispose();
    _extent.dispose();
    _entranceCurve.dispose();
    _coverCurve.dispose();
    _surfaceClaimed.dispose();
    super.dispose();
  }

  ScrollController _createScrollController({double initialScrollOffset = 0}) {
    return _SnapSheetScrollController(
      extent: _extent,
      initialScrollOffset: initialScrollOffset,
    );
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

  Widget _place(SnapSheetRoute<dynamic>? covering, Widget child) {
    // A SlideTransition asserts on a mouse hit test awaiting layout.
    final entrance = (1 - _entranceCurve.value) * _extent.height;
    final cover = covering == null
        ? 0.0
        : clampDouble(_coverCurve.value - covering._pulledDown.value, 0, 1);
    final scale = 1 - (1 - stackedSheetScale) * cover;
    return Transform(
      alignment: cover > 0 ? Alignment.topCenter : null,
      transform: Matrix4.diagonal3Values(scale, scale, 1)
        ..setTranslationRaw(
          0,
          _extent.overhang + entrance - stackedSheetPeek * cover,
          0,
        ),
      child: widget.fitsContent
          ? child
          : SizedBox(height: _extent.height, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor = context.colorScheme.surfaceContainerLow;
    final theme = Theme.of(context);
    final fitsContent = widget.fitsContent;
    Widget content = widget.builder(context, _scrollController);
    if (fitsContent) {
      content = PrimaryScrollController(
        controller: _scrollController,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: content,
      );
    }
    content = SheetScrollScope(
      createController: _createScrollController,
      child: content,
    );
    Widget scoped = _SheetKeyboard(
      extent: _extent,
      onChanged: _handleKeyboard,
      child: SheetProvider(
        type: SheetType.bottomSheet,
        child: SheetOverhangScope(
          overhang: _extent,
          fitsContent: fitsContent,
          child: SheetDismissScope(
            handler: widget.dismissHandler,
            child: content,
          ),
        ),
      ),
    );
    if (_stacks) {
      scoped = SheetStackScope(
        surfaceClaimed: _surfaceClaimed,
        child: CustomPaint(
          painter: _SheetSurfacePainter(
            color: sheetColor,
            claimed: _surfaceClaimed,
          ),
          child: Material(type: MaterialType.transparency, child: scoped),
        ),
      );
    } else {
      scoped = Material(color: sheetColor, child: scoped);
    }
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _extent.resize(constraints.maxHeight);
          return Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder(
              valueListenable: widget.coveringSheet,
              builder: (_, covering, child) => ListenableBuilder(
                listenable: Listenable.merge([
                  _extent,
                  _entranceCurve,
                  if (covering != null) ...[_coverCurve, covering._pulledDown],
                ]),
                builder: (_, child) => _place(covering, child!),
                child: child,
              ),
              child: Listener(
                onPointerSignal: _handlePointerSignal,
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: ClipRSuperellipse(
                    borderRadius: AppRadius.top(AppCorner.xxl),
                    child: Theme(
                      data: theme.copyWith(scaffoldBackgroundColor: sheetColor),
                      child: scoped,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetSurfacePainter extends CustomPainter {
  _SheetSurfacePainter({required this.color, required this.claimed})
    : super(repaint: claimed);

  final Color color;
  final ValueListenable<bool> claimed;

  @override
  void paint(Canvas canvas, Size size) {
    if (!claimed.value) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SheetSurfacePainter oldDelegate) =>
      color != oldDelegate.color || claimed != oldDelegate.claimed;
}

/// Out here the keyboard's motion skips a nested sheet's NavigatorResizable,
/// which learns a page's new size a frame late.
class _SheetKeyboard extends StatefulWidget {
  const _SheetKeyboard({
    required this.extent,
    required this.onChanged,
    required this.child,
  });

  final _SnapSheetExtent extent;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  State<_SheetKeyboard> createState() => _SheetKeyboardState();
}

class _SheetKeyboardState extends State<_SheetKeyboard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onChanged(MediaQuery.viewInsetsOf(context).bottom > 0);
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final keyboard = data.viewInsets.bottom;
    final child = MediaQuery(
      data: data.removeViewInsets(removeBottom: true),
      child: widget.child,
    );
    if (widget.extent.fitsContent) {
      return _FitSheetBox(
        extent: widget.extent,
        keyboard: keyboard,
        child: child,
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: child,
    );
  }
}

/// Where the sheet sits, in pixels off the bottom of the space it was given.
/// Its content is laid out at the height it shows, so every detent can scroll
/// to its end; only a drag below [minPixels] slides it off as [overhang].
class _SnapSheetExtent extends ChangeNotifier
    implements ValueListenable<double> {
  _SnapSheetExtent({
    required this.detents,
    required this.dismiss,
    required TickerProvider vsync,
    this.fitsContent = false,
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

  final bool fitsContent;

  final Future<void> Function() dismiss;

  final settling = ValueNotifier(false);

  late final ValueListenable<bool> open = _SheetOpen(this);

  late final AnimationController _settle;
  bool _disposed = false;
  double _available = 0;
  double _pixels = 0;
  double _settleFraction = 0;
  double _settleTarget = 0;

  /// Infinite while the content fills the height it was laid out to.
  double _fitHeight = double.infinity;
  bool _fitted = false;
  double _keyboard = 0;

  int _restStop = 0;
  int? _heldFrom;

  double get pixels => _pixels;

  bool get isSettling => _settle.isAnimating;

  List<double> get _stops => [
    for (final detent in detents)
      fitsContent
          ? math.min(detent * _available, _fitHeight + _keyboard)
          : detent * _available,
  ];

  double get minPixels => _stops.first;

  double get maxPixels => _stops.last;

  double get overhang => math.max(minPixels - _pixels, 0);

  double get height => math.max(minPixels, _pixels);

  @override
  double get value => overhang;

  bool get isAtMax => _pixels >= maxPixels - precisionErrorTolerance;

  bool get isOpen =>
      isAtMax ||
      (isSettling &&
          _settleFraction * _available >= maxPixels - precisionErrorTolerance);

  int? _stopAt(double pixels) {
    bool at(double stop) => (stop - pixels).abs() < precisionErrorTolerance;
    final stops = _stops;
    if (at(stops[_restStop])) {
      return _restStop;
    }
    final index = stops.indexWhere(at);
    return index < 0 ? null : index;
  }

  int? get _restingStop => isSettling ? null : _stopAt(_pixels);

  double get fitLimit {
    final stop = _restingStop;
    return math.min(
      stop == null ? height : detents[stop] * _available,
      detents.last * _available,
    );
  }

  /// Rescales silently: the sheet reads [pixels] later in the same build.
  void resize(double available) {
    if (_available == available) {
      return;
    }
    if (fitsContent) {
      if (_fitted) {
        _moveStops(() => _available = available);
      } else {
        _available = available;
        _pixels = minPixels;
      }
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
    _pixels = clampDouble(fraction * available, minPixels, maxPixels);
  }

  /// Follows the content's height silently, as [resize] does, unless a drag
  /// holds the sheet elsewhere.
  void fitContent(double height, double limit, double keyboard) {
    final fills = height >= limit - precisionErrorTolerance;
    final fit = !fills
        ? height
        : _fitHeight >= limit - precisionErrorTolerance
        ? _fitHeight
        : double.infinity;
    if (!_fitted) {
      _fitted = true;
      _fitHeight = fit;
      _keyboard = keyboard;
      _pixels = minPixels;
      return;
    }
    if (fit != _fitHeight || keyboard != _keyboard) {
      _moveStops(() {
        _fitHeight = fit;
        _keyboard = keyboard;
      });
    }
    if (keyboard == 0) {
      _releaseHold();
    }
  }

  void _moveStops(VoidCallback change) {
    final before = _stops;
    final resting = _restingStop;
    final settling = isSettling ? _stopAt(_settleTarget) : null;
    change();
    // Every retarget restarts the settle, whose first frame stands still.
    if (listEquals(before, _stops)) {
      return;
    }
    if (settling != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed && isSettling) {
          _settleTo(_stops[settling]);
        }
      });
    } else if (resting != null) {
      _restStop = resting;
      _pixels = _stops[resting];
    } else if (!isSettling) {
      _pixels = math.min(_pixels, maxPixels);
    }
  }

  void applyDelta(double delta) {
    _stopSettle();
    setPixels(_pixels + _withFriction(delta));
  }

  void setPixels(double value) {
    if (value == _pixels) {
      return;
    }
    _pixels = value;
    _restStop = _stopAt(value) ?? _restStop;
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

  /// Keeps a fit sheet resting where its stops meet at the tallest as the
  /// keyboard parts them, until it is gone and they meet again.
  void holdAtMax() {
    if (!fitsContent) {
      return;
    }
    _heldFrom ??= _restStop;
    _restStop = detents.length - 1;
  }

  void _releaseHold() {
    final from = _heldFrom;
    if (from == null || isSettling) {
      return;
    }
    _heldFrom = null;
    final stops = _stops;
    if (_restStop == stops.length - 1 &&
        (stops[from] - stops.last).abs() < precisionErrorTolerance) {
      _restStop = from;
    }
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

  void _stopSettle() {
    _settle.stop();
    settling.value = false;
  }

  void _settleTo(double target, {double? velocity}) {
    final carried = velocity ?? (isSettling ? _settle.velocity : 0.0);
    _stopSettle();
    _settleFraction = _available == 0 ? 0 : target / _available;
    _settleTarget = target;
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

/// Layout moves the detents silently, so this never caches isOpen.
class _SheetOpen implements ValueListenable<bool> {
  _SheetOpen(this._extent)
    : _changes = Listenable.merge([_extent, _extent.settling]);

  final _SnapSheetExtent _extent;
  final Listenable _changes;

  @override
  bool get value => _extent.isOpen;

  @override
  void addListener(VoidCallback listener) => _changes.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _changes.removeListener(listener);
}

class _SnapSheetScrollController extends ScrollController
    with SheetScrollController {
  _SnapSheetScrollController({required this.extent, super.initialScrollOffset});

  final _SnapSheetExtent extent;

  @override
  ValueListenable<bool> get sheetOpen => extent.open;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SnapSheetScrollPosition(
      physics: _SheetContentPhysics(parent: physics),
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
class _SnapSheetScrollPosition extends ScrollPositionWithSingleContext
    with ScrubbableScrollPosition {
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

  // A reverse list counts its own axis the other way round from the sheet,
  // so both readings flip with it. Positive means the sheet grows; the map is
  // its own inverse, so it also turns a sheet delta back into a content one.
  double _sheetDelta(double delta) => _isReversed ? delta : -delta;

  double _sheetVelocity(double velocity) => _isReversed ? -velocity : velocity;

  bool _sheetTakes(double sheetDelta) {
    if (isScrubbing || _contentScrolled) {
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

/// Keeps a drag that grows the sheet alive once the content fits its viewport.
class _SheetContentPhysics extends ScrollPhysics {
  const _SheetContentPhysics({super.parent});

  @override
  _SheetContentPhysics applyTo(ScrollPhysics? ancestor) {
    return _SheetContentPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return (position is _SnapSheetScrollPosition && position._isDragged) ||
        super.shouldAcceptUserOffset(position);
  }
}

/// Keeps taps off the rows while the sheet settles, as a fling does.
class _SettlingScrollActivity extends IdleScrollActivity {
  _SettlingScrollActivity(super.delegate);

  @override
  bool get shouldIgnorePointer => true;
}

/// Lays the content out at its own height, up to the fit limit, and rests the
/// sheet there; a drag past that height stretches the surface below it.
/// Never tight nor twice a frame: a nested sheet's NavigatorResizable asserts
/// on the first and relays out without end on the second.
class _FitSheetBox extends SingleChildRenderObjectWidget {
  const _FitSheetBox({
    required this.extent,
    required this.keyboard,
    required super.child,
  });

  final _SnapSheetExtent extent;
  final double keyboard;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFitSheetBox(extent: extent, keyboard: keyboard);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFitSheetBox renderObject,
  ) {
    renderObject
      ..extent = extent
      ..keyboard = keyboard;
  }
}

class _RenderFitSheetBox extends RenderProxyBox {
  _RenderFitSheetBox({
    required _SnapSheetExtent extent,
    required double keyboard,
  }) : _extent = extent,
       _keyboard = keyboard;

  _SnapSheetExtent _extent;
  double _keyboard;

  set keyboard(double value) {
    if (value == _keyboard) {
      return;
    }
    _keyboard = value;
    markNeedsLayout();
  }

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
      Size(
        constraints.maxWidth,
        math.min(_extent.fitLimit, constraints.maxHeight),
      ),
    );
  }

  @override
  void performLayout() {
    final child = this.child!;
    final width = constraints.maxWidth;
    final limit = math.min(_extent.fitLimit, constraints.maxHeight);
    final keyboard = math.min(_keyboard, limit);
    child.layout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        maxHeight: limit - keyboard,
      ),
      parentUsesSize: true,
    );
    final natural = child.size.height;
    _extent.fitContent(natural, limit - keyboard, keyboard);
    size = Size(
      width,
      constraints.constrainHeight(math.max(natural + keyboard, _extent.height)),
    );
  }
}
