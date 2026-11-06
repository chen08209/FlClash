import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

const _mobileSize = Size(400, 800);

class _RecordingCommonAction extends CommonAction {
  int toggleCount = 0;

  @override
  void build() {}

  @override
  void toggleRunning() {
    toggleCount++;
    final current = ref.read(runTimeProvider);
    ref.read(runTimeProvider.notifier).value = current == null ? 1 : null;
  }
}

Finder _glyph(Glyph glyph) {
  return find.byWidgetPredicate(
    (widget) => widget is AnimatedGlyph && widget.glyph == glyph,
  );
}

Widget _page(String title) {
  return Scaffold(title: title, body: Text('page:$title'));
}

Future<(ProviderContainer, _RecordingCommonAction)> _pumpExpressiveHome(
  WidgetTester tester, {
  List<Profile> profiles = const [
    Profile(id: 1, autoUpdateDuration: Duration.zero),
  ],
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = _mobileSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final recordingAction = _RecordingCommonAction();
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWithValue(profiles),
      suspendProvider.overrideWithValue(false),
      commonActionProvider.overrideWith(() => recordingAction),
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
              glyph: AppGlyphs.proxies,
              label: PageLabel.proxies,
              builder: (_) => _page('proxies'),
            ),
            NavigationItem(
              glyph: AppGlyphs.profiles,
              label: PageLabel.profiles,
              builder: (_) => _page('profiles'),
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
  container
      .read(appSettingProvider.notifier)
      .update(
        (state) =>
            state.copyWith(navigationBarStyle: NavigationBarStyle.floatingFab),
      );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(includeNavigatorKey: false, child: HomePage()),
    ),
  );
  await tester.pumpAndSettle();
  return (container, recordingAction);
}

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  testWidgets(
    'hides the companion FAB on dashboard and shows it on other tabs',
    (tester) async {
      final (container, action) = await _pumpExpressiveHome(tester);

      expect(find.byType(ExpressiveNavigationBar), findsOneWidget);
      expect(find.byType(ExpressiveNavigationFab), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(ExpressiveNavigationBar),
          matching: _glyph(AppGlyphs.proxies),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(currentPageLabelProvider), PageLabel.proxies);
      expect(find.byType(ExpressiveNavigationFab), findsOneWidget);

      await tester.tap(find.byType(ExpressiveNavigationFab));
      await tester.pumpAndSettle();

      expect(action.toggleCount, 1);
      expect(container.read(isStartProvider), isTrue);
      expect(
        tester
            .widget<ExpressiveNavigationFab>(
              find.byType(ExpressiveNavigationFab),
            )
            .running,
        isTrue,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(ExpressiveNavigationBar),
          matching: _glyph(AppGlyphs.dashboard),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
      expect(find.byType(ExpressiveNavigationFab), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disables the companion FAB when there is no profile', (
    tester,
  ) async {
    final (_, action) = await _pumpExpressiveHome(tester, profiles: const []);

    await tester.tap(
      find.descendant(
        of: find.byType(ExpressiveNavigationBar),
        matching: _glyph(AppGlyphs.tools),
      ),
    );
    await tester.pumpAndSettle();

    final fab = tester.widget<ExpressiveNavigationFab>(
      find.byType(ExpressiveNavigationFab),
    );
    expect(fab.enabled, isFalse);

    await tester.tap(find.byType(ExpressiveNavigationFab));
    await tester.pumpAndSettle();
    expect(action.toggleCount, 0);
  });

  testWidgets('stays solid M3E even when Liquid Glass is enabled', (
    tester,
  ) async {
    final (container, _) = await _pumpExpressiveHome(tester);
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(liquidGlass: LiquidGlassMode.ultra));
    container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.profiles);
    await tester.pumpAndSettle();

    final bar = find.byType(ExpressiveNavigationBar);
    expect(
      find.descendant(of: bar, matching: find.byType(LiquidGlass)),
      findsNothing,
    );

    final context = tester.element(bar);
    final colorScheme = context.colorScheme;
    final toolbarBox = tester.widget<DecoratedBox>(
      find.descendant(of: bar, matching: find.byType(DecoratedBox)).first,
    );
    expect(
      (toolbarBox.decoration as ShapeDecoration).color,
      colorScheme.surfaceContainerHigh,
    );

    final surfaces = tester
        .widgetList<PressSurface>(
          find.descendant(of: bar, matching: find.byType(PressSurface)),
        )
        .toList();
    final selectedSurface = surfaces[2];
    final unselectedSurface = surfaces[0];
    expect(selectedSurface.fill, colorScheme.primaryContainer);
    expect(selectedSurface.foreground, colorScheme.onPrimaryContainer);
    expect(unselectedSurface.foreground, colorScheme.onSurfaceVariant);
  });

  testWidgets(
    'switches bar, active pill, and companion FAB to M3E Vibrant colors',
    (tester) async {
      final (container, _) = await _pumpExpressiveHome(tester);
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(colorStyle: ColorStyle.vibrant));
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.profiles);
      await tester.pumpAndSettle();

      final bar = find.byType(ExpressiveNavigationBar);
      final context = tester.element(bar);
      final colorScheme = context.colorScheme;
      final toolbarBox = tester.widget<DecoratedBox>(
        find.descendant(of: bar, matching: find.byType(DecoratedBox)).first,
      );
      expect(
        (toolbarBox.decoration as ShapeDecoration).color,
        colorScheme.primaryContainer,
      );

      final surfaces = tester
          .widgetList<PressSurface>(
            find.descendant(of: bar, matching: find.byType(PressSurface)),
          )
          .toList();
      final selectedSurface = surfaces[2];
      final unselectedSurface = surfaces[0];
      expect(selectedSurface.fill, colorScheme.primary);
      expect(selectedSurface.foreground, colorScheme.onPrimary);
      expect(unselectedSurface.foreground, colorScheme.onPrimaryContainer);

      final fabFinder = find.byType(ExpressiveNavigationFab);
      expect(tester.widget<ExpressiveNavigationFab>(fabFinder).vibrant, isTrue);
      final fabGlyph = tester.widget<GlyphIcon>(
        find.descendant(of: fabFinder, matching: find.byType(GlyphIcon)),
      );
      expect(fabGlyph.color, colorScheme.onTertiaryContainer);
      final fabColors = ExpressiveNavigationBar.fabColorsOf(
        colorScheme,
        vibrant: true,
        enabled: true,
      );
      expect(fabColors.container, colorScheme.tertiaryContainer);
      expect(fabColors.foreground, colorScheme.onTertiaryContainer);
    },
  );

  testWidgets(
    'keeps FAB morph and selection repaints inside its own boundary',
    (tester) async {
      var selected = 1;
      var running = false;
      late StateSetter updateBar;
      final pageBoundary = GlobalKey();

      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: pageBoundary,
                    child: const ColoredBox(color: Color(0xFF112233)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      updateBar = setState;
                      return ExpressiveNavigationBar(
                        destinations: const [
                          NavigationDockDestination(
                            glyph: AppGlyphs.dashboard,
                            label: 'Dashboard',
                          ),
                          NavigationDockDestination(
                            glyph: AppGlyphs.proxies,
                            label: 'Proxies',
                          ),
                          NavigationDockDestination(
                            glyph: AppGlyphs.tools,
                            label: 'Tools',
                          ),
                        ],
                        selectedIndex: selected,
                        onSelected: (index) => setState(() => selected = index),
                        action: ExpressiveNavigationAction(
                          visible: selected != 0,
                          enabled: true,
                          running: running,
                          suspended: false,
                          label: running ? 'Stop' : 'Start',
                          onPressed: () => setState(() => running = !running),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final boundary =
          pageBoundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final baseline = boundary.debugSymmetricPaintCount;

      updateBar(() {
        selected = 2;
        running = true;
      });
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pumpAndSettle();

      expect(boundary.debugSymmetricPaintCount, baseline);
    },
  );

  testWidgets(
    'preserves tab item state and handles mid-flight spring retargeting',
    (tester) async {
      await _pumpExpressiveHome(tester);

      final bar = find.byType(ExpressiveNavigationBar);
      final dashboardGlyph = find.descendant(
        of: bar,
        matching: _glyph(AppGlyphs.dashboard),
      );
      final dashboardLabel = find.descendant(
        of: bar,
        matching: find.text('Dashboard'),
      );
      final dashboardLabelRect = tester.getRect(dashboardLabel);
      final dashboardGlyphRect = tester.getRect(dashboardGlyph);
      expect(dashboardLabelRect.height, lessThan(30));
      expect(
        (dashboardLabelRect.center.dy - dashboardGlyphRect.center.dy).abs(),
        lessThanOrEqualTo(1.5),
      );

      final proxiesGlyph = find.descendant(
        of: bar,
        matching: _glyph(AppGlyphs.proxies),
      );
      final profilesGlyph = find.descendant(
        of: bar,
        matching: _glyph(AppGlyphs.profiles),
      );
      final glyphStateBefore = tester.state(proxiesGlyph);

      await tester.tap(proxiesGlyph);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 64));

      expect(tester.state(proxiesGlyph), same(glyphStateBefore));
      final proxiesLabel = find.descendant(
        of: bar,
        matching: find.text(AppLocalizations.current.proxies),
      );
      final midLabelRect = tester.getRect(proxiesLabel);
      final midGlyphRect = tester.getRect(proxiesGlyph);
      expect(midLabelRect.height, lessThan(30));
      expect(
        (midLabelRect.center.dy - midGlyphRect.center.dy).abs(),
        lessThanOrEqualTo(1.5),
      );

      await tester.tap(profilesGlyph);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 32));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();

      expect(tester.state(proxiesGlyph), same(glyphStateBefore));
      expect(tester.takeException(), isNull);
    },
  );
}
