import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

class SubscriptionUsageCloud extends StatelessWidget {
  const SubscriptionUsageCloud({super.key, required this.usage});

  final double usage;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: CustomPaint(
        painter: _UsageCloudPainter(
          remaining: 1 - usage.clamp(0.0, 1.0),
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class _UsageCloudPainter extends CustomPainter {
  const _UsageCloudPainter({required this.remaining, required this.color});

  static const _bounds = Rect.fromLTRB(5.5, 9.5, 34.5, 30);
  static final _cloud = _cloudPath(_bounds);

  final double remaining;
  final Color color;

  static Path _cloudPath(Rect bounds) {
    final width = bounds.width;
    final left = bounds.left;
    final bottom = bounds.bottom;
    final leftLobe = width * 0.25;
    final rightLobe = width * 0.21;
    final top = bounds.height - width * 0.33;
    return Path.combine(
      PathOperation.union,
      Path.combine(
        PathOperation.union,
        Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(left + leftLobe, bottom - leftLobe),
              radius: leftLobe,
            ),
          )
          ..addOval(
            Rect.fromCircle(
              center: Offset(left + width - rightLobe, bottom - rightLobe),
              radius: rightLobe,
            ),
          ),
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(left + width * 0.53, bounds.top + width * 0.33),
            radius: width * 0.33,
          ),
        ),
      ),
      Path()..addRect(
        Rect.fromLTRB(
          left + leftLobe,
          bottom - top,
          left + width - rightLobe,
          bottom,
        ),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final surface = _bounds.bottom - _bounds.height * remaining;
    final amplitude = 1.2 * math.sin(math.pi * remaining);
    final quarter = _bounds.width / 4;
    canvas
      ..save()
      ..scale(size.width / 40, size.height / 40)
      ..drawPath(_cloud, Paint()..color = color.withValues(alpha: 0.15))
      ..clipPath(_cloud)
      ..drawPath(
        Path()
          ..moveTo(_bounds.left, surface)
          ..quadraticBezierTo(
            _bounds.left + quarter,
            surface - amplitude * 2,
            _bounds.left + quarter * 2,
            surface,
          )
          ..quadraticBezierTo(
            _bounds.left + quarter * 3,
            surface + amplitude * 2,
            _bounds.right,
            surface,
          )
          ..lineTo(_bounds.right, _bounds.bottom)
          ..lineTo(_bounds.left, _bounds.bottom)
          ..close(),
        Paint()..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_UsageCloudPainter oldDelegate) =>
      oldDelegate.remaining != remaining || oldDelegate.color != color;
}
