import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDetailTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(SegmentedControl<int>).last,
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}
