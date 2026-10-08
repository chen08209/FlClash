import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Slides pages by [slide] while they fade. A page fades by laying
/// [color] over it wherever only that color lies beneath, since an opacity
/// layer costs Impeller an offscreen pass of the page every frame.
class SharedXPageTransition extends StatelessWidget {
  const SharedXPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.color,
    required this.slide,
    required this.overSettledPage,
    this.uncoveredByGesture = false,
    required this.child,
  });

  static const duration = Duration(milliseconds: 450);

  /// Android 14's page slide, as FadeForwardsPageTransitionsBuilder has it.
  static const pageSlide = Offset(0.25, 0);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Color color;

  /// How far a page travels, as a fraction of its size.
  final Offset slide;

  /// Whether the page below sat still as this one came in, so it fades out on
  /// this route's animation and leaves only [color] beneath.
  final bool overSettledPage;

  /// Whether a drag on the page above drives [secondaryAnimation]: the page
  /// then trails the finger and fades in as far as it is uncovered, instead
  /// of showing only near the end of the drag.
  final bool uncoveredByGesture;
  final Widget child;

  static final _slideCurve = CurveTween(curve: Curves.easeInOutCubicEmphasized);

  static const _fadeInCurve = Interval(0.15, 0.55, curve: Curves.easeOutCubic);
  static const _fadeOutCurve = Interval(0, 0.3);
  static final _fadeIn = CurveTween(curve: _fadeInCurve);
  static final _fadeOut = Tween(
    begin: 1.0,
    end: 0.0,
  ).chain(CurveTween(curve: _fadeOutCurve));

  // The fades cross a fifth of the way through, both pages a third opaque, and
  // the page on top shows only on its side of that point so they never double.
  static const _handOver = 0.2;
  static final _takeOver = CurveTween(
    curve: const _HandOver(_fadeInCurve, at: _handOver, leaving: false),
  );
  static final _handBack = Tween(begin: 1.0, end: 0.0).chain(
    CurveTween(
      curve: const _HandOver(_fadeOutCurve, at: _handOver, leaving: true),
    ),
  );

  Animatable<Offset> _slide(Offset begin, Offset end) {
    return Tween(begin: begin, end: end).chain(_slideCurve);
  }

  Widget _overPageBelow(
    Animation<double> animation,
    Animatable<double> pageBelowOpacity,
    Widget child,
  ) {
    final fades = !overSettledPage && animation.isAnimating;
    final opacity = fades ? pageBelowOpacity.evaluate(animation) : 1.0;
    return CustomPaint(
      painter: _Fill(color.withValues(alpha: color.a * (1 - opacity))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterSlide = _slide(slide, Offset.zero);
    final exitSlide = _slide(Offset.zero, slide);
    final gesture = uncoveredByGesture;
    final uncoverSlide = gesture
        ? Tween(begin: -slide, end: Offset.zero)
        : _slide(-slide, Offset.zero);
    final coverSlide = gesture
        ? Tween(begin: Offset.zero, end: -slide)
        : _slide(Offset.zero, -slide);
    final covered = DualTransitionBuilder(
      animation: ReverseAnimation(secondaryAnimation),
      forwardBuilder: (_, animation, child) => SlideTransition(
        position: uncoverSlide.animate(animation),
        child: _PageFade(
          opacity: gesture ? animation : _fadeIn.animate(animation),
          color: color,
          child: child,
        ),
      ),
      reverseBuilder: (_, animation, child) => SlideTransition(
        position: coverSlide.animate(animation),
        child: _PageFade(
          opacity: gesture
              ? ReverseAnimation(animation)
              : _fadeOut.animate(animation),
          color: color,
          child: child,
        ),
      ),
      child: child,
    );
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (_, animation, child) => _overPageBelow(
        animation,
        _fadeOut,
        SlideTransition(
          position: enterSlide.animate(animation),
          child: _PageFade(
            opacity: _takeOver.animate(animation),
            color: color,
            opaque: true,
            child: child,
          ),
        ),
      ),
      reverseBuilder: (_, animation, child) => IgnorePointer(
        ignoring: animation.status == AnimationStatus.forward,
        child: _overPageBelow(
          animation,
          _fadeIn,
          SlideTransition(
            position: exitSlide.animate(animation),
            child: _PageFade(
              opacity: _handBack.animate(animation),
              color: color,
              opaque: true,
              child: child,
            ),
          ),
        ),
      ),
      child: ColoredBox(
        color: secondaryAnimation.isAnimating ? color : Colors.transparent,
        child: covered,
      ),
    );
  }
}

class _HandOver extends Curve {
  const _HandOver(this.curve, {required this.at, required this.leaving});

  final Curve curve;
  final double at;
  final bool leaving;

  @override
  double transformInternal(double t) {
    if (leaving) {
      return t < at ? curve.transform(t) : 1;
    }
    return t < at ? 0 : curve.transform(t);
  }
}

class _Fill extends CustomPainter {
  const _Fill(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_Fill oldDelegate) => color != oldDelegate.color;
}

/// Fades [child] toward [color] by painting that color over it, and under it
/// too if [opaque], so nothing beneath shows through.
class _PageFade extends SingleChildRenderObjectWidget {
  const _PageFade({
    required this.opacity,
    required this.color,
    this.opaque = false,
    super.child,
  });

  final Animation<double> opacity;
  final Color color;
  final bool opaque;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPageFade(opacity: opacity, color: color, opaque: opaque);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPageFade renderObject) {
    renderObject
      ..opacity = opacity
      ..color = color
      ..opaque = opaque;
  }
}

class _RenderPageFade extends RenderProxyBox {
  _RenderPageFade({
    required Animation<double> opacity,
    required Color color,
    required bool opaque,
  }) : _opacity = opacity,
       _color = color,
       _opaque = opaque;

  Animation<double> _opacity;
  Color _color;
  bool _opaque;
  bool _visible = true;

  set opacity(Animation<double> value) {
    if (identical(value, _opacity)) {
      return;
    }
    if (attached) {
      _opacity.removeListener(_update);
      value.addListener(_update);
    }
    _opacity = value;
    _update();
  }

  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  set opaque(bool value) {
    if (value == _opaque) {
      return;
    }
    _opaque = value;
    markNeedsPaint();
  }

  void _update() {
    final visible = _opacity.value > 0;
    if (visible != _visible) {
      _visible = visible;
      markNeedsSemanticsUpdate();
    }
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _opacity.addListener(_update);
    _update();
  }

  @override
  void detach() {
    _opacity.removeListener(_update);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final opacity = _opacity.value;
    if (child == null || opacity == 0) {
      return;
    }
    if (opacity == 1) {
      super.paint(context, offset);
      return;
    }
    if (_opaque) {
      context.canvas.drawRect(offset & size, Paint()..color = _color);
    }
    super.paint(context, offset);
    context.canvas.drawRect(
      offset & size,
      Paint()..color = _color.withValues(alpha: _color.a * (1 - opacity)),
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_visible) {
      super.visitChildrenForSemantics(visitor);
    }
  }
}
