import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
  static const defaultDuration = Duration(milliseconds: 300);
  static const defaultExitDuration = defaultDuration;

  final bool visible;
  final Axis axis;
  final Duration exitDuration;
  final Widget child;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.axis,
    this.exitDuration = defaultExitDuration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final beginOffset = axis == Axis.horizontal
        ? const Offset(-1, 0)
        : const Offset(0, 1);
    return ExcludeSemantics(
      excluding: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: defaultDuration,
              reverseDuration: exitDuration,
              switchInCurve: Easing.standardDecelerate,
              switchOutCurve: const FlippedCurve(Easing.standardAccelerate),
              transitionBuilder: (child, animation) {
                final slideTransition = SlideTransition(
                  position: animation.drive(
                    Tween(begin: beginOffset, end: Offset.zero),
                  ),
                  child: child,
                );
                final content = child.key == const ValueKey(true)
                    ? FadeTransition(opacity: animation, child: slideTransition)
                    : slideTransition;
                return SizeTransition(
                  sizeFactor: animation,
                  axis: axis,
                  alignment: AlignmentDirectional.topStart,
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
