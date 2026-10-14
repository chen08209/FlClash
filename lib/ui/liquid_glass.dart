import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

const _shaderAsset = 'shaders/liquid_glass.frag';
const _glowIn = Duration(milliseconds: 120);
const _glowOut = Duration(milliseconds: 360);
const double _glowSpread = 3;
const _profileTurns = 64;
const double _maxShaderFrost = 3;
// kLine in shaders/liquid_glass.frag.
const double _hairlineWidth = 0.67;
final _flatProfile = List<double>.unmodifiable(
  List<double>.filled(_profileTurns, 0),
);

/// Whether the navigation dock and the buttons of a page's bar are glass.
class LiquidGlassScope extends InheritedWidget {
  const LiquidGlassScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LiquidGlassScope>()?.enabled ??
      false;

  @override
  bool updateShouldNotify(LiquidGlassScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Lets the glass below read one shared copy of what lies behind it, rather
/// than a copy each. Glass in one group must never overlap.
class LiquidGlassGroup extends StatefulWidget {
  const LiquidGlassGroup({super.key, required this.child});

  final Widget child;

  static int? _idOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LiquidGlassGroupScope>()?.id;

  @override
  State<LiquidGlassGroup> createState() => _LiquidGlassGroupState();
}

class _LiquidGlassGroupState extends State<LiquidGlassGroup> {
  // Clear of the ids BackdropKey hands out, which count up from zero.
  static int _nextId = 1 << 30;

  final int _id = _nextId++;

  @override
  Widget build(BuildContext context) {
    return _LiquidGlassGroupScope(id: _id, child: widget.child);
  }
}

class _LiquidGlassGroupScope extends InheritedWidget {
  const _LiquidGlassGroupScope({required this.id, required super.child});

  final int id;

  @override
  bool updateShouldNotify(_LiquidGlassGroupScope oldWidget) =>
      id != oldWidget.id;
}

/// Lengths are dp. The shader shrinks [bevel] and [refraction] to fit a pane
/// too small for them, so that a button bends in proportion to the dock.
@immutable
class LiquidGlassStyle {
  const LiquidGlassStyle({
    required this.tint,
    this.contrast = 0,
    this.blur = 2.5,
    this.refraction = 60,
    this.bevel = 20,
    this.saturation = 1.5,
    this.brightness = 1,
    this.rim = 0.6,
    this.rimWidth = 1.3,
    this.endShade = 0,
    this.dispersion = 0,
    this.hairline = 0,
  });

  factory LiquidGlassStyle.regular(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
            contrast: -0.4,
            saturation: 2.84,
            rim: 0.35,
            hairline: 0.48,
          )
        : const LiquidGlassStyle(
            tint: Color(0x8AFDFDFD),
            contrast: 0.4,
            saturation: 2.08,
            hairline: 0.48,
          );
  }

  factory LiquidGlassStyle.pill(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
            contrast: -0.4,
            saturation: 1.925,
            rim: 0.35,
            hairline: 0.35,
          )
        : const LiquidGlassStyle(
            tint: Color(0x93F4F4F4),
            contrast: 0.4,
            saturation: 2.1,
            hairline: 0.35,
          );
  }

  /// Thicker than [LiquidGlassStyle.regular], for rows that read over anything.
  factory LiquidGlassStyle.menu(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainer.withValues(alpha: 0.7),
            contrast: -0.6,
            blur: 12,
            brightness: 0.96,
            rim: 0.35,
            hairline: 0.48,
          )
        : LiquidGlassStyle(
            tint: colorScheme.surfaceBright.withValues(alpha: 0.72),
            contrast: 0.6,
            blur: 12,
            hairline: 0.48,
          );
  }

  factory LiquidGlassStyle.tinted(ColorScheme colorScheme, Color color) {
    final dark = colorScheme.brightness == Brightness.dark;
    return LiquidGlassStyle(
      tint: color.withValues(alpha: 0.82),
      saturation: 1.2,
      rim: dark ? 0.35 : 0.6,
      hairline: 0.48,
    );
  }

  factory LiquidGlassStyle.lens(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return LiquidGlassStyle(
      tint: Colors.white.withValues(alpha: dark ? 0.08 : 0),
      blur: 0,
      refraction: -30,
      bevel: 11.2,
      saturation: 1,
      rimWidth: 1.1,
      endShade: 0.045,
      dispersion: 0.08,
      hairline: 0.42,
    );
  }

  final Color tint;

  /// How far the tint thickens toward opaque over content much darker, or if
  /// negative much lighter, than it, so what sits on the glass stays legible.
  final double contrast;
  final double blur;

  /// Negative for a raised lens, which bends outward at its top and bottom.
  final double refraction;
  final double bevel;
  final double saturation;
  final double brightness;

  final double rim;
  final double rimWidth;

  final double endShade;
  final double dispersion;
  final double hairline;

  /// Eases in from bare air, as glass materializes by bending, not fading.
  LiquidGlassStyle scale(double t) {
    final amount = t.clamp(0.0, 1.0);
    return LiquidGlassStyle(
      tint: tint.withValues(alpha: tint.a * amount),
      contrast: contrast * amount,
      blur: blur * amount,
      refraction: refraction * amount,
      bevel: bevel,
      saturation: 1 + (saturation - 1) * amount,
      brightness: 1 + (brightness - 1) * amount,
      rim: rim * amount,
      rimWidth: rimWidth,
      endShade: endShade * amount,
      dispersion: dispersion * amount,
      hairline: hairline * amount,
    );
  }

  static LiquidGlassStyle lerp(
    LiquidGlassStyle a,
    LiquidGlassStyle b,
    double t,
  ) {
    double between(double a, double b) => ui.lerpDouble(a, b, t)!;
    return LiquidGlassStyle(
      tint: Color.lerp(a.tint, b.tint, t)!,
      contrast: between(a.contrast, b.contrast),
      blur: between(a.blur, b.blur),
      refraction: between(a.refraction, b.refraction),
      bevel: between(a.bevel, b.bevel),
      saturation: between(a.saturation, b.saturation),
      brightness: between(a.brightness, b.brightness),
      rim: between(a.rim, b.rim),
      rimWidth: between(a.rimWidth, b.rimWidth),
      endShade: between(a.endShade, b.endShade),
      dispersion: between(a.dispersion, b.dispersion),
      hairline: between(a.hairline, b.hairline),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle &&
      other.tint == tint &&
      other.contrast == contrast &&
      other.blur == blur &&
      other.refraction == refraction &&
      other.bevel == bevel &&
      other.saturation == saturation &&
      other.brightness == brightness &&
      other.rim == rim &&
      other.rimWidth == rimWidth &&
      other.endShade == endShade &&
      other.dispersion == dispersion &&
      other.hairline == hairline;

  @override
  int get hashCode => Object.hash(
    tint,
    contrast,
    blur,
    refraction,
    bevel,
    saturation,
    brightness,
    rim,
    rimWidth,
    endShade,
    dispersion,
    hairline,
  );
}

/// Light a press casts on a pane, in its coordinates: [strength] at [center],
/// falling off over [reach] to [wash] of it across the rest of the pane.
@immutable
class LiquidGlassGlow {
  const LiquidGlassGlow({
    required this.center,
    required this.reach,
    required this.strength,
    this.wash = 0,
  });

  static const none = LiquidGlassGlow(
    center: Offset.zero,
    reach: 1,
    strength: 0,
  );

  final Offset center;
  final double reach;
  final double strength;
  final double wash;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassGlow &&
      other.center == center &&
      other.reach == reach &&
      other.strength == strength &&
      other.wash == wash;

  @override
  int get hashCode => Object.hash(center, reach, strength, wash);
}

/// A pane of glass behind [child], after iOS's Liquid Glass, a pill unless
/// [clipper] shapes it. It casts [shadows] only outside itself, as one
/// under it would show through. Without Impeller's shader filters it frosts
/// but does not bend.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.style,
    this.clipper,
    this.shadows = const [],
    this.grouped = true,
    this.pressed = false,
    this.glow,
    this.child,
  });

  final LiquidGlassStyle style;

  /// Shapes the pane to its path in place of the pill. The glass bends
  /// to the path by how far it reaches from the pane's center in each
  /// direction, so it must meet every ray from the center once.
  final CustomClipper<Path>? clipper;

  final List<BoxShadow> shadows;

  /// Reads the backdrop the enclosing [LiquidGlassGroup] shares; a pane that
  /// overlaps another one in the group, such as a lens, must not.
  final bool grouped;

  final bool pressed;

  /// Lights the pane in place of the glow [pressed] lights at its center.
  final LiquidGlassGlow? glow;

  final Widget? child;

  /// Builds the scenes of [capture] without panes, for a snapshot: offscreen
  /// a pane has no backdrop to bend and comes out a flat tint.
  static T withoutPanes<T>(T Function() capture) {
    _LiquidGlassLayer._skipped++;
    try {
      return capture();
    } finally {
      _LiquidGlassLayer._skipped--;
    }
  }

  /// Replaces a button's fill with glass.
  static ButtonStyle buttonStyle(
    LiquidGlassStyle Function(Set<WidgetState> states) styleOf,
  ) {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundBuilder: (context, states, child) => LiquidGlass(
        style: styleOf(states),
        pressed: states.contains(WidgetState.pressed),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = grouped ? LiquidGlassGroup._idOf(context) : null;
    final window = View.of(context).physicalSize;
    if (glow case final glow?) {
      return _LiquidGlassPane(
        style: style,
        clipper: clipper,
        shadows: shadows,
        group: group,
        press: 0,
        fading: false,
        glow: glow,
        window: window,
        child: child,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: pressed ? 1 : 0),
      duration: context.motionDuration(pressed ? _glowIn : _glowOut),
      curve: Curves.easeOut,
      builder: (context, press, child) => _LiquidGlassPane(
        style: style,
        clipper: clipper,
        shadows: shadows,
        group: group,
        press: press,
        fading: !pressed,
        glow: null,
        window: window,
        child: child,
      ),
      child: child,
    );
  }
}

class _LiquidGlassPane extends SingleChildRenderObjectWidget {
  const _LiquidGlassPane({
    required this.style,
    required this.clipper,
    required this.shadows,
    required this.group,
    required this.press,
    required this.fading,
    required this.glow,
    required this.window,
    super.child,
  });

  final LiquidGlassStyle style;
  final CustomClipper<Path>? clipper;
  final List<BoxShadow> shadows;
  final int? group;
  final double press;
  final bool fading;
  final LiquidGlassGlow? glow;
  final Size window;

  @override
  _RenderLiquidGlass createRenderObject(BuildContext context) {
    return _RenderLiquidGlass(
      style: style,
      clipper: clipper,
      shadows: shadows,
      group: group,
      press: press,
      fading: fading,
      glow: glow,
      window: window,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLiquidGlass renderObject,
  ) {
    renderObject
      ..style = style
      ..clipper = clipper
      ..shadows = shadows
      ..group = group
      ..press = press
      ..fading = fading
      ..glow = glow
      ..window = window;
  }
}

class _RenderLiquidGlass extends RenderProxyBox {
  _RenderLiquidGlass({
    required LiquidGlassStyle style,
    required CustomClipper<Path>? clipper,
    required List<BoxShadow> shadows,
    required int? group,
    required double press,
    required bool fading,
    required LiquidGlassGlow? glow,
    required Size window,
  }) : _style = style,
       _clipper = clipper,
       _shadows = shadows,
       _group = group,
       _press = press,
       _fading = fading,
       _glow = glow,
       _window = window;

  late final _pane = LiquidGlassPane(markNeedsPaint);

  LiquidGlassStyle _style;
  set style(LiquidGlassStyle value) {
    if (value == _style) {
      return;
    }
    _style = value;
    markNeedsPaint();
  }

  CustomClipper<Path>? _clipper;
  set clipper(CustomClipper<Path>? value) {
    final old = _clipper;
    if (value == old) {
      return;
    }
    if (attached) {
      old?.removeListener(_reclip);
      value?.addListener(_reclip);
    }
    _clipper = value;
    if (value == null ||
        old == null ||
        value.runtimeType != old.runtimeType ||
        value.shouldReclip(old)) {
      _reclip();
    }
  }

  Path? _outline;
  Size? _outlineSize;

  void _reclip() {
    _outline = null;
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

  int? _group;
  set group(int? value) {
    if (value == _group) {
      return;
    }
    _group = value;
    markNeedsPaint();
  }

  double _press;
  set press(double value) {
    if (value == _press) {
      return;
    }
    _press = value;
    if (value == 0) {
      _touch = null;
    }
    markNeedsPaint();
  }

  bool _fading;
  set fading(bool value) {
    if (value == _fading) {
      return;
    }
    _fading = value;
    markNeedsPaint();
  }

  // The pane wraps what it is the glass of, so it hears the presses on it and
  // lights from the finger, as iOS does; a key press lights its center.
  Offset? _touch;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      _touch = event.localPosition;
      if (_press > 0) {
        markNeedsPaint();
      }
    } else if (_press == 0) {
      _touch = null;
    }
  }

  LiquidGlassGlow? _glow;
  set glow(LiquidGlassGlow? value) {
    if (value == _glow) {
      return;
    }
    _glow = value;
    markNeedsPaint();
  }

  Size _window;
  set window(Size value) {
    if (value == _window) {
      return;
    }
    _window = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _clipper?.addListener(_reclip);
  }

  @override
  void detach() {
    _clipper?.removeListener(_reclip);
    super.detach();
  }

  @override
  void dispose() {
    _pane.dispose();
    super.dispose();
  }

  Path? get _currentOutline {
    final clipper = _clipper;
    if (clipper == null) {
      return null;
    }
    if (_outline == null || _outlineSize != size) {
      _outline = clipper.getClip(size);
      _outlineSize = size;
    }
    return _outline;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      _pane.clear();
    } else {
      final outline = _currentOutline;
      _pane.paint(
        context,
        offset & size,
        shape: outline != null
            ? LiquidGlassOutline(outline)
            : LiquidGlassCorners(BorderRadius.circular(size.shortestSide / 2)),
        style: _style,
        window: _window,
        shadows: _shadows,
        glow:
            _glow ??
            LiquidGlassGlow(
              center: _touch ?? size.center(Offset.zero),
              reach:
                  size.height /
                  math.sqrt2 *
                  (1 + (_fading ? _glowSpread * (1 - _press) : 0)),
              strength: _press * 0.16,
            ),
        group: _group,
      );
    }
    super.paint(context, offset);
  }
}

sealed class LiquidGlassShape {
  const LiquidGlassShape();
}

/// A rounded rectangle, no corner rounder than half the pane's short side.
final class LiquidGlassCorners extends LiquidGlassShape {
  const LiquidGlassCorners(this.radius);

  LiquidGlassCorners.circular(double radius)
    : radius = BorderRadius.circular(radius);

  final BorderRadius radius;
}

/// A path laid out from the pane's top left, as [LiquidGlass.clipper] gives.
final class LiquidGlassOutline extends LiquidGlassShape {
  const LiquidGlassOutline(this.path);

  final Path path;
}

/// A pane for a render object that shapes the glass itself, as a morph does.
class LiquidGlassPane {
  LiquidGlassPane(this.onReady);

  final VoidCallback onReady;

  final _layer = LayerHandle<_LiquidGlassLayer>();
  Path? _profiled;
  List<double> _profile = _flatProfile;

  void paint(
    PaintingContext context,
    Rect rect, {
    required LiquidGlassShape shape,
    required LiquidGlassStyle style,
    required Size window,
    List<BoxShadow> shadows = const [],
    LiquidGlassGlow glow = LiquidGlassGlow.none,
    int? group,
  }) {
    final pane = _layer.layer ??= _LiquidGlassLayer();
    switch (shape) {
      case LiquidGlassCorners(:final radius):
        final limit = Radius.circular(rect.shortestSide / 2);
        final corners = BorderRadius.only(
          topLeft: radius.topLeft.clamp(maximum: limit),
          topRight: radius.topRight.clamp(maximum: limit),
          bottomLeft: radius.bottomLeft.clamp(maximum: limit),
          bottomRight: radius.bottomRight.clamp(maximum: limit),
        );
        _profiled = null;
        _paintShadows(context.canvas, rect, corners, shadows);
        pane
          ..corners = corners
          ..outline = null
          ..profile = _flatProfile;
      case LiquidGlassOutline(:final path):
        assert(shadows.isEmpty, 'An outlined pane casts none');
        if (!identical(path, _profiled)) {
          _profiled = path;
          _profile = liquidGlassProfile(path, rect.size.center(Offset.zero));
        }
        pane
          ..corners = BorderRadius.zero
          ..outline = path.shift(rect.topLeft)
          ..profile = _profile;
    }
    pane
      ..program = _GlassProgram.request(onReady)
      ..rect = rect
      ..style = style
      ..glow = glow
      ..group = group
      ..window = window;
    context.addLayer(pane);
  }

  void clear() => _layer.layer = null;

  void dispose() {
    _GlassProgram.forget(onReady);
    clear();
  }

  static void _paintShadows(
    Canvas canvas,
    Rect rect,
    BorderRadius corners,
    List<BoxShadow> shadows,
  ) {
    if (shadows.isEmpty) {
      return;
    }
    final shape = AppShape.of(corners);
    final reach = shadows.fold(
      0.0,
      (reach, shadow) => math.max(
        reach,
        shadow.offset.distance + shadow.spreadRadius + shadow.blurRadius * 2,
      ),
    );
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(rect.inflate(reach))
          ..addPath(shape.getOuterPath(rect), Offset.zero),
      );
    for (final shadow in shadows) {
      canvas.drawRSuperellipse(
        corners.toRSuperellipse(
          rect.shift(shadow.offset).inflate(shadow.spreadRadius),
        ),
        shadow.toPaint(),
      );
    }
    canvas.restore();
  }
}

abstract final class _GlassProgram {
  static ui.FragmentProgram? _program;
  static Future<void>? _loading;

  /// Final: a bundled shader that failed once fails again, and every attempt
  /// loads synchronously on the UI isolate.
  static var _failed = false;
  static final _waiting = <VoidCallback>{};

  /// Makes the engine read a filter's input linearly (flutter-upgrade.md).
  static late final ui.Image linearInput;

  static ui.FragmentProgram? request(VoidCallback onLoaded) {
    if (_program != null ||
        _failed ||
        !ui.ImageFilter.isShaderFilterSupported) {
      return _program;
    }
    _waiting.add(onLoaded);
    _loading ??= _load().then(
      (program) {
        _program = program;
        final waiting = _waiting.toList();
        _waiting.clear();
        for (final callback in waiting) {
          callback();
        }
      },
      onError: (Object error, StackTrace stack) {
        _failed = true;
        _waiting.clear();
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'liquid glass',
          ),
        );
      },
    );
    return null;
  }

  static void forget(VoidCallback onLoaded) => _waiting.remove(onLoaded);

  static Future<ui.FragmentProgram> _load() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    final (program, image) = await (
      ui.FragmentProgram.fromAsset(_shaderAsset),
      recorder.endRecording().toImage(1, 1),
    ).wait;
    linearInput = image;
    return program;
  }
}

/// Where a pane lands on the texture its filter reads, found by walking the
/// layers above it: the engine hands a backdrop filter the whole surface it
/// draws into, so the pane has to be located on that surface.
@visibleForTesting
class LiquidGlassPlacement {
  const LiquidGlassPlacement({
    required this.device,
    required this.clip,
    required this.offscreen,
  });

  factory LiquidGlassPlacement.of(Layer layer, Rect rect, Size window) {
    final ancestors = <ContainerLayer>[
      for (var node = layer.parent; node != null; node = node.parent) node,
    ];
    final transform = Matrix4.identity();
    var clip = Offset.zero & window;
    var offscreen = false;
    for (var i = ancestors.length - 1; i >= 0; i--) {
      final ancestor = ancestors[i];
      offscreen = offscreen || _drawsOffscreen(ancestor);
      final bounds = ancestor.describeClipBounds();
      if (bounds != null) {
        clip = clip.intersect(
          _clipCoverage(
            ancestor,
            MatrixUtils.transformRect(transform, bounds),
            transform,
          ),
        );
      }
      ancestor.applyTransform(i == 0 ? layer : ancestors[i - 1], transform);
    }
    return LiquidGlassPlacement(
      device: MatrixUtils.transformRect(transform, rect),
      clip: clip,
      offscreen: offscreen,
    );
  }

  final Rect device;
  final Rect clip;

  /// Whether a layer above draws into a texture of its own, which then
  /// becomes the surface the pane's filter reads.
  final bool offscreen;

  /// A rect clip where Impeller's `EntityPassClipStack` snaps it to pixels.
  static Rect _clipCoverage(Layer layer, Rect bounds, Matrix4 transform) {
    if (layer is! ClipRectLayer ||
        transform.storage[1] != 0 ||
        transform.storage[4] != 0) {
      return bounds;
    }
    final snapped = Rect.fromLTRB(
      bounds.left.roundToDouble(),
      bounds.top.roundToDouble(),
      bounds.right.roundToDouble(),
      bounds.bottom.roundToDouble(),
    );
    bool near(double edge, double pixel) => (edge - pixel).abs() <= 0.124;
    return layer.clipBehavior == Clip.hardEdge ||
            near(bounds.left, snapped.left) &&
                near(bounds.top, snapped.top) &&
                near(bounds.right, snapped.right) &&
                near(bounds.bottom, snapped.bottom)
        ? snapped
        : bounds;
  }

  static bool _drawsOffscreen(Layer layer) {
    return switch (layer) {
      OpacityLayer(:final alpha) => alpha != null && alpha < 255,
      ColorFilterLayer() ||
      ImageFilterLayer() ||
      ShaderMaskLayer() ||
      BackdropFilterLayer() => true,
      ClipRectLayer(:final clipBehavior) ||
      ClipRRectLayer(:final clipBehavior) ||
      ClipRSuperellipseLayer(:final clipBehavior) ||
      ClipPathLayer(
        :final clipBehavior,
      ) => clipBehavior == Clip.antiAliasWithSaveLayer,
      _ => false,
    };
  }
}

/// On the window's own surface a pane reads the backdrop its group shares and
/// locates itself in window pixels. Under a layer that draws offscreen, as a
/// fading route does, the engine places that texture as it sees fit, so the
/// pane frosts into a texture of its own, sized to the part the clips leave,
/// and locates itself in that. Hence the scene builder calls, made per frame.
class _LiquidGlassLayer extends Layer {
  static int _skipped = 0;

  ui.FragmentProgram? program;
  Rect rect = Rect.zero;
  BorderRadius corners = BorderRadius.zero;
  Path? outline;
  List<double> profile = _flatProfile;
  LiquidGlassStyle style = const LiquidGlassStyle(tint: Colors.transparent);
  LiquidGlassGlow glow = LiquidGlassGlow.none;
  int? group;
  Size window = Size.zero;

  ui.FragmentShader? _shader;
  List<double>? _uniforms;
  ui.ImageFilter? _bend;
  ui.Picture? _frost;
  (Rect, BorderRadius, Path?, LiquidGlassStyle)? _frostKey;

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void dispose() {
    _shader?.dispose();
    _frost?.dispose();
    super.dispose();
  }

  ui.ImageFilter get _blur => style.blur > 0
      ? ui.ImageFilter.blur(sigmaX: style.blur, sigmaY: style.blur)
      : const ColorFilter.matrix(_identity);

  bool get _shaderFrosts => style.blur <= _maxShaderFrost;

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (_skipped > 0) {
      return;
    }
    final placement = LiquidGlassPlacement.of(this, rect, window);
    if (outline case final outline?) {
      builder.pushClipPath(outline);
    } else {
      builder.pushClipRSuperellipse(corners.toRSuperellipse(rect));
    }
    final program = this.program;
    if (program == null || placement.device.isEmpty) {
      _addFrost(builder);
    } else if (!placement.offscreen) {
      final device = placement.device;
      final bend = _bendFilter(
        program,
        _frame(device, device.intersect(placement.clip), Offset.zero),
      );
      builder.pushBackdropFilter(
        _shaderFrosts
            ? bend
            : ui.ImageFilter.compose(outer: bend, inner: _blur),
        backdropId: group,
      );
      builder.pop();
    } else {
      final device = placement.device;
      final visible = device.intersect(placement.clip);
      if (!visible.isEmpty) {
        builder.pushBackdropFilter(
          _shaderFrosts ? const ColorFilter.matrix(_identity) : _blur,
        );
        builder.pushBackdropFilter(
          _bendFilter(
            program,
            _frame(
              device,
              visible,
              Offset(visible.left.floorToDouble(), visible.top.floorToDouble()),
            ),
          ),
        );
        builder.pop();
        builder.pop();
      }
    }
    builder.pop();
  }

  /// The pane on the texture its filter reads, from [pass] (flutter-upgrade.md).
  List<double> _frame(Rect device, Rect visible, Offset pass) {
    final scaleX = rect.width / device.width;
    final scaleY = rect.height / device.height;
    double origin(double edge, double start, double cut) =>
        edge - start + cut - cut.floorToDouble();
    return [
      -origin(device.left, pass.dx, visible.left) * scaleX,
      -origin(device.top, pass.dy, visible.top) * scaleY,
      scaleX,
      scaleY,
    ];
  }

  ui.ImageFilter _bendFilter(ui.FragmentProgram program, List<double> frame) {
    final uniforms = [
      ...frame,
      rect.width,
      rect.height,
      style.bevel,
      if (_shaderFrosts) style.blur else 0.0,
      corners.topLeft.x,
      corners.topRight.x,
      corners.bottomRight.x,
      corners.bottomLeft.x,
      style.refraction,
      style.saturation,
      style.brightness,
      style.tint.r,
      style.tint.g,
      style.tint.b,
      style.tint.a,
      style.rim,
      style.rimWidth,
      style.endShade,
      glow.center.dx,
      glow.center.dy,
      glow.strength,
      style.contrast,
      glow.reach,
      glow.wash,
      style.hairline,
      style.dispersion,
      outline == null ? 0.0 : 1.0,
      ...profile,
    ];
    final cached = _bend;
    if (cached != null && listEquals(uniforms, _uniforms)) {
      return cached;
    }
    final shader = _shader ??= program.fragmentShader()
      ..setImageSampler(
        0,
        _GlassProgram.linearInput,
        filterQuality: FilterQuality.low,
      );
    for (final (index, value) in uniforms.indexed) {
      // The first two floats are the texture size the engine fills.
      shader.setFloat(index + 2, value);
    }
    _uniforms = uniforms;
    return _bend = ui.ImageFilter.shader(shader);
  }

  void _addFrost(ui.SceneBuilder builder) {
    final key = (rect, corners, outline, style);
    if (_frost == null || key != _frostKey) {
      _frost?.dispose();
      _frost = _paintFrost();
      _frostKey = key;
    }
    final saturate = ColorFilter.matrix(_saturation(style.saturation));
    builder.pushBackdropFilter(
      ui.ImageFilter.compose(outer: saturate, inner: _blur),
      backdropId: group,
    );
    builder.addPicture(Offset.zero, _frost!);
    builder.pop();
  }

  ui.Picture _paintFrost() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final tint = style.tint;
    final fill = Paint()
      ..color = tint.withValues(alpha: math.min(1, tint.a + 0.2));
    final rim = style.rim;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.rimWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: rim),
          Colors.white.withValues(alpha: rim * 0.15),
          Colors.white.withValues(alpha: rim * 0.5),
        ],
      ).createShader(rect);
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withValues(alpha: style.hairline * 0.3);
    if (outline case final outline?) {
      // The clip keeps the inner half of a stroke twice as wide.
      canvas
        ..drawPath(outline, fill)
        ..drawPath(outline, stroke..strokeWidth = style.rimWidth * 2)
        ..drawPath(outline, hairline..strokeWidth = _hairlineWidth * 2);
    } else {
      final shape = corners.toRSuperellipse(rect);
      canvas
        ..drawRSuperellipse(shape, fill)
        ..drawRSuperellipse(shape.deflate(style.rimWidth / 2), stroke)
        ..drawRSuperellipse(
          shape.deflate(_hairlineWidth / 2),
          hairline..strokeWidth = _hairlineWidth,
        );
    }
    return recorder.endRecording();
  }
}

/// How far [outline] reaches from [center] along [_profileTurns] even turns,
/// the first toward +x and the rest toward +y, as the shader reads it.
@visibleForTesting
List<double> liquidGlassProfile(Path outline, Offset center) {
  const step = 2 * math.pi / _profileTurns;
  final profile = List<double>.filled(_profileTurns, 0);
  void cross(Offset from, Offset to) {
    final start = from.direction;
    var span = to.direction - start;
    if (span > math.pi) {
      span -= 2 * math.pi;
    } else if (span <= -math.pi) {
      span += 2 * math.pi;
    }
    final edge = to - from;
    final first = (math.min(start, start + span) / step).ceil();
    final last = (math.max(start, start + span) / step).floor();
    for (var turn = first; turn <= last; turn++) {
      final ray = Offset.fromDirection(turn * step);
      final facing = ray.dx * edge.dy - ray.dy * edge.dx;
      profile[turn % _profileTurns] = facing.abs() < 1e-9
          ? math.max(from.distance, to.distance)
          : (from.dx * edge.dy - from.dy * edge.dx) / facing;
    }
  }

  for (final metric in outline.computeMetrics()) {
    final samples = math.max(_profileTurns * 4, metric.length.ceil());
    Offset pointAt(int index) =>
        metric.getTangentForOffset(metric.length * index / samples)!.position -
        center;
    var previous = pointAt(0);
    for (var index = 1; index <= samples; index++) {
      final next = pointAt(index);
      cross(previous, next);
      previous = next;
    }
  }
  return profile;
}

const _identity = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

List<double> _saturation(double amount) {
  const red = 0.2126;
  const green = 0.7152;
  const blue = 0.0722;
  final rest = 1 - amount;
  return [
    red * rest + amount, green * rest, blue * rest, 0, 0, //
    red * rest, green * rest + amount, blue * rest, 0, 0,
    red * rest, green * rest, blue * rest + amount, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
