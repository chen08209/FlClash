import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  late bool value;
  late List<bool> highlights;
  late int rowTaps;

  setUp(() {
    value = false;
    highlights = [];
    rowTaps = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    bool glass = false,
    bool rowFlips = false,
  }) async {
    await tester.pumpWidget(
      TestApp(
        child: LiquidGlassScope(
          enabled: glass,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ListView(
                children: [
                  InkWell(
                    onTap: () {
                      rowTaps++;
                      if (rowFlips) {
                        setState(() => value = !value);
                      }
                    },
                    onHighlightChanged: highlights.add,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CommonSwitch(
                          value: value,
                          onChanged: (next) => setState(() => value = next),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder switchFinder() => find.byType(CommonSwitch);

  // The track is drawn first, the thumb over it.
  Finder thumbFinder() => find
      .descendant(of: switchFinder(), matching: find.byType(DecoratedBox))
      .at(1);

  Future<TestGesture> hold(WidgetTester tester) async {
    final gesture = await tester.startGesture(tester.getCenter(switchFinder()));
    await tester.pump(kPressTimeout * 3);
    await tester.pump(const Duration(milliseconds: 200));
    return gesture;
  }

  testWidgets('a held switch keeps the ink around it dark and lifts its thumb '
      'out past the track', (tester) async {
    await pump(tester);
    final rest = tester.getSize(thumbFinder());

    final gesture = await hold(tester);

    expect(highlights, isEmpty);
    expect(rest, const Size.square(24));
    expect(tester.getSize(thumbFinder()), const Size.square(40));
    expect(
      tester.getSize(thumbFinder()).height,
      greaterThan(CommonSwitch.trackHeight),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(value, isTrue);
    expect(rowTaps, 0);
    expect(highlights, isEmpty);
    expect(tester.getSize(thumbFinder()), const Size.square(24));
  });

  testWidgets('on glass the held thumb turns into a clear lens over a solid '
      'track', (tester) async {
    await pump(tester, glass: true);
    expect(find.byType(LiquidGlass), findsNothing);

    final gesture = await hold(tester);
    final colorScheme = Theme.of(tester.element(switchFinder())).colorScheme;

    final lens = tester.widget<LiquidGlass>(
      find.descendant(of: switchFinder(), matching: find.byType(LiquidGlass)),
    );
    expect(lens.style, LiquidGlassStyle.lens(colorScheme).scale(1));
    expect(
      (tester.widget<DecoratedBox>(thumbFinder()).decoration as ShapeDecoration)
          .color!
          .a,
      0,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(value, isTrue);
    expect(find.byType(LiquidGlass), findsNothing);
  });

  testWidgets('on glass a tap carries the lens across before it settles', (
    tester,
  ) async {
    await pump(tester, glass: true);

    await tester.tap(switchFinder());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(value, isTrue);
    expect(
      find.descendant(of: switchFinder(), matching: find.byType(LiquidGlass)),
      findsOneWidget,
    );
    expect(
      tester.getSize(thumbFinder()).height,
      greaterThan(CommonSwitch.trackHeight),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlass), findsNothing);
    expect(tester.getSize(thumbFinder()), const Size.square(24));
  });

  testWidgets('on glass a row that flips the switch carries the lens too', (
    tester,
  ) async {
    await pump(tester, glass: true, rowFlips: true);

    await tester.tapAt(
      tester.getTopLeft(find.byType(InkWell).first) + const Offset(24, 24),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(rowTaps, 1);
    expect(value, isTrue);
    expect(
      find.descendant(of: switchFinder(), matching: find.byType(LiquidGlass)),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlass), findsNothing);
    expect(tester.getSize(thumbFinder()), const Size.square(24));
  });

  testWidgets('dragging the thumb across flips the switch', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(tester.getCenter(switchFinder()));
    for (var i = 0; i < 8; i++) {
      await gesture.moveBy(const Offset(6, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(value, isTrue);
    expect(rowTaps, 0);
  });

  testWidgets('a scroll that starts on the switch still scrolls', (
    tester,
  ) async {
    await pump(tester);

    await tester.drag(switchFinder(), const Offset(0, -200));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(value, isFalse);
    expect(highlights, isEmpty);
  });

  testWidgets('a scroll that starts on a held switch still scrolls', (
    tester,
  ) async {
    await pump(tester);

    final gesture = await hold(tester);
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(value, isFalse);
    expect(highlights, isEmpty);
  });

  testWidgets('the keyboard focuses and flips it', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CommonSwitch(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(value, isTrue);
  });

  testWidgets('without onChanged it neither presses nor flips', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Scaffold(
          body: Center(child: CommonSwitch(value: false, onChanged: null)),
        ),
      ),
    );
    final rest = tester.getSize(thumbFinder());

    final gesture = await hold(tester);
    expect(tester.getSize(thumbFinder()), rest);
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
