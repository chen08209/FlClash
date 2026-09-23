import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class DonutChartData {
  const DonutChartData({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is DonutChartData && value == other.value && color == other.color;

  @override
  int get hashCode => Object.hash(value, color);
}

class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.data,
    this.trackColor,
    this.duration = commonDuration,
  });

  final List<DonutChartData> data;

  /// Fills the part of the ring [data] leaves empty, such as all of it while
  /// every value is zero.
  final Color? trackColor;

  final Duration duration;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  static const _minChange = 1 / 720;

  late final AnimationController _controller;
  late final CurvedAnimation _progress;
  late List<double> _from;
  late List<double> _to;

  @override
  void initState() {
    super.initState();
    _to = _fractionsOf(widget.data);
    _from = _to;
    _controller = AnimationController(vsync: this, value: 1);
    _progress = CurvedAnimation(parent: _controller, curve: Easing.standard);
  }

  static List<double> _fractionsOf(List<DonutChartData> data) {
    final total = data.fold(0.0, (sum, item) => sum + max(0.0, item.value));
    return [
      for (final item in data) total > 0 ? max(0.0, item.value) / total : 0.0,
    ];
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _fractionsOf(widget.data);
    final current = _lerp(_from, _to, _progress.value);
    var change = double.infinity;
    if (target.length == current.length) {
      change = 0;
      for (var i = 0; i < target.length; i++) {
        change = max(change, (target[i] - current[i]).abs());
      }
    }
    if (change == 0) {
      return;
    }
    if (change < _minChange || change.isInfinite) {
      _from = target;
      _to = target;
      _controller.value = 1;
      return;
    }
    _from = current;
    _to = target;
    _controller
      ..duration = context.motionDuration(widget.duration)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _DonutChartPainter(
            from: _from,
            to: _to,
            progress: _progress,
            colors: [for (final item in widget.data) item.color],
            trackColor:
                widget.trackColor ??
                context.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

List<double> _lerp(List<double> from, List<double> to, double t) {
  return [for (var i = 0; i < to.length; i++) from[i] + (to[i] - from[i]) * t];
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.colors,
    required this.trackColor,
  }) : super(repaint: progress);

  static const _minStrokeWidth = 10.0;
  static const _maxStrokeWidth = 16.0;
  static const _strokeRatio = 0.12;
  static const _gapRatio = 0.3;
  static const _fullDotFraction = 0.01;
  static const _minSweep = 1e-3;

  final List<double> from;
  final List<double> to;
  final Animation<double> progress;
  final List<Color> colors;
  final Color trackColor;

  final Paint _arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _dotPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = min(size.width, size.height);
    final strokeWidth = (diameter * _strokeRatio).clamp(
      _minStrokeWidth.ap,
      _maxStrokeWidth.ap,
    );
    final radius = (diameter - strokeWidth) / 2;
    if (radius <= 0) {
      return;
    }
    final center = size.center(Offset.zero);
    final fractions = _lerp(from, to, progress.value);
    final covered = fractions.fold(0.0, (sum, fraction) => sum + fraction);
    final trackAlpha = trackColor.a * (1 - covered);
    if (trackAlpha * 255 >= 1) {
      _arcPaint
        ..color = trackColor.withValues(alpha: trackAlpha)
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, _arcPaint);
    }

    // Every segment keeps room for its round caps and a gap on either side,
    // so the smallest share still shows as a whole dot; the room, like the
    // dot, only shrinks away as the share falls to zero.
    final weights = [
      for (final fraction in fractions) min(1.0, fraction / _fullDotFraction),
    ];
    final slot = strokeWidth * (1 + _gapRatio) / radius;
    final reserved = weights.fold(0.0, (sum, weight) => sum + weight * slot);
    final available = max(0.0, 2 * pi - reserved);
    final rect = Rect.fromCircle(center: center, radius: radius);

    var start = -pi / 2;
    for (var i = 0; i < fractions.length; i++) {
      final weight = weights[i];
      final sweep = available * fractions[i];
      start += weight * slot / 2;
      if (weight > 0) {
        if (sweep > _minSweep) {
          _arcPaint
            ..color = colors[i]
            ..strokeWidth = strokeWidth * weight;
          canvas.drawArc(rect, start, sweep, false, _arcPaint);
        } else {
          _dotPaint.color = colors[i];
          canvas.drawCircle(
            center + Offset(cos(start), sin(start)) * radius,
            strokeWidth * weight / 2,
            _dotPaint,
          );
        }
      }
      start += sweep + weight * slot / 2;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColor != trackColor;
  }
}
