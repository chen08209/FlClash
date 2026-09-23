import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';
import 'sheet.dart';

/// Receives the sheet's own scroll controller, or null where the sheet has no
/// detents to drag between and the content keeps its own controller.
typedef SnapSheetBuilder =
    Widget Function(BuildContext context, ScrollController? controller);

/// The heights a snap sheet rests at, as a fraction of the space it gets.
const snapSheetDetents = [0.5, 0.9];

const _settleDuration = Duration(milliseconds: 400);
const _settleCurve = Curves.easeInOutCubicEmphasized;

const _bounceExtent = 120.0;
const _bounceResistance = 6.0;

class SnapSheetRoute<T> extends PopupRoute<T> {
  SnapSheetRoute({
    required this.builder,
    required this.capturedThemes,
    required this.sheetBarrierColor,
    required this.barrierLabel,
    this.detents = snapSheetDetents,
    this.initialScrollOffset = 0,
  });

  final SnapSheetBuilder builder;
  final CapturedThemes capturedThemes;
  final Color sheetBarrierColor;
  final List<double> detents;
  final double initialScrollOffset;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => sheetBarrierColor;

  @override
  bool get barrierDismissible => true;

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
        initialScrollOffset: initialScrollOffset,
        animation: animation,
        builder: builder,
      ),
    );
  }
}

class _SnapSheet extends StatefulWidget {
  const _SnapSheet({
    required this.detents,
    required this.initialScrollOffset,
    required this.animation,
    required this.builder,
  });

  final List<double> detents;
  final double initialScrollOffset;
  final Animation<double> animation;
  final SnapSheetBuilder builder;

  @override
  State<_SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<_SnapSheet>
    with SingleTickerProviderStateMixin {
  late final _extent = _SnapSheetExtent(detents: widget.detents, vsync: this);
  late final _scrollController = _SnapSheetScrollController(
    extent: _extent,
    initialScrollOffset: widget.initialScrollOffset,
  );
  late final _entrance = widget.animation.drive(
    Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).chain(CurveTween(curve: Easing.emphasizedDecelerate)),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    _extent.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _extent.applyDelta(-details.delta.dy);
  }

  void _handleDragEnd(DragEndDetails details) {
    _extent.settleAt(-details.velocity.pixelsPerSecond.dy);
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor = context.colorScheme.surfaceContainerLow;
    final theme = Theme.of(context);
    return SafeArea(
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
                    child: SizedBox(height: _extent.height, child: child),
                  ),
                );
              },
              child: GestureDetector(
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                child: ClipRSuperellipse(
                  borderRadius: AppRadius.top(AppCorner.xxl),
                  child: Theme(
                    data: theme.copyWith(scaffoldBackgroundColor: sheetColor),
                    child: ColoredBox(
                      color: sheetColor,
                      child: SheetProvider(
                        type: SheetType.bottomSheet,
                        child: SheetOverhangScope(
                          overhang: _extent,
                          child: widget.builder(context, _scrollController),
                        ),
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
  }
}

/// Where the sheet sits, in pixels off the bottom of the space it was given.
/// Its content is laid out at the height it shows, so every detent can scroll
/// to its end; only a drag below [minPixels] slides it off as [overhang].
class _SnapSheetExtent extends ChangeNotifier
    implements ValueListenable<double> {
  _SnapSheetExtent({required this.detents, required TickerProvider vsync}) {
    _settle = AnimationController.unbounded(vsync: vsync)
      ..addListener(() => setPixels(_settle.value));
  }

  /// Rest heights as fractions of [_available], shortest first.
  final List<double> detents;

  late final AnimationController _settle;
  double _available = 0;
  double _pixels = 0;
  double _settleFraction = 0;

  double get pixels => _pixels;

  bool get isSettling => _settle.isAnimating;

  double get minPixels => detents.first * _available;

  double get maxPixels => detents.last * _available;

  double get overhang => math.max(minPixels - _pixels, 0);

  double get height => math.max(minPixels, _pixels);

  @override
  double get value => overhang;

  bool get isAtMax => _pixels >= maxPixels - precisionErrorTolerance;

  /// Rescales silently: the sheet reads [pixels] later in the same build.
  void resize(double available) {
    if (_available == available) {
      return;
    }
    var fraction = _available == 0 ? detents.first : _pixels / _available;
    if (isSettling) {
      _settle.stop();
      fraction = _settleFraction;
    }
    _available = available;
    _pixels = clampDouble(fraction * available, minPixels, maxPixels);
  }

  void applyDelta(double delta) {
    _settle.stop();
    setPixels(_pixels + _withFriction(delta));
  }

  void setPixels(double value) {
    if (value == _pixels) {
      return;
    }
    _pixels = value;
    notifyListeners();
  }

  /// Thins a drag past either detent as smooth_sheets' bouncing physics does.
  double _withFriction(double delta) {
    var moved = _pixels;
    var consumed = 0.0;
    while (consumed.abs() < delta.abs()) {
      final fragment = clampDouble(delta - consumed, -kTouchSlop, kTouchSlop);
      final next = moved + fragment;
      final past = delta < 0
          ? math.max(minPixels - next, 0.0)
          : math.max(next - maxPixels, 0.0);
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
    _settleTo(_targetFor(velocity));
  }

  void settleTowards(double direction) {
    final target = _targetFor(direction.sign * kMinFlingVelocity);
    if (isSettling &&
        (target - _settleFraction * _available).abs() <
            precisionErrorTolerance) {
      return;
    }
    _settleTo(target);
  }

  void _settleTo(double target) {
    _settle.stop();
    _settleFraction = target / _available;
    if ((target - _pixels).abs() < precisionErrorTolerance) {
      setPixels(target);
      return;
    }
    _settle
      ..value = _pixels
      ..animateTo(target, duration: _settleDuration, curve: _settleCurve);
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  double _targetFor(double velocity) {
    final stops = [for (final detent in detents) detent * _available];
    if (velocity >= kMinFlingVelocity) {
      return stops.firstWhere(
        (stop) => stop > _pixels + precisionErrorTolerance,
        orElse: () => maxPixels,
      );
    }
    if (velocity <= -kMinFlingVelocity) {
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
class _SnapSheetScrollPosition extends ScrollPositionWithSingleContext {
  _SnapSheetScrollPosition({
    required this.extent,
    required super.physics,
    required super.context,
    super.initialPixels,
    super.oldPosition,
  });

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
    return sheetDelta < 0 || !extent.isAtMax;
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
    if (extent.isSettling) {
      return;
    }
    final sheetDelta = -_sheetDelta(delta);
    if (_sheetTakes(sheetDelta)) {
      extent.settleTowards(sheetDelta);
      return;
    }
    super.pointerScroll(delta);
  }

  @override
  void goBallistic(double velocity) {
    if (!_sheetHeld) {
      super.goBallistic(velocity);
      return;
    }
    _sheetHeld = false;
    extent.settleAt(_sheetVelocity(velocity));
    super.goBallistic(0);
  }
}
