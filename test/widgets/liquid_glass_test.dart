import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('a profile reads how far an outline reaches each way', () {
    final box = liquidGlassProfile(
      Path()..addRect(const Rect.fromLTWH(0, 0, 40, 20)),
      const Offset(20, 10),
    );
    expect(box[0], moreOrLessEquals(20, epsilon: 1e-6));
    expect(box[16], moreOrLessEquals(10, epsilon: 1e-6));
    expect(box[32], moreOrLessEquals(20, epsilon: 1e-6));
    expect(box[48], moreOrLessEquals(10, epsilon: 1e-6));
    expect(box[8], moreOrLessEquals(10 * math.sqrt2, epsilon: 1e-6));

    final round = liquidGlassProfile(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 30)),
      Offset.zero,
    );
    expect(round, everyElement(moreOrLessEquals(30, epsilon: 0.05)));
  });

  test('corner curves lie on the superellipse the engine clips to', () {
    for (final (size, radius) in [
      (const Size(338, 62), 31.0),
      (const Size(84, 54), 27.0),
      (const Size(44, 44), 22.0),
      (const Size(270, 160), 34.0),
      (const Size(60, 200), 30.0),
    ]) {
      final corners = BorderRadius.circular(radius);
      final path = Path()
        ..addRSuperellipse(corners.toRSuperellipse(Offset.zero & size));
      final outline = [
        for (final metric in path.computeMetrics())
          for (var at = 0.0; at < metric.length; at += 0.02)
            metric.getTangentForOffset(at)!.position,
      ];
      double offPath(Offset point) =>
          outline.map((on) => (on - point).distance).reduce(math.min);

      final curves = liquidGlassCornerCurves(size, corners);
      final half = size.center(Offset.zero);
      final shift = half.dx - half.dy;
      final octants = [
        (
          a: half.dx,
          curve: curves.sublist(0, 4),
          center: Offset(curves[8], curves[9]),
          place: (Offset w) => half - Offset(w.dx, w.dy - shift),
        ),
        (
          a: half.dy,
          curve: curves.sublist(4, 8),
          center: Offset(curves[10], curves[11]),
          place: (Offset w) => half - Offset(w.dy + shift, w.dx),
        ),
      ];
      for (final (:a, :curve, :center, :place) in octants) {
        final [n, jx, jy, arc] = curve;
        for (var x = 0.0; x <= jx; x += jx / 16) {
          final y = math.pow(1 - math.pow(x / a, n), 1 / n) * a;
          expect(offPath(place(Offset(x, y))), lessThan(0.06));
        }
        final from = (Offset(jx, jy) - center).direction;
        for (var step = 0; step <= 8; step++) {
          final turn = from - (from - math.pi / 4) * step / 8;
          final point = center + Offset.fromDirection(turn, arc);
          expect(offPath(place(point)), lessThan(0.06));
        }
      }
    }
    expect(
      liquidGlassCornerCurves(const Size(40, 20), BorderRadius.zero),
      everyElement(0),
    );
  });

  testWidgets('a pane shaped by a clipper keeps to its path', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox.square(
              dimension: 40,
              child: LiquidGlass(
                style: LiquidGlassStyle(tint: Colors.blue),
                clipper: _Diamond(),
              ),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = boundary.toImageSync();
    addTearDown(image.dispose);

    await tester.runAsync(() async {
      final bytes = (await image.toByteData())!;
      int alphaAt(int x, int y) =>
          bytes.getUint8((y * image.width + x) * 4 + 3);
      expect(alphaAt(5, 5), 0);
      expect(alphaAt(34, 34), 0);
      expect(alphaAt(20, 20), greaterThan(0));
      expect(alphaAt(20, 3), greaterThan(0));
    });
  });

  testWidgets('a snapshot taken without panes holds only what stands on them', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox.square(
              dimension: 40,
              child: LiquidGlass(style: LiquidGlassStyle(tint: Colors.blue)),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bare = LiquidGlass.withoutPanes(boundary.toImageSync);
    final glass = boundary.toImageSync();
    addTearDown(bare.dispose);
    addTearDown(glass.dispose);

    Future<int> centerAlpha(ui.Image image) async {
      final bytes = (await image.toByteData())!;
      return bytes.getUint8(
        ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4 + 3,
      );
    }

    await tester.runAsync(() async {
      expect(await centerAlpha(bare), 0);
      expect(await centerAlpha(glass), greaterThan(0));
    });
  });
}

class _Diamond extends CustomClipper<Path> {
  const _Diamond();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(size.width / 2, size.height)
    ..lineTo(0, size.height / 2)
    ..close();

  @override
  bool shouldReclip(_Diamond oldClipper) => false;
}
