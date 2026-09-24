import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _scrollbarPaint = find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
);

ScrollbarPainter scrollbarPainter(WidgetTester tester) =>
    tester.widget<CustomPaint>(_scrollbarPaint.first).foregroundPainter!
        as ScrollbarPainter;

/// Nudges [scrollable] so its faded-out bar shows, and returns the global
/// center of the thumb, which only takes a pointer while visible.
Future<Offset> revealScrollbarThumb(
  WidgetTester tester, {
  Finder? scrollable,
}) async {
  final position = tester
      .state<ScrollableState>(scrollable ?? find.byType(Scrollable).first)
      .position;
  final pixels = position.pixels;
  position.jumpTo(pixels > position.minScrollExtent ? pixels - 1 : pixels + 1);
  position.jumpTo(pixels);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  final painter = scrollbarPainter(tester);
  final box = tester.renderObject<RenderBox>(_scrollbarPaint.first);
  final x = box.size.width - 5;
  double? top;
  double? bottom;
  for (var y = 0.0; y < box.size.height; y++) {
    if (painter.hitTestOnlyThumbInteractive(
      Offset(x, y),
      PointerDeviceKind.mouse,
    )) {
      top ??= y;
      bottom = y;
    }
  }
  expect(top, isNotNull, reason: 'no visible scrollbar thumb');
  return box.localToGlobal(Offset(x, (top! + bottom!) / 2));
}
