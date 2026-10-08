import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

enum SourceKind { remote, file, custom }

extension on SourceKind {
  Color tintOf(ColorScheme colorScheme) => switch (this) {
    SourceKind.remote => colorScheme.primary,
    SourceKind.file => colorScheme.tertiary,
    SourceKind.custom => colorScheme.secondary,
  };
}

/// The tile sits [inset] from the edge of an [AppCorner.xl] surface, so its
/// corner is concentric with the surface's.
const _sourceIconInset = 12.0;
const _sourceIconSize = 40.0;
final _sourceIconShape = AppShape.all(AppCorner.xl - _sourceIconInset);

class SourceIcon extends StatelessWidget {
  const SourceIcon({
    super.key,
    required this.kind,
    this.usage,
    this.tooltip,
    this.onPressed,
  });

  static const size = _sourceIconSize;
  static const inset = _sourceIconInset;

  final SourceKind kind;
  final double? usage;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final usage = this.usage;
    final icon = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: kind.tintOf(colorScheme).opacity15,
        shape: _sourceIconShape,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: usage ?? 0),
        duration: commonDuration,
        curve: Curves.easeOutCubic,
        builder: (_, level, _) => CustomPaint(
          painter: _SourceArtPainter(
            kind: kind,
            colorScheme: colorScheme,
            level: usage == null ? null : level,
          ),
        ),
      ),
    );
    if (onPressed == null) {
      return icon;
    }
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(size),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: _sourceIconShape,
      ),
      onPressed: onPressed,
      icon: icon,
    );
  }
}

class _SourceArtPainter extends CustomPainter {
  const _SourceArtPainter({
    required this.kind,
    required this.colorScheme,
    required this.level,
  });

  static const _waveAmplitude = 1.2;
  static const _cloudBounds = Rect.fromLTRB(5.5, 9.5, 34.5, 30);
  static final _cloud = _cloudPath(_cloudBounds);
  static const _badgeCenter = Offset(30.5, 27);
  static final _badgedCloud = Path.combine(
    PathOperation.difference,
    _cloud,
    Path()..addOval(Rect.fromCircle(center: _badgeCenter, radius: 7.4)),
  );

  final SourceKind kind;
  final ColorScheme colorScheme;
  final double? level;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _sourceIconSize);
    switch (kind) {
      case SourceKind.remote:
        _paintRemote(canvas);
      case SourceKind.file:
        _paintFile(canvas);
      case SourceKind.custom:
        _paintCustom(canvas);
    }
  }

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

  void _paintRemote(Canvas canvas) {
    final primary = colorScheme.primary;
    final tertiary = colorScheme.tertiary;
    final level = this.level;
    // A solid cloud is what a gauge with nothing used looks like.
    if (level == null) {
      canvas.drawPath(_badgedCloud, Paint()..color = primary);
      _paintGlyph(canvas, AppGlyphs.removeCircle, _badgeCenter, 14, tertiary);
      return;
    }
    canvas
      ..drawPath(_cloud, Paint()..color = primary.withValues(alpha: 0.32))
      ..save()
      ..clipPath(_cloud);
    _paintWater(canvas, _cloudBounds, 1 - level, primary);
    canvas.restore();
  }

  void _paintFile(Canvas canvas) {
    final tertiary = colorScheme.tertiary;
    final ink = Color.lerp(tertiary, colorScheme.onTertiary, 0.5)!;
    canvas
      ..save()
      ..translate(16.5, 20.5)
      ..rotate(-pi / 24)
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 14, height: 20.5),
          const Radius.circular(3.5),
        ),
        Paint()..color = colorScheme.secondary.withValues(alpha: 0.38),
      )
      ..restore();
    const page = Rect.fromLTRB(15, 8.5, 30, 31);
    const fold = 6.0;
    final corner = Path()
      ..moveTo(page.right - fold, page.top)
      ..lineTo(page.right, page.top)
      ..lineTo(page.right, page.top + fold)
      ..close();
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(page)
          ..addPath(corner, Offset.zero),
      )
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(page, const Radius.circular(3.5)),
        Paint()..color = tertiary,
      )
      ..restore()
      ..drawPath(
        Path()
          ..moveTo(page.right - fold, page.top)
          ..lineTo(page.right - fold, page.top + fold - 2)
          ..quadraticBezierTo(
            page.right - fold,
            page.top + fold,
            page.right - fold + 2,
            page.top + fold,
          )
          ..lineTo(page.right, page.top + fold)
          ..close(),
        Paint()..color = ink,
      );
    for (final (top, right) in const [(19.5, 26.5), (24.0, 23.5)]) {
      canvas.drawRSuperellipse(
        RSuperellipse.fromLTRBR(
          18.5,
          top,
          right,
          top + 2.2,
          const Radius.circular(1.1),
        ),
        Paint()..color = ink,
      );
    }
  }

  void _paintCustom(Canvas canvas) {
    const block = 11.5;
    const gap = 3.0;
    const start = (_sourceIconSize - block * 2 - gap) / 2;
    const end = start + block + gap;
    for (final (left, top, color) in [
      (start, start, colorScheme.primary),
      (start, end, colorScheme.tertiary),
      (end, end, colorScheme.secondary),
    ]) {
      canvas.drawRSuperellipse(
        RSuperellipse.fromLTRBR(
          left,
          top,
          left + block,
          top + block,
          const Radius.circular(3.5),
        ),
        Paint()..color = color,
      );
    }
    final plus = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const center = Offset(end + block / 2, start + block / 2);
    const arm = block / 2 - 1.5;
    canvas
      ..drawLine(center.translate(-arm, 0), center.translate(arm, 0), plus)
      ..drawLine(center.translate(0, -arm), center.translate(0, arm), plus);
  }

  void _paintGlyph(
    Canvas canvas,
    Glyph glyph,
    Offset center,
    double extent,
    Color color,
  ) {
    canvas
      ..save()
      ..translate(center.dx - extent / 2, center.dy - extent / 2);
    GlyphPainter(
      glyph: glyph,
      fill: 1,
      color: color,
    ).paint(canvas, Size.square(extent));
    canvas.restore();
  }

  void _paintWater(Canvas canvas, Rect bounds, double level, Color color) {
    final surface = bounds.bottom - bounds.height * level;
    final amplitude = _waveAmplitude * sin(pi * level);
    final quarter = bounds.width / 4;
    canvas.drawPath(
      Path()
        ..moveTo(bounds.left, surface)
        ..quadraticBezierTo(
          bounds.left + quarter,
          surface - amplitude * 2,
          bounds.left + quarter * 2,
          surface,
        )
        ..quadraticBezierTo(
          bounds.left + quarter * 3,
          surface + amplitude * 2,
          bounds.right,
          surface,
        )
        ..lineTo(bounds.right, bounds.bottom)
        ..lineTo(bounds.left, bounds.bottom)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SourceArtPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.level != level;
}
