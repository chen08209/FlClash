import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind, kPressTimeout;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void main() {
  late int presses;
  late int innerPresses;
  late WidgetStatesController states;

  setUp(() {
    presses = 0;
    innerPresses = 0;
    states = WidgetStatesController();
  });

  tearDown(() => states.dispose());

  Widget card({bool inert = false, bool withAction = false}) => SizedBox(
    height: 64,
    child: Card(
      statesController: states,
      inert: inert,
      onPressed: () => presses++,
      child: Row(
        children: [
          const Expanded(child: Text('Card')),
          if (withAction)
            IconButton(
              tooltip: 'Inner',
              onPressed: () => innerPresses++,
              icon: const GlyphIcon(AppGlyphs.bolt),
            ),
        ],
      ),
    ),
  );

  Future<void> pump(
    WidgetTester tester, {
    bool scrolls = true,
    bool overflows = true,
    bool inert = false,
    bool withAction = false,
  }) async {
    final child = card(inert: inert, withAction: withAction);
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: scrolls
              ? ListView(
                  primary: overflows,
                  children: [
                    child,
                    if (overflows) const SizedBox(height: 2000),
                  ],
                )
              : GestureDetector(
                  onVerticalDragUpdate: (_) {},
                  child: Align(alignment: Alignment.topCenter, child: child),
                ),
        ),
      ),
    );
  }

  double pressed(WidgetTester tester) =>
      tester.widget<CardSurface>(find.byType(CardSurface).first).pressed.value;

  PressSparkles sparkles(WidgetTester tester) =>
      tester.widget<CardSurface>(find.byType(CardSurface).first).sparkles!;

  bool isPressed() => states.value.contains(WidgetState.pressed);

  testWidgets('a touch inks once the press timeout passes', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(sparkles(tester).isEmpty, isTrue);
    expect(isPressed(), isFalse);

    await tester.pump(kPressTimeout);
    expect(sparkles(tester).isEmpty, isFalse);
    expect(isPressed(), isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed(tester), 1);

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(pressed(tester), inExclusiveRange(0, 1));
    expect(presses, 1);

    await tester.pumpAndSettle();
    expect(pressed(tester), 0);
    expect(isPressed(), isFalse);
    expect(sparkles(tester).isEmpty, isTrue);
  });

  testWidgets('a mouse lays the state layer on button down', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(isPressed(), isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed(tester), greaterThan(0));
    expect(sparkles(tester).isEmpty, isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(pressed(tester), 0);
    expect(presses, 1);
  });

  testWidgets(
    'off Android a press only lays the state layer',
    (tester) async {
      await pump(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Card')),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(pressed(tester), 1);
      expect(sparkles(tester).isEmpty, isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(pressed(tester), 0);

      final focus = Focus.of(tester.element(find.text('Card')));
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed(tester), 1);
      expect(sparkles(tester).isEmpty, isTrue);
      await tester.pumpAndSettle();
      expect(pressed(tester), 0);
      expect(presses, 2);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('a quick tap still sparkles', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
    );
    await tester.pump(const Duration(milliseconds: 30));
    await gesture.up();
    await tester.pump();
    expect(sparkles(tester).isEmpty, isFalse);
    expect(presses, 1);

    await tester.pumpAndSettle();
    expect(sparkles(tester).isEmpty, isTrue);
    expect(pressed(tester), 0);
  });

  testWidgets('a sparkle goes once its page stops ticking', (tester) async {
    final ticking = ValueNotifier(true);
    addTearDown(ticking.dispose);
    await tester.pumpWidget(
      TestApp(
        child: ValueListenableBuilder(
          valueListenable: ticking,
          builder: (_, enabled, child) =>
              TickerMode(enabled: enabled, child: child!),
          child: Align(alignment: Alignment.topCenter, child: card()),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
    );
    await tester.pump(const Duration(milliseconds: 30));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(sparkles(tester).isEmpty, isFalse);

    ticking.value = false;
    await tester.pump();
    expect(sparkles(tester).isEmpty, isTrue);
  });

  testWidgets('scrolling after the press fades it', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
    );
    await tester.pump(kPressTimeout);
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed(tester), 1);

    await gesture.moveBy(const Offset(0, -60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    expect(pressed(tester), 0);
    expect(isPressed(), isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(presses, 0);
  });

  testWidgets('a drag another recognizer takes fades the press', (
    tester,
  ) async {
    await pump(tester, scrolls: false);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Card')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump(kPressTimeout);
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed(tester), 1);

    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    expect(pressed(tester), 0);
    expect(isPressed(), isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(presses, 0);
  });

  testWidgets('a hover changes nothing', (tester) async {
    await pump(tester);
    final mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Card')));
    await tester.pumpAndSettle();
    expect(pressed(tester), 0);
    expect(states.value, isNot(contains(WidgetState.hovered)));
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
    );
  });

  testWidgets('a control inside the card keeps its press', (tester) async {
    await pump(tester, withAction: true);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byTooltip('Inner')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(pressed(tester), 0);
    expect(sparkles(tester).isEmpty, isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(innerPresses, 1);
    expect(presses, 0);
  });

  testWidgets('an inert card ignores presses', (tester) async {
    await pump(tester, inert: true);
    for (final kind in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Card')),
        kind: kind,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(pressed(tester), 0);
      expect(sparkles(tester).isEmpty, isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
    }
    expect(presses, 0);
  });

  testWidgets('the activate key sparkles a focused card', (tester) async {
    await pump(tester);
    final focus = Focus.of(tester.element(find.text('Card')));
    focus.requestFocus();
    await tester.pump();
    expect(states.value, contains(WidgetState.focused));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(presses, 1);
    expect(sparkles(tester).isEmpty, isFalse);
    await tester.pumpAndSettle();
    expect(sparkles(tester).isEmpty, isTrue);
  });

  testWidgets('the card reads as one selected button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(
            child: Card(
              isSelected: true,
              onPressed: () => presses++,
              child: const Text('Card'),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(CardSurface)),
      matchesSemantics(
        label: 'Card',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Card'));
    expect(presses, 1);
    handle.dispose();
  });

  testWidgets('a small card keeps the button minimum and tap target', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(
            child: Card(
              onPressed: () {},
              child: const SizedBox(key: Key('content'), width: 8, height: 8),
            ),
          ),
        ),
      ),
    );
    final box = tester.renderObject<RenderBox>(find.byType(CardSurface));
    expect(box.size, const Size(64, 48));
    expect(tester.getSize(find.byKey(const Key('content'))), const Size(8, 8));
  });
}
