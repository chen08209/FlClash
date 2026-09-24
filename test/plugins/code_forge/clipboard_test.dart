import 'package:code_forge/code_forge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _document = 'proxies:\n  - name: a\n    port: 80\nrules:\n  - MATCH,a';

Future<CodeForgeController> _pump(WidgetTester tester) async {
  final controller = CodeForgeController()..text = _document;
  await pumpEditor(tester, controller);
  await focusEditor(tester);
  return controller;
}

void main() {
  setUpAll(initEditorNative);

  testWidgets('copy with nothing selected pastes the line above the caret', (
    tester,
  ) async {
    final clipboard = mockClipboard(tester);
    final controller = await _pump(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 4,
    );
    controller.copy();
    await tester.pump();
    expect(clipboard.text, '  - name: a\n');

    final caret = controller.getLineStartOffset(3) + 2;
    controller.selection = TextSelection.collapsed(offset: caret);
    await controller.paste();
    await settle(tester);

    expect(controller.lineCount, 6);
    expect(controller.getLineText(3), '  - name: a');
    expect(controller.getLineText(4), 'rules:');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: caret + '  - name: a\n'.length),
    );
  });

  testWidgets('pasted CRLF text comes in as LF', (tester) async {
    mockClipboard(tester).text = '- DIRECT\r\n- REJECT';
    final controller = await _pump(tester);

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await controller.paste();
    await settle(tester);

    expect(controller.text, '$_document- DIRECT\n- REJECT');
  });

  testWidgets('cut with nothing selected removes the line', (tester) async {
    final clipboard = mockClipboard(tester);
    final controller = await _pump(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(2) + 3,
    );
    controller.cut();
    await settle(tester);
    expect(clipboard.text, '    port: 80\n');
    expect(controller.text, 'proxies:\n  - name: a\nrules:\n  - MATCH,a');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.getLineStartOffset(2)),
    );

    controller.selection = TextSelection.collapsed(offset: controller.length);
    controller.cut();
    await settle(tester);
    expect(clipboard.text, '  - MATCH,a\n');
    expect(controller.text, 'proxies:\n  - name: a\nrules:');

    await controller.paste();
    await settle(tester);
    expect(controller.text, 'proxies:\n  - name: a\n  - MATCH,a\nrules:');
  });

  testWidgets('selections and outside clipboard text paste in place', (
    tester,
  ) async {
    final clipboard = mockClipboard(tester);
    final controller = await _pump(tester);
    final nameStart = controller.getLineStartOffset(1) + '  - name: '.length;

    controller.copy();
    controller.selection = TextSelection(
      baseOffset: nameStart,
      extentOffset: nameStart + 1,
    );
    controller.cut();
    await settle(tester);
    expect(clipboard.text, 'a');
    expect(controller.getLineText(1), '  - name: ');

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await controller.paste();
    await settle(tester);
    expect(controller.getLineText(4), '  - MATCH,aa');

    controller.selection = const TextSelection.collapsed(offset: 0);
    controller.copy();
    clipboard.text = 'b\n';
    controller.selection = TextSelection.collapsed(offset: nameStart);
    await controller.paste();
    await settle(tester);
    expect(controller.getLineText(0), 'proxies:');
    expect(controller.getLineText(1), '  - name: b');
    expect(controller.getLineText(2), '');
    expect(controller.getLineText(3), '    port: 80');
  });
}
