import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  test('the window picks the density', () {
    DashboardDensity of(double width, double height) =>
        DashboardDensity.of(Size(width, height));

    expect(of(1220, 900), DashboardDensity.standard);
    expect(of(1220, 824), DashboardDensity.standard);
    expect(of(1220, 823), DashboardDensity.compact);
    expect(of(1220, 500), DashboardDensity.compact);
    expect(of(1039, 900), DashboardDensity.compact);
    expect(of(860, 900), DashboardDensity.compact);
    expect(of(859, 900), DashboardDensity.standard);
    expect(of(640, 900), DashboardDensity.standard);
    expect(of(640, 823), DashboardDensity.compact);
    expect(of(639, 900), DashboardDensity.mobile);
    expect(dashboardColumnsOf(860), 4);
    expect(dashboardColumnsOf(859), 2);
  });

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.listen(groupsProvider, (_, _) {});
  });

  void seedGroups(int count) {
    container.read(groupsProvider.notifier).value = [
      for (var index = 0; index < count; index++)
        Group(
          type: GroupType.Selector,
          name: 'G$index',
          hidden: false,
          all: [Proxy(name: 'N$index', type: 'ss')],
        ),
    ];
  }

  tearDown(() => container.dispose());

  Future<void> pumpDashboard(
    WidgetTester tester,
    Size size, {
    SupportPlatform platform = SupportPlatform.MacOS,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: DashboardView(platform: platform)),
      ),
    );
    await tester.pump();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  Rect rectOf(WidgetTester tester, Type type) =>
      tester.getRect(find.byType(type).first);

  double scrollExtentOf(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .maxScrollExtent;

  testWidgets('the desktop fills the window with four rows, the controls '
      'under the exit', (tester) async {
    await pumpDashboard(tester, const Size(1220, 824));

    final current = rectOf(tester, CurrentOutboundCard);
    final upload = rectOf(tester, SpeedCard);
    final mode = rectOf(tester, OutboundModeBar);
    final systemProxy = tester.getRect(find.byType(NetworkTakeoverTile).first);
    final tun = tester.getRect(find.byType(NetworkTakeoverTile).last);
    final intranet = rectOf(tester, IntranetIpCard);
    final profile = rectOf(tester, ProfilesCard);
    final service = rectOf(tester, ServiceStatusCard);
    final table = rectOf(tester, ConnectionsTableCard);
    final groups = rectOf(tester, ProxyGroupsCard);

    expect(current.height, 208);
    expect(current.width, closeTo(upload.width * 2 + 16, 0.01));
    expect(mode.top, current.bottom + 16);
    expect(mode.height, 64);
    expect(mode.width, closeTo(current.width, 0.01));
    expect(systemProxy.left, closeTo(upload.left, 0.01));
    expect(tun.right, closeTo(upload.right + 16 + upload.width, 0.01));
    expect(intranet.top, mode.bottom + 16);
    expect(intranet.height, 176);
    expect(profile.top, intranet.top);
    expect(profile.left, closeTo(intranet.right + 16, 0.01));
    expect(service.width, closeTo(current.width, 0.01));
    expect(find.byType(MemoryInfo), findsNothing);
    expect(table.top, intranet.bottom + 16);
    expect(table.width / groups.width, closeTo(1.5, 0.01));
    expect(groups.top, table.top);
    expect(table.bottom, 824 - 24);
    expect(scrollExtentOf(tester), 0);
    expect(find.byType(OutboundModeCard), findsNothing);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('the table lines its text up with the column and its head with '
      'the group tiles', (tester) async {
    seedGroups(10);
    for (final size in const [Size(1220, 824), Size(1000, 900)]) {
      await pumpDashboard(tester, size);

      final head = tester.getRect(
        find
            .ancestor(
              of: find.text('Source'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final tile = tester.getRect(
        find
            .descendant(
              of: find.byType(ProxyGroupsCard),
              matching: find.byType(DashboardBlock),
            )
            .first,
      );
      expect(tile.top, closeTo(head.top, 0.01));
      expect(
        tester.getTopLeft(find.text('Source')).dx,
        closeTo(tester.getTopLeft(find.byGlyph(AppGlyphs.status)).dx, 0.01),
      );

      await teardown(tester);
    }
  });

  testWidgets('a wide window gives the memory card a column beside the '
      'services', (tester) async {
    await pumpDashboard(tester, const Size(1440, 900));

    final upload = rectOf(tester, SpeedCard);
    final service = rectOf(tester, ServiceStatusCard);
    final memory = rectOf(tester, MemoryInfo);
    expect(service.width, closeTo(upload.width, 0.01));
    expect(memory.top, service.top);
    expect(memory.left, closeTo(service.right + 16, 0.01));
    expect(
      memory.right,
      closeTo(rectOf(tester, SpeedCard).right + 16 + upload.width, 0.01),
    );
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('the default window opens on four full columns beside the '
      'expanded sidebar and a title bar', (tester) async {
    const sidebar = 220.0;
    const titleBar = 32.0;
    await pumpDashboard(
      tester,
      Size(
        defaultWindowSize.width - sidebar,
        defaultWindowSize.height - titleBar,
      ),
    );

    expect(rectOf(tester, CurrentOutboundCard).height, 208);
    expect(find.byType(ConnectionsTableCard), findsOneWidget);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('a short window keeps the layout with compact rows', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(1220, 720));

    expect(rectOf(tester, CurrentOutboundCard).height, 176);
    expect(rectOf(tester, OutboundModeBar).height, 56);
    expect(rectOf(tester, IntranetIpCard).height, 152);
    expect(scrollExtentOf(tester), 0);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('a window too short for the tables gives their height to the '
      'summaries, with no list left to scroll inside the page', (tester) async {
    seedGroups(12);
    await pumpDashboard(tester, const Size(1000, 660));

    final current = rectOf(tester, CurrentOutboundCard);
    final stats = rectOf(tester, ConnectionStatsCard);
    final groups = rectOf(tester, ProxyGroupsSummaryCard);
    expect(find.byType(ConnectionsTableCard), findsNothing);
    expect(find.byType(ProxyGroupsCard), findsNothing);
    expect(stats.height, greaterThan(112));
    expect(stats.bottom, 660 - 24);
    expect(stats.width, closeTo(current.width, 0.01));
    expect(groups.top, stats.top);
    expect(find.text('12 groups', findRichText: true), findsOneWidget);
    expect(scrollExtentOf(tester), 0);
    expect(find.byType(Scrollable), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpDashboard(tester, const Size(1220, 700));
    expect(find.byType(ConnectionsTableCard), findsNothing);
    expect(find.byType(ConnectionStatsCard), findsOneWidget);

    await pumpDashboard(tester, const Size(1000, 560));
    expect(rectOf(tester, ConnectionStatsCard).height, 112);
    expect(scrollExtentOf(tester), greaterThan(0));
    expect(find.byType(Scrollable), findsOneWidget);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('the tables take the bottom row once it holds a few '
      'connections', (tester) async {
    await pumpDashboard(tester, const Size(924, 737));

    final table = rectOf(tester, ConnectionsTableCard);
    expect(table.height, lessThan(240));
    expect(
      table.height,
      greaterThanOrEqualTo(
        connectionsTableMinHeight(DashboardDensity.compact, 1),
      ),
    );
    expect(find.byType(ConnectionStatsCard), findsNothing);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('a wide window centres columns that stop growing', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(2560, 1440));

    final current = rectOf(tester, CurrentOutboundCard);
    final memory = rectOf(tester, MemoryInfo);
    expect(rectOf(tester, SpeedCard).width, 440);
    expect(current.left - 16, closeTo(2560 - 24 - memory.right, 0.01));
    expect(rectOf(tester, ConnectionsTableCard).bottom, 1440 - 24);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('a resize lays the cards out for the new width in its first '
      'frame, before the view size catches up', (tester) async {
    await pumpDashboard(tester, const Size(1440, 900));

    tester.view.physicalSize = const Size(600, 800);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(OutboundModeCard), findsOneWidget);
    expect(find.byType(OutboundModeBar), findsNothing);

    tester.view.physicalSize = const Size(800, 900);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(rectOf(tester, OutboundModeBar).width, 800 - 16 - 24);

    tester.view.physicalSize = const Size(1440, 900);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(ConnectionsTableCard), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('larger text grows the box of every line', (tester) async {
    container.listen(localIpProvider, (_, _) {});
    container.read(localIpProvider.notifier).value = '192.168.100.200';
    List<String> clipped() => [
      for (final paragraph in tester.renderObjectList<RenderParagraph>(
        find.byType(RichText),
      ))
        if (paragraph.getMaxIntrinsicHeight(paragraph.size.width) >
            paragraph.size.height + 0.5)
          paragraph.text.toPlainText(),
    ];
    for (final (size, platform) in const [
      (Size(1440, 900), SupportPlatform.MacOS),
      (Size(1000, 1000), SupportPlatform.MacOS),
      (Size(412, 915), SupportPlatform.Android),
    ]) {
      for (final textScale in const [1.2, 1.4]) {
        await pumpDashboard(
          tester,
          size,
          platform: platform,
          textScale: textScale,
        );
        expect(clipped(), isEmpty, reason: '$size x$textScale');
        expect(tester.takeException(), isNull);
      }
    }

    await teardown(tester);
  });

  testWidgets('a mid-width window stacks the same cards in two columns', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(800, 900));
    final gap = cardSpacingOf(
      tester.element(find.byType(CurrentOutboundCard)),
      ViewMode.laptop,
    );

    final current = rectOf(tester, CurrentOutboundCard);
    final upload = rectOf(tester, SpeedCard);
    final mode = rectOf(tester, OutboundModeBar);
    final tun = tester.getRect(find.byType(NetworkTakeoverTile).last);
    final intranet = rectOf(tester, IntranetIpCard);
    final profile = rectOf(tester, ProfilesCard);

    expect(current.width, 800 - 16 - 24);
    expect(current.width, closeTo(upload.width * 2 + gap, 0.01));
    expect(mode.width, current.width);
    expect(tun.width, closeTo(upload.width, 0.01));
    expect(intranet.top, tun.bottom + gap);
    expect(profile.top, intranet.top);
    expect(profile.left, closeTo(intranet.right + gap, 0.01));
    final service = rectOf(tester, ServiceStatusCard);
    expect(service.width, closeTo(upload.width, 0.01));
    expect(rectOf(tester, MemoryInfo).top, service.top);
    expect(find.byType(OutboundModeCard), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byType(ProxyGroupsSummaryCard),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final stats = rectOf(tester, ConnectionStatsCard);
    final groups = rectOf(tester, ProxyGroupsSummaryCard);
    expect(stats.width, closeTo(upload.width, 0.01));
    expect(groups.top, stats.top);
    expect(groups.left, closeTo(stats.right + gap, 0.01));
    expect(find.byType(ConnectionsTableCard), findsNothing);
    expect(find.byType(Scrollable), findsOneWidget);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('larger text grows the rows and narrows the grid', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(1400, 1000), textScale: 1.2);
    expect(
      rectOf(tester, CurrentOutboundCard).height,
      closeTo(208 * 1.2, 0.01),
    );
    expect(tester.takeException(), isNull);

    await pumpDashboard(tester, const Size(1000, 1000), textScale: 1.2);
    final current = rectOf(tester, CurrentOutboundCard);
    expect(current.width, 1000 - 16 - 24);
    expect(current.height, closeTo(208 * 1.2, 0.01));
    expect(tester.takeException(), isNull);

    await pumpDashboard(tester, const Size(760, 1000), textScale: 1.2);
    expect(find.byType(ConnectionsTableCard), findsNothing);
    expect(find.byType(OutboundModeBar), findsNothing);
    expect(rectOf(tester, CurrentOutboundCard).width, 560);

    await teardown(tester);
  });

  testWidgets('a narrow desktop window shows the phone cards in a centred '
      'column, takeover in place of the VPN', (tester) async {
    await pumpDashboard(tester, const Size(620, 700));

    final card = rectOf(tester, CurrentOutboundCard);
    expect(card.width, 560);
    expect(card.center.dx, closeTo(310, 0.01));
    expect(find.byType(NetworkTakeoverCard), findsOneWidget);
    expect(find.byType(VpnCard), findsNothing);
    expect(find.byType(OutboundModeCard), findsOneWidget);
    expect(find.byType(OutboundModeBar), findsNothing);

    await teardown(tester);
  });

  testWidgets('a phone shows the saved cards edge to edge', (tester) async {
    await pumpDashboard(
      tester,
      const Size(400, 900),
      platform: SupportPlatform.Android,
    );

    final card = rectOf(tester, CurrentOutboundCard);
    expect(card.left, 16);
    expect(card.right, 400 - 16);
    expect(find.byType(VpnCard), findsOneWidget);
    expect(find.byType(NetworkTakeoverCard), findsNothing);

    await teardown(tester);
  });

  testWidgets('a tablet or a landscape phone gets the same grid, the VPN '
      'switch in place of the takeover', (tester) async {
    for (final size in const [Size(1280, 800), Size(915, 412)]) {
      await pumpDashboard(tester, size, platform: SupportPlatform.Android);

      final mode = rectOf(tester, OutboundModeBar);
      final vpn = rectOf(tester, VpnTile);
      expect(vpn.width, closeTo(mode.width, 0.01));
      expect(vpn.height, mode.height);
      expect(find.byType(NetworkTakeoverTile), findsNothing);
      expect(find.byType(CurrentOutboundCard), findsOneWidget);
      expect(find.byType(NetworkSpeedCard), findsNothing);
      expect(tester.takeException(), isNull);
    }

    await teardown(tester);
  });
}
