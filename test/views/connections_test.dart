import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

TrackerInfo _tracker({
  required String id,
  String host = 'example.com',
  String process = 'curl',
  List<String> chains = const ['Proxy'],
  int upload = 0,
  int download = 0,
  DateTime? start,
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
    ),
    chains: chains,
    rule: 'DOMAIN',
    rulePayload: host,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCoreHandlerInterface core;
  late ProviderContainer container;

  setUpAll(() {
    core = MockCoreHandlerInterface();
  });

  setUp(() {
    reset(core);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    globalState.container = container;
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
        child: const TestApp(child: ConnectionsView()),
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
    when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('shows nothing until core answers, then its rows at once', (
    tester,
  ) async {
    final pending = Completer<List<TrackerInfo>>();
    when(core.getConnections).thenAnswer((_) => pending.future);

    await pumpConnections(tester);
    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsNothing);

    pending.complete([_tracker(id: 'a', host: 'alpha.test')]);
    await tester.pump();
    await tester.pump();

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('shows its first connections while its page is pushed in', (
    tester,
  ) async {
    when(
      core.getConnections,
    ).thenAnswer((_) async => [_tracker(id: 'a', host: 'alpha.test')]);
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
                MaterialPageRoute<void>(
                  builder: (_) => const ConnectionsView(),
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

    final route = ModalRoute.of(tester.element(find.byType(ConnectionsView)))!;
    expect(route.animation!.isAnimating, isTrue);
    expect(find.textContaining('alpha.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('renders one row per reported connection', (tester) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test'),
        _tracker(id: 'b', host: 'beta.test'),
      ],
    );

    await pumpConnections(tester);
    await pumpSettled(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('orders rows by total traffic, then newest first', (
    tester,
  ) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test', download: 100),
        _tracker(id: 'b', host: 'beta.test', upload: 300, download: 300),
        _tracker(
          id: 'c',
          host: 'gamma.test',
          download: 100,
          start: DateTime.utc(2026, 2),
        ),
      ],
    );

    await pumpConnections(tester);
    await pumpSettled(tester);

    double topOf(String host) =>
        tester.getTopLeft(find.textContaining(host).first).dy;
    expect(topOf('beta.test'), lessThan(topOf('gamma.test')));
    expect(topOf('gamma.test'), lessThan(topOf('alpha.test')));
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a wide page lays the connections out as a table and blocks '
      'a row from it', (tester) async {
    var connections = [
      _tracker(id: 'a', host: 'alpha.test', chains: const ['Tokyo', 'Proxy']),
      _tracker(id: 'b', host: 'beta.test'),
    ];
    when(core.getConnections).thenAnswer((_) async => connections);
    when(() => core.closeConnection(any())).thenAnswer((_) async => true);

    await pumpConnections(tester);
    await pumpSettled(tester);

    for (final label in [
      'Process',
      'Target',
      'Protocol',
      'Rule',
      'Exit',
      'Download',
      'Upload',
      'Downloaded',
      'Uploaded',
      'Duration',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TrackerInfoTableRow), findsNWidgets(2));
    expect(find.byType(Divider), findsNothing);
    expect(
      tester
          .widgetList<TrackerInfoTableRow>(find.byType(TrackerInfoTableRow))
          .map((row) => row.striped)
          .toSet(),
      {true, false},
    );
    expect(find.text('Tokyo'), findsOneWidget);

    connections = [connections.last];
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.textContaining('alpha.test').first,
          matching: find.byType(TrackerInfoTableRow),
        ),
        matching: find.byTooltip('Block connection'),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => core.closeConnection('a')).called(1);
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a live table keeps the totals ahead of protocol and duration', (
    tester,
  ) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test', upload: 512, download: 1536),
      ],
    );

    await pumpConnections(tester, width: 1100);
    await pumpSettled(tester);

    expect(find.text('Downloaded'), findsOneWidget);
    expect(find.text('Uploaded'), findsOneWidget);
    expect(find.text('1.5KB'), findsOneWidget);
    expect(find.text('512B'), findsOneWidget);
    expect(find.text('Protocol'), findsNothing);
    expect(find.text('Duration'), findsNothing);

    tester.view.physicalSize = const Size(900, 1000);
    await tester.pump();

    expect(find.text('Traffic'), findsOneWidget);
    expect(find.text('2KB'), findsOneWidget);
    expect(find.text('Downloaded'), findsNothing);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('a sorted table keeps its order across polls', (tester) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test', process: 'zsh', download: 300),
        _tracker(id: 'b', host: 'beta.test', process: 'curl', download: 200),
        _tracker(id: 'c', host: 'gamma.test', process: 'make', download: 100),
      ],
    );

    await pumpConnections(tester);
    await pumpSettled(tester);

    double topOf(String host) =>
        tester.getTopLeft(find.textContaining(host).first).dy;
    expect(topOf('alpha.test'), lessThan(topOf('beta.test')));

    await tester.tap(find.text('Process'));
    await tester.pumpAndSettle();
    expect(topOf('beta.test'), lessThan(topOf('gamma.test')));
    expect(topOf('gamma.test'), lessThan(topOf('alpha.test')));

    await pumpSettled(tester);
    expect(topOf('beta.test'), lessThan(topOf('gamma.test')));
    expect(topOf('gamma.test'), lessThan(topOf('alpha.test')));

    await teardownView(tester);
  });

  testWidgets('keeps the empty state when core throws', (tester) async {
    when(core.getConnections).thenThrow(StateError('core down'));

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('stops polling once the view is disposed', (tester) async {
    when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);

    await pumpConnections(tester);
    await teardownView(tester);
    clearInteractions(core);

    await tester.pump(const Duration(seconds: 3));

    verifyNever(core.getConnections);
  });
}
