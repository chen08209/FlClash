import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

// Ten lines, so inserting two keeps two-digit line numbers: a wider gutter
// would narrow the wrap width and change every row count.
final _lines = [
  'root:',
  '  a: ${'x' * 120}',
  '  b: {',
  '    c: 1',
  '    d: 2',
  '  }',
  '  e: ${'y' * 60}',
  'f: 1',
  'g: 2',
  'end: true',
];

const _viewSize = Size(400, 1200);
const _textX = 300.0;

// Taps below the document also land on its last line, so the scan stops at
// the first hit on it and every fixture keeps its last line a single row.
typedef _Row = ({int line, int offset});

Future<List<_Row>> _tapEveryRow(
  WidgetTester tester,
  CodeForgeController controller,
) async {
  final rows = <_Row>[];
  final origin = tester.getTopLeft(find.byType(CodeForge));
  for (
    var y = editorTopPadding + editorLineHeight / 2;
    y < _viewSize.height - editorLineHeight;
    y += editorLineHeight
  ) {
    await tester.tapAt(origin + Offset(_textX, y));
    await tester.pump(const Duration(milliseconds: 500));
    final offset = controller.selection.extentOffset;
    rows.add((line: controller.getLineAtOffset(offset), offset: offset));
  }
  final lastLine = rows.indexWhere(
    (row) => row.line == controller.lineCount - 1,
  );
  expect(lastLine, isNonNegative, reason: 'the document fits the view');
  return rows.sublist(0, lastLine + 1);
}

Map<int, List<int>> _rowsByLine(List<_Row> rows) {
  final byLine = <int, List<int>>{};
  for (final row in rows) {
    byLine.putIfAbsent(row.line, () => []).add(row.offset);
  }
  return byLine;
}

void _expectContiguous(List<_Row> rows, List<int> visibleLines) {
  final order = <int>[];
  for (final row in rows) {
    if (order.isEmpty || order.last != row.line) order.add(row.line);
  }
  expect(order, visibleLines, reason: 'lines hit from top to bottom');
}

// With a 16px font and two-digit line numbers the gutter is 55.2px wide; its
// last 20px hold the fold icons.
const _lineNumberX = 12.0;
const _foldIconX = 48.0;

Offset _gutterAt(
  WidgetTester tester,
  List<_Row> rows,
  int line, {
  int row = 0,
  double x = _lineNumberX,
}) {
  final index = rows.indexWhere((r) => r.line == line) + row;
  return tester.getTopLeft(find.byType(CodeForge)) +
      Offset(x, editorTopPadding + editorLineHeight * (index + 0.5));
}

TextSelection _lineSelection(
  CodeForgeController controller,
  int from,
  int to,
) => TextSelection(
  baseOffset: controller.getLineStartOffset(from),
  extentOffset: to < controller.lineCount
      ? controller.getLineStartOffset(to)
      : controller.length,
);

void main() {
  setUpAll(initEditorNative);

  Future<CodeForgeController> pumpWrapped(WidgetTester tester) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    await pumpEditor(tester, controller, lineWrap: true, size: _viewSize);
    return controller;
  }

  testWidgets('taps land on the wrapped line painted at that height', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);

    final rows = await _tapEveryRow(tester, controller);
    _expectContiguous(rows, List.generate(_lines.length, (i) => i));

    final byLine = _rowsByLine(rows);
    for (final line in [0, 2, 3, 4, 5, 7, 8, 9]) {
      expect(byLine[line], hasLength(1), reason: 'line $line is one row');
    }
    final longRows = byLine[1]!.length;
    final shorterRows = byLine[6]!.length;
    expect(shorterRows, greaterThan(1));
    expect(longRows, greaterThan(shorterRows));
    for (final line in [1, 6]) {
      final offsets = byLine[line]!;
      for (var i = 1; i < offsets.length; i++) {
        expect(
          offsets[i],
          greaterThan(offsets[i - 1]),
          reason: 'row $i of line $line maps further into the line',
        );
      }
    }
  });

  testWidgets('a folded block takes no rows and taps skip it', (tester) async {
    final controller = await pumpWrapped(tester);
    final unfolded = await _tapEveryRow(tester, controller);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);
    expect(controller.isLineInFoldedRegion(5), isTrue);
    expect(controller.isLineInFoldedRegion(6), isFalse);

    final folded = await _tapEveryRow(tester, controller);
    _expectContiguous(folded, [0, 1, 2, 6, 7, 8, 9]);
    expect(folded, hasLength(unfolded.length - 3));
    expect(_rowsByLine(folded)[6], hasLength(_rowsByLine(unfolded)[6]!.length));
  });

  testWidgets('taps track lines inserted above a fold', (tester) async {
    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    final before = await _tapEveryRow(tester, controller);

    controller.replaceRange(0, 0, 'first: 1\nsecond: 2\n');
    await settle(tester);
    expect(controller.lineCount, _lines.length + 2);
    expect(controller.isLineInFoldedRegion(5), isTrue);
    expect(controller.isLineInFoldedRegion(8), isFalse);

    final after = await _tapEveryRow(tester, controller);
    _expectContiguous(after, [0, 1, 2, 3, 4, 8, 9, 10, 11]);
    expect(after, hasLength(before.length + 2));
    expect(
      [for (final row in after.skip(2)) row.line - 2],
      [for (final row in before) row.line],
    );
  });

  testWidgets('tapping the fold icon folds and unfolds a block', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final text = controller.text;
    final unfolded = await _tapEveryRow(tester, controller);
    final gutterTap = _gutterAt(tester, unfolded, 2, x: _foldIconX);

    await tester.tapAt(gutterTap);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);
    expect(visibleText(controller), isNot(contains('    c: 1')));
    expect(controller.text, text);

    await tester.tapAt(gutterTap);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isFalse);
    expect(visibleText(controller), text);
    _expectContiguous(
      await _tapEveryRow(tester, controller),
      List.generate(_lines.length, (i) => i),
    );
  });

  testWidgets('replacing the whole text resets lines, folds and the caret', (
    tester,
  ) async {
    final replacement = [
      'other:',
      '  z: ${'q' * 90}',
      '  list: [',
      '    1,',
      '    2,',
      '  ]',
      for (var i = 0; i < 5; i++) '  k$i: $i',
      'last: ${'w' * 150}',
      'end: 1',
    ].join('\n');
    final fresh = CodeForgeController()..text = replacement;
    await pumpEditor(tester, fresh, lineWrap: true, size: _viewSize);
    final expected = await _tapEveryRow(tester, fresh);
    _expectContiguous(expected, List.generate(13, (i) => i));
    await tester.pumpWidget(const SizedBox());

    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);

    controller.text = replacement;
    await settle(tester);
    expect(controller.lineCount, 13);
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.length),
    );
    expect(controller.foldings, isEmpty);
    expect(controller.isLineInFoldedRegion(3), isFalse);
    expect(await _tapEveryRow(tester, controller), expected);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(4), isTrue);
    expect(controller.isLineInFoldedRegion(6), isFalse);
  });

  testWidgets('clicking a line number selects the whole line', (tester) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 3));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 3, 4));

    await tester.tapAt(_gutterAt(tester, rows, 2));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 2, 3));
    expect(controller.isLineInFoldedRegion(3), isFalse);
  });

  testWidgets('a line number selects every row of a wrapped line', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);
    expect(_rowsByLine(rows)[1]!.length, greaterThan(1));

    await tester.tapAt(_gutterAt(tester, rows, 1, row: 1));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 1, 2));
  });

  testWidgets('a folded block is selected whole from its line number', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 2));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 2, 6));
    expect(controller.isLineInFoldedRegion(3), isTrue);
  });

  testWidgets('dragging over line numbers extends by whole lines', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    final down = await tester.startGesture(_gutterAt(tester, rows, 3));
    await tester.pump();
    await down.moveTo(_gutterAt(tester, rows, 5));
    await tester.pump();
    expect(controller.selection, _lineSelection(controller, 3, 6));
    await down.moveTo(_gutterAt(tester, rows, 1, row: 1));
    await tester.pump();
    await down.up();
    await settle(tester, 2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: controller.getLineStartOffset(4),
        extentOffset: controller.getLineStartOffset(1),
      ),
    );
  });

  testWidgets('shift-clicking a line number extends from the base', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);
    final base = controller.getLineStartOffset(4) + 2;

    Future<void> shiftClick(int line) async {
      controller.selection = TextSelection.collapsed(offset: base);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tapAt(_gutterAt(tester, rows, line));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await settle(tester, 2);
    }

    await shiftClick(7);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: base,
        extentOffset: controller.getLineStartOffset(8),
      ),
    );

    await shiftClick(2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: base,
        extentOffset: controller.getLineStartOffset(2),
      ),
    );
  });

  testWidgets('the last line number selects to the end of the text', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 9));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 9, 10));
    expect(controller.selection.extentOffset, controller.length);
  });

  testWidgets('dragging to the right edge stops at the line end', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    await pumpEditor(tester, controller);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    const rowY = editorTopPadding + editorLineHeight * 7.5;

    final drag = await tester.startGesture(
      origin + const Offset(_lineNumberX + 50, rowY),
    );
    await tester.pump();
    await drag.moveTo(
      origin + Offset(tester.getSize(find.byType(CodeForge)).width - 2, rowY),
    );
    await tester.pump();
    await drag.up();
    await settle(tester, 2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: controller.getLineStartOffset(7),
        extentOffset: controller.getLineStartOffset(7) + _lines[7].length,
      ),
    );
  });

  testWidgets('a shift-click keeps its base while the mouse moves on', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = List.generate(200, (i) => 'line $i').join('\n');
    await pumpEditor(tester, controller);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    const base = 3;
    controller.selection = const TextSelection.collapsed(offset: base);
    await tester.pump();

    final mouse = TestPointer(1, PointerDeviceKind.mouse)
      ..hover(origin + const Offset(_textX, 300));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 1500)));
    await settle(tester, 2);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    final click = await tester.startGesture(
      origin + const Offset(_textX, 300),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await click.moveBy(const Offset(16, 0));
    await tester.pump();
    await click.up();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await settle(tester, 2);

    expect(controller.selection.baseOffset, base);
    expect(
      controller.getLineAtOffset(controller.selection.extentOffset),
      greaterThan(60),
    );
  });

  testWidgets('each right click asks for the context menu where it landed', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    final requests = <Offset>[];
    await pumpEditor(
      tester,
      controller,
      onContextMenu: (context, request) => requests.add(request.globalPosition),
    );
    final at =
        tester.getTopLeft(find.byType(CodeForge)) +
        const Offset(_textX, editorTopPadding + editorLineHeight * 2.5);

    for (var i = 0; i < 2; i++) {
      await tester.tapAt(at, buttons: kSecondaryButton);
      await settle(tester, 2);
    }
    expect(requests, [at, at]);
  });

  testWidgets('the context menu gets the selected rows, not the glyph boxes', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    Rect? selectionRect;
    await pumpEditor(
      tester,
      controller,
      onContextMenu: (context, request) =>
          selectionRect = request.selectionRect,
    );
    final start = controller.getLineStartOffset(1) + 2;
    final end = controller.getLineStartOffset(3) + 2;
    controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    await settle(tester, 2);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    await tester.tapAt(
      origin + const Offset(_textX, editorTopPadding + editorLineHeight * 2.5),
      buttons: kSecondaryButton,
    );
    await settle(tester, 2);

    expect(selectionRect!.top - origin.dy, editorTopPadding + editorLineHeight);
    expect(
      selectionRect!.bottom - origin.dy,
      editorTopPadding + editorLineHeight * 4,
    );
  });
}
