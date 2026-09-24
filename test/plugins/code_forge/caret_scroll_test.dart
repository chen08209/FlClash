import 'package:code_forge/code_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

const _glyphWidth = 16.0;
const _gutterWidth = 45.6;

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
}
