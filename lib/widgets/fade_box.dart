import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class FadeBox extends StatelessWidget {
  final Widget child;
  final Alignment? alignment;

  const FadeBox({
    super.key,
    required this.child,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        child,
        animation,
        secondaryAnimation,
      ) {
        return Container(
          alignment: alignment ?? Alignment.centerLeft,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class FadeThroughBox extends StatelessWidget {
  final Widget child;
  final Alignment? alignment;
  final EdgeInsets? margin;

  const FadeThroughBox({
    super.key,
    required this.child,
    this.alignment,
    this.margin
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        child,
        animation,
        secondaryAnimation,
      ) {
        return Container(
          margin: margin,
          alignment: alignment ?? Alignment.centerLeft,
          child: FadeThroughTransition(
            animation: animation,
            fillColor: Colors.transparent,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class FadeScaleBox extends StatelessWidget {
  final Widget child;

  const FadeScaleBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (
        child,
        animation,
      ) {
        return Container(
          alignment: Alignment.bottomRight,
          child: FadeScaleTransition(
            animation: animation,
            child: child,
          ),
        );
      },
      duration: Duration(milliseconds: 300),
      child: child,
    );
  }
}

class FadeScaleEnterBox extends StatefulWidget {
  final Widget child;

  const FadeScaleEnterBox({
    super.key,
    required this.child,
  });

  @override
  State<FadeScaleEnterBox> createState() => _FadeScaleEnterBoxState();
}

class _FadeScaleEnterBoxState extends State<FadeScaleEnterBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        return FadeScaleEnterTransition(
          animation: _animation,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class FadeScaleEnterTransition extends StatelessWidget {
  const FadeScaleEnterTransition({
    super.key,
    required this.animation,
    this.child,
  });

  final Animation<double> animation;
  final Widget? child;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.3),
  );
  static final Animatable<double> _scaleInTransition = Tween<double>(
    begin: 0.70,
    end: 1.00,
  ).chain(CurveTween(curve: Easing.legacyDecelerate));

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInTransition.animate(animation),
      child: ScaleTransition(
        scale: _scaleInTransition.animate(animation),
        child: child,
      ),
    );
  }
}
