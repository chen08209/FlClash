import 'dart:async' show Timer, scheduleMicrotask, unawaited;
import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/motion.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:flutter/foundation.dart' show ValueListenable, listEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart' show SpringSimulation;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';

import 'liquid_glass.dart';
import 'navigation_dock.dart' show ElasticPress, ElasticPressHandle;
import 'text.dart';

typedef PopupAnchorResolver = Rect? Function();

typedef PopupOpen = void Function();

enum PopupPlacement { overAnchorEnd, overAnchorStart, belowPoint }

const _screenMargin = 16.0;

const _anchorOverlap = 8.0;

const _avoidGap = 8.0;

const _cardInset = 8.0;

const _itemRadius = AppCorner.md;

const _cardRadius = _itemRadius + _cardInset;

const _itemIconSize = 20.0;
const _submenuArrowSize = 16.0;

const _itemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

const _itemArrowPadding = EdgeInsets.only(
  left: 12,
  top: 12,
  bottom: 12,
  right: 8,
);

const _dividerHeight = _cardInset * 2 + 1;

// Soft and wide like HyperOS menus rather than a Material elevation.
List<BoxShadow> _cardShadows(ColorScheme colorScheme, [double depth = 1]) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  final alpha = strength * depth;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.05 * alpha),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * alpha),
      blurRadius: 30,
      offset: const Offset(0, 4),
    ),
  ];
}

const _maxContentBlur = 8.0;

const _overshootPerLongestSide = 0.1;

const _openDuration = Duration(milliseconds: 750);

const _dismissDuration = Duration(milliseconds: 300);

const _shrinkDuration = Duration(milliseconds: 200);

/// How far a popup with no control to return into shrinks toward its anchor
/// as it fades, as an iOS context menu does.
const _dismissScale = 0.8;

double _secondsOf(Duration duration) =>
    duration.inMicroseconds / Duration.microsecondsPerSecond;

final _openSeconds = _secondsOf(_openDuration);

final _dismissSeconds = _secondsOf(_dismissDuration);

const _contentOut = Interval(0, 0.5, curve: Curves.easeOut);

final _returnSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 260),
  ),
  seconds: _dismissSeconds,
);

final _returnXSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 220),
  ),
  seconds: _dismissSeconds,
);

final _returnYSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 290),
  ),
  seconds: _dismissSeconds,
);

final _growSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 500),
    bounce: 0.3,
  ),
  seconds: _openSeconds,
);

final _moveYSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 340),
    bounce: 0.12,
  ),
  seconds: _openSeconds,
);

final _moveXSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 520),
    bounce: 0.2,
  ),
  seconds: _openSeconds,
);

const _dwellDuration = Duration(milliseconds: 400);

final _unfoldSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 420),
  bounce: 0.15,
);

final _foldSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 340),
);

class CommonPopupRoute<T> extends PopupRoute<T> {
  CommonPopupRoute({
    required this.builder,
    required this.anchorOf,
    required this.barrierLabel,
    this.placement = PopupPlacement.overAnchorEnd,
    this.elevated = false,
    this.sourceColor = Colors.transparent,
    this.sourceImage,
    this.modal = true,
    this.avoid,
  }) : super(requestFocus: modal ? null : false);

  final WidgetBuilder builder;

  /// Resolves the rect of the control the popup grows out of.
  final PopupAnchorResolver anchorOf;
  final PopupPlacement placement;

  /// Whether the popup opens from a sheet's [ElevatedSurfaceTheme], which
  /// lies below the navigator the popup is pushed on.
  final bool elevated;

  /// The background of the source control, which the platter starts from.
  final Color sourceColor;

  /// A snapshot of the source control, drawn inside the platter while the
  /// control itself is hidden; null while it is still being taken.
  final ValueListenable<ui.Image?>? sourceImage;

  /// Off, focus stays on the page and touches outside pass through to it.
  final bool modal;

  /// A rect the popup keeps clear of when there is room above or below it.
  final Rect? avoid;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => _openDuration;

  @override
  Duration get reverseTransitionDuration =>
      sourceImage == null ? _shrinkDuration : _dismissDuration;

  late final CurvedAnimation _grow = CurvedAnimation(
    parent: animation!,
    curve: _growSpring,
  );

  late final CurvedAnimation _moveX = CurvedAnimation(
    parent: animation!,
    curve: _moveXSpring,
  );

  late final CurvedAnimation _moveY = CurvedAnimation(
    parent: animation!,
    curve: _moveYSpring,
  );

  late final CurvedAnimation _content = CurvedAnimation(
    parent: animation!,
    curve: const Interval(0.04, 0.45, curve: Curves.easeOutCubic),
  );

  final _unfolded = ValueNotifier<bool>(false);

  /// Whether the platter shows rather than the cards, which on glass stand
  /// bare meanwhile so that one pane, the platter's, bends what lies behind.
  final _platter = ValueNotifier<bool>(true);

  final _pin = _PopupPin();

  final _press = _CarriedPress();

  @override
  void install() {
    super.install();
    animation!
      ..addListener(_updatePlatter)
      ..addStatusListener(_handleStatusChanged);
    _unfolded.addListener(_updatePlatter);
  }

  void _handleStatusChanged(AnimationStatus status) => _updatePlatter();

  void _updatePlatter() {
    final animation = this.animation!;
    // A popup with a control to return into does so on the platter; one
    // without dissolves as it stood when it began to close.
    if (animation.status == AnimationStatus.reverse) {
      if (sourceImage != null) {
        _platter.value = true;
      }
      return;
    }
    _platter.value =
        !animation.isCompleted && _content.value < 1 && !_unfolded.value;
  }

  @override
  void dispose() {
    animation
      ?..removeListener(_updatePlatter)
      ..removeStatusListener(_handleStatusChanged);
    _grow.dispose();
    _moveX.dispose();
    _moveY.dispose();
    _content.dispose();
    _unfolded.dispose();
    _platter.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (isCurrent) {
      navigator?.pop();
    }
  }

  /// A popup that returns into its control runs a picked item once landed,
  /// so nothing the item rebuilds changes under the returning platter.
  void _runPicked(VoidCallback action) {
    if (sourceImage == null) {
      action();
      return;
    }
    unawaited(completed.whenComplete(action));
  }

  @override
  Widget buildModalBarrier() {
    return modal ? super.buildModalBarrier() : const SizedBox.shrink();
  }

  Widget _buildDismissLayer() {
    if (modal) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _handleDismiss,
      );
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleDismiss(),
      onPointerPanZoomStart: (_) => _handleDismiss(),
      onPointerSignal: (_) => _handleDismiss(),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SurfaceScope(
      level: SurfaceLevel.floatingOf(context.colorScheme),
      child: _PopupScope(
        platter: _platter,
        press: _press,
        runPicked: _runPicked,
        child: builder(context),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (elevated) {
      return ElevatedSurfaceTheme(
        child: Builder(
          builder: (context) => _buildPopup(context, animation, child),
        ),
      );
    }
    return _buildPopup(context, animation, child);
  }

  Widget _buildPopup(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final colorScheme = context.colorScheme;
    final glass = LiquidGlassScope.of(context);
    return Stack(
      children: [
        Positioned.fill(child: _buildDismissLayer()),
        _PopupAnchorTracker(
          anchorOf: anchorOf,
          builder: (anchor, safeInsets, child) => CustomSingleChildLayout(
            delegate: _PopupLayoutDelegate(
              anchor: anchor,
              safeInsets: safeInsets,
              placement: placement,
              avoid: avoid,
              pin: _pin,
            ),
            child: _PopupMorph(
              anchor: anchor,
              animation: animation,
              grow: _grow,
              moveX: _moveX,
              moveY: _moveY,
              content: _content,
              platter: _platter,
              sourceColor: sourceColor,
              sourceImage: sourceImage,
              surfaceColor: SurfaceLevel.floatingOf(
                colorScheme,
              ).colorOf(colorScheme),
              shadows: glass
                  ? glassMenuShadows(colorScheme)
                  : _cardShadows(colorScheme),
              glass: glass
                  ? (
                      from: LiquidGlassStyle.regular(colorScheme),
                      to: LiquidGlassStyle.menu(colorScheme),
                      rim: LiquidGlassRim.menu(colorScheme),
                    )
                  : null,
              child: child,
            ),
          ),
          child: NotificationListener<_PopupUnfoldNotification>(
            onNotification: (_) {
              _unfolded.value = true;
              return true;
            },
            child: child,
          ),
        ),
      ],
    );
  }
}

class _PopupUnfoldNotification extends Notification {
  const _PopupUnfoldNotification();
}

typedef _PlatterGlass = ({
  LiquidGlassStyle from,
  LiquidGlassStyle to,
  LiquidGlassRim rim,
});

/// The press that opened a popup on its control's pointer down. Its events
/// keep reaching the control, which hands them on for the menu to follow.
class _CarriedPress {
  ValueSetter<Offset>? onMove;
  ValueSetter<Offset>? onRelease;
  VoidCallback? onCancel;
}

class _PopupScope extends InheritedWidget {
  const _PopupScope({
    required this.platter,
    required this.press,
    required this.runPicked,
    required super.child,
  });

  final ValueListenable<bool> platter;
  final _CarriedPress press;
  final ValueSetter<VoidCallback> runPicked;

  static _PopupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PopupScope>();

  @override
  bool updateShouldNotify(_PopupScope oldWidget) =>
      platter != oldWidget.platter ||
      press != oldWidget.press ||
      runPicked != oldWidget.runPicked;
}

class _PopupMorph extends SingleChildRenderObjectWidget {
  const _PopupMorph({
    required this.anchor,
    required this.animation,
    required this.grow,
    required this.moveX,
    required this.moveY,
    required this.content,
    required this.platter,
    required this.sourceColor,
    required this.sourceImage,
    required this.surfaceColor,
    required this.shadows,
    required this.glass,
    super.child,
  });

  final Rect anchor;
  final Animation<double> animation;
  final Animation<double> grow;
  final Animation<double> moveX;
  final Animation<double> moveY;
  final Animation<double> content;
  final ValueListenable<bool> platter;
  final Color sourceColor;
  final ValueListenable<ui.Image?>? sourceImage;
  final Color surfaceColor;
  final List<BoxShadow> shadows;

  /// The platter's glass as it leaves the anchor and as it lands on the card,
  /// or null for a [surfaceColor] fill.
  final _PlatterGlass? glass;

  @override
  _RenderPopupMorph createRenderObject(BuildContext context) {
    return _RenderPopupMorph(
      anchor: anchor,
      animation: animation,
      grow: grow,
      moveX: moveX,
      moveY: moveY,
      content: content,
      platter: platter,
      sourceColor: sourceColor,
      sourceImage: sourceImage,
      surfaceColor: surfaceColor,
      shadows: shadows,
      glass: glass,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPopupMorph renderObject,
  ) {
    renderObject
      ..anchor = anchor
      ..animation = animation
      ..grow = grow
      ..moveX = moveX
      ..moveY = moveY
      ..content = content
      ..platter = platter
      ..sourceColor = sourceColor
      ..sourceImage = sourceImage
      ..surfaceColor = surfaceColor
      ..shadows = shadows
      ..glass = glass;
  }
}

typedef _MorphFrame = ({
  double grow,
  double moveX,
  double moveY,
  double reveal,
  bool platter,
});

/// Grows the popup out of its anchor the way iOS 26 menus leave their button:
/// a platter flies from the anchor's capsule to the card's center on an arc,
/// growing on its own spring, while the content rides inside it, scaling,
/// fading and sharpening in. Closing returns it into its control the same way,
/// the content blurring out first; with no control to return into, the popup
/// shrinks toward its anchor as it fades.
class _RenderPopupMorph extends RenderProxyBox {
  _RenderPopupMorph({
    required Rect anchor,
    required Animation<double> animation,
    required this.grow,
    required this.moveX,
    required this.moveY,
    required this.content,
    required ValueListenable<bool> platter,
    required Color sourceColor,
    required ValueListenable<ui.Image?>? sourceImage,
    required Color surfaceColor,
    required List<BoxShadow> shadows,
    required _PlatterGlass? glass,
  }) : _anchor = anchor,
       _animation = animation,
       _platter = platter,
       _sourceColor = sourceColor,
       _sourceImage = sourceImage,
       _surfaceColor = surfaceColor,
       _shadows = shadows,
       _glass = glass;

  late final _pane = LiquidGlassPane(markNeedsPaint);

  Animation<double> grow;
  Animation<double> moveX;
  Animation<double> moveY;
  Animation<double> content;

  Rect _anchor;

  set anchor(Rect value) {
    if (value == _anchor) {
      return;
    }
    _anchor = value;
    markNeedsPaint();
  }

  Animation<double> _animation;

  set animation(Animation<double> value) {
    if (value == _animation) {
      return;
    }
    if (attached) {
      _animation
        ..removeListener(markNeedsPaint)
        ..removeStatusListener(_handleStatusChanged);
      value
        ..addListener(markNeedsPaint)
        ..addStatusListener(_handleStatusChanged);
    }
    _animation = value;
    markNeedsPaint();
  }

  _MorphFrame? _closingFrame;
  double _closingFrom = 1;

  void _handleStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.reverse) {
      return;
    }
    _closingFrom = _animation.value;
    _closingFrame = _frame();
  }

  /// Where the opening stands, or null once it has settled.
  _MorphFrame? _frame() {
    if (_animation.value >= 1) {
      return null;
    }
    return (
      grow: grow.value,
      moveX: moveX.value,
      moveY: moveY.value,
      reveal: content.value,
      platter: _platter.value,
    );
  }

  ValueListenable<bool> _platter;

  set platter(ValueListenable<bool> value) {
    if (value == _platter) {
      return;
    }
    if (attached) {
      _platter.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _platter = value;
    markNeedsPaint();
  }

  Color _sourceColor;

  set sourceColor(Color value) {
    if (value == _sourceColor) {
      return;
    }
    _sourceColor = value;
    markNeedsPaint();
  }

  ValueListenable<ui.Image?>? _sourceImage;

  set sourceImage(ValueListenable<ui.Image?>? value) {
    if (value == _sourceImage) {
      return;
    }
    if (attached) {
      _sourceImage?.removeListener(markNeedsPaint);
      value?.addListener(markNeedsPaint);
    }
    _sourceImage = value;
    markNeedsPaint();
  }

  Color _surfaceColor;

  set surfaceColor(Color value) {
    if (value == _surfaceColor) {
      return;
    }
    _surfaceColor = value;
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

  _PlatterGlass? _glass;

  set glass(_PlatterGlass? value) {
    if (value == _glass) {
      return;
    }
    _glass = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation
      ..addListener(markNeedsPaint)
      ..addStatusListener(_handleStatusChanged);
    _platter.addListener(markNeedsPaint);
    _sourceImage?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation
      ..removeListener(markNeedsPaint)
      ..removeStatusListener(_handleStatusChanged);
    _platter.removeListener(markNeedsPaint);
    _sourceImage?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _pane.dispose();
    super.dispose();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  /// The anchor in this box's coordinates; it comes in those of the layout
  /// box that places this one.
  Rect get _localAnchor =>
      _anchor.shift(-(parentData! as BoxParentData).offset);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    if (_animation.status != AnimationStatus.reverse) {
      _paintFrame(context, offset, _frame());
      return;
    }
    final frame = _closingFrame;
    final from = _closingFrom;
    final dismissal = from <= 0
        ? 1.0
        : (1 - _animation.value / from).clamp(0.0, 1.0);
    if (_sourceImage != null) {
      final start =
          frame ??
          (grow: 1.0, moveX: 1.0, moveY: 1.0, reveal: 1.0, platter: true);
      _paintFrame(context, offset, (
        grow: start.grow * (1 - _returnSpring.transform(dismissal)),
        moveX: start.moveX * (1 - _returnXSpring.transform(dismissal)),
        moveY: start.moveY * (1 - _returnYSpring.transform(dismissal)),
        reveal: start.reveal * (1 - _contentOut.transform(dismissal)),
        platter: true,
      ), returning: true);
      return;
    }
    final shrink = Curves.easeOut.transform(dismissal);
    final scale = lerpDouble(1, _dismissScale, shrink)!;
    final anchor = _localAnchor.center;
    final origin = Offset(
      anchor.dx.clamp(0.0, size.width),
      anchor.dy.clamp(0.0, size.height),
    );
    final transform = Matrix4.translationValues(origin.dx, origin.dy, 0)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-origin.dx, -origin.dy, 0, 1);
    context.pushTransform(
      needsCompositing,
      offset,
      transform,
      (context, offset) => LiquidGlassFade.push(
        context,
        offset,
        Color.getAlphaFromOpacity(1 - shrink),
        (context, offset) => _paintFrame(context, offset, frame),
      ),
    );
  }

  void _paintFrame(
    PaintingContext context,
    Offset offset,
    _MorphFrame? frame, {
    bool returning = false,
  }) {
    final child = this.child!;
    if (frame == null) {
      _pane.clear();
      context.paintChild(child, offset);
      return;
    }
    final from = _localAnchor;
    final bounds = Offset.zero & size;
    final progress = frame.grow;
    final extent = Size.lerp(from.size, bounds.size, progress)!;
    final rect = Rect.fromCenter(
      center: Offset(
        lerpDouble(from.center.dx, bounds.center.dx, frame.moveX)!,
        lerpDouble(from.center.dy, bounds.center.dy, frame.moveY)!,
      ),
      width: math.max(0.0, extent.width),
      height: math.max(0.0, extent.height),
    );
    final radius = lerpDouble(from.shortestSide / 2, _cardRadius, progress)!;
    final clip = AppShape.all(math.max(0.0, radius)).getOuterPath(rect);
    final sourceImage = _sourceImage;
    final image = sourceImage?.value;
    // The source control stays visible until its snapshot exists, so the
    // platter would only cover it.
    if (sourceImage != null && image == null) {
      return;
    }
    final reveal = frame.reveal;
    // The card paints the same surface and shadow as the platter, so once it
    // is revealed, or a sub menu leaves the root's bounds, the platter steps
    // aside instead of clipping the levels until the spring settles.
    if (!frame.platter && !size.isEmpty) {
      _pane.clear();
      context.pushTransform(
        needsCompositing,
        offset,
        _contentTransform(rect),
        (context, offset) => context.paintChild(child, offset),
      );
      return;
    }
    final glass = _glass;
    final settled = progress.clamp(0.0, 1.0);
    final rim = glass?.rim.scale(settled);
    // Returning cards keep their own fill and shadow as they fade into the
    // platter's; on glass they stand bare and the platter holds throughout.
    final platter = returning && glass == null ? 1 - reveal : 1.0;
    final path = clip.shift(offset);
    if (glass != null) {
      // Frosted as the card and shadowed after, so one capture serves the morph.
      _pane.paint(
        context,
        rect.shift(offset),
        shape: LiquidGlassCorners.circular(math.max(0.0, radius)),
        style: LiquidGlassStyle.lerp(
          glass.from,
          glass.to,
          settled,
        ).copyWith(blur: glass.to.blur),
        hold: bounds
            .expandToInclude(from)
            .inflate(size.longestSide * _overshootPerLongestSide)
            .shift(offset),
        rim: rim,
      );
    }
    final canvas = context.canvas;
    final reach = _shadows.fold(
      0.0,
      (reach, shadow) =>
          math.max(reach, shadow.blurSigma * 3 + shadow.offset.distance),
    );
    // The blur shades under the platter too; keep that out of fading content.
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(path.getBounds().inflate(reach))
          ..addPath(path, Offset.zero),
      );
    final corners = AppRadius.all(math.max(0.0, radius));
    for (final shadow in _shadows) {
      canvas.drawRSuperellipse(
        corners.toRSuperellipse(rect.shift(offset + shadow.offset)),
        shadow.toPaint()
          ..color = shadow.color.withValues(
            alpha: shadow.color.a * settled * platter,
          ),
      );
    }
    canvas.restore();
    final Color fill;
    if (glass == null) {
      final surface = Color.lerp(_sourceColor, _surfaceColor, settled)!;
      fill = surface.withValues(alpha: surface.a * platter);
    } else {
      fill = _sourceColor.withValues(alpha: _sourceColor.a * (1 - settled));
    }
    canvas.drawPath(path, Paint()..color = fill);
    rim?.paintLine(context.canvas, rect.shift(offset), math.max(0.0, radius));
    final glyph = 1 - reveal;
    if (image != null && glyph > 0) {
      final source = from.shift(rect.center - from.center + offset);
      context.canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        source,
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, glyph)
          ..filterQuality = FilterQuality.medium,
      );
    }
    if (reveal <= 0 || size.isEmpty) {
      return;
    }
    // Opening, the content fills the platter and is cut to it; returning, it
    // shrinks whole inside it.
    final transform = _contentTransform(rect, fit: returning);
    final sigma = _maxContentBlur * (1 - reveal);
    void paintContent(PaintingContext context, Offset offset) =>
        context.pushOpacity(
          offset,
          Color.getAlphaFromOpacity(reveal),
          (context, offset) => context.pushLayer(
            ImageFilterLayer(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            ),
            (context, offset) => context.pushTransform(
              needsCompositing,
              offset,
              transform,
              (context, offset) => context.paintChild(child, offset),
            ),
            offset,
          ),
        );
    if (returning) {
      paintContent(context, offset);
      return;
    }
    context.pushClipPath(needsCompositing, offset, bounds, clip, paintContent);
  }

  Matrix4 _contentTransform(Rect rect, {bool fit = false}) {
    final scale = (fit ? math.min : math.max)(
      rect.width / size.width,
      rect.height / size.height,
    );
    return Matrix4.translationValues(rect.center.dx, rect.center.dy, 0)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1);
  }
}

class _PopupAnchorTracker extends StatefulWidget {
  const _PopupAnchorTracker({
    required this.anchorOf,
    required this.builder,
    required this.child,
  });

  final PopupAnchorResolver anchorOf;
  final Widget Function(Rect anchor, EdgeInsets safeInsets, Widget child)
  builder;
  final Widget child;

  @override
  State<_PopupAnchorTracker> createState() => _PopupAnchorTrackerState();
}

class _PopupAnchorTrackerState extends State<_PopupAnchorTracker> {
  Rect? _anchor;
  bool _syncScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) {
        return;
      }
      final anchor = widget.anchorOf();
      if (anchor == null || anchor == _anchor) {
        return;
      }
      setState(() {
        _anchor = anchor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final anchor = _anchor ??= widget.anchorOf() ?? Rect.zero;
    // padding already gives up the part of the bottom inset the keyboard
    // covers, so the sum keeps clear of the taller of the two.
    return widget.builder(
      anchor,
      mediaQuery.padding + mediaQuery.viewInsets,
      widget.child,
    );
  }
}

class _PopupLayoutDelegate extends SingleChildLayoutDelegate {
  const _PopupLayoutDelegate({
    required this.anchor,
    required this.safeInsets,
    required this.placement,
    required this.pin,
    this.avoid,
  });

  final Rect anchor;
  final EdgeInsets safeInsets;
  final PopupPlacement placement;
  final Rect? avoid;
  final _PopupPin pin;

  EdgeInsets get _insets => safeInsets + const EdgeInsets.all(_screenMargin);

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final insets = _insets;
    return BoxConstraints.loose(
      Size(
        math.max(0.0, constraints.maxWidth - insets.horizontal),
        math.max(0.0, constraints.maxHeight - insets.vertical),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final insets = _insets;
    final maxX = size.width - insets.right - childSize.width;
    final maxY = size.height - insets.bottom - childSize.height;
    final pinned = pin.topRightFor(this, size);
    final (x, y) = pinned != null
        ? (pinned.dx - childSize.width, pinned.dy)
        : switch (placement) {
            PopupPlacement.overAnchorEnd => (
              anchor.right - childSize.width,
              anchor.top - _anchorOverlap,
            ),
            PopupPlacement.overAnchorStart => (
              anchor.left,
              anchor.top - _anchorOverlap,
            ),
            PopupPlacement.belowPoint => (
              anchor.left,
              _yBelowPoint(childSize.height, insets.top, maxY),
            ),
          };
    final minY = placement == PopupPlacement.belowPoint
        ? insets.top
        : math.max(safeInsets.top, math.min(insets.top, y));
    final position = Offset(
      x.clamp(insets.left, math.max(insets.left, maxX)),
      y.clamp(minY, math.max(minY, maxY)),
    );
    if (pinned == null) {
      pin.hold(this, size, position.translate(childSize.width, 0));
    }
    return position;
  }

  double _yBelowPoint(double height, double minY, double maxY) {
    final avoid = this.avoid;
    if (avoid != null) {
      final above = avoid.top - _avoidGap - height;
      if (above >= minY) {
        return above;
      }
      final below = avoid.bottom + _avoidGap;
      if (below <= maxY) {
        return below;
      }
    }
    if (anchor.bottom > maxY && anchor.top - height >= minY) {
      return anchor.top - height;
    }
    return anchor.bottom;
  }

  bool _placesLike(_PopupLayoutDelegate other) {
    return other.anchor == anchor &&
        other.safeInsets == safeInsets &&
        other.placement == placement &&
        other.avoid == avoid;
  }

  @override
  bool shouldRelayout(_PopupLayoutDelegate oldDelegate) {
    return !_placesLike(oldDelegate) || oldDelegate.pin != pin;
  }
}

/// Keeps the top right corner the menu levels stack from while a sub menu
/// unfolds, so the card neither slides nor flips around what it avoids.
class _PopupPin {
  _PopupLayoutDelegate? _placement;
  Size _size = Size.zero;
  Offset _topRight = Offset.zero;

  Offset? topRightFor(_PopupLayoutDelegate placement, Size size) {
    final held = _placement;
    if (held == null || size != _size || !held._placesLike(placement)) {
      return null;
    }
    return _topRight;
  }

  void hold(_PopupLayoutDelegate placement, Size size, Offset topRight) {
    _placement = placement;
    _size = size;
    _topRight = topRight;
  }
}

/// Opens a popup out of the button [targetBuilder] builds. A press on the
/// button opens it at once, as iOS menus do, so the finger can slide on into
/// the menu and let go on an item.
class CommonPopupBox extends StatefulWidget {
  const CommonPopupBox({
    super.key,
    required this.targetBuilder,
    required this.popupBuilder,
    this.placement = PopupPlacement.overAnchorEnd,
  });

  final Widget Function(PopupOpen open) targetBuilder;

  final WidgetBuilder popupBuilder;

  final PopupPlacement placement;

  @override
  State<CommonPopupBox> createState() => _CommonPopupBoxState();
}

class _CommonPopupBoxState extends State<CommonPopupBox> {
  final _sourceKey = GlobalKey();
  final _sourceHidden = ValueNotifier<bool>(false);
  CommonPopupRoute<void>? _route;
  int? _pointer;
  Offset _pressOrigin = Offset.zero;
  bool _pressMoved = false;

  @override
  void dispose() {
    _sourceHidden.dispose();
    super.dispose();
  }

  Rect? _sourceRect() {
    if (!mounted) {
      return null;
    }
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached || !renderBox.hasSize) {
      return null;
    }
    final navigatorBox =
        Navigator.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final origin = renderBox.localToGlobal(Offset.zero, ancestor: navigatorBox);
    return origin & renderBox.size;
  }

  Color _sourceColor() {
    Color? color;
    void visit(Element element) {
      if (color != null) {
        return;
      }
      if (element.widget case final Material material) {
        color = material.type == MaterialType.transparency
            ? Colors.transparent
            : material.color ?? Colors.transparent;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    final resolved = color;
    if (resolved != null && resolved.a > 0) {
      return resolved;
    }
    if (LiquidGlassScope.of(context)) {
      return Colors.transparent;
    }
    final colorScheme = context.colorScheme;
    return SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
  }

  void _captureSource(
    CommonPopupRoute<void> route,
    ValueNotifier<ui.Image?> snapshot,
  ) {
    if (!mounted || !route.isActive) {
      return;
    }
    final boundary = _sourceKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.hasSize) {
      return;
    }
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    snapshot.value = LiquidGlass.withoutPanes(
      () => boundary.toImageSync(pixelRatio: pixelRatio),
    );
    _sourceHidden.value = true;
  }

  /// Whether the button takes taps, as the first ink response in it tells.
  bool _targetEnabled() {
    bool? enabled;
    void visit(Element element) {
      if (enabled != null) {
        return;
      }
      if (element.widget case final InkResponse response) {
        enabled = response.onTap != null;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return enabled ?? false;
  }

  bool _canOpen() => _pointer == null && _route == null && _targetEnabled();

  void _handlePress(PointerDownEvent event) {
    _pointer = event.pointer;
    _pressOrigin = event.position;
    _pressMoved = false;
    _releaseFromNavigator(event.pointer);
    _open();
    // A press around the button may hear this down after the box does.
    scheduleMicrotask(() {
      if (mounted) {
        ElasticPress.maybeOf(context)?.release();
      }
    });
  }

  // A navigator cancels the presses it tracks as it navigates (flutter#4770).
  void _releaseFromNavigator(int pointer) {
    final listener = Navigator.maybeOf(context)?.context.findRenderObject();
    if (listener is RenderPointerListener) {
      listener.onPointerCancel?.call(PointerCancelEvent(pointer: pointer));
    }
  }

  // The popup covers the button, so a press let go where it went down leaves
  // the popup open rather than picking what now lies under it.
  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final slop = computeHitSlop(
      event.kind,
      MediaQuery.maybeGestureSettingsOf(context),
    );
    _pressMoved =
        _pressMoved || (event.position - _pressOrigin).distance > slop;
    if (_pressMoved) {
      _route?._press.onMove?.call(event.position);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    if (_pressMoved) {
      _route?._press.onRelease?.call(event.position);
    }
  }

  void _handlePressCancel() {
    if (_pointer == null) {
      return;
    }
    _pointer = null;
    _route?._press.onCancel?.call();
  }

  void _open() {
    if (_route != null) {
      return;
    }
    final snapshot = ValueNotifier<ui.Image?>(null);
    final route = _route = CommonPopupRoute<void>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (context) => widget.popupBuilder(context),
      anchorOf: _sourceRect,
      placement: widget.placement,
      elevated: ElevatedSurfaceTheme.isIn(context),
      sourceColor: _sourceColor(),
      sourceImage: snapshot,
    );
    Navigator.of(context).push(route);
    void reveal() {
      if (mounted) {
        _sourceHidden.value = false;
      }
    }

    route.animation!.addStatusListener((status) {
      if (status.isDismissed) {
        reveal();
      }
    });
    route.completed.whenComplete(() {
      if (identical(_route, route)) {
        _route = null;
      }
      reveal();
      snapshot.value?.dispose();
      snapshot.dispose();
    });
    // The control repaints its ink as it is tapped, so it can only be
    // captured once that frame has been painted.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _captureSource(route, snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: {
        _PopupPressRecognizer:
            GestureRecognizerFactoryWithHandlers<_PopupPressRecognizer>(
              () => _PopupPressRecognizer(debugOwner: this),
              (recognizer) => recognizer
                ..delay = Scrollable.maybeOf(context) == null
                    ? Duration.zero
                    : kPressTimeout
                ..canOpen = _canOpen
                ..onPress = _handlePress
                ..onMove = _handlePointerMove
                ..onUp = _handlePointerUp
                ..onCancel = _handlePressCancel,
            ),
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _sourceHidden,
        builder: (_, hidden, child) =>
            Opacity(opacity: hidden ? 0 : 1, child: child),
        child: RepaintBoundary(
          key: _sourceKey,
          child: widget.targetBuilder(_open),
        ),
      ),
    );
  }
}

const _valueBlur = 4.0;

class PopupValueText extends StatelessWidget {
  const PopupValueText(
    this.text, {
    super.key,
    this.alignment = AlignmentDirectional.center,
  });

  final String text;
  final AlignmentGeometry alignment;

  static Widget _transition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          final sigma = _valueBlur * (1 - animation.value);
          return ImageFiltered(
            enabled: sigma > 0,
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(commonDuration);
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      alignment: alignment,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: const Interval(0.3, 1, curve: Curves.easeOut),
        switchOutCurve: const Interval(0.6, 1, curve: Curves.easeIn),
        transitionBuilder: _transition,
        // The old value takes no room, so the button sizes to the new one
        // and AnimatedSize eases it there while both are showing.
        layoutBuilder: (current, previous) => Stack(
          alignment: alignment,
          clipBehavior: Clip.none,
          children: [
            for (final child in previous)
              SizedOverflowBox(
                size: Size.zero,
                alignment: alignment,
                child: child,
              ),
            ?current,
          ],
        ),
        child: Text(
          text,
          key: ValueKey(text),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Opens a popup on its button's pointer down and carries the press on into
/// it, claiming the pointer so the button's tap and tooltip stand down. In a
/// scroll view it waits [delay] first, so a drag scrolls instead.
class _PopupPressRecognizer extends OneSequenceGestureRecognizer {
  _PopupPressRecognizer({super.debugOwner});

  Duration delay = Duration.zero;
  bool Function()? canOpen;
  ValueSetter<PointerDownEvent>? onPress;
  ValueSetter<PointerMoveEvent>? onMove;
  ValueSetter<PointerUpEvent>? onUp;
  VoidCallback? onCancel;

  PointerDownEvent? _down;
  Timer? _timer;
  bool _pressed = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      _down == null &&
      event.buttons == kPrimaryButton &&
      super.isPointerAllowed(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!(canOpen?.call() ?? false)) {
      return;
    }
    _down = event;
    _pressed = false;
    startTrackingPointer(event.pointer, event.transform);
    if (delay == Duration.zero) {
      _press();
    } else {
      _timer = Timer(delay, _press);
    }
  }

  void _press() {
    _timer?.cancel();
    _timer = null;
    final down = _down;
    if (down == null || _pressed) {
      return;
    }
    _pressed = true;
    resolve(GestureDisposition.accepted);
    onPress?.call(down);
  }

  @override
  void handleEvent(PointerEvent event) {
    final down = _down;
    if (down == null) {
      return;
    }
    if (event is PointerMoveEvent) {
      if (_pressed) {
        onMove?.call(event);
      } else if ((event.position - down.position).distance >
          computeHitSlop(event.kind, gestureSettings)) {
        resolve(GestureDisposition.rejected);
        _reset(event.pointer);
      }
    } else if (event is PointerUpEvent) {
      _press();
      onUp?.call(event);
      _reset(event.pointer);
    } else if (event is PointerCancelEvent) {
      if (_pressed) {
        onCancel?.call();
      } else {
        resolve(GestureDisposition.rejected);
      }
      _reset(event.pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    final pressed = _pressed;
    _reset(pointer);
    if (pressed) {
      onCancel?.call();
    }
  }

  void _reset(int pointer) {
    _timer?.cancel();
    _timer = null;
    _down = null;
    _pressed = false;
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  String get debugDescription => 'popup press';
}

class CommonPopupMenuItem {
  const CommonPopupMenuItem({
    required this.label,
    this.glyph,
    this.onPressed,
    this.danger = false,
    this.checked,
    this.subItems = const [],
  });

  final String label;
  final Glyph? glyph;
  final VoidCallback? onPressed;
  final bool danger;
  final bool? checked;
  final List<CommonPopupMenuItem> subItems;
}

const _menuMinWidth = 160.0;
const _menuMaxWidth = 280.0;
const _defaultMaxVisibleItems = 7;

class CommonPopupMenu extends StatefulWidget {
  const CommonPopupMenu({super.key, required this.items, this.maxVisibleItems});

  final List<CommonPopupMenuItem> items;

  /// Half of the next row shows past these, so the cut tells the menu scrolls.
  /// Setting them builds only the rows in view, which needs rows of one height.
  final int? maxVisibleItems;

  @override
  State<CommonPopupMenu> createState() => _CommonPopupMenuState();
}

class _MenuStep {
  const _MenuStep({
    required this.index,
    required this.itemTop,
    required this.itemHeight,
    required this.cardWidth,
  });

  final int index;
  final double itemTop;
  final double itemHeight;
  final double cardWidth;
}

class _MenuLevel {
  const _MenuLevel({
    required this.items,
    required this.top,
    required this.fromWidth,
    required this.minWidth,
    required this.maxWidth,
    this.owner,
    this.step,
  });

  final List<CommonPopupMenuItem> items;
  final CommonPopupMenuItem? owner;

  /// The step that opened this level from an item of the one below.
  final _MenuStep? step;
  final double top;
  final double fromWidth;
  final double minWidth;
  final double maxWidth;
}

/// [begin] to [end] of a value that may overshoot either, as 0 to 1.
class _Span extends Animatable<double> {
  const _Span(this.begin, this.end);

  final double begin;
  final double end;

  @override
  double transform(double t) => ((t - begin) / (end - begin)).clamp(0.0, 1.0);
}

class _CommonPopupMenuState extends State<CommonPopupMenu>
    with SingleTickerProviderStateMixin {
  static const _headerIndex = -1;
  static const _levelWidthScale = 1.12;
  static const _levelScaleStep = 0.05;
  static const _levelFadeStep = 0.2;
  static const _levelShadowStep = 1 / 3;
  static const _minShadow = 1 / 6;
  static const _widthSpan = 0.3;
  static const _glassSpan = _Span(0, 0.35);
  static final _arrowTurns = const _Span(
    0,
    1,
  ).chain(Tween(begin: 0.0, end: 0.25));

  /// Where the top sub menu stands, from its item at 0 to its card at 1; one
  /// spring drives every part of the move, so a fold caught mid-unfold turns
  /// around with the speed it had.
  late final _unfold = AnimationController.unbounded(vsync: this, value: 1);
  late final Animation<double> _items = _unfold.drive(const _Span(0.05, 0.4));
  late final Animation<double> _arrow = _unfold.drive(_arrowTurns);

  ValueListenable<bool>? _platter;
  late Listenable _motion = _unfold;
  _CarriedPress? _carried;
  ValueSetter<VoidCallback>? _runPicked;

  final List<_MenuStep> _path = [];
  bool _folding = false;
  final _menuKey = GlobalKey();
  final _checkedKey = GlobalKey();
  ScrollController? _lazyController;

  /// The row of the top level under a finger that pressed one, or
  /// [_headerIndex] for its header.
  int? _pressed;
  Timer? _dwell;

  /// Whether the press rests where a sub menu it opened or folded left it,
  /// the header standing on its item, so letting go there changes nothing.
  bool _landed = false;
  bool _carrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealChecked());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _PopupScope.maybeOf(context);
    final platter = scope?.platter;
    if (platter != _platter) {
      _platter = platter;
      _motion = Listenable.merge([_unfold, ?platter]);
    }
    _runPicked = scope?.runPicked;
    _carried = scope?.press
      ?..onMove = _slideCarried
      ..onRelease = _releaseCarried
      ..onCancel = _cancelCarried;
  }

  @override
  void dispose() {
    _carried
      ?..onMove = null
      ..onRelease = null
      ..onCancel = null;
    _dwell?.cancel();
    _unfold.dispose();
    _lazyController?.dispose();
    super.dispose();
  }

  /// A menu given its own cap builds only the rows in view, since building
  /// them all costs its first frame a row each; its rows share one height.
  bool _buildsLazily(_MenuLevel level) =>
      widget.maxVisibleItems != null &&
      level.owner == null &&
      level.items.every((item) => item.subItems.isEmpty);

  void _revealChecked() {
    final row = _checkedKey.currentContext;
    if (!mounted || row == null) {
      return;
    }
    // Whole rows above, not centring, keep the half row a label cut at the foot.
    final visible = _maxVisibleItems;
    final alignment = (visible ~/ 2) / (visible - 0.5);
    Scrollable.maybeOf(
      row,
    )?.position.ensureVisible(row.findRenderObject()!, alignment: alignment);
  }

  double _rowExtentOf(BuildContext context) =>
      _itemPadding.vertical +
      MediaQuery.textScalerOf(context).scale(AppTextStyle.subheadline.leading);

  int get _maxVisibleItems => widget.maxVisibleItems ?? _defaultMaxVisibleItems;

  double _maxHeightOf(BuildContext context, _MenuLevel level) {
    if (level.owner != null) {
      return double.infinity;
    }
    return 2 * _cardInset + (_maxVisibleItems + 0.5) * _rowExtentOf(context);
  }

  static final _labelWidths = <(String, TextStyle, TextScaler), double>{};

  /// What the rows would take at their intrinsic width, measured from the
  /// labels as the rows lay them out.
  double _lazyWidthOf(BuildContext context, List<CommonPopupMenuItem> items) {
    final style = AppTextStyle.subheadline.of(context);
    final root = DefaultTextStyle.of(context).style.merge(style);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    const limit = _menuMaxWidth - 2 * _cardInset;
    var width = 0.0;
    for (final item in items) {
      if (_labelWidths.length >= 1024) {
        _labelWidths.clear();
      }
      final label = _labelWidths[(item.label, root, textScaler)] ??= () {
        final painter = TextPainter(
          text: TextSpan(
            style: root,
            children: [EmojiText.spanOf(item.label, style)],
          ),
          textDirection: textDirection,
          textScaler: textScaler,
          locale: locale,
          maxLines: 1,
        )..layout();
        try {
          return painter.maxIntrinsicWidth;
        } finally {
          painter.dispose();
        }
      }();
      final checked = item.checked == true;
      final row =
          (checked ? _itemArrowPadding : _itemPadding).horizontal +
          (item.glyph != null ? _itemIconSize + 12 : 0) +
          label +
          (checked ? 8 + _submenuArrowSize : 0);
      width = math.max(width, row);
      if (width >= limit) {
        break;
      }
    }
    return width;
  }

  Widget _buildLazyContent(BuildContext context, _MenuLevel level) {
    final items = level.items;
    final extent = _rowExtentOf(context);
    final visible = _maxVisibleItems;
    final height = math.min(items.length, visible + 0.5) * extent;
    final controller = _lazyController ??= () {
      final checked = items.indexWhere((item) => item.checked == true);
      // Whole rows above, as _revealChecked leaves them.
      return ScrollController(
        initialScrollOffset: ((checked - visible ~/ 2) * extent).clamp(
          0.0,
          math.max(0.0, items.length * extent - height),
        ),
      );
    }();
    return SizedBox(
      width: _lazyWidthOf(context, items),
      height: height,
      child: ListView.builder(
        controller: controller,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemExtent: extent,
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildItem(context, items[index], index, active: true),
      ),
    );
  }

  List<_MenuLevel> _resolveLevels() {
    final levels = [
      _MenuLevel(
        items: widget.items,
        top: 0,
        fromWidth: _menuMinWidth,
        minWidth: _menuMinWidth,
        maxWidth: _menuMaxWidth,
      ),
    ];
    for (final step in _path) {
      final parent = levels.last;
      if (step.index >= parent.items.length) {
        break;
      }
      final item = parent.items[step.index];
      if (item.subItems.isEmpty) {
        break;
      }
      final fromWidth = math.max(step.cardWidth, parent.minWidth);
      final minWidth = fromWidth * _levelWidthScale;
      levels.add(
        _MenuLevel(
          items: item.subItems,
          owner: item,
          step: step,
          top: math.max(0, step.itemTop - _cardInset),
          fromWidth: fromWidth,
          minWidth: minWidth,
          maxWidth: math.max(minWidth, _menuMaxWidth),
        ),
      );
    }
    return levels;
  }

  void _push(BuildContext itemContext, int index) {
    final itemBox = itemContext.findRenderObject() as RenderBox?;
    final stackBox = context.findRenderObject() as RenderBox?;
    final placed =
        itemBox != null &&
        stackBox != null &&
        itemBox.hasSize &&
        stackBox.hasSize;
    const _PopupUnfoldNotification().dispatch(context);
    setState(() {
      _folding = false;
      _path.add(
        _MenuStep(
          index: index,
          itemTop: placed
              ? itemBox.localToGlobal(Offset.zero, ancestor: stackBox).dy
              : 0,
          itemHeight: placed ? itemBox.size.height : 0,
          cardWidth: placed
              ? itemBox.size.width + 2 * _cardInset
              : _menuMinWidth,
        ),
      );
    });
    _unfold.value = 0;
    _unfoldTop();
  }

  TickerFuture _springTo(double target, SpringDescription spring) {
    return _unfold.animateWith(
      SpringSimulation(spring, _unfold.value, target, _unfold.velocity),
    );
  }

  void _unfoldTop() {
    // A spring stops within its tolerance; the card lands on its bounds.
    _springTo(1, _unfoldSpring).then((_) {
      if (mounted && !_folding) {
        _unfold.value = 1;
      }
    });
  }

  void _pop() {
    if (_path.isEmpty || _folding) {
      return;
    }
    setState(() => _folding = true);
    _springTo(0, _foldSpring).then((_) {
      if (!mounted || !_folding) {
        return;
      }
      setState(() {
        _folding = false;
        final step = _path.removeLast();
        // The header stood on the item that opened its sub menu.
        if (_pressed == _headerIndex) {
          _pressed = step.index;
        }
        _unfold.value = 1;
      });
    });
  }

  /// The header stands on the item that opened its sub menu, so tapping it
  /// mid-fold reads as tapping that item again.
  void _toggleTop() {
    if (!_folding) {
      _pop();
      return;
    }
    setState(() => _folding = false);
    _unfoldTop();
  }

  void _select(VoidCallback onPressed) {
    Navigator.of(context).pop();
    final runPicked = _runPicked;
    if (runPicked == null) {
      onPressed();
    } else {
      runPicked(onPressed);
    }
  }

  /// Hit tests where the menu paints, which a press swells or stretches.
  _MenuRow? _rowAt(Offset position) {
    final box = _menuKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) {
      return null;
    }
    final painted = ElasticPress.paintBoundsOf(box);
    final local = box.globalToLocal(position);
    final result = BoxHitTestResult();
    box.hitTest(
      result,
      position: Offset(
        (local.dx - painted.left) * box.size.width / painted.width,
        (local.dy - painted.top) * box.size.height / painted.height,
      ),
    );
    for (final entry in result.path) {
      if (entry.target case RenderMetaData(metaData: final _MenuRow row)) {
        return row;
      }
    }
    return null;
  }

  bool _startPress(Offset position) {
    final row = _rowAt(position);
    if (row == null) {
      return false;
    }
    _hold(row);
    return true;
  }

  void _slidePress(Offset position) {
    final row = _rowAt(position);
    final index = row?.onTap == null ? null : row!.index;
    if (index == _pressed) {
      return;
    }
    if (index != null) {
      HapticFeedback.selectionClick();
    }
    _hold(row);
  }

  void _hold(_MenuRow? row) {
    _dwell?.cancel();
    _landed = false;
    final onTap = row?.onTap;
    final index = onTap == null ? null : row!.index;
    setState(() => _pressed = index);
    if (onTap == null || !row!.togglesSubMenu) {
      return;
    }
    _dwell = Timer(_dwellDuration, () {
      if (!mounted || _pressed != index) {
        return;
      }
      onTap();
      HapticFeedback.selectionClick();
      setState(() {
        _pressed = _headerIndex;
        _landed = true;
      });
    });
  }

  void _endPress(Offset position) {
    final onTap = _landed ? null : _rowAt(position)?.onTap;
    _cancelPress();
    onTap?.call();
  }

  void _cancelPress() {
    _dwell?.cancel();
    _landed = false;
    if (mounted && _pressed != null) {
      setState(() => _pressed = null);
    }
  }

  ElasticPressHandle? get _elastic {
    final menu = _menuKey.currentContext;
    return menu == null ? null : ElasticPress.maybeOf(menu);
  }

  bool get _platterShows => _platter?.value ?? false;

  void _slideCarried(Offset position) {
    if (!_carrying && !_platterShows) {
      _carrying = true;
      _elastic?.press(position);
    }
    if (_carrying) {
      _elastic?.drag(position);
    }
    _slidePress(position);
  }

  void _releaseCarried(Offset position) {
    _carrying = false;
    _elastic?.release();
    _endPress(position);
  }

  void _cancelCarried() {
    _carrying = false;
    _elastic?.release();
    _cancelPress();
  }

  Widget _buildRow(
    BuildContext context, {
    required CommonPopupMenuItem item,
    required int index,
    required VoidCallback? onTap,
    bool pressed = false,
    Animation<double>? arrowTurns,
  }) {
    final colorScheme = context.colorScheme;
    final enabled = onTap != null;
    final color = item.danger ? colorScheme.error : colorScheme.onSurface;
    final foregroundColor = enabled ? color : color.opacity30;
    Widget? arrow;
    if (item.subItems.isNotEmpty) {
      arrow = GlyphIcon(
        AppGlyphs.chevronForward,
        size: _submenuArrowSize,
        color: foregroundColor,
      );
      if (arrowTurns != null) {
        arrow = RotationTransition(turns: arrowTurns, child: arrow);
      }
    } else if (item.checked == true) {
      arrow = GlyphIcon(
        AppGlyphs.check,
        size: _submenuArrowSize,
        color: foregroundColor,
      );
    }
    // A press is the menu's to follow across the rows, so the row's own ink
    // only shows hover and focus.
    final child = InkWell(
      customBorder: AppShape.all(_itemRadius),
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: item.danger ? colorScheme.error.opacity10 : null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: pressed ? Theme.of(context).highlightColor : null,
          shape: AppShape.all(_itemRadius),
        ),
        child: Padding(
          padding: arrow != null ? _itemArrowPadding : _itemPadding,
          child: Row(
            children: [
              if (item.glyph case final glyph?) ...[
                GlyphIcon(glyph, size: _itemIconSize, color: foregroundColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: EmojiText(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(color: foregroundColor),
                ),
              ),
              if (arrow != null) ...[const SizedBox(width: 8), arrow],
            ],
          ),
        ),
      ),
    );
    return MetaData(
      metaData: _MenuRow(
        index,
        onTap,
        togglesSubMenu:
            item.subItems.isNotEmpty && !(index == _headerIndex && _folding),
      ),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        enabled: enabled,
        checked: item.checked,
        child: child,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    CommonPopupMenuItem item,
    int index, {
    required bool active,
  }) {
    final pressed = active && _pressed == index;
    if (item.subItems.isNotEmpty) {
      return Builder(
        builder: (itemContext) => _buildRow(
          itemContext,
          item: item,
          index: index,
          pressed: pressed,
          onTap: () => _push(itemContext, index),
        ),
      );
    }
    final onPressed = item.onPressed;
    return _buildRow(
      context,
      item: item,
      index: index,
      pressed: pressed,
      onTap: onPressed == null ? null : () => _select(onPressed),
    );
  }

  Widget _buildContent(
    BuildContext context,
    _MenuLevel level, {
    required bool active,
    required int? covered,
  }) {
    final owner = level.owner;
    final checked = owner == null
        ? level.items.indexWhere((item) => item.checked == true)
        : -1;
    final items = [
      for (var index = 0; index < level.items.length; index++)
        // The item a sub menu stands on hides under its header, which draws
        // it again; on glass the two would show through each other.
        Opacity(
          key: index == checked ? _checkedKey : null,
          opacity: index == covered ? 0 : 1,
          child: _buildItem(context, level.items[index], index, active: active),
        ),
    ];
    if (owner == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          context,
          item: owner,
          index: _headerIndex,
          pressed: active && _pressed == _headerIndex,
          onTap: _toggleTop,
          arrowTurns: active ? _arrow : const AlwaysStoppedAnimation(0.25),
        ),
        IgnorePointer(
          ignoring: active && _folding,
          child: FadeTransition(
            opacity: active ? _items : kAlwaysCompleteAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: _dividerHeight, thickness: 1),
                ...items,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevel(
    BuildContext context,
    _MenuLevel level, {
    required int depth,
    required double pivot,
    required int? covered,
  }) {
    final receding = depth > 0;
    final step = receding ? null : level.step;
    final colorScheme = context.colorScheme;
    final glass = LiquidGlassScope.of(context)
        ? LiquidGlassStyle.menu(colorScheme)
        : null;
    final rim = glass == null ? null : LiquidGlassRim.menu(colorScheme);
    final fill = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    // A card behind a sub menu takes a tap as one outside that sub menu.
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: receding ? _pop : null,
      child: ExcludeSemantics(
        excluding: receding,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, child) {
              final unfold = _unfold.value;
              final settled = unfold.clamp(0.0, 1.0);
              final width = step == null
                  ? 1.0
                  : (settled / _widthSpan).clamp(0.0, 1.0);
              final distance = receding ? depth - 1 + settled : 0.0;
              final scale = math.max(0.0, 1 - _levelScaleStep * distance);
              final shadow = receding
                  ? math.max(_minShadow, 1 - distance * _levelShadowStep)
                  : step == null
                  ? 1.0
                  : settled;
              return Transform(
                transform: Matrix4.diagonal3Values(scale, scale, 1),
                alignment: Alignment.topRight,
                origin: Offset(0, pivot),
                child: PopupMenuCard(
                  grow: step == null ? 1 : unfold,
                  origin: step == null
                      ? null
                      : (
                          top: step.itemTop - level.top,
                          height: step.itemHeight,
                        ),
                  shadows: glass == null
                      ? _cardShadows(colorScheme, shadow)
                      : glassMenuShadows(colorScheme, shadow),
                  fill: fill,
                  dim: colorScheme.surface.withValues(
                    alpha: math.min(0.4, _levelFadeStep * distance),
                  ),
                  glass: step == null
                      ? glass
                      : glass?.scale(_glassSpan.transform(unfold)),
                  rim: step == null
                      ? rim
                      : rim?.scale(_glassSpan.transform(unfold)),
                  bare: _platter?.value ?? false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: lerpDouble(
                        level.fromWidth,
                        level.minWidth,
                        width,
                      )!,
                      maxWidth: lerpDouble(
                        level.fromWidth,
                        level.maxWidth,
                        width,
                      )!,
                      maxHeight: _maxHeightOf(context, level),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: IgnorePointer(
              ignoring: receding,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.all(_cardInset),
                  child: _buildsLazily(level)
                      ? _buildLazyContent(context, level)
                      : SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: IntrinsicWidth(
                            child: _buildContent(
                              context,
                              level,
                              active: !receding,
                              covered: covered,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levels = _resolveLevels();
    final topIndex = levels.length - 1;
    return PopScope(
      canPop: topIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _pop();
        }
      },
      // The platter clips the menu while it opens and does not swell with it,
      // so a swell then would cut the menu's edges until the platter left.
      child: ValueListenableBuilder<bool>(
        valueListenable: _platter ?? const AlwaysStoppedAnimation(false),
        builder: (_, platter, child) =>
            ElasticPress(enabled: !platter, pullPastEdges: true, child: child!),
        child: RawGestureDetector(
          key: _menuKey,
          gestures: {
            _RowPressRecognizer:
                GestureRecognizerFactoryWithHandlers<_RowPressRecognizer>(
                  () => _RowPressRecognizer(debugOwner: this),
                  (recognizer) => recognizer
                    ..onStart = _startPress
                    ..onUpdate = _slidePress
                    ..onEnd = _endPress
                    ..onCancel = _cancelPress,
                ),
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              for (var index = 0; index <= topIndex; index++)
                Padding(
                  key: ValueKey(index),
                  padding: EdgeInsets.only(top: levels[index].top),
                  child: _buildLevel(
                    context,
                    levels[index],
                    depth: topIndex - index,
                    pivot: index < topIndex
                        ? _path[index].itemTop - levels[index].top
                        : 0,
                    covered: index < topIndex ? _path[index].index : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow {
  const _MenuRow(this.index, this.onTap, {required this.togglesSubMenu});

  final int index;
  final VoidCallback? onTap;
  final bool togglesSubMenu;
}

/// Follows a press on a row across the rows and picks the one it is let go
/// on, as iOS menus do. It claims the pointer only then, so a menu that
/// scrolls takes a drag first, and a row's own tap never fires on a press.
class _RowPressRecognizer extends OneSequenceGestureRecognizer {
  _RowPressRecognizer({super.debugOwner});

  bool Function(Offset position)? onStart;
  ValueSetter<Offset>? onUpdate;
  ValueSetter<Offset>? onEnd;
  VoidCallback? onCancel;

  int? _pointer;
  Offset? _release;
  bool _accepted = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      _pointer == null &&
      event.buttons == kPrimaryButton &&
      super.isPointerAllowed(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!(onStart?.call(event.position) ?? false)) {
      return;
    }
    _pointer = event.pointer;
    _release = null;
    _accepted = false;
    startTrackingPointer(event.pointer, event.transform);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onUpdate?.call(event.position);
    } else if (event is PointerUpEvent) {
      _release = event.position;
      stopTrackingPointer(event.pointer);
      if (_accepted) {
        _finish();
      } else {
        resolve(GestureDisposition.accepted);
      }
    } else if (event is PointerCancelEvent) {
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  void acceptGesture(int pointer) {
    _accepted = true;
    if (pointer == _pointer && _release != null) {
      _finish();
    }
  }

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
    if (pointer != _pointer) {
      return;
    }
    _pointer = null;
    _release = null;
    onCancel?.call();
  }

  void _finish() {
    final release = _release!;
    _pointer = null;
    _release = null;
    onEnd?.call(release);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'menu row press';
}

/// A menu card, which a sub menu grows out of the item that opens it: its
/// surface and clip move from that item at [grow] 0 to its own bounds at 1,
/// over content laid out at full height.
@visibleForTesting
class PopupMenuCard extends SingleChildRenderObjectWidget {
  const PopupMenuCard({
    super.key,
    required this.grow,
    required this.origin,
    required this.shadows,
    required this.fill,
    required this.dim,
    required this.glass,
    this.rim,
    required this.bare,
    super.child,
  });

  final double grow;

  /// The top and height of the item a sub menu grows out of, which spans the
  /// card's current width since the content is laid out to it.
  final ({double top, double height})? origin;

  final List<BoxShadow> shadows;
  final Color fill;

  /// Laid over the content, as a card recedes under the one above it.
  final Color dim;

  final LiquidGlassStyle? glass;
  final LiquidGlassRim? rim;

  /// Leaves the glass out while the popup's platter bends the backdrop.
  final bool bare;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPopupMenuCard(
      grow: grow,
      origin: origin,
      shadows: shadows,
      fill: fill,
      dim: dim,
      glass: glass,
      rim: rim,
      bare: bare,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderPopupMenuCard)
      ..grow = grow
      ..origin = origin
      ..shadows = shadows
      ..fill = fill
      ..dim = dim
      ..glass = glass
      ..rim = rim
      ..bare = bare;
  }
}

class _RenderPopupMenuCard extends RenderProxyBox {
  _RenderPopupMenuCard({
    required double grow,
    required ({double top, double height})? origin,
    required List<BoxShadow> shadows,
    required Color fill,
    required Color dim,
    required LiquidGlassStyle? glass,
    required LiquidGlassRim? rim,
    required bool bare,
  }) : _grow = grow,
       _origin = origin,
       _shadows = shadows,
       _fill = fill,
       _dim = dim,
       _glass = glass,
       _rim = rim,
       _bare = bare;

  late final _pane = LiquidGlassPane(markNeedsPaint);
  final _clip = LayerHandle<ClipPathLayer>();

  double _grow;
  set grow(double value) {
    if (value == _grow) {
      return;
    }
    _grow = value;
    markNeedsPaint();
  }

  ({double top, double height})? _origin;
  set origin(({double top, double height})? value) {
    if (value == _origin) {
      return;
    }
    _origin = value;
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

  Color _fill;
  set fill(Color value) {
    if (value == _fill) {
      return;
    }
    _fill = value;
    markNeedsPaint();
  }

  Color _dim;
  set dim(Color value) {
    if (value == _dim) {
      return;
    }
    _dim = value;
    markNeedsPaint();
  }

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

  LiquidGlassRim? _rim;
  set rim(LiquidGlassRim? value) {
    if (value == _rim) {
      return;
    }
    _rim = value;
    markNeedsPaint();
  }

  bool _bare;
  set bare(bool value) {
    if (value == _bare) {
      return;
    }
    _bare = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _glass != null;

  Rect get _rect {
    final bounds = Offset.zero & size;
    final origin = _origin;
    if (origin == null) {
      return bounds;
    }
    final item = Rect.fromLTRB(
      _cardInset,
      origin.top,
      size.width - _cardInset,
      origin.top + origin.height,
    );
    return Rect.lerp(item, bounds, _grow)!;
  }

  double get _radius => _origin == null
      ? _cardRadius
      : math.max(0.0, lerpDouble(_itemRadius, _cardRadius, _grow)!);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_rect.contains(position)) {
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void dispose() {
    _pane.dispose();
    _clip.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    final rect = _rect;
    if (child == null || rect.isEmpty) {
      _pane.clear();
      _clip.layer = null;
      return;
    }
    final radius = _radius;
    final shape = AppShape.all(radius).getOuterPath(rect);
    final glass = _glass;
    if (glass == null) {
      final canvas = context.canvas;
      final surface = shape.shift(offset);
      final corners = AppRadius.all(radius);
      for (final shadow in _shadows) {
        canvas.drawRSuperellipse(
          corners.toRSuperellipse(rect.shift(offset + shadow.offset)),
          shadow.toPaint(),
        );
      }
      canvas.drawPath(surface, Paint()..color = _fill);
    } else if (_bare) {
      _pane.clear();
    } else {
      _pane.paint(
        context,
        rect.shift(offset),
        shape: LiquidGlassCorners.circular(radius),
        style: glass,
        shadows: _shadows,
        hold: (Offset.zero & size).shift(offset),
        rim: _rim,
      );
      _rim?.paintLine(context.canvas, rect.shift(offset), radius);
    }
    _clip.layer = context.pushClipPath(
      needsCompositing,
      offset,
      Offset.zero & size,
      shape,
      (context, offset) {
        context.paintChild(child, offset);
        if (_dim.a > 0) {
          context.canvas.drawPath(shape.shift(offset), Paint()..color = _dim);
        }
      },
      oldLayer: _clip.layer,
    );
  }
}
