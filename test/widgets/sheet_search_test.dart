import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void main() {
  late List<String> queries;

  setUp(() => queries = []);

  Widget scaffold({required SheetType? type, Widget? body}) {
    final scaffold = CommonScaffold(
      title: 'title',
      searchState: AppBarSearchState(onSearch: queries.add),
      body: body ?? const SizedBox(),
    );
    return TestApp(
      wrapInProviderScope: true,
      child: type == null
          ? scaffold
          : SheetProvider(type: type, child: scaffold),
    );
  }

  testWidgets('a bottom sheet searches from a docked field, not a bar button', (
    tester,
  ) async {
    await tester.pumpWidget(scaffold(type: SheetType.bottomSheet));
    await tester.pumpAndSettle();

    expect(find.byType(SearchField), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.search),
      ),
      findsNothing,
    );
    expect(find.text('title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wiki');
    await tester.pumpAndSettle();

    expect(queries, ['wiki']);
    // The title survives searching, because nothing took the bar over.
    expect(find.text('title'), findsOneWidget);
  });

  testWidgets('a docked field leaves the close button at the leading edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      scaffold(
        type: SheetType.bottomSheet,
        body: const SizedBox(width: 600, height: 200),
      ),
    );
    await tester.pumpAndSettle();

    final bar = find.byType(AppBar);
    final close = find.descendant(
      of: bar,
      matching: find.byGlyph(AppGlyphs.close),
    );
    expect(close, findsOneWidget);
    final rect = tester.getRect(bar);
    expect(rect.width, 600);
    expect(tester.getCenter(close).dx, lessThan(rect.center.dx));
  });

  testWidgets('a page and a side sheet keep the bar button', (tester) async {
    for (final type in [null, SheetType.page, SheetType.sideSheet]) {
      await tester.pumpWidget(scaffold(type: type));
      await tester.pumpAndSettle();

      expect(find.byType(SearchField), findsNothing, reason: '$type');
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byGlyph(AppGlyphs.search),
        ),
        findsOneWidget,
        reason: '$type',
      );
    }
  });

  testWidgets('a phone page pushed over another docks its search at its foot', (
    tester,
  ) async {
    for (final (view, docks) in [
      (const Size(400, 900), true),
      (const Size(1200, 800), false),
    ]) {
      tester.view.physicalSize = view;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestApp(
          overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
          homeBuilder: (page) => Navigator(
            onGenerateInitialRoutes: (_, _) => [
              MaterialPageRoute<void>(builder: (_) => const SizedBox()),
              MaterialPageRoute<void>(builder: (_) => page),
            ],
          ),
          child: CommonScaffold(
            title: 'title',
            searchState: AppBarSearchState(onSearch: queries.add),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final barButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.search),
      );
      expect(barButton, docks ? findsNothing : findsOneWidget, reason: '$view');
      if (!docks) {
        continue;
      }
      final field = find.byType(SearchField);
      expect(
        tester.getRect(field).bottom,
        view.height - BottomInsetScope.dockedSearchMargin,
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(field).bottom,
        view.height - 300 - BottomInsetScope.dockedSearchMargin,
      );
      tester.view.resetViewInsets();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a phone page that asks keeps its search a bar button', (
    tester,
  ) async {
    const view = Size(400, 900);
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        homeBuilder: (page) => Navigator(
          onGenerateInitialRoutes: (_, _) => [
            MaterialPageRoute<void>(builder: (_) => const SizedBox()),
            MaterialPageRoute<void>(builder: (_) => page),
          ],
        ),
        child: CommonScaffold(
          title: 'title',
          searchState: AppBarSearchState(onSearch: queries.add),
          searchInBar: true,
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.search),
      ),
      findsOneWidget,
    );
    expect(find.byType(SearchField), findsNothing);
  });

  Future<void> openModalSheet(
    WidgetTester tester, {
    Widget? body,
    bool glass = false,
  }) async {
    await tester.pumpWidget(
      LiquidGlassScope(
        enabled: glass,
        child: TestApp(
          wrapInProviderScope: true,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SheetProvider(
                  type: SheetType.bottomSheet,
                  child: CommonScaffold(
                    title: 'title',
                    searchState: AppBarSearchState(onSearch: queries.add),
                    body: body ?? const SizedBox(height: 200),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a docked field leaves the list room to scroll clear of it', (
    tester,
  ) async {
    late double inset;

    await openModalSheet(
      tester,
      body: Builder(
        builder: (context) {
          inset = BottomInsetScope.of(context);
          return const SizedBox(height: 200);
        },
      ),
    );

    expect(inset, BottomInsetScope.dockedSearchInset);
    expect(
      tester.getSize(find.byType(SearchField)).height,
      BottomInsetScope.dockedSearchHeight,
    );
  });

  GooSurface dockOf(WidgetTester tester) => tester.widget<GooSurface>(
    find.ancestor(
      of: find.byType(SearchField),
      matching: find.byType(GooSurface),
    ),
  );

  testWidgets('a docked field stands on an opaque surface of its own', (
    tester,
  ) async {
    await openModalSheet(tester);

    final field = tester.element(find.byType(TextField));
    final colorScheme = Theme.of(field).colorScheme;
    final dock = dockOf(tester);

    expect(dock.glass, isNull);
    expect(
      dock.color,
      SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
    );
    expect(dock.color.a, 1);
    expect(dock.shadows, isNotEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.filled,
      isFalse,
    );
    // The dock itself paints nothing, so no band spans the sheet behind it.
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.byType(SearchField),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.type, MaterialType.transparency);
  });

  testWidgets('a docked field stands on glass in place of its fill', (
    tester,
  ) async {
    await openModalSheet(tester, glass: true);

    expect(dockOf(tester).glass, isNotNull);
  });

  Future<void> openSnapSheet(WidgetTester tester) async {
    const size = Size(400, 900);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
        homeBuilder: (home) => RemoteFocusAdapter(enabled: false, child: home),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSnapSheet(
              context,
              builder: (_, controller) => CommonScaffold(
                title: 'title',
                searchState: AppBarSearchState(onSearch: queries.add),
                body: ListView.builder(
                  controller: controller,
                  itemCount: 60,
                  itemBuilder: (_, index) =>
                      SizedBox(height: 40, child: Text('$index')),
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
  }

  Future<void> closeSnapSheet(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('a docked field rings only focus a key moved there', (
    tester,
  ) async {
    await openSnapSheet(tester);
    InputBorder focusedBorder() => tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration
        .focusedBorder!;

    expect(focusedBorder(), isA<AppInputBorder>());
    expect((focusedBorder() as AppInputBorder).borderRadius, AppRadius.full);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focusedBorder().borderSide, BorderSide.none);

    final focusNode = tester
        .widget<TextField>(find.byType(TextField))
        .focusNode!;
    focusNode.unfocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(
      focusedBorder().borderSide.color,
      Theme.of(tester.element(find.byType(TextField))).colorScheme.primary,
    );

    await closeSnapSheet(tester);
  });

  testWidgets('a docked field offers cancel while it is in use', (
    tester,
  ) async {
    await openSnapSheet(tester);
    final cancel = find.byTooltip('Cancel').hitTestable();
    expect(cancel, findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(cancel, findsOneWidget);
    expect(
      tester.getRect(cancel).left -
          tester.getRect(find.byType(SearchField)).right,
      12,
    );
    // A bar's button, as tall as the field and in the bar's foreground.
    expect(tester.getSize(cancel), Size.square(TonalButtonSize.docked.button));
    final glyph = find.descendant(of: cancel, matching: find.byType(GlyphIcon));
    expect(
      IconTheme.of(tester.element(glyph)).color,
      Theme.of(tester.element(glyph)).colorScheme.onSurface,
    );
    await tester.enterText(find.byType(TextField), 'wiki');

    await tester.tap(cancel);
    await tester.pumpAndSettle();

    expect(queries, ['wiki', '']);
    expect(find.byType(SearchField), findsOneWidget);
    expect(cancel, findsNothing);

    await closeSnapSheet(tester);
  });

  testWidgets('a mouse press on cancel leaves the field until it lets go', (
    tester,
  ) async {
    await openSnapSheet(tester);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final cancel = find.byTooltip('Cancel').hitTestable();

    final gesture = await tester.startGesture(
      tester.getCenter(cancel),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(cancel, findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(cancel, findsNothing);
    expect(queries, ['']);

    await closeSnapSheet(tester);
  });

  testWidgets('a docked field clears the bottom safe area once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);

    await openModalSheet(tester);

    expect(
      tester.getBottomLeft(find.byType(SearchField)).dy,
      900 - 34 - BottomInsetScope.dockedSearchMargin,
    );
  });

  testWidgets('a fit sheet keeps its docked field above the keyboard', (
    tester,
  ) async {
    const size = Size(400, 900);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSheet<void>(
              context: context,
              builder: (_) => CommonScaffold(
                title: 'title',
                searchState: AppBarSearchState(onSearch: queries.add),
                body: const SizedBox(height: 200),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(900));

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(600));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a snap sheet keeps its docked field above the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSnapSheet(
              context,
              builder: (_, controller) => CommonScaffold(
                title: 'title',
                searchState: AppBarSearchState(onSearch: queries.add),
                body: ListView.builder(
                  controller: controller,
                  itemCount: 60,
                  itemBuilder: (_, index) =>
                      SizedBox(height: 40, child: Text('$index')),
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

    expect(find.byType(SearchField), findsOneWidget);
    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(900));

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(600));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
