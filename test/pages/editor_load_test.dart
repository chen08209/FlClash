import 'dart:async';

import 'package:code_forge/code_forge.dart';
import 'package:fl_clash/common/navigator.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
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
          load: () => content.future,
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

  testWidgets('loads only once the push transition has finished', (
    tester,
  ) async {
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
    AnimationStatus? statusAtLoad;
    unawaited(
      BaseNavigator.push<void>(
        home,
        Builder(
          builder: (context) {
            transition = ModalRoute.of(context)!.animation;
            return EditorPage(
              title: 'Editor',
              load: () async {
                statusAtLoad = transition!.status;
                return 'mode: rule';
              },
              onSave: (_, _, _) {},
            );
          },
        ),
      ),
    );
    await settle(tester, 12);

    expect(statusAtLoad, AnimationStatus.completed);
    expect(find.byType(CodeForge), findsOneWidget);
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
    var confirms = 0;
    unawaited(
      BaseNavigator.push<void>(
        home,
        EditorPage(
          title: 'Editor',
          content: loaded ? null : crlf,
          load: loaded ? () async => crlf : null,
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

  testWidgets('the YAML editor offers Clash snippets with their key', (
    tester,
  ) async {
    final controller = await pumpTyped(tester, Language.yaml, 'vle');

    expect(find.text('proxies · vless reality'), findsOneWidget);
    await tester.tap(find.text('vless'));
    await settle(tester, 8);

    expect(controller.text, startsWith('- name: vless\n  type: vless\n'));
    expect(
      controller.text.substring(
        controller.selection.start,
        controller.selection.end,
      ),
      'vless',
    );
  });

  testWidgets('the script editor offers script snippets', (tester) async {
    await pumpTyped(tester, Language.javaScript, 'addg');

    expect(find.text('addgroup'), findsOneWidget);
    expect(find.text('vless'), findsNothing);
    await settle(tester, 8);
  });
}
