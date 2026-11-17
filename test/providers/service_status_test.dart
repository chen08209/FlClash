import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
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

  void answerWith(String Function() status) {
    stubCheckServices(mocks.api, (sweep) async {
      sweeps.add(sweep);
      return [_item(sweep.names.single, status: status())];
    });
  }

  testWidgets('a failed service recovers while the route holds still', (
    tester,
  ) async {
    var status = 'failed';
    answerWith(() => status);
    final scope = container();
    const target = ServiceTarget.youtube;
    notifierOf(scope).watch(target);
    await tester.pump();
    expect(stateOf(scope).isLoading(target), isTrue);
    await tester.pump(probeConfirmDelay);
    expect(stateOf(scope).entryOf(target).phase, ProbePhase.failed);

    for (final minutes in [1, 2, 5, 5]) {
      final calls = sweeps.length;
      await tester.pump(
        Duration(minutes: minutes) - const Duration(milliseconds: 1),
      );
      expect(sweeps, hasLength(calls));
      await tester.pump(const Duration(milliseconds: 1));
      expect(sweeps, hasLength(calls + 1));
      expect(stateOf(scope).entryOf(target).phase, ProbePhase.failed);
    }
    status = 'available';
    await tester.pump(const Duration(minutes: 5));
    expect(
      stateOf(scope).valueOf(target)?.status,
      ServiceProbeStatus.available,
    );
    final calls = sweeps.length;
    await tester.pump(const Duration(minutes: 6));
    expect(sweeps, hasLength(calls));
    scope.dispose();
  });

  testWidgets(
    'a visible timeout backs off but resume uses the normal throttle',
    (tester) async {
      answerWith(() => 'timeout');
      final scope = container();
      const target = ServiceTarget.youtube;
      notifierOf(scope).watch(target);
      await tester.pump();
      expect(
        stateOf(scope).valueOf(target)?.status,
        ServiceProbeStatus.timeout,
      );
      await tester.pump(const Duration(minutes: 1));
      expect(sweeps, hasLength(2));

      scope.read(routeTrackerProvider.notifier).markResumed();
      await tester.pump();
      expect(sweeps, hasLength(2));
      await tester.pump(probeThrottleDuration);
      expect(sweeps, hasLength(3));
      notifierOf(scope).unwatch(target);
      await tester.pump(const Duration(minutes: 6));
      expect(sweeps, hasLength(3));

      notifierOf(scope).watch(target);
      scope
          .read(routeTrackerProvider.notifier)
          .applySnapshot(
            const RouteSnapshot(coreEpoch: 1, routeVersion: 1, running: true),
          );
      await tester.pump();
      await tester.pump(const Duration(minutes: 1));
      expect(sweeps, hasLength(5));
      scope.dispose();
    },
  );

  List<Timer> trackTimers(Duration interval, void Function() start) {
    final timers = <Timer>[];
    runZoned(
      start,
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, duration, callback) {
          final timer = parent.createTimer(zone, duration, callback);
          if (duration == interval) timers.add(timer);
          return timer;
        },
      ),
    );
    return timers;
  }

  testWidgets('a timeout landing while hidden arms no recheck timer', (
    tester,
  ) async {
    final reply = Completer<List<ServiceItem>>();
    stubCheckServices(mocks.api, (_) => reply.future);
    final scope = container();
    final timers = trackTimers(
      const Duration(minutes: 1),
      () => notifierOf(scope).watch(ServiceTarget.youtube),
    );
    await tester.pump();
    expect(timers, isEmpty);
    scope.read(appVisibleProvider.notifier).value = false;
    reply.complete([_item('youtube', status: 'timeout')]);
    await tester.pump();
    expect(
      stateOf(scope).entryOf(ServiceTarget.youtube).phase,
      ProbePhase.failed,
    );
    expect(timers, isEmpty);
    scope.dispose();
  });

  testWidgets('hiding a failed service cancels its recheck until shown again', (
    tester,
  ) async {
    answerWith(() => 'timeout');
    final scope = container();
    const target = ServiceTarget.youtube;
    final backoffTimers = trackTimers(
      const Duration(minutes: 2),
      () => notifierOf(scope).watch(target),
    );
    await tester.pump();
    await tester.pump(const Duration(minutes: 1));
    expect(backoffTimers.single.isActive, isTrue);

    final visible = scope.read(appVisibleProvider.notifier);
    visible.value = false;
    expect(backoffTimers.single.isActive, isFalse);
    await tester.pump(const Duration(minutes: 2));
    expect(sweeps, hasLength(2));
    visible.value = true;
    await tester.pump();
    expect(sweeps, hasLength(2));
    await tester.pump(const Duration(minutes: 2));
    expect(sweeps, hasLength(3));
    scope.dispose();
  });

  testWidgets('a reset and a later outage each start at one minute', (
    tester,
  ) async {
    var status = 'timeout';
    answerWith(() => status);
    final scope = container();
    const target = ServiceTarget.youtube;
    final service = notifierOf(scope);
    service.watch(target);
    await tester.pump();
    await tester.pump(const Duration(minutes: 1));
    expect(sweeps, hasLength(2));

    scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
    await tester.pump(probeMoveSettleDuration);
    expect(sweeps, hasLength(3));
    status = 'available';
    await tester.pump(const Duration(minutes: 1));
    expect(
      stateOf(scope).valueOf(target)?.status,
      ServiceProbeStatus.available,
    );

    status = 'timeout';
    service.refresh([target]);
    await tester.pump();
    expect(sweeps, hasLength(5));
    await tester.pump(const Duration(minutes: 1));
    expect(sweeps, hasLength(6));
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
