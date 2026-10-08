import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

final _proxyTypes = {
  for (var i = 1; i <= sheetSearchMinItemCount; i++)
    'Node $i': i.isEven ? 'Vmess' : 'Trojan',
};

Future<List<String>> _pumpSheet(
  WidgetTester tester, {
  required List<String> proxies,
}) async {
  final picked = <String>[];
  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
      ],
      child: SheetProvider(
        type: SheetType.bottomSheet,
        child: SelectionSheet<String>(
          title: 'Target',
          sections: [
            const SelectionSection(label: 'Basic', items: ['DIRECT', 'REJECT']),
            SelectionSection(
              label: 'Proxies',
              items: proxies,
              subtitleBuilder: (_, name) => _proxyTypes[name],
            ),
          ],
          labelBuilder: (item) => item,
          selectedOf: (_) => null,
          onSelected: picked.add,
        ),
      ),
    ),
  );
  await tester.pump();
  return picked;
}

void main() {
  testWidgets('a short list has no search field', (tester) async {
    await _pumpSheet(tester, proxies: ['Node 1']);

    expect(find.byType(SearchField), findsNothing);
    expect(find.text('Node 1'), findsOneWidget);
  });

  testWidgets('leaves out a section with nothing in it', (tester) async {
    await _pumpSheet(tester, proxies: const []);

    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Proxies'), findsNothing);
  });

  testWidgets('narrows the sections by label and subtitle', (tester) async {
    final picked = await _pumpSheet(tester, proxies: _proxyTypes.keys.toList());
    expect(find.byType(SearchField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'vmess 4');
    await tester.pump();
    expect(find.text('Basic'), findsNothing);
    expect(find.text('Node 4'), findsOneWidget);
    expect(find.text('Node 2'), findsNothing);

    await tester.tap(find.text('Node 4'));
    expect(picked, ['Node 4']);

    await tester.enterText(find.byType(TextField), 'reject');
    await tester.pump();
    expect(find.text('REJECT'), findsOneWidget);
    expect(find.text('Proxies'), findsNothing);
  });

  testWidgets('a sheet that removes picks stays open until the last one', (
    tester,
  ) async {
    final picked = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: const SizedBox.shrink(),
      ),
    );
    globalState.navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => SheetProvider(
          type: SheetType.bottomSheet,
          child: SelectionSheet<String>(
            title: 'Add',
            sections: const [
              SelectionSection(label: 'Basic', items: ['DIRECT', 'REJECT']),
              SelectionSection(label: 'Proxies', items: ['Node 1']),
            ],
            labelBuilder: (item) => item,
            selectedOf: (_) => null,
            removeOnSelect: true,
            onSelected: picked.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final sheet = find.byType(SelectionSheet<String>);

    await tester.tap(find.text('Node 1'));
    await tester.pump();
    await tester.tap(find.text('Node 1'), warnIfMissed: false);
    expect(picked, ['Node 1']);
    expect(find.text('Proxies'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Node 1'), findsNothing);
    expect(find.text('Proxies'), findsNothing);

    await tester.tap(find.text('DIRECT'));
    await tester.pumpAndSettle();
    expect(sheet, findsOneWidget);

    await tester.tap(find.text('REJECT'));
    await tester.pumpAndSettle();
    expect(picked, ['Node 1', 'DIRECT', 'REJECT']);
    expect(sheet, findsNothing);
  });

  testWidgets('keeps the field above the no-results state', (tester) async {
    await _pumpSheet(tester, proxies: _proxyTypes.keys.toList());

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizations.current.noSearchResults), findsOneWidget);
    expect(find.byType(SearchField), findsOneWidget);

    await tester.tap(find.byTooltip(AppLocalizations.current.clearSearch));
    await tester.pumpAndSettle();
    expect(find.text('Node 1'), findsOneWidget);
  });

  testWidgets('a drag on the list opens a bottom sheet to the tall detent', (
    tester,
  ) async {
    const view = Size(400, 900);
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSheet<void>(
              context: context,
              builder: (_) => SelectionSheet<String>(
                title: 'Add',
                sections: [
                  SelectionSection(
                    items: [for (var i = 0; i < 60; i++) 'Item $i'],
                  ),
                ],
                labelBuilder: (item) => item,
                selectedOf: (_) => null,
                onSelected: (_) {},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    double sheetTop() => tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    final list = find.byType(CustomScrollView);
    expect(sheetTop(), closeTo(view.height * (1 - snapSheetDetents.first), 1));

    await tester.fling(list, const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(), closeTo(view.height * (1 - snapSheetDetents.last), 1));
    expect(tester.widget<CustomScrollView>(list).controller!.offset, 0);
  });
}
