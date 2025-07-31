import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class FadeBox extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry? alignment;

  const FadeBox({super.key, required this.child, this.alignment});

  @override
  Widget build(BuildContext context) {
    final realAlignment = alignment ?? Alignment.center;
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Align(
        alignment: realAlignment,
        child: Stack(
          alignment: realAlignment,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
      ),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      duration: commonDuration,
      child: child,
    );
  }
}

class FadeThroughBox extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry? alignment;
  final EdgeInsets? margin;

  const FadeThroughBox({
    super.key,
    required this.child,
    this.alignment,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final realAlignment = alignment ?? Alignment.centerLeft;
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: animation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      layoutBuilder: (entries) => Container(
        alignment: realAlignment,
        margin: margin,
        child: Stack(alignment: realAlignment, children: entries),
      ),
      child: child,
    );
  }
}

class FadeRotationScaleBox extends StatelessWidget {
  final Widget child;

  const FadeRotationScaleBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: commonDuration,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: animation.drive(Tween(begin: 0.8, end: 1.0)),
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0.6, end: 1.0)),
            child: ScaleTransition(scale: animation, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class FadeScaleBox extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry? alignment;

  const FadeScaleBox({super.key, required this.child, this.alignment});

  @override
  Widget build(BuildContext context) {
    final realAlignment = alignment ?? Alignment.center;
    return AnimatedSwitcher(
      duration: commonDuration,
      switchOutCurve: Curves.easeOutBack,
      switchInCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.4, end: 1.0)),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Align(
        alignment: realAlignment,
        child: Stack(
          alignment: realAlignment,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
      ),
      child: child,
    );
  }
}

class FadeScaleEnterBox extends StatefulWidget {
  final Widget child;

  const FadeScaleEnterBox({super.key, required this.child});

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
    _controller = AnimationController(vsync: this, duration: commonDuration);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return FadeScaleEnterTransition(animation: _animation, child: child!);
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
