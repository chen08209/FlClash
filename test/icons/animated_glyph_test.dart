import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _icon({required bool filled, IconThemeData? theme}) {
  final icon = AnimatedGlyph(glyph: AppGlyphs.profiles, filled: filled);
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: theme == null ? icon : IconTheme(data: theme, child: icon),
    ),
  );
}

CustomPaint _paint(WidgetTester tester) => tester.widget<CustomPaint>(
  find.descendant(
    of: find.byType(AnimatedGlyph),
    matching: find.byType(CustomPaint),
  ),
);

GlyphPainter _painter(WidgetTester tester) =>
    _paint(tester).painter! as GlyphPainter;

double _fill(WidgetTester tester) => _painter(tester).fill;

double _scale(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byType(AnimatedGlyph),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform.getMaxScaleOnAxis();
}

void main() {
  testWidgets('rests on the outline and on the fill', (tester) async {
    await tester.pumpWidget(_icon(filled: false));
    expect(_fill(tester), 0);

    await tester.pumpWidget(_icon(filled: true));
    await tester.pumpAndSettle();
    expect(_fill(tester), 1);
    expect(_scale(tester), 1);
  });

  testWidgets('filling runs over time with a pop', (tester) async {
    await tester.pumpWidget(_icon(filled: false));
    await tester.pumpWidget(_icon(filled: true));

    await tester.pump(const Duration(milliseconds: 60));
    final early = _fill(tester);
    expect(early, allOf(greaterThan(0), lessThan(0.5)));
    expect(_scale(tester), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 90));
    expect(_fill(tester), greaterThan(early));

    await tester.pumpAndSettle();
    expect(_fill(tester), 1);
    expect(_scale(tester), 1);
  });

  testWidgets('emptying drains the fill without the pop', (tester) async {
    await tester.pumpWidget(_icon(filled: true));
    await tester.pumpWidget(_icon(filled: false));

    await tester.pump(const Duration(milliseconds: 150));
    expect(_fill(tester), allOf(greaterThan(0), lessThan(1)));
    expect(_scale(tester), 1);

    await tester.pumpAndSettle();
    expect(_fill(tester), 0);
  });

  testWidgets('reversing midway drains from where the fill got to', (
    tester,
  ) async {
    await tester.pumpWidget(_icon(filled: false));
    await tester.pumpWidget(_icon(filled: true));
    await tester.pump(const Duration(milliseconds: 100));
    final reached = _fill(tester);
    final popped = _scale(tester);
    expect(popped, greaterThan(1));

    await tester.pumpWidget(_icon(filled: false));
    await tester.pump(const Duration(milliseconds: 16));
    expect(_fill(tester), allOf(greaterThan(0), lessThan(reached)));
    expect(_scale(tester), closeTo(popped, 0.02));

    await tester.pump(const Duration(milliseconds: 150));
    expect(_fill(tester), 0);
    expect(_scale(tester), greaterThan(1));

    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('takes its size and color from the icon theme', (tester) async {
    await tester.pumpWidget(
      _icon(
        filled: false,
        theme: const IconThemeData(
          size: 32,
          color: Color(0xFF3366CC),
          opacity: 0.5,
        ),
      ),
    );

    expect(_paint(tester).size, const Size.square(32));
    expect(
      _painter(tester).color,
      const Color(0xFF3366CC).withValues(alpha: 0.5),
    );
  });
}
