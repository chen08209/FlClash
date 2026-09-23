import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  testWidgets('shows the unavailable state without the native editor library', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: const EditorPage(
          title: 'Editor',
          content: 'mixed-port: 7890',
          onSave: _noopSave,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Editor unavailable'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithGlyph(IconButton, AppGlyphs.save))
          .onPressed,
      isNull,
    );
  });

  testWidgets('Ctrl+S saves a changed document off Apple platforms', (
    tester,
  ) async {
    final saved = <String>[];
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: EditorPage(
          title: 'Editor',
          content: '',
          titleEditable: true,
          onSave: (_, title, _) => saved.add(title),
        ),
      ),
    );
    await tester.pump();
    Future<void> pressSave() async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
    }

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await pressSave();
    expect(saved, isEmpty);

    await tester.enterText(find.byType(TextField).first, 'Renamed');
    await pressSave();
    expect(saved, ['Renamed']);
  });
}

void _noopSave(BuildContext context, String title, String content) {}
