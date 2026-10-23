import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<void> _sendFind(WidgetTester tester, {bool settle = true}) async {
  final modifier = controlSingleActivator(LogicalKeyboardKey.keyF).meta
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
  await tester.sendKeyUpEvent(modifier);
  if (settle) {
    await tester.pumpAndSettle();
  }
}

double _opacityAbove(WidgetTester tester, Finder finder) => tester
    .widget<Opacity>(
      find.ancestor(of: finder, matching: find.byType(Opacity)).first,
    )
    .opacity;

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
      await tester.pump(const Duration(milliseconds: 400));

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

  testWidgets('a bar field reopened as it starts to close comes to rest', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );
    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    final field = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(GooPane),
    );
    final open = tester.getRect(field);

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await _sendFind(tester, settle: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 16));

    expect(tester.getRect(field), open);
  });

  testWidgets('an opening bar field shows its contents only once it grows', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
    );
    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(_opacityAbove(tester, find.byType(TextField)), 0);
    await tester.pumpAndSettle();
    expect(_opacityAbove(tester, find.byType(TextField)), 1);
  });

  testWidgets('a closing bar search gives its group the search glyph last', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(
          title: 'Page',
          searchState: AppBarSearchState(onSearch: (_) {}),
          iconActions: [IconButtonData(glyph: AppGlyphs.add, onPressed: () {})],
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));

    expect(find.text('Page'), findsOneWidget);
    expect(_opacityAbove(tester, find.byGlyph(AppGlyphs.search)), 0);
    await tester.pumpAndSettle();
    expect(_opacityAbove(tester, find.byGlyph(AppGlyphs.search)), 1);
  });

  testWidgets('a bar field on a pushed page closes into its back button', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CommonScaffold(
                  title: 'Page',
                  searchInBar: true,
                  searchState: AppBarSearchState(onSearch: (_) {}),
                  body: const SizedBox.expand(),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final back = tester.getRect(find.byTooltip('Back'));
    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));

    final field = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(GooPane),
    );
    expect(back.contains(tester.getCenter(field)), isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'a lone search button re-forms out of a droplet that overshoots',
    (tester) async {
      await tester.pumpWidget(
        TestApp(wrapInProviderScope: true, child: _page(onSearch: (_) {})),
      );
      final button = find.byTooltip('Search');
      final rest = tester.getRect(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final droplet = tester.getRect(button);
      expect(droplet.width, lessThan(rest.width / 2));
      expect(droplet.center.dx, greaterThan(rest.center.dx));
      await tester.pumpAndSettle();
      expect(tester.getRect(button), rest);
    },
  );

  testWidgets('a lone desktop search button swells once the field is in', (
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
    final rest = tester.getRect(find.byTooltip('Search'));
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    final field = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(GooPane),
    );

    FocusManager.instance.primaryFocus?.unfocus();
    // The field folds back once the focus change lands, a frame on.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.getRect(field).height, rest.height);

    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.getRect(field).height, greaterThan(rest.height * 1.15));
    expect(
      tester.getCenter(field).dx,
      moreOrLessEquals(rest.center.dx, epsilon: 1),
    );
    await tester.pumpAndSettle();
  });

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
