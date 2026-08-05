import 'dart:async';

import 'package:fl_clash/core/desktop/lifecycle.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _sessionId = '0123456789abcdef0123456789abcdef';

void main() {
  test(
    'publishes running only after ready, launch, connection, and PID match',
    () async {
      final transport = FakeDesktopCoreTransport();
      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final lifecycle = _createLifecycle(
        transport: transport,
        resolver: MutableLauncherResolver(launcher),
      );

      final start = lifecycle.start();
      expect(lifecycle.state, isA<DesktopCoreStarting>());
      transport.ready();
      await launcher.started;
      expect(lifecycle.state, isNot(isA<DesktopCoreRunning>()));
      transport.connect(pid: 42, generation: 1);

      final result = await start;
      expect(result.session?.owner, CoreProcessOwner.direct);
      expect(result.session?.connectionGeneration, 1);
      expect(lifecycle.state, isA<DesktopCoreRunning>());
      await _closeRunning(lifecycle, transport, launcher.lease, 1);
    },
  );

  test(
    'restart stops the App-owned lease before resolving Helper ownership',
    () async {
      final transport = FakeDesktopCoreTransport();
      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final helper = FakeLauncher(
        owner: CoreProcessOwner.windowsHelper,
        pid: 84,
      );
      final resolver = MutableLauncherResolver(direct);
      final lifecycle = _createLifecycle(
        transport: transport,
        resolver: resolver,
      );
      await _startConnected(lifecycle, transport, direct, pid: 42);
      resolver.launcher = helper;

      final restart = lifecycle.restart();
      await direct.lease.stopStarted;
      expect(helper.startCount, 0);
      transport.disconnect(1);
      await helper.started;
      transport.connect(pid: 84, generation: 2);

      final result = await restart;
      expect(direct.lease.stopCount, 1);
      expect(result.session?.owner, CoreProcessOwner.windowsHelper);
      expect(helper.lease.stopCount, 0);
      await _closeRunning(lifecycle, transport, helper.lease, 2);
    },
  );

  test('concurrent restarts coalesce behind one replacement', () async {
    final transport = FakeDesktopCoreTransport();
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    final helper = FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 84);
    final resolver = MutableLauncherResolver(direct);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: resolver,
    );
    await _startConnected(lifecycle, transport, direct, pid: 42);
    direct.lease.stopGate = Completer<void>();
    resolver.launcher = helper;

    final first = lifecycle.restart();
    await direct.lease.stopStarted;
    final second = lifecycle.restart();
    await pumpEventQueue();
    expect(direct.lease.stopCount, 1);

    transport.disconnect(1);
    direct.lease.stopGate!.complete();
    await helper.started;
    transport.connect(pid: 84, generation: 2);

    final results = await Future.wait([first, second]);
    expect(helper.startCount, 1);
    expect(results[0].session, same(results[1].session));
    expect(results[0].outcome, CoreLifecycleOutcome.coalesced);
    expect(results[1].outcome, CoreLifecycleOutcome.applied);
    await _closeRunning(lifecycle, transport, helper.lease, 2);
  });

  test('close supersedes an in-flight start and cleans its lease', () async {
    final transport = FakeDesktopCoreTransport();
    final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: MutableLauncherResolver(launcher),
    );
    final states = <DesktopCoreState>[];
    final subscription = lifecycle.states.listen(states.add);

    final start = lifecycle.start();
    transport.ready();
    await launcher.started;
    final close = lifecycle.close();
    transport.connect(pid: 42, generation: 1);

    final startResult = await start;
    await close;
    expect(startResult.outcome, CoreLifecycleOutcome.superseded);
    expect(launcher.lease.stopCount, 1);
    expect(states.whereType<DesktopCoreRunning>(), isEmpty);
    expect(lifecycle.state, isA<DesktopCoreClosed>());
    await subscription.cancel();
  });

  test('stop supersedes an in-flight start and publishes idle', () async {
    final transport = FakeDesktopCoreTransport();
    final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: MutableLauncherResolver(launcher),
    );

    final start = lifecycle.start();
    expect(lifecycle.state, isA<DesktopCoreStarting>());
    final stop = lifecycle.stop();

    final results = await Future.wait([start, stop]);
    expect(results[0].outcome, CoreLifecycleOutcome.superseded);
    expect(results[1].outcome, CoreLifecycleOutcome.applied);
    expect(lifecycle.state, isA<DesktopCoreIdle>());
    expect(launcher.startCount, 0);
    await lifecycle.close();
  });

  test(
    'terminal close failure settles once instead of retrying forever',
    () async {
      final transport = FakeDesktopCoreTransport()
        ..closeError = StateError('close failed');
      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final lifecycle = _createLifecycle(
        transport: transport,
        resolver: MutableLauncherResolver(launcher),
      );

      final close = lifecycle.close();
      await expectLater(
        close,
        throwsA(
          isA<DesktopCoreFailure>().having(
            (error) => error.code,
            'code',
            'lifecycle_error',
          ),
        ),
      );

      expect(lifecycle.state, isA<DesktopCoreFailed>());
      expect(identical(lifecycle.close(), close), isTrue);
      expect(transport.closeCount, 1);
    },
  );

  test('expected disconnect does not emit crash', () async {
    final transport = FakeDesktopCoreTransport();
    final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: MutableLauncherResolver(launcher),
    );
    await _startConnected(lifecycle, transport, launcher, pid: 42);
    final crashes = <DesktopCoreFailure>[];
    final subscription = lifecycle.crashEvents.listen(crashes.add);

    final stop = lifecycle.stop();
    await launcher.lease.stopStarted;
    transport.disconnect(1);
    await stop;

    expect(crashes, isEmpty);
    expect(lifecycle.state, isA<DesktopCoreIdle>());
    await subscription.cancel();
    await lifecycle.close();
  });

  test(
    'unexpected disconnect cleans one session and emits one crash',
    () async {
      final transport = FakeDesktopCoreTransport();
      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final lifecycle = _createLifecycle(
        transport: transport,
        resolver: MutableLauncherResolver(launcher),
      );
      await _startConnected(lifecycle, transport, launcher, pid: 42);
      final crash = lifecycle.crashEvents.first;

      transport.disconnect(1);

      expect((await crash).code, 'unexpected_disconnect');
      await launcher.lease.stopStarted;
      await pumpEventQueue();
      expect(launcher.lease.stopCount, 1);
      expect(lifecycle.state, isA<DesktopCoreFailed>());
      await lifecycle.close();
    },
  );

  test('stale disconnect generation cannot stop the current session', () async {
    final transport = FakeDesktopCoreTransport();
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    final helper = FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 84);
    final resolver = MutableLauncherResolver(direct);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: resolver,
    );
    await _startConnected(lifecycle, transport, direct, pid: 42);
    resolver.launcher = helper;
    final restart = lifecycle.restart();
    await direct.lease.stopStarted;
    transport.disconnect(1);
    await helper.started;
    transport.connect(pid: 84, generation: 2);
    await restart;

    transport.disconnect(1);
    await pumpEventQueue();

    expect(lifecycle.state, isA<DesktopCoreRunning>());
    expect(helper.lease.stopCount, 0);
    await _closeRunning(lifecycle, transport, helper.lease, 2);
  });

  test('unconfirmed process exit blocks replacement start', () async {
    final transport = FakeDesktopCoreTransport();
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
    direct.lease.stopResult = const CoreProcessStopResult(
      stopped: true,
      exitConfirmed: false,
    );
    final helper = FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 84);
    final resolver = MutableLauncherResolver(direct);
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: resolver,
    );
    await _startConnected(lifecycle, transport, direct, pid: 42);
    resolver.launcher = helper;

    await expectLater(
      lifecycle.restart(),
      throwsA(
        isA<DesktopCoreFailure>().having(
          (error) => error.code,
          'code',
          'process_exit_unconfirmed',
        ),
      ),
    );

    expect(helper.startCount, 0);
    expect(lifecycle.state, isA<DesktopCoreFailed>());
    await lifecycle.close();
  });

  test(
    'connection timeout cleans the lease returned by the launcher',
    () async {
      final transport = FakeDesktopCoreTransport();
      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final lifecycle = DesktopCoreLifecycle(
        transportFactory: () => transport,
        launcherResolver: MutableLauncherResolver(launcher),
        sessionIdFactory: () => _sessionId,
        verifyPeerPid: true,
        timeouts: const DesktopCoreTimeouts(
          ready: Duration(seconds: 1),
          connection: Duration(milliseconds: 10),
          disconnection: Duration(seconds: 1),
        ),
      );

      final start = lifecycle.start();
      transport.ready();
      await launcher.started;

      await expectLater(
        start,
        throwsA(
          isA<DesktopCoreFailure>().having(
            (error) => error.code,
            'code',
            'start_failed',
          ),
        ),
      );
      expect(launcher.lease.stopCount, 1);
      await lifecycle.close();
    },
  );

  test(
    'confirmed exit without disconnect replaces transport before restart',
    () async {
      final transports = <FakeDesktopCoreTransport>[];
      FakeDesktopCoreTransport createTransport() {
        final transport = FakeDesktopCoreTransport(
          address: 'test-address-${transports.length + 1}',
        );
        transports.add(transport);
        return transport;
      }

      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final helper = FakeLauncher(
        owner: CoreProcessOwner.windowsHelper,
        pid: 84,
      );
      final resolver = MutableLauncherResolver(direct);
      final lifecycle = DesktopCoreLifecycle(
        transportFactory: createTransport,
        launcherResolver: resolver,
        sessionIdFactory: () => _sessionId,
        verifyPeerPid: true,
        timeouts: const DesktopCoreTimeouts(
          ready: Duration(seconds: 1),
          connection: Duration(seconds: 1),
          disconnection: Duration(milliseconds: 10),
        ),
      );
      final firstTransport = transports.single;
      await _startConnected(lifecycle, firstTransport, direct, pid: 42);
      resolver.launcher = helper;

      final restart = lifecycle.restart();
      await firstTransport.closed;
      expect(transports, hasLength(2));
      final replacement = transports.last;
      replacement.ready();
      await helper.started;
      replacement.connect(pid: 84, generation: 1);

      final result = await restart;
      expect(result.session?.owner, CoreProcessOwner.windowsHelper);
      expect(firstTransport.closeCount, 1);
      await _closeRunning(lifecycle, replacement, helper.lease, 1);
    },
  );

  test(
    'confirmed exit without disconnect replaces transport during stop',
    () async {
      final transports = <FakeDesktopCoreTransport>[];
      FakeDesktopCoreTransport createTransport() {
        final transport = FakeDesktopCoreTransport(
          address: 'test-address-${transports.length + 1}',
        );
        transports.add(transport);
        return transport;
      }

      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42);
      final lifecycle = DesktopCoreLifecycle(
        transportFactory: createTransport,
        launcherResolver: MutableLauncherResolver(launcher),
        sessionIdFactory: () => _sessionId,
        verifyPeerPid: true,
        timeouts: const DesktopCoreTimeouts(
          ready: Duration(seconds: 1),
          connection: Duration(seconds: 1),
          disconnection: Duration(milliseconds: 10),
        ),
      );
      final firstTransport = transports.single;
      await _startConnected(lifecycle, firstTransport, launcher, pid: 42);

      await lifecycle.stop();

      expect(firstTransport.closeCount, 1);
      expect(transports, hasLength(2));
      expect(lifecycle.state, isA<DesktopCoreIdle>());
      await lifecycle.close();
    },
  );

  test('PID mismatch cleans the launched lease', () async {
    final transport = FakeDesktopCoreTransport();
    final launcher = FakeLauncher(
      owner: CoreProcessOwner.windowsHelper,
      pid: 42,
    );
    final lifecycle = _createLifecycle(
      transport: transport,
      resolver: MutableLauncherResolver(launcher),
    );

    final start = lifecycle.start();
    transport.ready();
    await launcher.started;
    transport.connect(pid: 84, generation: 1);

    await expectLater(
      start,
      throwsA(
        isA<DesktopCoreFailure>().having(
          (error) => error.code,
          'code',
          'peer_pid_mismatch',
        ),
      ),
    );
    expect(launcher.lease.stopCount, 1);
    await lifecycle.close();
  });

  test(
    'connection timeout while launcher is pending is handled once',
    () async {
      final transport = FakeDesktopCoreTransport();
      final launcher = FakeLauncher(owner: CoreProcessOwner.direct, pid: 42)
        ..startGate = Completer<void>();
      final lifecycle = DesktopCoreLifecycle(
        transportFactory: () => transport,
        launcherResolver: MutableLauncherResolver(launcher),
        sessionIdFactory: () => _sessionId,
        timeouts: const DesktopCoreTimeouts(
          ready: Duration(seconds: 1),
          connection: Duration(milliseconds: 10),
          disconnection: Duration(seconds: 1),
        ),
      );

      final start = lifecycle.start();
      transport.ready();
      await launcher.started;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      launcher.startGate!.complete();

      await expectLater(start, throwsA(isA<DesktopCoreFailure>()));
      expect(launcher.lease.stopCount, 1);
      await lifecycle.close();
    },
  );
}

DesktopCoreLifecycle _createLifecycle({
  required FakeDesktopCoreTransport transport,
  required MutableLauncherResolver resolver,
}) {
  return DesktopCoreLifecycle(
    transportFactory: () => transport,
    launcherResolver: resolver,
    sessionIdFactory: () => _sessionId,
    verifyPeerPid: true,
    timeouts: const DesktopCoreTimeouts(
      ready: Duration(seconds: 1),
      connection: Duration(seconds: 1),
      disconnection: Duration(seconds: 1),
    ),
  );
}

Future<CoreLifecycleResult> _startConnected(
  DesktopCoreLifecycle lifecycle,
  FakeDesktopCoreTransport transport,
  FakeLauncher launcher, {
  required int pid,
}) async {
  final start = lifecycle.start();
  transport.ready();
  await launcher.started;
  transport.connect(pid: pid, generation: 1);
  return start;
}

Future<void> _closeRunning(
  DesktopCoreLifecycle lifecycle,
  FakeDesktopCoreTransport transport,
  FakeProcessLease lease,
  int generation,
) async {
  final close = lifecycle.close();
  await lease.stopStarted;
  transport.disconnect(generation);
  await close;
}
