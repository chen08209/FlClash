import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<void> _sendFind(WidgetTester tester) async {
  final modifier = controlSingleActivator(LogicalKeyboardKey.keyF).meta
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

Widget _page({
  ValueChanged<String>? onSearch,
  List<Widget> actions = const [],
  List<IconButtonData> searchActions = const [],
}) {
  return CommonScaffold(
    title: 'Page',
    searchState: onSearch == null
        ? null
        : AppBarSearchState(onSearch: onSearch),
    actions: actions,
    searchActions: searchActions,
    body: const SizedBox.expand(),
  );
}

void main() {
  testWidgets('the find shortcut opens search and refocuses the field', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );

    await _sendFind(tester);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'needle');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    await _sendFind(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(
      field.controller!.selection,
      const TextSelection(baseOffset: 0, extentOffset: 6),
    );
  });

  testWidgets('the find shortcut leaves a page without search alone', (
    tester,
  ) async {
    await tester.pumpWidget(TestApp(wrapInProviderScope: true, child: _page()));

    await _sendFind(tester);

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('the find shortcut skips a page under another route', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('covering route')),
      ),
    );
    await tester.pumpAndSettle();
    await _sendFind(tester);
    expect(find.byType(TextField, skipOffstage: false), findsNothing);

    navigator.pop();
    await tester.pumpAndSettle();
    await _sendFind(tester);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('the find shortcut skips an inactive page', (tester) async {
    final searches = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: PageActivityScope(
          isActive: false,
          child: _page(onSearch: searches.add),
        ),
      ),
    );

    await _sendFind(tester);

    expect(searches, isEmpty);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('search actions stay beside the field while actions hide', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: _page(
          onSearch: (_) {},
          actions: const [Text('page action')],
          searchActions: [
            IconButtonData(
              glyph: AppGlyphs.add,
              onPressed: () {},
              tooltip: 'search action',
            ),
          ],
        ),
      ),
    );
    expect(find.text('page action'), findsOneWidget);
    expect(find.byTooltip('search action'), findsNothing);

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    expect(find.text('page action'), findsNothing);
    expect(find.byTooltip('search action'), findsOneWidget);
  });

  testWidgets('system back exits search on a pushed page before its own '
      'back handler', (tester) async {
    const view = Size(1200, 800);
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var pageBackCount = 0;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        child: const SizedBox.shrink(),
      ),
    );
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => CommonPopScope(
                onPop: (_) {
                  pageBackCount++;
                  return false;
                },
                child: _page(onSearch: (_) {}),
              ),
            ),
          ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(pageBackCount, 0);
    expect(find.text('Page'), findsOneWidget);
  });

  testWidgets('a fresh search callback each build keeps search open', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: _RebuildingSearchPage()),
    );

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    expect(find.text('query=a'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('cancel on a phone bar clears the query and closes the field', (
    tester,
  ) async {
    final searches = <String>[];
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: searches.add)),
    );

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    await tester.enterText(find.byType(TextField), 'needle');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(searches, ['needle', '']);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Page'), findsOneWidget);
  });

  testWidgets(
    'a closing bar field gives way to its buttons before it settles',
    (tester) async {
      await tester.pumpWidget(
        TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
      );
      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(
        tester
            .widget<LiquidGlassFade>(find.byType(LiquidGlassFade))
            .opacity
            .value,
        0,
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a desktop bar folds its search back once left empty', (
    tester,
  ) async {
    const view = Size(1200, 800);
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        child: _page(onSearch: (_) {}),
      ),
    );

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'needle');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byGlyph(AppGlyphs.search), findsOneWidget);
  });
}

class _RebuildingSearchPage extends StatefulWidget {
  const _RebuildingSearchPage();

  @override
  State<_RebuildingSearchPage> createState() => _RebuildingSearchPageState();
}

class _RebuildingSearchPageState extends State<_RebuildingSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Page',
      searchState: AppBarSearchState(
        onSearch: (value) => setState(() => _query = value),
      ),
      body: Text('query=$_query'),
    );
  }
}
