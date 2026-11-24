import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/connection/connection.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/dashboard/widgets/connection_stats.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/route_cover.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';
import '../../helpers/host_scaffold.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

const _mobileSize = Size(400, 800);

TrackerInfo _request(int index) {
  return TrackerInfo(
    id: '$index',
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: 'host-$index.test',
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: 'curl',
    ),
    chains: const ['Proxy'],
    rule: 'DOMAIN',
    rulePayload: 'host-$index.test',
  );
}

Finder _stat(String label) => find.descendant(
  of: find.byType(ConnectionStatsCard),
  matching: find.text(label),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCore core;
  late ProviderContainer container;

  setUp(() {
    core = _MockCore();
    when(() => core.getConnectionCount()).thenAnswer((_) async => 0);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    Size size = _mobileSize,
    Locale? locale,
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
          locale: locale,
          child: HostScaffold(
            body: ListView(children: const [ConnectionStatsCard()]),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownCard(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('counts what the Core is holding open', (tester) async {
    when(() => core.getConnectionCount()).thenAnswer((_) async => 34);

    await pumpCard(tester);

    expect(find.text('34'), findsOneWidget);

    await teardownCard(tester);
  });

  testWidgets('the request and DNS counts follow on the throttled cadence', (
    tester,
  ) async {
    await pumpCard(tester);

    container.read(requestCountProvider.notifier).value = 1284;
    container.read(dnsQueryCountProvider.notifier).value = 42;
    await tester.pump();

    expect(find.text('1,284'), findsNothing);
    await tester.pump(const Duration(milliseconds: 301));

    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    await teardownCard(tester);
  });

  Future<void> holdCounts(WidgetTester tester) async {
    container.read(runTimeProvider.notifier).value = 1000;
    await pumpCard(tester);
    container.read(requestCountProvider.notifier).value = 7;
    await tester.pump();
    expect(find.text('7'), findsOneWidget);

    container.read(requestCountProvider.notifier).value = 1284;
    container.read(dnsQueryCountProvider.notifier).value = 42;
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('1,284'), findsNothing);
  }

  void expectHeldCountsShown() {
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  }

  testWidgets('while running, the counts after the first wait for the next '
      'traffic sample', (tester) async {
    await holdCounts(tester);
    container.read(trafficsProvider.notifier).addTraffic(const Traffic());
    await tester.pump();
    expectHeldCountsShown();

    await teardownCard(tester);
  });

  testWidgets('held counts show once the run stops', (tester) async {
    await holdCounts(tester);
    container.read(runTimeProvider.notifier).value = null;
    await tester.pump();
    expectHeldCountsShown();

    await teardownCard(tester);
  });

  testWidgets('held counts show when no traffic sample comes', (tester) async {
    await holdCounts(tester);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('1,284'), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    expectHeldCountsShown();

    await teardownCard(tester);
  });

  testWidgets('a count too long for a third of a phone is shortened in any '
      'locale', (tester) async {
    when(() => core.getConnectionCount()).thenAnswer((_) async => 99999);
    container.read(requestCountProvider.notifier).value = 123456;

    await pumpCard(tester, locale: const Locale('zh', 'CN'));

    expect(find.text('99,999'), findsOneWidget);
    expect(find.text('123K'), findsOneWidget);

    await teardownCard(tester);
  });

  testWidgets('every count opens its own list in a sheet', (tester) async {
    await pumpCard(tester);

    for (final (label, list) in [
      ('Live connections', ConditionFilterRow<TrackerInfo, ConnectionStatus>),
      ('Recent requests', ConditionFilterRow<TrackerInfo, ConnectionStatus>),
      ('DNS queries', ConditionFilterRow<DnsQuery, DnsStatus>),
    ]) {
      await tester.tap(_stat(label));
      await tester.pumpAndSettle();

      final view = find.byType(RequestsView);
      expect(view, findsOneWidget);
      expect(
        find.descendant(of: view, matching: find.byType(list)),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byType(SheetDragHandle)).dy,
        closeTo(_mobileSize.height * (1 - snapSheetDetents.first), 1),
      );

      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(view, findsNothing);
    }

    await teardownCard(tester);
  });

  testWidgets('the requests sheet keeps the newest request at its end while '
      'it is dragged and requests arrive', (tester) async {
    final notifier = container.read(requestsProvider.notifier);
    var next = 0;
    while (next < 200) {
      notifier.addRequest(_request(next++));
    }
    await pumpCard(tester);
    await tester.tap(_stat('Recent requests'));
    await tester.pumpAndSettle();
    final list = find.descendant(
      of: find.byType(RecordFeedView<String>),
      matching: find.byType(Scrollable),
    );
    ScrollPosition position() =>
        tester.state<ScrollableState>(list.first).position;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SheetDragHandle)),
    );
    for (var frame = 0; frame < 40; frame++) {
      if (frame % 10 == 0) {
        for (var i = 0; i < 5; i++) {
          notifier.addRequest(_request(next++));
        }
      }
      await gesture.moveBy(const Offset(0, -6));
      await tester.pump(const Duration(milliseconds: 16));
      expect(position().pixels, position().maxScrollExtent);
    }
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(position().pixels, position().maxScrollExtent);
    expect(find.textContaining('host-${next - 1}.test'), findsWidgets);

    await teardownCard(tester);
  });

  testWidgets('a page pushed over the card and popped rebuilds none of it', (
    tester,
  ) async {
    when(() => core.getConnectionCount()).thenAnswer((_) async => 34);
    await pumpCard(tester);

    expect(
      await rebuildsWhileCovered<ConnectionStatsCard>(
        tester,
        find.byType(ConnectionStatsCard),
      ),
      0,
    );

    await teardownCard(tester);
  });
}
