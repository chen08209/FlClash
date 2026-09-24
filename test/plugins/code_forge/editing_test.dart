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
    final value = controller.currentTextEditingValue;
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
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [textDelta(value.text, 'x', caret, caret)]);

    final projected = controller.currentTextEditingValue;
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
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    await sendDeltas(tester, [textDelta(value.text, 'x', caret, caret)]);

    expect(controller.getLinesRange(0, 3), ['a', 'bx', 'c']);
    await settle(tester, 2);
  });

  testWidgets('select all hands the IME a window at the caret', (tester) async {
    final controller = CodeForgeController()
      ..text = List.generate(20000, (i) => 'line $i').join('\n');
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selectAll();
    await tester.pump();
    final value = controller.currentTextEditingValue;
    expect(value.text.length, lessThan(controller.text.length ~/ 10));
    expect(controller.text, endsWith(value.text));
    expect(
      value.selection,
      TextSelection(baseOffset: 0, extentOffset: value.text.length),
    );
    await settle(tester, 2);
  });

  testWidgets('a caret the input method moves out of its window gets the '
      'new window', (tester) async {
    final controller = CodeForgeController()
      ..text = List.generate(20, (i) => 'line $i').join('\n');
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(10) + 3,
    );
    await tester.pump();

    final value = controller.currentTextEditingValue;
    expect(value.text, isNot(contains('line 14')));
    final moved = value.text.indexOf('line 12') + 3;
    final logged = tester.testTextInput.log.length;
    await sendDeltas(tester, [
      {
        ...textDelta(value.text, '', -1, -1),
        'selectionBase': moved,
        'selectionExtent': moved,
      },
    ]);
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.getLineStartOffset(12) + 3),
    );
    final sent = tester.testTextInput.log
        .skip(logged)
        .lastWhere((call) => call.method == 'TextInput.setEditingState');
    final state = sent.arguments as Map;
    expect(state['text'], contains('line 14'));

    final caret = state['selectionExtent'] as int;
    await sendDeltas(tester, [
      textDelta(state['text'] as String, '', caret - 1, caret),
    ]);
    expect(controller.getLineText(12), 'lie 12');
    await settle(tester, 2);
  });

  group('a selection the IME window cuts short', () {
    final document = List.generate(2000, (i) => 'line $i').join('\n');
    late CodeForgeController controller;
    late UndoRedoController undo;
    late String window;

    Future<void> selectAll(WidgetTester tester) async {
      controller = CodeForgeController()..text = document;
      undo = UndoRedoController();
      addTearDown(undo.dispose);
      await pumpEditor(tester, controller, undoController: undo);
      await focusEditor(tester);
      controller.selectAll();
      await tester.pump();
      window = controller.currentTextEditingValue.text;
      expect(window.length, lessThan(document.length));
    }

    void expectOneUndoRestoresIt([TextSelection? selection]) {
      expect(undo.undo(), isTrue);
      expect(controller.text, document);
      expect(
        controller.selection,
        selection ??
            TextSelection(baseOffset: 0, extentOffset: document.length),
      );
      expect(undo.canUndo, isFalse);
    }

    testWidgets('is replaced whole by typed text', (tester) async {
      await selectAll(tester);
      await sendDeltas(tester, [textDelta(window, 'x', 0, window.length)]);

      expect(controller.text, 'x');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('is replaced whole by text that repeats its start', (
      tester,
    ) async {
      await selectAll(tester);
      await sendDeltas(tester, [
        textDelta(window, window[0], 0, window.length),
      ]);

      expect(controller.text, window[0]);
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('is replaced whole by a composition', (tester) async {
      await selectAll(tester);
      await sendDeltas(tester, [
        {
          ...textDelta(window, 'k', 0, window.length),
          'composingBase': 0,
          'composingExtent': 1,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'k');
      expect(controller.text, isEmpty);

      await sendDeltas(tester, [textDelta('k', '可', 0, 1)]);
      expect(controller.text, '可');
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('is replaced whole by a composition begun after the input '
        'method collapsed it', (tester) async {
      await selectAll(tester);
      await sendDeltas(tester, [
        {
          ...textDelta(window, '', -1, -1),
          'selectionBase': window.length,
          'selectionExtent': window.length,
        },
      ]);
      expect(
        controller.selection,
        TextSelection.collapsed(offset: document.length),
      );

      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'k', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 1,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'k');
      expect(controller.text, isEmpty);
      await settle(tester, 2);
    });

    Map<String, Object> caretDelta(String text, int caret, [int? extent]) => {
      ...textDelta(text, '', -1, -1),
      'selectionBase': caret,
      'selectionExtent': extent ?? caret,
    };

    Map<String, Object> composingDelta(String text, String typed, int at) => {
      ...textDelta(text, typed, at, at),
      'composingBase': at,
      'composingExtent': at + typed.length,
    };

    testWidgets('cut by the platform reaches the clipboard whole', (
      tester,
    ) async {
      final clipboard = mockClipboard(tester);
      await selectAll(tester);
      clipboard.text = window;

      await sendDeltas(tester, [textDelta(window, '', 0, window.length)]);
      await settle(tester, 2);

      expect(controller.text, isEmpty);
      expect(clipboard.text, document);
    });

    testWidgets('deleted by an input method that collapses it first leaves '
        'the clipboard alone', (tester) async {
      final clipboard = mockClipboard(tester);
      await selectAll(tester);
      clipboard.text = window;

      await sendDeltas(tester, [
        caretDelta(window, window.length),
        textDelta(window, '', 0, window.length),
      ]);
      await settle(tester, 2);

      expect(controller.text, isEmpty);
      expect(clipboard.text, window);
      expectOneUndoRestoresIt();
    });

    testWidgets('is replaced whole by an input method that collapses it, '
        'deletes what it saw, then composes', (tester) async {
      await selectAll(tester);
      await sendDeltas(tester, [
        caretDelta(window, window.length),
        textDelta(window, '', 0, window.length),
      ]);
      expect(controller.text, isEmpty);

      await sendDeltas(tester, [composingDelta('', 'k', 0)]);
      expect(controller.imeComposition?.displayText, 'k');
      expect(controller.text, isEmpty);

      await sendDeltas(tester, [textDelta('k', '可', 0, 1)]);
      expect(controller.text, '可');
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('outlives an input method that collapses it and then deletes '
        'a character', (tester) async {
      await selectAll(tester);
      await sendDeltas(tester, [caretDelta(window, window.length)]);
      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [textDelta(value.text, '', caret - 1, caret)]);

      expect(controller.text, document.substring(0, document.length - 1));
      await settle(tester, 2);
    });

    testWidgets('outlives an input method that collapses it to its middle, '
        'moves the caret and then composes', (tester) async {
      await selectAll(tester);
      final middle = window.length ~/ 2;
      await sendDeltas(tester, [
        caretDelta(window, middle, window.length),
        caretDelta(window, middle),
      ]);
      var value = controller.currentTextEditingValue;
      var caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        caretDelta(value.text, caret - 1, caret),
        caretDelta(value.text, caret - 1),
      ]);
      value = controller.currentTextEditingValue;
      caret = value.selection.extentOffset;
      await sendDeltas(tester, [composingDelta(value.text, 'k', caret)]);

      expect(controller.imeComposition?.displayText, 'k');
      expect(controller.text, document);
      await settle(tester, 2);
    });

    testWidgets('takes what the input method typed into the window it had '
        'before the new one reached it', (tester) async {
      await selectAll(tester);
      final kept = document.substring(0, document.indexOf('line 10'));
      controller.selection = TextSelection(
        baseOffset: kept.length,
        extentOffset: document.length,
      );
      await tester.pump();
      window = controller.currentTextEditingValue.text;
      await sendDeltas(tester, [
        caretDelta(window, window.length),
        textDelta(window, '', 0, window.length),
      ]);
      expect(controller.text, kept);
      final resent = controller.currentTextEditingValue;
      expect(resent.text, isNotEmpty);

      await sendDeltas(tester, [composingDelta('', 'q', 0)]);
      expect(controller.text, '${kept}q');
      expect(controller.imeComposition, isNull);

      await sendDeltas(tester, [
        caretDelta(resent.text, resent.selection.extentOffset),
      ]);
      expect(
        controller.selection,
        TextSelection.collapsed(offset: kept.length + 1),
      );

      await typeText(tester, controller, 'w');
      expect(controller.text, '${kept}qw');
    });

    testWidgets('takes what the input method typed into that window after '
        'hiding its keyboard', (tester) async {
      await selectAll(tester);
      final kept = document.substring(0, document.indexOf('line 10'));
      controller.selection = TextSelection(
        baseOffset: kept.length,
        extentOffset: document.length,
      );
      await tester.pump();
      window = controller.currentTextEditingValue.text;
      await sendDeltas(tester, [
        caretDelta(window, window.length),
        textDelta(window, '', 0, window.length),
      ]);

      await sendDeltas(tester, []);
      await sendDeltas(tester, [composingDelta('', 'q', 0)]);

      expect(controller.text, '${kept}q');
      expectOneUndoRestoresIt(
        TextSelection(baseOffset: kept.length, extentOffset: document.length),
      );
      await settle(tester, 2);
    });

    testWidgets('takes what the input method went on typing into that '
        'window', (tester) async {
      await selectAll(tester);
      final kept = document.substring(0, document.indexOf('line 10'));
      controller.selection = TextSelection(
        baseOffset: kept.length,
        extentOffset: document.length,
      );
      await tester.pump();
      window = controller.currentTextEditingValue.text;
      await sendDeltas(tester, [
        caretDelta(window, window.length),
        textDelta(window, '', 0, window.length),
      ]);

      await sendDeltas(tester, [composingDelta('', 'q', 0)]);
      await sendDeltas(tester, [
        {...composingDelta('q', 'w', 1), 'composingBase': 0},
      ]);

      expect(controller.text, '${kept}qw');
      await settle(tester, 2);
    });

    testWidgets('is replaced whole by a whole editing value', (tester) async {
      await selectAll(tester);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'x',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();

      expect(controller.text, 'x');
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });
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
    final value = controller.currentTextEditingValue;
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

  group('an interrupted composition', () {
    Future<CodeForgeController> composeThenMoveCaret(
      WidgetTester tester,
      List<String> shown,
    ) async {
      final controller = CodeForgeController()..text = 'ab';
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      final base = controller.currentTextEditingValue;
      final caret = base.selection.extentOffset;
      var composing = '';
      for (final next in shown) {
        await sendDeltas(tester, [
          {
            ...textDelta(
              base.text.replaceRange(caret, caret, composing),
              next,
              caret,
              caret + composing.length,
            ),
            'composingBase': caret,
            'composingExtent': caret + next.length,
          },
        ]);
        composing = next;
      }
      expect(controller.imeComposition?.displayText, shown.last);
      controller.selection = const TextSelection.collapsed(offset: 0);
      await settle(tester, 2);
      return controller;
    }

    testWidgets('commits kana as shown', (tester) async {
      final controller = await composeThenMoveCaret(tester, [
        'k',
        'か',
        'かn',
        'かな',
      ]);
      expect(controller.text, 'aかなb');
    });

    testWidgets('commits pinyin as typed, without the separators', (
      tester,
    ) async {
      final controller = await composeThenMoveCaret(tester, [
        'n',
        'ni',
        "ni'h",
        "ni'ha",
        "ni'hao",
      ]);
      expect(controller.text, 'anihaob');
    });

    testWidgets('commits a word taken up whole with its apostrophe', (
      tester,
    ) async {
      final controller = CodeForgeController()..text = "x: don't";
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      await sendDeltas(tester, [
        {
          ...textDelta("x: don't", '', -1, -1),
          'selectionBase': 8,
          'selectionExtent': 8,
          'composingBase': 3,
          'composingExtent': 8,
        },
        {
          ...textDelta("x: don't", "don'ts", 3, 8),
          'composingBase': 3,
          'composingExtent': 9,
        },
      ]);
      expect(controller.imeComposition?.displayText, "don'ts");

      controller.selection = const TextSelection.collapsed(offset: 0);
      await settle(tester, 2);
      expect(controller.text, "x: don'ts");
    });
  });

  group('composing after a selection', () {
    Future<CodeForgeController> selectHello(WidgetTester tester) async {
      final controller = CodeForgeController()..text = 'hello world';
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 5,
      );
      await tester.pump();
      return controller;
    }

    Future<void> composeAtCaret(
      WidgetTester tester,
      CodeForgeController controller,
    ) async {
      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'n', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 1,
        },
      ]);
      expect(controller.isComposingActive, isTrue);
    }

    testWidgets('the input method already deleted keeps the rest', (
      tester,
    ) async {
      final controller = await selectHello(tester);
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [textDelta(value.text, '', 0, 5)]);
      expect(controller.text, ' world');

      await composeAtCaret(tester, controller);
      expect(controller.text, ' world');
      await settle(tester, 2);
    });

    testWidgets('the input method only collapsed is replaced', (tester) async {
      final controller = await selectHello(tester);
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, '', -1, -1),
          'selectionBase': 5,
          'selectionExtent': 5,
        },
      ]);
      expect(controller.selection, const TextSelection.collapsed(offset: 5));

      await composeAtCaret(tester, controller);
      expect(controller.text, ' world');
      await settle(tester, 2);
    });

    // Android reports a caret the input method sets as two selections, the
    // first still reaching back to where the old one ended.
    Future<void> moveCaret(
      WidgetTester tester,
      CodeForgeController controller,
      int caret,
    ) async {
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [
        for (final extent in [value.selection.end, caret])
          {
            ...textDelta(value.text, '', -1, -1),
            'selectionBase': caret,
            'selectionExtent': extent,
          },
      ]);
      expect(controller.selection, TextSelection.collapsed(offset: caret));
    }

    testWidgets('the input method only collapsed gets the caret after what '
        'is committed over it', (tester) async {
      final controller = await selectHello(tester);
      await moveCaret(tester, controller, 5);
      await composeAtCaret(tester, controller);

      await sendDeltas(tester, [
        {
          ...textDelta('hellon world', '', -1, -1),
          'selectionBase': 6,
          'selectionExtent': 6,
        },
      ]);
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'n world');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
      await settle(tester, 2);
    });

    testWidgets('the input method only collapsed takes Enter after what is '
        'composed over it', (tester) async {
      final controller = await selectHello(tester);
      await moveCaret(tester, controller, 5);
      await composeAtCaret(tester, controller);

      await sendDeltas(tester, [textDelta('hellon world', '\n', 6, 6)]);
      expect(controller.text, 'n\n world');
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
      await settle(tester, 2);
    });

    testWidgets('the input method collapsed to its start stays replaced', (
      tester,
    ) async {
      final controller = await selectHello(tester);
      await moveCaret(tester, controller, 0);
      await composeAtCaret(tester, controller);
      expect(controller.text, ' world');

      await sendDeltas(tester, [
        {
          ...textDelta('nhello world', '', -1, -1),
          'selectionBase': 1,
          'selectionExtent': 1,
        },
      ]);
      expect(controller.text, 'n world');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
      await settle(tester, 2);
    });

    testWidgets(
      'the input method collapsed and moved the caret within is kept',
      (tester) async {
        final controller = await selectHello(tester);
        await moveCaret(tester, controller, 5);
        await moveCaret(tester, controller, 3);

        await composeAtCaret(tester, controller);
        expect(controller.text, 'hello world');
        await settle(tester, 2);
      },
    );

    testWidgets('the input method collapsed to its middle is kept', (
      tester,
    ) async {
      final controller = await selectHello(tester);
      await moveCaret(tester, controller, 2);

      await composeAtCaret(tester, controller);
      expect(controller.text, 'hello world');
      await settle(tester, 2);
    });

    testWidgets('the input method composes over before the same text '
        'leaves that text', (tester) async {
      final controller = CodeForgeController()..text = 'aa';
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 1,
      );
      await tester.pump();
      await sendDeltas(tester, [
        {
          ...textDelta('aa', 'n', 0, 1),
          'composingBase': 0,
          'composingExtent': 1,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'n');
      expect(controller.text, 'a');

      controller.commitComposition();
      await settle(tester, 2);
      expect(controller.text, 'na');
    });
  });

  group('a composition in progress', () {
    Future<CodeForgeController> composeE(
      WidgetTester tester, {
      UndoRedoController? undo,
    }) async {
      final controller = CodeForgeController()..text = 'a:\n  b: tru\nc';
      await pumpEditor(tester, controller, undoController: undo);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 11);
      await tester.pump();
      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'e', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 1,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'e');
      expect(controller.text, 'a:\n  b: tru\nc');
      return controller;
    }

    testWidgets('ended by Enter indents the new line', (tester) async {
      final controller = await composeE(tester);

      await sendDeltas(tester, [textDelta('a:\n  b: true\nc', '\n', 12, 12)]);

      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'a:\n  b: true\n  \nc');
      expect(controller.selection, const TextSelection.collapsed(offset: 15));
      await settle(tester, 2);
    });

    testWidgets('ended by a bracket gets the bracket closed', (tester) async {
      final controller = await composeE(tester);

      await sendDeltas(tester, [textDelta('a:\n  b: true\nc', '(', 12, 12)]);

      expect(controller.text, 'a:\n  b: true()\nc');
      expect(controller.selection, const TextSelection.collapsed(offset: 13));
      await settle(tester, 2);
    });

    testWidgets('an undo takes back before the edit made ahead of it', (
      tester,
    ) async {
      final undo = UndoRedoController();
      addTearDown(undo.dispose);
      final controller = CodeForgeController()..text = 'a:\n  b: t\nc';
      await pumpEditor(tester, controller, undoController: undo);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 9);
      await typeText(tester, controller, 'ru');
      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'e', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 1,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'e');

      expect(undo.undo(), isTrue);
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'a:\n  b: tru\nc');
      expect(undo.undo(), isTrue);
      expect(controller.text, 'a:\n  b: t\nc');

      undo
        ..redo()
        ..redo();
      expect(controller.text, 'a:\n  b: true\nc');
      await settle(tester, 2);
    });

    testWidgets('an undo takes back when it is all there is', (tester) async {
      final undo = UndoRedoController();
      addTearDown(undo.dispose);
      final controller = await composeE(tester, undo: undo);
      expect(undo.canUndo, isFalse);

      expect(undo.undo(), isTrue);

      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'a:\n  b: tru\nc');
      await settle(tester, 2);
    });

    testWidgets('the platform ends without a delta is committed', (
      tester,
    ) async {
      final controller = await composeE(tester);

      await sendDeltas(tester, []);

      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'a:\n  b: true\nc');
      expect(controller.selection, const TextSelection.collapsed(offset: 12));
      await settle(tester, 2);
    });

    testWidgets('is committed when the editor loses focus', (tester) async {
      final controller = await composeE(tester);

      controller.focusNode!.unfocus();
      await tester.pump();
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'a:\n  b: true\nc');

      controller.focusNode!.requestFocus();
      await tester.pump();
      await typeText(tester, controller, '!');
      expect(controller.text, 'a:\n  b: true!\nc');
    });
  });

  testWidgets('a caret the input method moves across identical lines gets the '
      'window at its new place', (tester) async {
    final controller = CodeForgeController()
      ..text = List.filled(10, 'x').join('\n');
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 7);
    await tester.pump();
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    int statesSent() => tester.testTextInput.log
        .where((call) => call.method == 'TextInput.setEditingState')
        .length;
    final sentBefore = statesSent();
    await sendDeltas(tester, [
      {
        ...textDelta(value.text, '', -1, -1),
        'selectionBase': caret + 2,
        'selectionExtent': caret + 2,
      },
    ]);
    expect(controller.selection, const TextSelection.collapsed(offset: 9));
    expect(controller.currentTextEditingValue.text, value.text);
    expect(statesSent(), sentBefore + 1);

    final moved = controller.currentTextEditingValue;
    final movedCaret = moved.selection.extentOffset;
    await sendDeltas(tester, [
      textDelta(moved.text, '', movedCaret - 1, movedCaret),
    ]);
    expect(controller.text, 'x\nx\nx\nx\n\nx\nx\nx\nx\nx');
    await settle(tester, 2);
  });

  group('a window of the same text further along', () {
    late CodeForgeController controller;
    late TextEditingValue value;

    int statesSent(WidgetTester tester) => tester.testTextInput.log
        .where((call) => call.method == 'TextInput.setEditingState')
        .length;

    Future<void> pumpIdenticalLines(WidgetTester tester) async {
      controller = CodeForgeController()
        ..text = List.filled(10, 'x').join('\n');
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 7);
      await tester.pump();
      value = controller.currentTextEditingValue;
    }

    testWidgets('maps an edit made in the one before it where that one put '
        'it', (tester) async {
      await pumpIdenticalLines(tester);
      final moved = value.selection.extentOffset + 2;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, '', -1, -1),
          'selectionBase': moved,
          'selectionExtent': moved,
        },
      ]);
      expect(controller.selection, const TextSelection.collapsed(offset: 9));

      await sendDeltas(tester, [textDelta(value.text, '', moved - 1, moved)]);
      expect(controller.text, 'x\nx\nx\nx\n\nx\nx\nx\nx\nx');
      await settle(tester, 2);
    });

    testWidgets('is sent for a caret a whole editing value moves', (
      tester,
    ) async {
      await pumpIdenticalLines(tester);
      final sentBefore = statesSent(tester);
      tester.testTextInput.updateEditingValue(
        value.copyWith(
          selection: TextSelection.collapsed(
            offset: value.selection.extentOffset + 2,
          ),
        ),
      );
      await tester.pump();

      expect(controller.selection, const TextSelection.collapsed(offset: 9));
      expect(statesSent(tester), sentBefore + 1);
      await settle(tester, 2);
    });
  });

  testWidgets('backspaces on a line longer than the IME window all land', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'x' * 6005;
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 6005);
    await tester.pump();

    var platform = controller.currentTextEditingValue.text;
    expect(platform.length, lessThan(6005));
    for (var i = 0; i < 5; i++) {
      final caret = platform.length;
      await sendDeltas(tester, [textDelta(platform, '', caret - 1, caret)]);
      platform = platform.substring(0, caret - 1);
    }
    expect(controller.length, 6000);
    await settle(tester, 2);
  });

  group('a selection the input method collapses and deletes', () {
    late CodeForgeController controller;
    late UndoRedoController undo;

    Future<void> deleteHello(WidgetTester tester) async {
      controller = CodeForgeController()..text = 'hello world';
      undo = UndoRedoController();
      addTearDown(undo.dispose);
      await pumpEditor(tester, controller, undoController: undo);
      await focusEditor(tester);
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 5,
      );
      await tester.pump();
      await sendDeltas(tester, [
        for (final extent in [0, 5])
          {
            ...textDelta('hello world', '', -1, -1),
            'selectionBase': 5,
            'selectionExtent': extent,
          },
        textDelta('hello world', '', 0, 5),
      ]);
      expect(controller.text, ' world');
    }

    void expectOneUndoRestoresIt() {
      expect(undo.undo(), isTrue);
      expect(controller.text, 'hello world');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 5),
      );
      expect(undo.canUndo, isFalse);
    }

    testWidgets('comes back selected on undo', (tester) async {
      await deleteHello(tester);
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('is typed over in one undo step', (tester) async {
      await deleteHello(tester);
      await sendDeltas(tester, [textDelta(' world', 'x', 0, 0)]);
      expect(controller.text, 'x world');
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });

    testWidgets('is composed over in one undo step', (tester) async {
      await deleteHello(tester);
      await sendDeltas(tester, [
        {
          ...textDelta(' world', 'k', 0, 0),
          'composingBase': 0,
          'composingExtent': 1,
        },
      ]);
      await sendDeltas(tester, [textDelta('k world', '可', 0, 1)]);
      expect(controller.text, '可 world');
      expectOneUndoRestoresIt();
      await settle(tester, 2);
    });
  });

  group('a word the input method marks as composing', () {
    Future<CodeForgeController> markWorld(
      WidgetTester tester,
      TextSelection selection,
    ) async {
      final controller = CodeForgeController()..text = 'hello world';
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      controller.selection = selection;
      await tester.pump();
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, '', -1, -1),
          'selectionBase': value.selection.baseOffset,
          'selectionExtent': value.selection.extentOffset,
          'composingBase': 6,
          'composingExtent': 11,
        },
      ]);
      return controller;
    }

    testWidgets('stays in the document and keeps the selection', (
      tester,
    ) async {
      final controller = await markWorld(
        tester,
        const TextSelection(baseOffset: 0, extentOffset: 5),
      );
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'hello world');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 5),
      );
      await settle(tester, 2);
    });

    testWidgets('is composed once the input method rewrites it', (
      tester,
    ) async {
      final controller = await markWorld(
        tester,
        const TextSelection.collapsed(offset: 11),
      );
      await sendDeltas(tester, [
        {
          ...textDelta('hello world', 'worlds', 6, 11),
          'composingBase': 6,
          'composingExtent': 12,
        },
      ]);
      expect(controller.imeComposition?.displayText, 'worlds');

      await sendDeltas(tester, [
        {
          ...textDelta('hello worlds', '', -1, -1),
          'selectionBase': 12,
          'selectionExtent': 12,
        },
      ]);
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'hello worlds');
      expect(controller.selection, const TextSelection.collapsed(offset: 12));
      await settle(tester, 2);
    });

    testWidgets('is kept as rewritten when the connection closes', (
      tester,
    ) async {
      final controller = await markWorld(
        tester,
        const TextSelection.collapsed(offset: 11),
      );
      await sendDeltas(tester, [
        {
          ...textDelta('hello world', 'worlds', 6, 11),
          'composingBase': 6,
          'composingExtent': 12,
        },
      ]);

      await sendToInputClient(tester, 'TextInputClient.onConnectionClosed');
      await settle(tester, 2);
      expect(controller.isComposingActive, isFalse);
      expect(controller.text, 'hello worlds');
    });
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

    final value = controller.currentTextEditingValue;
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

    final value = controller.currentTextEditingValue;
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

    final value = controller.currentTextEditingValue;
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
      final value = controller.currentTextEditingValue;
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

  test('a read-only document is neither indented nor outdented', () {
    final controller = CodeForgeController()
      ..text = '  a: 1'
      ..readOnly = true;
    addTearDown(controller.dispose);

    controller
      ..indent()
      ..unindent();

    expect(controller.text, '  a: 1');
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
    controller.takeChange();

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
    final edit = controller.takeChange().lines!;
    expect(edit, (line: 0, removed: 10, inserted: 10));
    expect([
      ...before.sublist(0, edit.line),
      ...after.sublist(edit.line, edit.line + edit.inserted + 1),
      ...before.sublist(edit.line + edit.removed + 1),
    ], after);
  });

  test('moving lines carries a selection that spans them', () {
    final controller = CodeForgeController()..text = 'a\nbb\nccc\ndd';
    controller.selection = const TextSelection(baseOffset: 3, extentOffset: 6);

    controller.moveLineUp();
    expect(controller.text, 'bb\nccc\na\ndd');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 1, extentOffset: 4),
    );
    controller.moveLineUp();
    expect(controller.text, 'bb\nccc\na\ndd');

    controller
      ..moveLineDown()
      ..moveLineDown();
    expect(controller.text, 'a\ndd\nbb\nccc');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 6, extentOffset: 9),
    );
    controller.moveLineDown();
    expect(controller.text, 'a\ndd\nbb\nccc');
  });

  test('duplicating copies the caret line or the selection after itself', () {
    final controller = CodeForgeController()..text = 'a: 1\nb: \u{1F600}';
    controller.selection = const TextSelection.collapsed(offset: 6);

    controller.duplicateLine();
    expect(controller.text, 'a: 1\nb: \u{1F600}\nb: \u{1F600}');
    expect(controller.selection, const TextSelection.collapsed(offset: 10));

    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);
    controller.duplicateLine();
    expect(controller.text, 'a: 1a: 1\nb: \u{1F600}\nb: \u{1F600}');
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  test('moving and deleting by word run over blank lines', () {
    final controller = CodeForgeController()..text = 'ab  \n\n   cd ef';
    controller.selection = const TextSelection.collapsed(offset: 2);

    controller.moveWordRight();
    expect(controller.selection, const TextSelection.collapsed(offset: 9));
    controller.moveWordRight();
    expect(controller.selection, const TextSelection.collapsed(offset: 11));

    controller.selection = const TextSelection.collapsed(offset: 9);
    controller.moveWordLeft();
    expect(controller.selection, const TextSelection.collapsed(offset: 6));
    controller.moveWordLeft();
    expect(controller.selection, const TextSelection.collapsed(offset: 5));

    controller.selection = const TextSelection.collapsed(offset: 2);
    controller.deleteWordForward();
    expect(controller.text, 'ab ef');
    controller.selection = const TextSelection.collapsed(offset: 3);
    controller.deleteWordBackward();
    expect(controller.text, 'ef');

    controller.text = 'x  \n  ';
    controller.selection = const TextSelection.collapsed(offset: 1);
    controller.moveWordRight();
    expect(controller.selection, const TextSelection.collapsed(offset: 6));
    controller.selection = const TextSelection.collapsed(offset: 1);
    controller.deleteWordForward();
    expect(controller.text, 'x');
  });
}
