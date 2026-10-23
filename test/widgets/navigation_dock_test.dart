import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';

const _mobileSize = Size(400, 800);

final _lens = find.descendant(
  of: find.byType(FloatingNavigationBar),
  matching: find.byType(PositionedDirectional),
);
const _addLabel = 'Add';

IconButtonData _addAction() {
  return IconButtonData(
    glyph: AppGlyphs.add,
    onPressed: () {},
    tooltip: _addLabel,
  );
}

Widget _page(String title, {IconButtonData? primaryAction}) {
  return CommonScaffold(
    title: title,
    primaryAction: primaryAction,
    body: Text('page:$title'),
  );
}

Future<ProviderContainer> _pumpHome(
  WidgetTester tester, {
  List<Override> overrides = const [],
  bool settle = true,
}) async {
  tester.view.physicalSize = _mobileSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWithValue([
        const Profile(id: 1, autoUpdateDuration: Duration.zero),
      ]),
      suspendProvider.overrideWithValue(false),
      ...overrides,
      navigationItemsStateProvider.overrideWithValue(
        NavigationItemsState(
          value: [
            NavigationItem(
              glyph: AppGlyphs.dashboard,
              label: PageLabel.dashboard,
              builder: (_) => _page('dashboard'),
            ),
            NavigationItem(
              glyph: AppGlyphs.profiles,
              label: PageLabel.profiles,
              builder: (_) => _page('profiles', primaryAction: _addAction()),
            ),
            NavigationItem(
              glyph: AppGlyphs.tools,
              label: PageLabel.tools,
              builder: (_) => _page('tools'),
            ),
          ],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = _mobileSize;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(includeNavigatorKey: false, child: HomePage()),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(seconds: 1));
  }
  return container;
}

// A press only paints, so its swell shows in the paint transform.
Rect _painted(WidgetTester tester, RenderObject box, Rect resting) {
  Matrix4? transform;
  expect(
    box,
    paints..everything((method, arguments) {
      if (method == #transform) {
        transform ??= Matrix4.fromFloat64List(arguments.single as Float64List);
      }
      return true;
    }),
  );
  final local = Offset.zero & resting.size;
  return (transform == null
          ? local
          : MatrixUtils.transformRect(transform!, local))
      .shift(resting.topLeft);
}

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets('the dock stays centred alone on every page, the dashboard '
      'included', (tester) async {
    final container = await _pumpHome(tester);

    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(bar.center.dx, _mobileSize.width / 2);

    await tester.drag(
      find.byType(FloatingNavigationBar),
      Offset(bar.width * 0.7, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    final alone = tester.getRect(find.byType(FloatingNavigationBar));
    expect(alone.center.dx, _mobileSize.width / 2);
    expect(alone.width, lessThan(_mobileSize.width - 40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap that just misses the bar still reaches it', (
    tester,
  ) async {
    final container = await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    final tools = bar.left + 4 + extent * 2.5;

    await tester.tapAt(Offset(tools, bar.bottom + 12));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

    await tester.tapAt(Offset(tools, bar.bottom + 6));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);

    final alone = tester.getRect(find.byType(FloatingNavigationBar));
    await tester.tapAt(Offset(alone.left - 6, alone.top - 6));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
  });

  testWidgets('the lens keeps up with a finger that never pauses', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    var finger = Offset(bar.left + 4 + extent / 2, bar.center.dy);
    final gesture = await tester.startGesture(finger);
    await tester.pump(const Duration(milliseconds: 16));
    for (var i = 0; i < 30; i++) {
      finger += Offset(extent * 2 / 30, 0);
      await gesture.moveTo(finger);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.getCenter(_lens).dx, closeTo(finger.dx, extent * 0.3));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the lens moving repaints the dock and not the page', (
    tester,
  ) async {
    await _pumpHome(tester);
    final page = tester.renderObject<RenderRepaintBoundary>(
      find
          .ancestor(
            of: find.byType(HomePage),
            matching: find.byType(RepaintBoundary),
          )
          .first,
    );
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    var finger = Offset(bar.left + 4 + extent / 2, bar.center.dy);
    final gesture = await tester.startGesture(finger);
    await tester.pump(const Duration(milliseconds: 16));
    page.debugResetMetrics();
    for (var i = 0; i < 10; i++) {
      finger += Offset(extent / 10, 0);
      await gesture.moveTo(finger);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(page.debugSymmetricPaintCount + page.debugAsymmetricPaintCount, 0);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the lens stops asking for frames once its wobble cannot show', (
    tester,
  ) async {
    final container = await _pumpHome(tester);
    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pump();
    var elapsed = Duration.zero;
    while (tester.binding.hasScheduledFrame && elapsed.inSeconds < 3) {
      await tester.pump(const Duration(milliseconds: 16));
      elapsed += const Duration(milliseconds: 16);
    }
    expect(elapsed, lessThan(const Duration(milliseconds: 1200)));
  });

  testWidgets('a flick carries the lens on to the next item', (tester) async {
    final container = await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    final start = Offset(bar.left + 4 + extent / 2, bar.center.dy);

    Future<void> drag(Duration duration) async {
      await tester.timedDragFrom(start, Offset(extent * 0.35, 0), duration);
      await tester.pumpAndSettle();
    }

    await drag(const Duration(seconds: 1));
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

    await drag(const Duration(milliseconds: 50));
    expect(container.read(currentPageLabelProvider), PageLabel.profiles);
  });

  testWidgets('a press lifts the lens past the bar until it is let go', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final resting = tester.getRect(_lens);
    expect(resting.height, bar.height - 8);

    final gesture = await tester.startGesture(resting.center);
    await tester.pumpAndSettle();
    final lifted = tester.getRect(_lens);
    expect(lifted.top, lessThan(bar.top));
    expect(lifted.bottom, greaterThan(bar.bottom));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(_lens), resting);
  });

  testWidgets('a quick tap lifts the lens all the way before it drops', (
    tester,
  ) async {
    await _pumpHome(tester);
    final resting = tester.getRect(_lens);
    final hold = await tester.startGesture(resting.center);
    await tester.pumpAndSettle();
    final held = tester.getRect(_lens).height - resting.height;
    await hold.up();
    await tester.pumpAndSettle();

    final tap = await tester.startGesture(resting.center);
    await tester.pump(const Duration(milliseconds: 40));
    await tap.up();
    var lifted = 0.0;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      lifted = math.max(lifted, tester.getRect(_lens).height - resting.height);
    }
    expect(lifted, greaterThan(held * 0.97));

    await tester.pumpAndSettle();
    expect(tester.getRect(_lens), resting);
  });

  for (final (quality, lifted) in [
    (LiquidGlassQuality.standard, 2),
    (LiquidGlassQuality.ultra, 3),
  ]) {
    testWidgets('on ${quality.name} glass the dock and a lifted lens are panes '
        'of glass', (tester) async {
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: LiquidGlassScope(
                enabled: true,
                quality: quality,
                child: child,
              ),
            ),
          ),
          child: NavigationDock(
            destinations: const [
              NavigationDockDestination(glyph: AppGlyphs.dashboard, label: 'a'),
              NavigationDockDestination(glyph: AppGlyphs.tools, label: 'b'),
            ],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final glass = find.byType(LiquidGlass);
      expect(glass, findsOneWidget);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('b')),
      );
      await tester.pumpAndSettle();
      expect(glass, findsNWidgets(lifted));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(glass, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the bar swells under a pointer and stretches past its end', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = find.byType(FloatingNavigationBar);
    final resting = tester.getRect(bar);
    Rect painted() => _painted(tester, tester.renderObject(bar), resting);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(resting.center);
    await tester.pumpAndSettle();
    final hovered = painted();
    expect(hovered.center, resting.center);
    expect(hovered.width, greaterThan(resting.width));

    await mouse.down(resting.center);
    await tester.pumpAndSettle();
    final pressed = painted();
    expect(tester.getRect(bar), resting);
    expect(pressed.center, resting.center);
    expect(pressed.width, greaterThan(hovered.width));
    expect(pressed.height, greaterThan(resting.height));

    await mouse.moveTo(resting.centerRight + const Offset(80, 0));
    await tester.pumpAndSettle();
    final pulled = painted();
    expect(pulled.center.dx, greaterThan(resting.center.dx + 4));
    expect(pulled.width, greaterThan(pressed.width));

    await mouse.up();
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(painted(), resting);
  });

  testWidgets(
    'a hovering pointer highlights and draws only the item under it',
    (tester) async {
      await _pumpHome(
        tester,
        overrides: [
          currentPageLabelProvider.overrideWithBuild((_, _) => PageLabel.tools),
        ],
      );
      final bar = find.byType(FloatingNavigationBar);
      final tools = find
          .descendant(of: bar, matching: find.byType(GlyphIcon))
          .last;
      final resting = tester.getRect(tools);
      // The lens is drawn first, so the highlight is the last positioned child.
      final positioned = find.descendant(
        of: bar,
        matching: find.byType(Positioned),
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(resting.center + const Offset(30, 0));
      await tester.pumpAndSettle();
      final hovered = tester.getRect(tools);
      expect(hovered.width, moreOrLessEquals(resting.width));
      expect(positioned, findsNWidgets(2));
      final highlight =
          tester.getCenter(positioned.last).dx - resting.center.dx;
      final drawn = hovered.center.dx - resting.center.dx;
      expect(drawn, greaterThan(0.5));
      expect(drawn, moreOrLessEquals(highlight / 2, epsilon: 0.5));
      expect(highlight, lessThan(30));
      expect(
        tester.getRect(positioned.first),
        rectMoreOrLessEquals(tester.getRect(positioned.last)),
      );

      await mouse.moveTo(resting.center - const Offset(80, 0));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester.getRect(tools).center.dx,
          inInclusiveRange(resting.center.dx - 0.5, hovered.center.dx),
        );
      }
      await tester.pumpAndSettle();
      expect(tester.getCenter(tools).dx, moreOrLessEquals(resting.center.dx));

      await mouse.moveTo(resting.center);
      await tester.pumpAndSettle();

      await mouse.down(resting.center);
      await tester.pumpAndSettle();
      expect(positioned, findsOneWidget);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(positioned, findsNWidgets(2));

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(tester.getCenter(tools).dx, moreOrLessEquals(resting.center.dx));
      expect(positioned, findsOneWidget);
    },
  );

  testWidgets('a tap leaves no highlight behind', (tester) async {
    await _pumpHome(tester);
    final bar = find.byType(FloatingNavigationBar);
    final tools = find
        .descendant(of: bar, matching: find.byType(GlyphIcon))
        .last;
    final positioned = find.descendant(
      of: bar,
      matching: find.byType(Positioned),
    );

    final finger = await tester.createGesture();
    addTearDown(finger.removePointer);
    await finger.addPointer(location: Offset.zero);
    await finger.moveTo(tester.getCenter(tools));
    await tester.pumpAndSettle();
    expect(positioned, findsOneWidget);

    await finger.down(tester.getCenter(tools));
    await finger.up();
    await tester.pumpAndSettle();
    expect(positioned, findsOneWidget);
  });

  for (final floating in [true, false]) {
    testWidgets('a phone page shows its primary action in its bar above a '
        '${floating ? 'floating' : 'fixed'} navigation bar', (tester) async {
      final container = await _pumpHome(tester);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(floatingNavigationBar: floating));
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.profiles);
      await tester.pumpAndSettle();

      final action = find.byWidgetPredicate(
        (widget) =>
            widget is AppBarActionButton && widget.data.tooltip == _addLabel,
      );
      expect(action, findsOneWidget);
      expect(
        find.ancestor(of: action, matching: find.byType(AppBar)),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('four destinations keep to their width and five fill the row', (
    tester,
  ) async {
    const size = Size(560, 800);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<Rect> pumpBar(int count) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: NavigationDock(
                destinations: [
                  for (var index = 0; index < count; index++)
                    NavigationDockDestination(
                      glyph: AppGlyphs.tools,
                      label: '$index',
                    ),
                ],
                selectedIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      return tester.getRect(find.byType(FloatingNavigationBar));
    }

    final four = await pumpBar(4);
    expect(four.center.dx, size.width / 2);
    expect(four.width, lessThan(size.width - 42));
    final five = await pumpBar(5);
    expect(five.left, 21);
    expect(five.right, size.width - 21);
  });

  testWidgets('a long label shrinks to fit, then ellipsizes behind a tooltip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(340, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<List<Text>> pumpLabels(String label) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: NavigationDock(
                destinations: [
                  for (final text in ['Home', 'Apps', 'Logs', label])
                    NavigationDockDestination(
                      glyph: AppGlyphs.tools,
                      label: text,
                    ),
                ],
                selectedIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      return tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(FloatingNavigationBar),
              matching: find.byType(Text),
            ),
          )
          .toList();
    }

    final tooltips = find.descendant(
      of: find.byType(FloatingNavigationBar),
      matching: find.byType(Tooltip),
    );

    var labels = await pumpLabels('Profile');
    final shrunk = labels.first.style!.fontSize!;
    expect(shrunk, lessThan(10));
    expect(shrunk, greaterThan(9));
    expect(labels.map((text) => text.style!.fontSize).toSet(), {shrunk});
    expect(tooltips, findsNothing);

    labels = await pumpLabels('Configuration');
    expect(labels.first.style!.fontSize, closeTo(9, 0.001));
    expect(tester.widget<Tooltip>(tooltips).message, 'Configuration');
  });

  testWidgets('a quick tap swells an elastic press all the way', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(
        child: Center(
          child: ElasticPress(
            child: ColoredBox(
              color: Colors.blue,
              child: SizedBox.square(dimension: 40),
            ),
          ),
        ),
      ),
    );
    final press = find.byType(ElasticPress);
    final resting = tester.getRect(press);
    Rect painted() => _painted(tester, tester.renderObject(press), resting);

    final gesture = await tester.startGesture(resting.center);
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    var swollen = resting.width;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      swollen = math.max(swollen, painted().width);
    }
    expect(swollen, greaterThan(resting.width * 1.24));

    await tester.pumpAndSettle();
    expect(painted(), resting);
  });

  testWidgets('a pointer lifts a tonal button part way, with no state layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: TonalButtonTheme(
            child: ElasticPress(
              child: IconButton(
                tooltip: _addLabel,
                onPressed: () {},
                icon: const GlyphIcon(AppGlyphs.add),
              ),
            ),
          ),
        ),
      ),
    );
    final press = find.byType(ElasticPress);
    final resting = tester.getRect(press);
    double width() =>
        _painted(tester, tester.renderObject(press), resting).width;
    final ink = tester.widget<InkWell>(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byType(InkWell),
      ),
    );
    for (final state in [
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.pressed,
    ]) {
      expect(ink.overlayColor!.resolve({state}), Colors.transparent);
    }

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(resting.center);
    await tester.pumpAndSettle();
    final hovered = width();
    expect(hovered, greaterThan(resting.width * 1.05));

    await mouse.down(resting.center);
    await tester.pumpAndSettle();
    expect(width(), greaterThan(hovered));

    await mouse.up();
    await tester.pumpAndSettle();
    expect(width(), moreOrLessEquals(hovered));

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(width(), resting.width);
    await mouse.removePointer();
  });

  testWidgets(
    'an elastic button leaves a press to the swell and keeps the icon theme',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: IconTheme.merge(
              data: const IconThemeData(fill: 1),
              child: Row(
                children: [
                  ElasticButton(
                    child: IconButton.filled(
                      tooltip: _addLabel,
                      onPressed: () {},
                      icon: const GlyphIcon(AppGlyphs.add),
                    ),
                  ),
                  ElasticButton(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text(_addLabel),
                    ),
                  ),
                  ElasticButton(
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () {},
                      child: const GlyphIcon(AppGlyphs.copy),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      InkWell inkOf(Type button) => tester.widget<InkWell>(
        find.descendant(
          of: find.byType(button),
          matching: find.byType(InkWell),
        ),
      );
      for (final button in [IconButton, FilledButton]) {
        final ink = inkOf(button);
        expect(ink.splashFactory, NoSplash.splashFactory);
        expect(
          ink.overlayColor!.resolve({WidgetState.pressed}),
          Colors.transparent,
        );
      }
      final fabInk = find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byType(InkWell),
      );
      final fabTheme = Theme.of(tester.element(fabInk));
      expect(fabTheme.splashFactory, NoSplash.splashFactory);
      expect(fabTheme.highlightColor, Colors.transparent);
      expect(
        IconTheme.of(tester.element(find.byType(GlyphIcon).first)).fill,
        1,
      );
    },
  );
}
