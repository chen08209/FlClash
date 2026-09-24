import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<List<String>> _pumpBar(
  WidgetTester tester, {
  bool hasSearch = false,
  String? primary,
  bool primaryLoading = false,
  bool foldPrimary = false,
  List<String> icons = const [],
  List<String> menuItems = const [],
  List<String> selection = const [],
}) async {
  final taps = <String>[];
  IconButtonData action(String label, {bool isLoading = false}) {
    return IconButtonData(
      glyph: AppGlyphs.add,
      onPressed: () => taps.add(label),
      tooltip: label,
      isLoading: isLoading,
    );
  }

  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      child: DockedPageScope(
        docked: true,
        child: CommonScaffold(
          title: 'Page',
          searchState: hasSearch ? AppBarSearchState(onSearch: (_) {}) : null,
          primaryAction: primary == null
              ? null
              : action(primary, isLoading: primaryLoading),
          iconActions: [for (final label in icons) action(label)],
          foldPrimaryAction: foldPrimary,
          selectionActions: [for (final label in selection) action(label)],
          menuItems: [
            for (final label in menuItems)
              CommonPopupMenuItem(
                label: label,
                onPressed: () => taps.add(label),
              ),
          ],
          body: const SizedBox.expand(),
        ),
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

  testWidgets('a bar that folds its primary action keeps icons in sight', (
    tester,
  ) async {
    final taps = await _pumpBar(
      tester,
      primary: 'Add',
      primaryLoading: true,
      foldPrimary: true,
      icons: ['Update', 'Sort', 'Filter'],
    );

    expect(_barButtons(tester), ['Update', 'Sort', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Add', 'Update', 'Sort', 'Filter']), [
      'Add',
      'Filter',
    ]);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(taps, isEmpty, reason: 'a running action folds in disabled');
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
    expect(
      _barButtons(tester),
      containsAllInOrder(['Clear search', 'Delete', 'Select all']),
    );
    expect(_inBar(find.byGlyph(AppGlyphs.more)), findsNothing);

    await tester.tap(find.byTooltip('Select all'));
    expect(taps, ['Select all']);
  });
}
