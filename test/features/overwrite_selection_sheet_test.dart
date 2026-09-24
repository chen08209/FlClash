import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
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
        child: OverwriteSelectionSheet<String>(
          title: 'Target',
          sections: [
            const OverwriteSelectionSection(
              label: 'Basic',
              items: ['DIRECT', 'REJECT'],
            ),
            OverwriteSelectionSection(
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
}
