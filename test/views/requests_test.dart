import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scrollbar.dart';
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

  testWidgets('holding the scrollbar thumb floats the start time beside it', (
    tester,
  ) async {
    final requests = List.generate(
      200,
      (i) => TrackerInfo(
        id: '$i',
        start: DateTime.utc(2026, 1, 1, 0, 0, i),
        metadata: Metadata(
          network: 'tcp',
          host: 'host-$i.test',
          destinationIP: '1.1.1.1',
          destinationPort: '443',
          process: 'curl',
        ),
        chains: const ['Proxy'],
        rule: 'DOMAIN',
        rulePayload: 'host-$i.test',
      ),
    );
    seedRequests(requests);

    await pumpRequests(tester);

    const hintKey = ValueKey('scrollbarHintPill');
    expect(find.byKey(hintKey), findsNothing);

    final thumb = await revealScrollbarThumb(tester);
    final gesture = await tester.startGesture(thumb);
    await gesture.moveBy(const Offset(0, -1));
    await tester.pump();

    expect(find.byKey(hintKey), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(label.data, requests.last.start.showFull);
    // The hint is pinned to the thumb: at the newest end the thumb center
    // rests 24 dp (half the 48 dp minimum thumb) below the track's top edge,
    // which the list running under the bar leaves at the bar's foot.
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(tester.getRect(find.byType(AppBar)).bottom + 24, 6),
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(hintKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byKey(hintKey), findsNothing);

    await teardownView(tester);
  });

  testWidgets('following pauses when the list is scrolled off its head and '
      'resumes when it is scrolled back', (tester) async {
    seedRequests([for (var i = 0; i < 60; i++) _tracker(id: '$i')]);

    await pumpRequests(tester);
    await tester.pumpAndSettle();

    final box = find.byType(ScrollToEndBox);
    bool following() => tester.widget<ScrollToEndBox>(box).enable;
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(following(), isTrue);

    // The list is reversed, so its head is the end of the scroll extent and
    // an upward drag moves away from it.
    await tester.drag(box, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(following(), isFalse);

    await tester.drag(box, const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(following(), isTrue);

    await teardownView(tester);
  });
}
