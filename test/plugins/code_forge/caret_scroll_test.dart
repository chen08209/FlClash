import 'package:code_forge/code_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

const _glyphWidth = 16.0;
const _gutterWidth = 57.6;

void main() {
  setUpAll(initEditorNative);

  testWidgets('the caret scrolls into view clear of the initial padding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const padding = EdgeInsets.only(right: 100, bottom: 100);
    late ScrollController vertical;
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 40; i++) 'a' * 60].join('\n');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeForge(
            controller: controller,
            language: langYaml,
            editorTheme: atomOneLightTheme,
            textStyle: const TextStyle(
              fontSize: 16,
              height: editorLineHeight / 16,
            ),
            innerPadding: padding,
            onContextMenu: (_, _) {},
            suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
            scrollbarBuilder: (_, details, child) {
              vertical = details.controller;
              return child;
            },
          ),
        ),
      ),
    );
    await settle(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(30) + 60,
    );
    await settle(tester);

    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    final caretX = _gutterWidth + 60 * _glyphWidth - horizontal.offset;
    final caretBottom = 31 * editorLineHeight - vertical.offset;
    expect(caretX, lessThanOrEqualTo(400 - padding.right));
    expect(caretBottom, lessThanOrEqualTo(300 - padding.bottom));
    expect(caretX, greaterThan(400 - padding.right - _glyphWidth));
    expect(caretBottom, greaterThan(300 - padding.bottom - editorLineHeight));
  });

  testWidgets('the view follows a caret the input method moves', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a' * 100;
    await pumpEditor(tester, controller, size: const Size(400, 300));
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 0);
    await settle(tester, 2);
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    expect(horizontal.offset, 0);

    await sendDeltas(tester, [
      {
        ...textDelta(controller.currentTextEditingValue.text, '', -1, -1),
        'selectionBase': 80,
        'selectionExtent': 80,
      },
    ]);
    await settle(tester, 2);

    expect(controller.selection, const TextSelection.collapsed(offset: 80));
    final caretX = _gutterWidth + 80 * _glyphWidth - horizontal.offset;
    expect(caretX, lessThanOrEqualTo(400));
  });

  testWidgets('the view follows the caret to the end of a pasted line wider '
      'than it', (tester) async {
    final clipboard = mockClipboard(tester)..text = 'b' * 100;
    final controller = CodeForgeController()..text = 'a\n\na';
    await pumpEditor(tester, controller, size: const Size(400, 300));
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    await settle(tester, 2);
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;

    await tester.runAsync(controller.paste);
    await settle(tester);

    expect(controller.getLineText(1), clipboard.text);
    final caretX = _gutterWidth + 100 * _glyphWidth - horizontal.offset;
    expect(caretX, lessThanOrEqualTo(400));
    expect(caretX, greaterThan(400 - 2 * _glyphWidth));
  });

  testWidgets('a long line far below the first screen widens the content '
      'once scrolled to', (tester) async {
    late ScrollController vertical;
    final controller = CodeForgeController()
      ..text = [
        for (var i = 0; i < 200; i++) i == 150 ? 'b' * 100 : 'a',
      ].join('\n');
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 300),
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    expect(horizontal.position.maxScrollExtent, 0);

    vertical.jumpTo(140 * editorLineHeight);
    await settle(tester, 2);

    expect(
      horizontal.position.maxScrollExtent,
      greaterThanOrEqualTo(_gutterWidth + 100 * _glyphWidth - 400),
    );
  });
}
