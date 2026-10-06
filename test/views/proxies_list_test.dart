import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<void> _pumpProxiesList(
  WidgetTester tester, {
  required Size size,
  Widget Function(Widget child)? homeBuilder,
  String selected = 'Proxy 1',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final profile = Profile.normal().copyWith(
    currentGroupName: 'Selector',
    selectedMap: {'Selector': selected},
    unfoldSet: {'Selector'},
  );
  final group = Group(
    name: 'Selector',
    type: GroupType.Selector,
    hidden: false,
    now: selected,
    all: List.generate(
      160,
      (index) => Proxy(name: 'Proxy $index', type: 'Direct'),
    ),
  );
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      currentGroupsStateProvider.overrideWithValue(GroupsState(value: [group])),
      groupsProvider.overrideWithValue([group]),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        homeBuilder: homeBuilder ?? (child) => child,
        child: const ProxiesView(),
      ),
    ),
  );
  container
      .read(proxiesStyleSettingProvider.notifier)
      .update((state) => state.copyWith(type: ProxiesType.list));
  await tester.pump();
}

void main() {
  testWidgets('the list scrolls its rows under the bar, pinning the header '
      'at its foot', (tester) async {
    await _pumpProxiesList(tester, size: const Size(1400, 1000));

    final barBottom = tester.getRect(find.byType(AppBar)).bottom;
    expect(tester.getRect(find.byType(ListHeader)).top, barBottom + 8);

    await tester.drag(find.byType(ProxyCard).first, const Offset(0, -300));
    await tester.pump();

    expect(tester.getRect(find.byType(ListHeader)).top, barBottom + 8);
    expect(
      find
          .byType(ProxyCard)
          .evaluate()
          .map((element) => tester.getRect(find.byWidget(element.widget))),
      contains(
        predicate<Rect>(
          (rect) => rect.top < barBottom && rect.bottom > 0,
          'a card under the bar',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  group('under a Miuix large title', () {
    Future<void> pumpMiuix(
      WidgetTester tester, {
      String selected = 'Proxy 1',
    }) async {
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.resetPadding);
      await _pumpProxiesList(
        tester,
        size: const Size(412, 800),
        selected: selected,
        homeBuilder: (child) => Theme(
          data: ThemeData(colorScheme: miuixColorScheme(Brightness.light))
              .withAppShapes
              .withInterfaceStyle(
                const InterfaceStyleTheme(style: InterfaceStyle.miuix),
              ),
          child: child,
        ),
      );
    }

    double barBottom(WidgetTester tester) => tester
        .getRect(
          find.descendant(
            of: find.byType(LargeTitleHeader),
            matching: find.byType(AbsorbPointer),
          ),
        )
        .bottom;

    double headerTop(WidgetTester tester) =>
        tester.getRect(find.byType(ListHeader)).top;

    testWidgets('the pinned header follows the collapsing title', (
      tester,
    ) async {
      await pumpMiuix(tester);
      final position = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(ProxiesListView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;

      expect(barBottom(tester), 24 + 96);
      expect(headerTop(tester), barBottom(tester) + 8);

      for (final pixels in [20.0, 600.0]) {
        position.jumpTo(pixels);
        await tester.pump();
        expect(barBottom(tester), 24 + 96 - (pixels > 40 ? 40 : pixels));
        expect(headerTop(tester), barBottom(tester) + 8, reason: '$pixels');
      }

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(LargeTitleHeader), findsNothing);
      expect(position.pixels, 600);
      expect(headerTop(tester), tester.getRect(find.byType(AppBar)).bottom + 8);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scroll to selected lands the row under the pinned header', (
      tester,
    ) async {
      await pumpMiuix(tester, selected: 'Proxy 101');

      await tester.tap(find.byTooltip('Scroll to selected'));
      await tester.pumpAndSettle();

      expect(barBottom(tester), 24 + 56);
      expect(headerTop(tester), barBottom(tester) + 8);
      final card = tester.getRect(
        find.byKey(const ValueKey('Selector.Proxy 101')).first,
      );
      expect(card.top, tester.getRect(find.byType(ListHeader)).bottom + 8);
    });
  });
}
