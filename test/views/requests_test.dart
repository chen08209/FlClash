import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

TrackerInfo _tracker({required String id, String host = 'example.com'}) {
  return TrackerInfo(
    id: id,
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: 'curl',
    ),
    chains: const ['Proxy'],
    rule: 'DOMAIN',
    rulePayload: host,
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
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));
  });

  tearDown(() => container.dispose());

  void seedRequests(List<TrackerInfo> requests) {
    final notifier = container.read(requestsProvider.notifier);
    notifier.value = FixedList<TrackerInfo>(500);
    for (final request in requests) {
      notifier.addRequest(request);
    }
  }

  void addRequest(TrackerInfo request) {
    container.read(requestsProvider.notifier).addRequest(request);
  }

  Future<void> pumpRequests(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: RequestsView()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state without any request', (tester) async {
    await pumpRequests(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('renders the requests already in the store on mount', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);

    await pumpRequests(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a request arriving after mount reaches the list', (
    tester,
  ) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    expect(find.textContaining('gamma.test'), findsNothing);

    addRequest(_tracker(id: 'c', host: 'gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('gamma.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('the scroll-to-end button toggles its icon', (tester) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);

    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(find.byIcon(Icons.vertical_align_top), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.vertical_align_top), findsOneWidget);

    await teardownView(tester);
  });
}
