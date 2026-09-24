import 'dart:async';

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
  _Probe({this.batched = false});

  @override
  final bool batched;

  final calls = <List<String>>[];
  final pending = <Completer<Map<String, ProbeAnswer<String>>>>[];

  @override
  RoutedProbeState<String, String> build() => buildProbe();

  @override
  bool isFailure(String value) => value == 'down';

  @override
  Future<Map<String, ProbeAnswer<String>>> probe(
    List<String> targets,
    RouteState route,
  ) {
    calls.add(targets);
    final completer = Completer<Map<String, ProbeAnswer<String>>>();
    pending.add(completer);
    return completer.future;
  }

  void answer(Map<String, ProbeAnswer<String>> answers) =>
      pending.removeAt(0).complete(answers);
}

final _probeProvider =
    NotifierProvider<_Probe, RoutedProbeState<String, String>>(_Probe.new);

final _batchedProvider =
    NotifierProvider<_Probe, RoutedProbeState<String, String>>(
      () => _Probe(batched: true),
    );

const _route = RouteState(
  coreEpoch: 1,
  picksVersion: 1,
  picks: {'Proxy': 'HK-01', 'Auto': 'JP-01'},
  hostEpoch: 1,
  proxied: true,
  synced: true,
  live: true,
);

ProbeAnswer<String> _ok(List<String> chains) =>
    ProbeAnswer(value: 'ok', coreEpoch: 1, picksVersion: 1, chains: chains);

void main() {
  ProviderContainer build({RouteState route = _route}) {
    final container = ProviderContainer(
      overrides: [routeTrackerProvider.overrideWithBuild((_, _) => route)],
    );
    addTearDown(container.dispose);
    container.listen(_probeProvider, (_, _) {});
    container.listen(_batchedProvider, (_, _) {});
    return container;
  }

  RouteTracker trackerOf(ProviderContainer container) =>
      container.read(routeTrackerProvider.notifier);

  test('probes a watched target and keeps the answer while fresh', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);

    probe.watch('a');
    expect(container.read(_probeProvider).entryOf('a').phase, ProbePhase.empty);
    await pumpEventQueue();
    expect(probe.calls, [
      ['a'],
    ]);
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
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
    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
    await pumpEventQueue();
    probe.unwatch('a');

    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();

    expect(probe.calls, hasLength(1));
    expect(container.read(_probeProvider).entries, isEmpty);
  });

  test(
    'a route change re-probes only the entries that went through it',
    () async {
      final container = build();
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      probe.watch('b');
      await pumpEventQueue();
      expect(probe.calls, [
        ['a'],
        ['b'],
      ]);
      probe.answer({
        'a': _ok(['HK-01', 'Proxy']),
      });
      probe.answer({
        'b': _ok(['JP-01', 'Auto']),
      });
      await pumpEventQueue();

      trackerOf(container).applySnapshot(
        const RouteSnapshot(
          coreEpoch: 1,
          picksVersion: 2,
          picks: {'Proxy': 'HK-02', 'Auto': 'JP-01'},
        ),
      );
      await pumpEventQueue();

      expect(probe.calls, [
        ['a'],
        ['b'],
        ['a'],
      ]);
      final state = container.read(_probeProvider);
      expect(state.isLoading('a'), isTrue);
      expect(state.entryOf('b').phase, ProbePhase.fresh);
    },
  );

  test('a route change asks again without waiting for the old probe', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();

    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(probe.calls, [
      ['a'],
      ['a'],
    ]);

    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    expect(container.read(_probeProvider).isLoading('a'), isTrue);

    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
    await pumpEventQueue();
    expect(container.read(_probeProvider).entryOf('a').phase, ProbePhase.fresh);
  });

  test('a pick change lets the running probe land', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    probe.watch('b');
    await pumpEventQueue();

    trackerOf(container).applySnapshot(
      const RouteSnapshot(
        coreEpoch: 1,
        picksVersion: 2,
        picks: {'Proxy': 'HK-02', 'Auto': 'JP-01'},
      ),
    );
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));

    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
    probe.answer({
      'b': _ok(['JP-01', 'Auto']),
    });
    await pumpEventQueue();
    expect(probe.calls, [
      ['a'],
      ['b'],
      ['a'],
    ]);
    final state = container.read(_probeProvider);
    expect(state.isLoading('a'), isTrue);
    expect(state.entryOf('b').phase, ProbePhase.fresh);
  });

  test('a failed answer waits for a retry or the app resuming', () async {
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

    probe.retry('a');
    await pumpEventQueue();
    expect(probe.calls, hasLength(2));
    probe.answer({
      'a': const ProbeAnswer(value: 'down', coreEpoch: 1, picksVersion: 1),
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
    probe.answer({
      'b': _ok(['JP-01', 'Auto']),
    });
    await pumpEventQueue();
    probe.unwatch('a');

    probe.watch('a');
    await pumpEventQueue();

    expect(probe.calls, [
      ['a'],
      ['b'],
      ['a'],
    ]);
    expect(container.read(_probeProvider).isLoading('a'), isTrue);
  });

  test(
    'a refresh keeps the old answer on show and reaches unwatched targets',
    () async {
      final container = build();
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      await pumpEventQueue();
      probe.answer({
        'a': _ok(['HK-01', 'Proxy']),
      });
      await pumpEventQueue();

      probe.refresh(['a', 'b']);
      await pumpEventQueue();

      expect(probe.calls, [
        ['a'],
        ['a'],
        ['b'],
      ]);
      final entry = container.read(_probeProvider).entryOf('a');
      expect(entry.isLoading, isTrue);
      expect(entry.value, 'ok');

      probe.answer({
        'a': _ok(['HK-01', 'Proxy']),
      });
      probe.answer({
        'b': _ok(['JP-01', 'Auto']),
      });
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
      expect(probe.calls, [
        ['a'],
        ['a'],
        ['b'],
        ['a'],
      ]);
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
      'a': _ok(['HK-01', 'Proxy']),
      'b': _ok(['HK-01']),
      'c': _ok(['JP-02', 'Auto']),
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

  test('a batched probe judges each target on its own', () async {
    final container = build();
    final probe = container.read(_batchedProvider.notifier);
    probe.watch('a');
    probe.watch('b');
    await pumpEventQueue();
    expect(probe.calls, [
      ['a', 'b'],
    ]);

    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
      'b': _ok(['JP-02', 'Auto']),
    });
    await pumpEventQueue();

    final state = container.read(_batchedProvider);
    expect(state.entryOf('a').phase, ProbePhase.fresh);
    expect(state.isLoading('b'), isTrue);
    expect(probe.calls, [
      ['a', 'b'],
      ['b'],
    ]);
  });

  test('nothing is probed before the Core has been read', () async {
    final container = build(route: const RouteState());
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    expect(probe.calls, isEmpty);

    trackerOf(
      container,
    ).applySnapshot(const RouteSnapshot(coreEpoch: 1, picksVersion: 1));
    await pumpEventQueue();

    expect(probe.calls, [
      ['a'],
    ]);
  });

  test('a probe that falls due while the app is hidden waits for it', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
    await pumpEventQueue();

    container.read(appVisibleProvider.notifier).value = false;
    trackerOf(container).bumpHostEpoch();
    await pumpEventQueue();
    expect(probe.calls, hasLength(1));

    container.read(appVisibleProvider.notifier).value = true;
    await pumpEventQueue();

    expect(probe.calls, hasLength(2));
  });

  test('a target left while its re-probe waits stops loading', () async {
    final container = build();
    final probe = container.read(_probeProvider.notifier);
    probe.watch('a');
    await pumpEventQueue();
    probe.answer({
      'a': _ok(['HK-01', 'Proxy']),
    });
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

    const stale = ProbeAnswer(
      value: 'ok',
      coreEpoch: 0,
      picksVersion: 1,
      chains: ['HK-01', 'Proxy'],
    );
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
        () => RouteSnapshot(coreEpoch: epoch, picksVersion: 1),
      );
      final probe = container.read(_probeProvider.notifier);
      probe.watch('a');
      await pumpEventQueue();
      expect(probe.calls, [
        ['a'],
      ]);

      epoch = 2;
      probe.answer({
        'a': const ProbeAnswer(
          value: 'ok',
          coreEpoch: 2,
          picksVersion: 1,
          chains: ['HK-01'],
        ),
      });
      await pumpEventQueue();

      verify(() => core.watchRoute(true)).called(2);
      expect(container.read(routeTrackerProvider).coreEpoch, 2);
      expect(probe.calls, [
        ['a'],
        ['a'],
      ]);

      probe.answer({
        'a': const ProbeAnswer(
          value: 'ok',
          coreEpoch: 2,
          picksVersion: 1,
          chains: ['HK-01'],
        ),
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
          () => const RouteSnapshot(coreEpoch: 1, picksVersion: 1),
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
        reads.last.complete(const RouteSnapshot(coreEpoch: 1, picksVersion: 1));
        await pumpEventQueue();
        probe.answer({
          'a': const ProbeAnswer(
            value: 'ok',
            coreEpoch: 1,
            picksVersion: 1,
            chains: ['HK-01'],
          ),
        });
        await pumpEventQueue();

        container.read(appVisibleProvider.notifier).value = false;
        container.read(routeTrackerProvider.notifier).bumpHostEpoch();
        await pumpEventQueue();
        container.read(appVisibleProvider.notifier).value = true;
        await pumpEventQueue();
        expect(probe.calls, hasLength(1));

        reads.last.complete(const RouteSnapshot(coreEpoch: 1, picksVersion: 2));
        await pumpEventQueue();
        expect(probe.calls, hasLength(2));
      },
    );

    test(
      'a target left while the Core was away is asked again on return',
      () async {
        final container = live(
          () => const RouteSnapshot(coreEpoch: 1, picksVersion: 1),
        );
        final probe = container.read(_probeProvider.notifier);
        probe.watch('a');
        await pumpEventQueue();
        probe.answer({
          'a': const ProbeAnswer(
            value: 'ok',
            coreEpoch: 1,
            picksVersion: 1,
            chains: ['HK-01'],
          ),
        });
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

        expect(probe.calls, [
          ['a'],
          ['b'],
          ['a'],
        ]);
      },
    );

    test('the last watcher releases the tracker', () async {
      final container = live(
        () => const RouteSnapshot(coreEpoch: 1, picksVersion: 1),
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
