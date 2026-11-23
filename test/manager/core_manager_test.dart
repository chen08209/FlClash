import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/core_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/app_paths.dart';
import '../helpers/core_mocks.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';
import '../helpers/test_app.dart';

const _nullProfileSetupState = SetupState(
  profileId: null,
  profileLastUpdateDate: null,
  profileType: ProfileType.file,
  rules: [],
  proxyGroups: [],
  addedRules: [],
  script: null,
  overrides: ProfileOverrides(),
);

class _ApplyRecordingSetupAction extends SetupAction {
  int updates = 0;
  int applies = 0;
  int globalRulesApplies = 0;

  @override
  void applyIfGlobalRulesUsed() => globalRulesApplies++;

  @override
  Future<void> updateConfigDebounce() async {
    updates++;
  }

  @override
  void applyProfileDebounce({bool silence = false, bool force = false}) {
    applies++;
  }
}

class _RecordingProxiesAction extends ProxiesAction {
  final delays = <Delay>[];
  int groupUpdates = 0;

  @override
  void setDelay(Delay delay) => delays.add(delay);

  @override
  void updateGroupsDebounce([Duration? duration]) => groupUpdates++;
}

class _LostRecordingSetupAction extends SetupAction {
  int lostCount = 0;

  @override
  void onCoreLost() => lostCount++;
}

class _Feeds {
  final crashes = StreamController<String>.broadcast();
  final dns = StreamController<List<DnsEntry>>.broadcast();
  final events = StreamController<List<CoreEventDto>>.broadcast();
  final connections = StreamController<ConnectionUpdate>.broadcast();
  final proxies = StreamController<ProxyUpdate>.broadcast();
  final logs = StreamController<List<LogEntry>>.broadcast();
  final engine = StreamController<EngineStatus>.broadcast();

  Future<void> close() => Future.wait([
    crashes.close(),
    dns.close(),
    events.close(),
    connections.close(),
    proxies.close(),
    logs.close(),
    engine.close(),
  ]);
}

typedef _Harness = ({CoreMocks mocks, _Feeds feeds});

_Harness _harness() {
  final mocks = coreMocks();
  final feeds = _Feeds();
  addTearDown(feeds.close);
  stubSilentFeeds(mocks.api);
  when(() => mocks.backend.crashes).thenAnswer((_) => feeds.crashes.stream);
  when(() => mocks.api.watchDns()).thenAnswer((_) => feeds.dns.stream);
  when(
    () => mocks.api.watchEvents(delays: true, state: true),
  ).thenAnswer((_) => feeds.events.stream);
  when(
    () => mocks.api.watchConnections(
      maxBatchMs: 250,
      counters: any(named: 'counters'),
    ),
  ).thenAnswer((_) => feeds.connections.stream);
  when(() => mocks.api.watchProxies()).thenAnswer((_) => feeds.proxies.stream);
  when(() => mocks.api.watchLogs()).thenAnswer((_) => feeds.logs.stream);
  when(
    () => mocks.api.watchEngineStatus(),
  ).thenAnswer((_) => feeds.engine.stream);
  when(() => mocks.api.lastWarnings()).thenAnswer((_) async => const []);
  when(() => mocks.api.providers()).thenAnswer((_) async => const []);
  when(
    () => mocks.api.proxyGroups(),
  ).thenAnswer((_) async => const ProxyGroupsDto());
  return (mocks: mocks, feeds: feeds);
}

ConnectionInfo _connection(
  int id, {
  int upload = 0,
  int download = 0,
  String? host,
}) => ConnectionInfo(
  id: id,
  start: 1,
  network: 'tcp',
  sourceIp: '10.0.0.1',
  sourcePort: 5000 + id,
  destinationPort: 443,
  host: host ?? 'host$id.test',
  inboundType: 'http',
  chains: const ['DIRECT'],
  rule: 'MATCH',
  upload: upload,
  download: download,
);

Future<ProviderContainer> _pumpCoreManager(
  WidgetTester tester,
  CoreController core, {
  List<Override> overrides = const [],
  bool? pausesInBackground,
}) async {
  final container = ProviderContainer(
    overrides: [coreHandlerProvider.overrideWithValue(core), ...overrides],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: HostApp(
        navigatorKey: globalState.navigatorKey,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          return BannerHost(stacked: false, topInset: 0, child: child!);
        },
        home: CoreManager(
          pausesInBackground: pausesInBackground,
          child: const SizedBox(),
        ),
      ),
    ),
  );
  return container;
}

Future<ProviderContainer> _pumpConnected(
  WidgetTester tester,
  _Harness harness, {
  List<Override> overrides = const [],
  bool? pausesInBackground,
}) async {
  final container = await _pumpCoreManager(
    tester,
    harness.mocks.controller,
    overrides: overrides,
    pausesInBackground: pausesInBackground,
  );
  container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  await tester.pump();
  return container;
}

// Loading.stop leaves a minDuration timer (up to 1000ms) pending after
// setupConfig resolves. Polling on the actual outcome instead of a fixed
// pump budget avoids racing it, and draining past it here keeps its
// callback from firing on a disposed container.
Future<void> _waitForSetupToSettle(
  WidgetTester tester,
  bool Function() condition,
) async {
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!condition() && DateTime.now().isBefore(deadline)) {
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    final drainDeadline = DateTime.now().add(
      const Duration(milliseconds: 1100),
    );
    while (DateTime.now().isBefore(drainDeadline)) {
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });
}

Future<List<WarningInfo>> _applied(MockCoreApi api) => api.applyConfig(
  profilePath: any(named: 'profilePath'),
  overlay: any(named: 'overlay'),
  selection: any(named: 'selection'),
  options: any(named: 'options'),
  host: any(named: 'host'),
);

void main() {
  late Directory profileSwitchTempDir;

  setUpAll(() async {
    registerFallbackValue(const CoreOptionsArg(testUrl: ''));
    registerFallbackValue(const ConfigPatch());
    registerFallbackValue(LogLevel.info);
    loadAppLocalizations(const Locale('en'));
    profileSwitchTempDir = Directory.systemTemp.createTempSync(
      'core_manager_test',
    );
    await useAppPaths(profileSwitchTempDir);
  });

  tearDownAll(() {
    try {
      profileSwitchTempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('duplicate crash reports disconnect the core only once', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpCoreManager(tester, harness.mocks.controller);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    harness.feeds.crashes
      ..add('boom')
      ..add('boom');
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(transitions, [CoreStatus.disconnected]);
    verifyNever(() => harness.mocks.backend.stop());

    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('a crash while the app is visible surfaces the message', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpCoreManager(tester, harness.mocks.controller);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    harness.feeds.crashes.add('boom');
    await tester.pump();
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(find.text('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a crash ends the run here without telling the Core to stop', (
    tester,
  ) async {
    final harness = _harness();
    final setup = _LostRecordingSetupAction();
    final container = await _pumpConnected(
      tester,
      harness,
      overrides: [setupActionProvider.overrideWith(() => setup)],
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    harness.feeds.crashes.add('boom');
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(setup.lostCount, 1);
    verifyNever(() => harness.mocks.api.stopEngine());

    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('connections still open close once the core is gone', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1)])),
    );
    await tester.pump();
    expect(container.read(requestsProvider).activeCount, 1);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();

    expect(container.read(requestsProvider).activeCount, 0);
    expect(container.read(requestsProvider)[1]!.closedAt, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a Core connected again starts the requests and DNS queries '
      'over, so the ids it numbers from 1 again meet no earlier ones', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    DnsEntry query(String domain) => DnsEntry(
      domain: domain,
      type: 'A',
      initiator: 'user',
      upstream: '',
      cached: false,
      answers: const ['1.1.1.1'],
      rcode: '',
      error: '',
      delay: 3,
      time: 1,
    );
    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1), _connection(2)])),
    );
    harness.feeds.dns.add([query('before.test')]);
    await tester.pump();
    final status = container.read(coreStatusProvider.notifier);
    status.value = CoreStatus.disconnected;
    await tester.pump();
    expect(container.read(requestsProvider)[1]!.isActive, isFalse);

    status.value = CoreStatus.connected;
    await tester.pump();
    harness.feeds.connections.add(
      ConnectionsChanged(
        ConnectionDelta(opened: [_connection(1, host: 'after.test')]),
      ),
    );
    harness.feeds.dns.add([query('after.test')]);
    await tester.pump();

    final log = container.read(requestsProvider);
    expect(log.list.map((request) => request.metadata.host), ['after.test']);
    expect(log[1]!.isActive, isTrue);
    expect(
      container.read(dnsQueriesProvider).list.map((query) => query.domain),
      ['after.test'],
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a crash is ignored when the core is not connected', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpCoreManager(tester, harness.mocks.controller);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);

    harness.feeds.crashes.add('boom');
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.connecting);
    expect(transitions, isEmpty);
    expect(find.text('boom'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the streams open on connect and close when it is lost', (
    tester,
  ) async {
    final harness = _harness();
    final feeds = harness.feeds;
    final container = await _pumpCoreManager(tester, harness.mocks.controller);
    await tester.pump();

    expect(feeds.dns.hasListener, isFalse);
    expect(feeds.events.hasListener, isFalse);
    expect(feeds.connections.hasListener, isFalse);
    expect(feeds.proxies.hasListener, isFalse);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    expect(feeds.dns.hasListener, isTrue);
    expect(feeds.events.hasListener, isTrue);
    expect(feeds.connections.hasListener, isTrue);
    expect(feeds.proxies.hasListener, isTrue);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();

    expect(feeds.dns.hasListener, isFalse);
    expect(feeds.events.hasListener, isFalse);
    expect(feeds.connections.hasListener, isFalse);
    expect(feeds.proxies.hasListener, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the log stream follows the openLogs setting', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);

    expect(harness.feeds.logs.hasListener, isFalse);
    verifyNever(() => harness.mocks.api.watchLogs());

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    expect(harness.feeds.logs.hasListener, isTrue);
    verify(() => harness.mocks.api.watchLogs()).called(1);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: false));
    await tester.pump();

    expect(harness.feeds.logs.hasListener, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the log stream waits for the core and is restored on '
      'every connection', (tester) async {
    final harness = _harness();
    final container = await _pumpCoreManager(tester, harness.mocks.controller);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    verifyNever(() => harness.mocks.api.watchLogs());

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    verify(() => harness.mocks.api.watchLogs()).called(1);
    expect(harness.feeds.logs.hasListener, isTrue);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();

    verifyNever(() => harness.mocks.api.watchLogs());
    expect(harness.feeds.logs.hasListener, isFalse);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    verify(() => harness.mocks.api.watchLogs()).called(1);
    expect(harness.feeds.logs.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a setting the Core patches live is not re-applied', (
    tester,
  ) async {
    final setupAction = _ApplyRecordingSetupAction();
    final container = await _pumpCoreManager(
      tester,
      _harness().mocks.controller,
      overrides: [setupActionProvider.overrideWith(() => setupAction)],
    );

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.global, mixedPort: 8899));
    await tester.pump();

    expect(setupAction.updates, 1);
    expect(setupAction.applies, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a setting only a setup carries re-applies the profile', (
    tester,
  ) async {
    final setupAction = _ApplyRecordingSetupAction();
    final container = await _pumpCoreManager(
      tester,
      _harness().mocks.controller,
      overrides: [setupActionProvider.overrideWith(() => setupAction)],
    );

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(hosts: const {'a.test': '1.1.1.1'}));
    await tester.pump();
    container
        .read(networkSettingProvider.notifier)
        .update(
          (state) => state.copyWith(appendSystemDns: !state.appendSystemDns),
        );
    await tester.pump();

    expect(setupAction.applies, 2);
    expect(setupAction.updates, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a test URL change reaches the Core as an update, without an '
      'apply', (tester) async {
    final setupAction = _ApplyRecordingSetupAction();
    final container = await _pumpCoreManager(
      tester,
      _harness().mocks.controller,
      overrides: [setupActionProvider.overrideWith(() => setupAction)],
    );

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(testUrl: 'https://probe.test/204'));
    await tester.pump();

    expect(setupAction.updates, 1);
    expect(setupAction.applies, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a change to the global added rules, not their first load, '
      'asks for an apply', (tester) async {
    final setupAction = _ApplyRecordingSetupAction();
    final container = await _pumpCoreManager(
      tester,
      _harness().mocks.controller,
      overrides: [
        setupActionProvider.overrideWith(() => setupAction),
        globalRulesProvider.overrideWith(() => TestGlobalRules()),
      ],
    );
    await tester.pump();
    expect(setupAction.globalRulesApplies, 0);

    container.read(globalRulesProvider.notifier).value = [
      const Rule(id: 1, content: 'a.test', ruleTarget: 'DIRECT'),
    ];
    await tester.pump();

    expect(setupAction.globalRulesApplies, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('core logs are recorded for the logs view', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    harness.feeds.logs.add(const [
      LogEntry(level: 'info', time: 1, text: 'hello'),
    ]);
    await tester.pump();

    expect(
      container.read(logsProvider).list.map((log) => log.payload),
      contains('hello'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('core dns queries are recorded and counted', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);

    harness.feeds.dns.add([
      for (final domain in ['alpha.test', 'beta.test'])
        DnsEntry(
          domain: domain,
          type: 'A',
          initiator: 'user',
          upstream: '',
          cached: false,
          answers: const ['1.1.1.1'],
          rcode: '',
          error: '',
          delay: 3,
          time: 1,
        ),
    ]);
    await tester.pump();

    expect(
      container.read(dnsQueriesProvider).list.map((query) => query.domain),
      ['alpha.test', 'beta.test'],
    );
    expect(container.read(dnsQueryCountProvider), 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a connection names the DNS queries that gave its address', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);

    harness.feeds.dns.add([
      DnsEntry.fromJson({
        'id': 7,
        'domain': 'host1.test',
        'type': 'A',
        'initiator': 'rule',
        'answers': ['1.1.1.1'],
        'delay': 3,
        'time': 1,
      }),
    ]);
    harness.feeds.connections.add(
      ConnectionsChanged(
        ConnectionDelta(
          opened: [
            ConnectionInfo.fromJson({
              'id': 1,
              'start': 1,
              'network': 'tcp',
              'sourceIp': '10.0.0.1',
              'sourcePort': 5001,
              'destinationPort': 443,
              'host': 'host1.test',
              'inboundType': 'http',
              'chains': ['DIRECT'],
              'rule': 'MATCH',
              'upload': 0,
              'download': 0,
              'dnsQueries': [7],
            }),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(container.read(dnsQueriesProvider).list.single.id, 7);
    expect(container.read(requestsProvider)[1]!.dnsQueries, [7]);
    expect(container.read(requestsProvider).resolvedBy(7), [1]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a closed connection keeps why and when the core says it '
      'ended', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1), _connection(2)])),
    );
    await tester.pump();

    harness.feeds.connections.add(
      ConnectionsChanged(
        ConnectionDelta.fromJson({
          'closed': [1, 2],
          'ended': [
            {'id': 1, 'reason': 'remote', 'endedAt': 5000},
            {
              'id': 2,
              'reason': 'timeout',
              'endedAt': 6000,
              'message': 'read timed out',
            },
          ],
        }),
      ),
    );
    await tester.pump();

    final log = container.read(requestsProvider);
    expect(log[1]!.isActive, isFalse);
    expect(log[1]!.end!.reason, ConnectionEndReason.remote);
    expect(log[1]!.endedAt, DateTime.fromMillisecondsSinceEpoch(5000));
    expect(log[2]!.end!.reason, ConnectionEndReason.timeout);
    expect(log[2]!.end!.message, 'read timed out');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('connection updates are recorded, counted, kept up to date '
      'and closed', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);

    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1), _connection(2)])),
    );
    await tester.pump();

    expect(container.read(requestsProvider).list.map((request) => request.id), [
      1,
      2,
    ]);
    expect(container.read(requestCountProvider), 2);

    harness.feeds.connections.add(
      ConnectionsChanged(
        ConnectionDelta(
          opened: [_connection(3)],
          counters: const [ConnectionCounter(id: 1, upload: 7, download: 9)],
          closed: const [2],
        ),
      ),
    );
    await tester.pump();

    final requests = container.read(requestsProvider).list;
    expect(requests.map((request) => request.id), [1, 2, 3]);
    expect(container.read(requestCountProvider), 3);
    expect(requests.first.upload, 7);
    expect(requests.first.download, 9);
    expect(requests.map((request) => request.isActive), [true, false, true]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a connection whose dial failed is recorded closed, with why', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    JsonMap failed(int id, String kind) => {
      'id': id,
      'start': 1,
      'network': 'tcp',
      'sourceIp': '10.0.0.1',
      'sourcePort': 5000,
      'destinationPort': 443,
      'host': 'host$id.test',
      'inboundType': 'http',
      'chains': ['Proxy'],
      'rule': 'MATCH',
      'upload': 0,
      'download': 0,
      'failure': {'kind': kind, 'message': 'i/o timeout'},
    };

    harness.feeds.connections.add(
      ConnectionsChanged(
        ConnectionDelta.fromJson({
          'opened': [failed(1, 'timeout'), failed(2, 'a kind yet to come')],
          'closed': [1, 2],
          'counters': [
            {'id': 1, 'upload': 0, 'download': 0},
            {'id': 2, 'upload': 0, 'download': 0},
          ],
        }),
      ),
    );
    await tester.pump();

    final log = container.read(requestsProvider);
    expect(log[1]!.isActive, isFalse);
    expect(
      log[1]!.failure,
      const ConnectionFailure(
        kind: ConnectionFailureKind.timeout,
        message: 'i/o timeout',
      ),
    );
    expect(log[2]!.failure?.kind, ConnectionFailureKind.other);
    expect(container.read(requestCountProvider), 2);
    expect(container.read(connectionBookProvider).count, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  ({
    StreamController<ConnectionUpdate> lifecycle,
    StreamController<ConnectionUpdate> counting,
  })
  splitConnectionWatches(_Harness harness) {
    final lifecycle = StreamController<ConnectionUpdate>.broadcast();
    final counting = StreamController<ConnectionUpdate>.broadcast();
    addTearDown(lifecycle.close);
    addTearDown(counting.close);
    when(
      () => harness.mocks.api.watchConnections(
        maxBatchMs: 250,
        counters: any(named: 'counters'),
      ),
    ).thenAnswer(
      (invocation) => invocation.namedArguments[#counters] == true
          ? counting.stream
          : lifecycle.stream,
    );
    return (lifecycle: lifecycle, counting: counting);
  }

  testWidgets(
    'connection counters are asked for only while a view shows them',
    (tester) async {
      final harness = _harness();
      final watches = splitConnectionWatches(harness);
      final container = await _pumpConnected(tester, harness);
      expect(watches.lifecycle.hasListener, isTrue);
      expect(watches.counting.hasListener, isFalse);

      final demand = container.read(connectionBookProvider).demand..acquire();
      await tester.pump();
      demand.acquire();
      await tester.pump();
      expect(watches.counting.hasListener, isTrue);

      watches.lifecycle.add(
        ConnectionsReset(ConnectionSnapshot([_connection(1)])),
      );
      watches.counting.add(
        const ConnectionsChanged(
          ConnectionDelta(
            counters: [
              ConnectionCounter(id: 1, upload: 5, download: 6),
              ConnectionCounter(id: 9, upload: 1, download: 1),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(container.read(requestsProvider)[1]!.download, 6);
      expect(container.read(requestsProvider)[9], isNull);

      demand
        ..release()
        ..release();
      await tester.pump();
      expect(watches.counting.hasListener, isFalse);
      expect(watches.lifecycle.hasListener, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('a connection that opens and closes as counters are turned on '
      'is recorded with its totals', (tester) async {
    final harness = _harness();
    final watches = splitConnectionWatches(harness);
    final container = await _pumpConnected(tester, harness);

    container.read(connectionBookProvider).demand.acquire();
    await tester.pump();
    watches.lifecycle.add(
      ConnectionsChanged(
        ConnectionDelta(
          opened: [_connection(1)],
          closed: const [1],
          counters: const [ConnectionCounter(id: 1, upload: 3, download: 4)],
        ),
      ),
    );
    await tester.pump();

    final request = container.read(requestsProvider)[1];
    expect(request?.isActive, isFalse);
    expect(request?.download, 4);
    expect(container.read(requestCountProvider), 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the connection feed is not read while the app is in the '
      'background and catches up on return', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(
      tester,
      harness,
      pausesInBackground: true,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1)])),
    );
    await tester.pump();
    expect(container.read(requestCountProvider), 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(container.read(requestCountProvider), 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a reconnect starts the connection book afresh', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    harness.feeds.connections.add(
      ConnectionsReset(ConnectionSnapshot([_connection(1)])),
    );
    await tester.pump();
    expect(container.read(connectionBookProvider).count, 1);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    expect(container.read(connectionBookProvider).count, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delay events and proxy changes reach the proxies action', (
    tester,
  ) async {
    final harness = _harness();
    final proxies = _RecordingProxiesAction();
    await _pumpConnected(
      tester,
      harness,
      overrides: [proxiesActionProvider.overrideWith(() => proxies)],
    );

    harness.feeds.events.add(const [
      DelayEvent(
        DelayResult(name: 'node', url: 'https://probe.test', value: 42),
      ),
    ]);
    harness.feeds.proxies.add(const ProxiesChanged(ProxyDelta()));
    await tester.pump();

    expect(proxies.delays, hasLength(1));
    expect(proxies.delays.single.name, 'node');
    expect(proxies.delays.single.url, 'https://probe.test');
    expect(proxies.delays.single.value, 42);
    expect(proxies.groupUpdates, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a loaded provider event refreshes that provider', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    ExternalProvider provider(int count) => ExternalProvider(
      name: 'sub',
      type: 'Proxy',
      count: count,
      vehicleType: 'HTTP',
      updateAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    container.read(providersProvider.notifier).value = [provider(1)];
    when(() => harness.mocks.api.provider('sub')).thenAnswer(
      (_) async => const ProviderInfo(
        name: 'sub',
        type: ProviderKindDto.proxy,
        vehicleType: 'HTTP',
        count: 5,
        path: '',
        updatedAt: 0,
      ),
    );

    harness.feeds.events.add(const [
      ResourceUpdateEvent(
        kind: ResourceKind.proxyProvider,
        name: 'sub',
        phase: ResourcePhase.updated,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(container.read(providersProvider).single.count, 5);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a dashboard pick and mode reach the app, and the host\'s '
      'own changes are not applied twice', (tester) async {
    final harness = _harness();
    final setupAction = _ApplyRecordingSetupAction();
    final profile = Profile.normal(
      label: 'p',
    ).copyWith(selectedMap: const {'G': 'A', 'F': 'dead'});
    when(() => harness.mocks.api.general()).thenAnswer(
      (_) async => const GeneralStateDto(
        seq: 1,
        general: GeneralChange(mode: 'rule'),
        selections: {'G': 'A'},
      ),
    );
    final container = await _pumpConnected(
      tester,
      harness,
      overrides: [
        setupActionProvider.overrideWith(() => setupAction),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      ],
    );
    await tester.pump();

    harness.feeds.events.add(const [
      StateChangedEvent(
        seq: 2,
        origin: ChangeOrigin.controller,
        change: SelectedChange(group: 'G', proxy: 'B'),
      ),
      StateChangedEvent(
        seq: 3,
        origin: ChangeOrigin.core,
        change: SelectedChange(group: 'F', proxy: ''),
      ),
      StateChangedEvent(
        seq: 4,
        origin: ChangeOrigin.controller,
        change: GeneralChange(mode: 'global'),
      ),
      StateChangedEvent(
        seq: 5,
        origin: ChangeOrigin.host,
        change: SelectedChange(group: 'G', proxy: 'C'),
      ),
    ]);
    await tester.pump();

    expect(container.read(currentProfileProvider)?.selectedMap, {'G': 'B'});
    expect(container.read(patchClashConfigProvider).mode, Mode.global);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a resynced event reads the groups and providers again', (
    tester,
  ) async {
    final harness = _harness();
    final proxies = _RecordingProxiesAction();
    final container = await _pumpConnected(
      tester,
      harness,
      overrides: [proxiesActionProvider.overrideWith(() => proxies)],
    );
    when(() => harness.mocks.api.providers()).thenAnswer(
      (_) async => const [
        ProviderInfo(
          name: 'rules',
          type: ProviderKindDto.rule,
          vehicleType: 'File',
          count: 3,
          path: '',
        ),
      ],
    );

    harness.feeds.events.add(const [EventsResynced()]);
    await tester.pump();
    await tester.pump();

    expect(proxies.groupUpdates, 1);
    expect(container.read(providersProvider).map((item) => item.name), [
      'rules',
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a dialer loop event surfaces the proxy name', (tester) async {
    final harness = _harness();
    await _pumpConnected(tester, harness);

    harness.feeds.events.add(const [DialerLoopEvent('loop-node')]);
    await tester.pump();
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.dialerProxyLoopStopped('loop-node')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('services that did not start are kept until they start', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    const fault = ServiceFault(
      service: FaultService.mixed,
      address: '127.0.0.1:7890',
      reason: FaultReason.addressInUse,
      message: 'address in use',
    );

    harness.feeds.engine.add(
      const EngineStatus(state: EngineState.running, faults: [fault]),
    );
    await tester.pump();
    expect(container.read(serviceFaultsProvider), [fault]);

    harness.feeds.engine.add(const EngineStatus(state: EngineState.running));
    await tester.pump();
    expect(container.read(serviceFaultsProvider), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a TUN that does not start stays off for the run, reported '
      'once, and keeps the tun setting', (tester) async {
    final harness = _harness();
    final setupAction = _ApplyRecordingSetupAction();
    final container = await _pumpConnected(
      tester,
      harness,
      overrides: [setupActionProvider.overrideWith(() => setupAction)],
    );
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.tun(enable: true));
    await tester.pump();
    final updatesBefore = setupAction.updates;
    const failed = EngineStatus(
      state: EngineState.running,
      faults: [
        ServiceFault(
          service: FaultService.tun,
          reason: FaultReason.other,
          message: 'Start TUN listening error: no device',
        ),
      ],
    );
    final banner = find.text(
      '${currentAppLocalizations.tunStartFailed}\n'
      'Start TUN listening error: no device',
    );

    harness.feeds.engine
      ..add(failed)
      ..add(failed)
      ..add(const EngineStatus(state: EngineState.running))
      ..add(failed);
    await tester.pump();
    await tester.pump();

    expect(container.read(patchClashConfigProvider).tun.enable, isTrue);
    expect(container.read(tunDisabledThisRunProvider), isTrue);
    expect(container.read(updateParamsProvider).tun?.enable, isFalse);
    expect(setupAction.updates, updatesBefore + 1);
    expect(container.read(serviceFaultsProvider), failed.faults);
    expect(banner, findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  test('a script notification links only to a web address', () {
    expect(
      scriptNotificationLink('https://a.test/x'),
      Uri.parse('https://a.test/x'),
    );
    expect(scriptNotificationLink(''), isNull);
    expect(scriptNotificationLink('file:///etc/hosts'), isNull);
    expect(scriptNotificationLink('clash://install-config?url=x'), isNull);
    expect(scriptNotificationLink('http://[::1'), isNull);
    expect(scriptNotificationLink('https:///no-host'), isNull);
  });

  testWidgets('a burst of script notifications shows its first alone', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final harness = _harness();
    await _pumpConnected(tester, harness);
    String shown(String title) =>
        currentAppLocalizations.scriptNotification('sign', title);

    harness.feeds.events.add(const [
      ScriptNotificationEvent(script: 'sign', title: 'one'),
      ScriptNotificationEvent(script: 'sign', title: 'two'),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text(shown('one')), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(shown('two')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('geo events are forwarded to the geo resource action', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    final key = GeoResource.MMDB.updatingKey;
    final subscription = container.listen<bool>(
      isUpdatingProvider(key),
      (_, _) {},
    );
    addTearDown(subscription.close);

    harness.feeds.events.add(const [
      ResourceUpdateEvent(
        kind: ResourceKind.geo,
        name: 'MMDB',
        phase: ResourcePhase.updating,
      ),
    ]);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isTrue);

    harness.feeds.events.add(const [
      ResourceUpdateEvent(
        kind: ResourceKind.geo,
        name: 'MMDB',
        phase: ResourcePhase.failed,
        error: 'background failure',
      ),
    ]);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(find.text('background failure'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a geo update whose end the events lost stops showing as '
      'updating', (tester) async {
    final harness = _harness();
    final container = await _pumpConnected(
      tester,
      harness,
      overrides: [
        proxiesActionProvider.overrideWith(_RecordingProxiesAction.new),
      ],
    );
    final key = GeoResource.MMDB.updatingKey;
    final subscription = container.listen<bool>(
      isUpdatingProvider(key),
      (_, _) {},
    );
    addTearDown(subscription.close);
    when(() => harness.mocks.api.providers()).thenAnswer((_) async => const []);

    harness.feeds.events.add(const [
      ResourceUpdateEvent(
        kind: ResourceKind.geo,
        name: 'MMDB',
        phase: ResourcePhase.updating,
      ),
    ]);
    await tester.pump();
    expect(container.read(isUpdatingProvider(key)), isTrue);

    harness.feeds.events.add(const [EventsResynced()]);
    await tester.pump();
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('non-geo Core errors retain global notifications', (
    tester,
  ) async {
    final harness = _harness();
    final container = await _pumpConnected(tester, harness);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    harness.feeds.logs.add(const [
      LogEntry(level: 'error', time: 1, text: 'core failure'),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('core failure'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });

  group('profile switch failure', () {
    late Profile previous;
    late Profile next;
    List<Override> profileOverrides() => [
      initProvider.overrideWithBuild((_, _) => true),
      profilesProvider.overrideWith(() => TestProfiles([previous, next])),
      currentProfileIdProvider.overrideWithBuild((_, _) => previous.id),
      setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
    ];

    setUp(() {
      previous = Profile.normal(label: 'previous');
      next = Profile.normal(label: 'next');
    });

    testWidgets('keeps the selected profile when Core rejects it', (
      tester,
    ) async {
      final harness = _harness();
      var setupCalls = 0;
      when(() => _applied(harness.mocks.api)).thenAnswer((_) async {
        setupCalls++;
        throw const CoreMethodException(
          code: 'config_rejected',
          message: 'rejected',
        );
      });
      final container = await _pumpCoreManager(
        tester,
        harness.mocks.controller,
        overrides: profileOverrides(),
      );
      globalState.container = container;

      container.read(currentProfileIdProvider.notifier).value = next.id;
      await _waitForSetupToSettle(tester, () => setupCalls >= 1);

      expect(container.read(currentProfileIdProvider), next.id);
      expect(setupCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('rapid A -> B -> C settles on C even when both are rejected', (
      tester,
    ) async {
      final harness = _harness();
      var setupCalls = 0;
      when(() => _applied(harness.mocks.api)).thenAnswer((_) async {
        setupCalls++;
        throw const CoreMethodException(
          code: 'config_rejected',
          message: 'rejected',
        );
      });
      final a = Profile.normal(label: 'a');
      final b = Profile.normal(label: 'b');
      final c = Profile.normal(label: 'c');
      final container = await _pumpCoreManager(
        tester,
        harness.mocks.controller,
        overrides: [
          initProvider.overrideWithBuild((_, _) => true),
          profilesProvider.overrideWith(() => TestProfiles([a, b, c])),
          currentProfileIdProvider.overrideWithBuild((_, _) => a.id),
          setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
        ],
      );
      globalState.container = container;

      container.read(currentProfileIdProvider.notifier).value = b.id;
      container.read(currentProfileIdProvider.notifier).value = c.id;
      await _waitForSetupToSettle(tester, () => setupCalls >= 2);

      expect(container.read(currentProfileIdProvider), c.id);
      expect(setupCalls, 2);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'a missing profile id recovers to a fallback without looping when '
      'the fallback is also rejected',
      (tester) async {
        final harness = _harness();
        var setupCalls = 0;
        when(() => _applied(harness.mocks.api)).thenAnswer((_) async {
          setupCalls++;
          throw const CoreMethodException(
            code: 'config_rejected',
            message: 'rejected',
          );
        });
        const missingId = -1;
        final container = await _pumpCoreManager(
          tester,
          harness.mocks.controller,
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            profilesProvider.overrideWith(() => TestProfiles([previous])),
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
          ],
        );
        globalState.container = container;

        container.read(currentProfileIdProvider.notifier).value = missingId;
        await _waitForSetupToSettle(
          tester,
          () => container.read(currentProfileIdProvider) == previous.id,
        );

        expect(setupCalls, lessThanOrEqualTo(3));
        expect(container.read(currentProfileIdProvider), previous.id);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });
}
