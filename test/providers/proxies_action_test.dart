import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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

ProviderContainer _delayContainer(ProviderContainer Function() build) {
  final container = build();
  container.read(appSettingProvider.notifier).value = const AppSettingProps(
    testUrl: _testUrl,
  );
  return container;
}

ExternalProvider _provider(String name, {int count = 1}) => ExternalProvider(
  name: name,
  type: 'Proxy',
  count: count,
  vehicleType: 'HTTP',
  updateAt: DateTime.utc(2026),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCoreHandlerInterface core;

  setUpAll(() async {
    registerFallbackValue(
      const ChangeProxyParams(groupName: 'G', proxyName: 'P'),
    );
    core = MockCoreHandlerInterface();
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() => reset(core));

  ProviderContainer buildContainer({Profile? profile}) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  ProxiesAction actionOf(ProviderContainer container) =>
      container.read(proxiesActionProvider.notifier);

  group('updateGroups', () {
    test('publishes the groups derived from core proxy data', () async {
      when(core.getProxies).thenAnswer(
        (_) async => ProxiesData(
          all: const ['Proxy', 'Direct'],
          proxies: Map<String, dynamic>.from({
            'Proxy': Map<String, dynamic>.from({
              'name': 'Proxy',
              'type': 'Selector',
              'now': 'HK-01',
              'all': ['HK-01'],
            }),
            'Direct': Map<String, dynamic>.from({
              'name': 'Direct',
              'type': 'Direct',
            }),
            'HK-01': Map<String, dynamic>.from({'name': 'HK-01', 'type': 'ss'}),
          }),
        ),
      );
      final container = buildContainer();

      await actionOf(container).updateGroups();

      final groups = container.read(groupsProvider);
      expect(groups.map((group) => group.name), ['Proxy']);
      expect(groups.single.all.map((proxy) => proxy.name), ['HK-01']);
    });

    test('keeps the groups already on screen when core throws', () async {
      when(core.getProxies).thenThrow(StateError('core down'));
      final container = buildContainer();
      container.read(groupsProvider.notifier).value = [
        _group('Stale', const []),
      ];

      await actionOf(container).updateGroups();

      // Stale groups beat no groups: a core hiccup used to empty the list the
      // user was looking at, and nothing refills it until the next update.
      expect(container.read(groupsProvider).map((group) => group.name), [
        'Stale',
      ]);
    });
  });

  group('changeProxy', () {
    setUp(() {
      when(() => core.changeProxy(any())).thenAnswer((_) async => '');
      when(core.closeConnections).thenAnswer((_) async => true);
      when(core.resetConnections).thenAnswer((_) async => true);
    });

    test('closes connections and bumps the ip check when enabled', () async {
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: true,
      );
      final before = container.read(checkIpNumProvider);

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verify(
        () => core.changeProxy(
          const ChangeProxyParams(groupName: 'Proxy', proxyName: 'HK-01'),
        ),
      ).called(1);
      verify(core.closeConnections).called(1);
      verifyNever(core.resetConnections);
      expect(container.read(checkIpNumProvider), before + 1);
    });

    test('resets connections instead when the setting is off', () async {
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: false,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verify(core.resetConnections).called(1);
      verifyNever(core.closeConnections);
    });

    test('still bumps the ip check when the connection reset throws', () async {
      when(core.closeConnections).thenThrow(
        const CoreMethodException(
          code: 'transport_disconnected',
          message: 'Core RPC client is closed',
        ),
      );
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        closeConnections: true,
      );
      final before = container.read(checkIpNumProvider);

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      expect(container.read(checkIpNumProvider), before + 1);
    });

    test('skips the connection reset when the switch itself fails', () async {
      when(() => core.changeProxy(any())).thenThrow(StateError('core down'));
      final container = buildContainer();
      final before = container.read(checkIpNumProvider);

      await actionOf(
        container,
      ).changeProxy(groupName: 'Proxy', proxyName: 'HK-01');

      verifyNever(core.closeConnections);
      verifyNever(core.resetConnections);
      expect(container.read(checkIpNumProvider), before);
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
      when(() => core.changeProxy(any())).thenThrow(StateError('core down'));
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
        when(() => core.changeProxy(any())).thenThrow(StateError('core down'));
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
      when(() => core.asyncTestDelay(_testUrl, 'HK-01')).thenAnswer((_) async {
        observed.add(
          container.read(pendingDelayTestsProvider).contains(_delayKey),
        );
        return const Delay(name: 'HK-01', url: _testUrl, value: 128);
      });
      container = _delayContainer(buildContainer);

      await actionOf(container).proxyDelayTest(_proxy);

      expect(observed, [true]);
      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], 128);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('keeps the last measurement when the Core does not answer', () async {
      when(
        () => core.asyncTestDelay(_testUrl, 'HK-01'),
      ).thenAnswer((_) async => null);
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
        () => core.asyncTestDelay(_testUrl, 'HK-01'),
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
      verifyNever(() => core.asyncTestDelay(any(), any()));
    });
  });

  group('delayTest', () {
    test('measures every proxy and bumps the sort counter', () async {
      when(() => core.asyncTestDelay(_testUrl, any())).thenAnswer(
        (invocation) async => Delay(
          name: invocation.positionalArguments[1] as String,
          url: _testUrl,
          value: 10,
        ),
      );
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

    test('probes a node that appears twice only once', () async {
      when(() => core.asyncTestDelay(_testUrl, 'HK-01')).thenAnswer(
        (_) async => const Delay(name: 'HK-01', url: _testUrl, value: 10),
      );
      final container = _delayContainer(buildContainer);

      await actionOf(container).delayTest(const [_proxy, _proxy]);

      verify(() => core.asyncTestDelay(_testUrl, 'HK-01')).called(1);
    });

    test('stops the run once the transport is gone', () async {
      var calls = 0;
      when(() => core.asyncTestDelay(_testUrl, any())).thenAnswer((_) async {
        calls++;
        throw const CoreMethodException(
          code: 'transport_disconnected',
          message: 'the Core is gone',
        );
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        maxConcurrentDelayTests * 3,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, lessThanOrEqualTo(maxConcurrentDelayTests));
      expect(calls, lessThan(proxies.length));
      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('a proxy that answers nothing leaves the rest of the run', () async {
      var calls = 0;
      when(() => core.asyncTestDelay(_testUrl, any())).thenAnswer((
        invocation,
      ) async {
        calls++;
        final name = invocation.positionalArguments[1] as String;
        if (name == 'HK-1') {
          return null;
        }
        return Delay(name: name, url: _testUrl, value: 10);
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        8,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, proxies.length);
      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?.length, proxies.length - 1);
      expect(delays?['HK-1'], isNull);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('a proxy that fails leaves the rest of the run', () async {
      var calls = 0;
      when(() => core.asyncTestDelay(_testUrl, any())).thenAnswer((
        invocation,
      ) async {
        calls++;
        final name = invocation.positionalArguments[1] as String;
        if (name == 'HK-1') {
          throw const CoreMethodException(
            code: 'internal_error',
            message: 'internal panic',
          );
        }
        return Delay(name: name, url: _testUrl, value: 10);
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        8,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, proxies.length);
      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?.length, proxies.length - 1);
      expect(delays?['HK-1'], isNull);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('drops every spinner when the Core goes away mid-run', () async {
      final release = Completer<Delay?>();
      when(
        () => core.asyncTestDelay(_testUrl, any()),
      ).thenAnswer((_) => release.future);
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

      release.complete(const Delay(name: 'HK-01', url: _testUrl, value: 10));
      await run;

      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });
  });

  group('updateProvider', () {
    test(
      'stores the refreshed provider and clears the updating flag',
      () async {
        final refreshed = _provider('geo', count: 5);
        final release = Completer<String>();
        when(
          () => core.updateExternalProvider('geo'),
        ).thenAnswer((_) => release.future);
        when(
          () => core.getExternalProvider('geo'),
        ).thenAnswer((_) async => refreshed);
        final container = buildContainer();
        container.read(providersProvider.notifier).value = [_provider('geo')];

        final update = actionOf(
          container,
        ).updateProvider(_provider('geo'), showLoading: true);

        expect(container.read(isUpdatingProvider('provider_geo')), isTrue);

        release.complete('');
        final message = await update;

        expect(message, isEmpty);
        expect(container.read(providersProvider), [refreshed]);
        expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
      },
    );

    testWidgets('the stale sweep does not interrupt the provider update', (
      tester,
    ) async {
      final refreshed = _provider('geo', count: 8);
      final release = Completer<String>();
      when(
        () => core.updateExternalProvider('geo'),
      ).thenAnswer((_) => release.future);
      when(
        () => core.getExternalProvider('geo'),
      ).thenAnswer((_) async => refreshed);
      final container = buildContainer();
      container.read(updatingActionProvider.notifier);
      container.read(providersProvider.notifier).value = [_provider('geo')];

      final update = actionOf(
        container,
      ).updateProvider(_provider('geo'), showLoading: true);

      await tester.pump(updatingStaleTimeout + updatingSweepInterval);

      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);

      release.complete('');

      expect(await update, isEmpty);
      expect(container.read(providersProvider), [refreshed]);

      await tester.pump(Duration.zero);
    });

    testWidgets('a core disconnect clears the provider updating state', (
      tester,
    ) async {
      final release = Completer<String>();
      when(
        () => core.updateExternalProvider('geo'),
      ).thenAnswer((_) => release.future);
      when(
        () => core.getExternalProvider('geo'),
      ).thenAnswer((_) async => _provider('geo'));
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

      release.complete('');
      await update;
      await tester.pump(Duration.zero);
    });

    test('returns the core message without storing a provider', () async {
      when(
        () => core.updateExternalProvider('geo'),
      ).thenAnswer((_) async => 'update failed');
      final container = buildContainer();

      final message = await actionOf(
        container,
      ).updateProvider(_provider('geo'), showLoading: true);

      expect(message, 'update failed');
      expect(container.read(providersProvider), isEmpty);
      expect(container.read(isUpdatingProvider('provider_geo')), isFalse);
      verifyNever(() => core.getExternalProvider(any()));
    });

    test('clears the updating flag when core throws', () async {
      when(
        () => core.updateExternalProvider('geo'),
      ).thenThrow(StateError('boom'));
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
      final refreshed = _provider('rules', count: 3);
      final release = Completer<String>();
      when(
        () => core.sideLoadExternalProvider(
          providerName: 'rules',
          data: 'payload',
        ),
      ).thenAnswer((_) => release.future);
      when(
        () => core.getExternalProvider('rules'),
      ).thenAnswer((_) async => refreshed);
      final container = buildContainer();
      container.read(providersProvider.notifier).value = [_provider('rules')];

      final sideLoad = actionOf(container).sideLoadExternalProvider(
        _provider('rules'),
        'payload',
        showLoading: true,
      );

      expect(container.read(isUpdatingProvider('provider_rules')), isTrue);

      release.complete('');
      final message = await sideLoad;

      expect(message, isEmpty);
      expect(container.read(providersProvider), [refreshed]);
      expect(container.read(isUpdatingProvider('provider_rules')), isFalse);
    });

    test('surfaces the core message and skips the refresh', () async {
      when(
        () => core.sideLoadExternalProvider(providerName: 'rules', data: 'bad'),
      ).thenAnswer((_) async => 'invalid payload');
      final container = buildContainer();

      final message = await actionOf(
        container,
      ).sideLoadExternalProvider(_provider('rules'), 'bad');

      expect(message, 'invalid payload');
      verifyNever(() => core.getExternalProvider(any()));
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
