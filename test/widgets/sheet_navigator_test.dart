import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_navigator.dart';
import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final hostKey = GlobalKey<NavigatorState>();
  late BuildContext pageContext;

  Widget pages(Widget child) => SheetPagesNavigator(
    onGenerateInitialRoutes: (_, _) => [
      MaterialPageRoute<void>(builder: (_) => child),
    ],
  );

  Future<void> pumpNested(WidgetTester tester, {bool isMobileView = true}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [isMobileViewProvider.overrideWithValue(isMobileView)],
        child: MaterialApp(
          home: Navigator(
            key: hostKey,
            onGenerateInitialRoutes: (_, _) => [
              MaterialPageRoute<void>(
                builder: (_) => pages(
                  pages(
                    Builder(
                      builder: (context) {
                        pageContext = context;
                        return const SizedBox.expand();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('skips every sheet navigator up to the one hosting them', (
    tester,
  ) async {
    await pumpNested(tester);
    expect(Navigator.of(pageContext).widget, isA<SheetPagesNavigator>());
    expect(sheetNavigatorOf(pageContext), hostKey.currentState);
  });

  testWidgets('a side sheet opened from a sheet page goes over the sheet', (
    tester,
  ) async {
    await pumpNested(tester);
    unawaited(
      showModalSideSheet<void>(
        context: pageContext,
        builder: (_) => const Text('side'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Navigator.of(tester.element(find.text('side'))),
      hostKey.currentState,
    );
  });

  for (final isMobileView in [true, false]) {
    testWidgets(
      'a sheet opened from a sheet page closes itself, not the page, through '
      'the context its builder gets${isMobileView ? '' : ' on desktop'}',
      (tester) async {
        await pumpNested(tester, isMobileView: isMobileView);
        String? picked;
        unawaited(
          showSheet<String>(
            context: pageContext,
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pop('picked'),
              child: const Text('pick'),
            ),
          ).then((value) => picked = value),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();

        expect(picked, 'picked');
        expect(find.text('pick'), findsNothing);
        expect(pageContext.mounted, isTrue);
      },
    );
  }
}
