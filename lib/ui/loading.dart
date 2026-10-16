import 'dart:math' as math;

import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

class CommonCircleLoading extends StatefulWidget {
  const CommonCircleLoading({
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  const CommonCircleLoading.page({super.key, this.color, this.semanticLabel})
    : size = 48;

  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  State<CommonCircleLoading> createState() => _CommonCircleLoadingState();
}

class _CommonCircleLoadingState extends State<CommonCircleLoading>
    with SingleTickerProviderStateMixin {
  static const _turnDuration = Duration(milliseconds: 1000);

  late final AnimationController _turns;

  @override
  void initState() {
    super.initState();
    _turns = AnimationController(vsync: this, duration: _turnDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = widget.size ?? IconTheme.of(context).size ?? Glyph.size;
    return Semantics(
      label: widget.semanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(side),
          painter: _CometRingPainter(
            turns: _turns,
            color: widget.color ?? context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _CometRingPainter extends CustomPainter {
  _CometRingPainter({required this.turns, required this.color})
    : super(repaint: turns);

  // A glyph keeps its outline within 20 of its 24 grid, so the ring standing
  // in for one reads at the same size.
  static const _liveArea = 20 / 24;
  static const _minStrokeWidth = 1.5;
  static const _tail = 0.72;

  final Animation<double> turns;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final strokeWidth = math.max(side / 12, _minStrokeWidth);
    final radius = (side * _liveArea - strokeWidth) / 2;
    if (radius <= 0) {
      return;
    }
    final ring = Rect.fromCircle(center: Offset.zero, radius: radius);
    const sweep = _tail * 2 * math.pi;
    Paint stroke() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawCircle(Offset.zero, radius, stroke()..color = color.opacity12);
    canvas.rotate(turns.value * 2 * math.pi);
    canvas.drawArc(
      ring,
      0,
      sweep,
      false,
      stroke()
        ..shader = SweepGradient(
          colors: [color.opacity0, color.opacity30, color, color.opacity0],
          stops: const [0, _tail / 2, _tail, _tail],
        ).createShader(ring),
    );
    canvas.drawCircle(
      Offset(math.cos(sweep), math.sin(sweep)) * radius,
      strokeWidth / 2,
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CometRingPainter oldDelegate) {
    return oldDelegate.turns != turns || oldDelegate.color != color;
  }
}
