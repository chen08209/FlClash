import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _EditorHarness extends StatelessWidget {
  final ValueNotifier<List<String>?> items;
  final void Function(Set<String> ids)? onDelete;
  final bool searchable;

  const _EditorHarness({
    required this.items,
    this.onDelete,
    this.searchable = false,
  });

  @override
  Widget build(BuildContext context) {
    return TestApp(
      wrapInProviderScope: true,
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
      ],
      child: OverwriteEditorPage<String, String>(
        title: 'Editor',
        itemsOf: (_) => items.value,
        itemBuilder:
            (
              context,
              ref,
              item,
              index,
              isEditing,
              isSelected,
              onToggleSelected,
            ) {
              return ListTile(
                title: Text(item),
                onTap: onToggleSelected,
                trailing: isSelected ? const GlyphIcon(AppGlyphs.check) : null,
              );
            },
        onReorder: (oldIndex, newIndex) {},
        onAdd: () {},
        emptyLabel: 'Empty',
        selectionEnabled: true,
        idOf: (item) => item,
        onDelete: onDelete,
        searchFieldsOf: searchable ? (item) => [item] : null,
      ),
    );
  }
}

Future<void> _search(WidgetTester tester, String query) async {
  await tester.tap(find.byGlyph(AppGlyphs.search));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), query);
  await tester.pump();
}

Future<void> _tapBarAction(WidgetTester tester, String tooltip) async {
  await tester.tap(
    find.descendant(of: find.byType(AppBar), matching: find.byTooltip(tooltip)),
  );
  await tester.pumpAndSettle();
}

Future<void> _answerDialog(WidgetTester tester, {required bool confirm}) async {
  await tester.pumpAndSettle();
  final localizations = AppLocalizations.current;
  await tester.tap(
    find.text(confirm ? localizations.confirm : localizations.cancel),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty label when there are no items', (tester) async {
    final items = ValueNotifier<List<String>>([]);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items));
    await tester.pump();

    expect(find.text('Empty'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows no empty label while the items are loading', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>?>(null);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items));
    await tester.pump();

    expect(find.text('Empty'), findsNothing);

    items.value = ['a'];
    await tester.pumpWidget(_EditorHarness(items: items));
    await tester.pump();

    expect(find.text('Empty'), findsNothing);
    expect(find.text('a'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping a row toggles selection and shows the actions', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items, onDelete: (_) {}));
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.delete), findsNothing);

    await tester.tap(find.text('a'));
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);
    expect(find.byTooltip(AppLocalizations.current.selectAll), findsOneWidget);

    await tester.tap(find.text('a'));
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.delete), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('select all toggles every row', (tester) async {
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items, onDelete: (_) {}));
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byTooltip(AppLocalizations.current.selectAll));
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.check), findsNWidgets(3));

    await tester.tap(find.byTooltip(AppLocalizations.current.selectAll));
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.check), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('offers no search without search fields', (tester) async {
    final items = ValueNotifier<List<String>>(['a']);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items));
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.search), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a search lists only the matches and cannot reorder them', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['alpha', 'beta', 'gamma']);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items, searchable: true));
    await tester.pump();
    expect(find.byType(ReorderableListView), findsOneWidget);

    await _search(tester, 'MA');
    expect(find.text('gamma'), findsOneWidget);
    expect(find.text('alpha'), findsNothing);
    expect(find.text('beta'), findsNothing);
    expect(find.byType(ReorderableListView), findsNothing);

    await tester.enterText(find.byType(TextField), 'zeta');
    await tester.pump();
    expect(find.text(AppLocalizations.current.noSearchResults), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.text('alpha'), findsOneWidget);
    expect(find.byType(ReorderableListView), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('select all during a search covers only the matches', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['alpha', 'beta', 'gamma']);
    addTearDown(items.dispose);
    Set<String>? deleted;
    await tester.pumpWidget(
      _EditorHarness(
        items: items,
        searchable: true,
        onDelete: (ids) => deleted = ids,
      ),
    );
    await tester.pump();

    await _search(tester, 'a');
    await tester.tap(find.text('beta'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ma');
    await tester.pump();
    await _tapBarAction(tester, AppLocalizations.current.selectAll);
    await _tapBarAction(tester, AppLocalizations.current.delete);
    await _answerDialog(tester, confirm: true);

    expect(deleted, {'gamma'});

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delete removes the selected items and clears the selection', (
    tester,
  ) async {
    final deleted = <Set<String>>[];
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(
        items: items,
        onDelete: (ids) {
          deleted.add(ids);
          items.value = items.value
              .where((item) => !ids.contains(item))
              .toList();
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await _answerDialog(tester, confirm: true);

    expect(deleted.single, {'a'});
    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.delete), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancelling delete keeps the selection', (tester) async {
    final deleted = <Set<String>>[];
    final items = ValueNotifier<List<String>>(['a', 'b']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: deleted.add),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await _answerDialog(tester, confirm: false);

    expect(deleted, isEmpty);
    expect(find.text('a'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a selection drops items that left the list', (tester) async {
    final deleted = <Set<String>>[];
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: deleted.add),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('b'));
    await tester.pump();

    items.value = ['b', 'c'];
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: deleted.add),
    );
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await _answerDialog(tester, confirm: true);

    expect(deleted.single, {'b'});

    await tester.tap(find.text('c'));
    await tester.pump();
    items.value = ['a'];
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: deleted.add),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.delete), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delete button is hidden without a delete handler', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['a', 'b']);
    addTearDown(items.dispose);
    await tester.pumpWidget(_EditorHarness(items: items));
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.delete), findsNothing);
    expect(find.byTooltip(AppLocalizations.current.selectAll), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
