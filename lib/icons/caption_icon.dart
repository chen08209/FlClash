import 'dart:ui' show ClipOp;

import 'package:material_ui/material_ui.dart';

/// Windows 11 renders every caption glyph as a 10x10 Segoe Fluent icon.
const captionGlyphSize = 10.0;

enum CaptionGlyph { minimize, maximize, restore, close }

class CaptionIcon extends StatelessWidget {
  const CaptionIcon(this.glyph, {super.key});

  final CaptionGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      size: const Size.square(captionGlyphSize),
      painter: _CaptionGlyphPainter(glyph: glyph, color: color),
    );
  }
}

class _CaptionGlyphPainter extends CustomPainter {
  const _CaptionGlyphPainter({required this.glyph, required this.color});

  final CaptionGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;
    const corner = Radius.circular(1);
    // Every coordinate sits on a half pixel so a one pixel stroke covers a
    // single device pixel at 100% scaling.
    final box = (Offset.zero & size).deflate(0.5);
    switch (glyph) {
      case CaptionGlyph.minimize:
        final y = (size.height / 2).floorToDouble() + 0.5;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      case CaptionGlyph.maximize:
        canvas.drawRSuperellipse(
          RSuperellipse.fromRectAndRadius(box, corner),
          paint,
        );
      case CaptionGlyph.restore:
        const offset = 2.0;
        final front = Rect.fromLTRB(
          box.left,
          box.top + offset,
          box.right - offset,
          box.bottom,
        );
        final back = front.shift(const Offset(offset, -offset));
        canvas.drawRSuperellipse(
          RSuperellipse.fromRectAndRadius(front, corner),
          paint,
        );
        canvas.save();
        canvas.clipRect(front.inflate(0.5), clipOp: ClipOp.difference);
        canvas.drawRSuperellipse(
          RSuperellipse.fromRectAndRadius(back, corner),
          paint,
        );
        canvas.restore();
      case CaptionGlyph.close:
        paint.strokeCap = StrokeCap.round;
        canvas.drawLine(box.topLeft, box.bottomRight, paint);
        canvas.drawLine(box.topRight, box.bottomLeft, paint);
    }
  }

  @override
  bool shouldRepaint(_CaptionGlyphPainter oldDelegate) =>
      glyph != oldDelegate.glyph || color != oldDelegate.color;
}
