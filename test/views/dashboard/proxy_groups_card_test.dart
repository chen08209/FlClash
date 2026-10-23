import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/proxy_groups.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _testUrl = 'https://test.example/generate_204';

Group _group(String name, List<String> proxies, {String? now}) => Group(
  type: GroupType.Selector,
  name: name,
  hidden: false,
  now: now,
  testUrl: _testUrl,
  all: [for (final proxy in proxies) Proxy(name: proxy, type: 'ss')],
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            const Profile(
              id: 1,
              label: 'P1',
              autoUpdateDuration: Duration.zero,
            ),
          ]),
        ),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    globalState.container = container;
    container.listen(groupsProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value = 1;
    container.listen(proxiesStyleSettingProvider, (_, _) {});
    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.tab));
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    DashboardDensity density = DashboardDensity.standard,
    Size size = const Size(1200, 1000),
    double? width,
    double height = 420,
    Widget card = const ProxyGroupsCard(),
  }) async {
    container.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final desktop = density.isDesktop;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width ?? (desktop ? 480 : 360),
                height: desktop ? height : null,
                child: DashboardDensityScope(
                  density: density,
                  scale: 1,
                  child: card,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder name(String text) => find.text(text, findRichText: true);

  Finder inSheet(Finder finder) =>
      find.descendant(of: find.byType(ProxiesView), matching: finder);

  testWidgets('without groups both cards say why', (tester) async {
    await pumpCard(tester);
    expect(find.text('No Proxy group yet'), findsOneWidget);

    await pumpCard(tester, density: DashboardDensity.mobile);
    expect(find.text('No Proxy group yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the desktop summary says why in the main group\'s place', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpCard(tester, height: 120, card: const ProxyGroupsSummaryCard());

    expect(find.text('Core is not running'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the desktop summary counts the groups instead of showing the '
      'main one', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01', 'SG-01'], now: 'HK-01'),
      _group('Media', ['JP-01'], now: 'JP-01'),
    ];
    await pumpCard(
      tester,
      density: DashboardDensity.compact,
      height: 112,
      card: const ProxyGroupsSummaryCard(),
    );

    expect(find.text('2 groups', findRichText: true), findsOneWidget);
    expect(name('HK-01'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Proxy group'));
    await tester.pumpAndSettle();
    expect(inSheet(name('SG-01')), findsOneWidget);
  });

  testWidgets('the phone card counts the groups as the desktop summary does', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01'], now: 'HK-01'),
      _group('Media', ['JP-01'], now: 'JP-01'),
    ];
    await pumpCard(
      tester,
      density: DashboardDensity.mobile,
      card: const ProxyGroupsSummaryCard(),
    );

    expect(find.text('2 groups', findRichText: true), findsOneWidget);
    expect(name('Auto'), findsNothing);
    expect(name('HK-01'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ProxyGroupsSummaryCard));
    await tester.pumpAndSettle();
    expect(inSheet(name('HK-01')), findsOneWidget);
  });

  testWidgets('a stopped Core is named instead of an empty list', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpCard(tester);

    expect(find.text('Core is not running'), findsOneWidget);
  });

  testWidgets('the desktop card counts the groups in a chip by its title and '
      'lists each as a tile', (tester) async {
    container.read(groupsProvider.notifier).value = [
      for (var index = 0; index < 6; index++)
        _group('G$index', ['N$index'], now: 'N$index'),
    ];
    await pumpCard(tester);

    final count = find.descendant(
      of: find.byTooltip('6 groups'),
      matching: find.widgetWithText(DashboardChip, '6'),
    );
    expect(count, findsOneWidget);
    final title = tester.getRect(find.text('Proxy group'));
    expect(tester.getCenter(count).dy, moreOrLessEquals(title.center.dy));
    expect(tester.getRect(count).left, moreOrLessEquals(title.right + 8));
    for (var index = 0; index < 6; index++) {
      expect(name('G$index'), findsWidgets);
      expect(name('N$index'), findsOneWidget);
    }
    expect(find.text('+2'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('both cards draw icons whatever style the proxies page uses', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [
      _group('G0', ['N0'], now: 'N0'),
      _group('G1', ['N1'], now: 'N1'),
    ];
    final inTiles = find.descendant(
      of: find.byType(DashboardBlock),
      matching: find.byType(GroupMonogram),
    );

    for (final style in ProxiesIconStyle.values) {
      container.read(proxiesStyleSettingProvider.notifier).value = container
          .read(proxiesStyleSettingProvider)
          .copyWith(iconStyle: style);

      await pumpCard(tester, height: 200);
      expect(inTiles, findsNWidgets(2), reason: style.name);

      await pumpCard(tester, density: DashboardDensity.mobile);
      expect(find.byType(GroupMonogram), findsNWidgets(2), reason: style.name);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow card lists its tiles in one column', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('G0', ['N0'], now: 'N0'),
      _group('G1', ['N1'], now: 'N1'),
    ];
    await pumpCard(tester);
    expect(tester.getTopLeft(name('N1')).dy, tester.getTopLeft(name('N0')).dy);

    await pumpCard(tester, width: 340);
    expect(tester.getTopLeft(name('N1')).dx, tester.getTopLeft(name('N0')).dx);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a timed out selection is counted in the header', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01'], now: 'HK-01'),
      _group('Media', ['JP-01'], now: 'JP-01'),
    ];
    container.read(delayDataSourceProvider.notifier).value = {
      _testUrl: {'HK-01': 48, 'JP-01': -1},
    };
    await pumpCard(tester);

    expect(find.text('48 ms'), findsOneWidget);
    expect(find.text('1 timed out'), findsOneWidget);
  });

  testWidgets('a tile opens the sheet on its group', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01']),
      _group('Media', ['JP-01', 'US-01'], now: 'JP-01'),
    ];
    await pumpCard(tester);

    await tester.tap(name('Media').first);
    await tester.pumpAndSettle();

    expect(inSheet(name('JP-01')), findsOneWidget);
    expect(inSheet(name('US-01')), findsOneWidget);
    expect(inSheet(name('HK-01')), findsNothing);
    expect(container.read(currentProfileProvider)!.currentGroupName, 'Media');
  });

  testWidgets('the sheet switches groups and picks a proxy', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01', 'SG-01'], now: 'HK-01'),
      _group('Media', ['JP-01', 'US-01'], now: 'JP-01'),
    ];
    await pumpCard(tester, density: DashboardDensity.mobile);

    await tester.tap(find.byType(ProxyGroupsSummaryCard));
    await tester.pumpAndSettle();
    expect(inSheet(name('HK-01')), findsOneWidget);

    await tester.tap(inSheet(name('Media')).first);
    await tester.pumpAndSettle();
    expect(inSheet(name('HK-01')), findsNothing);

    await tester.tap(inSheet(name('US-01')));
    await tester.pump();

    expect(container.read(currentProfileProvider)!.selectedMap, {
      'Media': 'US-01',
    });
    debouncer.cancel((FunctionTag.changeProxy, 'Media'));
  });

  testWidgets('the sheet searches apart from the proxies page', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01', 'SG-01']),
    ];
    final query = queryProvider(QueryTag.proxies);
    container.listen(query, (_, _) {});
    container.read(query.notifier).value = 'HK';
    await pumpCard(tester);

    await tester.tap(name('Auto').first);
    await tester.pumpAndSettle();
    expect(inSheet(name('SG-01')), findsOneWidget);

    container.read(query.notifier).value = 'SG';
    Navigator.of(tester.element(find.byType(ProxiesView))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(ProxiesView), findsNothing);
    expect(container.read(query), 'HK');
  });

  for (final (type, desktop, searching, mobile) in [
    (ProxiesType.list, ['Close', 'Search'], ['Cancel'], ['Close']),
    (
      ProxiesType.tab,
      ['Search', 'Delay test', 'Close'],
      ['Delay test', 'Cancel'],
      ['Close', 'Delay test'],
    ),
  ]) {
    testWidgets('the sheet bar of the ${type.name} layout keeps search and '
        'the delay test beside close', (tester) async {
      container
          .read(proxiesStyleSettingProvider.notifier)
          .update((state) => state.copyWith(type: type));
      container.read(groupsProvider.notifier).value = [
        _group('Auto', ['HK-01', 'SG-01']),
      ];
      Iterable<String?> barButtons() => tester
          .widgetList<AppBarActionButton>(
            inSheet(find.byType(AppBarActionButton).hitTestable()),
          )
          .map((button) => button.data.tooltip);

      await pumpCard(tester);
      await tester.tap(name('Auto').first);
      await tester.pumpAndSettle();
      expect(barButtons(), unorderedEquals(desktop));
      await tester.tap(inSheet(find.byTooltip('Search')));
      await tester.pumpAndSettle();
      expect(barButtons(), unorderedEquals(searching));
      await tester.tap(inSheet(find.byTooltip('Cancel')));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(ProxiesView))).pop();
      await tester.pumpAndSettle();
      await pumpCard(
        tester,
        density: DashboardDensity.mobile,
        size: const Size(400, 860),
      );
      await tester.tap(find.byType(ProxyGroupsSummaryCard));
      await tester.pumpAndSettle();
      expect(barButtons(), mobile);
      expect(inSheet(find.byType(SearchField)), findsOneWidget);
    });
  }

  testWidgets('the list in a bottom sheet starts below the sheet bar', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [
      _group('Auto', ['HK-01']),
      _group('Media', ['JP-01']),
    ];
    container.listen(proxiesStyleSettingProvider, (_, _) {});
    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.list));
    await pumpCard(
      tester,
      density: DashboardDensity.mobile,
      size: const Size(400, 860),
    );
    await tester.tap(find.byType(ProxyGroupsSummaryCard));
    await tester.pumpAndSettle();

    final barBottom = tester.getRect(inSheet(find.byType(AppBar))).bottom;
    expect(
      tester.getRect(inSheet(name('Auto'))).top,
      greaterThanOrEqualTo(barBottom),
    );
  });

  testWidgets('long names never overflow a tile', (tester) async {
    container.read(groupsProvider.notifier).value = [
      _group('Streaming-Services-Regional-Unlock-Fallback', [
        'VPS-HongKong-Premium-Dedicated-Line-01-Backup-Route',
      ], now: 'VPS-HongKong-Premium-Dedicated-Line-01-Backup-Route'),
    ];
    await pumpCard(tester);
    expect(tester.takeException(), isNull);

    await pumpCard(tester, density: DashboardDensity.mobile);
    expect(tester.takeException(), isNull);
  });
}
