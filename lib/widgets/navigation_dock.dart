import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const double _barHeight = 64;
const double _barPadding = 4;
const double _edgeMargin = 20;
const double _shadowRoom = 8;
const double _fabGap = 8;
const double _maxItemExtent = 72;
const double _iconSize = 24;
const double _trailingIconSize = 28;
const double _labelGap = 2;
const double _labelInset = 2;
const double _labelSize = 10;
const double _minLabelSize = 9;
const double _pressGrowth = 1 / 8;
const double _maxPressGrowth = 16;
const double _lensGrowth = 14;
const double _lensMagnify = 0.12;
const double _hoverMagnet = 0.2;
const double _hoverParallax = 0.5;
const double _hoverAlpha = 0.08;
const double _hoverSwell = 0.4;
const double _jellySpeed = 8;
const double _jellyStretch = 0.25;
const double _overdrag = 0.35;
const double _pullLimit = 7 / 32;
const double _pullStretch = 0.5;
const _flingProjection = Duration(milliseconds: 100);
const _slotDuration = Duration(milliseconds: 500);
const _slotExitDuration = Duration(milliseconds: 220);
const double _slotEnterScale = 0.5;
const double _slotExitScale = 0.7;
const double _slotBlur = 6;
const _slotRevealCurve = Interval(0, 0.5, curve: Curves.easeOut);
// No bounce: an overshoot would drive the slot's width below zero.
final _slotSizeCurve = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 420),
  ),
  seconds: 0.5,
);
final _slotPopCurve = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
    bounce: 0.3,
  ),
  seconds: 0.5,
);
final _trackSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 120),
);
final _liftSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 280),
  bounce: 0.2,
);
final _settleSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 500),
  bounce: 0.32,
);
final _hoverSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 260),
  bounce: 0.18,
);
final _fadeSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 200),
);

double _rubberBand(double overshoot, double limit) {
  final pull = 1 - 1 / (overshoot.abs() * 0.55 / limit + 1);
  return limit * pull * overshoot.sign;
}

/// The lens's box, measured from the start edge of the destination at 0.
Rect _lensRect({
  required double position,
  required double velocity,
  required double extent,
  required double height,
  required double lift,
}) {
  final stretch =
      (velocity.abs() / _jellySpeed).clamp(0.0, 1.0) * _jellyStretch;
  final growth = _lensGrowth * 2 * lift;
  final width = (extent + growth) * (1 + stretch);
  final lensHeight = (height + growth) * (1 - stretch / 2);
  return Rect.fromLTWH(
    (position + 0.5) * extent - width / 2,
    (height - lensHeight) / 2,
    width,
    lensHeight,
  );
}

/// A value that springs toward a target the finger may move every frame.
///
/// [AnimationController.animateWith] restarts its ticker, whose first frame
/// reads no elapsed time, so retargeting it on every pointer move holds the
/// value still for as long as the finger keeps moving.
class _Spring extends ChangeNotifier implements ValueListenable<double> {
  _Spring(TickerProvider vsync, this._value) {
    _ticker = vsync.createTicker(_tick);
  }

  late final Ticker _ticker;
  double _value;
  double _target = 0;
  SpringSimulation? _simulation;
  double _now = 0;
  double _start = 0;

  @override
  double get value => _value;

  double get target => _simulation == null ? _value : _target;

  double get velocity => _simulation?.dx(_now - _start) ?? 0;

  void springTo(double target, SpringDescription spring) {
    _simulation = SpringSimulation(spring, _value, target, velocity);
    _target = target;
    if (_ticker.isActive) {
      _start = _now;
      return;
    }
    _now = _start = 0;
    _ticker.start();
  }

  void jumpTo(double value) {
    _simulation = null;
    _ticker.stop();
    _value = value;
    notifyListeners();
  }

  void _tick(Duration elapsed) {
    _now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final simulation = _simulation!;
    final time = _now - _start;
    if (simulation.isDone(time)) {
      _value = _target;
      _simulation = null;
      _ticker.stop();
    } else {
      _value = simulation.x(time);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

// A soft, wide drop in the manner of iOS rather than a Material elevation.
List<BoxShadow> _dockShadows(ColorScheme colorScheme) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.08 * strength),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

({double width, double height}) _measureLabel(
  BuildContext context,
  String label,
  TextStyle? style,
) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
    maxLines: 1,
  )..layout();
  final size = (width: painter.width, height: painter.height);
  painter.dispose();
  return size;
}

class NavigationDockDestination {
  const NavigationDockDestination({required this.glyph, required this.label});

  final Glyph glyph;
  final String label;
}

/// Marks a phone's home page, whose foot the navigation dock holds.
class DockedPageScope extends InheritedWidget {
  const DockedPageScope({
    super.key,
    required this.docked,
    required super.child,
  });

  final bool docked;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DockedPageScope>()?.docked ??
      false;

  @override
  bool updateShouldNotify(DockedPageScope oldWidget) =>
      docked != oldWidget.docked;
}

class NavigationDock extends StatelessWidget {
  const NavigationDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.trailing,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? trailing;

  /// Whether [context] sits in the dock's button slot, where a button keeps
  /// to a circle the bar's height instead of growing a label.
  static bool isDocked(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DockedMarker>() != null;

  static double heightOf(BuildContext context) {
    return _barHeight +
        MediaQuery.textScalerOf(context).scale(_labelSize) -
        _labelSize;
  }

  static double _bottomMarginOf(BuildContext context) =>
      math.max(_edgeMargin, MediaQuery.paddingOf(context).bottom);

  /// The room content scrolling under the dock leaves at its foot.
  static double insetOf(BuildContext context) =>
      heightOf(context) + _bottomMarginOf(context);

  @override
  Widget build(BuildContext context) {
    final height = heightOf(context);
    final dock = Padding(
      padding: EdgeInsets.fromLTRB(
        _edgeMargin,
        _shadowRoom,
        _edgeMargin,
        _bottomMarginOf(context),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      destinations.length * _maxItemExtent + _barPadding * 2,
                ),
                child: FloatingNavigationBar(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                ),
              ),
            ),
            _DockTrailing(height: height, child: trailing),
          ],
        ),
      ),
    );
    return RepaintBoundary(child: dock);
  }
}

class _DockedMarker extends InheritedWidget {
  const _DockedMarker({required super.child});

  @override
  bool updateShouldNotify(_DockedMarker oldWidget) => false;
}

class _DockTrailing extends StatelessWidget {
  const _DockTrailing({required this.height, required this.child});

  final double height;
  final Widget? child;

  ThemeData _dockedTheme(ThemeData theme) {
    return theme.copyWith(
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        shape: AppShape.full,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        sizeConstraints: BoxConstraints.tightFor(width: height, height: height),
        iconSize: _trailingIconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = this.child;
    return AnimatedSize(
      duration: _slotDuration,
      curve: _slotSizeCurve,
      alignment: AlignmentDirectional.centerEnd,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        duration: _slotDuration,
        reverseDuration: _slotExitDuration,
        transitionBuilder: (child, animation) =>
            _SlotMaterialize(animation: animation, child: child),
        // A leaving button takes no width, so the bar grows into its place
        // while it dissolves instead of waiting for it.
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerEnd,
          clipBehavior: Clip.none,
          children: [
            for (final child in previous)
              SizedBox(
                width: 0,
                child: OverflowBox(
                  alignment: AlignmentDirectional.centerEnd,
                  maxWidth: double.infinity,
                  child: IgnorePointer(child: child),
                ),
              ),
            ?current,
          ],
        ),
        child: child == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: _fabGap),
                child: ElasticButton(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.full,
                      shadows: _dockShadows(theme.colorScheme),
                    ),
                    child: Builder(
                      builder: (context) => Theme(
                        data: _dockedTheme(Theme.of(context)),
                        child: _DockedMarker(child: child),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SlotMaterialize extends StatelessWidget {
  const _SlotMaterialize({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final entering = animation.status != AnimationStatus.reverse;
        final scale = entering
            ? lerpDouble(_slotEnterScale, 1, _slotPopCurve.transform(t))!
            : lerpDouble(_slotExitScale, 1, Curves.easeOutCubic.transform(t))!;
        final reveal = entering
            ? _slotRevealCurve.transform(t)
            : Curves.easeOut.transform(t);
        final blur = _slotBlur * (1 - reveal);
        return Opacity(
          opacity: reveal,
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              enabled: blur > 0.05,
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Grows under a press and stretches after a dragging finger, springing back
/// on release, as the bar's lens does.
///
/// The press only paints: layout, hit testing, and anything anchored to the
/// child, such as a popup menu or a tooltip, see it at rest.
class ElasticPress extends StatefulWidget {
  const ElasticPress({super.key, this.enabled = true, required this.child});

  /// Leaves a press on the button inside to the swell alone.
  static const buttonStyle = ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateMapper<Color?>({
      WidgetState.pressed: Colors.transparent,
    }),
  );

  final bool enabled;
  final Widget child;

  @override
  State<ElasticPress> createState() => _ElasticPressState();
}

class _ElasticPressState extends State<ElasticPress>
    with TickerProviderStateMixin {
  late final _Spring _lift = _Spring(this, 0);
  late final _Spring _pullX = _Spring(this, 0);
  late final _Spring _pullY = _Spring(this, 0);
  late final Listenable _motion = Listenable.merge([_lift, _pullX, _pullY]);
  int? _pointer;
  Offset _origin = Offset.zero;

  @override
  void dispose() {
    _lift.dispose();
    _pullX.dispose();
    _pullY.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled ||
        _pointer != null ||
        event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.localPosition;
    _lift.springTo(1, _liftSpring);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final limit = context.size!.shortestSide * _pullLimit;
    final pull = event.localPosition - _origin;
    _pullX.springTo(_rubberBand(pull.dx, limit), _trackSpring);
    _pullY.springTo(_rubberBand(pull.dy, limit), _trackSpring);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    _lift.springTo(0, _settleSpring);
    _pullX.springTo(0, _settleSpring);
    _pullY.springTo(0, _settleSpring);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (_, child) => _PressTransform(
          lift: _lift.value,
          pull: Offset(_pullX.value, _pullY.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Leaves a press on the filled button or FAB inside to [ElasticPress]; one
/// whose style sets a foreground color merges [ElasticPress.buttonStyle].
class ElasticButton extends StatelessWidget {
  const ElasticButton({super.key, this.enabled = true, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElasticPress(
      enabled: enabled,
      child: Theme(
        data: theme.copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: IconTheme(
          data: IconTheme.of(context),
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: ElasticPress.buttonStyle.merge(
                IconButtonTheme.of(context).style,
              ),
            ),
            child: FilledButtonTheme(
              data: FilledButtonThemeData(
                style: ElasticPress.buttonStyle.merge(
                  FilledButtonTheme.of(context).style,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PressTransform extends SingleChildRenderObjectWidget {
  const _PressTransform({required this.lift, required this.pull, super.child});

  final double lift;
  final Offset pull;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPressTransform(lift: lift, pull: pull);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPressTransform renderObject,
  ) {
    renderObject
      ..lift = lift
      ..pull = pull;
  }
}

class _RenderPressTransform extends RenderProxyBox {
  _RenderPressTransform({required double lift, required Offset pull})
    : _lift = lift,
      _pull = pull;

  double _lift;
  Offset _pull;

  set lift(double value) {
    if (value == _lift) {
      return;
    }
    _lift = value;
    markNeedsPaint();
  }

  set pull(Offset value) {
    if (value == _pull) {
      return;
    }
    _pull = value;
    markNeedsPaint();
  }

  Matrix4 get _transform {
    final swell =
        1 +
        _lift * math.min(_pressGrowth * 2, _maxPressGrowth / size.longestSide);
    final scaleX = swell * (1 + _pull.dx.abs() / size.width * _pullStretch);
    final scaleY = swell * (1 + _pull.dy.abs() / size.height * _pullStretch);
    final center = size.center(Offset.zero);
    return Matrix4.diagonal3Values(scaleX, scaleY, 1)..setTranslationRaw(
      center.dx * (1 - scaleX) + _pull.dx,
      center.dy * (1 - scaleY) + _pull.dy,
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty || (_lift == 0 && _pull == .zero)) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }
}

/// A floating pill of destinations whose selection is a lens that springs
/// between them, after iOS's tab bar. Pressing swells the bar as
/// [ElasticPress] does and lifts the lens under the finger; dragging slides
/// the lens across the bar, selecting where it is let go, and stretches the
/// bar past either end.
class FloatingNavigationBar extends StatefulWidget {
  const FloatingNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar>
    with TickerProviderStateMixin {
  late final _Spring _lens = _Spring(this, _selectedIndex.toDouble());
  late final _Spring _lift = _Spring(this, 0);
  late final _Spring _hover = _Spring(this, 0);
  late final _Spring _hoverShow = _Spring(this, 0);
  late final _Spring _swell = _Spring(this, 0);
  late final _Spring _stretch = _Spring(this, 0);
  late final Listenable _barMotion = Listenable.merge([_swell, _stretch]);
  late final Listenable _motion = Listenable.merge([_lens, _lift]);
  late final Listenable _hoverMotion = Listenable.merge([_hover, _hoverShow]);
  int? _pointer;
  int? _pressedIndex;
  double _pressX = 0;
  bool _dragging = false;
  VelocityTracker? _tracker;
  Offset? _cursor;
  final ValueNotifier<double?> _hoverAt = ValueNotifier(null);

  int get _lastIndex => math.max(0, widget.destinations.length - 1);

  int get _selectedIndex => widget.selectedIndex.clamp(0, _lastIndex);

  @override
  void didUpdateWidget(covariant FloatingNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pressedIndex == null && _lens.target != _selectedIndex) {
      _lens.springTo(_selectedIndex.toDouble(), _settleSpring);
    }
  }

  @override
  void dispose() {
    _lens.dispose();
    _lift.dispose();
    _hover.dispose();
    _hoverShow.dispose();
    _swell.dispose();
    _stretch.dispose();
    _hoverAt.dispose();
    super.dispose();
  }

  double _positionAt(Offset localPosition) {
    final width = context.size!.width;
    final dx = Directionality.of(context) == TextDirection.ltr
        ? localPosition.dx
        : width - localPosition.dx;
    final extent = (width - _barPadding * 2) / widget.destinations.length;
    final position = (dx - _barPadding) / extent - 0.5;
    if (position < 0) {
      return _rubberBand(position, _overdrag);
    }
    if (position > _lastIndex) {
      return _lastIndex + _rubberBand(position - _lastIndex, _overdrag);
    }
    return position;
  }

  int _indexAt(double position) => position.round().clamp(0, _lastIndex);

  void _showHover() {
    final cursor = _cursor;
    if (cursor == null || _pointer != null || widget.destinations.isEmpty) {
      return;
    }
    final position = _positionAt(cursor);
    final index = _indexAt(position);
    final target = index + (position - index) * _hoverMagnet;
    _hoverAt.value = position;
    if (_hoverShow.target == 0 && _hoverShow.value == 0) {
      _hover.jumpTo(target);
    } else {
      _hover.springTo(target, _hoverSpring);
    }
    _hoverShow.springTo(1, _fadeSpring);
  }

  void _settleSwell() {
    final target = _cursor == null ? 0.0 : _hoverSwell;
    if (_pointer == null && _swell.target != target) {
      _swell.springTo(target, _settleSpring);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    // The engine synthesizes a hover before a touch lands, and the touch
    // pointer lingers until removed, so a tap would leave the highlight on.
    if (event.kind == PointerDeviceKind.touch) {
      return;
    }
    _cursor = event.localPosition;
    _showHover();
    _settleSwell();
  }

  void _handleExit(PointerExitEvent event) {
    _cursor = null;
    _hoverShow.springTo(0, _fadeSpring);
    _hoverAt.value = null;
    _settleSwell();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _tracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.localPosition);
    _hoverShow.springTo(0, _fadeSpring);
    _hoverAt.value = null;
    _swell.springTo(1, _liftSpring);
    _press(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _pointer) {
      _tracker?.addPosition(event.timeStamp, event.localPosition);
      _slide(event.localPosition);
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    final tracker = _tracker;
    _tracker = null;
    if (event is PointerUpEvent && tracker != null) {
      _fling(tracker.getVelocity().pixelsPerSecond.dx);
    }
    _release(commit: event is PointerUpEvent);
    _stretch.springTo(0, _settleSpring);
    if (_cursor != null) {
      _cursor = event.localPosition;
      _showHover();
    }
    _settleSwell();
  }

  void _press(Offset localPosition) {
    if (widget.destinations.isEmpty) {
      return;
    }
    final index = _indexAt(_positionAt(localPosition));
    _pressedIndex = index;
    _pressX = localPosition.dx;
    _dragging = false;
    _lift.springTo(1, _liftSpring);
    _lens.springTo(index.toDouble(), _settleSpring);
  }

  void _slide(Offset localPosition) {
    if (_pressedIndex == null) {
      return;
    }
    if (!_dragging) {
      if ((localPosition.dx - _pressX).abs() < kTouchSlop) {
        return;
      }
      _dragging = true;
    }
    final size = context.size!;
    final overshoot =
        localPosition.dx - localPosition.dx.clamp(0.0, size.width);
    _stretch.springTo(
      _rubberBand(overshoot, size.shortestSide * _pullLimit),
      _trackSpring,
    );
    final position = _positionAt(localPosition);
    _lens.springTo(position, _trackSpring);
    final index = _indexAt(position);
    if (index != _pressedIndex) {
      HapticFeedback.selectionClick();
      _pressedIndex = index;
    }
  }

  /// Carries a drag let go mid-flick on to the next destination, at most one
  /// past the one under the finger.
  void _fling(double velocityX) {
    final pressed = _pressedIndex;
    if (!_dragging || pressed == null) {
      return;
    }
    final extent =
        (context.size!.width - _barPadding * 2) / widget.destinations.length;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final lead =
        velocityX /
        extent *
        direction *
        _flingProjection.inMicroseconds /
        Duration.microsecondsPerSecond;
    final index = (_lens.target + lead)
        .round()
        .clamp(pressed - 1, pressed + 1)
        .clamp(0, _lastIndex);
    if (index != pressed) {
      HapticFeedback.selectionClick();
      _pressedIndex = index;
    }
  }

  void _release({required bool commit}) {
    final index = _pressedIndex;
    if (index == null) {
      return;
    }
    _pressedIndex = null;
    _dragging = false;
    _lift.springTo(0, _settleSpring);
    if (!commit) {
      _lens.springTo(_selectedIndex.toDouble(), _settleSpring);
      return;
    }
    _lens.springTo(index.toDouble(), _settleSpring);
    if (index != widget.selectedIndex) {
      widget.onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      fontSize: _labelSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
    final labels = [
      for (final destination in widget.destinations)
        _measureLabel(context, destination.label, labelStyle),
    ];
    final widest = labels.fold(
      0.0,
      (width, label) => math.max(width, label.width),
    );
    final lineHeight = labels.fold(
      0.0,
      (height, label) => math.max(height, label.height),
    );
    final bar = DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.full,
        shadows: _dockShadows(colorScheme),
      ),
      child: Material(
        color: colorScheme.surfaceContainer,
        shape: AppShape.full,
        // Raw pointers rather than recognizers: a drag has nothing to win the
        // arena from, and a tap waiting on one lifts the lens late.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: MouseRegion(
            onHover: _handleHover,
            onExit: _handleExit,
            child: Padding(
              padding: const EdgeInsets.all(_barPadding),
              // Above the LayoutBuilder: rebuilding anything under one relays
              // it out, and that repaint would otherwise reach the whole dock.
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final extent =
                        constraints.maxWidth /
                        math.max(1, widget.destinations.length);
                    final room = extent - _labelInset * 2;
                    final labelScale = widest <= room
                        ? 1.0
                        : math.max(room / widest, _minLabelSize / _labelSize);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (widget.destinations.isNotEmpty)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (_, _) => _Lens(
                              position: _lens.value,
                              velocity: _lens.velocity,
                              extent: extent,
                              height: constraints.maxHeight,
                              lift: _lift.value,
                            ),
                          ),
                        if (widget.destinations.isNotEmpty)
                          AnimatedBuilder(
                            animation: _hoverMotion,
                            builder: (_, _) => _HoverHighlight(
                              position: _hover.value,
                              extent: extent,
                              opacity: _hoverShow.value,
                            ),
                          ),
                        Row(
                          children: [
                            for (final (index, destination)
                                in widget.destinations.indexed)
                              Expanded(
                                child: _FloatingBarItem(
                                  destination: destination,
                                  selected: index == _selectedIndex,
                                  index: index,
                                  lens: _lens,
                                  hoverAt: _hoverAt,
                                  extent: extent,
                                  lift: _lift,
                                  labelStyle: labelStyle?.copyWith(
                                    fontSize: _labelSize * labelScale,
                                  ),
                                  labelHeight: lineHeight,
                                  labelOverflows:
                                      labels[index].width * labelScale > room,
                                  onActivate: () => widget.onSelected(index),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _barMotion,
      builder: (_, child) => _PressTransform(
        lift: _swell.value,
        pull: Offset(_stretch.value, 0),
        child: child,
      ),
      child: bar,
    );
  }
}

/// The pointer's highlight, drawn to the destination under it and leaning a
/// little toward the cursor, as iPadOS highlights a tab bar item; the item
/// under it follows the cursor half as far.
class _HoverHighlight extends StatelessWidget {
  const _HoverHighlight({
    required this.position,
    required this.extent,
    required this.opacity,
  });

  final double position;
  final double extent;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final alpha = _hoverAlpha * opacity.clamp(0.0, 1.0);
    if (alpha == 0) {
      return const SizedBox.shrink();
    }
    return Positioned.directional(
      textDirection: Directionality.of(context),
      start: position * extent,
      top: 0,
      bottom: 0,
      width: extent,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: alpha),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens({
    required this.position,
    required this.velocity,
    required this.extent,
    required this.height,
    required this.lift,
  });

  final double position;
  final double velocity;
  final double extent;
  final double height;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final rect = _lensRect(
      position: position,
      velocity: velocity,
      extent: extent,
      height: height,
      lift: lift,
    );
    return PositionedDirectional(
      start: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Color.alphaBlend(
            colorScheme.onSecondaryContainer.withValues(
              alpha: 0.08 * lift.clamp(0.0, 1.0),
            ),
            colorScheme.secondaryContainer,
          ),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _FloatingBarItem extends StatefulWidget {
  const _FloatingBarItem({
    required this.destination,
    required this.selected,
    required this.index,
    required this.lens,
    required this.hoverAt,
    required this.extent,
    required this.lift,
    required this.labelStyle,
    required this.labelHeight,
    required this.labelOverflows,
    required this.onActivate,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final int index;
  final _Spring lens;

  /// Where the pointer hovers, in destinations from the first one's center.
  final ValueListenable<double?> hoverAt;
  final double extent;
  final ValueListenable<double> lift;
  final TextStyle? labelStyle;
  final double labelHeight;
  final bool labelOverflows;
  final VoidCallback onActivate;

  @override
  State<_FloatingBarItem> createState() => _FloatingBarItemState();
}

class _FloatingBarItemState extends State<_FloatingBarItem>
    with SingleTickerProviderStateMixin {
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onActivate();
        return null;
      },
    ),
  };
  late final _Spring _parallax = _Spring(this, 0);
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.hoverAt.addListener(_followPointer);
  }

  @override
  void didUpdateWidget(covariant _FloatingBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoverAt != widget.hoverAt) {
      oldWidget.hoverAt.removeListener(_followPointer);
      widget.hoverAt.addListener(_followPointer);
    }
    _followPointer();
  }

  @override
  void dispose() {
    widget.hoverAt.removeListener(_followPointer);
    _parallax.dispose();
    super.dispose();
  }

  void _followPointer() {
    final hoverAt = widget.hoverAt.value;
    final offset = hoverAt == null ? 0.0 : hoverAt - widget.index;
    final target = offset.abs() > 0.5
        ? 0.0
        : offset * _hoverMagnet * _hoverParallax;
    if (target != _parallax.target) {
      _parallax.springTo(target, _hoverSpring);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final content = _LensTint(
      lens: widget.lens,
      lift: widget.lift,
      index: widget.index,
      color: colorScheme.primary,
      textDirection: Directionality.of(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _labelInset),
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.lens, widget.lift, _parallax]),
          builder: (context, _) {
            final emphasis = (1 - (widget.lens.value - widget.index).abs())
                .clamp(0.0, 1.0);
            final color = colorScheme.onSurfaceVariant;
            final column = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlyphIcon(
                  widget.destination.glyph,
                  size: _iconSize,
                  color: color,
                  fill: 1,
                ),
                const SizedBox(height: _labelGap),
                SizedBox(
                  height: widget.labelHeight,
                  child: Center(
                    child: Text(
                      widget.destination.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: widget.labelStyle?.copyWith(color: color),
                    ),
                  ),
                ),
              ],
            );
            return Transform.translate(
              offset: Offset(_parallax.value * widget.extent * direction, 0),
              transformHitTests: false,
              child: Transform.scale(
                scale: 1 + _lensMagnify * emphasis * widget.lift.value,
                child: column,
              ),
            );
          },
        ),
      ),
    );
    return FocusableActionDetector(
      actions: _actions,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        label: widget.destination.label,
        excludeSemantics: true,
        onTap: widget.onActivate,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: _focused
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: AppShape.full.copyWith(
              side: _focused
                  ? BorderSide(color: colorScheme.secondary, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: widget.labelOverflows
              ? Tooltip(message: widget.destination.label, child: content)
              : content,
        ),
      ),
    );
  }
}

/// Paints what lies under the lens in [color] and the rest as it is, cut to
/// the lens's own shape so a destination it passes over turns part by part.
class _LensTint extends SingleChildRenderObjectWidget {
  const _LensTint({
    required this.lens,
    required this.lift,
    required this.index,
    required this.color,
    required this.textDirection,
    super.child,
  });

  final _Spring lens;
  final ValueListenable<double> lift;
  final int index;
  final Color color;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLensTint(
      lens: lens,
      lift: lift,
      index: index,
      color: color,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLensTint renderObject) {
    renderObject
      ..lens = lens
      ..lift = lift
      ..index = index
      ..color = color
      ..textDirection = textDirection;
  }
}

class _RenderLensTint extends RenderProxyBox {
  _RenderLensTint({
    required _Spring lens,
    required ValueListenable<double> lift,
    required int index,
    required Color color,
    required TextDirection textDirection,
  }) : _lens = lens,
       _lift = lift,
       _index = index,
       _color = color,
       _textDirection = textDirection;

  final _outside = LayerHandle<ClipPathLayer>();
  final _inside = LayerHandle<ClipPathLayer>();
  final _tint = LayerHandle<ColorFilterLayer>();

  _Spring _lens;
  set lens(_Spring value) {
    if (value == _lens) {
      return;
    }
    if (attached) {
      _lens.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _lens = value;
    markNeedsPaint();
  }

  ValueListenable<double> _lift;
  set lift(ValueListenable<double> value) {
    if (value == _lift) {
      return;
    }
    if (attached) {
      _lift.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _lift = value;
    markNeedsPaint();
  }

  int _index;
  set index(int value) {
    if (value == _index) {
      return;
    }
    _index = value;
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _lens.addListener(markNeedsPaint);
    _lift.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _lens.removeListener(markNeedsPaint);
    _lift.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _outside.layer = null;
    _inside.layer = null;
    _tint.layer = null;
    super.dispose();
  }

  Rect get _lensBounds {
    final rect = _lensRect(
      position: _lens.value - _index,
      velocity: _lens.velocity,
      extent: size.width,
      height: size.height,
      lift: _lift.value,
    );
    return _textDirection == TextDirection.ltr
        ? rect
        : Rect.fromLTRB(
            size.width - rect.right,
            rect.top,
            size.width - rect.left,
            rect.bottom,
          );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    final lensBounds = _lensBounds;
    // The magnified content spills a little past the destination's box.
    final reach = (Offset.zero & size).inflate(size.shortestSide / 2);
    if (!lensBounds.overlaps(reach)) {
      _outside.layer = null;
      _inside.layer = null;
      _tint.layer = null;
      super.paint(context, offset);
      return;
    }
    final lens = AppShape.full.getOuterPath(lensBounds);
    _outside.layer = context.pushClipPath(
      needsCompositing,
      offset,
      reach,
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(reach)
        ..addPath(lens, Offset.zero),
      super.paint,
      oldLayer: _outside.layer,
    );
    _inside.layer = context.pushClipPath(
      needsCompositing,
      offset,
      lensBounds,
      lens,
      _paintTinted,
      oldLayer: _inside.layer,
    );
  }

  void _paintTinted(PaintingContext context, Offset offset) {
    final filter = ColorFilter.mode(_color, BlendMode.srcIn);
    if (needsCompositing) {
      _tint.layer = context.pushColorFilter(
        offset,
        filter,
        super.paint,
        oldLayer: _tint.layer,
      );
      return;
    }
    _tint.layer = null;
    final canvas = context.canvas
      ..saveLayer(_lensBounds.shift(offset), Paint()..colorFilter = filter);
    super.paint(context, offset);
    canvas.restore();
  }
}
