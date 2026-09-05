import 'dart:async';

import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the bottom sheet surface color and shape', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SheetProvider(
          type: SheetType.bottomSheet,
          child: SizedBox(
            width: 400,
            height: 600,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PagedSheet(child: SizedBox.expand()),
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(PagedSheet));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(PagedSheet),
        matching: find.byType(Material),
      ),
    );

    expect(material.color, ColorScheme.of(context).surfaceContainerLow);
    expect(material.shape, AppShape.top(AppCorner.xxl));
    expect(material.clipBehavior, Clip.antiAlias);
  });

  testWidgets('pushes, animates, and returns a nested page result', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: SheetProvider(
          type: SheetType.sideSheet,
          child: SizedBox(
            width: 400,
            height: 600,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PagedSheet(
                child: Navigator(
                  key: navigatorKey,
                  onGenerateInitialRoutes: (_, _) => [
                    PagedSheetRoute(
                      builder: (context) => Center(
                        child: FilledButton(
                          onPressed: () async {
                            result = await Navigator.of(context).push<String>(
                              PagedSheetRoute(
                                builder: (context) => Center(
                                  child: FilledButton(
                                    onPressed: () {
                                      Navigator.of(context).pop('done');
                                    },
                                    child: const Text('close nested'),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text('open nested'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open nested'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('open nested'), findsOneWidget);
    expect(find.text('close nested'), findsOneWidget);
    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pumpAndSettle();
    await tester.tap(find.text('close nested'));
    await tester.pumpAndSettle();

    expect(result, 'done');
    expect(find.text('open nested'), findsOneWidget);
    expect(find.text('close nested'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shrinks to the current page and resizes on push', (
    tester,
  ) async {
    late BuildContext pageContext;

    Widget page(double height, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: Builder(
              builder: (context) {
                pageContext = context;
                return Text(label);
              },
            ),
          ),
        ],
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: SheetProvider(
          type: SheetType.bottomSheet,
          child: Center(
            child: SizedBox(
              width: 400,
              height: 600,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PagedSheet(
                  child: Navigator(
                    onGenerateInitialRoutes: (_, _) => [
                      PagedSheetRoute(builder: (_) => page(120, 'first')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(PagedSheet)), const Size(400, 120));

    unawaited(
      Navigator.of(
        pageContext,
      ).push(PagedSheetRoute(builder: (_) => page(300, 'second'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));

    final midHeight = tester.getSize(find.byType(PagedSheet)).height;
    expect(midHeight, greaterThan(120));
    expect(midHeight, lessThan(300));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PagedSheet)), const Size(400, 300));
  });

  test('uses the configured duration in both directions', () {
    final route = PagedSheetRoute<void>(
      duration: const Duration(milliseconds: 350),
      builder: (_) => const SizedBox.shrink(),
    );

    expect(route.transitionDuration, const Duration(milliseconds: 350));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 350));
    expect(route.delegatedTransition, isNull);
  });
}
