import 'package:code_forge/code_forge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _document = 'proxies:\n  - name: a\n    port: 80\nrules:\n  - MATCH,a';

void main() {
  setUpAll(initEditorNative);

  testWidgets('typing through the input client inserts at the caret', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + '  - name: a'.length,
    );
    await typeText(tester, controller, 'bc');

    expect(controller.getLineText(1), '  - name: abc');
    expect(controller.lineCount, 5);
    expect(
      controller.selection,
      TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + '  - name: abc'.length,
      ),
    );
  });

  testWidgets('a typed newline splits the line and keeps its indentation', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(2) + '    port: 80'.length,
    );
    await typeText(tester, controller, '\n');
    await typeText(tester, controller, 'udp: true');

    expect(controller.lineCount, 6);
    expect(controller.getLineText(2), '    port: 80');
    expect(controller.getLineText(3), '    udp: true');
    expect(controller.getLineText(4), 'rules:');
  });

  testWidgets('undo and redo walk the edit history', (tester) async {
    final controller = CodeForgeController()..text = _document;
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(tester, controller, undoController: undo);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await typeText(tester, controller, '\n');
    await typeText(tester, controller, '- DIRECT');
    final edited = controller.text;
    expect(controller.lineCount, 6);
    expect(undo.canUndo, isTrue);

    while (undo.canUndo) {
      undo.undo();
      await settle(tester, 2);
    }
    expect(controller.text, _document);
    expect(controller.lineCount, 5);
    expect(undo.canRedo, isTrue);

    while (undo.canRedo) {
      undo.redo();
      await settle(tester, 2);
    }
    expect(controller.text, edited);
    expect(controller.lineCount, 6);
  });

  testWidgets('replaceRange edits are undoable as one step', (tester) async {
    final controller = CodeForgeController()..text = _document;
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(tester, controller, undoController: undo);
    await focusEditor(tester);

    final start = controller.getLineStartOffset(3);
    controller.replaceRange(start, start, 'dns:\n  enable: true\n');
    await settle(tester, 2);
    expect(controller.lineCount, 7);
    expect(controller.getLineText(3), 'dns:');
    expect(controller.getLineText(5), 'rules:');

    expect(undo.undo(), isTrue);
    await settle(tester, 2);
    expect(controller.text, _document);

    expect(undo.redo(), isTrue);
    await settle(tester, 2);
    expect(controller.getLineText(4), '  enable: true');
  });

  testWidgets('backspace deletes before the caret and joins lines', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(2) + '    port: 80'.length,
    );
    controller.backspace();
    controller.backspace();
    await settle(tester, 2);
    expect(controller.getLineText(2), '    port: ');

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(3),
    );
    controller.backspace();
    await settle(tester, 2);
    expect(controller.lineCount, 4);
    expect(controller.getLineText(2), '    port: rules:');
  });

  testWidgets('read-only opens no input connection and rejects edits', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller, readOnly: true);
    await focusEditor(tester);

    expect(
      tester.testTextInput.log.where(
        (call) => call.method == 'TextInput.setClient',
      ),
      isEmpty,
    );
    controller.selection = TextSelection.collapsed(offset: controller.length);
    controller.insertAtCurrentCursor('x\ny');
    controller.backspace();
    await settle(tester, 2);

    expect(controller.text, _document);
    expect(controller.lineCount, 5);
  });

  testWidgets('delete removes after the caret, joins lines and undoes', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(tester, controller, undoController: undo);
    await focusEditor(tester);

    final lineEnd = controller.getLineStartOffset(2) + '    port: 80'.length;
    controller.selection = TextSelection.collapsed(offset: lineEnd - 2);
    controller.delete();
    controller.delete();
    controller.delete();
    await settle(tester, 2);
    expect(controller.getLineText(2), '    port: rules:');
    expect(controller.lineCount, 4);
    expect(controller.selection, TextSelection.collapsed(offset: lineEnd - 2));

    while (undo.canUndo) {
      undo.undo();
    }
    await settle(tester, 2);
    expect(controller.text, _document);
  });

  testWidgets('deleting a word stops where CJK meets punctuation', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: \u4f60\u597d!!';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await settle(tester, 2);
    expect(controller.text, 'a: \u4f60\u597d');
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester, 2);
    expect(controller.text, 'a: ');
  });

  testWidgets('typed quotes and brackets pair, close over and skip words', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = '';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 0);
    await typeText(tester, controller, 'a: "abc"');
    expect(controller.text, 'a: "abc"');
    await typeText(tester, controller, " # don't [x] 'q'");
    expect(controller.text, 'a: "abc" # don\'t [x] \'q\'');
    expect(controller.selection.extentOffset, controller.length);

    await typeText(tester, controller, ' (');
    expect(controller.text, endsWith(' ()'));
    expect(controller.selection.extentOffset, controller.length - 1);
  });

  testWidgets('a closer typed at the end of an edited line is not skipped', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'ab\n)x';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 2);
    await typeText(tester, controller, 'c)');

    expect(controller.text, 'abc)\n)x');
    expect(controller.selection, const TextSelection.collapsed(offset: 4));
  });

  testWidgets('indenting an upward selection keeps it on the same text', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    final tab = controller.tabSpace.length;

    final base = controller.getLineStartOffset(2) + '    port'.length;
    final extent = controller.getLineStartOffset(1) + '  - '.length;
    controller.selection = TextSelection(
      baseOffset: base,
      extentOffset: extent,
    );
    controller.indent();
    await settle(tester, 2);
    expect(
      controller.selection,
      TextSelection(baseOffset: base + 2 * tab, extentOffset: extent + tab),
    );

    controller.unindent();
    await settle(tester, 2);
    expect(controller.text, _document);
    expect(
      controller.selection,
      TextSelection(baseOffset: base, extentOffset: extent),
    );
  });

  testWidgets('a batch of deltas maps each one in the window it was sent in', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = List.generate(8, (i) => 'l$i').join('\n');
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(3) + 2,
    );
    await tester.pump();
    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    final afterNewline = value.text.replaceRange(caret, caret, '\n');
    await sendDeltas(tester, [
      textDelta(value.text, '\n', caret, caret),
      textDelta(afterNewline, '', caret - 1, caret),
    ]);
    await settle(tester, 2);

    expect(controller.text, 'l0\nl1\nl2\nl\n\nl4\nl5\nl6\nl7');
  });

  testWidgets('the IME sees unflushed typing on a line past its window', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'k: ${'a' * 5000}';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump();
    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [textDelta(value.text, 'x', caret, caret)]);

    final projected = controller.currentTextEditingValue!;
    expect(projected.text, startsWith('k: xa'));
    expect(projected.selection, const TextSelection.collapsed(offset: 4));
    await settle(tester, 2);
  });

  testWidgets('getLinesRange includes typing not yet flushed to the rope', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a\nb\nc';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump();
    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [textDelta(value.text, 'x', caret, caret)]);

    expect(controller.getLinesRange(0, 3), ['a', 'bx', 'c']);
    await settle(tester, 2);
  });

  testWidgets('moving the caret mid-composition commits it in scalars', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    final anchor = controller.getLineStartOffset(1) + '  - name: '.length;
    controller.selection = TextSelection.collapsed(offset: anchor);
    await tester.pump();
    final setClient = tester.testTextInput.log.lastWhere(
      (call) => call.method == 'TextInput.setClient',
    );
    final client = (setClient.arguments as List)[0] as int;
    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        MethodCall('TextInputClient.updateEditingStateWithDeltas', [
          client,
          {
            'deltas': [
              {
                'oldText': value.text,
                'deltaText': '\u{1F600}',
                'deltaStart': caret,
                'deltaEnd': caret,
                'selectionBase': caret + 2,
                'selectionExtent': caret + 2,
                'selectionAffinity': 'TextAffinity.downstream',
                'selectionIsDirectional': false,
                'composingBase': caret,
                'composingExtent': caret + 2,
              },
            ],
          },
        ]),
      ),
      (_) {},
    );
    await tester.pump();
    expect(controller.isComposingActive, isTrue);

    final lineEnd = controller.getLineStartOffset(1) + '  - name: a'.length;
    controller.selection = TextSelection.collapsed(offset: lineEnd);
    await settle(tester, 2);
    expect(controller.getLineText(1), '  - name: \u{1F600}a');
    expect(controller.selection, TextSelection.collapsed(offset: lineEnd + 1));
  });

  test('only a line feed breaks a line, as in Dart', () {
    for (final text in ['a\rb\n', 'a\u2028b\n', 'a\u0085b\n']) {
      final controller = CodeForgeController()..text = text;
      final lines = text.split('\n');
      expect(controller.lineCount, lines.length, reason: text);
      expect(controller.getLineStartOffset(1), lines[0].length + 1);
    }
  });

  test('CRLF text comes in as LF, so a backspace joins the lines', () {
    final controller = CodeForgeController()..text = 'a: 1\r\nb: 2\r\n';
    expect(controller.text, 'a: 1\nb: 2\n');

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1),
    );
    controller.backspace();

    expect(controller.text, 'a: 1b: 2\n');
  });

  test('CRLF handed to replaceRange comes in as LF', () {
    final controller = CodeForgeController()..text = 'a: 1\n';

    controller.replaceRange(5, 5, 'b: 2\r\nc: 3\r\n');

    expect(controller.text, 'a: 1\nb: 2\nc: 3\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 15));
  });

  testWidgets('CRLF from the input method comes in as LF', (tester) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(offset: controller.length);
    await settle(tester, 2);

    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [
      textDelta(value.text, '\r\n  - DIRECT', caret, caret),
    ]);
    await settle(tester, 2);

    expect(controller.text, '$_document\n  - DIRECT');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.length),
    );
  });

  testWidgets('text after CRLF in the same batch lands right after it', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    final anchor = controller.getLineStartOffset(1) + '  - name: '.length;
    controller.selection = TextSelection.collapsed(offset: anchor);
    await settle(tester, 2);

    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    final afterCrlf = value.text.replaceRange(caret, caret, 'x\r\ny');
    await sendDeltas(tester, [
      textDelta(value.text, 'x\r\ny', caret, caret),
      textDelta(afterCrlf, 'z', caret + 4, caret + 4),
    ]);
    await settle(tester, 2);

    expect(controller.getLineText(1), '  - name: x');
    expect(controller.getLineText(2), 'yza');
    expect(controller.selection, TextSelection.collapsed(offset: anchor + 4));
  });

  testWidgets('a whole value with CRLF from the input method keeps no CR', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    final anchor = controller.getLineStartOffset(1) + '  - name: '.length;
    controller.selection = TextSelection.collapsed(offset: anchor);
    await settle(tester, 2);

    final value = controller.currentTextEditingValue!;
    final caret = value.selection.extentOffset;
    final typed = TextEditingValue(
      text: value.text.replaceRange(caret, caret, 'x\r\ny'),
      selection: TextSelection.collapsed(offset: caret + 4),
    );
    tester.testTextInput.updateEditingValue(typed);
    await tester.pump();
    expect(controller.selection, TextSelection.collapsed(offset: anchor + 3));
    tester.testTextInput.updateEditingValue(
      typed.copyWith(selection: TextSelection.collapsed(offset: caret + 1)),
    );
    await settle(tester, 2);

    expect(controller.text, isNot(contains('\r')));
    expect(controller.getLineText(2), 'ya');
    expect(controller.selection, TextSelection.collapsed(offset: anchor + 1));
  });

  group('a composition the input method commits with CRLF', () {
    late CodeForgeController controller;
    late int anchor;
    late int caret;
    late String composing;

    Future<void> startComposing(WidgetTester tester) async {
      controller = CodeForgeController()..text = _document;
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      anchor = controller.getLineStartOffset(1) + '  - name: '.length;
      controller.selection = TextSelection.collapsed(offset: anchor);
      await settle(tester, 2);
      final value = controller.currentTextEditingValue!;
      caret = value.selection.extentOffset;
      composing = value.text.replaceRange(caret, caret, 'ni');
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'ni', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 2,
        },
      ]);
      expect(controller.isComposingActive, isTrue);
    }

    testWidgets('comes in as LF with the caret after it', (tester) async {
      await startComposing(tester);

      await sendDeltas(tester, [
        textDelta(composing, 'x\r\ny', caret, caret + 2),
      ]);
      await settle(tester, 2);

      expect(controller.getLineText(1), '  - name: x');
      expect(controller.getLineText(2), 'ya');
      expect(controller.selection, TextSelection.collapsed(offset: anchor + 3));
    });

    testWidgets('while it goes on tells the input method the CR is gone', (
      tester,
    ) async {
      await startComposing(tester);

      final logged = tester.testTextInput.log.length;
      await sendDeltas(tester, [
        {
          ...textDelta(composing, 'x\r\nb', caret, caret + 2),
          'composingBase': caret + 3,
          'composingExtent': caret + 4,
        },
      ]);

      expect(controller.getLineText(1), '  - name: x');
      expect(controller.imeComposition?.anchor, anchor + 2);
      final sent = tester.testTextInput.log
          .skip(logged)
          .lastWhere((call) => call.method == 'TextInput.setEditingState');
      final state = sent.arguments as Map;
      expect(state['text'], isNot(contains('\r')));
      expect(
        [state['composingBase'], state['composingExtent']],
        [caret + 2, caret + 3],
      );

      await sendDeltas(tester, [
        textDelta(state['text'] as String, '不', caret + 2, caret + 3),
      ]);
      await settle(tester, 2);

      expect(controller.getLineText(2), '不a');
      expect(controller.selection, TextSelection.collapsed(offset: anchor + 3));
    });
  });

  test('outdenting lines keeps the selection end on its own line', () {
    final controller = CodeForgeController()..text = '\ta\n\tb\n\tc';
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 6);

    controller.unindent();

    expect(controller.text, 'a\nb\nc');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 4),
    );
  });

  test('a line moves down past an empty last line', () {
    final controller = CodeForgeController()..text = 'a\nb\n';
    controller.selection = const TextSelection.collapsed(offset: 3);

    controller.moveLineDown();

    expect(controller.text, 'a\n\nb');
    expect(controller.selection, const TextSelection.collapsed(offset: 4));
  });

  test('edits not yet rendered merge into one covering line range', () {
    final controller = CodeForgeController()
      ..text = List.generate(12, (i) => 'line $i').join('\n');
    final before = controller.text.split('\n');
    controller.clearDirtyRegion();

    void replaceLines(int from, int to, String text) => controller.replaceRange(
      controller.getLineStartOffset(from),
      controller.getLineStartOffset(to),
      text,
    );
    replaceLines(6, 6, 'a\nb\n');
    replaceLines(1, 2, '');
    replaceLines(9, 11, 'c\n');
    replaceLines(0, 0, 'd');

    final after = controller.text.split('\n');
    final edit = controller.lineEdit!;
    expect(edit, (line: 0, removed: 10, inserted: 10));
    expect([
      ...before.sublist(0, edit.line),
      ...after.sublist(edit.line, edit.line + edit.inserted + 1),
      ...before.sublist(edit.line + edit.removed + 1),
    ], after);
  });
}
