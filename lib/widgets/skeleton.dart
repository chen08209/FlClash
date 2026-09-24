import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// A pulsing bar that holds the place of one line of [style] text.
class SkeletonText extends StatefulWidget {
  const SkeletonText({super.key, required this.width, this.style});

  final double width;
  final TextStyle? style;

  @override
  State<SkeletonText> createState() => _SkeletonTextState();
}

class _SkeletonTextState extends State<SkeletonText>
    with SingleTickerProviderStateMixin {
  static const _period = Duration(milliseconds: 1600);

  late final AnimationController _controller;
  late final Animation<double> _opacity = _controller.drive(const _Pulse());

  @override
  void initState() {
    super.initState();
    // Starting from the wall clock keeps bars that appear at different times
    // pulsing in step.
    _controller = AnimationController(
      vsync: this,
      duration: _period,
      value:
          DateTime.now().millisecondsSinceEpoch %
          _period.inMilliseconds /
          _period.inMilliseconds,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final barHeight = MediaQuery.textScalerOf(
      context,
    ).scale(style.fontSize ?? 14);
    final bar = DecoratedBox(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: AppShape.full,
      ),
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        child: Stack(
          children: [
            Text(' ', style: style),
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  height: barHeight,
                  width: double.infinity,
                  child: context.disableAnimations
                      ? bar
                      : FadeTransition(opacity: _opacity, child: bar),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pulse extends Animatable<double> {
  const _Pulse();

  @override
  double transform(double t) => 0.75 + 0.25 * math.cos(2 * math.pi * t);
}
