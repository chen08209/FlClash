import 'package:code_forge/code_forge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void main() {
  setUpAll(initEditorNative);

  testWidgets('mounting the editor keeps another field as the input client', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final title = TextEditingController();
    final showEditor = ValueNotifier(false);
    addTearDown(title.dispose);
    addTearDown(showEditor.dispose);
    await pumpEditor(
      tester,
      controller,
      wrap: (editor) => Column(
        children: [
          TextField(controller: title),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: showEditor,
              builder: (_, show, _) => show ? editor : const SizedBox(),
            ),
          ),
        ],
      ),
    );
    await tester.showKeyboard(find.byType(TextField));

    showEditor.value = true;
    await settle(tester);
    tester.testTextInput.enterText('title');
    await tester.pump();

    expect(title.text, 'title');
    expect(controller.text, 'a: 1');
  });

  testWidgets('toggling read-only applies to the mounted editor', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    await pumpEditor(tester, controller, readOnly: true);
    await focusEditor(tester);
    expect(controller.readOnly, isTrue);

    await pumpEditor(tester, controller);
    expect(controller.readOnly, isFalse);
    controller.selection = TextSelection.collapsed(offset: controller.length);
    await typeText(tester, controller, '2');
    expect(controller.text, 'a: 12');

    await pumpEditor(tester, controller, readOnly: true);
    expect(controller.readOnly, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await settle(tester, 2);
    expect(controller.text, 'a: 12');
  });

  testWidgets('a disposed editor lets go of the controller', (tester) async {
    final controller = CodeForgeController()..text = 'a: 1';
    await pumpEditor(tester, controller, key: const ValueKey(1));
    await focusEditor(tester);
    final firstNode = controller.focusNode;

    await pumpEditor(tester, controller, key: const ValueKey(2));
    expect(controller.focusNode, isNot(same(firstNode)));
    expect(controller.focusNode?.context, isNotNull);
    expect(controller.undoController, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(controller.focusNode, isNull);
    expect(controller.connection, isNull);
    expect(controller.undoController, isNull);
    controller.replaceRange(0, 0, '# ');
    expect(controller.text, '# a: 1');
  });

  group('a composition in progress', () {
    Future<CodeForgeController> compose(WidgetTester tester, {Key? key}) async {
      final controller = CodeForgeController()..text = 'ab';
      await pumpEditor(tester, controller, key: key);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'n', 1, 1),
          'composingBase': 1,
          'composingExtent': 2,
        },
      ]);
      expect(controller.isComposingActive, isTrue);
      return controller;
    }

    testWidgets('is committed when the editor turns read-only', (tester) async {
      final controller = await compose(tester);

      await pumpEditor(tester, controller, readOnly: true);
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(controller.selection, const TextSelection.collapsed(offset: 3));
      await settle(tester, 2);
    });

    testWidgets('is committed when the editor is disposed', (tester) async {
      final controller = await compose(tester);

      await tester.pumpWidget(const SizedBox());
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');
    });

    testWidgets('is committed when the editor is re-keyed', (tester) async {
      final controller = await compose(tester, key: const ValueKey(1));

      await pumpEditor(tester, controller, key: const ValueKey(2));
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');
    });
  });

  testWidgets('a new controller takes over the mounted editor', (tester) async {
    final first = CodeForgeController()..text = 'first: 1';
    final second = CodeForgeController()
      ..text = 'b: 2'
      ..selection = const TextSelection.collapsed(offset: 0);
    await pumpEditor(tester, first);
    await focusEditor(tester);

    await pumpEditor(tester, second);
    expect(first.focusNode, isNull);
    expect(first.connection, isNull);
    expect(first.undoController, isNull);

    await focusEditor(tester);
    expect(second.selection, const TextSelection.collapsed(offset: 4));
    await typeText(tester, second, '3');
    expect(second.text, 'b: 23');
    expect(first.text, 'first: 1');
    expect(second.undoController!.undo(), isTrue);
    expect(second.text, 'b: 2');
  });

  testWidgets('new undo and find controllers take over the mounted editor', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undos = [UndoRedoController(), UndoRedoController()];
    final finders = [FindController(controller), FindController(controller)];
    for (final undo in undos) {
      addTearDown(undo.dispose);
    }
    for (final finder in finders) {
      addTearDown(finder.dispose);
    }
    Future<void> pump(int index) => pumpEditor(
      tester,
      controller,
      undoController: undos[index],
      findController: finders[index],
    );
    await pump(0);
    await focusEditor(tester);
    await typeText(tester, controller, '2');

    await pump(1);
    expect(controller.undoController, same(undos[1]));
    await typeText(tester, controller, '3');
    expect(undos[1].canUndo, isTrue);
    expect(undos[0].undo(), isFalse);
    expect(controller.text, 'a: 123');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(finders[1].isActive, isTrue);
    expect(finders[0].isActive, isFalse);
    await settle(tester, 2);
  });

  testWidgets('a released undo controller leaves the document alone', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(tester, controller, undoController: undo);
    await focusEditor(tester);
    await typeText(tester, controller, '2');
    expect(undo.canUndo, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(undo.undo(), isFalse);
    expect(undo.canUndo, isTrue);
    expect(controller.text, 'a: 12');
  });

  testWidgets('a re-keyed editor keeps the undo controller it shares', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    Future<void> pump(int key) => pumpEditor(
      tester,
      controller,
      undoController: undo,
      key: ValueKey(key),
    );
    await pump(1);
    await focusEditor(tester);
    await typeText(tester, controller, '2');

    await pump(2);
    expect(controller.undoController, same(undo));
    expect(undo.undo(), isTrue);
    expect(controller.text, 'a: 1');
  });

  test('a history another controller took over survives the first', () {
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    final first = CodeForgeController()..setUndoController(undo);
    final second = CodeForgeController()..text = 'b';
    addTearDown(second.dispose);
    second.setUndoController(undo);

    first.dispose();
    second.replaceRange(1, 1, 'x');

    expect(undo.undo(), isTrue);
    expect(second.text, 'b');
  });

  test('dispose releases the rope and the undo controller', () {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    controller
      ..setUndoController(undo)
      ..replaceRange(0, 0, '# ')
      ..dispose();

    expect(controller.rope.core.isDisposed, isTrue);
    expect(undo.undo(), isFalse);
  });

  test('dispose releases the suggestion notifiers', () {
    final controller = CodeForgeController()..text = 'a: 1';
    controller.dispose();
    expect(
      () => controller.suggestionsNotifier.addListener(() {}),
      throwsFlutterError,
    );
    expect(
      () => controller.selectedSuggestionNotifier.addListener(() {}),
      throwsFlutterError,
    );
  });

  test('replacing the text releases the previous rope', () {
    final controller = CodeForgeController()..text = 'a: 1';
    final previous = controller.rope;
    controller.text = 'b: 2';
    expect(previous.core.isDisposed, isTrue);
    expect(controller.rope.core.isDisposed, isFalse);
  });

  testWidgets('disposing the editor mid scroll to a line throws nothing', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 400; i++) 'k$i: $i'].join('\n');
    await pumpEditor(tester, controller);

    controller.scrollToLine(300);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing the editor while it computes folds reports no error', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 12000; i++) 'k$i: {a: $i}'].join('\n');
    final printed = <String?>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message);
    try {
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    } finally {
      debugPrint = original;
    }

    expect(printed, isEmpty);
  });
}
