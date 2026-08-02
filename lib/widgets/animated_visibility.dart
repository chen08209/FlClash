import 'package:flutter/material.dart';

const _transitionDuration = Duration(milliseconds: 300);

enum _VisibilityMotion {
  sidebar(
    axis: Axis.horizontal,
    alignment: AlignmentDirectional.topStart,
    hiddenOffset: Offset(-1, 0),
  ),
  bottomNavigation(
    axis: Axis.vertical,
    alignment: AlignmentDirectional.bottomStart,
    hiddenOffset: Offset(0, 1),
  );

  final Axis axis;
  final AlignmentGeometry alignment;
  final Offset hiddenOffset;

  const _VisibilityMotion({
    required this.axis,
    required this.alignment,
    required this.hiddenOffset,
  });
}

/// Animates navigation visibility together with the surrounding layout.
class AnimatedVisibility extends StatefulWidget {
  final bool visible;
  final _VisibilityMotion _motion;
  final Widget child;

  /// Creates a sidebar transition that moves to the left when hidden.
  const AnimatedVisibility.sidebar({
    super.key,
    required this.visible,
    required this.child,
  }) : _motion = _VisibilityMotion.sidebar;

  /// Creates a bottom-navigation transition that moves through the bottom.
  const AnimatedVisibility.bottomNavigation({
    super.key,
    required this.visible,
    required this.child,
  }) : _motion = _VisibilityMotion.bottomNavigation;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late Widget _presentedChild;
  late bool _includeChild;

  @override
  void initState() {
    super.initState();
    _presentedChild = widget.child;
    _includeChild = widget.visible;
    _controller = AnimationController(
      value: widget.visible ? 1 : 0,
      duration: _transitionDuration,
      reverseDuration: _transitionDuration,
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Easing.standardDecelerate,
      reverseCurve: const FlippedCurve(Easing.standardAccelerate),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      if (widget.visible) {
        _presentedChild = widget.child;
      }
      return;
    }
    if (widget.visible) {
      _presentedChild = widget.child;
      _includeChild = true;
      _controller.forward();
      return;
    }
    if (_controller.isDismissed) {
      _includeChild = false;
      return;
    }
    _controller.reverse();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed ||
        widget.visible ||
        !_includeChild) {
      return;
    }
    setState(() {
      _includeChild = false;
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = widget._motion;
    final content = _includeChild
        ? SizeTransition(
            sizeFactor: _animation,
            axis: motion.axis,
            alignment: motion.alignment,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: _animation.drive(
                  Tween(begin: motion.hiddenOffset, end: Offset.zero),
                ),
                child: _presentedChild,
              ),
            ),
          )
        : const SizedBox.shrink();
    return ExcludeSemantics(
      excluding: !widget.visible,
      child: ExcludeFocus(
        excluding: !widget.visible,
        child: IgnorePointer(
          ignoring: !widget.visible,
          child: ClipRect(child: content),
        ),
      ),
    );
  }
}
