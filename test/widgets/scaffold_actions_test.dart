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

void main() {
  testWidgets('a bar with two buttons keeps both in sight', (tester) async {
    await _pumpBar(tester, primary: 'Add', icons: ['Sync']);

    expect(_barButtons(tester), ['Add', 'Sync']);
    expect(_inBar(find.byGlyph(AppGlyphs.more)), findsNothing);

    await _pumpBar(tester, hasSearch: true, menuItems: ['Settings']);

    expect(_barButtons(tester), ['Search', 'More']);
  });

  testWidgets('past two a bar without search keeps its primary action', (
    tester,
  ) async {
    final taps = await _pumpBar(
      tester,
      primary: 'Add',
      icons: ['Sync', 'Sort'],
    );

    expect(_barButtons(tester), ['Add', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Add', 'Sync', 'Sort']), ['Sync', 'Sort']);

    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    expect(taps, ['Sort']);
  });

  testWidgets('past two a searchable bar folds its primary action too', (
    tester,
  ) async {
    final taps = await _pumpBar(
      tester,
      hasSearch: true,
      primary: 'Delay test',
      primaryLoading: true,
      icons: ['Locate'],
      menuItems: ['Settings'],
    );

    expect(_barButtons(tester), ['Search', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Delay test', 'Locate', 'Settings']), [
      'Delay test',
      'Locate',
      'Settings',
    ]);

    await tester.tap(find.text('Delay test'));
    await tester.pumpAndSettle();
    expect(taps, isEmpty, reason: 'a running action folds in disabled');
  });

  testWidgets('a bar that folds its primary action keeps an icon in sight', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      primary: 'Add',
      foldPrimary: true,
      icons: ['Update', 'Sort'],
    );

    expect(_barButtons(tester), ['Update', 'More']);

    await _openMenu(tester);
    expect(_menuLabels(tester, ['Add', 'Update', 'Sort']), ['Add', 'Sort']);
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
        matching: find.byType(AppBarButtonGroup),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.byTooltip('Delete'),
        matching: find.byType(AppBarButtonGroup),
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
