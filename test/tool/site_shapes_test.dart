import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/shapes/shapes.dart';

const _header =
    "// Material's shape morphs as cubic pairs in a unit square, written by\n"
    '// flutter test --update-goldens test/tool/site_shapes_test.dart\n';

final _file = File('site/assets/shapes.js');

typedef _Corner = (Point, CornerRounding);

// Compose's `customPolygon` in androidx.compose.material3.MaterialShapes,
// which prism_ui keeps private.
RoundedPolygon _custom(
  List<_Corner> corners,
  int reps, {
  bool mirroring = false,
}) {
  const center = Point(0.5, 0.5);
  final points = <_Corner>[];
  if (mirroring) {
    final angles = [for (final (p, _) in corners) (p - center).angleRadians];
    final distances = [
      for (final (p, _) in corners) (p - center).getDistance(),
    ];
    final section = math.pi * 2 / (reps * 2);
    for (var r = 0; r < reps * 2; r++) {
      for (var index = 0; index < corners.length; index++) {
        final i = r.isEven ? index : corners.length - 1 - index;
        if (i == 0 && r.isOdd) continue;
        final a =
            section * r +
            (r.isEven ? angles[i] : section - angles[i] + 2 * angles[0]);
        points.add((
          Point(math.cos(a), math.sin(a)) * distances[i] + center,
          corners[i].$2,
        ));
      }
    }
  } else {
    for (var i = 0; i < corners.length * reps; i++) {
      final (point, rounding) = corners[i % corners.length];
      points.add((
        point.rotate((i ~/ corners.length) * 360 / reps, center: center),
        rounding,
      ));
    }
  }
  return RoundedPolygon.fromVertices(
    [
      for (final (p, _) in points) ...[p.x, p.y],
    ],
    perVertexRounding: [for (final (_, r) in points) r],
    centerX: center.x,
    centerY: center.y,
  ).normalized();
}

_Corner _at(double x, double y, [double radius = 0]) =>
    (Point(x, y), CornerRounding(radius: radius));

// The values of the same shapes in Compose's MaterialShapes.
final _cycle = [
  RoundedPolygon.star(
    numVerticesPerRadius: 8,
    innerRadius: 0.8,
    rounding: const CornerRounding(radius: 0.15),
  ).normalized(),
  _custom([_at(0.5, 0.036), _at(0.758, -0.101, 0.209)], 8),
  _custom([_at(0.193, 0.277, 0.053), _at(0.176, 0.055, 0.053)], 10),
  _custom(
    [_at(0.370, 0.187), _at(0.416, 0.049, 0.381), _at(0.479, 0.001, 0.095)],
    8,
    mirroring: true,
  ),
  _custom([_at(1.237, 1.236, 0.258), _at(0.5, 0.918, 0.233)], 4),
  _custom([_at(0.5, -0.006, 0.006), _at(0.592, 0.158, 0.006)], 12),
  MaterialShapes.cookie12Sided,
  MaterialShapes.clover4Leaf,
  _custom([_at(0.5, 1.080, 0.085), _at(0.358, 0.843, 0.085)], 8),
  MaterialShapes.cookie6Sided,
];

final _morphs = {
  // The start button's morph, `_startMorph` in
  // lib/views/dashboard/widgets/current_outbound.dart.
  'start': [Morph(MaterialShapes.circle, MaterialShapes.cookie9Sided)],
  'enter': [Morph(MaterialShapes.cookie9Sided, _cycle.first)],
  'cycle': [
    for (var i = 0; i < _cycle.length; i++)
      Morph(_cycle[i], _cycle[(i + 1) % _cycle.length]),
  ],
};

String _number(double value) {
  final text = value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  return text == '-0' ? '0' : text;
}

String _morph(Morph morph, String indent) {
  final from = morph.asCubics(0);
  final to = morph.asCubics(1);
  return [
    for (var i = 0; i < from.length; i++)
      '$indent[${[...from[i].points, ...to[i].points].map(_number).join(',')}],',
  ].join('\n');
}

String _script() {
  final out = StringBuffer('${_header}globalThis.FlClashShapes = {\n');
  for (final MapEntry(:key, :value) in _morphs.entries) {
    if (key != 'cycle') {
      out.write('  $key: [\n${_morph(value.single, '    ')}\n  ],\n');
      continue;
    }
    out.write('  $key: [\n');
    for (final morph in value) {
      out.write('    [\n${_morph(morph, '      ')}\n    ],\n');
    }
    out.write('  ],\n');
  }
  out.write('};\n');
  return out.toString();
}

void main() {
  test('the site shapes are the app morphs', () {
    final expected = _script();
    final actual = _file.existsSync() ? _file.readAsStringSync() : '';
    if (autoUpdateGoldenFiles && actual != expected) {
      _file.writeAsStringSync(expected);
      return;
    }
    expect(actual, expected);
  });
}
