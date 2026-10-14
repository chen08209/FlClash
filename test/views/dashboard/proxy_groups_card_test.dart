import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/proxy_groups.dart';
import 'package:fl_clash/views/dashboard/widgets/row_card.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
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

  Future<void> pumpCard(
    WidgetTester tester, {
    double unitHeight = 80,
    Size size = const Size(1200, 1000),
  }) async {
    container.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
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

  const wheelRest = Duration(milliseconds: 250);

  Future<void> expectWheelRestsOnRow(WidgetTester tester) async {
    final list = find.byType(ListView);
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(list),
        scrollDelta: const Offset(0, 10),
      ),
    );
    await tester.pump(wheelRest);
    await tester.pumpAndSettle();
    final listView = tester.widget<ListView>(list);
    expect(listView.controller!.offset, listView.itemExtent);
  }

  Future<void> resizeRows(WidgetTester tester) async {
    final before = tester.widget<ListView>(find.byType(ListView)).itemExtent;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();
    final after = tester.widget<ListView>(find.byType(ListView)).itemExtent;
    expect(after, isNot(before));
  }

  testWidgets('groups settle on rows of a new height', (tester) async {
    container.read(groupsProvider.notifier).value = [
      for (var index = 0; index < 20; index++) _group('G$index', ['N$index']),
    ];
    await pumpCard(tester);
    await resizeRows(tester);

    await expectWheelRestsOnRow(tester);
  });

  testWidgets('a tapped group opens its nodes in a sheet and the card keeps '
      'its groups', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01']),
      _group('Media', ['JP-01', 'US-01']),
    ];
    await pumpCard(tester);

    await tester.tap(find.text('Media', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.byType(ProxyCard), findsNWidgets(2));
    expect(find.text('JP-01', findRichText: true), findsOneWidget);
    expect(find.text('US-01', findRichText: true), findsOneWidget);
    expect(find.text('Auto', findRichText: true), findsOneWidget);
  });

  testWidgets('a group with few nodes opens a sheet only as tall as them', (
    tester,
  ) async {
    const size = Size(400, 800);
    container.read(groupsProvider.notifier).value = [
      _group('Media', ['JP-01', 'US-01']),
    ];
    await pumpCard(tester, size: size);

    await tester.tap(find.text('Media', findRichText: true));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      greaterThan(size.height * (1 - snapSheetDetents.first)),
    );
    expect(
      tester.getBottomLeft(find.byType(ProxyCard).last).dy,
      lessThan(size.height),
    );
  });

  testWidgets('a mouse over a long group opening at its selected node '
      'raises nothing', (tester) async {
    const size = Size(400, 800);
    container.read(groupsProvider.notifier).value = [
      _group('Media', [
        for (var index = 0; index < 60; index++) 'N$index',
      ]).copyWith(now: 'N50'),
    ];
    await pumpCard(tester, size: size);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset(size.width / 2, size.height - 40));

    await tester.tap(find.text('Media', findRichText: true));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(ProxyCard),
        matching: find.text('N50', findRichText: true),
      ),
      findsOneWidget,
    );
    await mouse.removePointer();
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

  testWidgets('a long group name leaves the selected node whole', (
    tester,
  ) async {
    const group = 'Streaming-Services-Regional-Unlock-Fallback';
    expect(await tooltipsFor(tester, group: group, selected: 'VPS-HK-01'), [
      group,
    ]);
  });

  testWidgets('a long selected node leaves the group name whole', (
    tester,
  ) async {
    const selected = 'VPS-HongKong-Premium-Dedicated-Line-01-Backup-Route';
    expect(await tooltipsFor(tester, group: 'Proxy', selected: selected), [
      selected,
    ]);
  });
}
