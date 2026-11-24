import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'glyph_finders.dart';

Finder findStatusButton() => find
    .ancestor(of: find.byGlyph(AppGlyphs.picker), matching: find.byType(Card))
    .first;

List<String> _textsIn(WidgetTester tester, Finder of) => [
  for (final text in tester.widgetList<RichText>(
    find.descendant(of: of, matching: find.byType(RichText)),
  ))
    text.text.toPlainText(),
];

/// What the button shows, as `status count`.
String shownStatusText(WidgetTester tester) =>
    _textsIn(tester, findStatusButton()).join(' ');

Future<void> openStatusMenu(WidgetTester tester) async {
  await tester.tap(findStatusButton());
  await tester.pumpAndSettle();
}

/// The open menu's items, each as `status count`, the picked one ending in ✓.
List<String> statusMenuItems(WidgetTester tester) => [
  for (final item in tester.widget<PopupMenu>(find.byType(PopupMenu)).items)
    '${item.label} ${item.detail}${item.checked == true ? ' ✓' : ''}',
];

Future<void> closeStatusMenu(WidgetTester tester) async {
  await tester.tapAt(const Offset(1, 1));
  await tester.pumpAndSettle();
}

Future<void> pickStatus(WidgetTester tester, String status) async {
  await openStatusMenu(tester);
  final split = status.lastIndexOf(' ');
  expect(
    statusMenuItems(tester).map((item) => item.replaceAll(' ✓', '')),
    contains(status),
  );
  await tester.tap(
    find.descendant(
      of: find.byType(PopupMenu),
      matching: find.text(status.substring(0, split)),
    ),
  );
  await tester.pumpAndSettle();
}
