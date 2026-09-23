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
  late final _extent = _SnapSheetExtent(
    detents: widget.detents,
    vsync: this,
    dismiss: () => Navigator.of(context).maybePop(),
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

  final Future<bool> Function() dismiss;

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
    _pixels = clampDouble(fraction * available, minPixels, maxPixels);
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

  void _stopSettle() {
    _settle.stop();
    settling.value = false;
  }

  void _settleTo(double target) {
    _stopSettle();
    _settleFraction = _available == 0 ? 0 : target / _available;
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
