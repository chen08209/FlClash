import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _document = '''
proxies:
  - name: Port-A
    port: 80
  - name: b
    port: 8080
    sport: 1
rules:
  - DST-PORT,80,DIRECT''';

void main() {
  setUpAll(initEditorNative);

  Future<(CodeForgeController, FindController)> pumpFind(
    WidgetTester tester, {
    UndoRedoController? undoController,
    String text = _document,
  }) async {
    final controller = CodeForgeController()..text = text;
    final finder = FindController(controller);
    addTearDown(finder.dispose);
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      undoController: undoController,
    );
    return (controller, finder);
  }

  List<String> highlighted(CodeForgeController controller) => [
    for (final highlight in controller.searchHighlights)
      controller.text.substring(highlight.start, highlight.end),
  ];

  testWidgets('find counts matches, highlights them and moves the caret', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);

    finder.find('port');
    await settle(tester, 2);
    expect(finder.matchCount, 5);
    expect(highlighted(controller), ['Port', 'port', 'port', 'port', 'PORT']);
    expect(finder.currentMatchIndex, 0);
    expect(controller.selection.extentOffset, _document.indexOf('Port'));
    expect(
      controller.searchHighlights.where((h) => h.isCurrentMatch),
      hasLength(1),
    );

    finder.next();
    expect(finder.currentMatchIndex, 1);
    expect(controller.selection.extentOffset, _document.indexOf('port:'));
    finder.previous();
    finder.previous();
    expect(finder.currentMatchIndex, 4);
    expect(controller.selection.extentOffset, _document.indexOf('PORT'));

    finder.find('');
    await settle(tester, 2);
    expect(finder.matchCount, 0);
    expect(controller.searchHighlights, isEmpty);
  });

  testWidgets('case, whole-word and regex options narrow the matches', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);

    finder.find('port');
    finder.caseSensitive = true;
    expect(finder.matchCount, 3);
    finder.matchWholeWord = true;
    expect(finder.matchCount, 2);
    finder.caseSensitive = false;
    expect(highlighted(controller), ['Port', 'port', 'port', 'PORT']);

    finder.matchWholeWord = false;
    finder.isRegex = true;
    finder.find(r'\d+');
    expect(highlighted(controller), ['80', '8080', '1', '80']);
    finder.find('(');
    expect(finder.matchCount, 0);
  });

  testWidgets('finderBuilder shows only while the finder is active', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document;
    final findController = FindController(controller);
    addTearDown(findController.dispose);
    await pumpEditor(
      tester,
      controller,
      findController: findController,
      finderBuilder: (context, panel) => PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Text('matches: ${panel.matchCount}'),
      ),
    );
    expect(find.textContaining('matches:'), findsNothing);

    findController.isActive = true;
    findController.find('name');
    await tester.pump();
    expect(find.textContaining('matches: 2'), findsOneWidget);

    findController.isActive = false;
    await tester.pump();
    expect(find.textContaining('matches:'), findsNothing);
  });

  testWidgets('typing in the find field searches', (tester) async {
    final (_, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.findInputController.text = 'name';
    await settle(tester, 2);
    expect(finder.matchCount, 2);
  });

  testWidgets('matches follow edits to the document', (tester) async {
    final (controller, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.find('name');
    expect(finder.matchCount, 2);

    controller.replaceRange(controller.length, controller.length, '\n# name');
    await settle(tester, 2);
    expect(finder.matchCount, 3);
  });

  testWidgets('edits after closing the finder bring no highlights back', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.find('name');
    finder.isActive = false;
    expect(controller.searchHighlights, isEmpty);

    controller.replaceRange(controller.length, controller.length, '\n# name');
    await settle(tester, 2);
    expect(controller.searchHighlights, isEmpty);

    finder.isActive = true;
    expect(finder.matchCount, 3);
  });

  testWidgets('replace swaps the current match and replaceAll the rest', (
    tester,
  ) async {
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    final (controller, finder) = await pumpFind(tester, undoController: undo);
    finder.isActive = true;
    finder.matchWholeWord = true;
    finder.find('80');
    expect(finder.matchCount, 2);

    finder.replaceInputController.text = '443';
    finder.replace();
    await settle(tester, 2);
    expect(controller.getLineText(2), '    port: 443');
    expect(finder.matchCount, 1);

    finder.replaceInputController.text = '53';
    finder.replaceAll();
    await settle(tester, 2);
    expect(controller.getLineText(7), '  - DST-PORT,53,DIRECT');
    expect(controller.getLineText(4), '    port: 8080');
    expect(finder.matchCount, 0);

    while (undo.canUndo) {
      undo.undo();
      await settle(tester, 2);
    }
    expect(controller.text, _document);
  });

  testWidgets('regex replaceAll replaces the line matches find shows', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.isRegex = true;
    finder.find(r'^    port');
    expect(finder.matchCount, 2);

    finder.replaceInputController.text = '    listen';
    finder.replaceAll();
    await settle(tester, 2);
    expect(controller.getLineText(2), '    listen: 80');
    expect(controller.getLineText(4), '    listen: 8080');
    expect(controller.getLineText(5), '    sport: 1');
  });

  testWidgets('replacing an empty regex match moves on to the next one', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester, text: 'a\nb\nc');
    finder.isActive = true;
    finder.isRegex = true;
    finder.find(r'$');
    expect(finder.matchCount, 3);

    finder.replaceInputController.text = ';';
    for (var i = 0; i < 3; i++) {
      finder.replace();
      await settle(tester, 2);
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.text, 'a;\nb;\nc;');
  });

  group('a word still being composed', () {
    Future<(CodeForgeController, FindController)> composeAtFirstMatch(
      WidgetTester tester,
    ) async {
      final (controller, finder) = await pumpFind(tester);
      await focusEditor(tester);
      finder.isActive = true;
      finder.matchWholeWord = true;
      finder.find('80');
      await tester.pump();
      final value = controller.currentTextEditingValue;
      final caret = value.selection.extentOffset;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 's', caret, caret),
          'composingBase': caret,
          'composingExtent': caret + 1,
        },
      ]);
      expect(controller.isComposingActive, isTrue);
      finder.replaceInputController.text = '53';
      return (controller, finder);
    }

    testWidgets('is kept by replace', (tester) async {
      final (controller, finder) = await composeAtFirstMatch(tester);

      finder.replace();
      await settle(tester, 2);
      expect(controller.isComposingActive, isFalse);
      expect(controller.getLineText(2), '    port: s80');
      expect(controller.getLineText(7), '  - DST-PORT,53,DIRECT');
    });

    testWidgets('is kept by replaceAll', (tester) async {
      final (controller, finder) = await composeAtFirstMatch(tester);

      finder.replaceAll();
      await settle(tester, 2);
      expect(controller.isComposingActive, isFalse);
      expect(controller.getLineText(2), '    port: s80');
      expect(controller.getLineText(7), '  - DST-PORT,53,DIRECT');
    });
  });

  testWidgets('scrollToLine still works after the editor is rebuilt anew', (
    tester,
  ) async {
    final lines = [for (var i = 0; i < 200; i++) 'k$i: v'];
    final controller = CodeForgeController()..text = lines.join('\n');
    late ScrollController vertical;
    for (final key in const [ValueKey('light'), ValueKey('dark')]) {
      await pumpEditor(
        tester,
        controller,
        key: key,
        scrollbarBuilder: (context, details, child) {
          vertical = details.controller;
          return child;
        },
      );
    }
    vertical.jumpTo(0);
    await settle(tester, 2);

    controller.scrollToLine(100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      vertical.offset + (600 - editorTopPadding) / 2,
      closeTo(editorLineHeight * 100.5, editorLineHeight),
    );
  });

  testWidgets('matches move with edits and edited lines are searched again', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.find('port');
    expect(highlighted(controller), ['Port', 'port', 'port', 'port', 'PORT']);

    controller.replaceRange(0, 0, '# port\n');
    await settle(tester, 2);
    expect(highlighted(controller), [
      'port',
      'Port',
      'port',
      'port',
      'port',
      'PORT',
    ]);

    final sport = controller.text.indexOf('    sport');
    controller.replaceRange(sport, sport + '    sport: 1\n'.length, '');
    await settle(tester, 2);
    expect(highlighted(controller), ['port', 'Port', 'port', 'port', 'PORT']);
  });

  testWidgets('a regex match across lines is found once typing pauses', (
    tester,
  ) async {
    final (controller, finder) = await pumpFind(tester);
    finder.isActive = true;
    finder.isRegex = true;
    finder.find(r'b\n +port');
    expect(finder.matchCount, 1);

    final lineEnd = controller.getLineStartOffset(4) - 1;
    controller.replaceRange(lineEnd, lineEnd, ' x');
    await settle(tester, 2);
    expect(finder.matchCount, 0);

    controller.replaceRange(lineEnd, lineEnd + 2, '');
    await tester.pump(const Duration(milliseconds: 300));
    expect(finder.matchCount, 1);
  });
}
