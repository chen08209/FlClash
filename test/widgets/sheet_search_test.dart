import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
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

  testWidgets('a docked field leaves the close button at the trailing end', (
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
    expect(tester.getCenter(close).dx, greaterThan(rect.center.dx));
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

  testWidgets('a docked field carries its own opaque surface', (tester) async {
    await openModalSheet(tester);

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    final field = tester.element(find.byType(TextField));
    final theme = Theme.of(field);
    final inputTheme = InputDecorationTheme.of(field);
    final fill = decoration.fillColor ?? inputTheme.fillColor;

    expect(decoration.filled ?? inputTheme.filled, isTrue);
    expect(
      fill,
      SurfaceLevel.floatingOf(theme.colorScheme).colorOf(theme.colorScheme),
    );
    expect(fill!.a, 1);
    // The dock itself paints nothing, so no band spans the sheet behind it.
    final dock = tester.widget<Material>(
      find
          .ancestor(
            of: find.byType(SearchField),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(dock.type, MaterialType.transparency);
  });

  testWidgets('a docked field stands on glass in place of its fill', (
    tester,
  ) async {
    await openModalSheet(tester, glass: true);

    expect(
      find.ancestor(
        of: find.byType(SearchField),
        matching: find.byType(LiquidGlass),
      ),
      findsOneWidget,
    );
    expect(
      InputDecorationTheme.of(tester.element(find.byType(TextField))).filled,
      isFalse,
    );
  });

  testWidgets('a docked field is a pill that strokes only while focused', (
    tester,
  ) async {
    await openModalSheet(tester);

    final field = tester.element(find.byType(TextField));
    final inputTheme = InputDecorationTheme.of(field);
    final border = inputTheme.border;
    final focused = inputTheme.focusedBorder;

    expect(border, isA<AppInputBorder>());
    expect((border! as AppInputBorder).borderRadius, AppRadius.full);
    expect(border.borderSide, BorderSide.none);
    expect(focused, isA<AppInputBorder>());
    expect((focused! as AppInputBorder).borderRadius, AppRadius.full);
    expect(focused.borderSide.color, Theme.of(field).colorScheme.primary);
    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(
      decorator.decoration.floatingLabelBehavior,
      FloatingLabelBehavior.never,
    );
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
