import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _proxy = CodeForgeSnippet(
  '- name: \${1:trojan}\n'
  '  type: trojan\n'
  '  server: \${2:server}\n'
  '  port: \${3:443}\$0',
);

CodeForgeCompletion? _trojanSource(CodeForgeCompletionRequest request) {
  final typed = RegExp(r'[\w-]*$').stringMatch(request.textBeforeCaret)!;
  if (typed.isEmpty || !'x-trojan'.startsWith(typed)) return null;
  return CodeForgeCompletion(
    prefix: typed,
    suggestions: const [
      CodeForgeSuggestion(
        label: 'x-trojan',
        detail: 'proxies · trojan',
        snippet: _proxy,
      ),
    ],
  );
}

void main() {
  setUpAll(initEditorNative);

  Future<(CodeForgeController, UndoRedoController)> pump(
    WidgetTester tester, {
    String document = 'proxies:\n  ',
    List<CodeForgeSuggestionDetails>? popups,
  }) async {
    final controller = CodeForgeController()
      ..text = document
      ..completionSource = _trojanSource;
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(
      tester,
      controller,
      undoController: undo,
      suggestionPopupBuilder: (context, details) {
        popups?.add(details);
        return const SizedBox.shrink();
      },
    );
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(offset: controller.length);
    await settle(tester, 2);
    return (controller, undo);
  }

  String selected(CodeForgeController controller) => controller.text.substring(
    controller.selection.start,
    controller.selection.end,
  );

  Future<void> tab(WidgetTester tester, {bool shift = false}) async {
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await settle(tester, 2);
  }

  testWidgets('a suggestion expands its snippet over the prefix it matched', (
    tester,
  ) async {
    final popups = <CodeForgeSuggestionDetails>[];
    final (controller, _) = await pump(tester, popups: popups);

    await typeText(tester, controller, 'x-tro');
    await settle(tester, 8);

    final entry = popups.last.suggestions.single;
    expect(entry.label, 'x-trojan');
    expect(entry.detail, 'proxies · trojan');

    popups.last.onAccept(0);
    await settle(tester, 4);

    expect(
      controller.text,
      'proxies:\n'
      '  - name: trojan\n'
      '    type: trojan\n'
      '    server: server\n'
      '    port: 443',
    );
    expect(selected(controller), 'trojan');
    expect(controller.suggestions, isNull);
  });

  testWidgets('Tab walks the stops and follows typing inside one', (
    tester,
  ) async {
    final (controller, _) = await pump(tester);
    controller.insertSnippet(_proxy);
    await settle(tester, 8);

    await typeText(tester, controller, 'jp');
    await tab(tester);
    expect(selected(controller), 'server');
    await typeText(tester, controller, 'a.example');
    await tab(tester);
    expect(selected(controller), '443');
    await tab(tester, shift: true);
    expect(selected(controller), 'a.example');
    await tab(tester);
    await tab(tester);
    await settle(tester, 8);

    expect(
      controller.text,
      endsWith(
        '- name: jp\n    type: trojan\n'
        '    server: a.example\n    port: 443',
      ),
    );
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.extentOffset, controller.length);
    expect(controller.isSnippetActive, isFalse);
  });

  testWidgets('an edit outside the current stop ends the snippet', (
    tester,
  ) async {
    final (controller, _) = await pump(tester);
    controller.insertSnippet(_proxy);
    await settle(tester, 8);

    controller.selection = const TextSelection.collapsed(offset: 0);
    await typeText(tester, controller, 'x');
    await settle(tester, 8);

    expect(controller.isSnippetActive, isFalse);
    expect(controller.nextSnippetStop(), isFalse);
  });

  testWidgets('one undo removes the whole snippet', (tester) async {
    final (controller, undo) = await pump(tester);
    controller.insertSnippet(_proxy);
    await settle(tester, 8);

    undo.undo();
    await settle(tester, 8);

    expect(controller.text, 'proxies:\n  ');
  });

  testWidgets('an undone snippet leaves Tab to indent', (tester) async {
    final (controller, undo) = await pump(tester);
    controller.insertSnippet(const CodeForgeSnippet('\${1:key}\$0'));
    await settle(tester, 8);
    expect(selected(controller), 'key');

    undo.undo();
    await settle(tester, 8);
    expect(controller.isSnippetActive, isFalse);
    await tab(tester);
    await settle(tester, 8);

    expect(controller.text, 'proxies:\n  ${controller.tabSpace}');
  });

  testWidgets('a snippet replaces the word still being composed', (
    tester,
  ) async {
    final (controller, _) = await pump(tester);
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [
      {
        ...textDelta(value.text, 'a', caret, caret),
        'composingBase': caret,
        'composingExtent': caret + 1,
      },
    ]);
    expect(controller.isComposingActive, isTrue);

    controller.insertSnippet(const CodeForgeSnippet('\${1:key}: \$0'));
    await settle(tester, 8);

    expect(controller.isComposingActive, isFalse);
    expect(controller.text, 'proxies:\n  key: ');
    expect(selected(controller), 'key');
  });

  testWidgets('bodies resolve escapes, bare stops and repeated numbers', (
    tester,
  ) async {
    final (controller, _) = await pump(tester, document: '');
    controller.insertSnippet(
      const CodeForgeSnippet(
        'fn \${1:name}(\$2) {\n\t\$0\n} \\\$1 \${1:again} \$x',
      ),
    );
    await settle(tester, 8);

    expect(
      controller.text,
      'fn name() {\n${controller.tabSpace}\n} \$1 again \$x',
    );
    expect(selected(controller), 'name');
    await tab(tester);
    expect(controller.selection.extentOffset, 'fn name('.length);
    await tab(tester);
    expect(
      controller.selection.extentOffset,
      'fn name() {\n'.length + controller.tabSpace.length,
    );
    expect(controller.isSnippetActive, isFalse);
    await settle(tester, 8);
  });
}
