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

  late final Paint _paint;
  late final Path _path;

  static const int _samplePoints = 40;
  static const double _twoPi = 2 * pi;

  WavePainter({
    required this.animationValue,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.waveColor,
  }) {
    _paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    _path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = waveColor;
    _path.reset();

    final baseHeight = size.height / 3;
    final phase = animationValue * _twoPi;
    final widthFactor = _twoPi * waveFrequency / size.width;
    final step = size.width / _samplePoints;

    _path.moveTo(0, baseHeight);

    for (var i = 0; i <= _samplePoints; i++) {
      final x = i * step;
      final y = waveAmplitude * sin(x * widthFactor + phase);
      _path.lineTo(x, baseHeight + y);
    }

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
