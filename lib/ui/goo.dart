import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'liquid_glass.dart';
import 'navigation_dock.dart';

// At rest no closer than buttons stand in a bar, so none bulges toward its
// neighbor until a press swells it, as iOS 27 merges a search field it swells
// with its cancel button.
const double _restBlend = 8;
const double _pressBlend = 8;
const double _neckStep = 0.5;

/// Draws the [GooPane]s below, pills in rows, as one surface that flows
/// together where two neighbors in a row come close, as iOS 27 draws controls
/// whose glass shares a container. `TonalButtonTheme` and `TonalButtonGroup`
/// below put their buttons on panes.
class GooSurface extends StatelessWidget {
  const GooSurface({
    super.key,
    this.glass,
    required this.color,
    this.shadows = const [],
    required this.child,
  });

  final LiquidGlassStyle? glass;
  final Color color;

  /// Cast only outside the surface, as one under glass would show through.
  final List<BoxShadow> shadows;
  final Widget child;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GooScope>() != null;

  static const buttonStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.transparent),
    backgroundBuilder: _paneBehind,
  );

  static Widget _paneBehind(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) => GooPane(child: child);

  @override
  Widget build(BuildContext context) {
    return _GooScope(
      child: _GooSurfaceBox(
        glass: glass,
        color: color,
        shadows: shadows,
        child: child,
      ),
    );
  }
}

class _GooScope extends InheritedWidget {
  const _GooScope({required super.child});

  @override
  bool updateShouldNotify(_GooScope oldWidget) => false;
}

/// A pill of the [GooSurface] above, swelling with the presses around it.
class GooPane extends SingleChildRenderObjectWidget {
  const GooPane({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGooPane();
}

class _RenderGooPane extends RenderProxyBox {
  _RenderGooSurface? _surface;
  VoidCallback? _unfollow;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (var node = parent; node != null; node = node.parent) {
      if (node is _RenderGooSurface) {
        _surface = node.._panes.add(this);
        _unfollow = ElasticPress.followPresses(this, node.markNeedsPaint);
        node.markNeedsPaint();
        return;
      }
    }
  }

  @override
  void detach() {
    _unfollow?.call();
    _unfollow = null;
    _surface
      ?.._panes.remove(this)
      ..markNeedsPaint();
    _surface = null;
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    _surface?.markNeedsPaint();
  }
}

class _GooSurfaceBox extends SingleChildRenderObjectWidget {
  const _GooSurfaceBox({
    required this.glass,
    required this.color,
    required this.shadows,
    super.child,
  });

  final LiquidGlassStyle? glass;
  final Color color;
  final List<BoxShadow> shadows;

  @override
  _RenderGooSurface createRenderObject(BuildContext context) =>
      _RenderGooSurface(glass: glass, color: color, shadows: shadows);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGooSurface renderObject,
  ) {
    renderObject
      ..glass = glass
      ..color = color
      ..shadows = shadows;
  }
}

typedef _Placed = ({Rect rect, double lift});

class _RenderGooSurface extends RenderProxyBox {
  _RenderGooSurface({
    required LiquidGlassStyle? glass,
    required Color color,
    required List<BoxShadow> shadows,
  }) : _glass = glass,
       _color = color,
       _shadows = shadows;

  final _panes = <_RenderGooPane>{};
  late final _pane = LiquidGlassPane(markNeedsPaint);
  Offset? _touch;
  ({List<Rect> pills, List<double> blends, Path path})? _outline;

  LiquidGlassStyle? _glass;
  set glass(LiquidGlassStyle? value) {
    if (value == _glass) {
      return;
    }
    if ((value == null) != (_glass == null)) {
      markNeedsCompositingBitsUpdate();
    }
    _glass = value;
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

  List<BoxShadow> _shadows;
  set shadows(List<BoxShadow> value) {
    if (listEquals(value, _shadows)) {
      return;
    }
    _shadows = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _glass != null;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      _touch = event.localPosition;
    }
  }

  @override
  void dispose() {
    _pane.dispose();
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final panes = _rows([
      for (final pane in _panes)
        if (pane.attached && pane.hasSize && !pane.size.isEmpty)
          (
            rect: MatrixUtils.transformRect(
              pane.getTransformTo(this),
              ElasticPress.paintBoundsOf(pane),
            ),
            lift: ElasticPress.liftOf(pane),
          ),
    ]);
    final pills = [for (final pane in panes) pane.rect];
    if (pills.isEmpty) {
      _pane.clear();
      super.paint(context, offset);
      return;
    }
    final blends = [
      for (var index = 1; index < panes.length; index++)
        _inRow(panes[index - 1].rect, panes[index].rect)
            ? _restBlend +
                  _pressBlend *
                      math.max(panes[index - 1].lift, panes[index].lift)
            : 0.0,
    ];
    final bounds = pills.reduce((a, b) => a.expandToInclude(b));
    final path = _outlineOf(pills, blends);
    final canvas = context.canvas;
    _paintShadows(canvas, path.shift(offset), bounds.shift(offset));
    final glass = _glass;
    if (glass == null) {
      _pane.clear();
      canvas.drawPath(path.shift(offset), Paint()..color = _color);
    } else {
      final pressed = panes.reduce((a, b) => b.lift > a.lift ? b : a);
      final touch = _touch;
      _pane.paint(
        context,
        bounds.shift(offset),
        shape: LiquidGlassGoo(path.shift(-bounds.topLeft), [
          for (final pill in pills) pill.shift(-bounds.topLeft),
        ], blends),
        style: glass,
        glow: LiquidGlassGlow(
          center:
              (touch != null && pressed.rect.contains(touch)
                  ? touch
                  : pressed.rect.center) -
              bounds.topLeft,
          reach: pressed.rect.height / math.sqrt2,
          strength: pressed.lift * 0.16,
        ),
      );
    }
    super.paint(context, offset);
  }

  static bool _inRow(Rect a, Rect b) =>
      (a.center.dy - b.center.dy).abs() < math.min(a.height, b.height) / 2;

  /// [panes] in rows from the top, each from the left.
  static List<_Placed> _rows(List<_Placed> panes) {
    final rows = <List<_Placed>>[];
    for (final pane
        in panes
          ..removeWhere((pane) => pane.rect.isEmpty)
          ..sort((a, b) => a.rect.center.dy.compareTo(b.rect.center.dy))) {
      if (rows.isNotEmpty && _inRow(rows.last.first.rect, pane.rect)) {
        rows.last.add(pane);
      } else {
        rows.add([pane]);
      }
    }
    return [
      for (final row in rows)
        ...row..sort((a, b) => a.rect.center.dx.compareTo(b.rect.center.dx)),
    ];
  }

  Path _outlineOf(List<Rect> pills, List<double> blends) {
    final outline = _outline;
    if (outline != null &&
        listEquals(outline.pills, pills) &&
        listEquals(outline.blends, blends)) {
      return outline.path;
    }
    final path = gooOutline(pills, blends);
    _outline = (pills: pills, blends: blends, path: path);
    return path;
  }

  void _paintShadows(Canvas canvas, Path path, Rect bounds) {
    if (_shadows.isEmpty) {
      return;
    }
    final reach = _shadows.fold(
      0.0,
      (reach, shadow) =>
          math.max(reach, shadow.offset.distance + shadow.blurRadius * 2),
    );
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(bounds.inflate(reach))
          ..addPath(path, Offset.zero),
      );
    for (final shadow in _shadows) {
      canvas.drawPath(path.shift(shadow.offset), shadow.toPaint());
    }
    canvas.restore();
  }
}

/// The outline of [pills], as gooGeometry in shaders/liquid_glass.frag blends
/// their distances.
@visibleForTesting
Path gooOutline(List<Rect> pills, List<double> blends) {
  var outline = Path();
  for (final pill in pills) {
    outline.addRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        pill,
        Radius.circular(pill.shortestSide / 2),
      ),
    );
  }
  for (var index = 1; index < pills.length; index++) {
    final neck = _neck(pills[index - 1], pills[index], blends[index - 1]);
    if (neck != null) {
      outline = Path.combine(PathOperation.union, outline, neck);
    }
  }
  return outline;
}

double _pillDistance(Rect pill, Offset point) {
  final radius = pill.shortestSide / 2;
  final qx = (point.dx - pill.center.dx).abs() - pill.width / 2 + radius;
  final qy = (point.dy - pill.center.dy).abs() - pill.height / 2 + radius;
  return Offset(math.max(qx, 0), math.max(qy, 0)).distance +
      math.min(math.max(qx, qy), 0) -
      radius;
}

double _smoothMin(double a, double b, double blend) {
  final h = (0.5 + 0.5 * (b - a) / blend).clamp(0.0, 1.0);
  return lerpDouble(b, a, h)! - blend * h * (1 - h);
}

/// What [a] and [b] add to their own outlines between the centers of their
/// facing ends: a neck, or a bulge from each toward the other. Only where they
/// flow together, so each keeps its superellipse elsewhere, as the shader's
/// line does.
Path? _neck(Rect a, Rect b, double blend) {
  final from = a.right - a.shortestSide / 2;
  final to = b.left + b.shortestSide / 2;
  if (blend <= 0 || to <= from || b.left - a.right >= blend) {
    return null;
  }
  double field(Offset point) =>
      _smoothMin(_pillDistance(a, point), _pillDistance(b, point), blend);
  double axisAt(double x) =>
      lerpDouble(a.center.dy, b.center.dy, (x - from) / (to - from))!;
  final reach = math.max(a.height, b.height) / 2 + blend;
  double edge(double x, double toward) {
    final axis = axisAt(x);
    var inside = 0.0;
    var outside = reach;
    for (var step = 0; step < 16; step++) {
      final middle = (inside + outside) / 2;
      if (field(Offset(x, axis + toward * middle)) < 0) {
        inside = middle;
      } else {
        outside = middle;
      }
    }
    return axis + toward * (inside + outside) / 2;
  }

  double tip(double inside, double outside) {
    for (var step = 0; step < 16; step++) {
      final middle = (inside + outside) / 2;
      if (field(Offset(middle, axisAt(middle))) < 0) {
        inside = middle;
      } else {
        outside = middle;
      }
    }
    return (inside + outside) / 2;
  }

  final path = Path();
  final steps = math.max(2, ((to - from) / _neckStep).ceil());
  var top = <Offset>[];
  var bottom = <Offset>[];
  void close() {
    if (top.isEmpty) {
      return;
    }
    path.addPolygon([...top, ...bottom.reversed], true);
    top = [];
    bottom = [];
  }

  bool flows(Offset point) =>
      (_pillDistance(a, point) - _pillDistance(b, point)).abs() < blend;

  double? previous;
  var wasInside = false;
  for (var index = 0; index <= steps; index++) {
    final x = from + (to - from) * index / steps;
    final inside = field(Offset(x, axisAt(x))) < 0;
    final upper = inside ? Offset(x, edge(x, -1)) : null;
    final lower = inside ? Offset(x, edge(x, 1)) : null;
    if (upper != null && lower != null && (flows(upper) || flows(lower))) {
      if (top.isEmpty && previous != null && !wasInside) {
        final start = tip(x, previous);
        top.add(Offset(start, axisAt(start)));
      }
      top.add(upper);
      bottom.add(lower);
    } else if (top.isNotEmpty) {
      if (!inside) {
        final end = tip(previous!, x);
        top.add(Offset(end, axisAt(end)));
      }
      close();
    }
    previous = x;
    wasInside = inside;
  }
  close();
  return path;
}
