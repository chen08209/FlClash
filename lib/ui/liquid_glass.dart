import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

part 'liquid_glass_capture.dart';

const _shaderAsset = 'shaders/liquid_glass.frag';
const _glowIn = Duration(milliseconds: 120);
const _glowOut = Duration(milliseconds: 360);
const double _glowSpread = 3;
const _profileTurns = 64;
// kLine in shaders/liquid_glass.frag.
const double _hairlineWidth = 0.67;
// In corner radii from the corner of the bounds.
const _shineAround = [
  (along: 1.53, down: 0.0, lit: 0.68),
  (along: 1.0, down: 0.0, lit: 0.48),
  (along: 0.3, down: 0.3, lit: 0.38),
  (along: 0.0, down: 1.0, lit: 0.17),
  (along: 0.0, down: 1.5, lit: 0.07),
  (along: 0.0, down: 2.0, lit: 0.03),
];
const _shineBands = [
  (depth: 0.0, width: 1 / 3, lit: 1.0),
  (depth: 1 / 3, width: 1 / 3, lit: 0.7),
  (depth: 2 / 3, width: 1 / 3, lit: 0.47),
  (depth: 1.0, width: 2 / 3, lit: 0.18),
  (depth: 5 / 3, width: 2 / 3, lit: 0.12),
  (depth: 7 / 3, width: 2 / 3, lit: 0.085),
  (depth: 3.0, width: 2 / 3, lit: 0.065),
  (depth: 11 / 3, width: 2 / 3, lit: 0.045),
  (depth: 13 / 3, width: 2 / 3, lit: 0.035),
];
// The size of uShineEnds in shaders/liquid_glass.frag.
const _shineSlots = 12;
final _noShine = List<double>.unmodifiable(
  List<double>.filled(2 * (_shineAround.length + 2) + 2 * _shineSlots, 0),
);
final _flatProfile = List<double>.unmodifiable(
  List<double>.filled(_profileTurns, 0),
);

/// How much of iOS's glass the panes draw (.agents/architecture.md).
enum LiquidGlassQuality { standard, ultra }

/// Whether the navigation dock and the buttons of a page's bar are glass.
class LiquidGlassScope extends InheritedWidget {
  const LiquidGlassScope({
    super.key,
    required this.enabled,
    this.quality = LiquidGlassQuality.ultra,
    required super.child,
  });

  final bool enabled;
  final LiquidGlassQuality quality;

  static bool of(BuildContext context) => _of(context)?.enabled ?? false;

  static LiquidGlassQuality qualityOf(BuildContext context) =>
      _of(context)?.quality ?? LiquidGlassQuality.ultra;

  static LiquidGlassScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LiquidGlassScope>();

  @override
  bool updateShouldNotify(LiquidGlassScope oldWidget) =>
      enabled != oldWidget.enabled || quality != oldWidget.quality;
}

/// Lengths are dp. The shader shrinks [bevel] and [refraction] to fit a pane
/// too small for them, so that a button bends in proportion to the dock.
@immutable
class LiquidGlassStyle {
  const LiquidGlassStyle({
    required this.tint,
    this.contrast = 0,
    this.blur = 2.5,
    this.haze = 0,
    this.hazeBlur = 0,
    this.refraction = 60,
    this.bevel = 20,
    this.saturation = 1.5,
    this.brightness = 1,
    this.rim = 0.6,
    this.rimWidth = 1.3,
    this.rimTail = 0,
    this.rimFocus = 0,
    this.rimAdded = 0,
    this.endShade = 0,
    this.dispersion = 0,
    this.rimBlur = 0,
    this.hairline = 0,
    this.hairlineSide,
  });

  factory LiquidGlassStyle.regular(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
            contrast: -0.4,
            saturation: 2.84,
            rim: 0.28,
            rimWidth: 1.2,
            rimTail: 0.17,
            rimFocus: 1,
            rimAdded: 0.38,
            hairlineSide: 0.75,
          )
        : const LiquidGlassStyle(
            tint: Color(0x8AFDFDFD),
            contrast: 0.4,
            saturation: 2.08,
            rim: 0.28,
            rimWidth: 1.2,
            rimTail: 0.17,
            rimFocus: 1,
            rimAdded: 0.38,
            hairline: 0.25,
            hairlineSide: 0.75,
          );
  }

  factory LiquidGlassStyle.pill(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
            contrast: -0.4,
            blur: 0,
            haze: 0.72,
            hazeBlur: 15.6,
            saturation: 1.925,
            rim: 0.35,
          )
        : const LiquidGlassStyle(
            tint: Color(0x93F4F4F4),
            contrast: 0.4,
            blur: 0,
            haze: 0.72,
            hazeBlur: 15.6,
            saturation: 2.1,
            hairline: 0.35,
          );
  }

  /// Thicker than [LiquidGlassStyle.regular], for rows that read over anything.
  /// It takes its rim from a [LiquidGlassRim].
  factory LiquidGlassStyle.menu(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return dark
        ? LiquidGlassStyle(
            tint: colorScheme.surfaceContainerHighest.withValues(alpha: 0.63),
            contrast: -0.53,
            blur: 12,
            saturation: 1.75,
            brightness: 1.8,
            rim: 0,
          )
        : LiquidGlassStyle(
            tint: colorScheme.surfaceBright.withValues(alpha: 0.55),
            blur: 12,
            saturation: 2,
            brightness: 1.1,
            rim: 0,
          );
  }

  factory LiquidGlassStyle.alert(ColorScheme colorScheme) =>
      LiquidGlassStyle.menu(colorScheme).copyWith(blur: 16);

  factory LiquidGlassStyle.tinted(ColorScheme colorScheme, Color color) {
    final dark = colorScheme.brightness == Brightness.dark;
    return LiquidGlassStyle(
      tint: color.withValues(alpha: 0.82),
      saturation: 1.2,
      rim: dark ? 0.14 : 0.2,
      rimWidth: 1.2,
      rimTail: 0.17,
      rimFocus: 1,
      rimAdded: 0.38,
      hairline: dark ? 0 : 0.34,
      hairlineSide: dark ? 0.73 : 0.5,
    );
  }

  factory LiquidGlassStyle.lens(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return LiquidGlassStyle(
      tint: Colors.transparent,
      blur: 0,
      refraction: -4.3,
      bevel: 5.5,
      saturation: 1,
      brightness: dark ? 1.33 : 1,
      rim: dark ? 0.3 : 0.6,
      rimWidth: 1.1,
      endShade: 0.045,
      dispersion: 6.5,
      rimBlur: 1.5,
      hairline: 0.42,
    );
  }

  factory LiquidGlassStyle.lensContent(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    return LiquidGlassStyle(
      tint: Colors.transparent,
      blur: 0,
      refraction: 14,
      bevel: 11.2,
      saturation: 1,
      brightness: dark ? 1.33 : 1,
      rim: 0,
      dispersion: 3.6,
      rimBlur: 2.5,
    );
  }

  final Color tint;

  /// How far the tint thickens toward opaque over content much darker, or if
  /// negative much lighter, than it, so what sits on the glass stays legible.
  final double contrast;
  final double blur;

  /// The share of the backdrop seen through [hazeBlur] rather than [blur].
  final double haze;
  final double hazeBlur;

  /// Negative for a raised lens, which reads outward all around its rim.
  final double refraction;
  final double bevel;
  final double saturation;
  final double brightness;

  final double rim;
  final double rimWidth;

  final double rimTail;

  /// 0 dims [rim] round the ends as on iOS's tab bar, 1 as on its controls.
  final double rimFocus;

  /// The share of [rim] added as light rather than screened toward white.
  final double rimAdded;

  final double endShade;
  final double dispersion;

  final double rimBlur;
  final double hairline;
  final double? hairlineSide;

  /// Eases in from bare air, as glass materializes by bending, not fading.
  LiquidGlassStyle scale(double t) {
    final amount = t.clamp(0.0, 1.0);
    return LiquidGlassStyle(
      tint: tint.withValues(alpha: tint.a * amount),
      contrast: contrast * amount,
      blur: blur * amount,
      haze: haze * amount,
      hazeBlur: hazeBlur,
      refraction: refraction * amount,
      bevel: bevel,
      saturation: 1 + (saturation - 1) * amount,
      brightness: 1 + (brightness - 1) * amount,
      rim: rim * amount,
      rimWidth: rimWidth,
      rimTail: rimTail,
      rimFocus: rimFocus,
      rimAdded: rimAdded,
      endShade: endShade * amount,
      dispersion: dispersion * amount,
      rimBlur: rimBlur * amount,
      hairline: hairline * amount,
      hairlineSide: hairlineSide == null ? null : hairlineSide! * amount,
    );
  }

  LiquidGlassStyle copyWith({double? blur}) => LiquidGlassStyle(
    tint: tint,
    contrast: contrast,
    blur: blur ?? this.blur,
    haze: haze,
    hazeBlur: hazeBlur,
    refraction: refraction,
    bevel: bevel,
    saturation: saturation,
    brightness: brightness,
    rim: rim,
    rimWidth: rimWidth,
    rimTail: rimTail,
    rimFocus: rimFocus,
    rimAdded: rimAdded,
    endShade: endShade,
    dispersion: dispersion,
    rimBlur: rimBlur,
    hairline: hairline,
    hairlineSide: hairlineSide,
  );

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
      haze: between(a.haze, b.haze),
      hazeBlur: between(a.hazeBlur, b.hazeBlur),
      refraction: between(a.refraction, b.refraction),
      bevel: between(a.bevel, b.bevel),
      saturation: between(a.saturation, b.saturation),
      brightness: between(a.brightness, b.brightness),
      rim: between(a.rim, b.rim),
      rimWidth: between(a.rimWidth, b.rimWidth),
      rimTail: between(a.rimTail, b.rimTail),
      rimFocus: between(a.rimFocus, b.rimFocus),
      rimAdded: between(a.rimAdded, b.rimAdded),
      endShade: between(a.endShade, b.endShade),
      dispersion: between(a.dispersion, b.dispersion),
      rimBlur: between(a.rimBlur, b.rimBlur),
      hairline: between(a.hairline, b.hairline),
      hairlineSide: between(a._hairlineSide, b._hairlineSide),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle &&
      other.tint == tint &&
      other.contrast == contrast &&
      other.blur == blur &&
      other.haze == haze &&
      other.hazeBlur == hazeBlur &&
      other.refraction == refraction &&
      other.bevel == bevel &&
      other.saturation == saturation &&
      other.brightness == brightness &&
      other.rim == rim &&
      other.rimWidth == rimWidth &&
      other.rimTail == rimTail &&
      other.rimFocus == rimFocus &&
      other.rimAdded == rimAdded &&
      other.endShade == endShade &&
      other.dispersion == dispersion &&
      other.rimBlur == rimBlur &&
      other.hairline == hairline &&
      other.hairlineSide == hairlineSide;

  @override
  int get hashCode => Object.hash(
    tint,
    contrast,
    blur,
    haze,
    hazeBlur,
    refraction,
    bevel,
    saturation,
    brightness,
    rim,
    rimWidth,
    rimTail,
    rimFocus,
    rimAdded,
    endShade,
    dispersion,
    rimBlur,
    hairline,
    hairlineSide,
  );

  double get _hairlineSide => hairlineSide ?? hairline;

  /// The standard tier's: no colors parted, and a haze for the whole frost.
  LiquidGlassStyle get _standard {
    if (haze == 0 && dispersion == 0) {
      return this;
    }
    return LiquidGlassStyle(
      tint: tint,
      contrast: contrast,
      blur: haze > 0 ? hazeBlur : blur,
      refraction: refraction,
      bevel: bevel,
      saturation: saturation,
      brightness: brightness,
      rim: rim,
      rimWidth: rimWidth,
      rimTail: rimTail,
      rimFocus: rimFocus,
      rimAdded: rimAdded,
      endShade: endShade,
      rimBlur: rimBlur,
      hairline: hairline,
      hairlineSide: hairlineSide,
    );
  }
}

/// An iOS 27 menu's or alert's, measured over white.
List<BoxShadow> glassMenuShadows(ColorScheme colorScheme, [double depth = 1]) {
  final strength = colorScheme.brightness == Brightness.dark ? 1.5 : 1.0;
  final alpha = strength * depth;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.09 * alpha),
      blurRadius: 16.5,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.045 * alpha),
      blurRadius: 42,
      offset: const Offset(0, 8),
    ),
  ];
}

Color glassFillOf(ColorScheme colorScheme) =>
    (colorScheme.brightness == Brightness.dark ? Colors.white : Colors.black)
        .withValues(alpha: 0.13);

/// iOS 27's rim around a menu's or an alert's glass (.agents/architecture.md).
@immutable
class LiquidGlassRim {
  const LiquidGlassRim({
    required this.side,
    required this.corner,
    required this.flat,
    required this.shine,
  });

  factory LiquidGlassRim.alert(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? const LiquidGlassRim(side: 0.75, corner: 0.1, flat: 0.03, shine: 0.22)
      : const LiquidGlassRim(side: 0.35, corner: 0.22, flat: 0.12, shine: 0.16);

  factory LiquidGlassRim.menu(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? const LiquidGlassRim(side: 0.27, corner: 0.1, flat: 0.02, shine: 0.22)
      : const LiquidGlassRim(side: 0.25, corner: 0.15, flat: 0.09, shine: 0.16);

  final double side;
  final double corner;
  final double flat;

  /// Added light, not white laid over: iOS lifts dark and light panes alike.
  final double shine;

  LiquidGlassRim scale(double t) {
    final amount = t.clamp(0.0, 1.0);
    return LiquidGlassRim(
      side: side * amount,
      corner: corner * amount,
      flat: flat * amount,
      shine: shine * amount,
    );
  }

  /// The line, outside the pane; the pane given this rim draws the highlight.
  void paintLine(Canvas canvas, Rect rect, double radius) {
    if (rect.isEmpty) {
      return;
    }
    final round = _roundOf(rect.size, radius);
    final shape = AppRadius.all(round).toRSuperellipse(rect);
    final across = math.min(round / rect.width, 0.4);
    Color dark(double alpha) => Colors.black.withValues(alpha: alpha);
    canvas.drawRSuperellipse(
      shape.inflate(_hairlineWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _hairlineWidth
        ..shader = LinearGradient(
          colors: [
            dark(side),
            dark(corner),
            dark(flat),
            dark(flat),
            dark(corner),
            dark(side),
          ],
          stops: [0, across / 4, across, 1 - across, 1 - across / 4, 1],
        ).createShader(rect),
    );
  }

  static double _roundOf(Size size, double radius) =>
      math.min(math.max(0.0, radius), size.shortestSide / 2);

  List<double> _uniforms(Size size, double radius) {
    final turns = _turns(size, _roundOf(size, radius));
    final ends = [for (final band in _shineBands) band.depth + band.width];
    return [
      for (final (turn, _) in turns) turn,
      for (final (_, lit) in turns) shine * lit,
      for (var index = 0; index < _shineSlots; index++)
        ends[math.min(index, ends.length - 1)],
      for (var index = 0; index < _shineSlots; index++)
        index < _shineBands.length ? _shineBands[index].lit : 0.0,
    ];
  }

  void _paintShine(Canvas canvas, Rect rect, double radius) {
    final round = _roundOf(rect.size, radius);
    final shape = AppRadius.all(round).toRSuperellipse(rect);
    final around = _sweepStops(rect.size, round);
    final stops = [for (final (stop, _) in around) stop];
    for (final band in _shineBands) {
      final alpha = shine * band.lit;
      // A ring, not a stroke: Impeller widens a stroke thinner than a pixel.
      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRSuperellipse(shape.deflate(band.depth))
          ..addRSuperellipse(shape.deflate(band.depth + band.width)),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = SweepGradient(
            colors: [
              for (final (_, lit) in around)
                Colors.white.withValues(alpha: math.min(alpha * lit, 1)),
            ],
            stops: stops,
          ).createShader(rect),
      );
    }
  }

  static List<(double, double)> _turns(Size size, double round) {
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    final turns = [(0.0, 1.0)];
    for (final (:along, :down, :lit) in _shineAround) {
      final turn = math.atan2(
        halfWidth - math.min(along * round, halfWidth),
        halfHeight - math.min(down * round, halfHeight),
      );
      turns.add((math.max(turns.last.$1, turn), lit));
    }
    turns.add((math.pi / 2, 0));
    return turns;
  }

  static List<(double, double)> _sweepStops(Size size, double round) {
    final turns = _turns(size, round);
    const full = 2 * math.pi;
    return [
      for (final (turn, lit) in turns.reversed)
        ((math.pi / 2 - turn) / full, lit),
      for (final (turn, lit) in turns.skip(1))
        ((math.pi / 2 + turn) / full, lit),
      for (final (turn, lit) in turns.reversed.skip(1))
        ((math.pi * 1.5 - turn) / full, lit),
      for (final (turn, lit) in turns.skip(1))
        ((math.pi * 1.5 + turn) / full, lit),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassRim &&
      other.side == side &&
      other.corner == corner &&
      other.flat == flat &&
      other.shine == shine;

  @override
  int get hashCode => Object.hash(side, corner, flat, shine);
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
    if (glow case final glow?) {
      return _LiquidGlassPane(
        style: style,
        clipper: clipper,
        shadows: shadows,
        press: 0,
        fading: false,
        glow: glow,
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
        press: press,
        fading: !pressed,
        glow: null,
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
    required this.press,
    required this.fading,
    required this.glow,
    super.child,
  });

  final LiquidGlassStyle style;
  final CustomClipper<Path>? clipper;
  final List<BoxShadow> shadows;
  final double press;
  final bool fading;
  final LiquidGlassGlow? glow;

  @override
  _RenderLiquidGlass createRenderObject(BuildContext context) {
    return _RenderLiquidGlass(
      style: style,
      clipper: clipper,
      shadows: shadows,
      press: press,
      fading: fading,
      glow: glow,
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
      ..press = press
      ..fading = fading
      ..glow = glow;
  }
}

class _RenderLiquidGlass extends RenderProxyBox {
  _RenderLiquidGlass({
    required LiquidGlassStyle style,
    required CustomClipper<Path>? clipper,
    required List<BoxShadow> shadows,
    required double press,
    required bool fading,
    required LiquidGlassGlow? glow,
  }) : _style = style,
       _clipper = clipper,
       _shadows = shadows,
       _press = press,
       _fading = fading,
       _glow = glow;

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

  /// A pane moving within [hold] keeps one capture (.agents/architecture.md).
  void paint(
    PaintingContext context,
    Rect rect, {
    required LiquidGlassShape shape,
    required LiquidGlassStyle style,
    List<BoxShadow> shadows = const [],
    LiquidGlassGlow glow = LiquidGlassGlow.none,
    Rect? hold,
    LiquidGlassRim? rim,
  }) {
    final pane = _layer.layer ??= _LiquidGlassLayer();
    assert(rim == null || shape is LiquidGlassCorners);
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
        if (hold == null) {
          _paintShadows(context.canvas, rect, corners, shadows);
        }
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
      ..hold = hold
      ..rim = rim;
    context.addLayer(pane);
    if (hold != null) {
      _paintShadows(context.canvas, rect, pane.corners, shadows);
    }
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

  static Future<ui.FragmentProgram> _load() =>
      ui.FragmentProgram.fromAsset(_shaderAsset);
}

class _LiquidGlassLayer extends Layer {
  static int _skipped = 0;

  ui.FragmentProgram? program;
  Rect rect = Rect.zero;
  BorderRadius corners = BorderRadius.zero;
  Path? outline;
  List<double> profile = _flatProfile;
  LiquidGlassStyle style = const LiquidGlassStyle(tint: Colors.transparent);
  LiquidGlassGlow glow = LiquidGlassGlow.none;
  Rect? hold;
  LiquidGlassRim? rim;
  _Placement? _held;

  ui.Picture? _frost;
  (Rect, BorderRadius, Path?, LiquidGlassStyle, LiquidGlassRim?)? _frostKey;

  int _capturedPass = -1;
  ui.Picture? _captured;
  ui.FragmentShader? _captureShader;
  (ui.Image, Path?, BlendMode, ui.FragmentProgram?, List<double>)? _captureKey;

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void dispose() {
    _frost?.dispose();
    _dropCaptured();
    _captureShader?.dispose();
    super.dispose();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (_skipped > 0) {
      return;
    }
    if (_capturedPass == _LiquidGlassHostLayer._pass) {
      if (_captured case final picture?) {
        builder.addPicture(Offset.zero, picture);
      }
      return;
    }
    _dropCaptured();
    _addFrost(builder);
  }

  /// The uniforms from the pane's shape on, after where it and its texture
  /// lie.
  List<double> _look(LiquidGlassStyle style) => [
    rect.width,
    rect.height,
    style.bevel,
    style.blur,
    corners.topLeft.x,
    corners.topRight.x,
    corners.bottomRight.x,
    corners.bottomLeft.x,
    ...liquidGlassCornerCurves(rect.size, corners),
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
    style.rimBlur,
    style.rimTail,
    style.rimFocus,
    style.rimAdded,
    style._hairlineSide,
    outline == null ? 0.0 : 1.0,
    ...profile,
    ...rim?._uniforms(rect.size, corners.topLeft.x) ?? _noShine,
  ];

  void _addFrost(ui.SceneBuilder builder) {
    final key = (rect, corners, outline, style, rim);
    if (_frost == null || key != _frostKey) {
      _frost?.dispose();
      _frost = _paintFrost();
      _frostKey = key;
    }
    if (outline case final outline?) {
      builder.pushClipPath(outline);
    } else {
      builder.pushClipRSuperellipse(corners.toRSuperellipse(rect));
    }
    builder.addPicture(Offset.zero, _frost!);
    builder.pop();
  }

  /// Draws the pane from [atlas], where a host laid out what lies behind it,
  /// until the next pass of the host; [mapping] places the pane's slot.
  void _captureFrom(
    int pass,
    ui.Image atlas,
    List<double> mapping,
    BlendMode blendMode,
    LiquidGlassStyle style,
  ) {
    _capturedPass = pass;
    final program = this.program;
    final uniforms = <double>[
      atlas.width.toDouble(),
      atlas.height.toDouble(),
      -rect.left,
      -rect.top,
      1,
      1,
      ...mapping,
      ..._look(style),
    ];
    if (_captureKey
        case (final image, final path, final mode, final shaded, final values)?
        when _captured != null &&
            identical(image, atlas) &&
            identical(path, outline) &&
            mode == blendMode &&
            identical(shaded, program) &&
            listEquals(values, uniforms)) {
      return;
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (program == null) {
      _frostFrom(canvas, atlas, mapping, blendMode, style);
    } else {
      final shader = _captureShader ??= program.fragmentShader();
      shader.setImageSampler(0, atlas, filterQuality: FilterQuality.low);
      for (final (index, value) in uniforms.indexed) {
        shader.setFloat(index, value);
      }
      final paint = Paint()
        ..shader = shader
        ..blendMode = blendMode;
      if (outline case final outline?) {
        canvas.drawPath(outline, paint);
      } else {
        canvas.drawRSuperellipse(corners.toRSuperellipse(rect), paint);
      }
    }
    _captured?.dispose();
    _captured = recorder.endRecording();
    _captureKey = (atlas, outline, blendMode, program, uniforms);
  }

  /// Frosts the pane, without bending it, from the part of [atlas] behind it,
  /// which holds its blur already.
  void _frostFrom(
    Canvas canvas,
    ui.Image atlas,
    List<double> mapping,
    BlendMode blendMode,
    LiquidGlassStyle style,
  ) {
    canvas.save();
    if (outline case final outline?) {
      canvas.clipPath(outline);
    } else {
      canvas.clipRSuperellipse(corners.toRSuperellipse(rect));
    }
    final saturate = ColorFilter.matrix(
      _optics(style.saturation, style.brightness),
    );
    void drawSlot(int from, Paint paint) => canvas.drawImageRect(
      atlas,
      Rect.fromLTWH(
        -mapping[from] / mapping[from + 2],
        -mapping[from + 1] / mapping[from + 3],
        rect.width / mapping[from + 2],
        rect.height / mapping[from + 3],
      ),
      rect,
      paint
        ..filterQuality = FilterQuality.low
        ..colorFilter = saturate,
    );
    drawSlot(0, Paint()..blendMode = blendMode);
    final haze = mapping[_hazeShare];
    if (haze > 0) {
      drawSlot(_hazeSample, Paint()..color = Color.fromRGBO(0, 0, 0, haze));
    }
    _drawFrost(canvas, overCapture: true);
    canvas.restore();
  }

  /// Draws nothing until the next pass of the host, as nothing of the pane
  /// shows.
  void _captureNothing(int pass) {
    _capturedPass = pass;
    _dropCaptured();
  }

  void _dropCaptured() {
    _captured?.dispose();
    _captured = null;
    _captureKey = null;
  }

  ui.Picture _paintFrost() {
    final recorder = ui.PictureRecorder();
    _drawFrost(Canvas(recorder));
    return recorder.endRecording();
  }

  /// Thickens the tint to stand in for the frost, unless the pane lies
  /// [overCapture], which holds the blur.
  void _drawFrost(Canvas canvas, {bool overCapture = false}) {
    final tint = style.tint;
    final fill = Paint()
      ..color = overCapture
          ? tint
          : tint.withValues(alpha: math.min(1, tint.a + 0.2));
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
      ..color = Colors.black.withValues(
        alpha: (style.hairline + style._hairlineSide) / 2 * 0.3,
      );
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
      this.rim?._paintShine(canvas, rect, corners.topLeft.x);
    }
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

@visibleForTesting
List<double> liquidGlassCornerCurves(Size size, BorderRadius corners) => [
  for (final radius in [
    corners.topLeft.x,
    corners.topRight.x,
    corners.bottomRight.x,
    corners.bottomLeft.x,
  ])
    ..._cornerCurve(size.width / 2, size.height / 2, radius),
];

List<double> _cornerCurve(double halfWidth, double halfHeight, double radius) {
  final along = _superellipseOctant(halfWidth, radius);
  final across = _superellipseOctant(halfHeight, radius);
  return [
    along.n,
    along.joint.dx,
    along.joint.dy,
    along.radius,
    across.n,
    across.joint.dx,
    across.joint.dy,
    across.radius,
    along.center.dx,
    along.center.dy,
    across.center.dx,
    across.center.dy,
  ];
}

typedef _Octant = ({double n, Offset joint, Offset center, double radius});

/// ComputeOctant in impeller/geometry/round_superellipse_param.cc, which the
/// shader's cornerInset follows.
_Octant _superellipseOctant(double a, double radius) {
  if (radius <= 1e-3) {
    return (n: 0, joint: Offset.zero, center: Offset.zero, radius: 0);
  }
  final (n, jointAt) = _octantFit(a * 2 / radius);
  final joint = Offset(
    jointAt * a,
    math.pow(1 - math.pow(jointAt, n), 1 / n) * a,
  );
  final tangent = math.pow(joint.dx / joint.dy, n - 1);
  final diagonal = (joint.dx - tangent * joint.dy) / (1 - tangent);
  final meet = a - _octantGap * radius;
  final arc = (meet - diagonal) * math.sqrt2;
  final chord = Offset(meet, meet) - joint;
  final reach = math.sqrt(math.max(0, arc * arc - chord.distanceSquared / 4));
  final center =
      (joint + Offset(meet, meet)) / 2 +
      Offset(chord.dy, -chord.dx) / chord.distance * reach;
  return (n: n, joint: joint, center: center, radius: arc);
}

const _octantGap = 1 - math.sqrt1_2;

/// By the ratio of an octant's side to its radius: n, and 1 / (1 - xJ / a).
const _octantFits = [
  (2.0, 2.00000000, 1.13276676),
  (2.1, 2.18349805, 1.20311921),
  (2.2, 2.33888662, 1.28698796),
  (2.3, 2.48660575, 1.36351941),
  (2.4, 2.62226596, 1.44717976),
  (2.5, 2.75148990, 1.53385819),
  (3.0, 3.36298265, 1.98288283),
  (3.5, 4.08649929, 2.23811846),
  (4.0, 4.85481134, 2.47563463),
  (4.5, 5.62945551, 2.72948597),
  (5.0, 6.43023796, 2.98020421),
];

(double, double) _octantFit(double ratio) {
  final (lastRatio, lastN, lastK) = _octantFits.last;
  final past = ratio - lastRatio;
  if (past > 0) {
    return (lastN + 1.559599389 * past, 1 - 1 / (lastK + 0.522807185 * past));
  }
  var index = 0;
  while (index < _octantFits.length - 2 && ratio > _octantFits[index + 1].$1) {
    index++;
  }
  final (r0, n0, k0) = _octantFits[index];
  final (r1, n1, k1) = _octantFits[index + 1];
  final t = math.max(0.0, (ratio - r0) / (r1 - r0));
  return (ui.lerpDouble(n0, n1, t)!, 1 - 1 / ui.lerpDouble(k0, k1, t)!);
}

List<double> _optics(double saturation, double brightness) {
  final red = 0.2126 * brightness;
  final green = 0.7152 * brightness;
  final blue = 0.0722 * brightness;
  final rest = 1 - saturation;
  final kept = saturation * brightness;
  return [
    red * rest + kept, green * rest, blue * rest, 0, 0, //
    red * rest, green * rest + kept, blue * rest, 0, 0,
    red * rest, green * rest, blue * rest + kept, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
