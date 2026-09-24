import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/proxy_groups.dart';
import 'package:fl_clash/views/dashboard/widgets/row_card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

Group _group(String name, List<String> proxies) => Group(
  type: GroupType.Selector,
  name: name,
  hidden: false,
  all: [for (final proxy in proxies) Proxy(name: proxy, type: 'ss')],
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.listen(groupsProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester, {double unitHeight = 80}) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                child: DashboardWidgetMetrics(
                  unitHeight: unitHeight,
                  child: const ProxyGroupsCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  List<Group> manyGroups() => [
    for (var index = 0; index < 8; index++) _group('G$index', ['N$index']),
  ];

  Finder groupLabel(int index) => find.text('G$index', findRichText: true);

  int shownRows(WidgetTester tester) {
    final bottom = tester.getRect(find.byType(ProxyGroupsCard)).bottom;
    return [
      for (var index = 0; index < 8; index++)
        if (tester.any(groupLabel(index)) &&
            tester.getRect(groupLabel(index)).bottom <= bottom)
          index,
    ].length;
  }

  testWidgets('shows an empty state without proxy groups', (tester) async {
    await pumpCard(tester);

    expect(find.byType(EmptyIllustration), findsOneWidget);
    expect(find.text('No Proxy group yet'), findsOneWidget);
  });

  testWidgets('fits more groups as the card grows taller', (tester) async {
    container.read(groupsProvider.notifier).value = manyGroups();

    await pumpCard(tester);
    final compact = shownRows(tester);
    await pumpCard(tester, unitHeight: 120);
    final tall = shownRows(tester);

    expect(compact, greaterThan(1));
    expect(compact, lessThan(8));
    expect(tall, greaterThan(compact));
  });

  testWidgets('row corners stay under a third of the row height', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = manyGroups();
    for (final unitHeight in [80.0, 120.0]) {
      await pumpCard(tester, unitHeight: unitHeight);
      final pill = find.byType(RowCardPill).first;
      final material = tester.widget<Material>(
        find.descendant(of: pill, matching: find.byType(Material)).first,
      );
      final shape = material.shape! as RoundedSuperellipseBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, greaterThan(0));
      expect(radius, lessThanOrEqualTo(tester.getSize(pill).height / 3));
    }
  });

  testWidgets('scrolls to the groups below the fold', (tester) async {
    container.read(groupsProvider.notifier).value = manyGroups();
    await pumpCard(tester);

    await tester.drag(groupLabel(0), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(shownRows(tester), greaterThan(0));
    expect(tester.any(groupLabel(0)), isFalse);
    expect(tester.any(groupLabel(7)), isTrue);
  });

  testWidgets('a tapped group swaps in its nodes and back again', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01']),
      _group('Media', ['JP-01', 'US-01']),
    ];
    await pumpCard(tester);

    expect(find.byType(CommonCard), findsNothing);

    await tester.tap(find.text('Media', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Auto', findRichText: true), findsNothing);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('JP-01', findRichText: true), findsOneWidget);
    expect(find.text('US-01', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Media'));
    await tester.pumpAndSettle();

    expect(find.text('Auto', findRichText: true), findsOneWidget);
    expect(find.text('JP-01', findRichText: true), findsNothing);
  });

  Future<Iterable<String?>> tooltipsFor(
    WidgetTester tester, {
    required String group,
    required String selected,
  }) async {
    container.read(groupsProvider.notifier).value = [
      _group(group, [selected]).copyWith(now: selected),
    ];
    await pumpCard(tester);
    return tester
        .widgetList<Tooltip>(find.byType(Tooltip))
        .map((tooltip) => tooltip.message);
  }

  testWidgets('short names show in full without a tooltip', (tester) async {
    expect(await tooltipsFor(tester, group: 'Auto', selected: 'HK'), isEmpty);
  });

  testWidgets('a long group name yields to the selected node', (tester) async {
    const group = 'Streaming-Services-Regional-Unlock-Fallback';
    expect(await tooltipsFor(tester, group: group, selected: 'VPS-HK-01'), [
      group,
    ]);
  });

  testWidgets('a long selected node keeps two characters of the group', (
    tester,
  ) async {
    const selected = 'VPS-HongKong-Premium-Dedicated-Line-01-Backup-Route';
    final tooltips = await tooltipsFor(
      tester,
      group: 'Proxy',
      selected: selected,
    );

    expect(tooltips, contains(selected));
    final groupName = find.text('Proxy', findRichText: true);
    expect(
      tester.getSize(groupName).width,
      greaterThanOrEqualTo(
        globalState.measure
            .computeTextSize(
              Text('Pr…', style: tester.widget<RichText>(groupName).text.style),
            )
            .width,
      ),
    );
  });
}
