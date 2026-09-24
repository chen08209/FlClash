import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _document = 'proxies:\n  - name: alpha\n    type: vmess\n';

void main() {
  setUpAll(initEditorNative);

  Future<(CodeForgeController, List<CodeForgeSuggestionDetails>)> pumpWords(
    WidgetTester tester, [
    String document = _document,
  ]) async {
    final controller = CodeForgeController()..text = document;
    final popups = <CodeForgeSuggestionDetails>[];
    await pumpEditor(
      tester,
      controller,
      enableLocalSuggestions: true,
      suggestionPopupBuilder: (context, details) {
        popups.add(details);
        return Column(
          children: [
            for (final suggestion in details.suggestions)
              Text('suggest ${suggestion.label}'),
          ],
        );
      },
    );
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(offset: controller.length);
    await settle(tester, 2);
    return (controller, popups);
  }

  testWidgets('typing a known prefix opens the popup with document words', (
    tester,
  ) async {
    final (controller, popups) = await pumpWords(tester);

    await typeText(tester, controller, 'vm');
    await settle(tester, 8);

    expect(popups, isNotEmpty);
    final details = popups.last;
    expect(details.suggestions.map((s) => s.label), contains('vmess'));
    expect(find.text('suggest vmess'), findsOneWidget);
  });

  testWidgets('accepting a suggestion completes the word and closes it', (
    tester,
  ) async {
    final (controller, popups) = await pumpWords(tester);

    await typeText(tester, controller, 'al');
    await settle(tester, 8);
    final details = popups.last;
    final index = details.suggestions.indexWhere((s) => s.label == 'alpha');
    expect(index, isNonNegative);

    details.onAccept(index);
    await settle(tester, 4);

    expect(controller.text, '${_document}alpha');
    expect(find.textContaining('suggest '), findsNothing);
  });

  testWidgets('arrow keys move the highlight that Enter accepts', (
    tester,
  ) async {
    const document = 'a: [alpha, alpine, also]\n';
    final (controller, popups) = await pumpWords(tester, document);

    await typeText(tester, controller, 'al');
    await settle(tester, 8);
    final labels = popups.last.suggestions.map((s) => s.label).toList();
    expect(labels, ['also', 'alpha', 'alpine']);
    expect(popups.last.selectedIndex, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(popups.last.selectedIndex, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(popups.last.selectedIndex, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester, 4);
    expect(controller.text, '${document}alpha');
    expect(find.textContaining('suggest '), findsNothing);
  });

  testWidgets('a newline from the IME accepts the highlighted suggestion', (
    tester,
  ) async {
    final (controller, _) = await pumpWords(tester);

    await typeText(tester, controller, 'al');
    await settle(tester, 8);
    await typeText(tester, controller, '\n');
    await settle(tester, 8);

    expect(controller.text, '${_document}alpha');
  });

  testWidgets('a newline after a key opens no popup and breaks the line', (
    tester,
  ) async {
    final (controller, _) = await pumpWords(tester);

    await typeText(tester, controller, 'key:');
    await settle(tester, 8);
    expect(controller.suggestions, isNull);
    await typeText(tester, controller, '\n');
    await settle(tester, 8);

    expect(controller.text, startsWith('${_document}key:\n'));
    expect(controller.lineCount, _document.split('\n').length + 1);
  });

  testWidgets('a newline after a word with no matches breaks the line', (
    tester,
  ) async {
    final (controller, _) = await pumpWords(tester);

    await typeText(tester, controller, 'zzq');
    await settle(tester, 8);
    expect(controller.suggestions, isNull);
    await typeText(tester, controller, '\n');
    await settle(tester, 8);

    expect(controller.text, '${_document}zzq\n');
  });

  testWidgets('the popup is given the caret line as the editor scrolls', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [
        for (var i = 0; i < 40; i++) 'filler$i ${'z' * 60}',
        'type: vmess',
        'name: ',
        for (var i = 0; i < 40; i++) 'tail$i',
      ].join('\n');
    const popupKey = Key('popup');
    final popups = <CodeForgeSuggestionDetails>[];
    await pumpEditor(
      tester,
      controller,
      enableLocalSuggestions: true,
      suggestionPopupBuilder: (_, details) {
        popups.add(details);
        return const SizedBox(key: popupKey);
      },
    );
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.indexOf('name: ') + 'name: '.length,
    );
    await settle(tester, 2);
    await typeText(tester, controller, 'vm');
    await settle(tester, 8);

    final before = popups.last.caretRect;
    expect(before.height, editorLineHeight);
    final scrollable = tester.state<TwoDimensionalScrollableState>(
      find.byType(TwoDimensionalScrollable),
    );

    scrollable.horizontalScrollable.position.jumpTo(10);
    await tester.pump();
    expect(popups.last.caretRect, before.shift(const Offset(-10, 0)));

    final vertical = scrollable.verticalScrollable.position;
    final start = vertical.pixels;
    vertical.jumpTo(start + 10);
    await tester.pump();
    expect(popups.last.caretRect, before.shift(const Offset(-10, -10)));

    vertical.jumpTo(start + 700);
    await tester.pump();
    expect(find.byKey(popupKey), findsNothing);

    vertical.jumpTo(start);
    await tester.pump();
    expect(find.byKey(popupKey), findsOneWidget);
    expect(popups.last.caretRect, before.shift(const Offset(-10, 0)));
  });

  testWidgets('replacing the text closes the popup', (tester) async {
    final (controller, _) = await pumpWords(tester);

    await typeText(tester, controller, 'al');
    await settle(tester, 8);
    expect(controller.suggestions, isNotNull);
    controller.text = 'other: 1';

    expect(controller.suggestions, isNull);
    await settle(tester, 8);
    expect(controller.suggestions, isNull);
  });
}
