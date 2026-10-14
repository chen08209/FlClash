import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Color Function(Offset)> _captureFrame(WidgetTester tester) async {
  final size = tester.view.physicalSize;
  final ratio = tester.view.devicePixelRatio;
  final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
  final bytes = await tester.runAsync(() async {
    final image = await layer.toImage(Offset.zero & size);
    return image.toByteData();
  });
  final pixels = bytes!.buffer.asUint8List();
  final width = size.width.toInt();
  return (point) {
    final x = (point.dx * ratio).floor();
    final y = (point.dy * ratio).floor();
    final offset = (y * width + x) * 4;
    final [r, g, b, a] = Uint8List.sublistView(pixels, offset, offset + 4);
    return Color.fromARGB(a, r, g, b);
  };
}

double _distance(Color a, Color b) {
  return (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();
}

Future<Color> pixelAt(WidgetTester tester, Offset point) async {
  return (await _captureFrame(tester))(point);
}

// The first glyph's middle: a label's center can be a seam, and p is blank.
Offset inkPointOf(WidgetTester tester, String label) {
  final rect = tester.getRect(find.text(label));
  return rect.centerLeft + Offset(rect.height / 2, 0);
}

/// Pumps a page transition through, checking no two [labels] show at once on
/// any frame and, given a [floor], that one always shows more than that.
Future<void> expectHandOver(
  WidgetTester tester,
  List<String> labels, {
  required Color ink,
  required Color surface,
  double? floor,
}) async {
  final full = _distance(ink, surface);
  await tester.pump();
  for (var frame = 0; frame < 40; frame++) {
    final pixelOf = await _captureFrame(tester);
    final shown = {
      for (final label in labels)
        label: find.text(label).evaluate().isEmpty
            ? 0.0
            : _distance(pixelOf(inkPointOf(tester, label)), surface) / full,
    };
    expect(
      shown.values.where((value) => value > 0.02),
      hasLength(lessThanOrEqualTo(1)),
      reason: 'frame $frame shows $shown',
    );
    if (floor != null) {
      expect(
        shown.values.reduce(math.max),
        greaterThan(floor),
        reason: 'frame $frame shows $shown',
      );
    }
    await tester.pump(const Duration(milliseconds: 16));
  }
}
