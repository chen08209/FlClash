import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _RunStateReader extends ConsumerStatefulWidget {
  const _RunStateReader();

  @override
  ConsumerState<_RunStateReader> createState() => _RunStateReaderState();
}

class _RunStateReaderState extends ConsumerState<_RunStateReader> {
  @override
  void initState() {
    super.initState();
    ref.read(isStartProvider);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const _state = RouteState(
  coreEpoch: 3,
  routeVersion: 5,
  hostEpoch: 2,
  proxied: true,
  synced: true,
);

const _snapshot = RouteSnapshot(coreEpoch: 3, routeVersion: 1);

RouteStamp _stamp({
  int coreEpoch = 3,
  int routeVersion = 5,
  int hostEpoch = 2,
  bool proxied = true,
}) => RouteStamp(
  coreEpoch: coreEpoch,
  routeVersion: routeVersion,
  hostEpoch: hostEpoch,
  proxied: proxied,
  hits: const [RouteHit(host: 'example.com:443', exit: 'HK-01')],
);

void main() {
  group('isFresh', () {
    test('holds under the route version it was made or checked at', () {
      expect(_state.isFresh(_stamp()), isTrue);
      expect(_state.isFresh(_stamp(routeVersion: 4)), isFalse);
      expect(_state.isFresh(_stamp(routeVersion: 4).verifiedAt(5)), isTrue);
    });

    test('a newer route version is no move', () {
      expect(_state.hasMovedSince(_stamp(routeVersion: 4)), isFalse);
    });

    test('fails on either epoch', () {
      expect(_state.isFresh(_stamp(coreEpoch: 4)), isFalse);
      expect(_state.isFresh(_stamp(hostEpoch: 1)), isFalse);
      expect(_state.hasMovedSince(_stamp(coreEpoch: 4)), isTrue);
    });

    test('fails across the proxy switch', () {
      expect(_state.isFresh(_stamp(proxied: false)), isFalse);
    });

    test('holds nothing fresh before the Core has been read', () {
      expect(_state.copyWith(synced: false).isFresh(_stamp()), isFalse);
    });
  });

  test('isBehind spots counters the state has not seen', () {
    expect(_state.isBehind(_stamp()), isFalse);
    expect(_state.isBehind(_stamp(coreEpoch: 2)), isFalse);
    expect(_state.isBehind(_stamp(coreEpoch: 4)), isTrue);
    expect(_state.isBehind(_stamp(routeVersion: 6)), isTrue);
  });

  group('RouteTracker', () {
    late _MockCore core;

    setUp(() {
      core = _MockCore();
      when(() => core.watchRoute(true)).thenAnswer((_) async => _snapshot);
      when(() => core.watchRoute(false)).thenAnswer((_) async => null);
    });

    ProviderContainer build({
      bool init = true,
      CoreStatus status = CoreStatus.connected,
      bool running = true,
      bool watched = true,
    }) {
      final container = ProviderContainer(
        overrides: [
          initProvider.overrideWithBuild((_, _) => init),
          coreStatusProvider.overrideWithBuild((_, _) => status),
          runTimeProvider.overrideWithBuild((_, _) => running ? 1 : null),
          suspendProvider.overrideWithValue(false),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      if (watched) {
        container.listen(routeTrackerProvider, (_, _) {});
      }
      return container;
    }

    RouteTracker trackerOf(ProviderContainer container) =>
        container.read(routeTrackerProvider.notifier);

    RouteState stateOf(ProviderContainer container) =>
        container.read(routeTrackerProvider);

    test('proxied follows the run state', () async {
      final container = build(running: false);
      expect(stateOf(container).proxied, isFalse);

      container.read(runTimeProvider.notifier).value = 1;
      await pumpEventQueue();

      expect(stateOf(container).proxied, isTrue);
    });

    testWidgets(
      'a widget reading a run state the unwatched tracker missed mounts cleanly',
      (tester) async {
        final container = build(running: false, watched: false);
        trackerOf(container);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const SizedBox.shrink(),
          ),
        );
        container.read(runTimeProvider.notifier).value = 1;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const _RunStateReader(),
          ),
        );
        expect(tester.takeException(), isNull);

        await tester.pump();
        expect(stateOf(container).proxied, isTrue);
      },
    );

    test(
      'reads the Core once something watches and lets go when nothing does',
      () async {
        final container = build();
        final tracker = trackerOf(container);
        expect(stateOf(container).synced, isFalse);

        tracker.attach();
        await pumpEventQueue();

        verify(() => core.watchRoute(true)).called(1);
        final state = stateOf(container);
        expect(state.synced, isTrue);
        expect(state.coreEpoch, 3);
        expect(state.routeVersion, 1);
        expect(state.hostEpoch, 1);

        tracker.detach();
        await pumpEventQueue();

        verify(() => core.watchRoute(false)).called(1);
      },
    );

    test('waits for the app to initialize before reading the Core', () async {
      final container = build(init: false);
      trackerOf(container).attach();
      await pumpEventQueue();
      verifyNever(() => core.watchRoute(any()));

      container.read(initProvider.notifier).value = true;
      await pumpEventQueue();

      verify(() => core.watchRoute(true)).called(1);
      expect(stateOf(container).synced, isTrue);
    });

    test(
      'lets the Core go while the app is hidden and reads it again on return',
      () async {
        final container = build();
        trackerOf(container).attach();
        await pumpEventQueue();
        verify(() => core.watchRoute(true)).called(1);

        container.read(appVisibleProvider.notifier).value = false;
        await pumpEventQueue();

        verify(() => core.watchRoute(false)).called(1);
        expect(stateOf(container).synced, isTrue);
        expect(stateOf(container).live, isFalse);

        trackerOf(container).resync();
        await pumpEventQueue();
        verifyNever(() => core.watchRoute(true));

        container.read(appVisibleProvider.notifier).value = true;
        await pumpEventQueue();

        verify(() => core.watchRoute(true)).called(1);
        expect(stateOf(container).hostEpoch, 1);
        expect(stateOf(container).live, isTrue);
      },
    );

    test('a read asked for while one is on the way runs after it', () async {
      final reads = <Completer<RouteSnapshot?>>[];
      when(() => core.watchRoute(true)).thenAnswer((_) {
        final read = Completer<RouteSnapshot?>();
        reads.add(read);
        return read.future;
      });
      final container = build();
      final tracker = trackerOf(container);
      tracker.attach();
      await pumpEventQueue();

      container.read(appVisibleProvider.notifier).value = false;
      container.read(appVisibleProvider.notifier).value = true;
      reads.single.complete(_snapshot);
      await pumpEventQueue();

      expect(reads, hasLength(2));
      expect(stateOf(container).live, isFalse);

      reads.last.complete(_snapshot);
      await pumpEventQueue();
      expect(stateOf(container).live, isTrue);
    });

    testWidgets('a read the Core leaves unanswered is asked again', (
      tester,
    ) async {
      final answers = <RouteSnapshot? Function()>[
        () => throw Exception('no_response'),
        () => null,
        () => _snapshot,
      ];
      when(
        () => core.watchRoute(true),
      ).thenAnswer((_) async => answers.removeAt(0)());
      final container = build();
      trackerOf(container).attach();
      await tester.pump();
      expect(stateOf(container).live, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(stateOf(container).live, isFalse);

      await tester.pump(const Duration(seconds: 2));
      verify(() => core.watchRoute(true)).called(3);
      expect(stateOf(container).live, isTrue);
    });

    testWidgets('letting go stops asking again', (tester) async {
      when(() => core.watchRoute(true)).thenAnswer((_) async => null);
      final container = build();
      final tracker = trackerOf(container);
      tracker.attach();
      await tester.pump();

      tracker.detach();
      await tester.pump(const Duration(minutes: 1));

      verify(() => core.watchRoute(true)).called(1);
    });

    test('a hidden app with nothing watching leaves the Core alone', () async {
      final container = build();

      container.read(appVisibleProvider.notifier).value = false;
      container.read(appVisibleProvider.notifier).value = true;
      await pumpEventQueue();

      verifyNever(() => core.watchRoute(any()));
    });

    test(
      'a Core disconnect drops the sync and a reconnect reads it again',
      () async {
        final container = build();
        trackerOf(container).attach();
        await pumpEventQueue();

        container.read(coreStatusProvider.notifier).value =
            CoreStatus.disconnected;
        await pumpEventQueue();
        expect(stateOf(container).synced, isFalse);

        container.read(coreStatusProvider.notifier).value =
            CoreStatus.connected;
        await pumpEventQueue();

        verify(() => core.watchRoute(true)).called(2);
        expect(stateOf(container).synced, isTrue);
        expect(stateOf(container).hostEpoch, 2);
      },
    );

    test(
      'a snapshot moves the Core counters and leaves the host epoch alone',
      () async {
        final container = build();
        final tracker = trackerOf(container);
        tracker.attach();
        await pumpEventQueue();

        tracker.applySnapshot(
          const RouteSnapshot(coreEpoch: 4, routeVersion: 2),
        );

        final state = stateOf(container);
        expect(state.coreEpoch, 4);
        expect(state.routeVersion, 2);
        expect(state.hostEpoch, 1);
      },
    );

    test('a network change moves only the host epoch', () {
      final container = build();

      trackerOf(container).bumpHostEpoch();

      expect(stateOf(container).hostEpoch, 1);
      expect(stateOf(container).coreEpoch, 0);
    });
  });
}
