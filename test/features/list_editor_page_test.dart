import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _EditorHarness extends StatelessWidget {
  final ValueNotifier<List<String>?> items;
  final void Function(Set<String> ids)? onDelete;
  final bool searchable;
  final bool inBottomSheet;

  const _EditorHarness({
    required this.items,
    this.onDelete,
    this.searchable = false,
    this.inBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final page = ListEditorPage<String, String>(
      title: 'Editor',
      itemsOf: (_) => items.value,
      itemBuilder:
          (context, ref, item, index, isEditing, isSelected, onToggleSelected) {
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
    );
    return TestApp(
      wrapInProviderScope: true,
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
      ],
      child: inBottomSheet
          ? Material(
              child: SheetProvider(type: SheetType.bottomSheet, child: page),
            )
          : page,
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

  testWidgets('the last row scrolls clear of a docked search field', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>([
      for (var index = 0; index < 40; index++) 'item $index',
    ]);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, searchable: true, inBottomSheet: true),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('item 0'), const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.widgetWithText(ListTile, 'item 39')).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(SearchField)).dy),
    );

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

  testWidgets('delete during a search keeps the selection the search hides', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['alpha', 'beta', 'gamma']);
    addTearDown(items.dispose);
    final deleted = <Set<String>>[];
    await tester.pumpWidget(
      _EditorHarness(items: items, searchable: true, onDelete: deleted.add),
    );
    await tester.pump();

    await _search(tester, 'a');
    await tester.tap(find.text('beta'));
    await tester.pump();
    await tester.tap(find.text('gamma'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ma');
    await tester.pump();
    await _tapBarAction(tester, AppLocalizations.current.delete);
    await _answerDialog(tester, confirm: true);

    expect(deleted.single, {'gamma'});

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'beta'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delete is disabled while a search hides the whole selection', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['alpha', 'beta', 'gamma']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, searchable: true, onDelete: (_) {}),
    );
    await tester.pump();
    IconButton deleteButton() => tester.widget<IconButton>(
      find.widgetWithGlyph(IconButton, AppGlyphs.delete),
    );

    await _search(tester, 'a');
    await tester.tap(find.text('beta'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ma');
    await tester.pump();
    expect(deleteButton().onPressed, isNull);

    await tester.tap(find.text('gamma'));
    await tester.pump();
    expect(deleteButton().onPressed, isNotNull);

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

  testWidgets('builds rows past the viewport once its route settles and '
      'keeps the rows it arrived with', (tester) async {
    final items = [for (var i = 0; i < 200; i++) 'item $i'];
    final builds = <int, int>{};
    final page = ListEditorPage<String, String>(
      title: 'Editor',
      itemsOf: (_) => items,
      itemBuilder:
          (context, ref, item, index, isEditing, isSelected, onToggleSelected) {
            builds[index] = (builds[index] ?? 0) + 1;
            return ListTile(title: Text(item));
          },
      itemExtent: 50,
      onReorder: (oldIndex, newIndex) {},
      onAdd: () {},
      emptyLabel: 'Empty',
      idOf: (item) => item,
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(400, 600)),
        ],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => BaseNavigator.push(context, page),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final arrived = {...builds.keys};
    expect(arrived, isNotEmpty);
    expect(
      tester.getTopLeft(find.text('item ${arrived.length - 1}')).dy,
      lessThan(600),
    );

    await tester.pumpAndSettle();
    expect(builds.length, greaterThan(arrived.length));
    expect([for (final index in arrived) builds[index]], everyElement(1));
  });
}
