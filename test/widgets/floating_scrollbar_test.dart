import 'package:fl_clash/widgets/scroll.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the hint follows the thumb of a list in reading order', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloatingScrollbar(
            controller: controller,
            hintBuilder: (fraction) => fraction.toStringAsFixed(1),
            child: ListView.builder(
              controller: controller,
              itemCount: 200,
              itemBuilder: (_, index) =>
                  SizedBox(height: 40, child: Text('$index')),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable)),
    );
    for (var i = 0; i < 25; i++) {
      await gesture.moveBy(const Offset(0, -2000));
      await tester.pump();
    }

    final listRect = tester.getRect(find.byType(Scrollable));
    final hint = find.byKey(const ValueKey('scrollbarHintPill'));
    expect(hint, findsOneWidget);
    expect(tester.getCenter(hint).dy, greaterThan(listRect.center.dy));

    await gesture.up();
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
