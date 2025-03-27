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
    return LayoutBuilder(builder: (_, constraints) {
      return RepaintBoundary(
        child: AnimatedBuilder(
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
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            );
          },
        ),
      );
    });
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double waveAmplitude;
  final double waveFrequency;
  final Color waveColor;

  late Paint _paint;
  final Path _path = Path();
  Color _lastColor;

  WavePainter({
    required this.animationValue,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.waveColor,
  }) : _lastColor = waveColor {
    _paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (waveColor != _lastColor) {
      _paint = Paint()
        ..color = waveColor
        ..style = PaintingStyle.fill;
      _lastColor = waveColor;
    }

    _path.reset();

    final baseHeight = size.height / 3;
    final phase = animationValue * 2 * pi;
    final widthFactor = 2 * pi * waveFrequency / size.width;

    _path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x += size.width / 20) {
      final y = waveAmplitude * sin(x * widthFactor + phase);
      _path.lineTo(x, baseHeight + y);
    }

    _path.lineTo(
      size.width,
      baseHeight + waveAmplitude * sin(size.width * widthFactor + phase),
    );

    _path.lineTo(size.width, size.height);
    _path.lineTo(0, size.height);
    _path.close();

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.waveFrequency != waveFrequency ||
        oldDelegate.waveColor != waveColor;
  }
}
