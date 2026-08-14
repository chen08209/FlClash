import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

enum LoadingIndicatorM3EVariant { defaultStyle, contained }

class CommonCircleLoading extends StatefulWidget {
  static const double defaultDimension = 48;

  final LoadingIndicatorM3EVariant variant;
  final Color? color;
  final Color? containerColor;
  final List<StarBorder>? polygons;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final String? semanticValue;

  const CommonCircleLoading({
    super.key,
    this.variant = LoadingIndicatorM3EVariant.defaultStyle,
    this.color,
    this.containerColor,
    this.polygons,
    this.constraints,
    this.padding,
    this.semanticLabel,
    this.semanticValue,
  }) : assert(polygons == null || polygons.length > 1);

  @override
  State<CommonCircleLoading> createState() => _CommonCircleLoadingState();
}

class _CommonCircleLoadingState extends State<CommonCircleLoading>
    with TickerProviderStateMixin {
  static const _globalRotationDuration = Duration(milliseconds: 4666);
  static const _morphInterval = Duration(milliseconds: 650);
  static const _fullRotation = 360.0;
  static const _quarterRotation = _fullRotation / 4;
  static const _activeIndicatorScale = 38 / 48;
  static const _defaultConstraints = BoxConstraints.tightFor(
    width: CommonCircleLoading.defaultDimension,
    height: CommonCircleLoading.defaultDimension,
  );

  static const List<_ShapeSpec> _defaultShapeSequence = [
    // Soft burst.
    _ShapeSpec(
      points: 10,
      innerRadiusRatio: 0.78,
      pointRounding: 0.55,
      valleyRounding: 0.35,
    ),
    // Nine-sided cookie.
    _ShapeSpec(
      points: 9,
      innerRadiusRatio: 0.86,
      pointRounding: 0.62,
      valleyRounding: 0.28,
    ),
    // Pentagon.
    _ShapeSpec(points: 5, innerRadiusRatio: 0.81, pointRounding: 0.25),
    // Horizontal pill.
    _ShapeSpec(
      points: 2,
      innerRadiusRatio: 1,
      pointRounding: 0.5,
      valleyRounding: 0.5,
      widthScale: 0.95,
      heightScale: 0.52,
      squash: 1,
    ),
    // Sunny.
    _ShapeSpec(
      points: 8,
      innerRadiusRatio: 0.58,
      pointRounding: 0.52,
      valleyRounding: 0.18,
    ),
    // Four-sided cookie.
    _ShapeSpec(
      points: 4,
      innerRadiusRatio: 0.78,
      pointRounding: 0.62,
      valleyRounding: 0.28,
    ),
    // Vertical oval.
    _ShapeSpec(
      points: 2,
      innerRadiusRatio: 1,
      pointRounding: 0.5,
      valleyRounding: 0.5,
      widthScale: 0.62,
      heightScale: 0.95,
      squash: 1,
    ),
  ];

  final SpringSimulation _morphAnimation = SpringSimulation(
    SpringDescription.withDampingRatio(mass: 1, stiffness: 200, ratio: 0.6),
    0,
    1,
    5,
    snapToEnd: true,
  );

  late final AnimationController _morphController;
  late final AnimationController _globalRotationController;
  late final Listenable _animation;

  var _currentMorphIndex = 0;
  var _morphRotationTargetAngle = _quarterRotation;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController.unbounded(vsync: this);
    _globalRotationController = AnimationController(
      duration: _globalRotationDuration,
      vsync: this,
    )..repeat();
    _animation = Listenable.merge([
      _morphController,
      _globalRotationController,
    ]);
    unawaited(_runMorphLoop());
  }

  @override
  void dispose() {
    _morphController.dispose();
    _globalRotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommonCircleLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.polygons != oldWidget.polygons &&
        _currentMorphIndex >= _shapeCount) {
      _currentMorphIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = switch (widget.variant) {
      LoadingIndicatorM3EVariant.defaultStyle =>
        widget.color ?? colorScheme.primary,
      LoadingIndicatorM3EVariant.contained =>
        widget.color ?? colorScheme.onPrimaryContainer,
    };
    final backgroundColor = switch (widget.variant) {
      LoadingIndicatorM3EVariant.defaultStyle =>
        widget.containerColor ?? Colors.transparent,
      LoadingIndicatorM3EVariant.contained =>
        widget.containerColor ?? colorScheme.primaryContainer,
    };
    final shapeSequence =
        widget.polygons
            ?.map(_ShapeSpec.fromStarBorder)
            .toList(growable: false) ??
        _defaultShapeSequence;
    final padding = (widget.padding ?? EdgeInsets.zero).resolve(
      Directionality.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorConstraints = constraints.deflate(padding);
        final dimension = _resolveDimension(
          indicatorConstraints,
          widget.constraints ?? _defaultConstraints,
        );
        final currentMorphIndex = _currentMorphIndex % shapeSequence.length;
        return Align(
          widthFactor: 1,
          heightFactor: 1,
          child: Semantics(
            label: widget.semanticLabel,
            value: widget.semanticValue,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: padding,
                child: RepaintBoundary(
                  child: SizedBox.square(
                    dimension: dimension,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final morphProgress = _morphController.value.clamp(
                          0.0,
                          1.0,
                        );
                        final rotationDegrees =
                            morphProgress * _quarterRotation +
                            _morphRotationTargetAngle +
                            _globalRotationController.value * _fullRotation;
                        final shape = _ShapeSpec.lerp(
                          shapeSequence[currentMorphIndex],
                          shapeSequence[(currentMorphIndex + 1) %
                              shapeSequence.length],
                          morphProgress,
                        );
                        return Transform.rotate(
                          angle: rotationDegrees * math.pi / 180,
                          child: CustomPaint(
                            painter: _ShapePainter(
                              shape: shape,
                              color: activeColor,
                              scaleFactor: _activeIndicatorScale,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int get _shapeCount =>
      widget.polygons?.length ?? _defaultShapeSequence.length;

  double _resolveDimension(
    BoxConstraints parentConstraints,
    BoxConstraints preferredConstraints,
  ) {
    final effectiveConstraints = preferredConstraints.enforce(
      BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
    );
    final maxWidth = effectiveConstraints.maxWidth;
    final maxHeight = effectiveConstraints.maxHeight;

    if (maxWidth.isFinite && maxHeight.isFinite) {
      return maxWidth < maxHeight ? maxWidth : maxHeight;
    }

    if (maxWidth.isFinite) {
      return maxWidth;
    }

    if (maxHeight.isFinite) {
      return maxHeight;
    }

    return CommonCircleLoading.defaultDimension;
  }

  Future<void> _runMorphLoop() async {
    while (mounted) {
      final startedAt = DateTime.now();
      try {
        await _morphController.animateWith(_morphAnimation).orCancel;
      } on TickerCanceled {
        return;
      }

      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < _morphInterval) {
        await Future<void>.delayed(_morphInterval - elapsed);
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _currentMorphIndex = (_currentMorphIndex + 1) % _shapeCount;
        _morphRotationTargetAngle =
            (_morphRotationTargetAngle + _quarterRotation) % _fullRotation;
        _morphController.value = 0;
      });
    }
  }
}

class _ShapeSpec {
  final double points;
  final double innerRadiusRatio;
  final double pointRounding;
  final double valleyRounding;
  final double widthScale;
  final double heightScale;
  final double squash;

  const _ShapeSpec({
    required this.points,
    required this.innerRadiusRatio,
    required this.pointRounding,
    this.valleyRounding = 0,
    this.widthScale = 1,
    this.heightScale = 1,
    this.squash = 0,
  });

  static _ShapeSpec lerp(_ShapeSpec begin, _ShapeSpec end, double progress) {
    return _ShapeSpec(
      points: _lerp(begin.points, end.points, progress),
      innerRadiusRatio: _lerp(
        begin.innerRadiusRatio,
        end.innerRadiusRatio,
        progress,
      ),
      pointRounding: _lerp(begin.pointRounding, end.pointRounding, progress),
      valleyRounding: _lerp(begin.valleyRounding, end.valleyRounding, progress),
      widthScale: _lerp(begin.widthScale, end.widthScale, progress),
      heightScale: _lerp(begin.heightScale, end.heightScale, progress),
      squash: _lerp(begin.squash, end.squash, progress),
    );
  }

  static _ShapeSpec fromStarBorder(StarBorder border) {
    return _ShapeSpec(
      points: border.points,
      innerRadiusRatio: border.innerRadiusRatio,
      pointRounding: border.pointRounding,
      valleyRounding: border.valleyRounding,
      squash: border.squash,
    );
  }

  static double _lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  @override
  bool operator ==(Object other) {
    return other is _ShapeSpec &&
        other.points == points &&
        other.innerRadiusRatio == innerRadiusRatio &&
        other.pointRounding == pointRounding &&
        other.valleyRounding == valleyRounding &&
        other.widthScale == widthScale &&
        other.heightScale == heightScale &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(
    points,
    innerRadiusRatio,
    pointRounding,
    valleyRounding,
    widthScale,
    heightScale,
    squash,
  );
}

class _ShapePainter extends CustomPainter {
  final _ShapeSpec shape;
  final Color color;
  final double scaleFactor;
  final Paint _paint;

  _ShapePainter({
    required this.shape,
    required this.color,
    required this.scaleFactor,
  }) : _paint = Paint()
         ..style = PaintingStyle.fill
         ..isAntiAlias = true
         ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * scaleFactor * shape.widthScale,
      height: size.height * scaleFactor * shape.heightScale,
    );
    final border = StarBorder(
      points: shape.points,
      innerRadiusRatio: shape.innerRadiusRatio,
      pointRounding: shape.pointRounding,
      valleyRounding: shape.valleyRounding,
      squash: shape.squash,
    );
    canvas.drawPath(border.getOuterPath(rect), _paint);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
