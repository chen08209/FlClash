import 'dart:async';

import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hand_over.dart';

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
    expect(
      find.descendant(
        of: find.byType(PagedSheet),
        matching: find.byType(SlideTransition),
      ),
      findsWidgets,
    );

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));

    final midHeight = tester.getSize(find.byType(PagedSheet)).height;
    expect(midHeight, greaterThan(120));
    expect(midHeight, lessThan(300));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PagedSheet)), const Size(400, 300));
  });

  group('fading pages', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    Widget label(String text, {double top = 0}) {
      return Padding(
        padding: EdgeInsets.only(top: top),
        child: Align(alignment: Alignment.topCenter, child: Text(text)),
      );
    }

    Future<void> pumpSheet(WidgetTester tester) async {
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
                      key: navigatorKey,
                      onGenerateInitialRoutes: (_, _) => [
                        PagedSheetRoute(
                          builder: (_) =>
                              SizedBox(height: 200, child: label('first')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    void push(String text, {required double top}) {
      unawaited(
        navigatorKey.currentState!.push(
          PagedSheetRoute<void>(
            builder: (_) => SizedBox(height: 300, child: label(text, top: top)),
          ),
        ),
      );
    }

    Future<(Color, Color)> inkAndSurface(WidgetTester tester) async {
      final rect = tester.getRect(find.text('first'));
      return (
        await pixelAt(tester, inkPointOf(tester, 'first')),
        await pixelAt(tester, rect.centerRight + const Offset(20, 0)),
      );
    }

    testWidgets('hand over without one showing through the other', (
      tester,
    ) async {
      await pumpSheet(tester);
      final (ink, surface) = await inkAndSurface(tester);

      push('second', top: 100);
      await expectHandOver(
        tester,
        ['first', 'second'],
        ink: ink,
        surface: surface,
        floor: 0.25,
      );
      expect(find.text('first'), findsNothing);

      navigatorKey.currentState!.pop();
      await expectHandOver(
        tester,
        ['first', 'second'],
        ink: ink,
        surface: surface,
        floor: 0.25,
      );
      expect(find.text('second'), findsNothing);
    });

    testWidgets('cover a page still fading back in', (tester) async {
      await pumpSheet(tester);
      final (ink, surface) = await inkAndSurface(tester);
      push('second', top: 100);
      await tester.pumpAndSettle();

      navigatorKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      push('third', top: 200);
      await expectHandOver(
        tester,
        ['first', 'second', 'third'],
        ink: ink,
        surface: surface,
      );
    });

    testWidgets('fade without an opacity layer', (tester) async {
      await pumpSheet(tester);

      Future<void> expectNoLayers() async {
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            tester.layers.whereType<OpacityLayer>().where(
              (layer) => (layer.alpha ?? 255) < 255,
            ),
            isEmpty,
          );
        }
      }

      push('second', top: 100);
      await expectNoLayers();
      navigatorKey.currentState!.pop();
      await expectNoLayers();
    });
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
