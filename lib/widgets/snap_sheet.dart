import 'dart:async';
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

const _dismissVelocity = 700.0;

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
    this.collapsedDetent,
    this.initialScrollOffset = 0,
    this.sheetController,
  });

  final SnapSheetBuilder builder;
  final CapturedThemes capturedThemes;
  final Color sheetBarrierColor;
  final List<double> detents;

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
        collapsedDetent: collapsedDetent,
        initialScrollOffset: initialScrollOffset,
        animation: animation,
        controller: sheetController,
        scrimColor: collapsedDetent == null ? null : sheetBarrierColor,
        builder: builder,
      ),
    );
  }
}

class _SnapSheet extends StatefulWidget {
  const _SnapSheet({
    required this.detents,
    required this.collapsedDetent,
    required this.initialScrollOffset,
    required this.animation,
    required this.controller,
    required this.scrimColor,
    required this.builder,
  });

  final List<double> detents;
  final double? collapsedDetent;
  final double initialScrollOffset;
  final Animation<double> animation;
  final SnapSheetController? controller;
  final Color? scrimColor;
  final SnapSheetBuilder builder;

  @override
  State<_SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<_SnapSheet>
    with SingleTickerProviderStateMixin {
  late final _extent = _SnapSheetExtent(
    detents: widget.detents,
    collapsedDetent: widget.collapsedDetent,
    vsync: this,
    dismiss: () => Navigator.of(context).maybePop(),
    onRest: _publishRest,
  );
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

  bool _keyboardShown = false;

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
      widget.controller?._publish(0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keyboardShown = MediaQuery.viewInsetsOf(context).bottom > 0;
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
                          child: SheetSettlingScope(
                            settling: _extent.settling,
                            child: widget.builder(context, _scrollController),
                          ),
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
    this.collapsedDetent,
  }) {
    _settle = AnimationController.unbounded(vsync: vsync)
      ..addListener(() => setPixels(_settle.value))
      ..addStatusListener((_) {
        if (!_settle.isAnimating) {
          settling.value = false;
        }
      });
  }

  /// Rest heights as fractions of [_available], shortest first.
  final List<double> detents;

  final double? collapsedDetent;

  final Future<bool> Function() dismiss;

  final ValueChanged<double> onRest;

  final settling = ValueNotifier(false);

  late final AnimationController _settle;
  bool _disposed = false;
  double _available = 0;
  double _pixels = 0;
  double _settleFraction = 0;

  double get pixels => _pixels;

  bool get isSettling => _settle.isAnimating;

  double get minPixels => detents.first * _available;

  double get maxPixels => detents.last * _available;

  double get overhang => math.max(minPixels - _pixels, 0);

  double get height => math.max(minPixels, _pixels);

  double get _floorPixels => (collapsedDetent ?? detents.first) * _available;

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
      (isSettling && _settleFraction >= detents.last - precisionErrorTolerance);

  /// Rescales silently: the sheet reads [pixels] later in the same build.
  void resize(double available) {
    if (_available == available) {
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
      _settleTo(_targetFor(velocity));
      return;
    }
    if (overhang > 0 &&
        (velocity <= -_dismissVelocity || overhang >= minPixels / 2)) {
      _stopSettle();
      unawaited(
        dismiss().then((dismissed) {
          if (!dismissed) {
            _settleTo(minPixels);
          }
        }),
      );
      return;
    }
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

  void _settleTo(double target) {
    _stopSettle();
    _settleFraction = _available == 0 ? 0 : target / _available;
    onRest(target);
    if ((target - _pixels).abs() < precisionErrorTolerance) {
      setPixels(target);
      return;
    }
    _settle
      ..value = _pixels
      ..animateTo(target, duration: _settleDuration, curve: _settleCurve);
    settling.value = true;
  }

  @override
  void dispose() {
    _disposed = true;
    _settle.dispose();
    settling.dispose();
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
