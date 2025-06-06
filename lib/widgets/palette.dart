import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@immutable
class Palette extends StatefulWidget {
  const Palette({
    super.key,
    required this.controller,
  });

  final ValueNotifier<Color> controller;

  @override
  State<Palette> createState() => _PaletteState();
}

class _PaletteState extends State<Palette> {
  final double _thickness = 20;
  final double _radius = 4;
  final double _padding = 8;
  final GlobalKey renderBoxKey = GlobalKey();
  bool isSquare = false;
  bool isTrack = false;
  late double colorHue;
  late double colorSaturation;
  late double colorValue;

  late FocusNode _focusNode;

  Color get value => widget.controller.value;

  HSVColor get color => HSVColor.fromColor(value);

  @override
  void initState() {
    super.initState();
    colorHue = color.hue;
    colorSaturation = color.saturation;
    colorValue = color.value;
    _focusNode = FocusNode();
  }

  void _handleChange() {
    widget.controller.value = HSVColor.fromAHSV(
      color.alpha,
      colorHue,
      colorSaturation,
      colorValue,
    ).toColor();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  double trackRadius(Size size) =>
      math.min(size.width, size.height) / 2 - _thickness;

  static double squareRadius(double radius, double trackSquarePadding) =>
      (radius - trackSquarePadding) / math.sqrt(2);

  void onStart(Offset offset) {
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final radius = trackRadius(size);
    final radiusOuter = radius + _thickness;
    final effectiveSquareRadius = squareRadius(radius, _padding);
    final startPosition = renderBox.localToGlobal(Offset.zero);
    final center = Offset(size.width / 2, size.height / 2);
    final vector = offset - startPosition - center;
    final vectorLength = _Computer.vectorLength(vector);
    isSquare = vector.dx.abs() < effectiveSquareRadius &&
        vector.dy.abs() < effectiveSquareRadius;
    isTrack = vectorLength >= radius && vectorLength <= radiusOuter;
    if (isSquare) {
      colorSaturation =
          _Computer.vectorToSaturation(vector.dx, effectiveSquareRadius)
              .clamp(0.0, 1.0);
      colorValue = _Computer.vectorToValue(vector.dy, effectiveSquareRadius)
          .clamp(0.0, 1.0);
      _handleChange();
    } else if (isTrack) {
      colorHue = _Computer.vectorToHue(vector);
      _handleChange();
    } else {
      isTrack = false;
      isSquare = false;
    }
  }

  void onUpdate(Offset offset) {
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final radius = trackRadius(size);
    final effectiveSquareRadius = squareRadius(radius, _padding);
    final startPosition = renderBox.localToGlobal(Offset.zero);
    final center = Offset(size.width / 2, size.height / 2);
    final vector = offset - startPosition - center;
    if (isSquare) {
      isTrack = false;
      colorSaturation =
          _Computer.vectorToSaturation(vector.dx, effectiveSquareRadius)
              .clamp(0.0, 1.0);
      colorValue = _Computer.vectorToValue(vector.dy, effectiveSquareRadius)
          .clamp(0.0, 1.0);

      _handleChange();
    } else if (isTrack) {
      isSquare = false;
      colorHue = _Computer.vectorToHue(vector);
      _handleChange();
    } else {
      isTrack = false;
      isSquare = false;
    }
  }

  void onEnd() {
    isTrack = false;
    isSquare = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, __, ___) {
        return GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onVerticalDragDown: (DragDownDetails details) =>
              onStart(details.globalPosition),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              onUpdate(details.globalPosition),
          onHorizontalDragUpdate: (DragUpdateDetails details) =>
              onUpdate(details.globalPosition),
          onVerticalDragEnd: (DragEndDetails details) => onEnd(),
          onHorizontalDragEnd: (DragEndDetails details) => onEnd(),
          onTapUp: (TapUpDetails details) => onEnd(),
          child: SizedBox(
            key: renderBoxKey,
            child: Focus(
              focusNode: _focusNode,
              child: MouseRegion(
                cursor: WidgetStateMouseCursor.clickable,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _ShadePainter(
                          colorHue: colorHue,
                          colorSaturation: colorSaturation,
                          colorValue: colorValue,
                          thickness: _thickness,
                          padding: _padding,
                          trackBorderRadius: _radius,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _ShadeThumbPainter(
                        colorSaturation: colorSaturation,
                        colorValue: colorValue,
                        thickness: _thickness,
                        padding: _padding,
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _TrackPainter(
                          thickness: _thickness,
                          ticks: 360,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _TrackThumbPainter(
                        colorHue: colorHue,
                        thickness: _thickness,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShadePainter extends CustomPainter {
  const _ShadePainter({
    required this.colorHue,
    required this.colorSaturation,
    required this.colorValue,
    required this.thickness,
    required this.padding,
    required this.trackBorderRadius,
  }) : super();

  final double colorHue;
  final double colorSaturation;
  final double colorValue;

  final double thickness;
  final double padding;
  final double trackBorderRadius;

  static double trackRadius(Size size, double trackWidth) =>
      math.min(size.width, size.height) / 2 - trackWidth / 2;

  static double squareRadius(
          double radius, double trackWidth, double padding) =>
      (radius - trackWidth / 2 - padding) / math.sqrt(2);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = trackRadius(size, thickness);
    final double effectiveSquareRadius = squareRadius(
      radius,
      thickness,
      padding,
    );

    final Rect rectBox = Rect.fromLTWH(
        center.dx - effectiveSquareRadius,
        center.dy - effectiveSquareRadius,
        effectiveSquareRadius * 2,
        effectiveSquareRadius * 2);
    final RRect rRect = RRect.fromRectAndRadius(
      rectBox,
      Radius.circular(trackBorderRadius),
    );

    final Shader horizontal = LinearGradient(
      colors: <Color>[
        Colors.white,
        HSVColor.fromAHSV(1, colorHue, 1, 1).toColor()
      ],
    ).createShader(rectBox);
    canvas.drawRRect(
        rRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = horizontal);

    final Shader vertical = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Colors.transparent, Colors.black],
    ).createShader(rectBox);
    canvas.drawRRect(
        rRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = vertical);
  }

  @override
  bool shouldRepaint(_ShadePainter oldDelegate) {
    return oldDelegate.thickness != thickness ||
        oldDelegate.padding != padding ||
        oldDelegate.trackBorderRadius != trackBorderRadius ||
        oldDelegate.colorHue != colorHue ||
        oldDelegate.colorSaturation != colorSaturation ||
        oldDelegate.colorValue != colorValue;
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    this.ticks = 360,
    required this.thickness,
  }) : super();
  final int ticks;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    const double rads = (2 * math.pi) / 360;
    const double step = 1;
    const double aliasing = 0.5;

    final double shortestRectSide = math.min(size.width, size.height);

    final Rect rectCircle = Rect.fromCenter(
      center: center,
      width: shortestRectSide - thickness,
      height: shortestRectSide - thickness,
    );

    for (int i = 0; i < ticks; i++) {
      final double sRad = (i - aliasing) * rads;
      final double eRad = (i + step) * rads;
      final Paint segmentPaint = Paint()
        ..color = HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawArc(
        rectCircle,
        sRad,
        sRad - eRad,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) {
    return oldDelegate.thickness != thickness || oldDelegate.ticks != ticks;
  }
}

class _ShadeThumbPainter extends CustomPainter {
  const _ShadeThumbPainter({
    required this.colorSaturation,
    required this.colorValue,
    required this.thickness,
    required this.padding,
  }) : super();

  final double colorSaturation;
  final double colorValue;
  final double thickness;
  final double padding;

  static double trackRadius(Size size, double thickness) =>
      math.min(size.width, size.height) / 2 - thickness / 2;

  static double squareRadius(
          double radius, double thickness, double trackSquarePadding) =>
      (radius - thickness / 2 - trackSquarePadding) / math.sqrt(2);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = trackRadius(size, thickness);
    final double effectiveSquareRadius =
        squareRadius(radius, thickness, padding);

    final Paint paintBlack = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final Paint paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final double paletteX = _Computer.saturationToVector(
        colorSaturation, effectiveSquareRadius, center.dx);
    final double paletteY =
        _Computer.valueToVector(colorValue, effectiveSquareRadius, center.dy);
    final Offset paletteVector = Offset(paletteX, paletteY);
    canvas.drawCircle(paletteVector, 12, paintBlack);
    canvas.drawCircle(paletteVector, 12, paintWhite);
  }

  @override
  bool shouldRepaint(_ShadeThumbPainter oldDelegate) {
    return oldDelegate.thickness != thickness ||
        oldDelegate.colorSaturation != colorSaturation ||
        oldDelegate.colorValue != colorValue ||
        oldDelegate.padding != padding;
  }
}

class _TrackThumbPainter extends CustomPainter {
  const _TrackThumbPainter({
    required this.colorHue,
    required this.thickness,
  }) : super();

  final double colorHue;
  final double thickness;

  static double trackRadius(Size size, double thickness) =>
      math.min(size.width, size.height) / 2 - thickness / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = trackRadius(size, thickness);
    final Paint paintBlack = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final Paint paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final Offset track = _Computer.hueToVector(
      (colorHue + 360.0) * math.pi / 180.0,
      radius,
      center,
    );
    canvas.drawCircle(track, thickness / 2 + 4, paintBlack);
    canvas.drawCircle(track, thickness / 2 + 4, paintWhite);
  }

  @override
  bool shouldRepaint(_TrackThumbPainter oldDelegate) {
    return oldDelegate.thickness != thickness ||
        oldDelegate.colorHue != colorHue;
  }
}

class _Computer {
  static double vectorLength(Offset vector) =>
      math.sqrt(vector.dx * vector.dx + vector.dy * vector.dy);

  static double vectorToHue(Offset vector) =>
      (((math.atan2(vector.dy, vector.dx)) * 180.0 / math.pi) + 360.0) % 360.0;

  static double vectorToSaturation(double vectorX, double squareRadius) =>
      vectorX * 0.5 / squareRadius + 0.5;

  static double vectorToValue(double vectorY, double squareRadius) =>
      0.5 - vectorY * 0.5 / squareRadius;

  static Offset hueToVector(double h, double radius, Offset center) => Offset(
      math.cos(h) * radius + center.dx, math.sin(h) * radius + center.dy);

  static double saturationToVector(
          double s, double squareRadius, double centerX) =>
      (s - 0.5) * squareRadius / 0.5 + centerX;

  static double valueToVector(double l, double squareRadius, double centerY) =>
      (0.5 - l) * squareRadius / 0.5 + centerY;
}
