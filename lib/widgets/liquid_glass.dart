import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

// Kyant0/AndroidLiquidGlass's backdrop defaults, its dp read as logical px.
const double _shadowRadius = 24;
const Offset _shadowOffset = Offset(0, _shadowRadius / 6);
const double _shadowAlpha = 0.1;
const double _innerShadowAlpha = 0.15;
const double _highlightWidth = 0.5;
const double _highlightAlpha = 0.5;
const double _highlightAngle = math.pi / 4;
const double _glowAlpha = 0.08;
const double _glowSpotAlpha = 0.15;
const double _glowSpotRadius = 1.5;
const _glowStops = [0.0, 0.5, 0.625, 0.75, 0.875, 1.0];
const double _vibrancySaturation = 1.5;

final ui.ColorFilter _vibrancy = _saturation(_vibrancySaturation);

ui.ColorFilter _saturation(double saturation) {
  final red = 0.213 * (1 - saturation);
  final green = 0.715 * (1 - saturation);
  final blue = 0.072 * (1 - saturation);
  return ui.ColorFilter.matrix([
    red + saturation, green, blue, 0, 0, //
    red, green + saturation, blue, 0, 0, //
    red, green, blue + saturation, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}

/// Android's blur radius to sigma, in logical pixels.
double _sigma(double radius, double devicePixelRatio) {
  return radius * 0.57735 + 0.5 / devicePixelRatio;
}

RSuperellipse _capsule(Size size) =>
    AppRadius.full.toRSuperellipse(Offset.zero & size);

/// The glass shader programs, loaded once for the life of the process.
class LiquidGlassShaders {
  LiquidGlassShaders._(List<ui.FragmentProgram> programs)
    : refraction = programs[0].fragmentShader(),
      dispersion = programs[1].fragmentShader(),
      highlight = programs[2].fragmentShader();

  final ui.FragmentShader refraction;
  final ui.FragmentShader dispersion;
  final ui.FragmentShader highlight;

  static LiquidGlassShaders? _loaded;
  static Future<LiquidGlassShaders?>? _loading;

  /// Null until [load] has finished, and for good if it failed.
  static LiquidGlassShaders? get loaded => _loaded;

  static Future<LiquidGlassShaders?> load() => _loading ??= _load();

  static Future<LiquidGlassShaders?> _load() async {
    try {
      final programs = await Future.wait([
        for (final name in ['refraction', 'dispersion', 'highlight'])
          ui.FragmentProgram.fromAsset('shaders/liquid_glass_$name.frag'),
      ]);
      return _loaded = LiquidGlassShaders._(programs);
    } catch (error) {
      commonPrint.log(
        'Liquid glass shaders failed to load: $error',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }
}

/// A capsule of glass after the backdrop library's `drawBackdrop`: shadow,
/// backdrop through `vibrancy`, `blur` and `lens`, surface [color], inner
/// shadow, rim light. The lens alone needs Impeller's shader filters.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.shaders,
    required this.color,
    this.blurRadius = 0,
    this.vibrancy = false,
    this.refractionHeight = 0,
    this.refractionAmount = 0,
    this.chromaticAberration = false,
    this.shadowAlpha = 0,
    this.innerShadowRadius = 0,
    this.innerShadowAlpha = 0,
    this.highlightAlpha = 0,
  });

  final LiquidGlassShaders? shaders;
  final Color color;
  final double blurRadius;
  final bool vibrancy;
  final double refractionHeight;
  final double refractionAmount;
  final bool chromaticAberration;
  final double shadowAlpha;
  final double innerShadowRadius;
  final double innerShadowAlpha;
  final double highlightAlpha;

  ui.ImageFilter? _blur(double devicePixelRatio) {
    final blur = blurRadius > 0
        ? ui.ImageFilter.blur(
            sigmaX: _sigma(blurRadius, devicePixelRatio),
            sigmaY: _sigma(blurRadius, devicePixelRatio),
            tileMode: TileMode.clamp,
          )
        : null;
    if (!vibrancy) {
      return blur;
    }
    return blur == null
        ? _vibrancy
        : ui.ImageFilter.compose(outer: blur, inner: _vibrancy);
  }

  Widget _backdrop(double devicePixelRatio, Widget surface) {
    final blur = _blur(devicePixelRatio);
    final shader = chromaticAberration
        ? shaders?.dispersion
        : shaders?.refraction;
    if (shader != null &&
        refractionHeight > 0 &&
        refractionAmount > 0 &&
        ui.ImageFilter.isShaderFilterSupported) {
      return _LensBackdrop(
        shader: shader,
        blur: blur,
        refractionHeight: refractionHeight,
        refractionAmount: refractionAmount,
        child: surface,
      );
    }
    if (blur == null) {
      return surface;
    }
    return BackdropFilter(filter: blur, child: surface);
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return CustomPaint(
      painter: shadowAlpha > 0
          ? _ShadowPainter(
              alpha: shadowAlpha,
              devicePixelRatio: devicePixelRatio,
            )
          : null,
      foregroundPainter: innerShadowAlpha > 0 || highlightAlpha > 0
          ? _RimPainter(
              shaders: shaders,
              devicePixelRatio: devicePixelRatio,
              innerShadowRadius: innerShadowRadius,
              innerShadowAlpha: innerShadowAlpha,
              highlightAlpha: highlightAlpha,
            )
          : null,
      child: ClipRSuperellipse(
        borderRadius: AppRadius.full,
        child: _backdrop(devicePixelRatio, ColoredBox(color: color)),
      ),
    );
  }
}

/// The rim light of a capsule of glass, ALG's `Highlight.Default`.
class LiquidGlassHighlight extends StatelessWidget {
  const LiquidGlassHighlight({
    super.key,
    required this.shaders,
    this.alpha = 1,
  });

  final LiquidGlassShaders? shaders;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RimPainter(
        shaders: shaders,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        highlightAlpha: alpha,
      ),
    );
  }
}

/// The catalog's `InteractiveHighlight`: a press glowing around [center].
class LiquidGlassGlow extends StatelessWidget {
  const LiquidGlassGlow({
    super.key,
    required this.center,
    required this.progress,
  });

  final Offset center;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(center: center, progress: progress),
    );
  }
}

class _ShadowPainter extends CustomPainter {
  const _ShadowPainter({required this.alpha, required this.devicePixelRatio});

  final double alpha;
  final double devicePixelRatio;

  // Clipped out of the shape, so it cannot darken the glass above it.
  @override
  void paint(Canvas canvas, Size size) {
    final outline = _capsule(size);
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(_shadowRadius * 4))
      ..addRSuperellipse(outline);
    canvas
      ..save()
      ..clipPath(outside)
      ..drawRSuperellipse(
        outline.shift(_shadowOffset),
        Paint()
          ..color = Colors.black.withValues(alpha: _shadowAlpha * alpha)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            _sigma(_shadowRadius, devicePixelRatio),
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) {
    return alpha != oldDelegate.alpha ||
        devicePixelRatio != oldDelegate.devicePixelRatio;
  }
}

class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.shaders,
    required this.devicePixelRatio,
    this.innerShadowRadius = 0,
    this.innerShadowAlpha = 0,
    this.highlightAlpha = 0,
  });

  final LiquidGlassShaders? shaders;
  final double devicePixelRatio;
  final double innerShadowRadius;
  final double innerShadowAlpha;
  final double highlightAlpha;

  void _paintInnerShadow(Canvas canvas, RSuperellipse outline) {
    final shape = Path()..addRSuperellipse(outline);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        shape,
        shape.shift(Offset(0, innerShadowRadius)),
      ),
      Paint()
        ..color = Colors.black.withValues(
          alpha: _innerShadowAlpha * innerShadowAlpha,
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          _sigma(innerShadowRadius, devicePixelRatio),
        ),
    );
  }

  void _paintHighlight(Canvas canvas, Size size, RSuperellipse outline) {
    final width =
        (math.min(_highlightWidth, size.shortestSide / 2) * devicePixelRatio)
            .ceilToDouble() *
        2 /
        devicePixelRatio;
    final alpha = _highlightAlpha * highlightAlpha;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..blendMode = BlendMode.plus
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        _sigma(_highlightWidth / 2, devicePixelRatio),
      );
    final shader = shaders?.highlight;
    if (shader == null) {
      paint.color = Colors.white.withValues(alpha: alpha);
    } else {
      final radius = size.shortestSide / 2;
      paint.shader = shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, radius)
        ..setFloat(3, radius)
        ..setFloat(4, radius)
        ..setFloat(5, radius)
        ..setFloat(6, alpha)
        ..setFloat(7, alpha)
        ..setFloat(8, alpha)
        ..setFloat(9, alpha)
        ..setFloat(10, _highlightAngle)
        ..setFloat(11, 1);
    }
    canvas.drawRSuperellipse(outline, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final outline = _capsule(size);
    canvas
      ..save()
      ..clipRSuperellipse(outline);
    if (innerShadowAlpha > 0 && innerShadowRadius > 0) {
      _paintInnerShadow(canvas, outline);
    }
    if (highlightAlpha > 0) {
      _paintHighlight(canvas, size, outline);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) {
    return shaders != oldDelegate.shaders ||
        devicePixelRatio != oldDelegate.devicePixelRatio ||
        innerShadowRadius != oldDelegate.innerShadowRadius ||
        innerShadowAlpha != oldDelegate.innerShadowAlpha ||
        highlightAlpha != oldDelegate.highlightAlpha;
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter({required this.center, required this.progress});

  final Offset center;
  final double progress;

  // The catalog's shader is `smoothstep(radius, radius / 2, distance)`.
  static double _falloff(double stop) {
    final t = ((1 - stop) * 2).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..save()
      ..clipRSuperellipse(_capsule(size))
      ..drawRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: _glowAlpha * progress)
          ..blendMode = BlendMode.plus,
      )
      ..drawRect(
        rect,
        Paint()
          ..shader =
              ui.Gradient.radial(center, size.shortestSide * _glowSpotRadius, [
                for (final stop in _glowStops)
                  Colors.white.withValues(
                    alpha: _glowSpotAlpha * progress * _falloff(stop),
                  ),
              ], _glowStops)
          ..blendMode = BlendMode.plus,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) {
    return center != oldDelegate.center || progress != oldDelegate.progress;
  }
}

/// Maps [layer]'s space to the pixels of the whole backdrop a shader filter
/// receives, or null under an ancestor that reads its own backdrop at an
/// origin the framework cannot see. Unlike the render tree, the layer tree
/// carries paint-only transforms such as a press swell.
@visibleForTesting
Matrix4? backdropTransform(Layer layer) {
  final transform = Matrix4.identity();
  Layer child = layer;
  for (var parent = layer.parent; parent != null; parent = parent.parent) {
    final isolates = switch (parent) {
      OpacityLayer(:final alpha) => alpha != null && alpha < 255,
      ColorFilterLayer() ||
      ImageFilterLayer() ||
      ShaderMaskLayer() ||
      BackdropFilterLayer() ||
      _LensLayer() => true,
      _ => false,
    };
    if (isolates) {
      return null;
    }
    final step = Matrix4.identity();
    parent.applyTransform(child, step);
    transform.leftMultiply(step);
    child = parent;
  }
  return transform;
}

/// The lens shaders' uniforms that follow the engine-set input size.
@visibleForTesting
List<double> lensUniforms(
  Matrix4 toBackdrop,
  Rect rect, {
  required double refractionHeight,
  required double refractionAmount,
}) {
  final shape = MatrixUtils.transformRect(toBackdrop, rect);
  final scale = shape.shortestSide / rect.shortestSide;
  final radius = shape.shortestSide / 2;
  return [
    shape.width,
    shape.height,
    -shape.left,
    -shape.top,
    radius,
    radius,
    radius,
    radius,
    refractionHeight * scale,
    -refractionAmount * scale,
  ];
}

class _LensBackdrop extends SingleChildRenderObjectWidget {
  const _LensBackdrop({
    required this.shader,
    required this.blur,
    required this.refractionHeight,
    required this.refractionAmount,
    super.child,
  });

  final ui.FragmentShader shader;
  final ui.ImageFilter? blur;
  final double refractionHeight;
  final double refractionAmount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLensBackdrop(
      shader: shader,
      blur: blur,
      refractionHeight: refractionHeight,
      refractionAmount: refractionAmount,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLensBackdrop renderObject,
  ) {
    renderObject
      ..shader = shader
      ..blur = blur
      ..refractionHeight = refractionHeight
      ..refractionAmount = refractionAmount;
  }
}

class _RenderLensBackdrop extends RenderProxyBox {
  _RenderLensBackdrop({
    required ui.FragmentShader shader,
    required ui.ImageFilter? blur,
    required double refractionHeight,
    required double refractionAmount,
  }) : _shader = shader,
       _blur = blur,
       _refractionHeight = refractionHeight,
       _refractionAmount = refractionAmount;

  ui.FragmentShader _shader;
  set shader(ui.FragmentShader value) {
    if (value == _shader) {
      return;
    }
    _shader = value;
    markNeedsPaint();
  }

  ui.ImageFilter? _blur;
  set blur(ui.ImageFilter? value) {
    if (value == _blur) {
      return;
    }
    _blur = value;
    markNeedsPaint();
  }

  double _refractionHeight;
  set refractionHeight(double value) {
    if (value == _refractionHeight) {
      return;
    }
    _refractionHeight = value;
    markNeedsPaint();
  }

  double _refractionAmount;
  set refractionAmount(double value) {
    if (value == _refractionAmount) {
      return;
    }
    _refractionAmount = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty) {
      layer = null;
      return;
    }
    final lens = layer as _LensLayer? ?? _LensLayer();
    lens
      ..rect = offset & size
      ..shader = _shader
      ..blur = _blur
      ..refractionHeight = _refractionHeight
      ..refractionAmount = _refractionAmount;
    layer = lens;
    context.pushLayer(lens, super.paint, offset);
  }
}

/// Builds its filter at compositing, so the lens follows whatever moved it.
class _LensLayer extends ContainerLayer {
  Rect rect = Rect.zero;
  late ui.FragmentShader shader;
  ui.ImageFilter? blur;
  double refractionHeight = 0;
  double refractionAmount = 0;

  @override
  bool get alwaysNeedsAddToScene => true;

  ui.ImageFilter? _filter() {
    final transform = backdropTransform(this);
    if (transform == null || rect.isEmpty) {
      return blur;
    }
    final uniforms = lensUniforms(
      transform,
      rect,
      refractionHeight: refractionHeight,
      refractionAmount: refractionAmount,
    );
    for (final (index, value) in uniforms.indexed) {
      shader.setFloat(index + 2, value);
    }
    final lens = ui.ImageFilter.shader(shader);
    final inner = blur;
    return inner == null
        ? lens
        : ui.ImageFilter.compose(outer: lens, inner: inner);
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    final filter = _filter();
    if (filter == null) {
      engineLayer = null;
      addChildrenToScene(builder);
      return;
    }
    engineLayer = builder.pushBackdropFilter(
      filter,
      oldLayer: engineLayer as ui.BackdropFilterEngineLayer?,
    );
    addChildrenToScene(builder);
    builder.pop();
  }
}
