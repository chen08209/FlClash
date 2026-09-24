import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/search_field.dart';
import 'package:fl_clash/widgets/sheet.dart';
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

  Future<void> openModalSheet(WidgetTester tester, {Widget? body}) async {
    await tester.pumpWidget(
      TestApp(
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
    final theme = Theme.of(tester.element(find.byType(TextField)));
    final fill = decoration.fillColor ?? theme.inputDecorationTheme.fillColor;

    expect(decoration.filled ?? theme.inputDecorationTheme.filled, isTrue);
    expect(fill, theme.colorScheme.surfaceContainerHigh);
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

  testWidgets('a docked field is a pill', (tester) async {
    await openModalSheet(tester);

    final theme = Theme.of(tester.element(find.byType(TextField)));
    final border = theme.inputDecorationTheme.border;

    expect(border, isA<AppInputBorder>());
    expect((border! as AppInputBorder).borderRadius, AppRadius.full);
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

  testWidgets('a docked field stays above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openModalSheet(tester);
    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(900));

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.byType(SearchField)).dy, lessThan(600));
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
