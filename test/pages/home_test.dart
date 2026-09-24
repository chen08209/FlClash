import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

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
                  builder: (_) => const _StatefulContent(
                    key: GlobalObjectKey(PageLabel.dashboard),
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
      expect(sidebarContainer.color, colorScheme.surfaceContainer);

      final sidebarEdge = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppSidebarContainer),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Material && widget.shape is BorderDirectional,
              ),
            )
            .first,
      );
      expect(
        (sidebarEdge.shape! as BorderDirectional).end.color,
        colorScheme.outlineVariant,
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
                  builder: (_) => const ToolsView(
                    key: GlobalObjectKey(PageLabel.dashboard),
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
                  label: PageLabel.connections,
                  modes: const [
                    NavigationItemMode.desktop,
                    NavigationItemMode.more,
                  ],
                  builder: (_) => const SizedBox.shrink(),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) =>
                      const ToolsView(key: GlobalObjectKey(PageLabel.tools)),
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
                      icon: const Icon(Icons.more_horiz),
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
                      icon: const Icon(Icons.more_vert),
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
                  icon: const Icon(Icons.more_horiz),
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
                builder: (_) => CommonScaffold(
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
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
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

    expect(
      find.byType(CircularProgressIndicator, skipOffstage: false),
      findsOneWidget,
    );
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
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (_, child) => ThemeManager(child: child!),
      home: const HomePage(),
    );
  }
}

class _StatefulContent extends StatefulWidget {
  const _StatefulContent({super.key});

  @override
  State<_StatefulContent> createState() => _StatefulContentState();
}

class _StatefulContentState extends State<_StatefulContent> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
            MaterialPageRoute(
              builder: (_) => CommonScaffold(
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
