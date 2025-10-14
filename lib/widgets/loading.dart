import 'package:flutter/material.dart';

class CommonCircleLoading extends StatefulWidget {
  final Color? color;

  const CommonCircleLoading({super.key, this.color});

  @override
  State<CommonCircleLoading> createState() => _CommonCircleLoadingState();
}

class _CommonCircleLoadingState extends State<CommonCircleLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pointsController;
  late Animation<double> _pointsAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pointsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pointsAnimation = Tween<double>(begin: 3.0, end: 9.0).animate(
      CurvedAnimation(parent: _pointsController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: RotationTransition(
        turns: _rotateController,
        child: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _pointsController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarPainter(
                  points: _pointsAnimation.value,
                  color: color,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double points;
  final Color color;
  final Paint _paint;

  _StarPainter({required this.points, required this.color})
    : _paint = Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final starBorder = StarBorder(
      points: points,
      innerRadiusRatio: 0.8,
      pointRounding: 0.5,
      valleyRounding: 0.1,
      squash: 0.5,
    );

    final path = starBorder.getOuterPath(rect);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
