import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/common/constant.dart';
import 'package:flutter/material.dart';

@immutable
class BarChartData {
  final double value;
  final String label;

  const BarChartData({
    required this.value,
    required this.label,
  });
}

class BarChart extends StatefulWidget {
  final List<BarChartData> data;
  final Duration duration;

  const BarChart({
    super.key,
    required this.data,
    this.duration = commonDuration,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late List<BarChartData> _oldData;

  @override
  void initState() {
    super.initState();
    _oldData = widget.data;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward(from: 0);
  }

  @override
  void didUpdateWidget(BarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _oldData = oldWidget.data;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, container) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: BarChartPainter(
              _oldData,
              widget.data,
              _animationController.value,
            ),
            size: Size(container.maxWidth, container.maxHeight),
          );
        },
      );
    });
  }
}

class BarChartPainter extends CustomPainter {
  final List<BarChartData> oldData;
  final List<BarChartData> newData;
  final double progress;

  BarChartPainter(this.oldData, this.newData, this.progress);

  Map<String, Rect> getRectMap(List<BarChartData> dataList, Size size) {
    final spacing = size.width * 0.05;
    final maxBarWidth = 30;
    final barWidth =
        (size.width - spacing * (dataList.length - 1)) / dataList.length;
    final maxValue =
        dataList.fold(0.0, (max, item) => max > item.value ? max : item.value);
    final rects = <String, Rect>{};
    for (int i = 0; i < dataList.length; i++) {
      final data = dataList[i];
      double barHeight = (data.value / maxValue) * size.height;

      final adjustLeft =
          barWidth > maxBarWidth ? (barWidth - maxBarWidth) / 2 : 0;
      double left = i * (barWidth + spacing) + adjustLeft;
      double top = size.height - barHeight;
      rects[data.label] = Rect.fromLTWH(
        left,
        top,
        min(barWidth, 30),
        barHeight,
      );
    }
    return rects;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final oldRectMap = getRectMap(oldData, size);
    final newRectMap = getRectMap(newData, size);

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final newRectEntries = newRectMap.entries.toList();
    for (int i = 0; i < newRectEntries.length; i++) {
      final newRectEntry = newRectEntries[i];
      final newRect = newRectEntry.value;
      final oldRect = oldRectMap[newRectEntry.key] ??
          newRect.translate(newRect.left * (progress - 1), 0);

      final interpolatedRect = Rect.fromLTRB(
        lerpDouble(oldRect.left, newRect.left, progress)!,
        lerpDouble(oldRect.top, newRect.top, progress)!,
        lerpDouble(oldRect.right, newRect.right, progress)!,
        lerpDouble(oldRect.bottom, newRect.bottom, progress)!,
      );

      canvas.drawRect(interpolatedRect, paint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.oldData != oldData ||
        oldDelegate.newData != newData;
  }
}
