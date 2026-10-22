import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<List<String>> _pumpBar(
  WidgetTester tester, {
  bool hasSearch = false,
  String? primary,
  Set<String> loading = const {},
  List<String> icons = const [],
  List<String> menuItems = const [],
  List<String> selection = const [],
}) async {
  final taps = <String>[];
  IconButtonData action(String label) {
    return IconButtonData(
      glyph: AppGlyphs.add,
      onPressed: () => taps.add(label),
      tooltip: label,
      isLoading: loading.contains(label),
    );
  }

  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      child: CommonScaffold(
        title: 'Page',
        searchState: hasSearch ? AppBarSearchState(onSearch: (_) {}) : null,
        primaryAction: primary == null ? null : action(primary),
        iconActions: [for (final label in icons) action(label)],
        selectionActions: [for (final label in selection) action(label)],
        menuItems: [
          for (final label in menuItems)
            CommonPopupMenuItem(label: label, onPressed: () => taps.add(label)),
        ],
        body: const SizedBox.expand(),
      ),
    ),
  );
  return taps;
}

Finder _inBar(Finder finder) =>
    find.descendant(of: find.byType(AppBar), matching: finder);

List<String> _barButtons(WidgetTester tester) => [
  for (final button in tester.widgetList<IconButton>(
    _inBar(find.byType(IconButton)),
  ))
    button.tooltip ?? '',
];

List<String> _shownButtons(WidgetTester tester) => [
  for (final button in tester.widgetList<IconButton>(
    find.byType(IconButton).hitTestable(),
  ))
    button.tooltip ?? '',
];

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(_inBar(find.byGlyph(AppGlyphs.more)));
  await tester.pumpAndSettle();
}

List<String> _menuLabels(WidgetTester tester, List<String> labels) {
  final shown = [
    for (final label in labels)
      if (find.text(label).evaluate().isNotEmpty) label,
  ];
  return shown..sort(
    (a, b) => tester
        .getTopLeft(find.text(a))
        .dy
        .compareTo(tester.getTopLeft(find.text(b)).dy),
  );
}

Finder _inGroup(String tooltip) => find.ancestor(
  of: find.byTooltip(tooltip),
  matching: find.byType(TonalButtonGroup),
);

void main() {
  testWidgets('a bar with three buttons groups two beside the third', (
    tester,
  ) async {
    await _pumpBar(tester, primary: 'Add', icons: ['Sync', 'Sort']);

    expect(_barButtons(tester), ['Add', 'Sync', 'Sort']);
    expect(_inBar(find.byGlyph(AppGlyphs.more)), findsNothing);
    expect(_inGroup('Add'), findsOneWidget);
    expect(_inGroup('Sync'), findsOneWidget);
    expect(_inGroup('Sort'), findsNothing);

    await _pumpBar(tester, hasSearch: true, menuItems: ['Settings']);

    expect(_barButtons(tester), ['Search', 'More']);
  });

  testWidgets('the menu stands apart from the grouped buttons', (tester) async {
    await _pumpBar(
      tester,
      hasSearch: true,
      primary: 'Delay test',
      menuItems: ['Settings'],
    );

    expect(_barButtons(tester), ['Search', 'Delay test', 'More']);
    expect(_inGroup('Search'), findsOneWidget);
    expect(_inGroup('Delay test'), findsOneWidget);
    expect(_inGroup('More'), findsNothing);
  });

  testWidgets('past three a bar without search keeps two actions', (
    tester,
  ) async {
    final taps = await _pumpBar(
      tester,
      primary: 'Add',
      icons: ['Sync', 'Sort', 'Filter'],
    );

    expect(_barButtons(tester), ['Add', 'Sync', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Add', 'Sync', 'Sort', 'Filter']), [
      'Sort',
      'Filter',
    ]);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(taps, ['Filter']);
  });

  testWidgets('past three a searchable bar keeps its primary action', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      hasSearch: true,
      primary: 'Delay test',
      icons: ['Locate'],
      menuItems: ['Settings'],
    );

    expect(_barButtons(tester), ['Search', 'Delay test', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Delay test', 'Locate', 'Settings']), [
      'Locate',
      'Settings',
    ]);
  });

  testWidgets('a running action folds in disabled', (tester) async {
    final taps = await _pumpBar(
      tester,
      primary: 'Add',
      icons: ['Update', 'Sort', 'Filter'],
      loading: {'Filter'},
    );

    expect(_barButtons(tester), ['Add', 'Update', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Add', 'Update', 'Sort', 'Filter']), [
      'Sort',
      'Filter',
    ]);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(taps, isEmpty);
  });

  testWidgets('a selection keeps its actions grouped beside the search', (
    tester,
  ) async {
    final taps = await _pumpBar(
      tester,
      hasSearch: true,
      selection: ['Delete', 'Select all'],
    );

    expect(_barButtons(tester), ['Search', 'Delete', 'Select all']);
    expect(_inBar(find.byGlyph(AppGlyphs.more)), findsNothing);
    expect(
      find.ancestor(
        of: find.byTooltip('Search'),
        matching: find.byType(TonalButtonGroup),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.byTooltip('Delete'),
        matching: find.byType(TonalButtonGroup),
      ),
      findsOneWidget,
    );

    await tester.tap(_inBar(find.byTooltip('Search')));
    await tester.pumpAndSettle();
    expect(_shownButtons(tester), ['Delete', 'Select all', 'Cancel']);
    expect(_inGroup('Delete'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.more), findsNothing);

    await tester.tap(find.byTooltip('Select all'));
    expect(taps, ['Select all']);
  });

  testWidgets('a selection groups two actions and stands the rest apart', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      hasSearch: true,
      selection: ['Delete', 'Select all', 'Copy'],
    );

    void expectSplit(List<String> buttons) {
      expect(_shownButtons(tester), buttons);
      expect(_inGroup('Delete'), findsOneWidget);
      expect(_inGroup('Select all'), findsOneWidget);
      expect(_inGroup('Copy'), findsNothing);
      expect(find.byGlyph(AppGlyphs.more), findsNothing);
    }

    expectSplit(['Search', 'Delete', 'Select all', 'Copy']);

    await tester.tap(_inBar(find.byTooltip('Search')));
    await tester.pumpAndSettle();
    expectSplit(['Delete', 'Select all', 'Copy', 'Cancel']);
  });

  for (final (type, buttons) in [
    (SheetType.bottomSheet, ['Close', 'Delay test']),
    (SheetType.sideSheet, ['Close', 'Search', 'Delay test']),
  ]) {
    testWidgets('a ${type.name} leads with its close button, primary action '
        'or not', (tester) async {
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: SheetProvider(
            type: type,
            child: CommonScaffold(
              title: 'Sheet',
              searchState: AppBarSearchState(onSearch: (_) {}),
              primaryAction: IconButtonData(
                glyph: AppGlyphs.bolt,
                onPressed: () {},
                tooltip: 'Delay test',
              ),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(_barButtons(tester), buttons);
      expect(_inGroup('Close'), findsNothing);
    });
  }

  testWidgets('a page keeps its primary action in its bar', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(
          title: 'Page',
          primaryAction: IconButtonData(
            glyph: AppGlyphs.add,
            onPressed: () {},
            tooltip: 'Add',
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(_barButtons(tester), ['Add']);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('a title menu opens from the title start and runs its items', (
    tester,
  ) async {
    final taps = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(
          title: 'Page',
          titleMenuItems: [
            CommonPopupMenuItem(
              label: 'Rename',
              onPressed: () => taps.add('Rename'),
            ),
          ],
          body: const SizedBox.expand(),
        ),
      ),
    );
    expect(_inBar(find.byGlyph(AppGlyphs.chevronDown)), findsOneWidget);
    expect(_barButtons(tester), isEmpty);
    final title = tester.getRect(_inBar(find.text('Page')));

    await tester.tap(_inBar(find.text('Page')));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(PopupMenuCard)).left,
      moreOrLessEquals(title.left),
    );

    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(taps, ['Rename']);
  });
}
