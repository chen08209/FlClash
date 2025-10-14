import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum CrossSlideState { showFirst, showSecond }

typedef AnimatedCrossSlideBuilder =
    Widget Function(
      Widget topChild,
      Key topChildKey,
      Widget bottomChild,
      Key bottomChildKey,
    );

class AnimatedCrossSlide extends StatefulWidget {
  const AnimatedCrossSlide({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.firstCurve = Curves.linear,
    this.secondCurve = Curves.linear,
    this.sizeCurve = Curves.linear,
    this.alignment = Alignment.topCenter,
    required this.crossSlideState,
    required this.duration,
    this.reverseDuration,
    this.layoutBuilder = defaultLayoutBuilder,
    this.excludeBottomFocus = true,
  });

  final Widget firstChild;
  final Widget secondChild;

  final CrossSlideState crossSlideState;

  final Duration duration;

  final Duration? reverseDuration;

  final Curve firstCurve;

  final Curve secondCurve;

  final Curve sizeCurve;

  final AlignmentGeometry alignment;

  final AnimatedCrossSlideBuilder layoutBuilder;

  final bool excludeBottomFocus;

  static Widget defaultLayoutBuilder(
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          key: bottomChildKey,
          left: 0.0,
          top: 0.0,
          right: 0.0,
          child: bottomChild,
        ),
        Positioned(key: topChildKey, child: topChild),
      ],
    );
  }

  @override
  State<AnimatedCrossSlide> createState() => _AnimatedCrossSlideState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<CrossSlideState>('crossSlideState', crossSlideState),
    );
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        alignment,
        defaultValue: Alignment.topCenter,
      ),
    );
    properties.add(
      IntProperty('duration', duration.inMilliseconds, unit: 'ms'),
    );
    properties.add(
      IntProperty(
        'reverseDuration',
        reverseDuration?.inMilliseconds,
        unit: 'ms',
        defaultValue: null,
      ),
    );
  }
}

class _AnimatedCrossSlideState extends State<AnimatedCrossSlide>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _firstAnimation;
  late Animation<double> _secondAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      vsync: this,
    );
    if (widget.crossSlideState == CrossSlideState.showSecond) {
      _controller.value = 1.0;
    }
    _firstAnimation = _initAnimation(widget.firstCurve, true);
    _secondAnimation = _initAnimation(widget.secondCurve, false);
    _controller.addStatusListener((AnimationStatus status) {
      setState(() {});
    });
  }

  Animation<double> _initAnimation(Curve curve, bool inverted) {
    Animation<double> result = _controller.drive(CurveTween(curve: curve));
    if (inverted) {
      result = result.drive(Tween<double>(begin: 1.0, end: 0.0));
    }
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCrossSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.reverseDuration != oldWidget.reverseDuration) {
      _controller.reverseDuration = widget.reverseDuration;
    }
    if (widget.firstCurve != oldWidget.firstCurve) {
      _firstAnimation = _initAnimation(widget.firstCurve, true);
    }
    if (widget.secondCurve != oldWidget.secondCurve) {
      _secondAnimation = _initAnimation(widget.secondCurve, false);
    }
    if (widget.crossSlideState != oldWidget.crossSlideState) {
      switch (widget.crossSlideState) {
        case CrossSlideState.showFirst:
          _controller.reverse();
        case CrossSlideState.showSecond:
          _controller.forward();
      }
    }
  }

  final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  );
  final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    const Key kFirstChildKey = ValueKey<CrossFadeState>(
      CrossFadeState.showFirst,
    );
    const Key kSecondChildKey = ValueKey<CrossFadeState>(
      CrossFadeState.showSecond,
    );
    final Key topKey;
    Widget topChild;
    final Animation<double> topAnimation;
    final Animation<double> bottomAnimation;
    final Animation<Offset> topSlideAnimation;
    final Animation<Offset> bottomSlideAnimation;
    final Key bottomKey;
    Widget bottomChild;
    final secondSlideAnimation = _secondAnimation.drive(_kRightMiddleTween);
    final firstSlideAnimation = _firstAnimation.drive(_kMiddleLeftTween);
    if (_controller.isForwardOrCompleted) {
      topKey = kSecondChildKey;
      topChild = widget.secondChild;
      topAnimation = _secondAnimation;
      topSlideAnimation = secondSlideAnimation;
      bottomKey = kFirstChildKey;
      bottomChild = widget.firstChild;
      bottomAnimation = _firstAnimation;
      bottomSlideAnimation = firstSlideAnimation;
    } else {
      topKey = kFirstChildKey;
      topChild = widget.firstChild;
      topAnimation = _firstAnimation;
      topSlideAnimation = firstSlideAnimation;
      bottomKey = kSecondChildKey;
      bottomChild = widget.secondChild;
      bottomAnimation = _secondAnimation;
      bottomSlideAnimation = secondSlideAnimation;
    }

    bottomChild = TickerMode(
      key: bottomKey,
      enabled: _controller.isAnimating,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: ExcludeFocus(
            excluding: widget.excludeBottomFocus,
            child: SlideTransition(
              position: bottomSlideAnimation,
              child: FadeTransition(
                opacity: bottomAnimation,
                child: bottomChild,
              ),
            ),
          ),
        ),
      ),
    );
    topChild = TickerMode(
      key: topKey,
      enabled: true, // Top widget always has its animations enabled.
      child: IgnorePointer(
        ignoring: false,
        child: ExcludeSemantics(
          excluding: false,
          child: ExcludeFocus(
            excluding: false,
            child: SlideTransition(
              position: topSlideAnimation,
              child: FadeTransition(opacity: topAnimation, child: topChild),
            ),
          ),
        ),
      ),
    );
    return ClipRect(
      child: AnimatedSize(
        alignment: widget.alignment,
        duration: widget.duration,
        reverseDuration: widget.reverseDuration,
        curve: widget.sizeCurve,
        child: widget.layoutBuilder(topChild, topKey, bottomChild, bottomKey),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      EnumProperty<CrossSlideState>('crossSlideState', widget.crossSlideState),
    );
    description.add(
      DiagnosticsProperty<AnimationController>(
        'controller',
        _controller,
        showName: false,
      ),
    );
    description.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        widget.alignment,
        defaultValue: Alignment.topCenter,
      ),
    );
  }
}
