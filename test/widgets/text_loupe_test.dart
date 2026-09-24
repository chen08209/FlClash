import 'package:fl_clash/widgets/text_loupe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

MagnifierInfo _infoAt(double x) => MagnifierInfo(
  globalGesturePosition: Offset(x, 100),
  caretRect: Rect.fromLTWH(x, 90, 0, 20),
  fieldBounds: const Rect.fromLTWH(0, 0, 400, 400),
  currentLineBoundaries: const Rect.fromLTWH(0, 90, 400, 20),
);

void main() {
  late MagnifierController controller;
  late ValueNotifier<MagnifierInfo> info;

  Future<void> showLoupe(WidgetTester tester) async {
    controller = MagnifierController();
    info = ValueNotifier(_infoAt(100));
    addTearDown(info.dispose);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    controller.show(
      context: tester.element(find.byType(SizedBox)),
      builder: (_) => TextLoupe(
        controller: controller,
        magnifierInfo: info,
        borderColor: Colors.black,
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.shown, isTrue);
  }

  testWidgets('a layout change while the loupe hides lets it go', (
    tester,
  ) async {
    await showLoupe(tester);

    controller.hide();
    await tester.pump(const Duration(milliseconds: 50));
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpAndSettle();

    expect(controller.overlayEntry, isNull);
    expect(find.byType(TextLoupe), findsNothing);
  });

  testWidgets('a new position while the loupe hides brings it back', (
    tester,
  ) async {
    await showLoupe(tester);

    controller.hide();
    await tester.pump(const Duration(milliseconds: 50));
    info.value = _infoAt(200);
    await tester.pumpAndSettle();

    expect(controller.shown, isTrue);
    expect(find.byType(TextLoupe), findsOneWidget);
  });
}
