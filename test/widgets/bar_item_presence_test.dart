import 'dart:async';

import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

final _back = find.ancestor(
  of: find.byTooltip('Back'),
  matching: find.byType(IconButton),
);

void main() {
  Widget app() {
    return TestApp(
      wrapInProviderScope: true,
      child: Navigator(
        onGenerateRoute: (settings) => HomeRoute<void>(
          settings: settings,
          builder: (_) => HostScaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 300,
                height: 60,
                child: OpenContainer<void>(
                  transition: OpenContainerTransition.zoom,
                  closedBuilder: (_, open) =>
                      TextButton(onPressed: open, child: const Text('Tile')),
                  openBuilder: (_, _) => Scaffold(
                    title: 'Page',
                    iconActions: [
                      IconButtonData(
                        glyph: AppGlyphs.sync,
                        tooltip: 'Sync',
                        onPressed: () {},
                      ),
                    ],
                    body: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder button() => find.byTooltip('Sync');

  testWidgets('a zoom shows the bar buttons of its page where they rest', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final rest = tester.getRect(button());
    Navigator.of(tester.element(button())).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(button(), findsOneWidget);
    expect(tester.getCenter(button()), rest.center);
    expect(tester.getSize(button()).width, rest.width);

    await tester.pump(const Duration(milliseconds: 150));
    final arriving = tester.getRect(button());
    expect(arriving.center, rest.center);
    expect(arriving.width, greaterThan(rest.width));

    await tester.pumpAndSettle();
    expect(tester.getRect(button()), rest);
    expect(
      find.ancestor(of: button(), matching: find.byType(Scaffold)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bar buttons of a page leave as a zoom closes it', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final rest = tester.getRect(button());

    Navigator.of(tester.element(button())).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 150));
    final leaving = tester.getRect(button());
    expect(leaving.center, rest.center);
    expect(leaving.width, greaterThan(rest.width));

    await tester.pumpAndSettle();
    expect(button(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a page kept alive off screen keeps its bar buttons', (
    tester,
  ) async {
    final pages = PageController();
    addTearDown(pages.dispose);
    await tester.pumpWidget(
      TestApp(
        child: Navigator(
          onGenerateRoute: (settings) => HomeRoute<void>(
            settings: settings,
            builder: (_) => PageView(
              controller: pages,
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 60,
                    child: OpenContainer<void>(
                      transition: OpenContainerTransition.zoom,
                      closedBuilder: (_, open) => TextButton(
                        onPressed: open,
                        child: const Text('Tile'),
                      ),
                      openBuilder: (_, _) => const SizedBox.expand(),
                    ),
                  ),
                ),
                const _KeptAlive(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: BarItemPresence(
                      child: SizedBox.square(dimension: 44),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    pages.jumpToPage(1);
    await tester.pump();
    pages.jumpToPage(0);
    await tester.pump();

    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(BarItemPresence, skipOffstage: false), findsOneWidget);
  });

  testWidgets('a drag back cross-fades the bar buttons of both pages', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Navigator(
          onGenerateRoute: (settings) => HomeRoute<void>(
            settings: settings,
            builder: (_) => Scaffold(
              title: 'Home',
              iconActions: [
                IconButtonData(
                  glyph: AppGlyphs.addCircle,
                  tooltip: 'Add',
                  onPressed: () {},
                ),
              ],
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: OpenContainer<void>(
                    transition: OpenContainerTransition.zoom,
                    closedBuilder: (_, open) =>
                        TextButton(onPressed: open, child: const Text('Tile')),
                    openBuilder: (_, _) => Scaffold(
                      title: 'Page',
                      iconActions: [
                        IconButtonData(
                          glyph: AppGlyphs.sync,
                          tooltip: 'Sync',
                          onPressed: () {},
                        ),
                      ],
                      body: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();

    double presenceOf(String tooltip) =>
        BarItemPresence.of(tester.element(find.byTooltip(tooltip)))?.value ?? 1;
    final reach =
        0.6 * tester.view.physicalSize.width / tester.view.devicePixelRatio;
    Future<void> dragTo(TestGesture gesture, double progress) async {
      await gesture.moveBy(Offset(progress * reach, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    final gesture = await tester.startGesture(const Offset(400, 400));
    await gesture.moveBy(const Offset(20, 0));
    await dragTo(gesture, 0.3);
    expect(presenceOf('Sync'), moreOrLessEquals(0.5, epsilon: 1e-3));
    expect(presenceOf('Add'), 0);

    await dragTo(gesture, 0.4);
    expect(presenceOf('Sync'), 0);
    expect(presenceOf('Add'), moreOrLessEquals(0.5, epsilon: 1e-3));

    await dragTo(gesture, -0.7);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(presenceOf('Sync'), 1);
    expect(find.byTooltip('Add'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  Widget page(int depth) => Scaffold(
    title: 'Page $depth',
    iconActions: [
      IconButtonData(
        glyph: AppGlyphs.sync,
        tooltip: 'Sync$depth',
        onPressed: () {},
      ),
    ],
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(CardPageRoute<void>(builder: (_) => page(depth + 1))),
          child: Text('Push${depth + 1}'),
        ),
      ),
    ),
  );

  Widget pushApp({
    bool homeAction = true,
    bool wideHome = false,
    LiquidGlassQuality? glass,
  }) {
    return TestApp(
      wrapInProviderScope: true,
      liquidGlass: glass,
      child: Navigator(
        onGenerateRoute: (settings) => HomeRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            title: 'Home',
            iconActions: [
              if (homeAction)
                IconButtonData(
                  glyph: AppGlyphs.addCircle,
                  tooltip: 'Add',
                  onPressed: () {},
                ),
              if (wideHome)
                IconButtonData(
                  glyph: AppGlyphs.sync,
                  tooltip: 'Wide',
                  onPressed: () {},
                ),
            ],
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(CardPageRoute<void>(builder: (_) => page(1))),
                  child: const Text('Push1'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double presenceAt(WidgetTester tester, Finder finder) =>
      BarItemPresence.of(tester.element(finder))?.value ?? 1;

  double presenceOf(WidgetTester tester, String tooltip) =>
      presenceAt(tester, find.byTooltip(tooltip, skipOffstage: false));

  int glyphsOf(WidgetTester tester, Finder finder) => tester
      .widgetList(find.descendant(of: finder, matching: find.byType(GlyphIcon)))
      .length;

  bool drawnOverRoutes(WidgetTester tester, String tooltip) {
    final routes = tester.renderObject(
      find
          .descendant(
            of: find.byType(Navigator).last,
            matching: find.byType(Overlay),
          )
          .first,
    );
    for (
      RenderObject? node = tester.renderObject(find.byTooltip(tooltip));
      node != null;
      node = node.parent
    ) {
      if (identical(node, routes)) {
        return false;
      }
    }
    return true;
  }

  testWidgets('a push shows the bar buttons of its page where they rest', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp(homeAction: false));
    await tester.tap(find.text('Push1'));
    await tester.pumpAndSettle();
    final rest = tester.getRect(find.byTooltip('Sync1'));
    final title = tester.getRect(find.text('Page 1'));
    Navigator.of(tester.element(find.byTooltip('Sync1'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Push1'));
    await tester.pump();
    await tester.pump();
    expect(presenceOf(tester, 'Sync1'), 0);
    expect(presenceAt(tester, _back), 0);
    expect(tester.getCenter(find.byTooltip('Sync1')), rest.center);

    await tester.pump(const Duration(milliseconds: 100));
    expect(presenceOf(tester, 'Sync1'), inExclusiveRange(0, 1));
    expect(presenceAt(tester, _back), inExclusiveRange(0, 1));
    expect(tester.getCenter(find.byTooltip('Sync1')), rest.center);
    expect(presenceAt(tester, find.text('Page 1')), 1);
    expect(
      tester.getCenter(find.text('Page 1')).dx,
      greaterThan(title.center.dx),
    );

    await tester.pumpAndSettle();
    expect(presenceOf(tester, 'Sync1'), 1);
    expect(tester.getRect(find.byTooltip('Sync1')), rest);
    expect(drawnOverRoutes(tester, 'Sync1'), isFalse);

    Navigator.of(tester.element(find.byTooltip('Sync1'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    expect(presenceOf(tester, 'Sync1'), inExclusiveRange(0, 1));
    expect(tester.getCenter(find.byTooltip('Sync1')), rest.center);

    await tester.pumpAndSettle();
    expect(find.byTooltip('Sync1'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pushed page moves as it was painted at rest', (tester) async {
    await tester.pumpWidget(pushApp(homeAction: false));
    await tester.tap(find.text('Push1'));
    await tester.pump();
    final body = find.text('Push2');
    expect(ModalRoute.of(tester.element(body))!.animation!.value, 0);
    expect(tester.renderObject(body).debugNeedsPaint, isFalse);

    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(presenceOf(tester, 'Sync1'), inExclusiveRange(0, 1));
    expect(drawnOverRoutes(tester, 'Sync1'), isFalse);
  });

  int filterLayers(WidgetTester tester) {
    var count = 0;
    void visit(Layer? layer) {
      for (; layer != null; layer = layer.nextSibling) {
        if (layer is ImageFilterLayer) {
          count++;
        }
        if (layer is ContainerLayer) {
          visit(layer.firstChild);
        }
      }
    }

    visit(tester.binding.renderViews.first.debugLayer);
    return count;
  }

  for (final glass in [null, LiquidGlassQuality.standard]) {
    testWidgets('bar buttons come in and swap glyphs without a filter layer '
        'under ${glass?.name ?? 'no'} glass', (tester) async {
      await tester.pumpWidget(pushApp(glass: glass));
      await tester.tap(find.text('Push1'));
      await tester.pump();
      await tester.pump();
      for (var frame = 0; frame < 8; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(filterLayers(tester), 0);
      }
      expect(presenceAt(tester, _back), inExclusiveRange(0, 1));
      expect(glyphsOf(tester, find.byTooltip('Sync1')), 2);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('bar buttons blur as they come in under ultra glass', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp(glass: LiquidGlassQuality.ultra));
    await tester.tap(find.text('Push1'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(filterLayers(tester), greaterThan(0));
    await tester.pumpAndSettle();
    expect(filterLayers(tester), 0);
  });

  testWidgets('a push keeps the glass both pages have in a slot and swaps '
      'its glyph', (tester) async {
    await tester.pumpWidget(pushApp());
    final home = tester.getRect(find.byTooltip('Add'));

    await tester.tap(find.text('Push1'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump();
    final sync = find.byTooltip('Sync1');
    expect(presenceOf(tester, 'Sync1'), 1);
    expect(presenceOf(tester, 'Add'), 0);
    expect(glyphsOf(tester, sync), 2);
    expect(tester.getCenter(sync), home.center);
    expect(drawnOverRoutes(tester, 'Add'), isTrue);

    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getRect(sync).width, greaterThan(home.width));
    expect(glyphsOf(tester, sync), 2);

    await tester.pumpAndSettle();
    expect(glyphsOf(tester, sync), 1);
    expect(tester.getRect(sync), home);

    Navigator.of(tester.element(sync)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump();
    expect(presenceOf(tester, 'Add'), 1);
    expect(presenceOf(tester, 'Sync1'), 0);
    expect(glyphsOf(tester, find.byTooltip('Add')), 2);
    expect(drawnOverRoutes(tester, 'Add'), isTrue);

    await tester.pumpAndSettle();
    expect(glyphsOf(tester, find.byTooltip('Add')), 1);
    expect(tester.getRect(find.byTooltip('Add')), home);
    expect(drawnOverRoutes(tester, 'Add'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a push stacks no level on the glass of the pages in a slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      pushApp(wideHome: true, glass: LiquidGlassQuality.standard),
    );

    await tester.tap(find.text('Push1'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));

    final capture = LiquidGlassHost.debugLastCapture!;
    expect(capture.panes.length, greaterThan(1));
    expect(capture.panes.map((pane) => pane.level), everyElement(0));
    expect(capture.snapshots, lessThanOrEqualTo(1));
    await tester.pumpAndSettle();
  });

  testWidgets('a held dock keeps its lens a level over its glass', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        liquidGlass: LiquidGlassQuality.ultra,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BarItemPresence.held(
                child: NavigationDock(
                  destinations: [
                    for (final label in ['One', 'Two'])
                      NavigationDockDestination(
                        glyph: AppGlyphs.add,
                        label: label,
                      ),
                  ],
                  selectedIndex: 0,
                  onSelected: (_) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final gesture = await tester.startGesture(
      Offset(bar.left + bar.width / 4, bar.center.dy),
    );
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final levels = LiquidGlassHost.debugLastCapture!.panes.map(
      (pane) => pane.level,
    );
    expect(levels, contains(1));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a push between pages with back buttons keeps the button', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp());
    await tester.tap(find.text('Push1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Push2'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump();
    final backs = _back;
    expect(presenceAt(tester, backs.at(1)), 1);
    expect(presenceAt(tester, backs.at(0)), 0);
    expect(glyphsOf(tester, backs.at(1)), 1);
    expect(presenceOf(tester, 'Sync2'), 1);
    expect(glyphsOf(tester, find.byTooltip('Sync2')), 1);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a zoom held for its page keeps the back button of both', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp());
    await tester.tap(find.text('Push1'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Push2'))).push(
      CardPageRoute<void>(
        builder: (_) => Scaffold(
          title: 'List',
          body: Center(
            child: SizedBox(
              width: 300,
              height: 60,
              child: OpenContainer<void>(
                transition: OpenContainerTransition.zoom,
                closedBuilder: (_, open) =>
                    TextButton(onPressed: open, child: const Text('Tile')),
                openBuilder: (_, _) => const Scaffold(
                  title: 'Page',
                  body: ArrivalHold(ready: false, child: SizedBox.expand()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump(arrivalHoldLimit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump();
    final backs = _back;
    expect(presenceAt(tester, backs.last), 1);
    expect(presenceAt(tester, backs.first), 0);
    expect(glyphsOf(tester, backs.last), 1);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a zoom fades the titles of both pages where they rest', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Navigator(
          onGenerateRoute: (settings) => HomeRoute<void>(
            settings: settings,
            builder: (_) => Scaffold(
              title: 'Home',
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: OpenContainer<void>(
                    transition: OpenContainerTransition.zoom,
                    closedBuilder: (_, open) =>
                        TextButton(onPressed: open, child: const Text('Tile')),
                    openBuilder: (_, _) =>
                        const Scaffold(title: 'Page', body: SizedBox.expand()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final home = tester.getRect(find.text('Home'));
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final page = tester.getRect(find.text('Page'));
    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    expect(presenceAt(tester, find.text('Page')), inExclusiveRange(0, 1));
    expect(presenceAt(tester, find.text('Home')), inExclusiveRange(0, 1));
    expect(tester.getRect(find.text('Page')), page);
    expect(tester.getRect(find.text('Home')), home);

    await tester.pumpAndSettle();
    expect(presenceAt(tester, find.text('Page')), 1);
    expect(tester.getRect(find.text('Page')), page);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a zoom empties and fades the held dock over it, and brings it '
      'back whole', (tester) async {
    ValueListenable<bool>? filled;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Navigator(
          onGenerateRoute: (settings) => HomeRoute<void>(
            settings: settings,
            builder: (_) => HostScaffold(
              body: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: OpenContainer<void>(
                      transition: OpenContainerTransition.zoom,
                      closedBuilder: (_, open) => TextButton(
                        onPressed: open,
                        child: const Text('Tile'),
                      ),
                      openBuilder: (_, _) => const SizedBox.expand(),
                    ),
                  ),
                  const Spacer(),
                  BarItemPresence.held(
                    child: Builder(
                      builder: (context) {
                        filled = BarItemPresence.filledOf(context);
                        return const Tooltip(
                          message: 'Dock',
                          child: SizedBox(width: 200, height: 60),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final rest = tester.getRect(find.byTooltip('Dock'));
    double zoom() => ModalRoute.of(
      tester.element(find.byType(SizedBox).last),
    )!.animation!.value;

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(zoom(), inExclusiveRange(0, 1));
    expect(presenceOf(tester, 'Dock'), moreOrLessEquals(1 - zoom()));
    expect(filled!.value, isFalse);
    expect(drawnOverRoutes(tester, 'Dock'), isTrue);
    expect(tester.getRect(find.byTooltip('Dock')), rest);

    await tester.pumpAndSettle();
    expect(presenceOf(tester, 'Dock'), 0);

    Navigator.of(tester.element(find.byType(SizedBox).last)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(presenceOf(tester, 'Dock'), 1);
    expect(filled!.value, isTrue);
    expect(drawnOverRoutes(tester, 'Dock'), isTrue);
    expect(tester.getRect(find.byTooltip('Dock')), rest);

    await tester.pumpAndSettle();
    expect(drawnOverRoutes(tester, 'Dock'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a zoom fades the glass at the foot of both pages where it '
      'rests', (tester) async {
    Widget foot(String name, Widget body) => FloatingFootBar(
      bar: Tooltip(
        message: name,
        child: const SizedBox(width: 200, height: 48),
      ),
      body: body,
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Navigator(
          onGenerateRoute: (settings) => HomeRoute<void>(
            settings: settings,
            builder: (_) => HostScaffold(
              body: foot(
                'Below',
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 60,
                    child: OpenContainer<void>(
                      transition: OpenContainerTransition.zoom,
                      closedBuilder: (_, open) => TextButton(
                        onPressed: open,
                        child: const Text('Tile'),
                      ),
                      openBuilder: (_, _) => HostScaffold(
                        body: foot('Page', const SizedBox.expand()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final rest = tester.getRect(find.byTooltip('Below'));

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    for (final name in ['Below', 'Page']) {
      expect(presenceOf(tester, name), inExclusiveRange(0, 1));
      expect(tester.getRect(find.byTooltip(name)), rest);
    }
    expect(drawnOverRoutes(tester, 'Below'), isTrue);

    await tester.pumpAndSettle();
    expect(presenceOf(tester, 'Page'), 1);
    expect(tester.getRect(find.byTooltip('Page')), rest);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drag back of a push holds the bar buttons still', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp());
    await tester.tap(find.text('Push1'));
    await tester.pumpAndSettle();
    final button = find.byTooltip('Sync1');
    final rest = tester.getRect(button);

    final gesture = await tester.startGesture(const Offset(400, 400));
    await gesture.moveBy(const Offset(31, 0));
    await gesture.moveBy(const Offset(200, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getRect(button), rest);
    expect(presenceOf(tester, 'Sync1'), 1);
    expect(presenceOf(tester, 'Add'), 0);

    await gesture.moveBy(const Offset(-200, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(button), rest);
    expect(presenceOf(tester, 'Sync1'), 1);
    expect(drawnOverRoutes(tester, 'Sync1'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a lifted bar button follows its page out of a navigator that '
      'goes away', (tester) async {
    final page = KeyedSubtree(
      key: GlobalKey(),
      child: Scaffold(
        title: 'Page',
        iconActions: [
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: 'Sync',
            onPressed: () {},
          ),
        ],
        body: const SizedBox.expand(),
      ),
    );
    final inNavigator = ValueNotifier(true);
    addTearDown(inNavigator.dispose);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: ValueListenableBuilder(
          valueListenable: inNavigator,
          builder: (_, value, _) => value
              ? Navigator(
                  onGenerateRoute: (settings) => HomeRoute<void>(
                    settings: settings,
                    builder: (context) => TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).push(CardPageRoute<void>(builder: (_) => page)),
                      child: const Text('Open'),
                    ),
                  ),
                )
              : page,
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    inNavigator.value = false;
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(button(), findsOneWidget);
  });

  testWidgets('a bar button lifted over routes keeps its tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(pushApp(homeAction: false));
    await tester.tap(find.text('Push1'));
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(
      location: tester.getCenter(find.byTooltip('Sync1')),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sync1'), findsOneWidget);

    Navigator.of(
      tester.element(find.text('Push2')),
    ).push(CardPageRoute<void>(builder: (_) => const SizedBox.expand()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
    await gesture.removePointer();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a bar button whose group grows mid-push takes its new slot', (
    tester,
  ) async {
    final grown = ValueNotifier(false);
    addTearDown(grown.dispose);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: HostScaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                CardPageRoute<void>(
                  builder: (_) => ValueListenableBuilder(
                    valueListenable: grown,
                    builder: (_, grown, _) => Scaffold(
                      title: 'Page',
                      searchState: AppBarSearchState(onSearch: (_) {}),
                      searchInBar: true,
                      iconActions: [
                        if (grown)
                          IconButtonData(
                            glyph: AppGlyphs.selectAll,
                            tooltip: 'All',
                            onPressed: () {},
                          ),
                      ],
                      body: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              child: const Text('Push'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Push'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    grown.value = true;
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
    final midPush = tester.getRect(find.byTooltip('All'));
    final scale = 1.2 - 0.2 * presenceOf(tester, 'All');

    await tester.pumpAndSettle();
    final rest = tester.getRect(find.byTooltip('All'));
    final group = tester
        .getRect(
          find
              .ancestor(
                of: find.byTooltip('All'),
                matching: find.byType(BarItemPresence),
              )
              .first,
        )
        .center;
    Offset scaled(Offset point) => group + (point - group) * scale;
    expect(midPush.topLeft, offsetMoreOrLessEquals(scaled(rest.topLeft)));
    expect(
      midPush.bottomRight,
      offsetMoreOrLessEquals(scaled(rest.bottomRight)),
    );
  });

  testWidgets('a bar button of a resizing sheet rides its page', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    Widget sheetPage(int depth, double height) => SizedBox(
      height: height,
      child: Scaffold(
        title: 'Page $depth',
        iconActions: [
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: 'Sync$depth',
            onPressed: () {},
          ),
        ],
        body: const SizedBox.expand(),
      ),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: SheetProvider(
          type: SheetType.bottomSheet,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PagedSheet(
              child: SheetPagesNavigator(
                key: navigatorKey,
                onGenerateInitialRoutes: (_, _) => [
                  PagedSheetRoute<void>(builder: (_) => sheetPage(1, 200)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Offset centerInSheet() =>
        tester.getCenter(find.byTooltip('Sync1')) -
        tester.getTopLeft(
          find.ancestor(
            of: find.byTooltip('Sync1'),
            matching: find.byType(Scaffold),
          ),
        );
    final rest = centerInSheet();

    navigatorKey.currentState!.push(
      PagedSheetRoute<void>(builder: (_) => sheetPage(2, 450)),
    );
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(centerInSheet(), rest);
    }
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await tester.pump();
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(centerInSheet(), rest);
    }
    await tester.pumpAndSettle();
    expect(centerInSheet(), rest);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bar buttons of a floating sheet keep their size and place '
      'after a push', (tester) async {
    late BuildContext home;
    Widget sheetPage(int depth, {bool group = false}) => Scaffold(
      title: 'Page $depth',
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.sync,
          tooltip: 'Sync$depth',
          onPressed: () {},
        ),
        if (group)
          IconButtonData(
            glyph: AppGlyphs.addCircle,
            tooltip: 'Add$depth',
            onPressed: () {},
          ),
      ],
      body: const SizedBox(height: 200),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Builder(
          builder: (context) {
            home = context;
            return const HostScaffold();
          },
        ),
      ),
    );
    unawaited(
      showSheet<void>(
        context: home,
        props: nestedPagedSheetProps,
        builder: (_) => NestedPagedSheet(builder: (_) => sheetPage(1)),
      ),
    );
    await tester.pumpAndSettle();
    final rest = tester.getRect(find.byTooltip('Sync1'));
    expect(rest.width, lessThan(tester.getSize(find.byTooltip('Sync1')).width));
    final pages = tester.state<NavigatorState>(
      find.byType(SheetPagesNavigator),
    );

    pages.push(PagedSheetRoute<void>(builder: (_) => sheetPage(2)));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byTooltip('Sync2')), rectMoreOrLessEquals(rest));

    // A group the lift laid out at its shrunken size overflowed.
    pages.push(
      PagedSheetRoute<void>(builder: (_) => sheetPage(3, group: true)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a bar button of a sheet closing mid-pop stays in the sheet', (
    tester,
  ) async {
    late BuildContext home;
    Widget sheetPage(int depth) => Scaffold(
      title: 'Page $depth',
      iconActions: [
        IconButtonData(
          glyph: depth.isEven ? AppGlyphs.sync : AppGlyphs.addCircle,
          tooltip: 'Sync$depth',
          onPressed: () {},
        ),
      ],
      body: const SizedBox(height: 200),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Builder(
          builder: (context) {
            home = context;
            return const HostScaffold();
          },
        ),
      ),
    );
    unawaited(
      showSheet<void>(
        context: home,
        props: nestedPagedSheetProps,
        builder: (_) => NestedPagedSheet(builder: (_) => sheetPage(1)),
      ),
    );
    await tester.pumpAndSettle();
    final sheetPages = tester.state<NavigatorState>(
      find.byType(SheetPagesNavigator),
    );
    double offsetInSheet() =>
        tester.getCenter(find.byTooltip('Sync1', skipOffstage: false)).dy -
        tester.getTopLeft(find.byType(PagedSheet)).dy;
    final rest = offsetInSheet();
    sheetPages.push(PagedSheetRoute<void>(builder: (_) => sheetPage(2)));
    await tester.pumpAndSettle();

    sheetPages.pop();
    for (var frame = 0; frame < 22; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    Navigator.of(home).pop();
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(offsetInSheet(), moreOrLessEquals(rest));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _KeptAlive extends StatefulWidget {
  const _KeptAlive({required this.child});

  final Widget child;

  @override
  State<_KeptAlive> createState() => _KeptAliveState();
}

class _KeptAliveState extends State<_KeptAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
