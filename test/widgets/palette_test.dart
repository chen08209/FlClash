import 'package:fl_clash/widgets/palette.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Palette updates color from hue, chroma, and tone controls', (
    tester,
  ) async {
    final controller = ValueNotifier<Color>(Colors.blue);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 700, child: Palette(controller: controller)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);

    final initial = controller.value;
    tester.widget<Slider>(find.byType(Slider).first).onChanged!(180);
    await tester.pump();
    expect(controller.value, isNot(initial));

    final hueColor = controller.value;
    tester.widget<Slider>(find.byType(Slider).last).onChanged!(8);
    await tester.pump();
    expect(controller.value, isNot(hueColor));

    await tester.tap(find.text('0'));
    await tester.pump();
    expect(controller.value.computeLuminance(), lessThan(0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Palette lays out narrow tone and preview grids', (tester) async {
    final controller = ValueNotifier<Color>(Colors.white);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 32, child: Palette(controller: controller)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
