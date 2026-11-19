import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/record.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/core_mocks.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

TrackerInfo _tracker({
  required int id,
  String host = 'example.com',
  String process = 'curl',
  List<String> chains = const ['Proxy'],
  int upload = 0,
  int download = 0,
  DateTime? start,
  bool mitm = false,
}) {
  return TrackerInfo(
    id: id,
    upload: upload,
    download: download,
    start: start ?? DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: process,
      mitm: mitm,
    ),
    chains: chains,
    rule: 'DOMAIN',
    rulePayload: host,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoreMocks mocks;
  late ProviderContainer container;
  late Future<List<TrackerInfo>> Function() readConnections;
  var reads = 0;

  Future<List<TrackerInfo>> read() {
    reads++;
    return readConnections();
  }

  setUp(() {
    mocks = coreMocks();
    reads = 0;
    readConnections = () async => const [];
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(mocks.controller),
      ],
    );
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  });

  tearDown(() => container.dispose());

  Future<void> pumpConnections(
    WidgetTester tester, {
    double width = 1400,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: RequestsView(connectionsReader: read)),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> pumpSettled(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(commonDuration);
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state when core reports no connections', (
    tester,
  ) async {
    readConnections = () async => const <TrackerInfo>[];

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('lists a connection the Core reports that no event told of', (
    tester,
  ) async {
    final pending = Completer<List<TrackerInfo>>();
    readConnections = () => pending.future;

    await pumpConnections(tester);
    expect(find.textContaining('alpha.test'), findsNothing);

    pending.complete([_tracker(id: 1, host: 'alpha.test')]);
    await tester.pump();
    await pumpSettled(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('shows the connections it holds while its page is pushed in', (
    tester,
  ) async {
    readConnections = () async => [_tracker(id: 1, host: 'alpha.test')];
    container.read(requestsProvider.notifier).addRequests([
      _tracker(id: 1, host: 'alpha.test'),
    ]);
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                HostPageRoute<void>(
                  builder: (_) => RequestsView(connectionsReader: read),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    final route = ModalRoute.of(tester.element(find.byType(RequestsView)))!;
    expect(route.animation!.isAnimating, isTrue);
    expect(find.textContaining('alpha.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('renders one row per reported connection', (tester) async {
    readConnections = () async => [
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ];

    await pumpConnections(tester);
    await pumpSettled(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('lists the newest connection first, whatever its traffic', (
    tester,
  ) async {
    readConnections = () async => [
      _tracker(id: 1, host: 'alpha.test', download: 900),
      _tracker(
        id: 2,
        host: 'beta.test',
        download: 100,
        start: DateTime.utc(2026, 2),
      ),
      _tracker(
        id: 3,
        host: 'gamma.test',
        download: 300,
        start: DateTime.utc(2026, 3),
      ),
    ];

    for (final width in [1400.0, 600.0]) {
      await pumpConnections(tester, width: width);
      await pumpSettled(tester);

      double topOf(String host) =>
          tester.getTopLeft(find.textContaining(host).first).dy;
      expect(
        topOf('gamma.test'),
        lessThan(topOf('beta.test')),
        reason: '$width',
      );
      expect(
        topOf('beta.test'),
        lessThan(topOf('alpha.test')),
        reason: '$width',
      );
    }
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a wide page closes a row from its menu and keeps the rows '
      'where they are', (tester) async {
    var connections = [
      _tracker(id: 1, host: 'alpha.test', chains: const ['Tokyo', 'Proxy']),
      _tracker(id: 2, host: 'beta.test'),
    ];
    readConnections = () async => connections;
    when(
      () => mocks.api.closeConnections(ids: any(named: 'ids')),
    ).thenAnswer((_) async {});

    await pumpConnections(tester);
    await pumpSettled(tester);

    expect(find.byType(TrackerInfoItem), findsNWidgets(2));

    double topOf(String host) =>
        tester.getTopLeft(find.textContaining(host).first).dy;
    final alphaTop = topOf('alpha.test');
    final betaTop = topOf('beta.test');

    await tester.longPress(find.textContaining('alpha.test').first);
    await tester.pumpAndSettle();
    connections = [connections.last];
    await tester.tap(find.text('Close connection'));
    await tester.pumpAndSettle();

    verify(() => mocks.api.closeConnections(ids: [1])).called(1);
    await pumpSettled(tester);
    expect(container.read(requestsProvider)[1]!.isActive, isFalse);
    expect(topOf('alpha.test'), alphaTop);
    expect(topOf('beta.test'), betaTop);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a row marks a decrypted connection', (tester) async {
    readConnections = () async => [
      _tracker(id: 1, host: 'alpha.test', mitm: true),
      _tracker(id: 2, host: 'beta.test'),
    ];

    await pumpConnections(tester, width: 900);
    await pumpSettled(tester);

    expect(find.byType(TrackerInfoItem), findsNWidgets(2));
    final label = find.widgetWithText(RecordLabel, 'MITM');
    expect(label, findsOneWidget);
    expect(
      find.ancestor(
        of: label,
        matching: find.byWidgetPredicate(
          (widget) => widget is TrackerInfoItem && widget.trackerInfo.id == 1,
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('the menu closes every open connection once that is confirmed', (
    tester,
  ) async {
    readConnections = () async => [_tracker(id: 1, host: 'alpha.test')];
    when(() => mocks.api.closeConnections()).thenAnswer((_) async {});

    await pumpConnections(tester, width: 600);
    await pumpSettled(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close all active connections'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();

    verify(() => mocks.api.closeConnections()).called(1);

    await teardownView(tester);
  });

  testWidgets('keeps the empty state when core throws', (tester) async {
    readConnections = () async => throw StateError('core down');

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a late snapshot closes only the connections opened before it '
      'was asked for', (tester) async {
    final pending = Completer<List<TrackerInfo>>();
    readConnections = () => pending.future;
    final requests = container.read(requestsProvider.notifier);
    requests.addRequests([
      _tracker(
        id: 1,
        start: DateTime.now().subtract(const Duration(seconds: 5)),
      ),
    ]);

    await pumpConnections(tester);
    requests.addRequests([_tracker(id: 2, start: DateTime.now())]);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    pending.complete(const []);
    await tester.pump();
    await tester.pump();

    final log = container.read(requestsProvider);
    expect(log[1]!.isActive, isFalse);
    expect(log[2]!.isActive, isTrue);

    await teardownView(tester);
  });

  testWidgets('stops polling once the view is disposed', (tester) async {
    readConnections = () async => const <TrackerInfo>[];

    await pumpConnections(tester);
    await teardownView(tester);
    reads = 0;

    await tester.pump(const Duration(seconds: 3));

    expect(reads, 0);
  });
}
