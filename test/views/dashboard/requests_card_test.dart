import 'package:fl_clash/features/connection/tracker_info_list.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/dashboard/widgets/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
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
          child: Scaffold(body: ListView(children: const [RequestsCard()])),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the request count and follows it', (tester) async {
    await pumpCard(tester);

    expect(find.text('Recent requests'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    container.read(requestCountProvider.notifier).value = 42;
    await tester.pump();

    // The count repaints on the throttled cadence, not per request.
    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 301));

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping the card opens the requests in a sheet', (tester) async {
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(RequestsCard));
    await tester.pumpAndSettle();

    expect(find.byType(RequestsView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      closeTo(_mobileSize.height * (1 - snapSheetDetents.first), 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the sheet keeps the newest request at its top while it is '
      'dragged and requests arrive', (tester) async {
    final notifier = container.read(requestsProvider.notifier);
    var next = 0;
    while (next < 200) {
      notifier.addRequest(_request(next++));
    }
    await pumpCard(tester, size: _mobileSize);
    await tester.tap(find.byType(RequestsCard));
    await tester.pumpAndSettle();
    final list = find.descendant(
      of: find.byType(TrackerInfoList),
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

    expect(position().pixels, position().maxScrollExtent);
    expect(find.textContaining('host-${next - 1}.test'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
