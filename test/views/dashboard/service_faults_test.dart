import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/widgets/service_faults.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/host_scaffold.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _portTaken = ServiceFault(
  service: FaultService.mixed,
  address: '127.0.0.1:7890',
  reason: FaultReason.addressInUse,
  message: 'Address already in use (os error 48)',
);

const _dnsFailed = ServiceFault(
  service: FaultService.dns,
  address: '0.0.0.0:1053',
  reason: FaultReason.other,
  message: 'Start DNS server error: unsupported',
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpBadge(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: HostScaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: ServiceFaultsButton([_portTaken, _dnsFailed]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpDashboard(WidgetTester tester) async {
    const size = Size(412, 1400);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: DashboardView(platform: SupportPlatform.Android),
        ),
      ),
    );
    await tester.pump();
  }

  void report(List<ServiceFault> faults) {
    container.read(serviceFaultsProvider.notifier).value = faults;
  }

  testWidgets('counts the faults and explains them on a tap', (tester) async {
    await pumpBadge(tester);

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    for (final text in [
      'Mixed port 127.0.0.1:7890',
      'The address is already in use.',
      'DNS server 0.0.0.0:1053',
      _dnsFailed.message,
    ]) {
      expect(find.textContaining(text, findRichText: true), findsOneWidget);
    }
    expect(
      find.textContaining(_portTaken.message, findRichText: true),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the dashboard bar holds the badge only while a service is '
      'down, and keeps its edit button otherwise', (tester) async {
    await pumpDashboard(tester);

    expect(find.byTooltip('Services not started'), findsNothing);
    expect(find.byTooltip('Edit dashboard'), findsOneWidget);

    report(const [_portTaken]);
    await tester.pump();
    expect(find.byTooltip('Services not started'), findsOneWidget);

    report(const []);
    await tester.pump();
    expect(find.byTooltip('Services not started'), findsNothing);
    expect(find.byTooltip('Edit dashboard'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
