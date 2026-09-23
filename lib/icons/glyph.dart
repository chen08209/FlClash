import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:path_parsing/path_parsing.dart';

enum GlyphRole { body, detail, line }

class Glyph {
  const Glyph(this.shapes, {this.matchTextDirection = false});

  final List<GlyphShape> shapes;
  final bool matchTextDirection;

  static const size = 24.0;
  static const strokeWidth = 1.8;
}

sealed class GlyphShape {
  const GlyphShape({this.role = GlyphRole.body, this.solid = false});

  final GlyphRole role;
  final bool solid;

  Path get path;
}

class GlyphBox extends GlyphShape {
  const GlyphBox(
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.radius, {
    super.role,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double radius;

  @override
  Path get path => Path()
    ..addRSuperellipse(
      RSuperellipse.fromLTRBR(
        left,
        top,
        right,
        bottom,
        Radius.circular(radius),
      ),
    );
}

class GlyphCircle extends GlyphShape {
  const GlyphCircle(this.x, this.y, this.radius, {super.role, super.solid});

  final double x;
  final double y;
  final double radius;

  @override
  Path get path =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
}

class GlyphOval extends GlyphShape {
  const GlyphOval(this.left, this.top, this.right, this.bottom, {super.role});

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Path get path => Path()..addOval(Rect.fromLTRB(left, top, right, bottom));
}

class GlyphArc extends GlyphShape {
  const GlyphArc(
    this.x,
    this.y,
    this.radius,
    this.start,
    this.sweep, {
    super.role,
  });

  final double x;
  final double y;
  final double radius;
  final double start;
  final double sweep;

  @override
  Path get path => Path()
    ..addArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius),
      start,
      sweep,
    );
}

/// Joins two circles of [radius] with a line whose round caps end on their
/// strokes, so a cap never pokes into a hollow node.
class GlyphLink extends GlyphShape {
  const GlyphLink(this.from, this.to, this.radius)
    : super(role: GlyphRole.line);

  final Offset from;
  final Offset to;
  final double radius;

  @override
  Path get path {
    final delta = to - from;
    final inset = delta / delta.distance * (radius + Glyph.strokeWidth);
    final start = from + inset;
    final end = to - inset;
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }
}

/// SVG path data on the glyph grid, for curves the other shapes cannot draw.
/// Like them it traces the center of the stroke, not an outline to fill.
class GlyphPath extends GlyphShape {
  const GlyphPath(this.data, {super.role, super.solid});

  final String data;

  static final _parsed = Expando<Path>();

  @override
  Path get path => _parsed[this] ??= _parse(data);

  static Path _parse(String data) {
    final writer = _PathWriter();
    writeSvgPathDataToPath(data, writer);
    return writer.path;
  }
}

class _PathWriter implements PathProxy {
  final path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

class GlyphVertex {
  const GlyphVertex(this.x, this.y, [this.radius = 0]);

  final double x;
  final double y;
  final double radius;

  Offset get offset => Offset(x, y);
}

class GlyphPolyline extends GlyphShape {
  const GlyphPolyline(this.vertices, {this.closed = false, super.role});

  final List<GlyphVertex> vertices;
  final bool closed;

  (Offset, Offset) _corner(int index) {
    final count = vertices.length;
    final vertex = vertices[index].offset;
    final previous = vertices[(index - 1 + count) % count].offset;
    final next = vertices[(index + 1) % count].offset;
    final toPrevious = previous - vertex;
    final toNext = next - vertex;
    final radius = vertices[index].radius;
    return (
      vertex +
          toPrevious /
              toPrevious.distance *
              math.min(radius, toPrevious.distance / 2),
      vertex + toNext / toNext.distance * math.min(radius, toNext.distance / 2),
    );
  }

  @override
  Path get path {
    final path = Path();
    final count = vertices.length;
    final first = closed ? _corner(0).$2 : vertices.first.offset;
    path.moveTo(first.dx, first.dy);
    final last = closed ? count : count - 1;
    for (var index = 1; index <= last; index++) {
      final vertex = vertices[index % count];
      if (!closed && index == count - 1) {
        path.lineTo(vertex.x, vertex.y);
        break;
      }
      final (enter, exit) = _corner(index % count);
      path
        ..lineTo(enter.dx, enter.dy)
        ..quadraticBezierTo(vertex.x, vertex.y, exit.dx, exit.dy);
    }
    if (closed) {
      path.close();
    }
    return path;
  }
}
