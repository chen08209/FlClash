import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:material_ui/material_ui.dart';

/// A pulsing bar that holds the place of one line of [style] text.
class SkeletonText extends StatelessWidget {
  const SkeletonText({super.key, required this.width, this.style});

  final double width;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(this.style);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            Text(' ', style: style),
            Positioned.fill(
              child: Center(
                child: SkeletonPill(
                  width: double.infinity,
                  height: MediaQuery.textScalerOf(
                    context,
                  ).scale(style.fontSize ?? 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pulsing pill that holds the place of a block of a known size.
class SkeletonPill extends StatefulWidget {
  const SkeletonPill({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<SkeletonPill> createState() => _SkeletonPillState();
}

class _SkeletonPillState extends State<SkeletonPill>
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
    final bar = DecoratedBox(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: AppShape.full,
      ),
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: context.disableAnimations
            ? bar
            : FadeTransition(opacity: _opacity, child: bar),
      ),
    );
  }
}

class _Pulse extends Animatable<double> {
  const _Pulse();

  @override
  double transform(double t) => 0.75 + 0.25 * math.cos(2 * math.pi * t);
}
