import 'package:code_forge/code_forge.dart';
import 'package:fl_clash/features/editor/completion_popup.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _textStyle = TextStyle(fontSize: 14);

CodeForgeSuggestionDetails _details(
  List<CodeForgeSuggestion> suggestions, {
  int? selectedIndex,
  ValueChanged<int>? onAccept,
}) => CodeForgeSuggestionDetails(
  suggestions: suggestions,
  selectedIndex: selectedIndex,
  onAccept: onAccept ?? (_) {},
  caretRect: Rect.zero,
);

final _many = [
  for (var index = 0; index < 30; index++)
    CodeForgeSuggestion(label: 'item-$index'),
];

Future<void> _pump(
  WidgetTester tester,
  CodeForgeSuggestionDetails details, {
  double maxWidth = 400,
  double maxHeight = 600,
}) => tester.pumpWidget(
  TestApp(
    child: Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: EditorCompletionPopup(details: details, textStyle: _textStyle),
      ),
    ),
  ),
);

void main() {
  bool shown(WidgetTester tester, String label) {
    final popup = tester.getRect(find.byType(EditorCompletionPopup));
    final row = find.text(label);
    if (row.evaluate().isEmpty) {
      return false;
    }
    final rect = tester.getRect(row);
    return rect.top >= popup.top && rect.bottom <= popup.bottom;
  }

  testWidgets('the highlight moved past the visible rows brings its row into '
      'view, and moved back brings the earlier row back', (tester) async {
    await _pump(tester, _details(_many, selectedIndex: 0), maxHeight: 160);
    expect(shown(tester, 'item-0'), isTrue);
    expect(shown(tester, 'item-20'), isFalse);

    await _pump(tester, _details(_many, selectedIndex: 20), maxHeight: 160);
    await tester.pump();
    expect(shown(tester, 'item-20'), isTrue);
    expect(shown(tester, 'item-0'), isFalse);

    await _pump(tester, _details(_many, selectedIndex: 2), maxHeight: 160);
    await tester.pump();
    expect(shown(tester, 'item-2'), isTrue);
    expect(shown(tester, 'item-20'), isFalse);
  });

  testWidgets('a highlight already in view leaves the list where it is', (
    tester,
  ) async {
    await _pump(tester, _details(_many, selectedIndex: 0), maxHeight: 160);
    final first = tester.getTopLeft(find.text('item-0'));

    await _pump(tester, _details(_many, selectedIndex: 1), maxHeight: 160);
    await tester.pump();

    expect(tester.getTopLeft(find.text('item-0')), first);
  });

  testWidgets('a detail sits beside its label while the row has room for it', (
    tester,
  ) async {
    const suggestions = [
      CodeForgeSuggestion(label: 'proxies', detail: 'list'),
      CodeForgeSuggestion(label: 'mode', detail: 'string'),
    ];
    await _pump(tester, _details(suggestions, selectedIndex: 0));

    expect(find.text('list'), findsOneWidget);
    expect(find.text('string'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('list')).dx,
      greaterThan(tester.getTopRight(find.text('proxies')).dx),
    );
  });

  testWidgets('a detail is left out where the label fills the row', (
    tester,
  ) async {
    const suggestions = [
      CodeForgeSuggestion(
        label: 'a-label-much-wider-than-the-popup-can-be',
        detail: 'detail',
      ),
    ];
    await _pump(tester, _details(suggestions), maxWidth: 200);

    expect(find.text('detail'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row accepts that suggestion', (tester) async {
    final accepted = <int>[];
    await _pump(
      tester,
      _details(_many.take(3).toList(), onAccept: accepted.add),
    );

    await tester.tap(find.text('item-1'));

    expect(accepted, [1]);
  });
}
