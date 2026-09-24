import 'dart:ui' as ui;

import 'package:code_forge/code_forge.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show
        AxisDirection,
        Scrollable,
        ScrollableState,
        ScrollController,
        ScrollPosition;
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

  testWidgets('a tap past a composition lands on the text shown there', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'aaaa bbbb';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    final (_, lineStart) = _paintedParagraphs(tester).first;

    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump();
    await _compose(tester, controller, 'xy');
    expect(controller.isComposingActive, isTrue);

    final renderer = _renderer(tester) as RenderBox;
    await tester.tapAt(
      renderer.localToGlobal(lineStart + const Offset(8 * _glyphWidth + 4, 8)),
    );
    await settle(tester, 2);

    expect(controller.text, 'aaaaxy bbbb');
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  testWidgets('an edit after the input method dropped a composition is laid '
      'out', (tester) async {
    late ScrollController vertical;
    final controller = CodeForgeController()..text = 'ab\ncd';
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 40),
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    await _compose(tester, controller, 'x');
    expect(controller.isComposingActive, isTrue);

    final setClient = tester.testTextInput.log.lastWhere(
      (call) => call.method == 'TextInput.setClient',
    );
    final client = (setClient.arguments as List)[0] as int;
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        MethodCall('TextInputClient.onConnectionClosed', [client]),
      ),
      (_) {},
    );
    await tester.pump();
    expect(controller.isComposingActive, isFalse);

    controller.selection = const TextSelection.collapsed(offset: 2);
    controller.replaceRange(2, 2, '\n');
    await tester.pump();

    expect(
      vertical.position.maxScrollExtent,
      3 * editorLineHeight + editorTopPadding - 40,
    );
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

  Future<void> typeOne(
    WidgetTester tester,
    CodeForgeController controller,
    String char, {
    bool pump = true,
  }) {
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    return sendDeltas(tester, [
      textDelta(value.text, char, caret, caret),
    ], pump: pump);
  }

  testWidgets('typing on a line pauses the bracket highlight until it rests', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: {\n  b: 1\n}';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_bracketBoxes(tester), hasLength(2));

    await typeOne(tester, controller, 'x');
    expect(controller.isBufferActive, isTrue);
    expect(_bracketBoxes(tester), isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    final boxes = _bracketBoxes(tester);
    final (_, lineStart) = _paintedParagraphs(tester).first;
    expect(boxes, hasLength(2));
    expect(boxes.first.left, lineStart.dx + 4 * _glyphWidth - 1.5);
  });

  testWidgets('typing over a closing bracket repaints the caret at once', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'f()';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();

    await typeOne(tester, controller, ')', pump: false);

    expect(controller.text, 'f()');
    expect(controller.selection, const TextSelection.collapsed(offset: 3));
    expect(_renderer(tester).debugNeedsPaint, isTrue);
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

  SyntaxHighlighter yamlHighlighter() {
    final highlighter = SyntaxHighlighter(
      language: langYaml,
      editorTheme: atomOneLightTheme,
    );
    addTearDown(highlighter.dispose);
    return highlighter;
  }

  test('a line is highlighted once, wherever edits move it', () {
    final highlighter = yamlHighlighter();
    const text = 'a: 1 # note';
    final span = highlighter.lineSpan(text);
    expect(span, isNotNull);

    expect(highlighter.hasLineSpan(text), isTrue);
    expect(highlighter.lineSpan(text), same(span));
  });

  test(
    'a batch highlighted off the UI isolate matches one line at a time',
    () async {
      final highlighter = yamlHighlighter();
      final lines = [
        for (var i = 0; i < 100; i++) 'key$i: "value" # ${'note ' * 5}',
      ];

      await highlighter.preHighlightLines([
        for (var i = 0; i < lines.length; i++) i,
      ], (line) => lines[line]);

      final inline = yamlHighlighter();
      for (final line in lines) {
        expect(highlighter.hasLineSpan(line), isTrue);
        expect(highlighter.lineSpan(line), inline.lineSpan(line));
      }
    },
  );

  test('a line too long to highlight stays plain text', () {
    final highlighter = yamlHighlighter();
    final line = 'key: ${'v' * SyntaxHighlighter.maxHighlightedLineLength}';

    expect(highlighter.lineSpan(line), isNull);
    expect(highlighter.hasLineSpan(line), isTrue);
    expect(highlighter.lineSpan('key: v'), isNotNull);
  });

  testWidgets('a line too long to highlight is painted from a slice in view', (
    tester,
  ) async {
    const viewWidth = 400.0;
    final long = List.filled(3000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(viewWidth, 600));
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);

    final painted = _paintedParagraphs(tester);
    final lineStart = painted[0].$2.dx;
    final (slice, at) = painted[1];
    expect(slice.longestLine, lessThan(4 * viewWidth));
    expect(at.dx, lessThanOrEqualTo(0));
    expect(at.dx + slice.longestLine, greaterThanOrEqualTo(viewWidth));
    expect(at.dx - lineStart, greaterThan(0));
    expect((at.dx - lineStart) % _glyphWidth, 0);
  });

  testWidgets('a selection over a line too long to highlight is drawn around '
      'the view', (tester) async {
    const viewWidth = 400.0;
    final long = List.filled(3000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(viewWidth, 600));
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.length,
    );
    await tester.pump();

    final longRow = _selectionRects(
      tester,
    ).firstWhere((rect) => rect.top > 0 && rect.width > viewWidth);
    expect(longRow.width, lessThan(4 * viewWidth));
    expect(longRow.left, lessThanOrEqualTo(0));
    expect(longRow.right, greaterThanOrEqualTo(viewWidth));
    final lineStart = _paintedParagraphs(tester).first.$2.dx;
    expect((longRow.left - lineStart) % _glyphWidth, 0);
  });

  testWidgets('search highlights on a long line are drawn around the view', (
    tester,
  ) async {
    const viewWidth = 400.0;
    final long = List.filled(4000, 'ab').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    final finder = FindController(controller);
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      size: const Size(viewWidth, 600),
    );
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);
    finder.isActive = true;
    finder.find('ab', scrollToMatch: false);
    await tester.pump();

    final lineStart = _paintedParagraphs(tester).first.$2.dx;
    final rects = _rectsOf(tester, {0xFF01A2FF, 0xA348D7FF});
    expect(rects, isNotEmpty);
    expect(rects.length, lessThan(4 * viewWidth / (3 * _glyphWidth)));
    final inView = rects.where((r) => r.left >= 0 && r.right <= viewWidth);
    expect(inView, isNotEmpty);
    for (final rect in inView) {
      expect((rect.left - lineStart) % (3 * _glyphWidth), 0);
      expect(rect.width, 2 * _glyphWidth);
    }
  });

  testWidgets('a long wrapped line is painted from the rows in view', (
    tester,
  ) async {
    late ScrollController vertical;
    final long = List.filled(4000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 600),
      lineWrap: true,
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    vertical.jumpTo(3000);
    await tester.pump();

    final (slice, at) = _paintedParagraphs(tester).first;
    final lineTop = editorTopPadding + editorLineHeight - vertical.offset;
    expect(at.dy, lessThanOrEqualTo(0));
    expect(at.dy + slice.height, greaterThanOrEqualTo(600));
    expect(slice.height, lessThan(vertical.position.maxScrollExtent / 4));
    expect((at.dy - lineTop) % editorLineHeight, 0);

    const tap = Offset(200, 300);
    await focusEditor(tester);
    await tester.tapAt((_renderer(tester) as RenderBox).localToGlobal(tap));
    await settle(tester, 2);
    final caret = controller.selection.extentOffset;
    controller.selection = TextSelection(
      baseOffset: caret,
      extentOffset: caret + 1,
    );
    await tester.pump();
    final rect = _selectionRects(tester).single;
    expect(rect.top, lessThanOrEqualTo(tap.dy));
    expect(rect.bottom, greaterThan(tap.dy));
    expect((rect.left - tap.dx).abs(), lessThanOrEqualTo(_glyphWidth));
  });

  testWidgets('a line shown whole keeps its slices in place while it scrolls', (
    tester,
  ) async {
    final long = List.generate(30000, (i) => '${i % 10}').join();
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(400, 600));
    await focusEditor(tester);
    final lineStart = controller.getLineStartOffset(1);
    controller.selection = TextSelection.collapsed(offset: lineStart + 12000);
    await settle(tester, 2);

    final horizontal = _horizontalScroll(tester);
    for (final step in [...List.filled(8, 150.0), ...List.filled(12, -150.0)]) {
      horizontal.jumpTo(horizontal.pixels + step);
      await tester.pump();
      final column = (horizontal.pixels / _glyphWidth).round() + 5;
      controller.selection = TextSelection(
        baseOffset: lineStart + column,
        extentOffset: lineStart + column + 3,
      );
      await tester.pump();
      final textStart = _paintedParagraphs(tester).first.$2.dx;
      final rect = _selectionRects(tester).single;
      expect(rect.left - textStart, column * _glyphWidth);
      expect(rect.width, 3 * _glyphWidth);
    }
  });

  group('a line past the cut', () {
    const cut = 10000;
    CodeForgeController longLine() =>
        CodeForgeController()..text = 'a: 1\n${'x' * (3 * cut)}\nb: 2';

    testWidgets('is shown up to the cut with a marker after it', (
      tester,
    ) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.length,
      );
      await tester.pump();

      final lineStart = _paintedParagraphs(tester).first.$2.dx;
      expect(_cutMarker(tester)!.dx - lineStart, cut * _glyphWidth);
    });

    testWidgets('is shown whole once the caret moves past the cut', (
      tester,
    ) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + cut,
      );
      await settle(tester, 2);
      expect(_cutMarker(tester), isNotNull);

      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + cut + 1,
      );
      await settle(tester, 2);
      expect(_cutMarker(tester), isNull);
    });

    testWidgets('scrolls to a caret placed far past the cut', (tester) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      await focusEditor(tester);
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + 2 * cut,
      );
      await settle(tester, 3);

      final horizontal = _horizontalScroll(tester);
      expect(
        horizontal.pixels,
        greaterThan(2 * cut * _glyphWidth - horizontal.viewportDimension),
      );
    });

    testWidgets('is shown whole by a tap past the cut', (tester) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      await focusEditor(tester);
      final lineStart = controller.getLineStartOffset(1);
      controller.selection = TextSelection.collapsed(offset: lineStart + cut);
      await settle(tester, 2);
      final horizontal = _horizontalScroll(tester);
      horizontal.jumpTo(horizontal.maxScrollExtent);
      await tester.pump();

      final marker = _cutMarker(tester)!;
      final renderer = _renderer(tester) as RenderBox;
      expect(
        marker.dx + 2 * _glyphWidth,
        lessThanOrEqualTo(renderer.size.width),
      );
      await tester.tapAt(renderer.localToGlobal(marker + const Offset(20, 8)));
      await settle(tester, 2);

      expect(_cutMarker(tester), isNull);
      expect(controller.selection.extentOffset, lineStart + cut + 1);
    });

    testWidgets('is not cut when lines wrap', (tester) async {
      final controller = longLine();
      await pumpEditor(
        tester,
        controller,
        size: const Size(400, 600),
        lineWrap: true,
      );
      await tester.pump();
      expect(_cutMarker(tester), isNull);
    });
  });
}

Offset? _cutMarker(WidgetTester tester) {
  for (final (paragraph, at) in _paintedParagraphs(tester)) {
    if (paragraph.longestLine == 2 * _glyphWidth) return at;
  }
  return null;
}

List<Rect> _rectsOf(WidgetTester tester, Set<int> colors) {
  final rects = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRect &&
          colors.contains((args[1] as Paint).color.toARGB32())) {
        rects.add(args[0] as Rect);
      }
      return true;
    }),
  );
  return rects;
}

ScrollPosition _horizontalScroll(WidgetTester tester) => tester
    .stateList<ScrollableState>(find.byWidgetPredicate((w) => w is Scrollable))
    .firstWhere((s) => s.axisDirection == AxisDirection.right)
    .position;

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
