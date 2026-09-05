import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class FadeBox extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry? alignment;
  final StackFit fit;

  const FadeBox({
    super.key,
    required this.child,
    this.alignment,
    this.fit = StackFit.loose,
  });

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
          fit: fit,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
      ),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      duration: context.motionDuration(commonDuration),
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
      duration: context.motionDuration(commonDuration),
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
  final AlignmentGeometry? alignment;

  const FadeRotationScaleBox({super.key, required this.child, this.alignment});

  @override
  Widget build(BuildContext context) {
    final realAlignment = alignment ?? Alignment.center;
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
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: realAlignment,
        children: <Widget>[...previousChildren, ?currentChild],
      ),
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
          children: <Widget>[...previousChildren, ?currentChild],
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
    with SingleTickerProviderStateMixin, _EnterAnimation {
  @override
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: commonDuration);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.disableAnimations) {
      return widget.child;
    }
    return FadeScaleEnterTransition(animation: _animation, child: widget.child);
  }
}

mixin _EnterAnimation<T extends StatefulWidget> on State<T> {
  AnimationController get _controller;
  bool _entered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entered) {
      return;
    }
    _entered = true;
    if (context.disableAnimations) {
      _controller.value = _controller.upperBound;
    } else {
      _controller.forward();
    }
  }
}

const _defaultSlideDistance = 24.0;

class FadeSlideEnterBox extends StatefulWidget {
  final Duration delay;
  final double distance;
  final Axis axis;
  final Widget child;

  const FadeSlideEnterBox({
    super.key,
    this.delay = Duration.zero,
    this.distance = _defaultSlideDistance,
    this.axis = Axis.horizontal,
    required this.child,
  });

  @override
  State<FadeSlideEnterBox> createState() => _FadeSlideEnterBoxState();
}

class _FadeSlideEnterBoxState extends State<FadeSlideEnterBox>
    with SingleTickerProviderStateMixin, _EnterAnimation {
  @override
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final total = commonDuration + widget.delay;
    _controller = AnimationController(vsync: this, duration: total);
    final start = widget.delay.inMicroseconds / total.inMicroseconds;
    _animation = start == 0
        ? _controller.view
        : _controller.drive(CurveTween(curve: Interval(start, 1)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.disableAnimations) {
      return widget.child;
    }
    return FadeSlideEnterTransition(
      animation: _animation,
      distance: widget.distance,
      axis: widget.axis,
      child: widget.child,
    );
  }
}

class FadeSlideEnterTransition extends StatelessWidget {
  const FadeSlideEnterTransition({
    super.key,
    required this.animation,
    this.distance = _defaultSlideDistance,
    this.axis = Axis.horizontal,
    this.child,
  });

  final Animation<double> animation;
  final double distance;
  final Axis axis;
  final Widget? child;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.25),
  );
  static final Animatable<double> _slideInCurve = CurveTween(
    curve: Easing.emphasizedDecelerate,
  );

  @override
  Widget build(BuildContext context) {
    final begin = axis == Axis.horizontal
        ? Offset(-distance, 0)
        : Offset(0, distance);
    final slide = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).chain(_slideInCurve).animate(animation);
    return FadeTransition(
      opacity: _fadeInTransition.animate(animation),
      child: AnimatedBuilder(
        animation: slide,
        builder: (_, child) =>
            Transform.translate(offset: slide.value, child: child),
        child: child,
      ),
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
