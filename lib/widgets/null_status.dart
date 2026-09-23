import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

enum NullStatusIllustration {
  data,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  dns,
  ntp,
  wifi,
  apps,
  history,
  permission,
  camera,
  error,
  search,
}

class NullStatusSwitcher extends StatefulWidget {
  /// Only the first load is held back; later loads keep what is on screen.
  final bool isLoading;
  final bool isEmpty;
  final bool isSearching;
  final NullStatus nullStatus;
  final Widget child;

  const NullStatusSwitcher({
    super.key,
    this.isLoading = false,
    required this.isEmpty,
    this.isSearching = false,
    required this.nullStatus,
    required this.child,
  });

  @override
  State<NullStatusSwitcher> createState() => _NullStatusSwitcherState();
}

class _NullStatusSwitcherState extends State<NullStatusSwitcher> {
  static const _exitDuration = Duration(milliseconds: 150);

  late bool _loaded = !widget.isLoading;

  @override
  void didUpdateWidget(covariant NullStatusSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loaded = _loaded || !widget.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox.expand();
    }
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      reverseDuration: context.motionDuration(_exitDuration),
      switchInCurve: Easing.emphasizedDecelerate,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Align(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
          child: child,
        ),
      ),
      child: switch ((widget.isEmpty, widget.isSearching)) {
        (true, true) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.noResults),
          child: NullStatus(
            label: context.appLocalizations.noSearchResults,
            illustration: NullStatusIllustration.search,
          ),
        ),
        (true, false) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.empty),
          child: widget.nullStatus,
        ),
        (false, _) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.content),
          child: widget.child,
        ),
      },
    );
  }
}

enum _NullStatusSlot { empty, noResults, content }

class NullStatus extends StatelessWidget {
  final String label;
  final String? description;
  final Widget? action;
  final NullStatusIllustration illustration;

  const NullStatus({
    super.key,
    required this.label,
    this.description,
    this.action,
    this.illustration = NullStatusIllustration.data,
  });

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final action = this.action;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final compact = MediaQuery.sizeOf(context).height < _compactHeight;
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EnterItem(
                child: _EmptyIllustration(
                  type: illustration,
                  dimension: compact ? 120 : 160,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              _EnterItem(
                delay: _staggerStep,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                _EnterItem(
                  delay: _staggerStep * 2,
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 24),
                _EnterItem(
                  delay: _staggerStep * (description != null ? 3 : 2),
                  child: action,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _compactHeight = 560.0;
const _staggerStep = Duration(milliseconds: 60);
const _enterRise = 12.0;

bool _skipsEntrance(BuildContext context) {
  final route = ModalRoute.of(context);
  final routeEntering =
      route != null &&
      (route.offstage || (route.animation?.isAnimating ?? false));
  return context.disableAnimations || routeEntering;
}

class _EnterItem extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _EnterItem({this.delay = Duration.zero, required this.child});

  @override
  State<_EnterItem> createState() => _EnterItemState();
}

class _EnterItemState extends State<_EnterItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _skipped;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration + widget.delay,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_skipped != null) {
      return;
    }
    _skipped = _skipsEntrance(context);
    if (!_skipped!) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skipped = _skipped;
    if (skipped == null || skipped) {
      return widget.child;
    }
    final total = commonDuration + widget.delay;
    final start = widget.delay.inMicroseconds / total.inMicroseconds;
    final animation = start == 0
        ? _controller.view
        : _controller.drive(CurveTween(curve: Interval(start, 1)));
    return FadeSlideEnterTransition(
      animation: animation,
      distance: _enterRise,
      axis: Axis.vertical,
      child: widget.child,
    );
  }
}

class _EmptyIllustration extends StatefulWidget {
  final NullStatusIllustration type;
  final double dimension;

  const _EmptyIllustration({required this.type, required this.dimension});

  @override
  State<_EmptyIllustration> createState() => _EmptyIllustrationState();
}

class _EmptyIllustrationState extends State<_EmptyIllustration>
    with SingleTickerProviderStateMixin {
  static final _random = math.Random();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );
  final _entrance = _Entrance.values[_random.nextInt(_Entrance.values.length)];
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (!_skipsEntrance(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final colorScheme = context.colorScheme;
    final (shape, glyph) = _artOf(type);
    return RepaintBoundary(
      child: CustomPaint(
        key: ValueKey(type),
        painter: _IllustrationPainter(
          shape: shape,
          glyph: glyph,
          palette: type == NullStatusIllustration.error
              ? _IllustrationPalette.error(colorScheme)
              : _IllustrationPalette(colorScheme),
          entrance: _entrance,
          progress: _controller,
        ),
        child: SizedBox.square(dimension: widget.dimension),
      ),
    );
  }

  static (RoundedPolygon, Glyph) _artOf(
    NullStatusIllustration type,
  ) => switch (type) {
    NullStatusIllustration.data => (
      MaterialShapes.cookie12Sided,
      AppGlyphs.resources,
    ),
    NullStatusIllustration.logs => (
      MaterialShapes.cookie9Sided,
      AppGlyphs.logs,
    ),
    NullStatusIllustration.proxies => (MaterialShapes.sunny, AppGlyphs.proxies),
    NullStatusIllustration.profile => (
      MaterialShapes.cookie7Sided,
      AppGlyphs.profiles,
    ),
    NullStatusIllustration.scripts => (
      MaterialShapes.cookie6Sided,
      AppGlyphs.code,
    ),
    NullStatusIllustration.rules => (
      MaterialShapes.clover8Leaf,
      AppGlyphs.rules,
    ),
    NullStatusIllustration.connections => (
      MaterialShapes.cookie4Sided,
      AppGlyphs.connections,
    ),
    NullStatusIllustration.requests => (
      MaterialShapes.softBurst,
      AppGlyphs.requests,
    ),
    NullStatusIllustration.dns => (MaterialShapes.puffy, AppGlyphs.dns),
    NullStatusIllustration.ntp => (MaterialShapes.pentagon, AppGlyphs.clock),
    NullStatusIllustration.wifi => (
      MaterialShapes.cookie7Sided,
      AppGlyphs.wifi,
    ),
    NullStatusIllustration.apps => (
      MaterialShapes.clover4Leaf,
      AppGlyphs.appsList,
    ),
    NullStatusIllustration.history => (
      MaterialShapes.cookie12Sided,
      AppGlyphs.history,
    ),
    NullStatusIllustration.permission => (MaterialShapes.sunny, AppGlyphs.lock),
    NullStatusIllustration.camera => (
      MaterialShapes.cookie6Sided,
      AppGlyphs.camera,
    ),
    NullStatusIllustration.error => (MaterialShapes.softBurst, AppGlyphs.error),
    NullStatusIllustration.search => (MaterialShapes.flower, AppGlyphs.search),
  };
}

class _IllustrationPalette {
  final Color shape;
  final Color ink;
  final Color highlight;
  final Color accent;
  final Color accentContainer;
  final bool sparkles;

  _IllustrationPalette(ColorScheme colorScheme)
    : shape = colorScheme.primaryContainer,
      ink = colorScheme.onPrimaryContainer,
      highlight = colorScheme.primary,
      accent = colorScheme.tertiary,
      accentContainer = colorScheme.tertiaryContainer,
      sparkles = true;

  _IllustrationPalette.error(ColorScheme colorScheme)
    : shape = colorScheme.errorContainer,
      ink = colorScheme.onErrorContainer,
      highlight = colorScheme.error,
      accent = colorScheme.error,
      accentContainer = colorScheme.errorContainer,
      sparkles = false;

  @override
  bool operator ==(Object other) =>
      other is _IllustrationPalette &&
      other.shape == shape &&
      other.ink == ink &&
      other.highlight == highlight &&
      other.accent == accent &&
      other.accentContainer == accentContainer &&
      other.sparkles == sparkles;

  @override
  int get hashCode =>
      Object.hash(shape, ink, highlight, accent, accentContainer, sparkles);
}

/// Every choreography must land on the same final frame, since a skipped
/// entrance paints that frame directly.
enum _Entrance { spin, morph, orbit }

enum _Accent { sparkle, blob, dot, ring }

typedef _ShapePose = ({double scale, double turn, double morph, double alpha});
typedef _GlyphPose = ({double scale, double rise, double fill, double alpha});
typedef _AccentPose = ({double scale, double drift, double orbit, double turn});

class _IllustrationPainter extends CustomPainter {
  static const _shapeExtent = 0.72;
  static const _haloExtent = 0.84;
  static const _glyphExtent = 0.4;
  static const _accents = [
    (_Accent.sparkle, Offset(0.3, -0.31), 0.22),
    (_Accent.blob, Offset(-0.32, 0.3), 0.14),
    (_Accent.dot, Offset(-0.4, -0.18), 0.05),
    (_Accent.ring, Offset(0.42, 0.15), 0.075),
  ];
  static final _paths = Expando<Path>();
  static final _morphs = Expando<Morph>();

  final RoundedPolygon shape;
  final Glyph glyph;
  final _IllustrationPalette palette;
  final _Entrance entrance;
  final Animation<double> progress;

  _IllustrationPainter({
    required this.shape,
    required this.glyph,
    required this.palette,
    required this.entrance,
    required this.progress,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final side = size.shortestSide;
    final center = size.center(Offset.zero);
    final (halo, body, mark) = _poseAt(t);

    _paintShape(
      canvas,
      halo,
      center,
      side * _haloExtent,
      palette.highlight.withValues(
        alpha: palette.highlight.a * 0.14 * halo.alpha,
      ),
    );
    _paintShape(canvas, body, center, side * _shapeExtent, palette.shape);
    if (mark.scale > 0) {
      _paintGlyph(
        canvas,
        glyph,
        center + Offset(0, side * mark.rise),
        side * _glyphExtent * mark.scale,
        mark.fill,
        palette.ink.withValues(alpha: palette.ink.a * mark.alpha),
      );
    }

    for (final (index, (accent, offset, extent)) in _accents.indexed) {
      if (accent == _Accent.sparkle && !palette.sparkles) {
        continue;
      }
      final pose = _accentAt(t, index);
      if (pose.scale <= 0) {
        continue;
      }
      final at =
          center +
          Offset.fromDirection(offset.direction + pose.orbit, offset.distance) *
              side *
              pose.drift;
      final diameter = side * extent * pose.scale;
      switch (accent) {
        case _Accent.sparkle:
          _paintGlyph(
            canvas,
            AppGlyphs.sparkle,
            at,
            diameter,
            1,
            palette.accent,
            turn: pose.turn,
          );
        case _Accent.blob:
          _paintPath(
            canvas,
            _paths[MaterialShapes.cookie4Sided] ??= MaterialShapes.cookie4Sided
                .toPath(),
            at,
            diameter,
            math.pi / 12 + pose.turn,
            palette.accentContainer,
          );
        case _Accent.dot:
          canvas.drawCircle(at, diameter / 2, Paint()..color = palette.accent);
        case _Accent.ring:
          final width = diameter * 0.28;
          canvas.drawCircle(
            at,
            (diameter - width) / 2,
            Paint()
              ..color = palette.highlight
              ..style = PaintingStyle.stroke
              ..strokeWidth = width,
          );
      }
    }
  }

  (_ShapePose, _ShapePose, _GlyphPose) _poseAt(double t) {
    switch (entrance) {
      case _Entrance.spin:
        _ShapePose spun(double settle) => (
          scale: lerpDouble(0.6, 1, settle)!,
          turn: -math.pi / 3 * (1 - settle),
          morph: 1,
          alpha: 1,
        );
        return (
          spun(_phase(t, 0.08, 0.75, Curves.easeOutBack)),
          spun(_phase(t, 0, 0.65, Curves.easeOutBack)),
          (
            scale:
                lerpDouble(0.5, 1, _phase(t, 0.1, 0.55, Curves.easeOutBack))! +
                math.sin(math.pi * _phase(t, 0.55, 0.85)) * 0.08,
            rise: 0,
            fill: _phase(t, 0.2, 0.6, Curves.easeInOutCubic),
            alpha: _phase(t, 0.1, 0.3),
          ),
        );
      case _Entrance.morph:
        _ShapePose morphed(double begin, double end) {
          final morph = _phase(t, begin, end, Curves.easeInOutCubic);
          return (
            scale: lerpDouble(
              0.5,
              1,
              _phase(t, begin, begin + 0.5, Curves.easeOutBack),
            )!,
            turn: math.pi / 2 * (1 - morph),
            morph: morph,
            alpha: 1,
          );
        }
        final rise = _phase(t, 0.2, 0.6, Curves.easeOutBack);
        return (
          morphed(0.15, 0.8),
          morphed(0.05, 0.65),
          (
            scale: lerpDouble(0.8, 1, rise)!,
            rise: 0.14 * (1 - rise),
            fill: _phase(t, 0.3, 0.7, Curves.easeInOutCubic),
            alpha: _phase(t, 0.2, 0.35),
          ),
        );
      case _Entrance.orbit:
        final ripple = _phase(t, 0.2, 0.75, Curves.easeOutCubic);
        return (
          (
            scale: lerpDouble(_shapeExtent / _haloExtent, 1, ripple)!,
            turn: 0,
            morph: 1,
            alpha: ripple,
          ),
          (
            scale: lerpDouble(
              0.3,
              1,
              _phase(t, 0, 0.6, const ElasticOutCurve(0.6)),
            )!,
            turn: 0,
            morph: 1,
            alpha: 1,
          ),
          (
            scale: _phase(t, 0.15, 0.7, const ElasticOutCurve(0.5)),
            rise: 0,
            fill: _phase(t, 0.3, 0.7, Curves.easeInOutCubic),
            alpha: _phase(t, 0.15, 0.25),
          ),
        );
    }
  }

  _AccentPose _accentAt(double t, int index) {
    switch (entrance) {
      case _Entrance.spin:
        final begin = 0.4 + index * 0.08;
        final enter = _phase(t, begin, begin + 0.35, Curves.easeOutBack);
        return (
          scale: enter,
          drift: lerpDouble(0.7, 1, enter)!,
          orbit: 0,
          turn: -math.pi / 4 * (1 - enter),
        );
      case _Entrance.morph:
        final begin = 0.45 + (_accents.length - 1 - index) * 0.07;
        final enter = _phase(t, begin, begin + 0.3, Curves.easeOutBack);
        return (
          scale: enter,
          drift: 1,
          orbit: 0,
          turn: -math.pi / 2 * (1 - enter),
        );
      case _Entrance.orbit:
        final begin = 0.3 + index * 0.1;
        final travel = _phase(t, begin, begin + 0.4, Curves.easeOutCubic);
        return (
          scale: _phase(t, begin, begin + 0.3, Curves.easeOutBack),
          drift: lerpDouble(0.55, 1, travel)!,
          orbit: -math.pi * 0.7 * (1 - travel),
          turn: -math.pi / 2 * (1 - travel),
        );
    }
  }

  static double _phase(
    double t,
    double begin,
    double end, [
    Curve curve = Curves.linear,
  ]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

  void _paintShape(
    Canvas canvas,
    _ShapePose pose,
    Offset center,
    double extent,
    Color color,
  ) {
    final path = pose.morph >= 1
        ? _paths[shape] ??= shape.toPath()
        : (_morphs[shape] ??= Morph(
            MaterialShapes.circle,
            shape,
          )).toPath(progress: pose.morph);
    _paintPath(canvas, path, center, extent * pose.scale, pose.turn, color);
  }

  void _paintPath(
    Canvas canvas,
    Path path,
    Offset center,
    double extent,
    double rotation,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(extent);
    canvas.translate(-0.5, -0.5);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _paintGlyph(
    Canvas canvas,
    Glyph glyph,
    Offset center,
    double extent,
    double fill,
    Color color, {
    double turn = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turn);
    canvas.translate(-extent / 2, -extent / 2);
    GlyphPainter(
      glyph: glyph,
      fill: fill,
      color: color,
    ).paint(canvas, Size.square(extent));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.glyph != glyph ||
      oldDelegate.palette != palette ||
      oldDelegate.entrance != entrance ||
      oldDelegate.progress != progress;
}
