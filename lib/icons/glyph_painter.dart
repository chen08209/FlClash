import 'dart:ui' show lerpDouble;

import 'package:fl_clash/icons/glyph.dart';
import 'package:material_ui/material_ui.dart';

const _grid = Rect.fromLTWH(0, 0, Glyph.size, Glyph.size);
const _fillStart = Glyph.strokeWidth / 2;

// Details thin away before this point and return as cutouts after it, so a
// detail never shows as a stroke and a cutout at once.
const _detailSwap = 0.5;

// Lines have nothing to fill, so they gain weight instead and hold their own
// beside filled bodies.
const _filledLineWidth = 2.2;

class GlyphPainter extends CustomPainter {
  const GlyphPainter({
    required this.glyph,
    required this.fill,
    required this.color,
  });

  final Glyph glyph;
  final double fill;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final opaque = color.withValues(alpha: 1);
    final stroke = _stroke(opaque, Glyph.strokeWidth);
    final line = _stroke(
      opaque,
      lerpDouble(Glyph.strokeWidth, _filledLineWidth, fill.clamp(0, 1))!,
    );
    final area = Paint()..color = opaque;
    Paint paintFor(GlyphShape shape) => shape.solid
        ? area
        : shape.role == GlyphRole.line
        ? line
        : stroke;

    final cut = fill > _detailSwap;
    final detailScale = cut
        ? (fill - _detailSwap) / (1 - _detailSwap)
        : 1 - fill / _detailSwap;
    canvas.save();
    canvas.scale(size.shortestSide / Glyph.size);
    // Opaque strokes under one alpha keep a translucent color even on overlaps,
    // and cutouts clear only the glyph's own layer.
    if (color.a < 1 || (cut && detailScale > 0)) {
      canvas.saveLayer(
        _grid,
        Paint()..color = Color.fromRGBO(0, 0, 0, color.a),
      );
    } else {
      canvas.save();
    }
    for (final shape in glyph.shapes) {
      if (shape.role == GlyphRole.body) {
        _paintFill(canvas, shape.path, opaque);
      }
    }
    if (detailScale > 0) {
      for (final shape in glyph.shapes) {
        if (shape.role == GlyphRole.detail) {
          _paintDetail(canvas, shape, opaque, detailScale, cut: cut);
        }
      }
    }
    for (final shape in glyph.shapes) {
      if (shape.role != GlyphRole.detail) {
        canvas.drawPath(shape.path, paintFor(shape));
      }
    }
    canvas.restore();
    canvas.restore();
  }

  void _paintFill(Canvas canvas, Path body, Color color) {
    if (fill <= 0) {
      return;
    }
    if (fill >= 1) {
      canvas.drawPath(body, Paint()..color = color);
      return;
    }
    final depth = body.getBounds().shortestSide / 2;
    final reach = _fillStart + (depth - _fillStart) * fill;
    canvas.save();
    canvas.clipPath(body);
    canvas.drawPath(body, _stroke(color, reach * 2));
    canvas.restore();
  }

  void _paintDetail(
    Canvas canvas,
    GlyphShape detail,
    Color color,
    double scale, {
    required bool cut,
  }) {
    final blendMode = cut ? BlendMode.clear : BlendMode.srcOver;
    if (!detail.solid) {
      canvas.drawPath(
        detail.path,
        _stroke(color, Glyph.strokeWidth * scale)..blendMode = blendMode,
      );
      return;
    }
    final center = detail.path.getBounds().center;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(
      detail.path,
      Paint()
        ..color = color
        ..blendMode = blendMode,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter oldDelegate) =>
      glyph != oldDelegate.glyph ||
      fill != oldDelegate.fill ||
      color != oldDelegate.color;
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
