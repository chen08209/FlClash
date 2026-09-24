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
    expect(controller.requestImeReset, isNull);
    expect(controller.undoController, isNull);
    controller.replaceRange(0, 0, '# ');
    expect(controller.text, '# a: 1');
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
