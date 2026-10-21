import 'dart:async';
import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/loading.dart';
import 'package:fl_clash/ui/navigator.dart';
import 'package:fl_clash/ui/paged_sheet.dart';
import 'package:fl_clash/ui/popup.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind, kSecondaryButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../plugins/code_forge/support.dart';

void main() {
  setUpAll(initEditorNative);

  testWidgets('mounts the editor only once loaded content arrives', (
    tester,
  ) async {
    final content = Completer<String>();
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          load: () async => CodeForgeDocument.fromText(await content.future),
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(CodeForge), findsNothing);

    content.complete('mixed-port: 7890\nmode: rule');
    await settle(tester);

    final editor = tester.widget<CodeForge>(find.byType(CodeForge));
    expect(editor.controller.text, 'mixed-port: 7890\nmode: rule');
    expect(
      editor.controller.selection,
      const TextSelection.collapsed(offset: 0),
    );
  });

  testWidgets('mounts the editor once a large document is built', (
    tester,
  ) async {
    final document = 'mode: rule\n' * 20000;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          load: () => CodeForgeDocument.fromText(document),
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);

    final editor = tester.widget<CodeForge>(find.byType(CodeForge));
    expect(editor.controller.length, document.length);
    expect(
      editor.controller.selection,
      const TextSelection.collapsed(offset: 0),
    );
  });

  testWidgets('loads as the push starts and mounts the editor once the route '
      'settles', (tester) async {
    late BuildContext home;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: Builder(
          builder: (context) {
            home = context;
            return const SizedBox();
          },
        ),
      ),
    );
    Animation<double>? transition;
    var loads = 0;
    unawaited(
      BaseNavigator.push<void>(
        home,
        Builder(
          builder: (context) {
            transition = ModalRoute.of(context)!.animation;
            return EditorPage(
              title: 'Editor',
              load: () {
                loads++;
                return CodeForgeDocument.fromText('mode: rule');
              },
              onSave: (_, _, _) {},
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(transition!.status, AnimationStatus.forward);
    expect(loads, 1);

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(transition!.status, AnimationStatus.forward);
    expect(find.byType(CodeForge), findsNothing);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await settle(tester, 12);
    expect(find.byType(CodeForge), findsOneWidget);
  });

  testWidgets('an editor in a sheet grows the sheet before it scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late BuildContext home;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(400, 860)),
        ],
        child: Builder(
          builder: (context) {
            home = context;
            return const SizedBox();
          },
        ),
      ),
    );
    late BuildContext sheetPage;
    unawaited(
      showSheet<void>(
        context: home,
        props: nestedPagedSheetProps,
        builder: (_) => NestedPagedSheet(
          builder: (context) {
            sheetPage = context;
            return ListView(
              primary: true,
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 44, child: Text('$i')),
              ],
            );
          },
        ),
      ),
    );
    await settle(tester, 12);
    unawaited(
      Navigator.of(sheetPage).push(
        PagedSheetRoute<void>(
          builder: (_) => EditorPage(
            title: 'Preview',
            content: [for (var i = 0; i < 400; i++) 'key$i: $i'].join('\n'),
          ),
        ),
      ),
    );
    await settle(tester, 30);
    double sheetTop() => tester.getTopLeft(find.byType(PagedSheet)).dy;
    double editorOffset() => tester
        .stateList<ScrollableState>(
          find.descendant(
            of: find.byType(CodeForge),
            matching: find.byWidgetPredicate((widget) => widget is Scrollable),
          ),
        )
        .firstWhere((state) => state.position.axis == Axis.vertical)
        .position
        .pixels;
    final collapsed = sheetTop();

    // A trackpad pan scrolls without the press a touch selects with on the
    // host, and the sheet measures what it fits only between frames.
    Future<void> dragEditor(double dy) async {
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(tester.getCenter(find.byType(CodeForge)));
      for (var moved = 10.0; moved <= dy.abs(); moved += 10) {
        await gesture.panZoomUpdate(
          tester.getCenter(find.byType(CodeForge)),
          pan: Offset(0, moved * dy.sign),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.panZoomEnd();
      await settle(tester, 30);
    }

    await dragEditor(-200);

    expect(sheetTop(), lessThan(collapsed - 100));
    expect(editorOffset(), 0);

    await dragEditor(-100);

    expect(editorOffset(), greaterThan(0));
  });

  Future<void> openCrlf(WidgetTester tester, {required bool loaded}) async {
    const crlf = 'mode: rule\r\nmixed-port: 7890\r\n';
    late BuildContext home;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: Builder(
          builder: (context) {
            home = context;
            return const SizedBox();
          },
        ),
      ),
    );
    final directory = Directory.systemTemp.createTempSync('editor_crlf');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/config.yaml')..writeAsStringSync(crlf);
    var confirms = 0;
    unawaited(
      BaseNavigator.push<void>(
        home,
        EditorPage(
          title: 'Editor',
          content: loaded ? null : crlf,
          load: loaded ? () => openEditorFile(file.path) : null,
          onSave: (_, _, _) {},
          onPop: (_, _, _) async {
            confirms++;
            return true;
          },
        ),
      ),
    );
    await settle(tester, 12);
    expect(
      tester
          .widget<IconButton>(find.widgetWithGlyph(IconButton, AppGlyphs.check))
          .onPressed,
      isNull,
    );

    await tester.binding.handlePopRoute();
    await settle(tester, 12);

    expect(confirms, 0);
    expect(find.byType(EditorPage), findsNothing);
  }

  testWidgets(
    'a CRLF file opens with nothing to save or confirm',
    (tester) => openCrlf(tester, loaded: true),
  );

  testWidgets(
    'CRLF content handed over opens with nothing to save or confirm',
    (tester) => openCrlf(tester, loaded: false),
  );

  Future<CodeForgeController> pumpTyped(
    WidgetTester tester,
    Language language,
    String typed,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          content: '',
          language: language,
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);
    final controller = tester
        .widget<CodeForge>(find.byType(CodeForge))
        .controller;
    controller.focusNode!.requestFocus();
    await settle(tester, 2);
    await typeText(tester, controller, typed);
    await settle(tester, 8);
    return controller;
  }

  testWidgets('only an edit that changes the document can be saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          content: 'mode: rule',
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);
    final controller = tester
        .widget<CodeForge>(find.byType(CodeForge))
        .controller;
    Future<bool> canSaveAfter(int start, int end, String text) async {
      controller.replaceRange(start, end, text);
      await settle(tester, 2);
      return tester
              .widget<IconButton>(
                find.widgetWithGlyph(IconButton, AppGlyphs.check),
              )
              .onPressed !=
          null;
    }

    expect(await canSaveAfter(6, 10, 'RULE'), isTrue);
    expect(await canSaveAfter(6, 10, 'global'), isTrue);
    expect(await canSaveAfter(6, 12, 'rule'), isFalse);
  });

  testWidgets('typing over the selection closes its context menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          content: 'mode: rule',
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);
    final controller = tester
        .widget<CodeForge>(find.byType(CodeForge))
        .controller;
    controller.focusNode!.requestFocus();
    controller.selection = const TextSelection(baseOffset: 6, extentOffset: 10);
    await settle(tester, 2);
    await tester.tapAt(
      tester.getCenter(find.byType(CodeForge)),
      buttons: kSecondaryButton,
    );
    await settle(tester, 8);
    expect(find.byType(CommonPopupMenu), findsOneWidget);

    await typeText(tester, controller, 'g');
    await settle(tester, 12);

    expect(controller.text, 'mode: g');
    expect(find.byType(CommonPopupMenu), findsNothing);
  });

  Future<(CodeForgeController, List<String>)> pushSaving(
    WidgetTester tester, {
    FutureOr<void> Function(BuildContext context)? save,
  }) async {
    late BuildContext home;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: Builder(
          builder: (context) {
            home = context;
            return const SizedBox();
          },
        ),
      ),
    );
    final saved = <String>[];
    unawaited(
      BaseNavigator.push<void>(
        home,
        EditorPage(
          title: 'Editor',
          content: 'mode: rule',
          onSave: (context, _, content) async {
            final FutureOr<void> Function(BuildContext) finish =
                save ?? (context) => Navigator.of(context).pop();
            saved.add(await content.readText());
            if (context.mounted) {
              await finish(context);
            }
          },
        ),
      ),
    );
    await settle(tester, 12);
    final controller = tester
        .widget<CodeForge>(find.byType(CodeForge))
        .controller;
    controller.focusNode!.requestFocus();
    await settle(tester, 2);
    return (controller, saved);
  }

  Future<void> pressSaveShortcut(WidgetTester tester, {int repeats = 0}) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
    for (var i = 0; i < repeats; i++) {
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyS);
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  }

  VoidCallback? saveButton(WidgetTester tester) => tester
      .widget<IconButton>(find.widgetWithGlyph(IconButton, AppGlyphs.check))
      .onPressed;

  testWidgets('a held save shortcut saves once', (tester) async {
    final (controller, saved) = await pushSaving(tester, save: (_) {});
    controller.replaceRange(10, 10, 's');
    await settle(tester, 2);

    await pressSaveShortcut(tester, repeats: 3);
    await settle(tester, 2);

    expect(saved, ['mode: rules']);
  });

  testWidgets('a save still running takes no second one', (tester) async {
    final saving = Completer<void>();
    final (controller, saved) = await pushSaving(
      tester,
      save: (_) => saving.future,
    );
    controller.replaceRange(10, 10, 's');
    await settle(tester, 2);

    await tester.tap(find.widgetWithGlyph(IconButton, AppGlyphs.check));
    await tester.pump();
    expect(saveButton(tester), isNull);
    await pressSaveShortcut(tester);
    await tester.tapAt(
      tester.getCenter(find.byType(CodeForge)),
      buttons: kSecondaryButton,
    );
    await settle(tester, 8);
    expect(saved, ['mode: rules']);
    expect(find.byType(CommonPopupMenu), findsNothing);

    saving.complete();
    await settle(tester, 2);
    expect(saveButton(tester), isNotNull);
  });

  testWidgets('a name changed while the content loads can be saved', (
    tester,
  ) async {
    final content = Completer<String>();
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: EditorPage(
          title: 'Editor',
          titleEditable: true,
          load: () async => CodeForgeDocument.fromText(await content.future),
          onSave: (_, _, _) {},
        ),
      ),
    );
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.pump();

    content.complete('mode: rule');
    await settle(tester);

    expect(saveButton(tester), isNotNull);
  });

  testWidgets('the context menu closes once the editor loses focus', (
    tester,
  ) async {
    final (controller, _) = await pushSaving(tester);
    await tester.tapAt(
      tester.getCenter(find.byType(CodeForge)),
      buttons: kSecondaryButton,
    );
    await settle(tester, 8);
    expect(find.byType(CommonPopupMenu), findsOneWidget);

    controller.focusNode!.unfocus();
    await settle(tester, 12);

    expect(find.byType(CommonPopupMenu), findsNothing);
  });

  testWidgets('saving takes in the word still being composed', (tester) async {
    final (controller, saved) = await pushSaving(tester);
    controller.selection = const TextSelection.collapsed(offset: 10);
    await tester.pump();
    await sendDeltas(tester, [
      {
        ...textDelta('mode: rule', 's', 10, 10),
        'composingBase': 6,
        'composingExtent': 11,
      },
    ]);
    expect(controller.text, 'mode: ');

    await tester.tap(find.widgetWithGlyph(IconButton, AppGlyphs.check));
    await settle(tester, 12);

    expect(saved, ['mode: rules']);
    expect(find.byType(EditorPage), findsNothing);
  });

  testWidgets('undo is offered for a word still being composed', (
    tester,
  ) async {
    final (controller, _) = await pushSaving(tester);
    controller.selection = const TextSelection.collapsed(offset: 10);
    await tester.pump();
    await sendDeltas(tester, [
      {
        ...textDelta('mode: rule', 's', 10, 10),
        'composingBase': 10,
        'composingExtent': 11,
      },
    ]);
    expect(controller.imeComposition?.displayText, 's');

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await settle(tester, 8);
    await tester.tap(find.byGlyph(AppGlyphs.undo));
    await settle(tester, 8);

    expect(controller.isComposingActive, isFalse);
    expect(controller.text, 'mode: rule');
  });

  testWidgets('the save shortcut under an open context menu closes the page', (
    tester,
  ) async {
    final (controller, saved) = await pushSaving(tester);
    controller.replaceRange(10, 10, 's');
    await settle(tester, 2);
    await tester.tapAt(
      tester.getCenter(find.byType(CodeForge)),
      buttons: kSecondaryButton,
    );
    await settle(tester, 8);
    expect(find.byType(CommonPopupMenu), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester, 12);

    expect(saved, ['mode: rules']);
    expect(find.byType(EditorPage), findsNothing);
  });

  testWidgets('the YAML editor completes Clash keys with their separator', (
    tester,
  ) async {
    final controller = await pumpTyped(tester, Language.yaml, 'mixed-p');

    await tester.tap(find.text('mixed-port'));
    await settle(tester, 8);

    expect(controller.text, 'mixed-port: ');
    expect(controller.selection.extentOffset, controller.length);
  });

  testWidgets('the script editor completes script words', (tester) async {
    await pumpTyped(tester, Language.javaScript, 'cons');

    expect(find.text('console'), findsOneWidget);
    expect(find.text('mixed-port'), findsNothing);
    await settle(tester, 8);
  });
}
