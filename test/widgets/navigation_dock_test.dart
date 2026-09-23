import 'dart:typed_data';

import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/start_button.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/widgets/widgets.dart';
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

IconButtonData _addAction({bool isLoading = false}) {
  return IconButtonData(
    glyph: AppGlyphs.add,
    onPressed: () {},
    tooltip: _addLabel,
    isLoading: isLoading,
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

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets('the start button holds the end of the dock on every page', (
    tester,
  ) async {
    final container = await _pumpHome(tester);

    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final button = tester.getRect(find.byType(FloatingActionButton));
    expect(find.byType(StartButton), findsOneWidget);
    expect(button.width, button.height);
    expect(button.height, bar.height);
    expect(button.center.dy, bar.center.dy);
    expect(button.left - bar.right, 8);
    expect(button.right, _mobileSize.width - 16);

    await tester.drag(
      find.byType(FloatingNavigationBar),
      Offset(bar.width * 0.7, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.getRect(find.byType(FloatingNavigationBar)), bar);
    expect(find.byType(StartButton), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets(
    'the docked start button swells and follows a drag like the lens',
    (tester) async {
      await _pumpHome(tester);
      final press = find.ancestor(
        of: find.byType(FloatingActionButton),
        matching: find.byType(ElasticPress),
      );
      final resting = tester.getRect(press);
      // The press only paints, so its swell shows in the paint transform.
      Rect painted() {
        final listener = tester.renderObject<RenderProxyBox>(press);
        Matrix4? transform;
        expect(
          listener.child,
          paints..everything((method, arguments) {
            if (method == #transform) {
              transform ??= Matrix4.fromFloat64List(
                arguments.single as Float64List,
              );
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

      final gesture = await tester.startGesture(resting.center);
      await tester.pumpAndSettle();
      final pressed = painted();
      expect(tester.getRect(press), resting);
      expect(pressed.center, resting.center);
      expect(pressed.width, greaterThan(resting.width + 8));
      expect(
        pressed.width / pressed.height,
        moreOrLessEquals(resting.width / resting.height),
      );

      await gesture.moveBy(const Offset(-60, 0));
      await tester.pumpAndSettle();
      final pulled = painted();
      expect(pulled.center.dx, lessThan(resting.center.dx - 4));
      expect(pulled.width / pulled.height, greaterThan(1));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(painted(), resting);
    },
  );

  testWidgets('a phone page shows its primary action in its bar', (
    tester,
  ) async {
    final container = await _pumpHome(tester);
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
    expect(
      find.descendant(
        of: find.byType(CommonScaffold),
        matching: find.byType(FloatingActionButton),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the docked start button stays an icon-only circle while it runs',
    (tester) async {
      await _pumpHome(
        tester,
        settle: false,
        overrides: [
          runTimeProvider.overrideWithBuild(
            (_, _) => const Duration(
              hours: 2,
              minutes: 13,
              seconds: 8,
            ).inMilliseconds,
          ),
        ],
      );

      final bar = tester.getRect(find.byType(FloatingNavigationBar));
      final button = tester.getRect(find.byType(FloatingActionButton));
      expect(button.width, button.height);
      expect(button.height, bar.height);
      expect(find.text('02:13:08'), findsNothing);
      expect(find.byType(RunTimeText), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a page off the dock shows its primary action as a FAB', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: _page('page', primaryAction: _addAction()),
      ),
    );

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    expect(find.text(_addLabel), findsOneWidget);
    expect(find.byType(AppBarActionButton), findsNothing);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: _page('page', primaryAction: _addAction(isLoading: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedScale>(
            find.ancestor(of: fab, matching: find.byType(AnimatedScale)),
          )
          .scale,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long label shrinks to fit, then ellipsizes behind a tooltip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
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
    expect(shrunk, lessThan(11));
    expect(shrunk, greaterThan(10));
    expect(labels.map((text) => text.style!.fontSize).toSet(), {shrunk});
    expect(tooltips, findsNothing);

    labels = await pumpLabels('Configuration');
    expect(labels.first.style!.fontSize, closeTo(10, 0.001));
    expect(tester.widget<Tooltip>(tooltips).message, 'Configuration');
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
