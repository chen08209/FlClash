import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('uses the bottom sheet surface color and shape', (tester) async {
    await tester.pumpWidget(
      const HostApp(
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
    final material = tester.widget<Surface>(
      find.descendant(
        of: find.byType(PagedSheet),
        matching: find.byType(Surface),
      ),
    );

    expect(material.color, SurfaceLevel.page.colorOf(ColorScheme.of(context)));
    expect(material.shape, AppShape.top(AppCorner.xxl));
    expect(material.clipBehavior, Clip.antiAlias);
  });

  testWidgets('a bottom sheet holds its handle still over a push', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    Widget page(String title) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetToolBar(appBar: Text(title)),
        const SizedBox(height: 200),
      ],
    );
    await tester.pumpWidget(
      HostApp(
        home: SheetProvider(
          type: SheetType.bottomSheet,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PagedSheet(
              child: SheetPagesNavigator(
                key: navigatorKey,
                onGenerateInitialRoutes: (_, _) => [
                  PagedSheetRoute<void>(builder: (_) => page('Page 1')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final handle = find.byType(SheetDragHandle);
    expect(handle, findsOneWidget);
    final rest = tester.getRect(handle);
    expect(rest.size, const Size(28, SheetDragHandle.height));

    navigatorKey.currentState!.push(
      PagedSheetRoute<void>(builder: (_) => page('Page 2')),
    );
    await tester.pump();
    await tester.pump();
    final arriving = tester.getTopLeft(find.text('Page 2')).dx;
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(find.text('Page 2')).dx, lessThan(arriving));
    expect(handle, findsOneWidget);
    expect(tester.getRect(handle), rest);
    await tester.pumpAndSettle();
  });

  testWidgets('pushes, animates, and returns a nested page result', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    String? result;

    await tester.pumpWidget(
      HostApp(
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

    final opener = tester.getTopLeft(find.text('open nested')).dx;
    await tester.tap(find.text('open nested'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(tester.getTopLeft(find.text('open nested')).dx, lessThan(opener));
    final arriving = tester.getTopLeft(find.text('close nested')).dx;

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('close nested')).dx, lessThan(arriving));

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
      HostApp(
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

  group('card pages', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    Widget label(String text, {double top = 0}) {
      return Padding(
        padding: EdgeInsets.only(top: top),
        child: Align(alignment: Alignment.topCenter, child: Text(text)),
      );
    }

    Future<void> pumpSheet(
      WidgetTester tester, {
      SheetType type = SheetType.bottomSheet,
    }) async {
      await tester.pumpWidget(
        HostApp(
          theme: ThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).applyDisplayCornerRadii(BorderRadius.circular(48)),
            child: child!,
          ),
          home: SheetProvider(
            type: type,
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

    testWidgets('slide the page below back by three tenths of the sheet', (
      tester,
    ) async {
      await pumpSheet(tester);
      final origin = tester.getTopLeft(find.text('first')).dx;

      push('second', top: 100);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      final progress = ModalRoute.of(
        tester.element(find.text('second')),
      )!.animation!.value;
      expect(progress, inExclusiveRange(0, 1));
      expect(
        tester.getTopLeft(find.text('first')).dx,
        closeTo(origin - 0.3 * 400 * progress, 0.5),
      );
    });

    Iterable<ClipRSuperellipseLayer> cardClipsOf(
      WidgetTester tester, {
      required double top,
      required double bottom,
    }) => tester.layers.whereType<ClipRSuperellipseLayer>().where((layer) {
      final shape = layer.clipRSuperellipse;
      return shape != null &&
          shape.width == 400 &&
          shape.tlRadius.x == top &&
          shape.trRadius.x == top &&
          shape.blRadius.x == bottom &&
          shape.brRadius.x == bottom;
    });

    testWidgets('round a moving page with the sheet corners', (tester) async {
      await pumpSheet(tester);
      Iterable<ClipRSuperellipseLayer> cardClips() =>
          cardClipsOf(tester, top: 38, bottom: 38);

      push('second', top: 100);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(cardClips(), hasLength(2));

      await tester.pumpAndSettle();
      expect(cardClips(), isEmpty);
    });

    testWidgets('round a moving page in a form sheet with its corners', (
      tester,
    ) async {
      await pumpSheet(tester, type: SheetType.formSheet);

      push('second', top: 100);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        cardClipsOf(tester, top: AppCorner.alert, bottom: AppCorner.alert),
        hasLength(2),
      );
    });

    testWidgets('leave the page below in view when popped while covered', (
      tester,
    ) async {
      await pumpSheet(tester);
      push('second', top: 100);
      await tester.pumpAndSettle();
      push('third', top: 150);
      await tester.pumpAndSettle();
      final backdrop = ColorScheme.of(
        tester.element(find.text('first', skipOffstage: false)),
      ).surfaceContainerLowest;

      navigatorKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      navigatorKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      // The leaving card's leading side shows the page below.
      expect(
        tester.renderObject(find.byType(PagedSheet)),
        isNot(
          paints..something(
            (method, arguments) =>
                method == #drawRect &&
                (arguments[0] as Rect).left == 0 &&
                (arguments[0] as Rect).width > AppCorner.xxl + 1 &&
                (arguments[1] as Paint).color == backdrop,
          ),
        ),
      );
      expect(find.text('first'), findsOneWidget);
    });

    testWidgets('move without an opacity layer', (tester) async {
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
}
