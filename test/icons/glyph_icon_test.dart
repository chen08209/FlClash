import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> _mirrored(
  WidgetTester tester,
  Glyph glyph,
  TextDirection direction,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: direction,
      child: Center(child: GlyphIcon(glyph)),
    ),
  );
  final transform = find.descendant(
    of: find.byType(GlyphIcon),
    matching: find.byType(Transform),
  );
  if (transform.evaluate().isEmpty) {
    return false;
  }
  return tester.widget<Transform>(transform).transform.entry(0, 0) < 0;
}

void main() {
  testWidgets('mirrors in right-to-left text when the glyph asks', (
    tester,
  ) async {
    final sidebar = AppGlyphs.sidebar(0);

    expect(await _mirrored(tester, sidebar, TextDirection.rtl), isTrue);
    expect(await _mirrored(tester, sidebar, TextDirection.ltr), isFalse);
    expect(
      await _mirrored(tester, AppGlyphs.target, TextDirection.rtl),
      isFalse,
    );
  });

  testWidgets('its own size, color and fill win over the icon theme', (
    tester,
  ) async {
    const themeColor = Color(0xFF0000FF);
    const ownColor = Color(0xFFFF0000);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: IconThemeData(size: 24, color: themeColor, fill: 1),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlyphIcon(AppGlyphs.target),
                GlyphIcon(AppGlyphs.target, size: 16, color: ownColor, fill: 0),
              ],
            ),
          ),
        ),
      ),
    );

    final painters = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(GlyphIcon),
            matching: find.byType(CustomPaint),
          ),
        )
        .toList();
    expect(painters.map((paint) => paint.size), const [
      Size.square(24),
      Size.square(16),
    ]);
    expect(
      painters.map((paint) => (paint.painter! as GlyphPainter).color),
      const [themeColor, ownColor],
    );
    expect(
      painters.map((paint) => (paint.painter! as GlyphPainter).fill),
      const [1, 0],
    );
  });

  testWidgets('keeps its size inside a box forced larger, as Icon does', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size.square(48)),
            child: const GlyphIcon(AppGlyphs.target),
          ),
        ),
      ),
    );

    final paint = find.descendant(
      of: find.byType(GlyphIcon),
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(find.byType(GlyphIcon)), const Size.square(48));
    expect(tester.getSize(paint), const Size.square(24));
    expect(tester.getCenter(paint), tester.getCenter(find.byType(GlyphIcon)));
  });
}
