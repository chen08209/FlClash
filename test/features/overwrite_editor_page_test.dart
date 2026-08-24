import 'dart:async';

import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _EditorHarness extends StatelessWidget {
  final ValueNotifier<List<String>> items;
  final Future<bool> Function(Set<dynamic> selected)? onDelete;

  const _EditorHarness({required this.items, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return TestApp(
      wrapInProviderScope: true,
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
      ],
      child: OverwriteEditorPage<String>(
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
                trailing: isSelected ? const Icon(Icons.check) : null,
              );
            },
        onReorder: (oldIndex, newIndex) {},
        onAdd: () {},
        emptyLabel: 'Empty',
        selectionEnabled: true,
        idOf: (item) => item,
        onDelete: onDelete,
      ),
    );
  }
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

  testWidgets('tapping a row toggles selection and shows the actions', (
    tester,
  ) async {
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: (selected) async => true),
    );
    await tester.pump();

    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.tap(find.text('a'));
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text(AppLocalizations.current.selectAll), findsOneWidget);

    await tester.tap(find.text('a'));
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('select all toggles every row', (tester) async {
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: (selected) async => true),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text(AppLocalizations.current.selectAll));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(3));

    await tester.tap(find.text(AppLocalizations.current.selectAll));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delete removes the selected items and clears the selection', (
    tester,
  ) async {
    final deleted = <Set<dynamic>>[];
    final items = ValueNotifier<List<String>>(['a', 'b', 'c']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(
        items: items,
        onDelete: (selected) async {
          deleted.add(selected);
          items.value = items.value
              .where((item) => !selected.contains(item))
              .toList();
          return true;
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(deleted.single, {'a'});
    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancelling delete keeps the selection', (tester) async {
    final items = ValueNotifier<List<String>>(['a', 'b']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: (selected) async => false),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(find.text('a'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a delete that resolves after disposal does not touch ref', (
    tester,
  ) async {
    // `onDelete` normally awaits a confirmation dialog, so it stays pending for
    // as long as the user leaves it open — long enough for the sheet holding
    // this page to be torn down underneath it.
    final gate = Completer<bool>();
    final items = ValueNotifier<List<String>>(['a', 'b']);
    addTearDown(items.dispose);
    await tester.pumpWidget(
      _EditorHarness(items: items, onDelete: (_) => gate.future),
    );
    await tester.pump();

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete(true);
    await tester.pump();

    expect(tester.takeException(), isNull);
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

    expect(find.byIcon(Icons.delete), findsNothing);
    expect(find.text(AppLocalizations.current.selectAll), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
