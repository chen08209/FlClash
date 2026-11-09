import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

Finder _glyph(Glyph glyph) => find.byGlyph(glyph);

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets('initial desktop layout does not animate mobile navigation out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    expect(container.read(viewSizeProvider), Size.zero);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _ThemeManagedTestApp(),
      ),
    );

    expect(globalState.navigatorKey.currentContext, isNotNull);
    expect(container.read(viewSizeProvider), const Size(1200, 800));
    expect(find.byType(FloatingNavigationBar), findsNothing);

    await tester.pump();

    expect(find.byType(NavigationSidebar), findsOneWidget);
    expect(find.byType(FloatingNavigationBar), findsNothing);

    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(FloatingNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the frame before the view size is known paints the page', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _ThemeManagedTestApp(),
      ),
    );

    final home = find.byType(HomePage);
    final fill = tester.widget<ColoredBox>(
      find.descendant(of: home, matching: find.byType(ColoredBox)).first,
    );
    expect(
      fill.color,
      SurfaceLevel.page.colorOf(tester.element(home).colorScheme),
    );
  });

  testWidgets(
    'screen-size transition preserves current content and animates navigation',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => const _StatefulContent(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();

      final sidebarBackground = find.descendant(
        of: find.byType(AppSidebarContainer),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.child is Row,
        ),
      );
      final sidebarContainer = tester.widget<Container>(
        sidebarBackground.first,
      );
      final colorScheme = Theme.of(
        tester.element(find.byType(AppSidebarContainer)),
      ).colorScheme;
      expect(sidebarContainer.color, SurfaceLevel.page.colorOf(colorScheme));
      final sidebarSurface = tester.widget<Surface>(
        find
            .ancestor(
              of: find.byType(NavigationSidebar),
              matching: find.byType(Surface),
            )
            .first,
      );
      expect(sidebarSurface.color, colorScheme.chromeSurface);
      expect(sidebarSurface.color, isNot(sidebarContainer.color));
      expect(
        (sidebarSurface.shape! as BorderDirectional).end,
        Divider.createBorderSide(
          tester.element(find.byType(NavigationSidebar)),
        ),
      );

      await tester.tap(find.text('count: 0'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.byType(FloatingNavigationBar), findsNothing);

      for (var width = 1180.0; width >= 500; width -= 20) {
        tester.view.physicalSize = Size(width, 800);
        container.read(viewSizeProvider.notifier).value = Size(width, 800);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'width: $width');
      }

      expect(find.text('count: 1'), findsOneWidget);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.byType(FloatingNavigationBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);

      final outgoingTools = find.descendant(
        of: find.byType(NavigationSidebar),
        matching: _glyph(AppGlyphs.tools),
      );
      await tester.tap(outgoingTools, warnIfMissed: false);
      await tester.pump();
      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

      await tester.pump(const Duration(milliseconds: 301));
      expect(find.byType(NavigationSidebar), findsNothing);
      expect(find.byType(FloatingNavigationBar), findsOneWidget);

      tester.view.physicalSize = const Size(1200, 800);
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);
      await tester.pump();

      expect(find.text('count: 1'), findsOneWidget);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.byType(FloatingNavigationBar), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 301));
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.byType(FloatingNavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the sidebar widens in place only at desktop width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final sidebar = find.byType(NavigationSidebar);
    expect(tester.getSize(sidebar).width, 220);

    await tester.tap(find.byTooltip('Collapse'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(appSettingProvider).sidebarExpanded, isFalse);
    expect(tester.getSize(sidebar).width, 48);

    await tester.tap(find.byTooltip('Expand'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(sidebar).width, 220);

    tester.view.physicalSize = const Size(800, 800);
    container.read(viewSizeProvider.notifier).value = const Size(800, 800);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(sidebar).width, 48);

    await tester.tap(find.byTooltip('Expand'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(sidebar).width, 48);
    expect(find.text('Tools'), findsNWidgets(2));
    expect(container.read(appSettingProvider).sidebarExpanded, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'list content stays valid while resizing through the breakpoint',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => const ToolsView(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();

      for (var width = 1180.0; width >= 380; width -= 20) {
        tester.view.physicalSize = Size(width, 800);
        container.read(viewSizeProvider.notifier).value = Size(width, 800);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'width: $width');
      }
    },
  );

  testWidgets(
    'tools page survives widening past the breakpoint with more items',
    (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => const SizedBox.shrink(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.proxies,
                  label: PageLabel.logs,
                  modes: const [
                    NavigationItemMode.desktop,
                    NavigationItemMode.more,
                  ],
                  builder: (_) => const SizedBox.shrink(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.connections,
                  label: PageLabel.requests,
                  modes: const [
                    NavigationItemMode.desktop,
                    NavigationItemMode.more,
                  ],
                  builder: (_) => const SizedBox.shrink(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) => const ToolsView(),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(500, 800);
      container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();
      expect(find.byType(ToolsView), findsOneWidget);
      expect(find.byType(FloatingNavigationBar), findsOneWidget);

      for (var width = 520.0; width <= 1200; width += 20) {
        tester.view.physicalSize = Size(width, 800);
        container.read(viewSizeProvider.notifier).value = Size(width, 800);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'width: $width');
      }
      await tester.pump(const Duration(milliseconds: 301));
      expect(tester.takeException(), isNull);
      expect(find.byType(ToolsView), findsOneWidget);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(container.read(currentPageLabelProvider), PageLabel.tools);

      for (var width = 1180.0; width >= 500; width -= 20) {
        tester.view.physicalSize = Size(width, 800);
        container.read(viewSizeProvider.notifier).value = Size(width, 800);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'width: $width');
      }
      await tester.pump(const Duration(milliseconds: 301));
      expect(tester.takeException(), isNull);
      expect(find.byType(ToolsView), findsOneWidget);
      expect(container.read(currentPageLabelProvider), PageLabel.tools);
    },
  );

  testWidgets(
    'profile trailing controls stay valid while a maximized window restores',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = Profile.normal();
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => _HomeTestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          versionProvider.overrideWithBuild((_, _) => 15),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.profiles);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            includeNavigatorKey: false,
            child: ThemeManager(
              child: WindowHeaderContainer(child: HomePage()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(380, 900);
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop navigation keeps the tools route when logs are enabled',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1400, 1000);
      container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();

      final generalItem = find.text('General');
      await tester.scrollUntilVisible(
        generalItem,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(generalItem);
      await tester.pumpAndSettle();
      expect(find.byType(GeneralView), findsOneWidget);

      final logItem = find.text('Logcat');
      await tester.scrollUntilVisible(
        logItem,
        500,
        scrollable: find
            .descendant(
              of: find.byType(GeneralView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pump();
      await tester.tap(logItem);
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).openLogs, isTrue);
      expect(find.byType(GeneralView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop navigation keeps arrow traversal after keyboard page changes',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {},
                      icon: const SizedBox.square(dimension: 24),
                    ),
                  ),
                ),
                NavigationItem(
                  glyph: AppGlyphs.proxies,
                  label: PageLabel.proxies,
                  builder: (_) => Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {},
                      icon: const SizedBox.square(dimension: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();
      expect(find.byType(NavigationSidebar), findsOneWidget);

      bool focusInSidebar() {
        final context = FocusManager.instance.primaryFocus?.context;
        return context?.findAncestorWidgetOfExactType<NavigationSidebar>() !=
            null;
      }

      Glyph? focusedSidebarIcon() {
        final focusNode = FocusManager.instance.primaryFocus;
        if (!focusInSidebar() || focusNode == null) {
          return null;
        }
        for (final glyph in [AppGlyphs.dashboard, AppGlyphs.proxies]) {
          if (focusNode.rect.contains(tester.getCenter(_glyph(glyph)))) {
            return glyph;
          }
        }
        return null;
      }

      for (var i = 0; i < 30 && focusedSidebarIcon() == null; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(focusedSidebarIcon(), AppGlyphs.dashboard);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedSidebarIcon(), AppGlyphs.proxies);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(container.read(currentPageLabelProvider), PageLabel.proxies);
      final sidebar = tester.widget<NavigationSidebar>(
        find.byType(NavigationSidebar),
      );
      expect(sidebar.selectedIndex, 1);
      expect(focusedSidebarIcon(), AppGlyphs.proxies);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedSidebarIcon(), AppGlyphs.dashboard);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
      expect(focusedSidebarIcon(), AppGlyphs.dashboard);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(focusedSidebarIcon(), AppGlyphs.proxies);
      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
    },
  );

  testWidgets('mobile bottom navigation keeps page and highlight consistent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget page(String label) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Text('page:$label'),
          Positioned(
            left: 200,
            bottom: 0,
            child: Builder(
              builder: (context) => Padding(
                padding: EdgeInsets.only(bottom: BottomInsetScope.of(context)),
                child: IconButton(
                  key: const ValueKey('content-action'),
                  onPressed: () {},
                  icon: const SizedBox.square(dimension: 24),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => page('dashboard'),
              ),
              NavigationItem(
                glyph: AppGlyphs.profiles,
                label: PageLabel.profiles,
                builder: (_) => page('profiles'),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => page('tools'),
              ),
              NavigationItem(
                glyph: AppGlyphs.proxies,
                label: PageLabel.logs,
                builder: (_) => page('logs'),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    expect(find.byType(FloatingNavigationBar), findsOneWidget);

    FloatingNavigationBar navBar() => tester.widget<FloatingNavigationBar>(
      find.byType(FloatingNavigationBar),
    );

    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(navBar().selectedIndex, 2);
    expect(find.text('page:tools'), findsOneWidget);

    bool focusInNav() {
      final context = FocusManager.instance.primaryFocus?.context;
      return context?.findAncestorWidgetOfExactType<FloatingNavigationBar>() !=
          null;
    }

    for (var i = 0; i < 20 && !focusInNav(); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(focusInNav(), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.profiles);
    expect(navBar().selectedIndex, 1);
    expect(find.text('page:profiles'), findsOneWidget);

    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(_glyph(AppGlyphs.proxies));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(_glyph(AppGlyphs.profiles));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.profiles);
    expect(navBar().selectedIndex, 1);
    expect(find.text('page:profiles'), findsOneWidget);
    expect(focusInNav(), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    final focusedIconButton = FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<IconButton>();
    expect(
      focusedIconButton?.key,
      const ValueKey('content-action'),
      reason: 'up from the bottom bar must enter the current page',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a page that leaves the navigation hands the screen to the '
      'first one until it returns', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    NavigationItem item(Glyph glyph, PageLabel label) => NavigationItem(
      glyph: glyph,
      label: label,
      builder: (_) => Builder(
        builder: (context) => Text(
          'page:${label.name} active:${PageActivityScope.isActiveOf(context)}',
        ),
      ),
    );
    final dashboard = item(AppGlyphs.dashboard, PageLabel.dashboard);
    final proxies = item(AppGlyphs.proxies, PageLabel.proxies);
    final profiles = item(AppGlyphs.profiles, PageLabel.profiles);
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWith(
          (ref) =>
              NavigationItemsState(value: ref.watch(_navigationItemsProvider)),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);
    final items = container.read(_navigationItemsProvider.notifier)
      ..set([dashboard, proxies, profiles]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    await tester.tap(_glyph(AppGlyphs.proxies));
    await tester.pumpAndSettle();

    int selectedIndex() => tester
        .widget<FloatingNavigationBar>(find.byType(FloatingNavigationBar))
        .selectedIndex;

    expect(selectedIndex(), 1);
    expect(find.text('page:proxies active:true'), findsOneWidget);

    items.set([dashboard, profiles]);
    await tester.pumpAndSettle();
    expect(selectedIndex(), 0);
    expect(find.text('page:dashboard active:true'), findsOneWidget);
    expect(find.textContaining('page:profiles'), findsNothing);
    expect(container.read(currentPageLabelProvider), PageLabel.proxies);

    items.set([dashboard, proxies, profiles]);
    await tester.pumpAndSettle();
    expect(selectedIndex(), 1);
    expect(find.text('page:proxies active:true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a page inserted before the current one leaves it on screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    NavigationItem item(Glyph glyph, PageLabel label) => NavigationItem(
      glyph: glyph,
      label: label,
      builder: (_) => Center(child: Text('page:${label.name}')),
    );
    final dashboard = item(AppGlyphs.dashboard, PageLabel.dashboard);
    final proxies = item(AppGlyphs.proxies, PageLabel.proxies);
    final profiles = item(AppGlyphs.profiles, PageLabel.profiles);
    final tools = item(AppGlyphs.tools, PageLabel.tools);
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWith(
          (ref) =>
              NavigationItemsState(value: ref.watch(_navigationItemsProvider)),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.fade));
    final items = container.read(_navigationItemsProvider.notifier)
      ..set([dashboard, profiles, tools]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pumpAndSettle();

    items.set([dashboard, proxies, profiles, tools]);
    await tester.pumpAndSettle();

    final page = find.text('page:tools');
    expect(page.hitTestable(), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: page, matching: find.byType(Opacity)).first,
          )
          .opacity,
      1,
    );
    expect(tester.getCenter(page).dx, 250);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a non-floating bottom bar leaves the page no bottom inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget page(String label) {
      return Builder(
        builder: (context) =>
            Text('page:$label inset:${BottomInsetScope.of(context)}'),
      );
    }

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => page('dashboard'),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => page('tools'),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(floatingNavigationBar: false));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    expect(find.byType(FloatingNavigationBar), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('page:dashboard inset:0.0'), findsOneWidget);

    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(floatingNavigationBar: true));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(FloatingNavigationBar), findsOneWidget);
    expect(find.textContaining('page:tools inset:'), findsOneWidget);
    expect(find.text('page:tools inset:0.0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the dock over the system bar leaves the content one clearance', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 800)
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);

    double? inset;
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              for (final (glyph, label) in [
                (AppGlyphs.dashboard, PageLabel.dashboard),
                (AppGlyphs.tools, PageLabel.tools),
              ])
                NavigationItem(
                  glyph: glyph,
                  label: label,
                  builder: (_) => Scaffold(
                    title: label.name,
                    body: Builder(
                      builder: (context) {
                        inset = context.bottomInset;
                        return const SizedBox.expand(key: ValueKey('body'));
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();

    final dockInset = NavigationDock.insetOf(
      tester.element(find.byType(NavigationDock)),
    );
    final bodyBottom = tester
        .getRect(find.byKey(const ValueKey('body')))
        .bottom;
    expect(bodyBottom, 800);
    expect(bodyBottom - inset!, 800 - dockInset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the fade tab switch cross-fades the pages in place', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const Text('page:dashboard'),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const Text('page:tools'),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.fade));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();
    final start = tester.getTopLeft(find.text('page:dashboard')).dx;

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    double opacityOf(String text) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
        )
        .opacity;
    expect(tester.getTopLeft(find.text('page:dashboard')).dx, start);
    expect(tester.getTopLeft(find.text('page:tools')).dx, start);
    expect(opacityOf('page:dashboard'), inExclusiveRange(0, 1));
    expect(
      opacityOf('page:dashboard') + opacityOf('page:tools'),
      moreOrLessEquals(1),
    );

    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.getTopLeft(find.text('page:tools')).dx, start);
    expect(tester.takeException(), isNull);
  });

  for (final animation in TabAnimation.values) {
    testWidgets('a ${animation.name} tab switch draws moving pages from '
        'snapshots and resting ones live', (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => const Text('page:dashboard'),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) => const Text('page:tools'),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(500, 800);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(tabAnimation: animation));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();

      bool snapshots(String text) => tester
          .widget<SnapshotWidget>(
            find
                .ancestor(
                  of: find.text(text),
                  matching: find.byType(SnapshotWidget),
                )
                .first,
          )
          .controller
          .allowSnapshotting;

      expect(snapshots('page:dashboard'), isFalse);

      container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(snapshots('page:dashboard'), isTrue);
      expect(snapshots('page:tools'), isTrue);

      await tester.pumpAndSettle();
      expect(snapshots('page:tools'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a far mobile page switch builds no page in between', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final inits = <PageLabel>[];
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              for (final (glyph, label) in [
                (AppGlyphs.dashboard, PageLabel.dashboard),
                (AppGlyphs.proxies, PageLabel.proxies),
                (AppGlyphs.profiles, PageLabel.profiles),
                (AppGlyphs.tools, PageLabel.tools),
              ])
                NavigationItem(
                  glyph: glyph,
                  label: label,
                  builder: (_) => _InitRecorder(label: label, inits: inits),
                ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('page:dashboard'), findsOneWidget);
    expect(find.text('page:tools'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('page:dashboard'), findsNothing);
    expect(find.text('page:tools'), findsOneWidget);

    await tester.tap(_glyph(AppGlyphs.dashboard));
    await tester.pumpAndSettle();
    expect(find.text('page:dashboard'), findsOneWidget);
    expect(inits.toSet(), {PageLabel.dashboard, PageLabel.tools});
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching home pages exits a generic search layer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var query = '';
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => Scaffold(
                  title: 'Search page',
                  searchState: AppBarSearchState(
                    onSearch: (value) {
                      query = value;
                    },
                  ),
                  body: const SizedBox(),
                ),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'needle');
    expect(query, 'needle');

    await tester.tap(_glyph(AppGlyphs.tools));
    await tester.pumpAndSettle();
    expect(query, isEmpty);
    await tester.tap(_glyph(AppGlyphs.dashboard));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a page kept alive off screen stops asking for frames', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.profiles,
                label: PageLabel.profiles,
                builder: (_) => const Center(child: ActivityIndicator()),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();

    Finder railIcon(Glyph glyph) => find.descendant(
      of: find.byType(NavigationSidebar),
      matching: _glyph(glyph),
    );

    await tester.tap(railIcon(AppGlyphs.profiles));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.tap(railIcon(AppGlyphs.dashboard));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityIndicator, skipOffstage: false), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('desktop nested route inherits home page activity', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var query = '';
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => _NestedSearchLauncher(
                  onSearch: (value) {
                    query = value;
                  },
                ),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open nested search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'needle');
    expect(query, 'needle');

    final navigationRail = find.byType(NavigationSidebar);
    await tester.tap(
      find.descendant(of: navigationRail, matching: _glyph(AppGlyphs.tools)),
    );
    await tester.pumpAndSettle();
    expect(query, isEmpty);

    await tester.tap(
      find.descendant(
        of: navigationRail,
        matching: _glyph(AppGlyphs.dashboard),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nested search'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a desktop page left open reopens in the mobile layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final results = <String?>[];
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => _PageOpener(onClosed: results.add),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(includeNavigatorKey: false, child: HomePage()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open page'));
    await tester.pumpAndSettle();
    expect(
      ModalRoute.of(tester.element(find.text('Sub page'))),
      isA<FadePageRoute<String>>(),
    );

    tester.view.physicalSize = const Size(500, 800);
    container.read(viewSizeProvider.notifier).value = const Size(500, 800);
    await tester.pumpAndSettle();

    expect(find.text('Sub page'), findsOneWidget);
    final reopened = tester.element(find.text('Sub page'));
    expect(ModalRoute.of(reopened), isA<CardPageRoute<String>>());
    expect(results, isEmpty);

    Navigator.of(reopened).pop('done');
    await tester.pumpAndSettle();

    expect(find.text('Sub page'), findsNothing);
    expect(results, ['done']);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop tabbing past page content does not scroll the PageView',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Widget pageContent(String label) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('page:$label'),
              const SizedBox(height: 16),
              TextButton(onPressed: () {}, child: const Text('button')),
            ],
          ),
        );
      }

      final container = ProviderContainer(
        overrides: [
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => pageContent('dashboard'),
                ),
                NavigationItem(
                  glyph: AppGlyphs.profiles,
                  label: PageLabel.profiles,
                  builder: (_) => pageContent('profiles'),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(includeNavigatorKey: false, child: HomePage()),
        ),
      );
      await tester.pump();
      expect(find.byType(NavigationSidebar), findsOneWidget);

      Finder railIcon(Glyph glyph) => find.descendant(
        of: find.byType(NavigationSidebar),
        matching: _glyph(glyph),
      );

      // Visit another page so its content stays alive in the PageView cache.
      await tester.tap(railIcon(AppGlyphs.profiles));
      await tester.pumpAndSettle();
      expect(container.read(currentPageLabelProvider), PageLabel.profiles);
      await tester.tap(railIcon(AppGlyphs.dashboard));
      await tester.pumpAndSettle();
      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

      bool focusInSidebar() {
        final context = FocusManager.instance.primaryFocus?.context;
        return context?.findAncestorWidgetOfExactType<NavigationSidebar>() !=
            null;
      }

      for (var i = 0; i < 40 && !focusInSidebar(); i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          container.read(currentPageLabelProvider),
          PageLabel.dashboard,
          reason: 'tab $i flipped the page',
        );
      }
      expect(focusInSidebar(), isTrue);
      expect(
        find.text('page:profiles').hitTestable(),
        findsNothing,
        reason: 'focus traversal scrolled the PageView to another page',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class _ThemeManagedTestApp extends StatelessWidget {
  const _ThemeManagedTestApp();

  @override
  Widget build(BuildContext context) {
    return PrismApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        AppUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (_, child) => ThemeManager(child: child!),
      home: const HomePage(),
    );
  }
}

class _StatefulContent extends StatefulWidget {
  const _StatefulContent();

  @override
  State<_StatefulContent> createState() => _StatefulContentState();
}

class _StatefulContentState extends State<_StatefulContent> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return TestRow(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const SizedBox(width: 80),
      title: TextButton(
        onPressed: () {
          setState(() {
            _count++;
          });
        },
        child: Text('count: $_count'),
      ),
    );
  }
}

class _NestedSearchLauncher extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _NestedSearchLauncher({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).push(
            HostPageRoute(
              builder: (_) => Scaffold(
                title: 'Nested search',
                searchState: AppBarSearchState(onSearch: onSearch),
                body: const SizedBox(),
              ),
            ),
          );
        },
        child: const Text('Open nested search'),
      ),
    );
  }
}

class _PageOpener extends StatelessWidget {
  final ValueChanged<String?> onClosed;

  const _PageOpener({required this.onClosed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () async {
          onClosed(
            await BaseNavigator.push<String>(
              context,
              const HostScaffold(body: Center(child: Text('Sub page'))),
            ),
          );
        },
        child: const Text('Open page'),
      ),
    );
  }
}

final _navigationItemsProvider =
    NotifierProvider<_NavigationItems, List<NavigationItem>>(
      _NavigationItems.new,
    );

class _NavigationItems extends Notifier<List<NavigationItem>> {
  @override
  List<NavigationItem> build() => const [];

  void set(List<NavigationItem> items) => state = items;
}

class _HomeTestProfiles extends Profiles {
  final List<Profile> initial;

  _HomeTestProfiles(this.initial);

  @override
  List<Profile> build() => initial;
}

class _InitRecorder extends StatefulWidget {
  const _InitRecorder({required this.label, required this.inits});

  final PageLabel label;
  final List<PageLabel> inits;

  @override
  State<_InitRecorder> createState() => _InitRecorderState();
}

class _InitRecorderState extends State<_InitRecorder> {
  @override
  void initState() {
    super.initState();
    widget.inits.add(widget.label);
  }

  @override
  Widget build(BuildContext context) => Text('page:${widget.label.name}');
}
