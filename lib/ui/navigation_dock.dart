import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart'
    show Hct;
import 'package:material_ui/material_ui.dart';

import 'liquid_glass.dart';

const double _barHeight = 62;
const double _barPadding = 4;
const double _edgeMargin = 21;
const double _shadowRoom = 8;
const double _hitSlop = 8;
const double _maxItemExtent = 86;
const double _minLensWidth = 84;
const _fullWidthCount = 5;
const double _iconSize = 28;
const double _labelGap = 2;
const double _labelInset = 2;
const double _labelSize = 10;
const double _labelLeading = 14.5;
const double _minLabelSize = 9;
const double _pressGrowth = 1 / 8;
const double _maxPressGrowth = 16;
const double _lensGrowth = 8;
const double _lensMagnify = 0.16;
const double _liftSnap = 0.975;
const double _liftRelease = 0.04;
const double _hoverMagnet = 0.2;
const double _hoverParallax = 0.5;
const double _hoverAlpha = 0.08;
const double _hoverSwell = 0.4;
const double _jellySpeed = 3;
const double _jellyStretch = 0.2;
const double _jellyBrake = 25;
const double _jellySquash = 0.15;
const double _jellyAspect = 1.4;
const double _glowReach = 28;
const double _glowGrowth = 3;
const double _glowPeak = 0.06;
const double _glowWash = 0.7;
const double _overdrag = 0.35;
const double _pullLimit = 7 / 32;
const double _pullStretch = 0.5;
const _flingProjection = Duration(milliseconds: 100);
final _trackSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 120),
);
final _pressSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 311,
  ratio: 0.593,
);
final _followSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 1024,
  ratio: 0.9,
);
final _liftSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 250),
);
final _travelSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 400),
  bounce: 0.15,
);
final _jellySpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 100,
  ratio: 0.4,
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
final _glowInSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 100),
);
final _glowOutSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 500),
);

double _rubberBand(double overshoot, double limit) {
  final pull = 1 - 1 / (overshoot.abs() * 0.55 / limit + 1);
  return limit * pull * overshoot.sign;
}

double _saturate(double value) => 1 - 2 / (math.exp(2 * value) + 1);

/// The lens's box, measured from the start edge of the destination at 0.
Rect _lensRect({
  required double position,
  required double stretch,
  required double pitch,
  required double width,
  required double height,
  required double lift,
}) {
  final growth = _lensGrowth * 2 * lift;
  final lensWidth = (width + growth) * (1 + stretch);
  final lensHeight = (height + growth) * (1 - stretch * _jellyAspect);
  return Rect.fromLTWH(
    (position + 0.5) * pitch - lensWidth / 2,
    (height - lensHeight) / 2,
    lensWidth,
    lensHeight,
  );
}

/// Spaces destinations as iOS's tab bar does: the resting lens overhangs its
/// destination by [_barPadding] and never narrows below [_minLensWidth].
({double pitch, double lens, double inset}) _dockLayout(
  double span,
  int count,
) {
  if (count <= 1) {
    return (pitch: span - _barPadding * 2, lens: span, inset: _barPadding);
  }
  final pitch = (span - _barPadding * 2) / count;
  if (pitch + _barPadding * 2 >= _minLensWidth) {
    return (pitch: pitch, lens: pitch + _barPadding * 2, inset: _barPadding);
  }
  final lens = math.min(_minLensWidth, span);
  final closed = (span - lens) / (count - 1);
  return (pitch: closed, lens: lens, inset: (lens - closed) / 2);
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
  SpringDescription? _spring;
  double _now = 0;
  double _start = 0;

  @override
  double get value => _value;

  double get target => _simulation == null ? _value : _target;

  double get velocity => _simulation?.dx(_now - _start) ?? 0;

  double get acceleration {
    final spring = _spring;
    if (_simulation == null || spring == null) {
      return 0;
    }
    return (spring.stiffness * (_target - _value) - spring.damping * velocity) /
        spring.mass;
  }

  void springTo(double target, SpringDescription spring) {
    _simulation = SpringSimulation(spring, _value, target, velocity);
    _spring = spring;
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
List<BoxShadow> dockShadows(ColorScheme colorScheme) {
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

// iOS 27 shades its glass bars only below, faintly, and no darker in dark mode.
List<BoxShadow> dockGlassShadows(ColorScheme colorScheme) => [
  BoxShadow(
    color: colorScheme.shadow.withValues(alpha: 0.013),
    blurRadius: 3.8,
    offset: const Offset(0, 6.5),
  ),
];

/// What the dock's parts stand on: a floating surface, or glass.
class _DockSurface extends StatelessWidget {
  const _DockSurface({
    required this.glass,
    required this.style,
    required this.shadows,
    required this.glow,
    required this.child,
  });

  final bool glass;
  final LiquidGlassStyle style;
  final List<BoxShadow> shadows;
  final ValueListenable<LiquidGlassGlow> glow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (glass) {
      return ValueListenableBuilder(
        valueListenable: glow,
        builder: (_, glow, child) => LiquidGlass(
          style: style,
          shadows: shadows,
          glow: glow,
          child: child,
        ),
        child: child,
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.full,
        shadows: dockShadows(colorScheme),
      ),
      child: child,
    );
  }
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

class NavigationDock extends StatelessWidget {
  const NavigationDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
      child: _HitSlop(
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: _HitSlop(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: destinations.length >= _fullWidthCount
                          ? double.infinity
                          : destinations.length * _maxItemExtent +
                                _barPadding * 4,
                    ),
                    child: FloatingNavigationBar(
                      destinations: destinations,
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // The bar rebuilds every frame its lens or a press moves; a scope of its
    // own keeps that to the dock (.agents/architecture.md, Rebuild Scopes).
    return SizedBox(
      width: double.infinity,
      height: _shadowRoom + height + _bottomMarginOf(context),
      child: RepaintBoundary(child: LayoutBuilder(builder: (_, _) => dock)),
    );
  }
}

/// Lets a touch that misses the dock by at most [_hitSlop] still reach it.
class _HitSlop extends SingleChildRenderObjectWidget {
  const _HitSlop({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHitSlop();
}

class _RenderHitSlop extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    if (size.isEmpty ||
        !(Offset.zero & size).inflate(_hitSlop).contains(position)) {
      return false;
    }
    if (!hitTestChildren(result, position: _onSpine(position))) {
      return false;
    }
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  // A pill's rounded ends clip hit tests; its straight core never does.
  Offset _onSpine(Offset position) {
    final radius = size.shortestSide / 2;
    return Offset(
      position.dx.clamp(radius, size.width - radius),
      size.height / 2,
    );
  }
}

/// Grows under a press and stretches after a dragging finger, springing back
/// on release, as the bar's lens does.
///
/// The press only paints: layout, hit testing, and anything anchored to the
/// child, such as a popup menu or a tooltip, see it at rest.
class ElasticPress extends StatefulWidget {
  const ElasticPress({
    super.key,
    this.enabled = true,
    this.pullPastEdges = false,
    this.maxGrowth = _maxPressGrowth,
    this.maxPull,
    this.panelOf,
    required this.child,
  });

  /// Leaves a press on the button inside to the swell alone.
  static const buttonStyle = ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateMapper<Color?>({
      WidgetState.pressed: Colors.transparent,
    }),
  );

  final bool enabled;
  final bool pullPastEdges;
  final double maxGrowth;
  final double? maxPull;

  /// Where the pressed panel lies in this box, when the box is larger.
  final Rect Function(RenderBox box)? panelOf;

  final Widget child;

  static ElasticPressHandle? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_ElasticPressState>();

  /// Where [box] paints under the presses around it, in its own coordinates.
  static Rect paintBoundsOf(RenderBox box) {
    final bounds = Offset.zero & box.size;
    var painted = Matrix4.identity();
    RenderObject from = box;
    for (var node = box.parent; node != null; node = node.parent) {
      if (node is _RenderPressTransform && node.hasSize) {
        painted = node._transform.multiplied(
          from.getTransformTo(node).multiplied(painted),
        );
        from = node;
      }
    }
    final rest = Matrix4.tryInvert(box.getTransformTo(from));
    if (identical(from, box) || rest == null) {
      return bounds;
    }
    return MatrixUtils.transformRect(rest.multiplied(painted), bounds);
  }

  @override
  State<ElasticPress> createState() => _ElasticPressState();
}

/// Drives an [ElasticPress] with a press it does not hear, at global positions.
abstract interface class ElasticPressHandle {
  void press(Offset position);

  void drag(Offset position);

  void release();
}

class _ElasticPressState extends State<ElasticPress>
    with TickerProviderStateMixin
    implements ElasticPressHandle {
  late final _Spring _lift = _Spring(this, 0);
  late final _Spring _pullX = _Spring(this, 0);
  late final _Spring _pullY = _Spring(this, 0);
  late final Listenable _motion = Listenable.merge([_lift, _pullX, _pullY]);
  int? _pointer;
  Offset _origin = Offset.zero;
  bool _releasing = false;

  @override
  void initState() {
    super.initState();
    _lift.addListener(_settle);
  }

  @override
  void dispose() {
    _lift.dispose();
    _pullX.dispose();
    _pullY.dispose();
    super.dispose();
  }

  void _swell(Offset origin) {
    _origin = origin;
    _releasing = false;
    _lift.springTo(1, _pressSpring);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled ||
        _pointer != null ||
        event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _swell(event.localPosition);
  }

  // A pointer's events keep reaching the hit-test path recorded at its down,
  // so a press removed mid-gesture still hears its moves and release.
  void _handlePointerMove(PointerMoveEvent event) {
    if (!mounted || event.pointer != _pointer) {
      return;
    }
    _pullToward(event.localPosition);
  }

  void _pullToward(Offset position) {
    final box = context.findRenderObject()! as RenderBox;
    final panel = widget.panelOf?.call(box) ?? Offset.zero & box.size;
    final limit = widget.maxPull ?? panel.shortestSide * _pullLimit;
    final pull = widget.pullPastEdges
        ? position -
              Offset(
                position.dx.clamp(panel.left, panel.right),
                position.dy.clamp(panel.top, panel.bottom),
              )
        : position - _origin;
    _pullX.springTo(_rubberBand(pull.dx, limit), _trackSpring);
    _pullY.springTo(_rubberBand(pull.dy, limit), _trackSpring);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (!mounted || event.pointer != _pointer) {
      return;
    }
    _release();
  }

  void _release() {
    _pointer = null;
    _pullX.springTo(0, _pressSpring);
    _pullY.springTo(0, _pressSpring);
    _releasing = true;
    _settle();
  }

  // A tap lets go before the swell has risen; it rises all the way first, as
  // UIKit lifts the tab bar's lens all the way on a tap.
  void _settle() {
    if (!_releasing || _lift.value < _liftSnap) {
      return;
    }
    _releasing = false;
    _lift.springTo(0, _pressSpring);
  }

  Offset _localOf(Offset position) =>
      (context.findRenderObject()! as RenderBox).globalToLocal(position);

  @override
  void press(Offset position) {
    if (!widget.enabled) {
      return;
    }
    _swell(_localOf(position));
  }

  @override
  void drag(Offset position) => _pullToward(_localOf(position));

  @override
  void release() => _release();

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
          maxGrowth: widget.maxGrowth,
          panelOf: widget.panelOf,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Leaves a press on the filled button inside to [ElasticPress]; one whose
/// style sets a foreground color merges [ElasticPress.buttonStyle].
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
  const _PressTransform({
    required this.lift,
    required this.pull,
    this.maxGrowth = _maxPressGrowth,
    this.panelOf,
    super.child,
  });

  final double lift;
  final Offset pull;
  final double maxGrowth;
  final Rect Function(RenderBox box)? panelOf;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPressTransform(lift: lift, pull: pull)
      ..maxGrowth = maxGrowth
      ..panelOf = panelOf;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPressTransform renderObject,
  ) {
    renderObject
      ..lift = lift
      ..pull = pull
      ..maxGrowth = maxGrowth
      ..panelOf = panelOf;
  }
}

class _RenderPressTransform extends RenderProxyBox {
  _RenderPressTransform({required double lift, required Offset pull})
    : _lift = lift,
      _pull = pull;

  double _lift;
  Offset _pull;
  double maxGrowth = _maxPressGrowth;
  Rect Function(RenderBox box)? panelOf;

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
    final panel = panelOf?.call(this) ?? Offset.zero & size;
    final swell =
        1 + _lift * math.min(_pressGrowth * 2, maxGrowth / panel.longestSide);
    final scaleX = swell * (1 + _pull.dx.abs() / panel.width * _pullStretch);
    final scaleY = swell * (1 + _pull.dy.abs() / panel.height * _pullStretch);
    final center = panel.center;
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
  late final _Spring _jelly = _Spring(this, 0);
  late final _Spring _glow = _Spring(this, 0);
  late final _Spring _glowSpread = _Spring(this, 0);
  final ValueNotifier<LiquidGlassGlow> _touchGlow = ValueNotifier(
    LiquidGlassGlow.none,
  );
  Offset _glowAt = Offset.zero;
  late final Listenable _barMotion = Listenable.merge([_swell, _stretch]);
  late final Listenable _motion = Listenable.merge([_lens, _lift, _jelly]);
  late final Listenable _hoverMotion = Listenable.merge([_hover, _hoverShow]);
  final List<_Spring> _parallax = [];
  bool _lifted = false;
  int? _pointer;
  int? _pressedIndex;
  double _pressX = 0;
  bool _dragging = false;
  bool _dropping = false;
  VelocityTracker? _tracker;
  Offset? _cursor;
  final ValueNotifier<double?> _hoverAt = ValueNotifier(null);

  int get _lastIndex => math.max(0, widget.destinations.length - 1);

  int get _selectedIndex => widget.selectedIndex.clamp(0, _lastIndex);

  ({double pitch, double lens, double inset}) get _layout => _dockLayout(
    context.size!.width - _barPadding * 2,
    widget.destinations.length,
  );

  @override
  void initState() {
    super.initState();
    _lens
      ..addListener(_wobble)
      ..addListener(_dropLift);
    _lift
      ..addListener(_dropLift)
      ..addListener(_noteLift);
    _glow.addListener(_shine);
    _glowSpread.addListener(_shine);
    _hoverAt.addListener(_leanContent);
    _syncParallax();
  }

  @override
  void didUpdateWidget(covariant FloatingNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncParallax();
    _leanContent();
    final rest = _lensRest;
    if (_pressedIndex == null && _lens.target != rest) {
      _lens.springTo(rest, _travelSpring);
    }
  }

  @override
  void dispose() {
    for (final parallax in _parallax) {
      parallax.dispose();
    }
    _lens.dispose();
    _lift.dispose();
    _hover.dispose();
    _hoverShow.dispose();
    _swell.dispose();
    _stretch.dispose();
    _jelly.dispose();
    _glow.dispose();
    _glowSpread.dispose();
    _touchGlow.dispose();
    _hoverAt.dispose();
    super.dispose();
  }

  void _wobble() {
    final velocity = _lens.velocity;
    final braking = math.max(0.0, -_lens.acceleration * velocity.sign);
    final target =
        _jellyStretch * _saturate(velocity.abs() / _jellySpeed) -
        _jellySquash * _saturate(braking / _jellyBrake);
    if (target != _jelly.target) {
      _jelly.springTo(target, _jellySpring);
    }
  }

  // UIKit lights the bar from the finger, washing over the rest of it, and
  // spreads the light out as it fades on release.
  void _shine() {
    final glow = _glow.value;
    _touchGlow.value = LiquidGlassGlow(
      center: _glowAt,
      reach: _glowReach * (1 + _glowGrowth * _glowSpread.value),
      strength: _glowPeak * glow * glow,
      wash: _glowWash,
    );
  }

  void _syncParallax() {
    final count = widget.destinations.length;
    while (_parallax.length > count) {
      _parallax.removeLast().dispose();
    }
    while (_parallax.length < count) {
      _parallax.add(_Spring(this, 0));
    }
  }

  void _leanContent() {
    final hoverAt = _hoverAt.value;
    for (final (index, parallax) in _parallax.indexed) {
      final offset = hoverAt == null ? 0.0 : hoverAt - index;
      final target = offset.abs() > 0.5
          ? 0.0
          : offset * _hoverMagnet * _hoverParallax;
      if (target != parallax.target) {
        parallax.springTo(target, _hoverSpring);
      }
    }
  }

  void _noteLift() {
    final lifted = _lift.value > 0;
    if (lifted != _lifted) {
      setState(() => _lifted = lifted);
    }
  }

  // UIKit keeps the lens lifted until it has risen all the way and arrived.
  void _dropLift() {
    if (!_dropping || _pointer != null || _lift.value < _liftSnap) {
      return;
    }
    if ((_lens.target - _lens.value).abs() > _liftRelease) {
      return;
    }
    _dropping = false;
    _lift.springTo(0, _liftSpring);
  }

  double _positionAt(Offset localPosition) {
    final width = context.size!.width;
    final dx = Directionality.of(context) == TextDirection.ltr
        ? localPosition.dx
        : width - localPosition.dx;
    final layout = _layout;
    final position = (dx - _barPadding - layout.inset) / layout.pitch - 0.5;
    if (position < 0) {
      return _rubberBand(position, _overdrag);
    }
    if (position > _lastIndex) {
      return _lastIndex + _rubberBand(position - _lastIndex, _overdrag);
    }
    return position;
  }

  int _indexAt(double position) => position.round().clamp(0, _lastIndex);

  double _leanAt(double position) {
    final index = _indexAt(position);
    return index + (position - index) * _hoverMagnet;
  }

  double get _lensRest {
    final hoverAt = _hoverAt.value;
    if (hoverAt == null || _indexAt(hoverAt) != _selectedIndex) {
      return _selectedIndex.toDouble();
    }
    return _leanAt(hoverAt);
  }

  // A lens headed to a just-tapped destination is left for didUpdateWidget.
  void _leanLens() {
    if (_pressedIndex != null || _indexAt(_lens.target) != _selectedIndex) {
      return;
    }
    final rest = _lensRest;
    if (_lens.target != rest) {
      _lens.springTo(rest, _hoverSpring);
    }
  }

  void _showHover() {
    final cursor = _cursor;
    if (cursor == null || _pointer != null || widget.destinations.isEmpty) {
      return;
    }
    final position = _positionAt(cursor);
    final target = _leanAt(position);
    _hoverAt.value = position;
    if (_hoverShow.target == 0 && _hoverShow.value == 0) {
      _hover.jumpTo(target);
    } else {
      _hover.springTo(target, _hoverSpring);
    }
    _hoverShow.springTo(1, _fadeSpring);
    _leanLens();
  }

  void _settleSwell(SpringDescription spring) {
    final target = _cursor == null ? 0.0 : _hoverSwell;
    if (_pointer == null && _swell.target != target) {
      _swell.springTo(target, spring);
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
    _settleSwell(_settleSpring);
  }

  void _handleExit(PointerExitEvent event) {
    _cursor = null;
    _hoverShow.springTo(0, _fadeSpring);
    _hoverAt.value = null;
    _leanLens();
    _settleSwell(_settleSpring);
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
    _swell.springTo(1, _pressSpring);
    _glowAt = event.localPosition;
    _glowSpread.jumpTo(0);
    _glow.springTo(1, _glowInSpring);
    _press(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _pointer) {
      _tracker?.addPosition(event.timeStamp, event.localPosition);
      _glowAt = event.localPosition;
      _shine();
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
    _glow.springTo(0, _glowOutSpring);
    _glowSpread.springTo(1, _glowOutSpring);
    _stretch.springTo(0, _pressSpring);
    if (_cursor != null) {
      _cursor = event.localPosition;
      _showHover();
    }
    _settleSwell(_pressSpring);
  }

  void _press(Offset localPosition) {
    if (widget.destinations.isEmpty) {
      return;
    }
    final index = _indexAt(_positionAt(localPosition));
    _pressedIndex = index;
    _pressX = localPosition.dx;
    _dragging = false;
    _dropping = false;
    _lift.springTo(1, _liftSpring);
    _lens.springTo(index.toDouble(), _travelSpring);
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
    _lens.springTo(position, _followSpring);
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
    final extent = _layout.pitch;
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
    _dropping = true;
    _lens.springTo((commit ? index : _selectedIndex).toDouble(), _travelSpring);
    _dropLift();
    if (commit && index != widget.selectedIndex) {
      widget.onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = AppTextStyle.custom(
      context,
      size: _labelSize,
      leading: _labelLeading,
      weight: FontWeight.w500,
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
    final glass = LiquidGlassScope.of(context);
    final ultra =
        LiquidGlassScope.qualityOf(context) == LiquidGlassQuality.ultra;
    final bar = _DockSurface(
      glass: glass,
      style: LiquidGlassStyle.pill(colorScheme),
      shadows: ultra ? dockGlassShadows(colorScheme) : const [],
      glow: _touchGlow,
      child: Material(
        color: glass
            ? Colors.transparent
            : SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
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
                    final layout = _dockLayout(
                      constraints.maxWidth,
                      widget.destinations.length,
                    );
                    final room = layout.pitch - _labelInset * 2;
                    final labelScale = widest <= room
                        ? 1.0
                        : math.max(room / widest, _minLabelSize / _labelSize);
                    Rect lensRect() => _lensRect(
                      position: _lens.value,
                      stretch: _jelly.value,
                      pitch: layout.pitch,
                      width: layout.lens,
                      height: constraints.maxHeight,
                      lift: _lift.value,
                    ).shift(Offset(layout.inset, 0));
                    Widget items(_LensPart part) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: layout.inset),
                      child: Row(
                        children: [
                          for (final (index, destination)
                              in widget.destinations.indexed)
                            Expanded(
                              child: _FloatingBarItem(
                                destination: destination,
                                selected: index == _selectedIndex,
                                index: index,
                                part: part,
                                lens: _lens,
                                lensWidth: layout.lens,
                                jelly: _jelly,
                                parallax: _parallax[index],
                                lift: _lift,
                                labelStyle: labelStyle.copyWith(
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
                    );
                    final lensed =
                        glass && _lifted && widget.destinations.isNotEmpty;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (widget.destinations.isNotEmpty)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (_, _) => _Lens(
                              rect: lensRect(),
                              lift: _lift.value,
                              glass: glass,
                            ),
                          ),
                        if (widget.destinations.isNotEmpty)
                          AnimatedBuilder(
                            animation: _hoverMotion,
                            builder: (_, _) => _HoverHighlight(
                              start:
                                  layout.inset +
                                  (_hover.value + 0.5) * layout.pitch -
                                  layout.lens / 2,
                              width: layout.lens,
                              opacity: _hoverShow.value,
                            ),
                          ),
                        if (glass && widget.destinations.isNotEmpty)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (_, _) =>
                                _GlassLens(rect: lensRect(), lift: _lift.value),
                          ),
                        items(lensed ? _LensPart.outside : _LensPart.both),
                        if (lensed)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (_, child) => _LensContent(
                              rect: lensRect(),
                              lift: _lift.value,
                              warp: ultra,
                              child: child!,
                            ),
                            child: items(_LensPart.inside),
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
    required this.start,
    required this.width,
    required this.opacity,
  });

  final double start;
  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final alpha = _hoverAlpha * opacity.clamp(0.0, 1.0);
    if (alpha == 0) {
      return const SizedBox.shrink();
    }
    return Positioned.directional(
      textDirection: Directionality.of(context),
      start: start,
      top: 0,
      bottom: 0,
      width: width,
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
  const _Lens({required this.rect, required this.lift, required this.glass});

  final Rect rect;
  final double lift;

  /// On glass the lens rests as a platter in the secondary hue, sunk in dark
  /// mode as iOS's tab bar marks its selection, and clears as it lifts into
  /// the [_GlassLens].
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final lifted = lift.clamp(0.0, 1.0);
    final tone = colorScheme.brightness == Brightness.dark ? 4.0 : 90.0;
    final hct = Hct.fromInt(colorScheme.secondary.toARGB32())..tone = tone;
    final platter = Color(hct.toInt()).withValues(alpha: 0.85);
    return PositionedDirectional(
      start: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: glass
              ? platter.withValues(alpha: platter.a * (1 - lifted))
              : Color.alphaBlend(
                  colorScheme.onSurface.withValues(alpha: 0.08 * lifted),
                  SurfaceLevel.floatingOf(
                    colorScheme,
                  ).next.colorOf(colorScheme),
                ),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

/// The clear lens a lifted selection becomes on glass. The destinations stand
/// on it, as iOS draws them over its lens, so it bends only the bar.
class _GlassLens extends StatelessWidget {
  const _GlassLens({required this.rect, required this.lift});

  final Rect rect;
  final double lift;

  @override
  Widget build(BuildContext context) {
    if (lift <= 0) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    return Positioned.directional(
      textDirection: Directionality.of(context),
      start: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: LiquidGlass(
          style: LiquidGlassStyle.lens(colorScheme).scale(lift),
          shadows: _lensShadows(colorScheme, lift),
        ),
      ),
    );
  }
}

List<BoxShadow> _lensShadows(ColorScheme colorScheme, double lift) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(
        alpha: 0.055 * strength * lift.clamp(0.0, 1.0),
      ),
      blurRadius: 5,
      offset: const Offset(0, 8),
    ),
  ];
}

/// What a lifted lens on glass shows of the destinations under it, over the
/// [_GlassLens], with a pane of its own that warps only them: they are drawn
/// offscreen, so that pane reads them and not the bar.
class _LensContent extends StatelessWidget {
  const _LensContent({
    required this.rect,
    required this.lift,
    required this.warp,
    required this.child,
  });

  final Rect rect;
  final double lift;
  final bool warp;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final clipper = _LensClip(rect, textDirection);
    if (!warp) {
      return Positioned.fill(
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: ClipPath(clipper: clipper, child: child),
          ),
        ),
      );
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: ClipPath(
            clipper: clipper,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: child),
                Positioned.directional(
                  textDirection: textDirection,
                  start: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: LiquidGlass(
                    style: LiquidGlassStyle.lensContent(
                      context.colorScheme,
                    ).scale(lift),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LensClip extends CustomClipper<Path> {
  const _LensClip(this.rect, this.textDirection);

  final Rect rect;
  final TextDirection textDirection;

  @override
  Path getClip(Size size) => AppShape.full.getOuterPath(
    textDirection == TextDirection.ltr
        ? rect
        : Rect.fromLTRB(
            size.width - rect.right,
            rect.top,
            size.width - rect.left,
            rect.bottom,
          ),
  );

  @override
  bool shouldReclip(_LensClip oldClipper) =>
      rect != oldClipper.rect || textDirection != oldClipper.textDirection;
}

enum _LensPart { both, outside, inside }

class _FloatingBarItem extends StatefulWidget {
  const _FloatingBarItem({
    required this.destination,
    required this.selected,
    required this.index,
    required this.part,
    required this.lens,
    required this.lensWidth,
    required this.jelly,
    required this.parallax,
    required this.lift,
    required this.labelStyle,
    required this.labelHeight,
    required this.labelOverflows,
    required this.onActivate,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final int index;

  /// Only [_LensPart.inside] is drawn bare: it stands over the lens, while
  /// the destination it copies takes the presses and the focus.
  final _LensPart part;
  final _Spring lens;
  final double lensWidth;
  final ValueListenable<double> jelly;
  final ValueListenable<double> parallax;
  final ValueListenable<double> lift;
  final TextStyle? labelStyle;
  final double labelHeight;
  final bool labelOverflows;
  final VoidCallback onActivate;

  @override
  State<_FloatingBarItem> createState() => _FloatingBarItemState();
}

class _FloatingBarItemState extends State<_FloatingBarItem> {
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onActivate();
        return null;
      },
    ),
  };
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = colorScheme.onSurfaceVariant;
    var tint = colorScheme.primary;
    if (widget.part == _LensPart.inside &&
        LiquidGlassScope.qualityOf(context) == LiquidGlassQuality.standard) {
      // Without a pane of its own the copy takes the light that one adds.
      final brightness = LiquidGlassStyle.lensContent(colorScheme).brightness;
      tint = Color.from(
        alpha: tint.a,
        red: math.min(tint.r * brightness, 1),
        green: math.min(tint.g * brightness, 1),
        blue: math.min(tint.b * brightness, 1),
      );
    }
    final content = _LensTint(
      part: widget.part,
      lens: widget.lens,
      lensWidth: widget.lensWidth,
      jelly: widget.jelly,
      lift: widget.lift,
      parallax: widget.parallax,
      index: widget.index,
      color: tint,
      textDirection: Directionality.of(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _labelInset),
        child: Column(
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
        ),
      ),
    );
    if (widget.part == _LensPart.inside) {
      return content;
    }
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
              side: _focused ? focusRingSide(colorScheme) : BorderSide.none,
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

/// Paints what lies under the lens in [color], magnified as the lens lifts,
/// and the rest as it is, cut to the lens's own shape so a destination it
/// passes over turns part by part. The content leans after the [parallax], in
/// destinations, while layout and hit testing see it at rest.
class _LensTint extends SingleChildRenderObjectWidget {
  const _LensTint({
    required this.part,
    required this.lens,
    required this.lensWidth,
    required this.jelly,
    required this.lift,
    required this.parallax,
    required this.index,
    required this.color,
    required this.textDirection,
    super.child,
  });

  final _LensPart part;
  final _Spring lens;
  final double lensWidth;
  final ValueListenable<double> jelly;
  final ValueListenable<double> lift;
  final ValueListenable<double> parallax;
  final int index;
  final Color color;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLensTint(
      part: part,
      lens: lens,
      lensWidth: lensWidth,
      jelly: jelly,
      lift: lift,
      parallax: parallax,
      index: index,
      color: color,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLensTint renderObject) {
    renderObject
      ..part = part
      ..lens = lens
      ..lensWidth = lensWidth
      ..jelly = jelly
      ..lift = lift
      ..parallax = parallax
      ..index = index
      ..color = color
      ..textDirection = textDirection;
  }
}

class _RenderLensTint extends RenderProxyBox {
  _RenderLensTint({
    required _LensPart part,
    required _Spring lens,
    required double lensWidth,
    required ValueListenable<double> jelly,
    required ValueListenable<double> lift,
    required ValueListenable<double> parallax,
    required int index,
    required Color color,
    required TextDirection textDirection,
  }) : _part = part,
       _lens = lens,
       _lensWidth = lensWidth,
       _jelly = jelly,
       _lift = lift,
       _parallax = parallax,
       _index = index,
       _color = color,
       _textDirection = textDirection;

  final _outside = LayerHandle<ClipPathLayer>();
  final _inside = LayerHandle<ClipPathLayer>();
  final _tint = LayerHandle<ColorFilterLayer>();
  final _outsideMotion = LayerHandle<TransformLayer>();
  final _insideMotion = LayerHandle<TransformLayer>();

  _LensPart _part;
  set part(_LensPart value) {
    if (value == _part) {
      return;
    }
    _part = value;
    markNeedsPaint();
  }

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

  double _lensWidth;
  set lensWidth(double value) {
    if (value == _lensWidth) {
      return;
    }
    _lensWidth = value;
    markNeedsPaint();
  }

  ValueListenable<double> _jelly;
  set jelly(ValueListenable<double> value) {
    if (value == _jelly) {
      return;
    }
    if (attached) {
      _jelly.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _jelly = value;
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

  ValueListenable<double> _parallax;
  set parallax(ValueListenable<double> value) {
    if (value == _parallax) {
      return;
    }
    if (attached) {
      _parallax.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _parallax = value;
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
    _jelly.addListener(markNeedsPaint);
    _lift.addListener(markNeedsPaint);
    _parallax.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _lens.removeListener(markNeedsPaint);
    _jelly.removeListener(markNeedsPaint);
    _lift.removeListener(markNeedsPaint);
    _parallax.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _outside.layer = null;
    _inside.layer = null;
    _tint.layer = null;
    _outsideMotion.layer = null;
    _insideMotion.layer = null;
    super.dispose();
  }

  Rect get _lensBounds {
    final rect = _lensRect(
      position: _lens.value - _index,
      stretch: _jelly.value,
      pitch: size.width,
      width: _lensWidth,
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

  Matrix4? _motion(double scale) {
    final direction = _textDirection == TextDirection.ltr ? 1 : -1;
    final shift = _parallax.value * size.width * direction;
    if (scale == 1 && shift == 0) {
      return null;
    }
    final center = size.center(Offset.zero);
    return Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
      center.dx * (1 - scale) + shift,
      center.dy * (1 - scale),
      0,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final motion = _motion(1);
    if (motion != null) {
      transform.multiply(motion);
    }
  }

  void _paintMoved(
    PaintingContext context,
    Offset offset,
    Matrix4? motion,
    LayerHandle<TransformLayer> handle,
  ) {
    if (motion == null) {
      handle.layer = null;
      super.paint(context, offset);
      return;
    }
    handle.layer = context.pushTransform(
      needsCompositing,
      offset,
      motion,
      super.paint,
      oldLayer: handle.layer,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    final rest = _motion(1);
    final magnified = _motion(1 + _lensMagnify * _lift.value);
    final bounds = Offset.zero & size;
    Rect moved(Matrix4? motion) =>
        motion == null ? bounds : MatrixUtils.transformRect(motion, bounds);
    final lensBounds = _lensBounds;
    // The lens rests [_barPadding] past its destination, over the edges of
    // the neighbours where nothing is drawn.
    final reached = Rect.fromLTRB(
      lensBounds.left + _barPadding,
      lensBounds.top,
      lensBounds.right - _barPadding,
      lensBounds.bottom,
    );
    final outside = _part != _LensPart.inside;
    final inside = _part != _LensPart.outside;
    if (!reached.overlaps(moved(rest)) && !reached.overlaps(moved(magnified))) {
      _outside.layer = null;
      _inside.layer = null;
      _tint.layer = null;
      _insideMotion.layer = null;
      if (outside) {
        _paintMoved(context, offset, rest, _outsideMotion);
      } else {
        _outsideMotion.layer = null;
      }
      return;
    }
    final reach = moved(rest).expandToInclude(bounds).inflate(_labelInset);
    final lens = AppShape.full.getOuterPath(lensBounds);
    if (outside) {
      _outside.layer = context.pushClipPath(
        needsCompositing,
        offset,
        reach,
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(reach)
          ..addPath(lens, Offset.zero),
        (context, offset) => _paintMoved(context, offset, rest, _outsideMotion),
        oldLayer: _outside.layer,
      );
    } else {
      _outside.layer = null;
      _outsideMotion.layer = null;
    }
    if (inside) {
      _inside.layer = context.pushClipPath(
        needsCompositing,
        offset,
        lensBounds,
        lens,
        (context, offset) =>
            _paintTinted(context, offset, lensBounds, magnified),
        oldLayer: _inside.layer,
      );
    } else {
      _inside.layer = null;
      _tint.layer = null;
      _insideMotion.layer = null;
    }
  }

  void _paintTinted(
    PaintingContext context,
    Offset offset,
    Rect lensBounds,
    Matrix4? motion,
  ) {
    final filter = ColorFilter.mode(_color, BlendMode.srcIn);
    if (needsCompositing) {
      _tint.layer = context.pushColorFilter(
        offset,
        filter,
        (context, offset) =>
            _paintMoved(context, offset, motion, _insideMotion),
        oldLayer: _tint.layer,
      );
      return;
    }
    _tint.layer = null;
    final canvas = context.canvas
      ..saveLayer(lensBounds.shift(offset), Paint()..colorFilter = filter);
    _paintMoved(context, offset, motion, _insideMotion);
    canvas.restore();
  }
}
