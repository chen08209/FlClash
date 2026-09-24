import 'package:code_forge/code_forge.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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

  testWidgets('an indentation fold covers a block of any length', (
    tester,
  ) async {
    final text = '${_document(900)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
  });

  testWidgets('a document folds the same past the per-line folding limit', (
    tester,
  ) async {
    const lines = [
      'a: {',
      '  b: (',
      '  c: 1',
      '}',
      'd: [',
      '  e: )',
      ']',
      'f(x, [',
      '  y)',
      ']',
      'k: [ v:',
      '    x',
      '    y',
      ']',
      'm:',
      '  n: 1',
      '',
      '  o: 2',
      'p: 3',
      'q:\u{feff}',
      '  r: 1',
    ];

    Future<List<(int, int)>> foldsOf(String text) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      final folds = <(int, int)>[];
      for (var line = 0; line < lines.length; line++) {
        controller.toggleFold(line);
        await tester.pump();
        final fold = controller.foldings[line];
        if (fold != null && fold.isFolded) folds.add((line, fold.endIndex));
        controller.toggleFold(line);
        await tester.pump();
      }
      return folds;
    }

    final text = lines.join('\n');
    final perLine = await foldsOf(text);
    expect(perLine, [
      (0, 3),
      (1, 5),
      (4, 6),
      (7, 8),
      (10, 12),
      (14, 17),
      (19, 20),
    ]);
    expect(await foldsOf('$text${'\n' * 10001}'), perLine);
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

  group('an edit inside a fold', () {
    const text = 'a: {\n  b: 1\n  c: 2\n}\nd: 3';

    Future<CodeForgeController> pump(
      WidgetTester tester, {
      bool folded = true,
    }) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      if (folded) {
        controller.toggleFold(0);
        await settle(tester);
        expect(controller.getFoldStartForLine(3), 0);
      }
      return controller;
    }

    void closeEarly(CodeForgeController controller) {
      final end = controller.getLineStartOffset(2) - 1;
      controller.replaceRange(end, end, ' }');
    }

    testWidgets('that keeps its shape leaves it folded', (tester) async {
      final controller = await pump(tester);

      final end = controller.getLineStartOffset(2) - 1;
      controller.replaceRange(end, end, '0');
      await settle(tester);

      expect(controller.getLineText(1), '  b: 10');
      expect(visibleText(controller), 'a: {\nd: 3');
    });

    testWidgets('that ends it on an earlier line unfolds it', (tester) async {
      final controller = await pump(tester);

      closeEarly(controller);
      await settle(tester);

      expect(visibleText(controller), controller.text);
    });

    testWidgets('that adds lines and ends it early unfolds it', (tester) async {
      final controller = await pump(tester);

      final start = controller.getLineStartOffset(2);
      controller.replaceRange(start, start, '}\ne: {\n');
      await settle(tester);

      expect(controller.lineCount, 7);
      expect(visibleText(controller), controller.text);
    });

    testWidgets('left unfolded is folded by what the text now says', (
      tester,
    ) async {
      final controller = await pump(tester, folded: false);

      closeEarly(controller);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      expect(visibleText(controller), 'a: {\n  c: 2\n}\nd: 3');
    });
  });

  testWidgets('indenting a folded key past its lines unfolds it', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = 'proxies:\n  - a\n  - b\nrules:\n  - c';
    await pumpEditor(tester, controller);
    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - c');

    controller.replaceRange(0, 0, '    ');
    await settle(tester);

    expect(visibleText(controller), controller.text);
  });

  group('past the per-line folding limit, a whole-document pass', () {
    Future<CodeForgeController> pump(WidgetTester tester) async {
      final controller = CodeForgeController()..text = _document(1700);
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      return controller;
    }

    Future<void> closeEarly(
      WidgetTester tester,
      CodeForgeController controller,
    ) async {
      final end = controller.getLineStartOffset(_optsLine(0) + 2) - 1;
      controller.replaceRange(end, end, ' }');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
    }

    testWidgets('unfolds a fold an edit ended on an earlier line', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);
      controller.toggleFold(line);
      await settle(tester);
      expect(controller.getFoldStartForLine(line + 2), line);

      await closeEarly(tester, controller);

      expect(controller.isLineInFoldedRegion(line + 1), isFalse);
      expect(controller.isLineInFoldedRegion(line + 2), isFalse);
    });

    testWidgets('gives an unfolded fold the range an edit left it', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);

      await closeEarly(tester, controller);
      controller.toggleFold(line);
      await settle(tester);

      expect(controller.getFoldStartForLine(line + 1), line);
      expect(controller.isLineInFoldedRegion(line + 2), isFalse);
    });

    testWidgets('keeps a fold whose head a whole-line edit moved', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);
      controller.toggleFold(line);
      await settle(tester);

      final above = controller.getLineStartOffset(line - 1);
      final head = controller.getLineStartOffset(line);
      controller.replaceRange(above, head, '');
      await settle(tester);
      expect(controller.getFoldStartForLine(line), line - 1);

      controller.replaceRange(above, above, '    udp: true\n');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(controller.getFoldStartForLine(line + 1), line);
      expect(controller.isLineInFoldedRegion(line + 3), isFalse);
    });

    testWidgets('leaves a folded fold the folds it folded over', (
      tester,
    ) async {
      final controller = await pump(tester);
      final inner = _optsLine(0);
      controller.toggleFold(inner);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      controller.replaceRange(0, 0, '# top\n');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(controller.getFoldStartForLine(inner + 1), 1);
      controller.toggleFold(1);
      await settle(tester);

      expect(controller.isLineInFoldedRegion(inner + 1), isFalse);
      expect(controller.getFoldStartForLine(inner + 2), inner + 1);
    });
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

  group('a fold with a whole line edited at its edge', () {
    const text = 'x: 1\na:\n  b: 1\nc: 2';

    Future<CodeForgeController> pumpFolded(WidgetTester tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      controller.toggleFold(1);
      await settle(tester);
      expect(visibleText(controller), 'x: 1\na:\nc: 2');
      return controller;
    }

    testWidgets('stays folded when the line above it is deleted', (
      tester,
    ) async {
      final controller = await pumpFolded(tester);

      controller.replaceRange(0, controller.getLineStartOffset(1), '');
      await settle(tester);

      expect(visibleText(controller), 'a:\nc: 2');
    });

    testWidgets('stays folded when a line is inserted at its start', (
      tester,
    ) async {
      final controller = await pumpFolded(tester);

      final head = controller.getLineStartOffset(1);
      controller.replaceRange(head, head, 'n: 0\n');
      await settle(tester);

      expect(visibleText(controller), 'x: 1\nn: 0\na:\nc: 2');
    });
  });

  group('nested folds', () {
    const text = 'a:\n  b:\n    x: 1\n    y: 2\nc: 3';

    Future<CodeForgeController> pumpBothFolded(WidgetTester tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      controller.toggleFold(1);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);
      expect(visibleText(controller), 'a:\nc: 3');
      return controller;
    }

    testWidgets('refold the inner one only by what the text still gives', (
      tester,
    ) async {
      final controller = await pumpBothFolded(tester);

      final start = controller.getLineStartOffset(3);
      controller.replaceRange(start, start + 2, '');
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      expect(visibleText(controller), controller.text);
    });

    testWidgets('keep the inner one folded when an edit opens the outer', (
      tester,
    ) async {
      final controller = await pumpBothFolded(tester);

      controller.replaceRange(2, 2, ' 1');
      await settle(tester);

      expect(visibleText(controller), 'a: 1\n  b:\nc: 3');
    });

    testWidgets('open down to a line scrolled to', (tester) async {
      final controller = await pumpBothFolded(tester);

      controller.scrollToLine(2);
      await settle(tester, 12);

      expect(controller.isLineInFoldedRegion(2), isFalse);
    });

    testWidgets('keep the inner one folded through a replace-all across '
        'them', (tester) async {
      final controller = CodeForgeController()..text = 'z: 0\n$text';
      final finder = FindController(controller);
      addTearDown(finder.dispose);
      await pumpEditor(tester, controller, findController: finder);
      controller.toggleFold(2);
      await settle(tester);
      controller.toggleFold(1);
      await settle(tester);

      finder.isRegex = true;
      finder.find(r'\d');
      finder.replaceInputController.text = '9';
      finder.replaceAll();
      await tester.pump(const Duration(milliseconds: 300));
      await settle(tester);
      expect(visibleText(controller), 'z: 9\na:\nc: 9');

      controller.toggleFold(1);
      await settle(tester);
      expect(visibleText(controller), 'z: 9\na:\n  b:\nc: 9');
    });

    testWidgets('keep the inner one folded in a re-keyed editor that is '
        'edited', (tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller, key: const ValueKey(1));
      controller.toggleFold(1);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);
      await pumpEditor(tester, controller, key: const ValueKey(2));

      controller.replaceRange(0, 0, '# top\n');
      await settle(tester);
      controller.toggleFold(1);
      await settle(tester);

      expect(visibleText(controller), '# top\na:\n  b:\nc: 3');
    });
  });

  testWidgets('a replace-all across a fold keeps it only where it still '
      'is', (tester) async {
    final controller = CodeForgeController()..text = _document(6);
    final finder = FindController(controller);
    addTearDown(finder.dispose);
    await pumpEditor(tester, controller, findController: finder);
    final line = _optsLine(3);
    controller.toggleFold(line);
    await settle(tester);

    finder.find('vmess');
    finder.replaceInputController.text = 'trojan';
    finder.replaceAll();
    await settle(tester);
    expect(controller.getFoldStartForLine(line + 2), line);

    finder.isRegex = true;
    finder.find(r'^  - name: node [14]\n(.*\n){5}');
    expect(finder.matchCount, 2);
    finder.replaceInputController.text = '';
    finder.replaceAll();
    await tester.pump(const Duration(milliseconds: 300));
    await settle(tester);
    expect(controller.lineCount, 1 + 4 * _blockLines);
    expect(visibleText(controller), controller.text);
  });

  group('the caret', () {
    const text = 'x: 1\na:\n  b: 1\n  c: 2';

    Future<CodeForgeController> pumpFocused(
      WidgetTester tester, [
      String text = text,
    ]) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      return controller;
    }

    testWidgets('on a line a fold hides moves to the line heading it', (
      tester,
    ) async {
      final controller = await pumpFocused(tester);
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(2) + 3,
      );
      await settle(tester, 2);

      controller.toggleFold(1);
      await settle(tester);

      expect(visibleText(controller), 'x: 1\na:');
      expect(controller.selection, const TextSelection.collapsed(offset: 7));
    });

    testWidgets('steps over a fold to the line after it', (tester) async {
      final controller = await pumpFocused(tester, '$text\nd: 3');
      controller.toggleFold(1);
      await settle(tester);
      controller.selection = const TextSelection.collapsed(offset: 7);
      await settle(tester, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester, 2);

      expect(visibleText(controller), 'x: 1\na:\nd: 3');
      expect(
        controller.selection,
        TextSelection.collapsed(offset: controller.getLineStartOffset(4)),
      );
    });

    testWidgets('stays on the line heading a fold that ends the document', (
      tester,
    ) async {
      final controller = await pumpFocused(tester);
      controller.toggleFold(1);
      await settle(tester);
      controller.selection = const TextSelection.collapsed(offset: 5);
      await settle(tester, 2);

      for (final key in [
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowRight,
      ]) {
        await tester.sendKeyEvent(key);
        await settle(tester, 2);
      }

      expect(visibleText(controller), 'x: 1\na:');
      expect(controller.selection, const TextSelection.collapsed(offset: 7));
    });
  });

  testWidgets('a fold the text no longer gives leaves its line number to '
      'select the line', (tester) async {
    final controller = CodeForgeController()..text = 'a:\n  b: 1\nc: 2';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 5);
    await settle(tester, 2);
    controller.replaceRange(3, 5, '');
    await tester.pump();

    await tester.tapAt(
      tester.getTopLeft(find.byType(CodeForge)) +
          const Offset(36, editorTopPadding + editorLineHeight / 2),
    );
    await settle(tester, 8);

    expect(visibleText(controller), controller.text);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 3),
    );
  });

  testWidgets('finding text inside a fold opens it and scrolls there', (
    tester,
  ) async {
    const block = 150;
    final line = _optsLine(block) + 1;
    final text = _document(200).split('\n')..[line] = '      path: /unique';
    final controller = CodeForgeController()..text = text.join('\n');
    final finder = FindController(controller);
    addTearDown(finder.dispose);
    late ScrollController vertical;
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    controller.toggleFold(0);
    await settle(tester);
    expect(vertical.position.maxScrollExtent, 0);

    finder.find('unique');
    await settle(tester, 12);

    expect(controller.isLineInFoldedRegion(line), isFalse);
    final lineTop = editorTopPadding + line * editorLineHeight;
    expect(vertical.offset, lessThanOrEqualTo(lineTop));
    expect(vertical.offset + 600, greaterThanOrEqualTo(lineTop + 20));
  });

  testWidgets('a line indented under a key gives the key its fold at once', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a:\nb: 1';
    await pumpEditor(tester, controller);

    controller.replaceRange(3, 3, '  ');
    await settle(tester);
    controller.toggleFold(0);
    await settle(tester);

    expect(visibleText(controller), 'a:');
  });

  testWidgets('indenting the line below a folded block into it unfolds it', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = 'proxies:\n  - a\n\nrules:\n  - c';
    await pumpEditor(tester, controller);
    controller.toggleFold(0);
    await settle(tester);

    final start = controller.getLineStartOffset(3);
    controller.replaceRange(start, start, '  ');
    await settle(tester);

    expect(visibleText(controller), controller.text);
  });

  testWidgets('a re-keyed editor keeps what was folded', (tester) async {
    final controller = CodeForgeController()..text = 'a:\n  b: 1\n  c: 2\nd: 3';
    await pumpEditor(tester, controller, key: const ValueKey(1));
    controller.toggleFold(0);
    await settle(tester);

    await pumpEditor(tester, controller, key: const ValueKey(2));

    expect(visibleText(controller), 'a:\nd: 3');
    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), controller.text);
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
                380,
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
