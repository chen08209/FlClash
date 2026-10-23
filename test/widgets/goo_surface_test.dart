import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void _noop() {}

void main() {
  const field = Rect.fromLTWH(0, 0, 300, 44);
  const cancel = Rect.fromLTWH(312, 0, 44, 44);
  final swollen = field.inflate(8);

  test('neighbors at rest keep apart, and a press flows them together', () {
    expect(
      gooOutline([field, cancel], [8]).contains(const Offset(306, 22)),
      isFalse,
    );

    const gap = Offset(310, 22);
    expect(gooOutline([swollen, cancel], [16]).contains(gap), isTrue);
    expect(gooOutline([swollen, cancel], [0]).contains(gap), isFalse);
  });

  test('a neck stays narrower than the pills it joins', () {
    final outline = gooOutline([swollen, cancel], [16]);

    expect(outline.contains(const Offset(310, 2)), isFalse);
    expect(outline.contains(const Offset(310, 42)), isFalse);
  });

  testWidgets('buttons under a goo surface stand on its panes', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Center(
          child: GooSurface(
            color: Colors.white,
            child: TonalButtonTheme(
              glass: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElasticPress(
                    child: IconButton(
                      onPressed: _noop,
                      icon: GlyphIcon(AppGlyphs.close),
                    ),
                  ),
                  TonalButtonGroup(
                    children: [
                      IconButton(
                        onPressed: _noop,
                        icon: GlyphIcon(AppGlyphs.chevronUp),
                      ),
                      IconButton(
                        onPressed: _noop,
                        icon: GlyphIcon(AppGlyphs.chevronDown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GooPane), findsNWidgets(2));
    expect(find.byType(LiquidGlass), findsNothing);
  });

  testWidgets('a press behind a repaint boundary still reshapes its pane', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(
        child: Center(
          child: GooSurface(
            color: Colors.white,
            child: Opacity(
              opacity: 1,
              child: ElasticPress(
                child: GooPane(
                  child: ColoredBox(
                    color: Colors.blue,
                    child: SizedBox.square(dimension: 44),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final surface = tester.renderObject(find.byType(GooSurface));
    var paints = 0;
    debugProfilePaintsEnabled = true;
    debugOnProfilePaint = (object) {
      if (identical(object, surface)) {
        paints++;
      }
    };
    try {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GooPane)),
      );
      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(paints, greaterThanOrEqualTo(4));
      await gesture.up();
    } finally {
      debugProfilePaintsEnabled = false;
      debugOnProfilePaint = null;
    }
    await tester.pumpAndSettle();
  });

  testWidgets('a pressed search field swells and follows the finger', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Material(
          child: Center(
            child: SizedBox(
              width: 300,
              child: GooSurface(
                color: Colors.white,
                child: ElasticPress(
                  child: GooPane(child: SearchField(onChanged: (_) {})),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final pane = tester.renderObject<RenderBox>(find.byType(GooPane));
    final rest = Offset.zero & pane.size;
    expect(ElasticPress.paintBoundsOf(pane), rest);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SearchField)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final pressed = ElasticPress.paintBoundsOf(pane);
    expect(pressed.width, greaterThan(rest.width));
    expect(pressed.center, offsetMoreOrLessEquals(rest.center));

    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ElasticPress.paintBoundsOf(pane).center.dy, greaterThan(22));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(ElasticPress.paintBoundsOf(pane), rest);
  });
}
