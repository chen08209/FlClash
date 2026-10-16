import 'package:fl_clash/widgets/palette.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  late ValueNotifier<Color> controller;

  setUp(() => controller = ValueNotifier(const Color(0xFF007AFF)));
  tearDown(() => controller.dispose());

  Future<void> pumpPalette(WidgetTester tester, {ScrollController? scroll}) {
    return tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Scaffold(
          body: ListView(
            controller: scroll,
            children: [
              SizedBox(width: 360, child: Palette(controller: controller)),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      ),
    );
  }

  final pad = find.descendant(
    of: find.byType(Palette),
    matching: find.byType(AspectRatio),
  );

  Offset at(WidgetTester tester, double x, double y) {
    final rect = tester.getRect(pad);
    return rect.topLeft + Offset(rect.width * x, rect.height * y);
  }

  testWidgets('the grid picks the cell under the finger', (tester) async {
    await pumpPalette(tester);

    await tester.tapAt(at(tester, 0.02, 0.02));
    expect(controller.value, const Color(0xFFFFFFFF));

    await tester.tapAt(at(tester, 0.98, 0.02));
    expect(controller.value, const Color(0xFF000000));

    final hues = <double>{};
    final gesture = await tester.startGesture(at(tester, 0.04, 0.5));
    for (var x = 0.04; x < 1; x += 0.0833) {
      await gesture.moveTo(at(tester, x, 0.5));
      hues.add(HSVColor.fromColor(controller.value).hue.roundToDouble());
    }
    await gesture.up();
    expect(hues.length, 12);
  });

  testWidgets('the spectrum runs hue across and lightness down, and keeps '
      'the drag from scrolling', (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpPalette(tester, scroll: scroll);
    await tester.tap(find.text('Spectrum'));
    await tester.pumpAndSettle();

    await tester.tapAt(at(tester, 0.5, 0.5));
    final middle = HSLColor.fromColor(controller.value);
    expect(middle.hue, closeTo(180, 2));
    expect(middle.lightness, closeTo(0.5, 0.02));

    final gesture = await tester.startGesture(at(tester, 0.5, 0.5));
    await gesture.moveBy(const Offset(0, -400));
    await tester.pump();
    await gesture.up();

    expect(scroll.offset, 0);
    expect(controller.value, const Color(0xFFFFFFFF));
  });

  testWidgets('the sliders keep the hue a gray drops', (tester) async {
    await pumpPalette(tester);
    await tester.tap(find.text('Sliders'));
    await tester.pumpAndSettle();
    Slider slider(int index) =>
        tester.widget<Slider>(find.byType(Slider).at(index));
    final hue = slider(0).value;

    slider(1).onChanged!(0);
    await tester.pump();

    expect(HSVColor.fromColor(controller.value).saturation, 0);
    expect(slider(0).value, hue);

    slider(1).onChanged!(1);
    await tester.pump();
    slider(2).onChanged!(0.5);
    await tester.pump();

    final picked = HSVColor.fromColor(controller.value);
    expect(picked.hue, closeTo(hue, 1));
    expect(picked.value, closeTo(0.5, 0.01));
    expect(find.text('50%'), findsOneWidget);
  });

  group('hex field', () {
    Future<void> pumpField(WidgetTester tester) {
      return tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, color, _) => HexColorField(
                color: color,
                onChanged: (color) => controller.value = color,
              ),
            ),
          ),
        ),
      );
    }

    String text(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).controller!.text;

    testWidgets('applies six digits and leaves a partial one alone', (
      tester,
    ) async {
      await pumpField(tester);
      expect(text(tester), '007AFF');

      await tester.enterText(find.byType(TextField), 'ff3');
      await tester.pump();
      expect(controller.value, const Color(0xFF007AFF));
      expect(text(tester), 'FF3');

      await tester.enterText(find.byType(TextField), 'ff3b30');
      await tester.pump();
      expect(controller.value, const Color(0xFFFF3B30));
      expect(text(tester), 'FF3B30');
    });

    testWidgets('follows a color picked elsewhere', (tester) async {
      await pumpField(tester);

      controller.value = const Color(0xFF34C759);
      await tester.pump();

      expect(text(tester), '34C759');
    });
  });
}
