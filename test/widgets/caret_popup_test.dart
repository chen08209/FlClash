import 'package:fl_clash/widgets/caret_popup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const areaKey = Key('area');
  const popupKey = Key('popup');

  Future<Rect> layOut(
    WidgetTester tester, {
    required Rect caretRect,
    Size popup = const Size(200, 100),
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: areaKey,
            width: 300,
            height: 300,
            child: CustomSingleChildLayout(
              delegate: CaretPopupLayout(caretRect: caretRect),
              child: SizedBox(
                key: popupKey,
                width: popup.width,
                height: popup.height,
              ),
            ),
          ),
        ),
      ),
    );
    return tester.getRect(find.byKey(popupKey));
  }

  testWidgets('opens below the caret line when it fits', (tester) async {
    final popup = await layOut(
      tester,
      caretRect: const Rect.fromLTWH(40, 20, 0, 20),
    );
    expect(popup.topLeft, const Offset(40, 44));
  });

  testWidgets('opens above when the side below is too short', (tester) async {
    final popup = await layOut(
      tester,
      caretRect: const Rect.fromLTWH(40, 250, 0, 20),
    );
    expect(popup.bottom, 246);
  });

  testWidgets('stays inside the area near its right edge', (tester) async {
    final popup = await layOut(
      tester,
      caretRect: const Rect.fromLTWH(290, 20, 0, 20),
      popup: const Size(400, 100),
    );
    final area = tester.getRect(find.byKey(areaKey));
    expect(popup.left, greaterThanOrEqualTo(area.left + 8));
    expect(popup.right, lessThanOrEqualTo(area.right - 8));
  });
}
