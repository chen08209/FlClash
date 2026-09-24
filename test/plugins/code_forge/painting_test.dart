import 'dart:ui' as ui;

import 'package:code_forge/code_forge.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

const _glyphWidth = 16.0;

RenderObject _renderer(WidgetTester tester) => tester.allRenderObjects
    .firstWhere((r) => r.runtimeType.toString() == '_CodeFieldRenderer');

List<(ui.Paragraph, Offset)> _paintedParagraphs(WidgetTester tester) {
  final painted = <(ui.Paragraph, Offset)>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawParagraph) {
        painted.add((args[0] as ui.Paragraph, args[1] as Offset));
      }
      return true;
    }),
  );
  return painted;
}

Future<void> _compose(
  WidgetTester tester,
  CodeForgeController controller,
  String text,
) async {
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
              'deltaText': text,
              'deltaStart': caret,
              'deltaEnd': caret,
              'selectionBase': caret + text.length,
              'selectionExtent': caret + text.length,
              'selectionAffinity': 'TextAffinity.downstream',
              'selectionIsDirectional': false,
              'composingBase': caret,
              'composingExtent': caret + text.length,
            },
          ],
        },
      ]),
    ),
    (_) {},
  );
  await tester.pump();
}

void main() {
  setUpAll(initEditorNative);

  testWidgets('the composition overlay redraws the rest of the line after '
      'an astral character', (tester) async {
    final controller = CodeForgeController()..text = '\u{1F600}ab\nc';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();
    await _compose(tester, controller, 'x');
    expect(controller.isComposingActive, isTrue);

    final painted = _paintedParagraphs(tester);
    final (composing, composingAt) = painted[painted.length - 2];
    final (remainder, remainderAt) = painted.last;
    expect(composing.longestLine, _glyphWidth);
    expect(remainderAt.dx - composingAt.dx, _glyphWidth);
    expect(remainder.longestLine, _glyphWidth);
  });

  testWidgets('a selection starting at a line end marks that line end', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'abcd\nef';
    await pumpEditor(tester, controller);
    controller.selection = const TextSelection(baseOffset: 4, extentOffset: 6);
    await tester.pump();

    final rects = _selectionRects(tester);
    expect(rects, hasLength(2));
    final (_, lineStart) = _paintedParagraphs(tester).first;
    expect(rects.first.left, lineStart.dx + 4 * _glyphWidth);
    expect(rects.last.left, lineStart.dx);
  });

  testWidgets('an edit between a bracket pair moves its highlight along', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: {\n  b: 1\n}';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_bracketBoxes(tester), hasLength(2));

    controller.replaceRange(5, 5, 'x');
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    final boxes = _bracketBoxes(tester);
    expect(boxes, hasLength(2));
    expect(boxes.last.top - boxes.first.top, 2 * editorLineHeight);
  });

  test('a highlighted line stays highlighted after an edit above it', () {
    final highlighter = SyntaxHighlighter(
      language: langYaml,
      editorTheme: atomOneLightTheme,
    );
    addTearDown(highlighter.dispose);
    const text = 'a: 1 # note';
    final span = highlighter.getLineSpan(3, text);
    expect(span, isNotNull);

    highlighter.applyDocumentEdit(0);
    expect(highlighter.hasCachedLineSpan(3, text), isTrue);
    expect(highlighter.getCachedLineSpan(3, text), same(span));
  });
}

List<Rect> _selectionRects(WidgetTester tester) {
  final rects = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRect &&
          (args[1] as Paint).color.toARGB32() ==
              CodeSelectionStyle().selectionColor.toARGB32()) {
        rects.add(args[0] as Rect);
      }
      return true;
    }),
  );
  return rects;
}

List<Rect> _bracketBoxes(WidgetTester tester) {
  final boxes = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRSuperellipse &&
          ((args[1] as Paint).strokeWidth - 1.2).abs() < 0.01) {
        boxes.add((args[0] as RSuperellipse).outerRect);
      }
      return true;
    }),
  );
  return boxes;
}
