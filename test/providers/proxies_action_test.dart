import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/core_mocks.dart';
import '../helpers/test_profiles.dart';

const _testUrl = 'http://delay.test';

Group _group(String name, List<Proxy> all) =>
    Group(type: GroupType.Selector, name: name, all: all);

const _proxy = Proxy(name: 'HK-01', type: 'ss');

Profile _selectedProfile(String proxyName) => Profile(
  id: 1,
  autoUpdateDuration: Duration.zero,
  selectedMap: {'Proxy': proxyName},
);

final _delayKey = delayTestKey(_testUrl, 'HK-01');

Future<DelayResult> _delayCall(MockCoreApi api, [String? proxy, String? url]) =>
    api.testDelay(
      proxy ?? any(),
      url: url ?? any(named: 'url'),
      timeout: any(named: 'timeout'),
    );

class _DelayRun {
  _DelayRun(this.names, this.url, this.timeout, this.concurrency) {
    controller = StreamController<DelayRunEvent>(
      onCancel: () => cancelled = true,
    );
  }

  final List<String> names;
  final String? url;
  final int? timeout;
  final int? concurrency;
  late final StreamController<DelayRunEvent> controller;
  bool cancelled = false;

  void result(String name, int value) => controller.add(
    DelayRunResult(DelayResult(name: name, url: url ?? '', value: value)),
  );

  void done() {
    controller.add(const DelayRunDone());
    unawaited(controller.close());
  }

  void fail(Object error) {
    controller.addError(error);
    unawaited(controller.close());
  }
}

List<_DelayRun> _stubRuns(MockCoreApi api, void Function(_DelayRun run) drive) {
  final runs = <_DelayRun>[];
  when(
    () => api.runDelays(
      any(),
      url: any(named: 'url'),
      timeout: any(named: 'timeout'),
      concurrency: any(named: 'concurrency'),
    ),
  ).thenAnswer((invocation) {
    final run = _DelayRun(
      invocation.positionalArguments[0] as List<String>,
      invocation.namedArguments[#url] as String?,
      invocation.namedArguments[#timeout] as int?,
      invocation.namedArguments[#concurrency] as int?,
    );
    runs.add(run);
    scheduleMicrotask(() => drive(run));
    return run.controller.stream;
  });
  return runs;
}

ProviderContainer _delayContainer(ProviderContainer Function() build) {
  final container = build();
  container.read(patchClashConfigProvider.notifier).value =
      const PatchClashConfig(testUrl: _testUrl);
  return container;
}

ProviderInfo _providerInfo(String name, {int count = 1}) => ProviderInfo(
  name: name,
  type: ProviderKindDto.proxy,
  vehicleType: 'HTTP',
  count: count,
  path: '',
  updatedAt: DateTime.utc(2026).millisecondsSinceEpoch,
);

ExternalProvider _provider(String name, {int count = 1}) =>
    providerOf(_providerInfo(name, count: count));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoreMocks mocks;

  setUpAll(() async {
    loadAppLocalizations(const Locale('en'));
  });

  setUp(() => mocks = coreMocks());

  ProviderContainer buildContainer({Profile? profile}) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(mocks.controller),
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  ProxiesAction actionOf(ProviderContainer container) =>
      container.read(proxiesActionProvider.notifier);

  ProviderContainer runningContainer() {
    final container = buildContainer();
    container.read(initProvider.notifier).value = true;
    container.read(runTimeProvider.notifier).value = 1;
    return container;
  }

  const proxyListing = ProxyGroupsDto(
    order: ['Proxy', 'Direct'],
    groups: [
      GroupInfo(
        name: 'Proxy',
        type: 'Selector',
        now: 'HK-01',
        all: ['HK-01'],
        testUrl: '',
        hidden: false,
        icon: '',
        emptyFallback: '',
      ),
      GroupInfo(
        name: 'Direct',
        type: 'Direct',
        testUrl: '',
        hidden: false,
        icon: '',
        emptyFallback: '',
      ),
    ],
    nodes: [NodeInfo(name: 'HK-01', type: 'ss')],
  );

  group('updateGroups', () {
    test('publishes the groups derived from core proxy data', () async {
      when(mocks.api.proxyGroups).thenAnswer((_) async => proxyListing);
      final container = buildContainer();

      await actionOf(container).updateGroups();

      final groups = container.read(groupsProvider);
      expect(groups.map((group) => group.name), ['Proxy']);
      expect(groups.single.all.map((proxy) => proxy.name), ['HK-01']);
    });

    test(
      'publishes the groups once a retry succeeds after core throws',
      () async {
        var attempt = 0;
        when(mocks.api.proxyGroups).thenAnswer((_) async {
          attempt++;
          if (attempt == 1) {
            throw StateError('core down');
          }
          return proxyListing;
        });
        final container = buildContainer();

        await actionOf(container).updateGroups();

        final groups = container.read(groupsProvider);
        expect(groups.map((group) => group.name), ['Proxy']);
        verify(mocks.api.proxyGroups).called(2);
      },
    );

    test(
      'clears the groups once retry is exhausted after core throws',
      () async {
        when(mocks.api.proxyGroups).thenThrow(StateError('core down'));
        final container = buildContainer();
        container.read(groupsProvider.notifier).value = [
          _group('Stale', const []),
        ];

        await actionOf(container).updateGroups();

        expect(container.read(groupsProvider), isEmpty);
        verify(mocks.api.proxyGroups).called(3);
      },
    );

    test('a core status change alone does not clear the groups', () {
      final container = buildContainer();
      actionOf(container);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(groupsProvider.notifier).value = [
        _group('Stale', const []),
      ];

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;

      expect(container.read(groupsProvider).map((group) => group.name), [
        'Stale',
      ]);
    });
  });

  group('changeProxy', () {
    setUp(() {
      when(
        () => mocks.api.selectProxy(any(), any()),
      ).thenAnswer((_) async => (changed: true, seq: 1));
      when(mocks.api.closeConnections).thenAnswer((_) async {});
      when(mocks.api.resetNetwork).thenAnswer((_) async {});
    });

    test('closes connections when enabled', () async {
      final container = runningContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: true,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verify(() => mocks.api.selectProxy('Proxy', 'HK-01')).called(1);
      verify(mocks.api.closeConnections).called(1);
      verifyNever(mocks.api.resetNetwork);
    });

    test('resets connections instead when the setting is off', () async {
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: false,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verify(mocks.api.resetNetwork).called(1);
      verifyNever(mocks.api.closeConnections);
    });

    test('a failing connection reset does not fail the switch', () async {
      when(mocks.api.closeConnections).thenThrow(
        const CoreMethodException(
          code: 'transport_disconnected',
          message: 'Core RPC client is closed',
        ),
      );
      final container = buildContainer(profile: _selectedProfile('HK-00'));
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: true,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verify(mocks.api.closeConnections).called(1);
      expect(container.read(currentProfileProvider)?.selectedMap, {
        'Proxy': 'HK-01',
      });
      expect(container.read(routeTrackerProvider).picks, 1);
    });

    test('skips the connection reset when the switch itself fails', () async {
      when(
        () => mocks.api.selectProxy(any(), any()),
      ).thenThrow(StateError('core down'));
      final container = runningContainer();

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verifyNever(mocks.api.closeConnections);
      verifyNever(mocks.api.resetNetwork);
    });

    test(
      'skips the connection reset when the Core reports no change',
      () async {
        when(
          () => mocks.api.selectProxy(any(), any()),
        ).thenAnswer((_) async => (changed: false, seq: 1));
        final container = runningContainer();

        await actionOf(
          container,
        ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

        verifyNever(mocks.api.closeConnections);
        verifyNever(mocks.api.resetNetwork);
        expect(container.read(routeTrackerProvider).picks, 0);
      },
    );

    test('rolls the selection back when the Core refuses the switch', () async {
      when(() => mocks.api.selectProxy(any(), any())).thenThrow(
        const CoreMethodException(
          code: 'not_found',
          message: 'proxy not exist',
        ),
      );
      final container = buildContainer(profile: _selectedProfile('HK-00'));

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verifyNever(mocks.api.closeConnections);
      expect(container.read(currentProfileProvider)?.selectedMap, {
        'Proxy': 'HK-00',
      });
    });

    test('commits the selection the Core accepted', () async {
      final container = buildContainer(profile: _selectedProfile('HK-00'));

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      expect(container.read(currentProfileProvider)?.selectedMap, {
        'Proxy': 'HK-01',
      });
    });

    test('rolls the selection back when the switch fails', () async {
      when(
        () => mocks.api.selectProxy(any(), any()),
      ).thenThrow(StateError('core down'));
      final container = buildContainer(profile: _selectedProfile('HK-00'));

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      expect(container.read(currentProfileProvider)?.selectedMap, {
        'Proxy': 'HK-00',
      });
    });

    test(
      'rolls back to the last selection the Core applied, not the last tap',
      () async {
        when(
          () => mocks.api.selectProxy(any(), any()),
        ).thenThrow(StateError('core down'));
        final container = buildContainer(profile: _selectedProfile('HK-00'));
        final action = actionOf(container);

        action.changeProxyDebounce('Proxy', 'HK-01');
        action.changeProxyDebounce('Proxy', 'HK-02');
        expect(container.read(currentProfileProvider)?.selectedMap, {
          'Proxy': 'HK-02',
        });

        await action.changeProxy(groupName: 'Proxy', proxyName: 'HK-02');

        expect(container.read(currentProfileProvider)?.selectedMap, {
          'Proxy': 'HK-00',
        });
        debouncer.cancel((FunctionTag.changeProxy, 'Proxy'));
      },
    );
  });

  group('proxyDelayTest', () {
    test('marks the node pending while it runs, then records it', () async {
      late ProviderContainer container;
      final observed = <bool>[];
      when(() => _delayCall(mocks.api, 'HK-01', _testUrl)).thenAnswer((
        _,
      ) async {
        observed.add(
          container.read(pendingDelayTestsProvider).containsKey(_delayKey),
        );
        return const DelayResult(name: 'HK-01', url: _testUrl, value: 128);
      });
      container = _delayContainer(buildContainer);

      await actionOf(container).proxyDelayTest(_proxy);

      expect(observed, [true]);
      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], 128);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('keeps the last measurement when the Core does not answer', () async {
      when(
        () => _delayCall(mocks.api, 'HK-01', _testUrl),
      ).thenThrow(TimeoutException('no answer'));
      final container = _delayContainer(buildContainer);
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(const Delay(name: 'HK-01', url: _testUrl, value: 42));

      await actionOf(container).proxyDelayTest(_proxy);

      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], 42);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('falls back to untested when a throwing call had no value', () async {
      when(
        () => _delayCall(mocks.api, 'HK-01', _testUrl),
      ).thenThrow(StateError('channel is gone'));
      final container = _delayContainer(buildContainer);

      await actionOf(container).proxyDelayTest(_proxy);

      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], null);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('does nothing when the resolved proxy name is empty', () async {
      final container = buildContainer();

      await actionOf(container).proxyDelayTest(const Proxy(name: '', type: ''));

      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      verifyNever(() => _delayCall(mocks.api));
    });
  });

  group('delayTest', () {
    test('measures every proxy and bumps the sort counter', () async {
      _stubRuns(mocks.api, (run) {
        for (final name in run.names) {
          run.result(name, 10);
        }
        run.done();
      });
      final container = _delayContainer(buildContainer);
      final before = container.read(sortNumProvider);

      await actionOf(
        container,
      ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);

      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?['HK-01'], 10);
      expect(delays?['HK-02'], 10);
      expect(container.read(sortNumProvider), before + 1);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('lands a run of quick results in batches, not one per node', () async {
      _stubRuns(mocks.api, (run) {
        for (final name in run.names) {
          run.result(name, 10);
        }
        run.done();
      });
      final container = _delayContainer(buildContainer);
      var delayChanges = 0;
      var pendingChanges = 0;
      container.listen(delayDataSourceProvider, (_, _) => delayChanges++);
      container.listen(pendingDelayTestsProvider, (_, _) => pendingChanges++);
      final proxies = List.generate(
        1000,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(
        container.read(delayDataSourceProvider)[_testUrl],
        hasLength(1000),
      );
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      expect(delayChanges, 1);
      expect(pendingChanges, lessThanOrEqualTo(4));
    });

    test(
      'marks only the first wave of nodes as running, the rest queued',
      () async {
        final runs = _stubRuns(mocks.api, (_) {});
        final container = _delayContainer(buildContainer);
        final proxies = List.generate(
          maxConcurrentDelayTests + 1,
          (index) => Proxy(name: 'HK-$index', type: 'ss'),
        );
        DelayTestPhase? phaseOf(int index) => container.read(
          pendingDelayTestsProvider,
        )[delayTestKey(_testUrl, 'HK-$index')];

        final run = actionOf(container).delayTest(proxies);
        await Future<void>.delayed(Duration.zero);

        expect(phaseOf(0), DelayTestPhase.running);
        expect(phaseOf(maxConcurrentDelayTests - 1), DelayTestPhase.running);
        expect(phaseOf(maxConcurrentDelayTests), DelayTestPhase.queued);

        runs.single.result('HK-0', 10);
        await Future<void>.delayed(renderThrottleDuration * 2);

        expect(phaseOf(0), isNull);
        expect(phaseOf(maxConcurrentDelayTests), DelayTestPhase.running);

        runs.single.done();
        await run;

        expect(container.read(pendingDelayTestsProvider), isEmpty);
      },
    );

    test('asks for the width and the timeout the settings give', () async {
      final runs = _stubRuns(mocks.api, (run) {
        run.done();
      });
      final container = _delayContainer(buildContainer);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(delayTestTimeout: 2000));

      await actionOf(
        container,
      ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);

      expect(runs.single.names, ['HK-01', 'HK-02']);
      expect(runs.single.url, _testUrl);
      expect(runs.single.timeout, 2000);
      expect(runs.single.concurrency, 2);
    });

    test('probes a node that appears twice only once', () async {
      when(() => _delayCall(mocks.api, 'HK-01', _testUrl)).thenAnswer(
        (_) async => const DelayResult(name: 'HK-01', url: _testUrl, value: 10),
      );
      final container = _delayContainer(buildContainer);

      await actionOf(container).delayTest(const [_proxy, _proxy]);

      verify(() => _delayCall(mocks.api, 'HK-01', _testUrl)).called(1);
    });

    test('a single proxy is one delay.test with the timeout setting', () async {
      when(() => _delayCall(mocks.api, 'HK-01', _testUrl)).thenAnswer(
        (_) async => const DelayResult(name: 'HK-01', url: _testUrl, value: 10),
      );
      final container = _delayContainer(buildContainer);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(delayTestTimeout: 2000));

      await actionOf(container).delayTest(const [_proxy]);

      verify(
        () => mocks.api.testDelay('HK-01', url: _testUrl, timeout: 2000),
      ).called(1);
    });

    test('testing groups runs a shared node once per test URL', () async {
      const otherUrl = 'http://other.test';
      final runs = _stubRuns(mocks.api, (run) {
        for (final name in run.names) {
          run.result(name, 10);
        }
        run.done();
      });
      final container = _delayContainer(buildContainer);
      final before = container.read(sortNumProvider);

      await actionOf(container).delayTestGroups([
        _group('A', const [_proxy]),
        _group('B', const [_proxy, Proxy(name: 'HK-02', type: 'ss')]),
        const Group(
          type: GroupType.URLTest,
          name: 'C',
          testUrl: otherUrl,
          all: [_proxy],
        ),
      ]);

      expect(
        [for (final run in runs) '${run.url} ${run.names.join(',')}'],
        ['$_testUrl HK-01,HK-02', '$otherUrl HK-01'],
      );
      expect(container.read(sortNumProvider), before + 1);
    });

    test('runs from two jobs do not overlap', () async {
      final runs = _stubRuns(mocks.api, (_) {});
      final container = _delayContainer(buildContainer);
      final action = actionOf(container);

      final first = action.delayTest(const [
        _proxy,
        Proxy(name: 'HK-02', type: 'ss'),
      ]);
      final second = action.delayTest(const [
        Proxy(name: 'JP-01', type: 'ss'),
        Proxy(name: 'JP-02', type: 'ss'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(runs, hasLength(1));
      runs.single.done();
      await first;
      await Future<void>.delayed(Duration.zero);
      expect(runs, hasLength(2));
      runs.last.done();
      await second;
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test(
      'testing a page group probes the nodes the timeout filter hides',
      () async {
        final runs = _stubRuns(mocks.api, (run) {
          run.done();
        });
        final container = _delayContainer(buildContainer);
        container
            .read(groupsProvider.notifier)
            .update(
              (_) => [
                _group('Proxy', const [
                  _proxy,
                  Proxy(name: 'HK-02', type: 'ss'),
                  Proxy(name: 'JP-01', type: 'ss'),
                ]),
              ],
            );
        container
            .read(delayDataSourceProvider.notifier)
            .setDelay(const Delay(url: _testUrl, name: 'HK-02', value: -1));
        container
            .read(proxiesStyleSettingProvider.notifier)
            .update((state) => state.copyWith(hideTimeoutProxies: true));
        container.read(queryProvider(QueryTag.proxies).notifier).value = 'HK';

        await actionOf(container).delayTestPageGroup('Proxy');

        expect(runs.single.names, ['HK-01', 'HK-02']);
      },
    );

    test(
      'a group tested away from the proxies page ignores its search',
      () async {
        final runs = _stubRuns(mocks.api, (run) {
          run.done();
        });
        final container = _delayContainer(buildContainer);
        container
            .read(groupsProvider.notifier)
            .update(
              (_) => [
                _group('Proxy', const [
                  _proxy,
                  Proxy(name: 'JP-01', type: 'ss'),
                ]),
              ],
            );
        container.listen(queryProvider(QueryTag.proxies), (_, _) {});
        container.read(queryProvider(QueryTag.proxies).notifier).value = 'HK';

        await actionOf(
          container,
        ).delayTestPageGroup('Proxy', matchSearch: false);

        expect(runs.single.names, ['HK-01', 'JP-01']);
      },
    );

    test('a page group holds its testing mark until the run settles', () async {
      final release = Completer<DelayResult>();
      when(
        () => _delayCall(mocks.api, 'HK-01', _testUrl),
      ).thenAnswer((_) => release.future);
      final container = _delayContainer(buildContainer);
      container
          .read(groupsProvider.notifier)
          .update(
            (_) => [
              _group('Proxy', const [_proxy]),
            ],
          );

      final run = actionOf(container).delayTestPageGroup('Proxy');
      await actionOf(container).delayTestPageGroup('Proxy');

      expect(container.read(delayTestingGroupsProvider), {'Proxy'});
      release.completeError(
        const CoreMethodException(code: 'internal_error', message: 'boom'),
      );
      await run;

      verify(() => _delayCall(mocks.api, 'HK-01', _testUrl)).called(1);
      expect(container.read(delayTestingGroupsProvider), isEmpty);
    });

    test('stops the run once the transport is gone', () async {
      final runs = _stubRuns(mocks.api, (run) {
        run.fail(
          const CoreMethodException(
            code: 'transport_disconnected',
            message: 'the Core is gone',
          ),
        );
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        maxConcurrentDelayTests * 3,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(runs, hasLength(1));
      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test(
      'a run that fails halfway keeps what it had and drops the rest',
      () async {
        _stubRuns(mocks.api, (run) {
          for (final name in run.names.take(3)) {
            run.result(name, 10);
          }
          run.fail(
            const CoreMethodException(code: 'internal', message: 'boom'),
          );
        });
        final container = _delayContainer(buildContainer);
        final proxies = List.generate(
          8,
          (index) => Proxy(name: 'HK-$index', type: 'ss'),
        );

        await actionOf(container).delayTest(proxies);

        final delays = container.read(delayDataSourceProvider)[_testUrl];
        expect(delays?.keys, ['HK-0', 'HK-1', 'HK-2']);
        expect(container.read(pendingDelayTestsProvider), isEmpty);
      },
    );

    test(
      'a failure the Core reports for a node is stored as its delay',
      () async {
        _stubRuns(mocks.api, (run) {
          run.result('HK-01', -2);
          run.result('HK-02', -1);
          run.done();
        });
        final container = _delayContainer(buildContainer);

        await actionOf(
          container,
        ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);

        final delays = container.read(delayDataSourceProvider)[_testUrl];
        expect(delays, {'HK-01': -2, 'HK-02': -1});
      },
    );

    test('cancelling stops the Core run and drops every spinner', () async {
      final runs = _stubRuns(mocks.api, (_) {});
      final container = _delayContainer(buildContainer);
      final action = actionOf(container);

      final run = action.delayTest(const [
        _proxy,
        Proxy(name: 'HK-02', type: 'ss'),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(pendingDelayTestsProvider), isNotEmpty);

      action.cancelDelayTests();
      await run;

      expect(runs.single.cancelled, isTrue);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      expect(container.read(delayDataSourceProvider), isEmpty);
    });

    test('drops every spinner when the Core goes away mid-run', () async {
      final runs = _stubRuns(mocks.api, (_) {});
      final container = _delayContainer(buildContainer);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      final run = actionOf(
        container,
      ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(pendingDelayTestsProvider), isNotEmpty);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      await run;

      expect(runs.single.cancelled, isTrue);
      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });
  });

  group('updateProvider', () {
    test(
      'stores the refreshed provider and clears the updating flag',
      () async {
        final refreshedInfo = _providerInfo('geo', count: 5);
        final refreshed = providerOf(refreshedInfo);
        final release = Completer<void>();
        when(
          () => mocks.api.updateProvider('geo'),
        ).thenAnswer((_) => release.future);
        when(
          () => mocks.api.provider('geo'),
        ).thenAnswer((_) async => refreshedInfo);
        final container = buildContainer();
        container.read(providersProvider.notifier).value = [_provider('geo')];

        final update = actionOf(
          container,
        ).updateProvider(_provider('geo'), showLoading: true);

        expect(container.read(isUpdatingProvider('provider_geo')), isTrue);

        release.complete();
        await update;

        expect(container.read(providersProvider), [refreshed]);
        expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
      },
    );

    testWidgets('the stale sweep does not interrupt the provider update', (
      tester,
    ) async {
      final refreshedInfo = _providerInfo('geo', count: 8);
      final refreshed = providerOf(refreshedInfo);
      final release = Completer<void>();
      when(
        () => mocks.api.updateProvider('geo'),
      ).thenAnswer((_) => release.future);
      when(
        () => mocks.api.provider('geo'),
      ).thenAnswer((_) async => refreshedInfo);
      final container = buildContainer();
      container.read(updatingActionProvider.notifier);
      container.read(providersProvider.notifier).value = [_provider('geo')];

      final update = actionOf(
        container,
      ).updateProvider(_provider('geo'), showLoading: true);

      await tester.pump(updatingStaleTimeout + updatingSweepInterval);

      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);

      release.complete();

      await update;
      expect(container.read(providersProvider), [refreshed]);

      await tester.pump(Duration.zero);
    });

    testWidgets('a core disconnect clears the provider updating state', (
      tester,
    ) async {
      final release = Completer<void>();
      when(
        () => mocks.api.updateProvider('geo'),
      ).thenAnswer((_) => release.future);
      when(
        () => mocks.api.provider('geo'),
      ).thenAnswer((_) async => _providerInfo('geo'));
      final container = buildContainer();
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      final update = actionOf(
        container,
      ).updateProvider(_provider('geo'), showLoading: true);

      expect(container.read(isUpdatingProvider('provider_geo')), isTrue);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      await tester.pump();

      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);

      release.complete();
      await update;
      await tester.pump(Duration.zero);
    });

    test('surfaces the core error without storing a provider', () async {
      when(() => mocks.api.updateProvider('geo')).thenThrow(
        const CoreMethodException(code: 'rejected', message: 'update failed'),
      );
      final container = buildContainer();

      await expectLater(
        actionOf(container).updateProvider(_provider('geo'), showLoading: true),
        throwsA(isA<CoreMethodException>()),
      );

      expect(container.read(providersProvider), isEmpty);
      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
      verifyNever(() => mocks.api.provider(any()));
    });

    test('clears the updating flag when core throws', () async {
      when(() => mocks.api.updateProvider('geo')).thenThrow(StateError('boom'));
      final container = buildContainer();

      await expectLater(
        actionOf(container).updateProvider(_provider('geo'), showLoading: true),
        throwsStateError,
      );

      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
    });
  });

  group('sideLoadExternalProvider', () {
    test('stores the provider after a successful side load', () async {
      final refreshedInfo = _providerInfo('rules', count: 3);
      final refreshed = providerOf(refreshedInfo);
      final release = Completer<void>();
      when(
        () => mocks.api.sideLoadProvider('rules', 'payload'),
      ).thenAnswer((_) => release.future);
      when(
        () => mocks.api.provider('rules'),
      ).thenAnswer((_) async => refreshedInfo);
      final container = buildContainer();
      container.read(providersProvider.notifier).value = [_provider('rules')];

      final sideLoad = actionOf(container).sideLoadExternalProvider(
        _provider('rules'),
        'payload',
        showLoading: true,
      );

      expect(container.read(isUpdatingProvider('provider_rules')), isTrue);

      release.complete();
      await sideLoad;

      expect(container.read(providersProvider), [refreshed]);
      expect(container.read(isUpdatingProvider('provider_rules')), isFalse);
    });

    test('surfaces the core error and skips the refresh', () async {
      when(() => mocks.api.sideLoadProvider('rules', 'bad')).thenThrow(
        const CoreMethodException(code: 'rejected', message: 'invalid payload'),
      );
      final container = buildContainer();

      await expectLater(
        actionOf(container).sideLoadExternalProvider(_provider('rules'), 'bad'),
        throwsA(isA<CoreMethodException>()),
      );
      verifyNever(() => mocks.api.provider(any()));
    });
  });

  group('addToLocalProxies', () {
    const hongKong = CustomProxy(
      id: 5,
      definition: {'name': 'HK', 'type': 'ss', 'server': 'hk.example.com'},
    );

    late db.Database testDatabase;

    setUp(() async {
      testDatabase = db.Database(NativeDatabase.memory());
      db.database = testDatabase;
      await testDatabase.customProxies.put(hongKong.toCompanion('a0'));
    });

    tearDown(() => testDatabase.close());

    test(
      'adds the running proxy after the app proxies, without its dialer',
      () async {
        when(() => mocks.api.proxyDefinition('SG')).thenAnswer(
          (_) async => {
            'name': 'SG',
            'type': 'ss',
            'server': 'sg.example.com',
            'dialer-proxy': 'Relay',
          },
        );

        await actionOf(buildContainer()).addToLocalProxies('SG');

        final proxies = await testDatabase.customProxiesDao.query().get();
        expect([for (final proxy in proxies) proxy.name], ['HK', 'SG']);
        expect(proxies.last.definition, {
          'name': 'SG',
          'type': 'ss',
          'server': 'sg.example.com',
        });
      },
    );

    test('adds nothing for a proxy an app proxy already holds', () async {
      when(
        () => mocks.api.proxyDefinition('Hong Kong'),
      ).thenAnswer((_) async => {...hongKong.definition, 'name': 'Hong Kong'});

      await actionOf(buildContainer()).addToLocalProxies('Hong Kong');

      expect(await testDatabase.customProxiesDao.query().get(), [
        hongKong.copyWith(order: 'a0'),
      ]);
    });

    test('names a proxy the running config does not define', () async {
      when(
        () => mocks.api.proxyDefinition('Gone'),
      ).thenAnswer((_) async => null);

      await expectLater(
        actionOf(buildContainer()).addToLocalProxies('Gone'),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.customIssueMissingProxies('Gone'),
          ),
        ),
      );
    });
  });

  group('current profile mutations', () {
    test('updateCurrentGroupName writes the new group onto the profile', () {
      final profile = Profile.normal(label: 'p');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentGroupName('Proxy');

      expect(container.read(profilesProvider).single.currentGroupName, 'Proxy');
    });

    test('updateCurrentGroupName is a no-op for the same group', () {
      final profile = Profile.normal(
        label: 'p',
      ).copyWith(currentGroupName: 'Proxy');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentGroupName('Proxy');

      expect(container.read(profilesProvider).single, same(profile));
    });

    test('updateCurrentUnfoldSet is a no-op without a current profile', () {
      final container = buildContainer();

      expect(
        () => actionOf(container).updateCurrentUnfoldSet({'Proxy'}),
        returnsNormally,
      );
      expect(container.read(profilesProvider), isEmpty);
    });

    test('updateCurrentUnfoldSet stores the set on the current profile', () {
      final profile = Profile.normal(label: 'p');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentUnfoldSet({'Proxy', 'Auto'});

      expect(container.read(profilesProvider).single.unfoldSet, {
        'Proxy',
        'Auto',
      });
    });
  });
}
