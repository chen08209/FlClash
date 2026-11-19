import 'package:fl_clash/common/fixed.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/core_mocks.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('the rules in force are listed again each time the Core connects, '
      'and kept while it is away', () async {
    final mocks = coreMocks();
    var calls = 0;
    when(mocks.api.ruleList).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? throw StateError('stopped')
          : {
              'rules': [
                {'type': 'MATCH', 'payload': '', 'target': 'DIRECT'},
              ],
            };
    });
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.test(mocks.backend),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(activeRulesProvider, (_, _) {}, onError: (_, _) {});
    final status = container.read(coreStatusProvider.notifier);

    await expectLater(
      container.read(activeRulesProvider.future),
      throwsStateError,
    );
    status.value = CoreStatus.connecting;
    status.value = CoreStatus.connected;
    final rules = await container.read(activeRulesProvider.future);
    expect(rules.holds(0, type: 'MATCH', payload: ''), isTrue);

    status.value = CoreStatus.disconnected;
    await Future<void>.delayed(Duration.zero);
    expect(container.read(activeRulesProvider).value, same(rules));
    expect(calls, 2);
  });

  group('AuthorizedTunEnable provider', () {
    test('default is none', () {
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
    });

    test('can store authorized and unauthorized results', () {
      final notifier = container.read(authorizedTunEnableProvider.notifier);
      notifier.update((_) => TunAuthorizationState.authorized);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.authorized,
      );
      notifier.update((_) => TunAuthorizationState.unauthorized);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.unauthorized,
      );
    });
  });

  group('Packages provider', () {
    test('default is empty list', () {
      expect(container.read(packagesProvider), isEmpty);
    });

    test('can update state', () {
      const pkg = Package(
        packageName: 'test.app',
        label: 'Test App',
        system: false,
        internet: true,
        lastUpdateTime: 0,
      );
      container.read(packagesProvider.notifier).update((_) => [pkg]);
      expect(container.read(packagesProvider).length, 1);
      expect(container.read(packagesProvider).first.packageName, 'test.app');
    });
  });

  group('Providers provider', () {
    test('setProvider replaces provider with matching name', () {
      final oldProvider = ExternalProvider(
        name: 'Proxy',
        type: 'Proxy',
        count: 1,
        vehicleType: 'HTTP',
        updateAt: DateTime(2026),
      );
      final newProvider = oldProvider.copyWith(count: 2);
      container.read(providersProvider.notifier).update((_) => [oldProvider]);

      container.read(providersProvider.notifier).setProvider(newProvider);

      expect(container.read(providersProvider).single.count, 2);
    });

    test('setProvider ignores null and missing provider names', () {
      final provider = ExternalProvider(
        name: 'Proxy',
        type: 'Proxy',
        count: 1,
        vehicleType: 'HTTP',
        updateAt: DateTime(2026),
      );
      container.read(providersProvider.notifier).update((_) => [provider]);

      container.read(providersProvider.notifier).setProvider(null);
      container
          .read(providersProvider.notifier)
          .setProvider(provider.copyWith(name: 'Other', count: 9));

      expect(container.read(providersProvider).single, provider);
    });
  });

  group('SystemBrightness provider', () {
    test('default is dark', () {
      expect(container.read(systemBrightnessProvider), Brightness.dark);
    });

    test('can update to light', () {
      container
          .read(systemBrightnessProvider.notifier)
          .update((_) => Brightness.light);
      expect(container.read(systemBrightnessProvider), Brightness.light);
    });
  });

  group('LocalIp provider', () {
    test('default is null', () {
      expect(container.read(localIpProvider), null);
    });

    test('can set IP', () {
      container.read(localIpProvider.notifier).update((_) => '192.168.1.1');
      expect(container.read(localIpProvider), '192.168.1.1');
    });
  });

  group('RunTime provider', () {
    test('default is null', () {
      expect(container.read(runTimeProvider), null);
    });

    test('can set runtime', () {
      container.read(runTimeProvider.notifier).update((_) => 3600);
      expect(container.read(runTimeProvider), 3600);
    });
  });

  group('ViewSize provider', () {
    test('default is zero', () {
      expect(container.read(viewSizeProvider), Size.zero);
    });

    test('can update size', () {
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(800, 600));
      final value = container.read(viewSizeProvider);
      expect(value.width, 800);
      expect(value.height, 600);
    });
  });

  group('SideWidth provider', () {
    test('default is 0', () {
      expect(container.read(sideWidthProvider), 0.0);
    });

    test('can update side width', () {
      container.read(sideWidthProvider.notifier).update((_) => 300.0);
      expect(container.read(sideWidthProvider), 300.0);
    });
  });

  group('viewWidth provider (derived)', () {
    test('derives from viewSize width', () {
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(800, 600));
      expect(container.read(viewWidthProvider), 800);
    });
  });

  group('Init provider', () {
    test('default is false', () {
      expect(container.read(initProvider), false);
    });

    test('can update to true', () {
      container.read(initProvider.notifier).update((_) => true);
      expect(container.read(initProvider), true);
    });
  });

  group('CurrentPageLabel provider', () {
    test('default is dashboard', () {
      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
    });

    test('toPage changes page', () {
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.proxies);
      expect(container.read(currentPageLabelProvider), PageLabel.proxies);
    });

    test('toProfiles changes page', () {
      container.read(currentPageLabelProvider.notifier).toProfiles();
      expect(container.read(currentPageLabelProvider), PageLabel.profiles);
    });
  });

  group('SortNum provider', () {
    test('default is 0', () {
      expect(container.read(sortNumProvider), 0);
    });

    test('can update', () {
      container.read(sortNumProvider.notifier).update((_) => 5);
      expect(container.read(sortNumProvider), 5);
    });
  });

  group('Version provider', () {
    test('default is 0', () {
      expect(container.read(versionProvider), 0);
    });

    test('can set version', () {
      container.read(versionProvider.notifier).update((_) => 3);
      expect(container.read(versionProvider), 3);
    });
  });

  group('Groups provider', () {
    test('default is empty', () {
      expect(container.read(groupsProvider), isEmpty);
    });

    test('can set groups', () {
      final groups = [
        const Group(name: 'G1', type: GroupType.Selector, now: 'auto'),
      ];
      container.read(groupsProvider.notifier).update((_) => groups);
      expect(container.read(groupsProvider).length, 1);
      expect(container.read(groupsProvider).first.name, 'G1');
    });
  });

  group('TotalTraffic provider', () {
    test('default is empty Traffic', () {
      final t = container.read(totalTrafficProvider);
      expect(t.up, 0);
      expect(t.down, 0);
    });
  });

  group('append-backed buffers notify on every arrival', () {
    test('Logs.add advances the generation and reaches listeners', () {
      container.read(logsProvider.notifier).value = FixedList(3);
      final revisions = <int>[];
      final subscription = container.listen(
        logsProvider.select((state) => state.revision),
        (_, next) => revisions.add(next),
      );
      addTearDown(subscription.close);

      final notifier = container.read(logsProvider.notifier);
      notifier.add(Log.app('a'));
      notifier.add(Log.app('b'));

      expect(revisions.length, 2, reason: 'one notification per log line');
      expect(container.read(logsProvider).list.map((log) => log.payload), [
        'a',
        'b',
      ]);
    });

    test('Requests.addRequest reaches listeners', () {
      container.read(requestsProvider.notifier).value = ConnectionLog(3);
      var notifications = 0;
      final subscription = container.listen(
        requestsProvider.select((state) => state.revision),
        (_, _) => notifications++,
      );
      addTearDown(subscription.close);

      container.read(requestsProvider.notifier).addRequests([
        TrackerInfo(
          id: 1,
          start: DateTime.utc(2026),
          metadata: const Metadata(network: 'tcp', host: 'example.com'),
          chains: const ['Proxy'],
          rule: 'DOMAIN',
          rulePayload: 'example.com',
        ),
      ]);

      expect(notifications, 1);
      expect(container.read(requestsProvider).length, 1);
    });

    test('Requests.updateTraffic updates the requests it names', () {
      TrackerInfo request(int id) => TrackerInfo(
        id: id,
        upload: 460,
        start: DateTime.utc(2026),
        metadata: const Metadata(network: 'tcp', host: 'example.com'),
        chains: const ['Proxy'],
        rule: 'DOMAIN',
        rulePayload: 'example.com',
      );
      final notifier = container.read(requestsProvider.notifier);
      notifier.value = ConnectionLog(3);
      notifier.addRequests([request(1)]);
      notifier.addRequests([request(2)]);
      var notifications = 0;
      final subscription = container.listen(
        requestsProvider.select((state) => state.revision),
        (_, _) => notifications++,
      );
      addTearDown(subscription.close);

      notifier.updateTraffic({99: (upload: 1, download: 1)});
      expect(notifications, 0);

      notifier.updateTraffic({
        1: (upload: 520, download: 257835),
        99: (upload: 1, download: 1),
      });

      expect(notifications, 1);
      expect(
        container
            .read(requestsProvider)
            .list
            .map((request) => (request.id, request.upload, request.download)),
        [(1, 520, 257835), (2, 460, 0)],
      );
    });

    test('Requests notifies once per close, sync and closeAll that changes '
        'the log, and not for one that changes nothing', () {
      TrackerInfo request(int id, int second) => TrackerInfo(
        id: id,
        start: DateTime.utc(2026).add(Duration(seconds: second)),
        metadata: const Metadata(network: 'tcp', host: 'example.com'),
        chains: const ['Proxy'],
        rule: 'DOMAIN',
        rulePayload: 'example.com',
      );
      final notifier = container.read(requestsProvider.notifier);
      notifier.value = ConnectionLog(3);
      notifier.addRequests([request(1, 0)]);
      notifier.addRequests([request(2, 1)]);
      notifier.addRequests([request(3, 2)]);
      var notifications = 0;
      final subscription = container.listen(
        requestsProvider.select((state) => state.revision),
        (_, _) => notifications++,
      );
      addTearDown(subscription.close);
      final later = DateTime.utc(2026, 1, 2);

      notifier.close([1], at: later);
      expect(notifications, 1);
      notifier.close([1, 99], at: later);
      expect(notifications, 1);

      notifier.sync(
        [request(3, 2)],
        requestedAt: later,
        lineage: container.read(requestsProvider).lineage,
      );
      expect(notifications, 2);
      expect(container.read(requestsProvider)[2]!.closedAt, later);
      notifier.sync(
        [request(3, 2)],
        requestedAt: later,
        lineage: container.read(requestsProvider).lineage,
      );
      expect(notifications, 2);

      notifier.closeAll(at: later);
      expect(notifications, 3);
      notifier.closeAll(at: later);
      expect(notifications, 3);
      expect(container.read(requestsProvider).activeCount, 0);
    });

    test('Traffics.addTraffic reaches listeners and clear resets', () {
      container.read(trafficsProvider.notifier).value = FixedList(3);
      var notifications = 0;
      final subscription = container.listen(
        trafficsProvider,
        (_, _) => notifications++,
      );
      addTearDown(subscription.close);

      final notifier = container.read(trafficsProvider.notifier);
      notifier.addTraffic(const Traffic(up: 1, down: 2));
      notifier.addTraffic(const Traffic(up: 3, down: 4));
      expect(notifications, 2);

      notifier.clear();
      expect(notifications, 3);
      expect(container.read(trafficsProvider).length, 0);
    });
  });

  group('SortNum provider', () {
    test('increment returns previous value and updates state', () {
      final value = container.read(sortNumProvider.notifier).add();

      expect(value, 0);
      expect(container.read(sortNumProvider), 1);
    });
  });

  group('DelayDataSource provider', () {
    test('sets delay by url and proxy name', () {
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(
            const Delay(name: 'Proxy', url: 'https://test.example', value: 120),
          );

      expect(container.read(delayDataSourceProvider), {
        'https://test.example': {'Proxy': 120},
      });
    });

    test('keeps same state instance when delay value is unchanged', () {
      final notifier = container.read(delayDataSourceProvider.notifier);
      const delay = Delay(name: 'Proxy', url: 'https://test.example', value: 1);
      notifier.setDelay(delay);
      final state = container.read(delayDataSourceProvider);

      notifier.setDelay(delay);

      expect(identical(container.read(delayDataSourceProvider), state), isTrue);
    });

    test('a reset of the state is not undone by the next delay', () {
      const url = 'https://test.example';
      final notifier = container.read(delayDataSourceProvider.notifier);
      notifier.setDelay(const Delay(name: 'A', url: url, value: 10));

      notifier.value = {};
      notifier.setDelay(const Delay(name: 'B', url: url, value: 20));

      expect(container.read(delayDataSourceProvider), {
        url: {'B': 20},
      });
    });

    test('applies a batch of delays as one state change', () {
      const url = 'https://test.example';
      final changes = <DelayMap>[];
      container.listen(delayDataSourceProvider, (_, next) => changes.add(next));

      container.read(delayDataSourceProvider.notifier).setDelays([
        const Delay(name: 'A', url: url, value: 10),
        const Delay(name: 'B', url: url, value: -1),
        const Delay(name: 'A', url: url, value: 20),
        const Delay(name: 'A', url: 'https://other.example', value: 30),
      ]);

      expect(changes, [
        {
          url: {'A': 20, 'B': -1},
          'https://other.example': {'A': 30},
        },
      ]);
    });
  });

  group('Loading provider', () {
    test('stop without start sets loading false immediately', () async {
      final notifier = container.read(
        loadingProvider(LoadingTag.profiles).notifier,
      );

      await notifier.stop();

      expect(container.read(loadingProvider(LoadingTag.profiles)), false);
    });

    test('stop keeps loading visible for minimum duration', () async {
      final notifier = container.read(
        loadingProvider(LoadingTag.profiles).notifier,
      );

      notifier.start();
      await notifier.stop();

      expect(container.read(loadingProvider(LoadingTag.profiles)), true);

      await Future.delayed(const Duration(milliseconds: 1100));

      expect(container.read(loadingProvider(LoadingTag.profiles)), false);
    });

    test(
      'disposing while the minimum-duration timer is pending is safe',
      () async {
        final scoped = ProviderContainer();
        final notifier = scoped.read(
          loadingProvider(LoadingTag.profiles).notifier,
        );

        notifier.start();
        await notifier.stop();
        scoped.dispose();

        await Future.delayed(const Duration(milliseconds: 1100));
      },
    );
  });

  group('UpdatingKeys provider', () {
    test('survives a subscriber that stops watching', () {
      const key = 'provider_geo';
      final subscription = container.listen<bool>(
        isUpdatingProvider(key),
        (_, _) {},
      );
      container.read(updatingKeysProvider.notifier).start(key);
      subscription.close();

      expect(container.read(isUpdatingProvider(key)), isTrue);
    });

    test('overlapping operations finish independently', () {
      const key = 'provider_rules';
      final notifier = container.read(updatingKeysProvider.notifier);

      final first = notifier.start(key);
      final second = notifier.start(key);

      notifier.stop(key, first);

      expect(container.read(isUpdatingProvider(key)), isTrue);

      notifier.stop(key, second);

      expect(container.read(isUpdatingProvider(key)), isFalse);
    });

    test('a stale operation cannot stop a later one', () {
      const key = 'profile_1';
      final notifier = container.read(updatingKeysProvider.notifier);

      final stale = notifier.start(key);
      notifier.stopKeys([key]);
      notifier.start(key);
      notifier.stop(key, stale);

      expect(container.read(isUpdatingProvider(key)), isTrue);
    });

    test('a core disconnect only discards the core scope', () {
      final notifier = container.read(updatingKeysProvider.notifier);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      notifier.start('geo_resource_MMDB', scope: UpdatingScope.core);
      notifier.start('provider_geo', scope: UpdatingScope.core);
      notifier.start('profile_1');

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;

      expect(container.read(isUpdatingProvider('geo_resource_MMDB')), isFalse);
      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
      expect(container.read(isUpdatingProvider('profile_1')), isTrue);
    });
  });

  group('CoreStatus provider', () {
    test('default is disconnected', () {
      expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    });
  });
  group('ConfigWarningsState provider', () {
    const warning = ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'proxies[1]',
      message: 'removed',
    );

    test('live warnings follow logs without discarding the core report', () {
      container.listen(appSettingProvider, (_, _) {});
      container.listen(liveConfigWarningsProvider, (_, _) {});
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      const note = ConfigWarning(
        level: ConfigWarningLevel.info,
        path: 'experimental',
        message: 'ignored',
      );
      container.read(configWarningsStateProvider.notifier).report([
        warning,
        note,
      ]);
      expect(container.read(liveConfigWarningsProvider), isEmpty);
      final settings = container.read(appSettingProvider.notifier);
      settings.value = settings.value.copyWith(openLogs: true);
      expect(container.read(liveConfigWarningsProvider), [warning]);
      settings.value = settings.value.copyWith(openLogs: false);
      expect(container.read(liveConfigWarningsProvider), isEmpty);
      expect(container.read(configWarningsStateProvider), [warning, note]);
    });

    test('the warnings end with the connection to the core', () {
      container.read(configWarningsStateProvider);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(configWarningsStateProvider.notifier).value = [warning];
      expect(container.read(configWarningsStateProvider), [warning]);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;

      expect(container.read(configWarningsStateProvider), isEmpty);
    });

    test('warnings that land once the core stopped are not kept', () {
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;

      container.read(configWarningsStateProvider.notifier).report([warning]);

      expect(container.read(configWarningsStateProvider), isEmpty);
    });

    test('a starting core keeps the warnings of its setup', () {
      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;

      container.read(configWarningsStateProvider.notifier).report([warning]);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      expect(container.read(configWarningsStateProvider), [warning]);
    });

    test('why the core stopped is kept until it starts again', () {
      container.read(coreStopReasonProvider.notifier).value = 'pipe reset';
      expect(container.read(coreStopReasonProvider), 'pipe reset');

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;

      expect(container.read(coreStopReasonProvider), isNull);
    });

    test('a core that reports nothing supports everything', () {
      final capabilities = container.read(coreCapabilitiesStateProvider);

      expect(capabilities.restricted, isFalse);
    });
  });
}
