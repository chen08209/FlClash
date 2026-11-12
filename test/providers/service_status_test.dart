import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/service_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/core_mocks.dart';
import '../helpers/probe_dtos.dart';

ServiceItem _item(String name, {String status = 'available'}) => serviceItem(
  name,
  status: status,
  delay: 12,
  chains: const ['HK-01'],
  checkedAt: 1700000000000,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoreMocks mocks;
  late List<ServiceSweep> sweeps;

  setUp(() {
    mocks = coreMocks();
    sweeps = [];
    stubCheckServices(mocks.api, (sweep) async {
      sweeps.add(sweep);
      return [for (final name in sweep.names) _item(name)];
    });
  });

  ProviderContainer container({bool proxied = true, bool synced = true}) {
    final scope = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWithBuild(
          (_, _) => RouteState(
            coreEpoch: 1,
            routeVersion: 1,
            hostEpoch: 1,
            proxied: proxied,
            synced: synced,
            live: synced,
          ),
        ),
        coreHandlerProvider.overrideWithValue(mocks.controller),
      ],
    );
    addTearDown(scope.dispose);
    scope.listen(serviceStatusProvider, (_, _) {});
    return scope;
  }

  ServiceStatus notifierOf(ProviderContainer scope) =>
      scope.read(serviceStatusProvider.notifier);

  RoutedProbeState<ServiceTarget, ServiceCheck> stateOf(
    ProviderContainer scope,
  ) => scope.read(serviceStatusProvider);

  test(
    'checks each watched target through the Core route on its own',
    () async {
      final scope = container();

      notifierOf(scope)
        ..watch(ServiceTarget.youtube)
        ..watch(ServiceTarget.claude);
      await pumpEventQueue();

      expect(sweeps.map((sweep) => sweep.names), [
        ['youtube'],
        ['claude'],
      ]);
      expect(sweeps.first.proxy, isEmpty);
      expect(sweeps.first.timeout, probeTimeoutDuration.inMilliseconds);
      final state = stateOf(scope);
      expect(state.entryOf(ServiceTarget.youtube).phase, ProbePhase.fresh);
      expect(state.valueOf(ServiceTarget.youtube)?.node, 'HK-01');
      expect(state.valueOf(ServiceTarget.claude)?.delay, 12);
    },
  );

  test('shows each answer as it lands', () async {
    final scope = container();
    final gates = <String, Completer<List<ServiceItem>>>{};
    stubCheckServices(
      mocks.api,
      (sweep) => (gates[sweep.names.single] = Completer()).future,
    );

    notifierOf(scope).refresh(ServiceTarget.values);
    await pumpEventQueue();
    expect(gates.keys, [for (final target in ServiceTarget.values) target.id]);

    gates['google']!.complete([_item('google')]);
    await pumpEventQueue();
    final state = stateOf(scope);
    expect(state.entryOf(ServiceTarget.google).phase, ProbePhase.fresh);
    expect(state.isLoading(ServiceTarget.github), isTrue);
  });

  testWidgets(
    'a route change asks the Core again once it settles, not behind the stale '
    'checks',
    (tester) async {
      final scope = container();
      stubCheckServices(mocks.api, (sweep) {
        sweeps.add(sweep);
        return Completer<List<ServiceItem>>().future;
      });
      final notifier = notifierOf(scope);
      ServiceTarget.values.forEach(notifier.watch);
      await tester.pump();
      expect(sweeps, hasLength(ServiceTarget.values.length));

      scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
      await tester.pump(probeSettleDuration);

      expect(sweeps.skip(ServiceTarget.values.length).map((s) => s.names), [
        for (final target in ServiceTarget.values) [target.id],
      ]);
      await tester.pump(probeThrottleDuration);
    },
  );

  test('checks through the direct outbound while the proxy is off', () async {
    final scope = container(proxied: false);

    notifierOf(scope).watch(ServiceTarget.bilibili);
    await pumpEventQueue();

    expect(sweeps.single.proxy, directOutbound);
    expect(sweeps.single.names, ['bilibili']);
  });

  test('does not ask the Core before the route has been read', () async {
    final scope = container(synced: false);

    notifierOf(scope).watch(ServiceTarget.bilibili);
    await pumpEventQueue();

    verifyNeverCheckServices(mocks.api);
    expect(stateOf(scope).isLoading(ServiceTarget.bilibili), isFalse);
  });

  test('marks a target loading while its check is in flight', () async {
    final scope = container();
    final gate = Completer<List<ServiceItem>>();
    stubCheckServices(mocks.api, (_) => gate.future);

    notifierOf(scope).watch(ServiceTarget.youtube);
    await pumpEventQueue();
    expect(stateOf(scope).isLoading(ServiceTarget.youtube), isTrue);

    gate.complete([_item('youtube')]);
    await pumpEventQueue();
    expect(stateOf(scope).isLoading(ServiceTarget.youtube), isFalse);
  });

  test(
    'will not queue a second check for a target already in flight',
    () async {
      final scope = container();
      final gate = Completer<List<ServiceItem>>();
      stubCheckServices(mocks.api, (_) => gate.future);
      final notifier = notifierOf(scope);

      notifier.watch(ServiceTarget.youtube);
      await pumpEventQueue();
      notifier
        ..watch(ServiceTarget.youtube)
        ..refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      gate.complete([_item('youtube')]);
      await pumpEventQueue();

      verifyCheckServices(mocks.api).called(1);
    },
  );

  test('a refresh checks the named targets, watched or not', () async {
    final scope = container();
    final notifier = notifierOf(scope);
    notifier.watch(ServiceTarget.youtube);
    await pumpEventQueue();

    notifier.refresh([ServiceTarget.youtube, ServiceTarget.claude]);
    await pumpEventQueue();

    expect(sweeps.map((sweep) => sweep.names), [
      ['youtube'],
      ['youtube'],
      ['claude'],
    ]);
    expect(stateOf(scope).valueOf(ServiceTarget.claude), isNotNull);
  });

  testWidgets('a timeout is shown as a status and asked again behind it', (
    tester,
  ) async {
    stubCheckServices(mocks.api, (sweep) async {
      sweeps.add(sweep);
      return [for (final name in sweep.names) _item(name, status: 'timeout')];
    });
    final scope = container();
    notifierOf(scope).watch(ServiceTarget.youtube);
    await tester.pump();

    final entry = stateOf(scope).entryOf(ServiceTarget.youtube);
    expect(entry.phase, ProbePhase.failed);
    expect(entry.value?.status, ServiceProbeStatus.timeout);

    await tester.pump(const Duration(minutes: 1));
    expect(sweeps, hasLength(1));

    scope.read(routeTrackerProvider.notifier).markResumed();
    await tester.pump();
    await tester.pump(probeThrottleDuration);
    expect(sweeps, hasLength(2));
    scope.dispose();
  });

  testWidgets('drops results once the route has changed under them', (
    tester,
  ) async {
    final scope = container();
    notifierOf(scope).watch(ServiceTarget.youtube);
    await tester.pump();
    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);

    scope.read(routeTrackerProvider.notifier).bumpHostEpoch();

    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNull);
    expect(stateOf(scope).isLoading(ServiceTarget.youtube), isTrue);
    await tester.pump(probeSettleDuration);
    expect(sweeps, hasLength(2));
    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);
    await tester.pump(probeThrottleDuration);
  });

  testWidgets('an answer that arrives after the route changed is asked again', (
    tester,
  ) async {
    final scope = container();
    final gate = Completer<List<ServiceItem>>();
    var first = true;
    stubCheckServices(mocks.api, (sweep) {
      sweeps.add(sweep);
      if (first) {
        first = false;
        return gate.future;
      }
      return Future.value([for (final name in sweep.names) _item(name)]);
    });
    notifierOf(scope).watch(ServiceTarget.youtube);
    await tester.pump();

    scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
    gate.complete([_item('youtube')]);
    await tester.pump(probeSettleDuration);

    expect(sweeps, hasLength(2));
    expect(
      stateOf(scope).entryOf(ServiceTarget.youtube).phase,
      ProbePhase.fresh,
    );
    await tester.pump(probeThrottleDuration);
  });

  test(
    'enabled targets follow the saved order and skip turned-off services',
    () {
      final scope = container();
      scope.read(appSettingProvider.notifier).value = const AppSettingProps(
        serviceOrder: ['claude', 'google'],
        disabledServices: ['github', 'bilibili'],
      );

      expect(scope.read(enabledServiceTargetsProvider).map((t) => t.id), [
        'claude',
        'google',
        for (final target in ServiceTarget.values)
          if (!['claude', 'google', 'github', 'bilibili'].contains(target.id))
            target.id,
      ]);
    },
  );

  test('a config that turns every service off still offers them all', () {
    final scope = container();
    scope.read(appSettingProvider.notifier).value = AppSettingProps(
      disabledServices: [for (final target in ServiceTarget.values) target.id],
    );

    expect(scope.read(enabledServiceTargetsProvider), ServiceTarget.values);
  });
}
