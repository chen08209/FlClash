import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

TrackerInfo _connection(
  int index, {
  required String network,
  int download = 0,
}) {
  return TrackerInfo(
    id: '$index',
    download: download,
    start: DateTime.utc(2026).add(Duration(seconds: index)),
    metadata: Metadata(network: network, host: 'host-$index.test'),
    chains: const ['Proxy'],
    rule: 'MATCH',
    rulePayload: '',
  );
}

TrackerInfo _request(String host, int download) {
  return TrackerInfo(
    id: host,
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
    requests.value = FixedList<TrackerInfo>(500);
    requests.addRequest(_request('gamma.test', 10));
    requests.addRequest(_request('alpha.test', 30));
    requests.addRequest(_request('beta.test', 20));
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

  testWidgets('a column dragged wider in the card keeps its width', (
    tester,
  ) async {
    await pumpRequestsTable(tester);

    final ruleHead = find.descendant(
      of: find.byType(ConnectionsTableCard),
      matching: find.text('Rule'),
    );
    final rule = tester.getTopLeft(ruleHead).dx;
    final handles = find.byWidgetPredicate(
      (widget) =>
          widget is MouseRegion &&
          widget.cursor == SystemMouseCursors.resizeColumn,
    );
    await tester.drag(
      handles.at(2),
      const Offset(60, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    expect(tester.getTopLeft(ruleHead).dx, greaterThan(rule + 30));
    expect(
      container
          .read(appSettingProvider)
          .tableColumnWidths['dashboard.requests'],
      contains('target'),
    );

    await teardown(tester);
  });

  testWidgets('the table keeps the newest rows, sorts every connection and '
      'counts them all', (tester) async {
    final core = _MockCore();
    when(() => core.getConnections()).thenAnswer(
      (_) async => [
        for (var index = 0; index < 150; index++)
          _connection(
            index,
            network: index < 130 ? 'tcp' : 'udp',
            download: index == 0 ? 1 << 30 : index,
          ),
      ],
    );
    final connections = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    addTearDown(connections.dispose);
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
          child: Scaffold(
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
    expect(find.text('host-149.test'), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.childrenDelegate.estimatedChildCount, 100);
    expect(find.text('host-0.test'), findsNothing);

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(find.text('host-0.test'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
