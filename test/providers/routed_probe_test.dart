import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _Probe extends Notifier<RoutedProbeState<String, String>>
    with RoutedProbe<String, String> {
  final calls = <String>[];
  final routes = <RouteState>[];
  final pending = <Completer<Map<String, ProbeAnswer<String>>>>[];
  final checks = <List<List<RouteHit>>>[];
  final moved = <String>{};
  Future<RouteCheck?> Function()? checkAnswer;
  Duration settle = Duration.zero;
  Duration moveSettle = Duration.zero;
  Duration throttle = Duration.zero;

  @override
  Duration get settleDuration => settle;

  @override
  Duration get moveSettleDuration => moveSettle;

  @override
  Duration get throttleDuration => throttle;

  @override
  RoutedProbeState<String, String> build() => buildProbe();

  @override
  bool isFailure(String value) => value == 'down';

  @override
  Future<Map<String, ProbeAnswer<String>>> probe(
    String target,
    RouteState route,
  ) {
    calls.add(target);
    routes.add(route);
    final completer = Completer<Map<String, ProbeAnswer<String>>>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<RouteCheck?> checkRoutes(List<List<RouteHit>> routes) {
    checks.add(routes);
    final answer = checkAnswer;
    if (answer != null) {
      return answer();
    }
    final route = ref.read(routeTrackerProvider);
    return Future.value(
      RouteCheck(
        coreEpoch: route.coreEpoch,
        routeVersion: route.routeVersion,
        held: [
          for (final hits in routes)
            hits.isNotEmpty && hits.every((hit) => !moved.contains(hit.host)),
        ],
      ),
    );
  }

  void answer(Map<String, ProbeAnswer<String>> answers) =>
      pending.removeAt(0).complete(answers);
}

final _probeProvider =
    NotifierProvider<_Probe, RoutedProbeState<String, String>>(_Probe.new);

const _route = RouteState(
  coreEpoch: 1,
  routeVersion: 1,
  hostEpoch: 1,
  proxied: true,
  synced: true,
  live: true,
);

ProbeAnswer<String> _ok(String host, {int routeVersion = 1}) => ProbeAnswer(
  value: 'ok',
  coreEpoch: 1,
  routeVersion: routeVersion,
  hits: [RouteHit(host: host, exit: host)],
);

void main() {
  ProviderContainer build({RouteState route = _route}) {
    final container = ProviderContainer(
      overrides: [routeTrackerProvider.overrideWithBuild((_, _) => route)],
    );
    addTearDown(container.dispose);
    container.listen(_probeProvider, (_, _) {});
    return container;
  }

  RouteTracker trackerOf(ProviderContainer container) =>
      container.read(routeTrackerProvider.notifier);

  void moveRoute(ProviderContainer container, int routeVersion) => trackerOf(
    container,
  ).applySnapshot(RouteSnapshot(coreEpoch: 1, routeVersion: routeVersion));

  test('probes a watched target and keeps the answer while fresh', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);

    probe.watch('a');
    expect(container.read(_probeProvider).entryOf('a').phase, ProbePhase.empty);
    await pumpEventQueue();
    expect(probe.calls, ['a']);
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();
    final entry = container.read(_probeProvider).entryOf('a');
    expect(entry.phase, ProbePhase.fresh);
    expect(entry.value, 'ok');

    probe.watch('a');
    await pumpEventQueue();
    expect(probe.calls, hasLength(1));
  });

  test('probes nothing that nobody watches', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();
    probe.unwatch('a');

    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();

    expect(probe.calls, hasLength(1));
    expect(container.read(_probeProvider).entries, isEmpty);
  });

  test(
    'a new route version asks again only where the Core finds the exit moved',
    () async {
      final container = build();
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      probe.watch('b');
      await pumpEventQueue();
      probe.answer({'a': _ok('a.example:443')});
      probe.answer({'b': _ok('b.example:443')});
      await pumpEventQueue();

      probe.moved.add('a.example:443');
      moveRoute(container, 2);
      await pumpEventQueue();

      expect(probe.checks, [
        [
          [const RouteHit(host: 'a.example:443', exit: 'a.example:443')],
          [const RouteHit(host: 'b.example:443', exit: 'b.example:443')],
        ],
      ]);
      expect(probe.calls, ['a', 'b', 'a']);
      final state = container.read(_probeProvider);
      expect(state.isLoading('a'), isTrue);
      expect(state.entryOf('b').phase, ProbePhase.fresh);
      expect(state.entryOf('b').stamp?.routeVersion, 2);
    },
  );

  test('an unwatched answer whose exit moved is dropped', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.refresh(['a']);
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    probe.moved.add('a.example:443');
    moveRoute(container, 2);
    await pumpEventQueue();

    expect(container.read(_probeProvider).entries, isEmpty);
    expect(probe.calls, ['a']);
  });

  test('a route check the Core cannot answer asks again', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..checkAnswer = () => Future.error(Exception('no_response'));
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    moveRoute(container, 2);
    await pumpEventQueue();

    expect(probe.calls, ['a', 'a']);
  });

  test('an answer without hits never holds', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({
      'a': const ProbeAnswer(value: 'ok', coreEpoch: 1, routeVersion: 1),
    });
    await pumpEventQueue();

    moveRoute(container, 2);
    await pumpEventQueue();

    expect(probe.calls, ['a', 'a']);
  });

  test('a move that lands during a check is checked again', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    final check = Completer<RouteCheck?>();
    probe.checkAnswer = () => check.future;
    moveRoute(container, 2);
    await pumpEventQueue();
    expect(probe.checks, hasLength(1));

    probe.checkAnswer = null;
    moveRoute(container, 3);
    await pumpEventQueue();
    check.complete(
      const RouteCheck(coreEpoch: 1, routeVersion: 2, held: [true]),
    );
    await pumpEventQueue();

    expect(probe.checks, hasLength(2));
    expect(probe.calls, ['a']);
    final entry = container.read(_probeProvider).entryOf('a');
    expect(entry.phase, ProbePhase.fresh);
    expect(entry.stamp?.routeVersion, 3);
  });

  test('a route change asks again without waiting for the old probe', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();

    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(probe.calls, ['a', 'a']);

    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();
    expect(container.read(_probeProvider).entryOf('a').phase, ProbePhase.fresh);
  });

  testWidgets('a burst of route changes is probed once it settles', (
    tester,
  ) async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..settle = probeSettleDuration
      ..moveSettle = probeMoveSettleDuration;
    probe.watch('a');
    await tester.pump();
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    for (var i = 0; i < 3; i++) {
      trackerOf(container).bumpHostEpoch();
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(container.read(_probeProvider).isLoading('a'), isTrue);
    expect(probe.calls, ['a']);

    await tester.pump(probeMoveSettleDuration);
    expect(probe.calls, ['a', 'a']);
    expect(probe.routes.last.hostEpoch, _route.hostEpoch + 3);
  });

  testWidgets('a route check waits past the next pick poll', (tester) async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..settle = probeSettleDuration
      ..moveSettle = probeMoveSettleDuration;
    probe.watch('a');
    await tester.pump();
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    probe.moved.add('a.example:443');
    moveRoute(container, 2);
    await tester.pump(const Duration(seconds: 1));
    moveRoute(container, 3);
    await tester.pump(const Duration(milliseconds: 100));
    expect(probe.checks, isEmpty);
    expect(container.read(_probeProvider).entryOf('a').phase, ProbePhase.fresh);

    await tester.pump(probeSettleDuration);
    expect(probe.checks, hasLength(1));
    expect(probe.calls, ['a', 'a']);
  });

  testWidgets('an exit that keeps moving is asked at most once a throttle', (
    tester,
  ) async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..throttle = const Duration(seconds: 5);
    probe.watch('a');
    await tester.pump();
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    probe.moved.add('a.example:443');
    for (var version = 2; version < 5; version++) {
      moveRoute(container, version);
      await tester.pump(const Duration(seconds: 1));
    }
    expect(probe.calls, ['a']);
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    await tester.pump(const Duration(seconds: 2));
    expect(probe.calls, ['a', 'a']);
    expect(probe.routes.last.routeVersion, 4);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a refresh and a move both skip the throttle', (tester) async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..throttle = const Duration(seconds: 5);
    probe.watch('a');
    await tester.pump();
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    probe.refresh(['a']);
    await tester.pump();
    expect(probe.calls, ['a', 'a']);
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    trackerOf(container).bumpHostEpoch();
    await tester.pump(Duration.zero);
    expect(probe.calls, ['a', 'a', 'a']);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a refresh does not wait for the route to settle', (
    tester,
  ) async {
    final container = build();
    final probe = container.read(_probeProvider.notifier)
      ..settle = probeSettleDuration
      ..moveSettle = probeMoveSettleDuration;
    probe.watch('a');
    await tester.pump();
    probe.answer({'a': _ok('a.example:443')});
    await tester.pump();

    trackerOf(container).bumpHostEpoch();
    await tester.pump();
    probe.refresh(['a']);
    await tester.pump();
    expect(probe.calls, ['a', 'a']);

    await tester.pump(probeSettleDuration);
    expect(probe.calls, ['a', 'a']);
  });

  test('an answer the route moved under shows once its check holds', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    probe.watch('b');
    await pumpEventQueue();

    moveRoute(container, 2);
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    expect(probe.checks, isEmpty);

    final check = Completer<RouteCheck?>();
    probe.checkAnswer = () => check.future;
    probe.answer({'a': _ok('a.example:443')});
    probe.answer({'b': _ok('b.example:443')});
    await pumpEventQueue();
    expect(probe.checks, [
      [
        [const RouteHit(host: 'a.example:443', exit: 'a.example:443')],
      ],
    ]);
    var state = container.read(_probeProvider);
    expect(state.isLoading('a'), isTrue);
    expect(state.isLoading('b'), isTrue);

    probe.checkAnswer = null;
    check.complete(
      const RouteCheck(coreEpoch: 1, routeVersion: 2, held: [false]),
    );
    await pumpEventQueue();

    expect(probe.checks, hasLength(2));
    expect(probe.calls, ['a', 'b', 'a']);
    state = container.read(_probeProvider);
    expect(state.isLoading('a'), isTrue);
    expect(state.entryOf('b').phase, ProbePhase.fresh);
    expect(state.entryOf('b').stamp?.routeVersion, 2);
  });

  test('a failed answer waits for a refresh or the app resuming', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer(const {});
    await pumpEventQueue();
    expect(
      container.read(_probeProvider).entryOf('a').phase,
      ProbePhase.failed,
    );

    probe.watch('a');
    await pumpEventQueue();
    expect(probe.calls, hasLength(1));

    probe.refresh(['a']);
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    probe.answer({
      'a': const ProbeAnswer(value: 'down', coreEpoch: 1, routeVersion: 1),
    });
    await pumpEventQueue();
    final entry = container.read(_probeProvider).entryOf('a');
    expect(entry.phase, ProbePhase.failed);
    expect(entry.value, 'down');

    trackerOf(container).markResumed();
    await pumpEventQueue();
    expect(probe.calls, hasLength(3));
  });

  test('coming back to a failed target asks again', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    probe.watch('b');
    await pumpEventQueue();
    probe.answer({'b': _ok('b.example:443')});
    await pumpEventQueue();
    probe.unwatch('a');

    probe.watch('a');
    await pumpEventQueue();

    expect(probe.calls, ['a', 'b', 'a']);
    expect(container.read(_probeProvider).isLoading('a'), isTrue);
  });

  test(
    'a refresh keeps the old answer on show and reaches unwatched targets',
    () async {
      final container = build();
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      await pumpEventQueue();
      probe.answer({'a': _ok('a.example:443')});
      await pumpEventQueue();

      probe.refresh(['a', 'b']);
      await pumpEventQueue();

      expect(probe.calls, ['a', 'a', 'b']);
      final entry = container.read(_probeProvider).entryOf('a');
      expect(entry.isLoading, isTrue);
      expect(entry.value, 'ok');

      probe.answer({'a': _ok('a.example:443')});
      probe.answer({'b': _ok('b.example:443')});
      await pumpEventQueue();
      expect(
        container.read(_probeProvider).entryOf('b').phase,
        ProbePhase.fresh,
      );

      trackerOf(container).bumpHostEpoch();
      await pumpEventQueue();
      expect(
        container.read(_probeProvider).entryOf('b').phase,
        ProbePhase.empty,
      );
      expect(probe.calls, ['a', 'a', 'b', 'a']);
    },
  );

  test('a fresh answer for another target stands in for its lookup', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    probe.watch('b');
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));

    probe.answer({
      'a': _ok('a.example:443'),
      'b': _ok('a.example:443'),
      'c': _ok('a.example:443', routeVersion: 0),
    });
    await pumpEventQueue();
    final state = container.read(_probeProvider);
    expect(state.entryOf('b').phase, ProbePhase.fresh);
    expect(state.entryOf('c').phase, ProbePhase.empty);

    probe.answer({'b': const ProbeAnswer()});
    await pumpEventQueue();
    expect(container.read(_probeProvider).entryOf('b').phase, ProbePhase.fresh);
    expect(probe.calls, hasLength(2));
  });

  test('nothing is probed before the Core has been read', () async {
    final container = build(route: const RouteState());
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    expect(probe.calls, isEmpty);

    trackerOf(
      container,
    ).applySnapshot(const RouteSnapshot(coreEpoch: 1, routeVersion: 1));
    await pumpEventQueue();

    expect(probe.calls, ['a']);
  });

  test('a probe that falls due while the app is hidden waits for it', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    container.read(appVisibleProvider.notifier).value = false;
    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(probe.calls, hasLength(1));

    container.read(appVisibleProvider.notifier).value = true;
    await pumpEventQueue();

    expect(probe.calls, hasLength(2));
  });

  test('a route check that falls due while the app is hidden waits', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    container.read(appVisibleProvider.notifier).value = false;
    moveRoute(container, 2);
    await pumpEventQueue();
    expect(probe.checks, isEmpty);

    container.read(appVisibleProvider.notifier).value = true;
    await pumpEventQueue();

    expect(probe.checks, hasLength(1));
    expect(container.read(_probeProvider).entryOf('a').stamp?.routeVersion, 2);
  });

  test('a target left while its re-probe waits stops loading', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({'a': _ok('a.example:443')});
    await pumpEventQueue();

    container.read(appVisibleProvider.notifier).value = false;
    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    probe.unwatch('a');
    await pumpEventQueue();
    expect(container.read(_probeProvider).entries, isEmpty);

    container.read(appVisibleProvider.notifier).value = true;
    await pumpEventQueue();
    expect(probe.calls, hasLength(1));
  });

  test('a second stale answer under the same route gives up', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();

    const stale = ProbeAnswer(value: 'ok', coreEpoch: 0, routeVersion: 1);
    probe.answer({'a': stale});
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));

    probe.answer({'a': stale});
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    expect(
      container.read(_probeProvider).entryOf('a').phase,
      ProbePhase.failed,
    );

    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(probe.calls, hasLength(3));
  });

  group('with a live tracker', () {
    late _MockCore core;

    setUp(() => core = _MockCore());

    ProviderContainer live(RouteSnapshot Function() snapshot) {
      when(() => core.watchRoute(true)).thenAnswer((_) async => snapshot());
      when(() => core.watchRoute(false)).thenAnswer((_) async => null);
      final container = ProviderContainer(
        overrides: [
          initProvider.overrideWithBuild((_, _) => true),
          coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
          runTimeProvider.overrideWithBuild((_, _) => 1),
          suspendProvider.overrideWithValue(false),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(_probeProvider, (_, _) {});
      return container;
    }

    test('an answer newer than the state has the Core read again', () async {
      var epoch = 1;
      final container = live(
        () => RouteSnapshot(coreEpoch: epoch, routeVersion: 1),
      );
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      await pumpEventQueue();
      expect(probe.calls, ['a']);

      epoch = 2;
      probe.answer({
        'a': const ProbeAnswer(value: 'ok', coreEpoch: 2, routeVersion: 1),
      });
      await pumpEventQueue();

      verify(() => core.watchRoute(true)).called(2);
      expect(container.read(routeTrackerProvider).coreEpoch, 2);
      expect(probe.calls, ['a', 'a']);

      probe.answer({
        'a': const ProbeAnswer(value: 'ok', coreEpoch: 2, routeVersion: 1),
      });
      await pumpEventQueue();
      expect(
        container.read(_probeProvider).entryOf('a').phase,
        ProbePhase.fresh,
      );
    });

    test(
      'a probe due on return waits for the route to be read again',
      () async {
        final container = live(
          () => const RouteSnapshot(coreEpoch: 1, routeVersion: 1),
        );
        final reads = <Completer<RouteSnapshot>>[];
        when(() => core.watchRoute(true)).thenAnswer((_) {
          final read = Completer<RouteSnapshot>();
          reads.add(read);
          return read.future;
        });
        final probe = container.read(_probeProvider.notifier);
        probe.watch('a');
        await pumpEventQueue();
        reads.last.complete(const RouteSnapshot(coreEpoch: 1, routeVersion: 1));
        await pumpEventQueue();
        probe.answer({'a': _ok('a.example:443')});
        await pumpEventQueue();

        container.read(appVisibleProvider.notifier).value = false;
        container.read(routeTrackerProvider.notifier).bumpHostEpoch();
        await pumpEventQueue();
        container.read(appVisibleProvider.notifier).value = true;
        await pumpEventQueue();
        expect(probe.calls, hasLength(1));

        reads.last.complete(const RouteSnapshot(coreEpoch: 1, routeVersion: 2));
        await pumpEventQueue();
        expect(probe.calls, hasLength(2));
      },
    );

    test(
      'a target left while the Core was away is asked again on return',
      () async {
        final container = live(
          () => const RouteSnapshot(coreEpoch: 1, routeVersion: 1),
        );
        final probe = container.read(_probeProvider.notifier);
        probe.watch('a');
        await pumpEventQueue();
        probe.answer({'a': _ok('a.example:443')});
        await pumpEventQueue();

        container.read(coreStatusProvider.notifier).value =
            CoreStatus.disconnected;
        await pumpEventQueue();
        probe.watch('b');
        probe.unwatch('a');
        container.read(coreStatusProvider.notifier).value =
            CoreStatus.connected;
        await pumpEventQueue();
        probe.watch('a');
        probe.unwatch('b');
        await pumpEventQueue();

        expect(probe.calls, ['a', 'b', 'a']);
      },
    );

    test('the last watcher releases the tracker', () async {
      final container = live(
        () => const RouteSnapshot(coreEpoch: 1, routeVersion: 1),
      );
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      probe.watch('a');
      await pumpEventQueue();

      probe.unwatch('a');
      verifyNever(() => core.watchRoute(false));

      probe.unwatch('a');
      await pumpEventQueue();
      verify(() => core.watchRoute(false)).called(1);
    });
  });
}
