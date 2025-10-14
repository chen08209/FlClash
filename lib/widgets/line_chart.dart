import 'dart:ui';

import 'package:fl_clash/common/color.dart';
import 'package:flutter/material.dart';

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}

class LineChart extends StatefulWidget {
  final List<Point> points;
  final Color color;
  final Duration duration;
  final bool gradient;

  const LineChart({
    super.key,
    this.gradient = false,
    required this.points,
    required this.color,
    this.duration = Duration.zero,
  });

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Point> _points = [];

  List<Point> _prevRenderPoints = [];
  List<Point> _currentRenderPoints = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _points = widget.points;
    _currentRenderPoints = _getRenderPoints(_points);
    _prevRenderPoints = _currentRenderPoints;
  }

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != _points) {
      _points = widget.points;
      _prevRenderPoints = _currentRenderPoints;
      _currentRenderPoints = _getRenderPoints(_points);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Point> _getRenderPoints(List<Point> points) {
    if (points.isEmpty) return [];
    double maxX = points[0].x;
    double minX = points[0].x;
    double maxY = points[0].y;
    double minY = points[0].y;

    for (final point in points) {
      if (point.x > maxX) maxX = point.x;
      if (point.x < minX) minX = point.x;
      if (point.y > maxY) maxY = point.y;
      if (point.y < minY) minY = point.y;
    }

    return points.map((e) {
      var x = (e.x - minX) / (maxX - minX);
      if (x.isNaN) x = 0;
      var y = (e.y - minY) / (maxY - minY);
      if (y.isNaN) y = 0;
      return Point(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, container) {
        return AnimatedBuilder(
          animation: _controller.view,
          builder: (_, _) {
            return CustomPaint(
              painter: LineChartPainter(
                prevRenderPoints: _prevRenderPoints,
                currentRenderPoints: _currentRenderPoints,
                progress: _controller.value,
                gradient: widget.gradient,
                color: widget.color,
              ),
              child: SizedBox(
                height: container.maxHeight,
                width: container.maxWidth,
              ),
            );
          },
        );
      },
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Point> prevRenderPoints;
  final List<Point> currentRenderPoints;
  final double progress;
  final Color color;
  final bool gradient;

  late final Paint _strokePaint;
  late final Paint _fillPaint;

  Shader? _cachedShader;
  Size? _cachedShaderSize;
  Color? _cachedShaderColor;

  LineChartPainter({
    required this.prevRenderPoints,
    required this.currentRenderPoints,
    required this.progress,
    required this.color,
    required this.gradient,
  }) {
    _strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _fillPaint = Paint()..style = PaintingStyle.fill;
  }

  List<Point> _getInterpolatePoints(double t) {
    if (currentRenderPoints.isEmpty) return [];

    final length = currentRenderPoints.length;
    final result = <Point>[];

    for (var i = 0; i < length; i++) {
      if (i > prevRenderPoints.length - 1) {
        result.add(currentRenderPoints[i]);
      } else {
        final x = lerpDouble(
          prevRenderPoints[i].x,
          currentRenderPoints[i].x,
          t,
        )!;
        final y = lerpDouble(
          prevRenderPoints[i].y,
          currentRenderPoints[i].y,
          t,
        )!;
        result.add(Point(x, y));
      }
    }

    return result;
  }

  Path _getPath(List<Point> points, Size size) {
    if (points.isEmpty) return Path();

    final path = Path()
      ..moveTo(points[0].x * size.width, (1 - points[0].y) * size.height);

    for (var i = 1; i < points.length - 1; i++) {
      final nextPoint = points[i + 1];
      final currentPoint = points[i];
      final midX = (currentPoint.x + nextPoint.x) / 2;
      final midY = (currentPoint.y + nextPoint.y) / 2;

      path.quadraticBezierTo(
        currentPoint.x * size.width,
        (1 - currentPoint.y) * size.height,
        midX * size.width,
        (1 - midY) * size.height,
      );
    }

    path.lineTo(points.last.x * size.width, (1 - points.last.y) * size.height);
    return path;
  }

  Path _getAnimatedPath(Size size) {
    final interpolatedPoints = _getInterpolatePoints(progress);
    return _getPath(interpolatedPoints, size);
  }

  Shader _getShader(Size size) {
    if (_cachedShader == null ||
        _cachedShaderSize != size ||
        _cachedShaderColor != color) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.opacity38, color.opacity10],
      );

      final strokeWidth = 2.0;
      _cachedShader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height + strokeWidth * 2),
      );
      _cachedShaderSize = size;
      _cachedShaderColor = color;
    }
    return _cachedShader!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (currentRenderPoints.isEmpty) return;

    final strokeWidth = 2.0;
    final chartSize = Size(size.width, size.height * 0.7);
    final path = _getAnimatedPath(chartSize);

    if (gradient) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height + strokeWidth * 2);
      fillPath.lineTo(0, size.height + strokeWidth * 2);
      fillPath.close();

      _fillPaint.shader = _getShader(size);
      canvas.drawPath(fillPath, _fillPaint);
    }

    canvas.drawPath(path, _strokePaint);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.prevRenderPoints != prevRenderPoints ||
        oldDelegate.currentRenderPoints != currentRenderPoints ||
        oldDelegate.color != color ||
        oldDelegate.gradient != gradient;
  }
}
