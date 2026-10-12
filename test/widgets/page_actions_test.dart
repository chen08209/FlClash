import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/start_button.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _size = Size(400, 800);

Future<ProviderContainer> _pumpHome(
  WidgetTester tester, {
  required bool floatingBar,
  required Brightness brightness,
}) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 34, right: 24);
  tester.view.viewPadding = const FakeViewPadding(
    top: 24,
    bottom: 34,
    right: 24,
  );
  addTearDown(tester.view.reset);
  navigationPort = navigation;
  addTearDown(() => navigationPort = null);
  const profile = Profile(
    id: 1,
    label: 'Test profile',
    autoUpdateDuration: Duration.zero,
    currentGroupName: 'Selector',
    selectedMap: {'Selector': 'DIRECT'},
  );
  const group = Group(
    name: 'Selector',
    type: GroupType.Selector,
    hidden: false,
    now: 'DIRECT',
    all: [Proxy(name: 'DIRECT', type: 'Direct')],
  );
  final container = ProviderContainer(
    overrides: [
      appSettingProvider.overrideWithBuild(
        (_, _) => AppSettingProps(
          floatingNavigationBar: floatingBar,
          dashboardWidgets: const [],
        ),
      ),
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      currentGroupsStateProvider.overrideWithValue(
        const GroupsState(value: [group]),
      ),
      groupsProvider.overrideWithValue([group]),
      suspendProvider.overrideWithValue(false),
      navigationItemsStateProvider.overrideWithValue(
        NavigationItemsState(
          value: [
            NavigationItem(
              glyph: AppGlyphs.dashboard,
              label: PageLabel.dashboard,
              builder: (_) => const DashboardView(),
            ),
            NavigationItem(
              glyph: AppGlyphs.proxies,
              label: PageLabel.proxies,
              builder: (_) => const ProxiesView(),
            ),
            NavigationItem(
              glyph: AppGlyphs.profiles,
              label: PageLabel.profiles,
              builder: (_) => const ProfilesView(),
            ),
          ],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = _size;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        includeNavigatorKey: false,
        child: Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff6750a4),
              brightness: brightness,
            ),
          ).withAppShapes,
          child: const HomePage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final brightness in Brightness.values) {
    for (final floatingBar in [true, false]) {
      testWidgets(
        'three page actions move independently with $brightness, floating bar=$floatingBar',
        (tester) async {
          final container = await _pumpHome(
            tester,
            brightness: brightness,
            floatingBar: floatingBar,
          );
          final navigation = find.byType(
            floatingBar ? FloatingNavigationBar : NavigationBar,
          );
          for (final floating in [false, true, false]) {
            container
                .read(appSettingProvider.notifier)
                .update(
                  (state) => state.copyWith(floatingPageActions: floating),
                );
            await tester.pumpAndSettle();
            for (final (label, type) in [
              (PageLabel.dashboard, DashboardView),
              (PageLabel.proxies, ProxiesView),
              (PageLabel.profiles, ProfilesView),
            ]) {
              final destination = find.descendant(
                of: navigation,
                matching: find.text(label.label),
              );
              await tester.tap(destination);
              await tester.pumpAndSettle();
              expect(container.read(currentPageLabelProvider), label);
              final page = find.byType(type);
              final fab = find.descendant(
                of: page,
                matching: find.byType(FloatingActionButton),
              );
              expect(navigation, findsOneWidget);
              expect(
                container.read(appSettingProvider).floatingNavigationBar,
                floatingBar,
              );
              if (floating) {
                expect(fab, findsOneWidget);
                final rect = tester.getRect(fab);
                expect(rect.right, lessThanOrEqualTo(_size.width - 24));
                expect(rect.bottom, lessThan(tester.getTopLeft(navigation).dy));
                expect(rect.top, greaterThan(_size.height / 2));
              } else {
                expect(fab, findsNothing);
                final bar = find.descendant(
                  of: page,
                  matching: find.byType(AppBar),
                );
                final buttons = tester.widgetList<IconButton>(
                  find.descendant(of: bar, matching: find.byType(IconButton)),
                );
                expect(buttons.last.tooltip, switch (label) {
                  PageLabel.dashboard => 'Start',
                  PageLabel.proxies => 'Delay test',
                  _ => 'Add profile',
                });
                final last = find
                    .descendant(of: bar, matching: find.byType(IconButton))
                    .last;
                expect(
                  tester.getRect(last).right,
                  lessThanOrEqualTo(_size.width - 24),
                );
                expect(tester.getRect(last).top, greaterThanOrEqualTo(24));
              }
              if (label == PageLabel.dashboard && floatingBar) {
                expect(
                  find.descendant(
                    of: find.byType(NavigationDock),
                    matching: find.byType(StartButton),
                  ),
                  findsOneWidget,
                );
              }
              expect(tester.takeException(), isNull);
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
