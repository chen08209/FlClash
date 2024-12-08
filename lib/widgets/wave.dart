import 'dart:math';
import 'package:flutter/material.dart';

class WaveView extends StatefulWidget {
  final double waveAmplitude;
  final double waveFrequency;
  final Color waveColor;
  final Duration duration;

  const WaveView({
    super.key,
    this.waveAmplitude = 50.0,
    this.waveFrequency = 1.5,
    required this.waveColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<WaveView> createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, container) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              animationValue: _controller.value,
              waveAmplitude: widget.waveAmplitude,
              waveFrequency: widget.waveFrequency,
              waveColor: widget.waveColor,
            ),
            size: Size(
              container.maxHeight,
              container.maxHeight,
            ),
          );
        },
      );
    });
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double waveAmplitude;
  final double waveFrequency;
  final Color waveColor;

  WavePainter({
    required this.animationValue,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();

    final baseHeight = size.height / 3;

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = waveAmplitude *
          sin((x / size.width * 2 * pi * waveFrequency) +
              (animationValue * 2 * pi));
      path.lineTo(x, baseHeight + y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
