import 'package:code_forge/code_forge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _document = 'proxies:\n  - name: a\n    port: 80\nrules:\n  - MATCH,a';

Future<void> _chord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool control = false,
  bool meta = false,
  bool alt = false,
  bool shift = false,
}) async {
  final modifiers = [
    if (control) LogicalKeyboardKey.controlLeft,
    if (meta) LogicalKeyboardKey.metaLeft,
    if (alt) LogicalKeyboardKey.altLeft,
    if (shift) LogicalKeyboardKey.shiftLeft,
  ];
  for (final modifier in modifiers) {
    await tester.sendKeyDownEvent(modifier);
  }
  await tester.sendKeyEvent(key);
  for (final modifier in modifiers.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  await settle(tester, 2);
}

void main() {
  setUpAll(initEditorNative);

  Future<(CodeForgeController, FindController, UndoRedoController)> pump(
    WidgetTester tester, {
    bool readOnly = false,
  }) async {
    final controller = CodeForgeController()..text = _document;
    final finder = FindController(controller);
    final undo = UndoRedoController();
    addTearDown(finder.dispose);
    addTearDown(undo.dispose);
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      undoController: undo,
      readOnly: readOnly,
    );
    await focusEditor(tester);
    return (controller, finder, undo);
  }

  testWidgets('Ctrl+F and Ctrl+H open the finder', (tester) async {
    final (_, finder, _) = await pump(tester);

    await _chord(tester, LogicalKeyboardKey.keyF, control: true);
    expect(finder.isActive, isTrue);
    expect(finder.isReplaceMode, isFalse);

    await _chord(tester, LogicalKeyboardKey.keyH, control: true);
    expect(finder.isReplaceMode, isTrue);

    await _chord(tester, LogicalKeyboardKey.escape);
    expect(finder.isActive, isFalse);
  });

  testWidgets('read-only opens only the plain finder and blocks edits', (
    tester,
  ) async {
    final (controller, finder, _) = await pump(tester, readOnly: true);
    final clipboard = mockClipboard(tester);
    clipboard.text = 'x';

    await _chord(tester, LogicalKeyboardKey.keyH, control: true);
    expect(finder.isActive, isTrue);
    expect(finder.isReplaceMode, isFalse);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 4,
    );
    await _chord(tester, LogicalKeyboardKey.keyD, control: true);
    await _chord(tester, LogicalKeyboardKey.keyV, control: true);
    await _chord(tester, LogicalKeyboardKey.keyX, control: true);
    await _chord(tester, LogicalKeyboardKey.backspace, control: true);
    await _chord(tester, LogicalKeyboardKey.tab);
    expect(controller.text, _document);

    await _chord(tester, LogicalKeyboardKey.keyC, control: true);
    expect(clipboard.text, '  - name: a\n');
  });

  testWidgets('select all, copy, cut, paste and undo, redo', (tester) async {
    final (controller, _, undo) = await pump(tester);
    final clipboard = mockClipboard(tester);

    await _chord(tester, LogicalKeyboardKey.keyA, control: true);
    expect(
      controller.selection,
      TextSelection(baseOffset: 0, extentOffset: controller.length),
    );
    await _chord(tester, LogicalKeyboardKey.keyC, control: true);
    expect(clipboard.text, _document);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(2) + 2,
    );
    await _chord(tester, LogicalKeyboardKey.keyX, control: true);
    expect(clipboard.text, '    port: 80\n');
    expect(controller.lineCount, 4);

    controller.selection = const TextSelection.collapsed(offset: 3);
    await _chord(tester, LogicalKeyboardKey.keyV, control: true);
    expect(controller.getLineText(0), '    port: 80');
    expect(controller.getLineText(1), 'proxies:');

    await _chord(tester, LogicalKeyboardKey.keyZ, control: true);
    await _chord(tester, LogicalKeyboardKey.keyZ, control: true);
    expect(controller.text, _document);
    await _chord(tester, LogicalKeyboardKey.keyY, control: true);
    expect(controller.lineCount, 4);
    await _chord(tester, LogicalKeyboardKey.keyZ, control: true, shift: true);
    expect(controller.getLineText(0), '    port: 80');
    expect(undo.canRedo, isFalse);
  });

  testWidgets('Tab indents and Shift+Tab outdents the selected lines', (
    tester,
  ) async {
    final (controller, _, _) = await pump(tester);
    final tab = controller.tabSpace;

    controller.selection = TextSelection(
      baseOffset: 2,
      extentOffset: controller.getLineStartOffset(1) + 2,
    );
    await _chord(tester, LogicalKeyboardKey.tab);
    expect(controller.getLineText(0), '${tab}proxies:');
    expect(controller.getLineText(1), '$tab  - name: a');

    await _chord(tester, LogicalKeyboardKey.tab, shift: true);
    expect(controller.text, _document);
  });

  testWidgets('Ctrl+arrows move by word and Ctrl+Backspace/Delete delete one', (
    tester,
  ) async {
    final (controller, _, _) = await pump(tester);
    final line = controller.getLineStartOffset(1);

    controller.selection = TextSelection.collapsed(offset: line);
    await _chord(tester, LogicalKeyboardKey.arrowRight, control: true);
    expect(controller.selection.extentOffset, line + 2);
    await _chord(tester, LogicalKeyboardKey.arrowRight, control: true);
    expect(controller.selection.extentOffset, line + 3);
    await _chord(
      tester,
      LogicalKeyboardKey.arrowRight,
      control: true,
      shift: true,
    );
    expect(
      controller.selection,
      TextSelection(baseOffset: line + 3, extentOffset: line + 4),
    );
    await _chord(tester, LogicalKeyboardKey.arrowLeft, control: true);
    expect(controller.selection, TextSelection.collapsed(offset: line + 2));

    controller.selection = TextSelection.collapsed(
      offset: line + '  - name'.length,
    );
    await _chord(tester, LogicalKeyboardKey.backspace, control: true);
    expect(controller.getLineText(1), '  - : a');
    await _chord(tester, LogicalKeyboardKey.delete, control: true);
    expect(controller.getLineText(1), '  -  a');
  });

  testWidgets('Apple platforms use Cmd and Option', (tester) async {
    final (controller, finder, _) = await pump(tester);

    await _chord(tester, LogicalKeyboardKey.keyF, meta: true, alt: true);
    expect(finder.isReplaceMode, isTrue);
    await _chord(tester, LogicalKeyboardKey.escape);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + '  - name'.length,
    );
    await _chord(tester, LogicalKeyboardKey.backspace, alt: true);
    expect(controller.getLineText(1), '  - : a');
    await _chord(tester, LogicalKeyboardKey.keyZ, meta: true);
    expect(controller.text, _document);
    await _chord(tester, LogicalKeyboardKey.keyZ, meta: true, shift: true);
    expect(controller.getLineText(1), '  - : a');
    await _chord(tester, LogicalKeyboardKey.backspace, meta: true);
    expect(controller.getLineText(1), ': a');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
