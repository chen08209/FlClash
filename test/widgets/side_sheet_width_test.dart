import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

typedef _Opener = void Function(BuildContext context);

Widget _page() {
  return CommonScaffold(
    title: 'title',
    body: ListView(
      children: [for (var i = 0; i < 3; i++) ListTile(title: Text('row $i'))],
    ),
  );
}

final _openers = <String, _Opener>{
  'showSheet': (context) =>
      showSheet<void>(context: context, builder: (_) => _page()),
  'a nested paged sheet': (context) => showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(builder: (_) => _page()),
  ),
  'showExtend': (context) => showExtend<void>(context, builder: (_) => _page()),
  'showSnapSheet': (context) => showSnapSheet<void>(
    context,
    builder: (_, _) => NestedPagedSheet(builder: (_) => _page()),
  ),
};

void main() {
  Future<void> open(
    WidgetTester tester,
    Size view,
    _Opener opener, {
    double sidebarWidth = 0,
  }) async {
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        child: Row(
          children: [
            SizedBox(width: sidebarWidth),
            Expanded(
              child: Navigator(
                onGenerateInitialRoutes: (_, _) => [
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () => opener(context),
                        child: const Text('open'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect sheetRect(WidgetTester tester) => tester.getRect(find.byType(SideSheet));

  const expectedWidths = [(700.0, 360.0), (1280.0, 512.0), (1920.0, 560.0)];

  for (final MapEntry(key: name, value: opener) in _openers.entries) {
    for (final (viewWidth, width) in expectedWidths) {
      testWidgets('$name in a ${viewWidth.round()} dp window opens a '
          'full-height side sheet ${width.round()} dp wide', (tester) async {
        final view = Size(viewWidth, 800);
        await open(tester, view, opener);
        expect(
          sheetRect(tester),
          Rect.fromLTWH(viewWidth - width, 0, width, view.height),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the side sheet follows the window as it resizes', (
    tester,
  ) async {
    await open(tester, const Size(1280, 800), _openers['showSheet']!);
    expect(sheetRect(tester).width, 512);

    tester.view.physicalSize = const Size(1600, 900);
    await tester.pumpAndSettle();
    expect(sheetRect(tester), const Rect.fromLTWH(1600 - 560, 0, 560, 900));

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpAndSettle();
    expect(sheetRect(tester), const Rect.fromLTWH(1000 - 400, 0, 400, 800));
  });

  testWidgets('a page beside the sidebar opens the same width as the window '
      'root', (tester) async {
    await open(
      tester,
      const Size(1280, 800),
      _openers['showSheet']!,
      sidebarWidth: 240,
    );
    expect(sheetRect(tester), const Rect.fromLTWH(1280 - 512, 0, 512, 800));
  });
}
