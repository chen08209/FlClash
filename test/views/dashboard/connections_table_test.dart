import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_list.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';
import '../../helpers/host_scaffold.dart';

ConnectionInfo _connection(
  int index, {
  required String network,
  int download = 0,
}) {
  return ConnectionInfo(
    id: index,
    start: DateTime.utc(
      2026,
    ).add(Duration(seconds: index)).millisecondsSinceEpoch,
    network: network,
    sourceIp: '127.0.0.1',
    sourcePort: 50000,
    destinationPort: 443,
    host: 'host-$index.test',
    inboundType: 'mixed',
    chains: const ['Proxy'],
    rule: 'MATCH',
    upload: 0,
    download: download,
  );
}

TrackerInfo _request(int id, String host, int download) {
  return TrackerInfo(
    id: id,
    download: download,
    start: DateTime.utc(2026),
    metadata: Metadata(network: 'tcp', host: host, destinationPort: '443'),
    chains: const ['DIRECT'],
    rule: 'MATCH',
    rulePayload: '',
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {});
    final requests = container.read(requestsProvider.notifier);
    requests.value = ConnectionLog(500);
    requests.addRequests([
      _request(1, 'gamma.test', 10),
      _request(2, 'alpha.test', 30),
      _request(3, 'beta.test', 20),
    ]);
  });

  tearDown(() => container.dispose());

  Future<void> pumpRequestsTable(WidgetTester tester) async {
    const size = Size(1220, 824);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: DashboardView(platform: SupportPlatform.MacOS),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(ConnectionsTableCard),
        matching: find.text('Recent requests'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  double topOf(WidgetTester tester, String host) =>
      tester.getTopLeft(find.textContaining(host)).dy;

  testWidgets('tapping a column head sorts the card table', (tester) async {
    await pumpRequestsTable(tester);

    expect(topOf(tester, 'beta.test'), lessThan(topOf(tester, 'alpha.test')));

    await tester.tap(find.text('Traffic'));
    await tester.pump();
    expect(topOf(tester, 'alpha.test'), lessThan(topOf(tester, 'beta.test')));
    expect(topOf(tester, 'beta.test'), lessThan(topOf(tester, 'gamma.test')));

    await teardown(tester);
  });

  Finder ruleHead() => find.descendant(
    of: find.byType(ConnectionsTableCard),
    matching: find.text('Rule'),
  );

  Finder resizeHandle() => find
      .byWidgetPredicate(
        (widget) =>
            widget is MouseRegion &&
            widget.cursor == SystemMouseCursors.resizeColumn,
      )
      .at(2);

  Future<void> widenTarget(WidgetTester tester) async {
    await tester.drag(
      resizeHandle(),
      const Offset(60, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
  }

  testWidgets('a column dragged wider in the card keeps its width', (
    tester,
  ) async {
    await pumpRequestsTable(tester);
    final rule = tester.getTopLeft(ruleHead()).dx;
    await widenTarget(tester);

    expect(tester.getTopLeft(ruleHead()).dx, greaterThan(rule + 30));
    expect(
      container
          .read(appSettingProvider)
          .tableColumnWidths['dashboard.requests'],
      contains('target'),
    );

    await teardown(tester);
  });

  testWidgets('a double click on a column edge sets the card\'s columns back', (
    tester,
  ) async {
    await pumpRequestsTable(tester);
    final rule = tester.getTopLeft(ruleHead()).dx;
    await widenTarget(tester);
    expect(tester.getTopLeft(ruleHead()).dx, greaterThan(rule + 30));

    await tester.tap(resizeHandle(), kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(resizeHandle(), kind: PointerDeviceKind.mouse);
    await tester.pump(kDoubleTapTimeout);

    expect(tester.getTopLeft(ruleHead()).dx, rule);
    expect(
      container.read(appSettingProvider).tableColumnWidths,
      isNot(contains('dashboard.requests')),
    );

    await teardown(tester);
  });

  testWidgets('the card table opens with the widths saved for it', (
    tester,
  ) async {
    await pumpRequestsTable(tester);
    final rule = tester.getTopLeft(ruleHead()).dx;
    await widenTarget(tester);
    final widened = tester.getTopLeft(ruleHead()).dx;
    await teardown(tester);

    await pumpRequestsTable(tester);

    expect(widened, greaterThan(rule + 30));
    expect(tester.getTopLeft(ruleHead()).dx, widened);

    await teardown(tester);
  });

  testWidgets('the table keeps the newest rows, sorts every connection and '
      'counts them all', (tester) async {
    final connections = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    addTearDown(connections.dispose);
    connections
        .read(connectionBookProvider)
        .apply(
          ConnectionsReset(
            ConnectionSnapshot([
              for (var index = 0; index < 150; index++)
                _connection(
                  index,
                  network: index < 130 ? 'tcp' : 'udp',
                  download: index == 0 ? 1 << 30 : index,
                ),
            ]),
          ),
        );
    globalState.container = connections;
    const size = Size(1000, 700);
    connections.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: connections,
        child: const TestApp(
          child: HostScaffold(
            body: SizedBox(
              width: 960,
              height: 600,
              child: DashboardDensityScope(
                density: DashboardDensity.standard,
                scale: 1,
                child: ConnectionsTableCard(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('TCP 130'), findsOneWidget);
    expect(find.text('UDP 20'), findsOneWidget);
    expect(
      find.textContaining('host-149.test', findRichText: true),
      findsOneWidget,
    );
    final list = tester.widget<PrismListView>(find.byType(PrismListView));
    expect(list.itemCount, 100);
    expect(
      find.textContaining('host-0.test', findRichText: true),
      findsNothing,
    );

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(
      find.textContaining('host-0.test', findRichText: true),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
