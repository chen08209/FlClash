import 'dart:async';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    await controller.copy();
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
    await controller.cut();
    await settle(tester);
    expect(clipboard.text, '    port: 80\n');
    expect(controller.text, 'proxies:\n  - name: a\nrules:\n  - MATCH,a');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.getLineStartOffset(2)),
    );

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await controller.cut();
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

    await controller.copy();
    controller.selection = TextSelection(
      baseOffset: nameStart,
      extentOffset: nameStart + 1,
    );
    await controller.cut();
    await settle(tester);
    expect(clipboard.text, 'a');
    expect(controller.getLineText(1), '  - name: ');

    controller.selection = TextSelection.collapsed(offset: controller.length);
    await controller.paste();
    await settle(tester);
    expect(controller.getLineText(4), '  - MATCH,aa');

    controller.selection = const TextSelection.collapsed(offset: 0);
    await controller.copy();
    clipboard.text = 'b\n';
    controller.selection = TextSelection.collapsed(offset: nameStart);
    await controller.paste();
    await settle(tester);
    expect(controller.getLineText(0), 'proxies:');
    expect(controller.getLineText(1), '  - name: b');
    expect(controller.getLineText(2), '');
    expect(controller.getLineText(3), '    port: 80');
  });

  testWidgets('a large copy lands before the paste or copy after it', (
    tester,
  ) async {
    final clipboard = mockClipboard(tester);
    final document = List.generate(20000, (i) => 'line $i').join('\n');
    final controller = CodeForgeController()..text = document;
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    await tester.runAsync(() async {
      controller.selectAll();
      unawaited(controller.copy());
      controller.selection = TextSelection.collapsed(offset: controller.length);
      await controller.paste();
    });
    await settle(tester);
    expect(controller.text, '$document$document');

    await tester.runAsync(() async {
      controller.selectAll();
      unawaited(controller.copy());
      controller.selection = const TextSelection.collapsed(offset: 0);
      unawaited(controller.copy());
      await controller.paste();
    });
    await settle(tester);
    expect(clipboard.text, 'line 0\n');
    expect(controller.getLineText(1), 'line 0');
  });

  testWidgets('a cut the clipboard refuses keeps the text and says so', (
    tester,
  ) async {
    final controller = await _pump(tester);
    var failures = 0;
    controller.onClipboardWriteFailed = () => failures++;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => throw PlatformException(code: 'error'),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.getLineStartOffset(1),
    );
    await controller.cut();
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(2),
    );
    await controller.cut();
    await settle(tester);

    expect(controller.text, _document);
    expect(failures, 2);
  });

  group('a cut still writing the clipboard leaves the text', () {
    late MockClipboard clipboard;
    late CodeForgeController controller;
    late Future<void> cut;

    Future<void> startCut(WidgetTester tester) async {
      clipboard = mockClipboard(tester);
      controller = await _pump(tester);
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.getLineStartOffset(1),
      );
      cut = controller.cut();
    }

    testWidgets('once the selection moves', (tester) async {
      await startCut(tester);
      controller.selection = TextSelection.collapsed(offset: controller.length);
      await cut;
      await settle(tester);

      expect(clipboard.text, 'proxies:\n');
      expect(controller.text, _document);
    });

    testWidgets('once the editor is read-only', (tester) async {
      await startCut(tester);
      controller.readOnly = true;
      await cut;
      await settle(tester);

      expect(controller.text, _document);
    });

    testWidgets('once the controller is disposed', (tester) async {
      await startCut(tester);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await cut;

      expect(clipboard.text, 'proxies:\n');
    });
  });

  testWidgets('a paste still reading the clipboard leaves a disposed '
      'controller alone', (tester) async {
    mockClipboard(tester).text = 'x';
    final controller = await _pump(tester);

    final paste = controller.paste();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await paste;
  });

  testWidgets('a paste the clipboard fails leaves the text', (tester) async {
    final controller = await _pump(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => throw PlatformException(code: 'error'),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await controller.paste();

    expect(controller.text, _document);
  });

  testWidgets('Android is not sent a clip past what one Binder call carries', (
    tester,
  ) async {
    const limit = 1 << 20;
    final clipboard = mockClipboard(tester);
    final controller = CodeForgeController()
      ..text = List.filled(1024, 'x' * 1024).join('\n');
    addTearDown(controller.dispose);
    final document = controller.text;
    var failures = 0;
    controller.onClipboardWriteFailed = () => failures++;

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      controller.selectAll();
      await controller.cut();
      expect(clipboard.text, isNull);
      expect(failures, 1);
      expect(controller.text, document);

      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: limit - 1,
      );
      await tester.runAsync(controller.copy);
      expect(clipboard.text, hasLength(limit - 1));
      expect(failures, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
