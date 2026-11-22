import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/core_connections.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() {
    container.dispose();
  });

  List<TrackerInfo> buildConnections(int count) {
    return List.generate(
      count,
      (index) => TrackerInfo(
        id: '$index',
        start: DateTime(2024),
        metadata: Metadata(
          network: 'tcp',
          host: 'host-$index.com',
          destinationPort: '443',
        ),
        chains: const ['proxy-a'],
        rule: 'MATCH',
        rulePayload: '',
      ),
    );
  }

  Future<void> pumpConnections(
    WidgetTester tester, {
    required Future<List<TrackerInfo>> Function() connectionsReader,
    bool isPageActive = true,
  }) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: isPageActive,
            child: RequestsView(connectionsReader: connectionsReader),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the list lazily builds every connection, newest first', (
    tester,
  ) async {
    final connections = buildConnections(100);

    await pumpConnections(tester, connectionsReader: () async => connections);
    await tester.pump(const Duration(seconds: 1));

    final builtItems = find.byType(TrackerInfoItem).evaluate().length;
    expect(builtItems, greaterThan(0));
    expect(builtItems, lessThan(connections.length));
    expect(find.textContaining('host-99.com'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('host-0.com'),
      -800,
      scrollable: find
          .descendant(
            of: find.byType(RecordMinuteList<String>),
            matching: find.byType(Scrollable),
          )
          .first,
    );

    expect(find.textContaining('host-0.com'), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'a row closes its own connection from its menu, and stays where it was, '
    'closed',
    (tester) async {
      final core = _MockCoreHandlerInterface();
      when(() => core.closeConnection(any())).thenAnswer((_) async {});
      container.dispose();
      container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      globalState.container = container;
      var connections = buildConnections(2);
      var readCount = 0;

      await pumpConnections(
        tester,
        connectionsReader: () async {
          readCount++;
          return connections;
        },
      );
      await tester.pump(const Duration(seconds: 1));
      final reads = readCount;

      expect(find.byTooltip('Close connection'), findsNothing);
      await tester.longPress(find.textContaining('host-0.com'));
      await tester.pumpAndSettle();
      connections = connections.sublist(1);
      await tester.tap(find.text('Close connection'));
      await tester.pumpAndSettle();

      verify(() => core.closeConnection('0')).called(1);
      expect(readCount, greaterThan(reads));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('host-0.com'), findsOneWidget);
      expect(container.read(requestsProvider)['0']!.isActive, isFalse);

      await tester.longPress(find.textContaining('host-0.com'));
      await tester.pumpAndSettle();
      expect(find.text('Close connection'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('a failed close still refreshes the list and raises nothing', (
    tester,
  ) async {
    final core = _MockCoreHandlerInterface();
    when(
      () => core.closeConnection(any()),
    ).thenAnswer((_) async => throw Exception('closed already'));
    container.dispose();
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    globalState.container = container;
    var readCount = 0;

    await pumpConnections(
      tester,
      connectionsReader: () async {
        readCount++;
        return buildConnections(2);
      },
    );
    await tester.pump(const Duration(seconds: 1));
    final reads = readCount;

    await tester.longPress(find.textContaining('host-0.com'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close connection'));
    await tester.pumpAndSettle();

    verify(() => core.closeConnection('0')).called(1);
    expect(readCount, greaterThan(reads));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a Core that is not connected is not asked and lists nothing', (
    tester,
  ) async {
    final core = _MockCoreHandlerInterface();
    container.dispose();
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    globalState.container = container;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: RequestsView()),
      ),
    );
    await tester.pump();
    await tester.pump();

    registerConnectionsPresenter<ConnectionPoll>();
    verifyNever(() => core.getConnectionsWith<ConnectionPoll>(any()));
    expect(find.byType(NullStatus), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the list polls only while the page is active', (tester) async {
    var readCount = 0;

    Future<List<TrackerInfo>> readConnections() async {
      readCount++;
      return const [];
    }

    await pumpConnections(
      tester,
      connectionsReader: readConnections,
      isPageActive: false,
    );
    await tester.pump(const Duration(seconds: 3));

    expect(readCount, 0);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: true,
            child: RequestsView(connectionsReader: readConnections),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(readCount, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(readCount, 2);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: false,
            child: RequestsView(connectionsReader: readConnections),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    expect(readCount, 2);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the list stops polling while the app is paused', (tester) async {
    var readCount = 0;

    Future<List<TrackerInfo>> readConnections() async {
      readCount++;
      return const [];
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpConnections(tester, connectionsReader: readConnections);
    await tester.pump();

    expect(readCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 4));

    expect(readCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(readCount, 2);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return HostApp(
      navigatorKey: globalState.navigatorKey,
      builder: (context, child) {
        return wrapAppScopes(context, child!);
      },
      home: child,
    );
  }
}

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}
