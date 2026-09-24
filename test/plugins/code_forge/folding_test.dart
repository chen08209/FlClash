import 'package:code_forge/code_forge.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _blockLines = 6;

String _block(int i) =>
    '''
  - name: node $i
    type: vmess
    server: ${'s' * 40}.example$i.com
    opts: {
      path: /
    }''';

String _document(int blocks) =>
    ['proxies:', for (var i = 0; i < blocks; i++) _block(i)].join('\n');

int _optsLine(int block) => 1 + block * _blockLines + 3;

void main() {
  setUpAll(initEditorNative);

  testWidgets('folding hides lines and keeps the text', (tester) async {
    final text = _document(3);
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(_optsLine(1));
    await settle(tester);
    expect(controller.text, text);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 1), isTrue);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 2), isTrue);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 3), isFalse);
    expect(controller.getFoldStartForLine(_optsLine(1) + 1), _optsLine(1));
    final visible = text.split('\n')
      ..removeRange(_optsLine(1) + 1, _optsLine(1) + 3);
    expect(visibleText(controller), visible.join('\n'));

    controller.toggleFold(_optsLine(1));
    await settle(tester);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 1), isFalse);
    expect(visibleText(controller), text);
    expect(controller.text, text);
  });

  testWidgets('an indentation fold covers every nested line', (tester) async {
    final text = '${_document(2)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
    expect(controller.getFoldStartForLine(2 * _blockLines), 0);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), text);
    expect(controller.text, text);
  });

  testWidgets('an indentation fold holds past the per-line folding limit', (
    tester,
  ) async {
    final text = '${_document(1700)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
  });

  testWidgets('a whole-document fold pass overtaken by an edit is redone', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(1700);
    await pumpEditor(tester, controller);
    await tester.pump(const Duration(milliseconds: 400));
    controller.replaceRange(0, 0, '#\n#\n');
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);

    controller.toggleFold(0);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(1), isFalse);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.getFoldStartForLine(3), 2);
  });

  testWidgets('editing below a fold keeps it folded and the text exact', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    controller.toggleFold(_optsLine(0));
    await settle(tester);

    final line = _optsLine(2);
    final start = controller.getLineStartOffset(line);
    controller.replaceRange(start, start, '    udp: true\n');
    await settle(tester);

    expect(controller.getLineText(line), '    udp: true');
    expect(controller.isLineInFoldedRegion(_optsLine(0) + 1), isTrue);
    expect(controller.lineCount, 1 + 3 * _blockLines + 1);
  });

  testWidgets('deleting a whole folded block leaves no fold behind', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    controller.replaceRange(
      controller.getLineStartOffset(line),
      controller.getLineStartOffset(line + 3),
      '',
    );
    await settle(tester);

    for (var i = 0; i < controller.lineCount; i++) {
      expect(controller.isLineInFoldedRegion(i), isFalse, reason: 'line $i');
    }
    expect(visibleText(controller), controller.text);
  });

  testWidgets('a newline on a folded start line does not move the fold', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(0);
    controller.toggleFold(line);
    await settle(tester);

    final end = controller.getLineStartOffset(line + 1) - 1;
    controller.replaceRange(end, end, '\n');
    await settle(tester);

    expect(controller.getFoldStartForLine(line + 2), isNot(line + 1));
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
    expect(visibleText(controller), controller.text);
  });

  testWidgets('replacing lines that hold a fold drops it', (tester) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    controller.replaceRange(
      controller.getLineStartOffset(line - 1),
      controller.getLineStartOffset(line + 2) - 1,
      '    x: 1\n    y: 2\n    z: 3',
    );
    await settle(tester);

    expect(controller.lineCount, 1 + 3 * _blockLines);
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
    expect(visibleText(controller), controller.text);
  });

  testWidgets('editing a folded start line before its bracket keeps it', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(0);
    controller.toggleFold(line);
    await settle(tester);

    final start = controller.getLineStartOffset(line) + '    '.length;
    controller.replaceRange(start, start + 'opts'.length, 'options');
    await settle(tester);

    expect(controller.getLineText(line), '    options: {');
    expect(controller.getFoldStartForLine(line + 1), line);
    expect(controller.isLineInFoldedRegion(line + 2), isTrue);
    expect(controller.isLineInFoldedRegion(line + 3), isFalse);

    controller.toggleFold(line);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
  });

  testWidgets('a line inserted above a fold shifts it whole', (tester) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    final start = controller.getLineStartOffset(1);
    controller.replaceRange(start, start, '# a\n# b\n');
    await settle(tester);

    expect(controller.getFoldStartForLine(line + 3), line + 2);
    expect(controller.isLineInFoldedRegion(line + 4), isTrue);
    expect(controller.isLineInFoldedRegion(line + 5), isFalse);
  });

  testWidgets(
    'after scrolling a folded wrapped document, taps and the line indicator agree',
    (tester) async {
      final controller = CodeForgeController()..text = _document(200);
      late CodeForgeScrollbarDetails scrollbar;
      await pumpEditor(
        tester,
        controller,
        lineWrap: true,
        size: const Size(400, 600),
        scrollbarBuilder: (context, details, child) {
          scrollbar = details;
          return child;
        },
      );
      for (final block in [2, 5, 8, 40, 41, 42]) {
        controller.toggleFold(_optsLine(block));
        await settle(tester, 2);
      }

      final editor = find.byType(CodeForge);
      final center = tester.getCenter(editor);
      for (var i = 0; i < 6; i++) {
        tester.binding.handlePointerEvent(
          PointerScrollEvent(
            position: center,
            scrollDelta: const Offset(0, 997),
          ),
        );
        await settle(tester, 2);
      }
      expect(scrollbar.controller.offset, greaterThan(4000));

      final origin = tester.getTopLeft(editor);
      final hits = <int>[];
      for (var row = 0; row < 25; row++) {
        await tester.tapAt(
          origin +
              Offset(
                300,
                editorTopPadding + 1 + (row + 0.5) * editorLineHeight,
              ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        hits.add(controller.getLineAtOffset(controller.selection.extentOffset));
      }

      expect(hits.first, scrollbar.firstVisibleLine.value - 1);
      for (var i = 1; i < hits.length; i++) {
        expect(hits[i], greaterThanOrEqualTo(hits[i - 1]));
      }
      for (final line in hits) {
        expect(controller.isLineInFoldedRegion(line), isFalse);
      }
      final lines = hits.toSet().toList();
      final hidden = <int>{
        for (final block in [40, 41, 42]) ...[
          _optsLine(block) + 1,
          _optsLine(block) + 2,
        ],
      };
      final expected = [
        for (var line = lines.first; line <= lines.last; line++)
          if (!hidden.contains(line)) line,
      ];
      expect(lines, expected, reason: 'every visible line gets a row');
    },
  );
}
