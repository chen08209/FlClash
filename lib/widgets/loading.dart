import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/shape.dart';
import 'package:flutter/foundation.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';

enum LoadingIndicatorM3EVariant { defaultStyle, contained }

class CommonCircleLoading extends StatefulWidget {
  static const double defaultDimension = 48;

  final LoadingIndicatorM3EVariant variant;
  final Color? color;
  final Color? containerColor;
  final List<RoundedPolygon>? polygons;
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

  static final List<RoundedPolygon> _defaultShapeSequence = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
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

  List<RoundedPolygon>? _cachedPolygons;
  List<Morph>? _cachedMorphs;

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
    final shapeSequence = widget.polygons ?? _defaultShapeSequence;
    final morphs = _morphsFor(shapeSequence);
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
                borderRadius: AppRadius.full,
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
                        return Transform.rotate(
                          angle: rotationDegrees * math.pi / 180,
                          child: CustomPaint(
                            painter: _MorphPainter(
                              morph: morphs[currentMorphIndex],
                              progress: morphProgress,
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

  List<Morph> _morphsFor(List<RoundedPolygon> polygons) {
    final cachedMorphs = _cachedMorphs;
    if (cachedMorphs != null && listEquals(_cachedPolygons, polygons)) {
      return cachedMorphs;
    }
    _cachedPolygons = polygons;
    return _cachedMorphs = [
      for (var i = 0; i < polygons.length; i++)
        Morph(polygons[i], polygons[(i + 1) % polygons.length]),
    ];
  }

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

class _MorphPainter extends CustomPainter {
  final Morph morph;
  final double progress;
  final Color color;
  final double scaleFactor;
  final Paint _paint;

  _MorphPainter({
    required this.morph,
    required this.progress,
    required this.color,
    required this.scaleFactor,
  }) : _paint = Paint()
         ..style = PaintingStyle.fill
         ..isAntiAlias = true
         ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width * scaleFactor;
    final offset = (size.width - scale) / 2;
    canvas.save();
    canvas.translate(offset, offset);
    canvas.scale(scale);
    canvas.drawPath(morph.toPath(progress: progress), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MorphPainter oldDelegate) {
    return oldDelegate.morph != morph ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
