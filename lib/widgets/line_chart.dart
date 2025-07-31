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
  List<Point> prevPoints = [];
  List<Point> points = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    points = widget.points;
    prevPoints = points;
  }

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != points) {
      prevPoints = points;
      points = widget.points;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                prevPoints: prevPoints,
                points: points,
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
  final List<Point> prevPoints;
  final List<Point> points;
  final double progress;
  final Color color;
  final bool gradient;

  LineChartPainter({
    required this.prevPoints,
    required this.points,
    required this.progress,
    required this.color,
    required this.gradient,
  });

  List<Point> getRenderPoints(List<Point> points) {
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

  List<Point> getInterpolatePoints(
    List<Point> prevPoints,
    List<Point> points,
    double t,
  ) {
    final renderPrevPoints = getRenderPoints(prevPoints);
    final renderPoints = getRenderPoints(points);

    return List.generate(renderPoints.length, (i) {
      if (i > renderPrevPoints.length - 1) {
        return renderPoints[i];
      }
      final x = lerpDouble(renderPrevPoints[i].x, renderPoints[i].x, t)!;
      final y = lerpDouble(renderPrevPoints[i].y, renderPoints[i].y, t)!;
      return Point(x, y);
    });
  }

  Path getPath(List<Point> points, Size size) {
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

  Path getAnimatedPath(Size size) {
    final interpolatedPoints = getInterpolatePoints(
      prevPoints,
      points,
      progress,
    );
    final path = getPath(interpolatedPoints, size);

    final metric = path.computeMetrics().first;
    final length = metric.length;
    return metric.extractPath(0, length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 2.0;
    final chartSize = Size(size.width, size.height * 0.7);
    final path = getAnimatedPath(chartSize);

    if (gradient) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height + strokeWidth * 2);
      fillPath.lineTo(0, size.height + strokeWidth * 2);
      fillPath.close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.opacity38, color.opacity10],
      );

      final shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height + strokeWidth * 2),
      );

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.prevPoints != prevPoints ||
        oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.gradient != gradient;
  }
}
