import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
  static const defaultDuration = Duration(milliseconds: 450);
  static const _backgroundFadeFraction = 0.35;

  final bool visible;
  final Axis axis;
  final Color? backgroundColor;
  final Duration duration;
  final Widget child;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.axis,
    this.backgroundColor,
    this.duration = defaultDuration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final beginOffset = axis == Axis.horizontal
        ? const Offset(-0.04, 0)
        : const Offset(0, 0.04);
    return ExcludeSemantics(
      excluding: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) {
                final contentAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInOutCubic,
                );
                final content = FadeTransition(
                  opacity: contentAnimation,
                  child: SlideTransition(
                    position: contentAnimation.drive(
                      Tween(begin: beginOffset, end: Offset.zero),
                    ),
                    child: child,
                  ),
                );
                if (backgroundColor == null ||
                    child.key != const ValueKey(true)) {
                  return content;
                }
                return AnimatedBuilder(
                  animation: animation,
                  builder: (_, child) {
                    final opacity = (animation.value / _backgroundFadeFraction)
                        .clamp(0.0, 1.0);
                    return Material(
                      color: backgroundColor!.withValues(
                        alpha: backgroundColor!.a * opacity,
                      ),
                      child: child,
                    );
                  },
                  child: content,
                );
              },
              child: visible
                  ? KeyedSubtree(key: const ValueKey(true), child: child)
                  : const SizedBox(key: ValueKey(false)),
            ),
          ),
        ),
      ),
    );
  }
}
