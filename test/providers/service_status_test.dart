import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/service_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

ServiceCheckItem _item(String name, {String status = 'available'}) =>
    ServiceCheckItem(
      name: name,
      status: status,
      delay: 12,
      chains: const ['HK-01'],
      checkedAt: 1700000000000,
      coreEpoch: 1,
      picksVersion: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(const ServiceCheckParams(timeout: 0)));

  late _MockCore core;
  late List<ServiceCheckParams> sweeps;

  setUp(() {
    core = _MockCore();
    sweeps = [];
    when(() => core.serviceCheck(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as ServiceCheckParams;
      sweeps.add(params);
      return [for (final name in params.names) _item(name)];
    });
  });

  ProviderContainer container({bool proxied = true, bool synced = true}) {
    final scope = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWithBuild(
          (_, _) => RouteState(
            coreEpoch: 1,
            picksVersion: 1,
            hostEpoch: 1,
            proxied: proxied,
            synced: synced,
            live: synced,
          ),
        ),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
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
    'checks the watched targets through the Core route in one sweep',
    () async {
      final scope = container();

      notifierOf(scope)
        ..watch(ServiceTarget.youtube)
        ..watch(ServiceTarget.claude);
      await pumpEventQueue();

      expect(sweeps.single.names, ['youtube', 'claude']);
      expect(sweeps.single.proxyName, isEmpty);
      expect(sweeps.single.timeout, probeTimeoutDuration.inMilliseconds);
      final state = stateOf(scope);
      expect(state.entryOf(ServiceTarget.youtube).phase, ProbePhase.fresh);
      expect(state.valueOf(ServiceTarget.youtube)?.node, 'HK-01');
      expect(state.valueOf(ServiceTarget.claude)?.delay, 12);
    },
  );

  test('checks through the direct outbound while the proxy is off', () async {
    final scope = container(proxied: false);

    notifierOf(scope).watch(ServiceTarget.bilibili);
    await pumpEventQueue();

    expect(sweeps.single.proxyName, directOutbound);
    expect(sweeps.single.names, ['bilibili']);
  });

  test('does not ask the Core before the route has been read', () async {
    final scope = container(synced: false);

    notifierOf(scope).watch(ServiceTarget.bilibili);
    await pumpEventQueue();

    verifyNever(() => core.serviceCheck(any()));
    expect(stateOf(scope).isLoading(ServiceTarget.bilibili), isFalse);
  });

  test('marks a target loading while its check is in flight', () async {
    final scope = container();
    final gate = Completer<List<ServiceCheckItem>>();
    when(() => core.serviceCheck(any())).thenAnswer((_) => gate.future);

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
      final gate = Completer<List<ServiceCheckItem>>();
      when(() => core.serviceCheck(any())).thenAnswer((_) => gate.future);
      final notifier = notifierOf(scope);

      notifier.watch(ServiceTarget.youtube);
      await pumpEventQueue();
      notifier
        ..watch(ServiceTarget.youtube)
        ..refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      gate.complete([_item('youtube')]);
      await pumpEventQueue();

      verify(() => core.serviceCheck(any())).called(1);
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
      ['youtube', 'claude'],
    ]);
    expect(stateOf(scope).valueOf(ServiceTarget.claude), isNotNull);
  });

  test(
    'a timeout is shown as a status and retried once the app resumes',
    () async {
      when(() => core.serviceCheck(any())).thenAnswer((invocation) async {
        final params =
            invocation.positionalArguments.single as ServiceCheckParams;
        sweeps.add(params);
        return [
          for (final name in params.names) _item(name, status: 'timeout'),
        ];
      });
      final scope = container();
      notifierOf(scope).watch(ServiceTarget.youtube);
      await pumpEventQueue();

      final entry = stateOf(scope).entryOf(ServiceTarget.youtube);
      expect(entry.phase, ProbePhase.failed);
      expect(entry.value?.status, ServiceProbeStatus.timeout);

      scope.read(routeTrackerProvider.notifier).markResumed();
      await pumpEventQueue();

      expect(sweeps, hasLength(2));
    },
  );

  test('drops results once the route has changed under them', () async {
    final scope = container();
    notifierOf(scope).watch(ServiceTarget.youtube);
    await pumpEventQueue();
    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);

    scope.read(routeTrackerProvider.notifier).bumpHostEpoch();

    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNull);
    expect(stateOf(scope).isLoading(ServiceTarget.youtube), isTrue);
    await pumpEventQueue();
    expect(sweeps, hasLength(2));
    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);
  });

  test(
    'an answer that arrives after the route changed is asked again',
    () async {
      final scope = container();
      final gate = Completer<List<ServiceCheckItem>>();
      var first = true;
      when(() => core.serviceCheck(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single as ServiceCheckParams;
        sweeps.add(params);
        if (first) {
          first = false;
          return gate.future;
        }
        return Future.value([for (final name in params.names) _item(name)]);
      });
      notifierOf(scope).watch(ServiceTarget.youtube);
      await pumpEventQueue();

      scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
      gate.complete([_item('youtube')]);
      await pumpEventQueue();

      expect(sweeps, hasLength(2));
      expect(
        stateOf(scope).entryOf(ServiceTarget.youtube).phase,
        ProbePhase.fresh,
      );
    },
  );

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
