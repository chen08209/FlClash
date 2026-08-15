import 'dart:async';

import 'launcher.dart';
import 'model.dart';
import 'transport.dart';

abstract interface class DesktopCoreLifecycleController {
  DesktopCoreState get state;

  Stream<DesktopCoreState> get states;

  Stream<DesktopCoreFailure> get crashEvents;

  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  Future<DesktopCoreSession> waitUntilRunning(Duration timeout);
}

enum _LifecycleTarget { running, restarted, stopped, closed }

enum _LifecycleAchievement { runningExisting, runningFresh, idle, closed }

final class _LifecycleIntent {
  final int revision;
  final _LifecycleTarget target;

  const _LifecycleIntent(this.revision, this.target);
}

final class _PendingLifecycleCommand {
  final _LifecycleIntent intent;
  final Completer<CoreLifecycleResult> completer =
      Completer<CoreLifecycleResult>();

  _PendingLifecycleCommand(this.intent);
}

final class _SessionDisconnect {
  final DesktopCoreSession session;
  final Completer<void> _completed = Completer<void>();

  _SessionDisconnect(this.session);

  Future<void> get future => _completed.future;

  bool get isCompleted => _completed.isCompleted;

  void record(int generation) {
    if (generation == session.connectionGeneration && !_completed.isCompleted) {
      _completed.complete();
    }
  }
}

final class _TransportConnectionWaiter {
  final Completer<void> _settled = Completer<void>();
  late final StreamSubscription<DesktopTransportEvent> _subscription;
  late final Timer _timer;
  TransportConnected? _connection;
  Object? _error;
  StackTrace? _stackTrace;

  _TransportConnectionWaiter(
    Stream<DesktopTransportEvent> events,
    Duration timeout,
  ) {
    _subscription = events.listen(
      (event) {
        switch (event) {
          case TransportConnected():
            if (!_settled.isCompleted) {
              _connection = event;
              _settled.complete();
            }
          case TransportFailed(:final error, :final stackTrace):
            if (!_settled.isCompleted) {
              _error = error;
              _stackTrace = stackTrace;
              _settled.complete();
            }
          case TransportReady() || TransportDisconnected():
            break;
        }
      },
      onDone: () {
        if (!_settled.isCompleted) {
          _error = StateError('Core transport closed before connection');
          _stackTrace = StackTrace.current;
          _settled.complete();
        }
      },
    );
    _timer = Timer(timeout, () {
      if (!_settled.isCompleted) {
        _error = TimeoutException(
          'Core transport connection timed out',
          timeout,
        );
        _stackTrace = StackTrace.current;
        _settled.complete();
      }
    });
  }

  Future<TransportConnected> get future async {
    await _settled.future;
    final error = _error;
    if (error != null) {
      Error.throwWithStackTrace(error, _stackTrace ?? StackTrace.current);
    }
    return _connection!;
  }

  Future<void> cancel() async {
    _timer.cancel();
    await _subscription.cancel();
  }
}

final class DesktopCoreLifecycle implements DesktopCoreLifecycleController {
  final DesktopCoreTransport Function() transportFactory;
  final DesktopCoreLauncherResolver launcherResolver;
  final DesktopCoreTimeouts timeouts;
  final String Function() sessionIdFactory;
  final bool verifyPeerPid;
  final DesktopCoreTransportBinding _transport;

  final StreamController<DesktopCoreState> _stateController =
      StreamController<DesktopCoreState>.broadcast();
  final StreamController<DesktopCoreFailure> _crashController =
      StreamController<DesktopCoreFailure>.broadcast();
  final List<_PendingLifecycleCommand> _pending = [];

  late final StreamSubscription<DesktopTransportEvent> _transportSubscription;
  DesktopCoreState _state = const DesktopCoreIdle();
  DesktopCoreSession? _session;
  _SessionDisconnect? _sessionDisconnect;
  Future<void>? _worker;
  Future<void>? _unexpectedDisconnectOperation;
  CoreProcessLease? _unconfirmedLease;
  Future<CoreLifecycleResult>? _closeResult;
  int _revision = 0;
  _LifecycleIntent _desired = const _LifecycleIntent(
    0,
    _LifecycleTarget.stopped,
  );
  Completer<void> _intentChanged = Completer<void>();
  bool _terminalRequested = false;

  factory DesktopCoreLifecycle({
    required DesktopCoreTransport Function() transportFactory,
    required DesktopCoreLauncherResolver launcherResolver,
    DesktopCoreTimeouts timeouts = const DesktopCoreTimeouts(),
    String Function()? sessionIdFactory,
    bool verifyPeerPid = false,
  }) {
    return DesktopCoreLifecycle._(
      transportFactory: transportFactory,
      launcherResolver: launcherResolver,
      timeouts: timeouts,
      sessionIdFactory: sessionIdFactory ?? createCoreSessionId,
      verifyPeerPid: verifyPeerPid,
      transport: DesktopCoreTransportBinding(transportFactory()),
    );
  }

  DesktopCoreLifecycle._({
    required this.transportFactory,
    required this.launcherResolver,
    required this.timeouts,
    required this.sessionIdFactory,
    required this.verifyPeerPid,
    required DesktopCoreTransportBinding transport,
  }) : _transport = transport {
    _transportSubscription = _transport.events.listen(_handleTransportEvent);
  }

  DesktopCoreTransport get transport => _transport;

  @override
  DesktopCoreState get state => _state;

  @override
  Stream<DesktopCoreState> get states => _stateController.stream;

  @override
  Stream<DesktopCoreFailure> get crashEvents => _crashController.stream;

  @override
  Future<CoreLifecycleResult> start() => _submit(_LifecycleTarget.running);

  @override
  Future<CoreLifecycleResult> restart() => _submit(_LifecycleTarget.restarted);

  @override
  Future<CoreLifecycleResult> stop() => _submit(_LifecycleTarget.stopped);

  @override
  Future<CoreLifecycleResult> close() {
    final closeResult = _closeResult;
    if (closeResult != null) {
      return closeResult;
    }
    final result = _submit(_LifecycleTarget.closed);
    _closeResult = result;
    return result;
  }

  Future<CoreLifecycleResult> _submit(_LifecycleTarget target) {
    if (_terminalRequested) {
      return Future.error(
        DesktopCoreFailure(
          code: 'lifecycle_closed',
          phase: DesktopCorePhase.closed,
          revision: _revision,
        ),
      );
    }
    if (target == _LifecycleTarget.closed) {
      _terminalRequested = true;
    }
    final intent = _LifecycleIntent(++_revision, target);
    final command = _PendingLifecycleCommand(intent);
    _pending.add(command);
    _desired = intent;
    final changed = _intentChanged;
    _intentChanged = Completer<void>();
    if (!changed.isCompleted) {
      changed.complete();
    }
    _ensureWorker();
    return command.completer.future;
  }

  void _ensureWorker() {
    if (_worker != null) {
      return;
    }
    late final Future<void> worker;
    worker = _runWorker().whenComplete(() {
      if (identical(_worker, worker)) {
        _worker = null;
      }
      if (_pending.isNotEmpty) {
        _ensureWorker();
      }
    });
    _worker = worker;
  }

  Future<void> _runWorker() async {
    while (_pending.isNotEmpty) {
      final recovery = _unexpectedDisconnectOperation;
      if (recovery != null) {
        await recovery;
      }
      final intent = _desired;
      try {
        final achievement = await _reconcile(intent);
        final settled = _desired;
        if (!_satisfies(achievement, settled.target)) {
          continue;
        }
        _completeCommands(settled);
      } catch (error, stackTrace) {
        final failure = error is DesktopCoreFailure
            ? error
            : _failure(
                code: 'lifecycle_error',
                phase: _state.phase,
                revision: intent.revision,
                cause: error,
                stackTrace: stackTrace,
              );
        final desired = _desired;
        if (desired.revision != intent.revision) {
          if (desired.target != _LifecycleTarget.closed) {
            _failCommands(intent.revision, failure);
          }
          continue;
        }
        _publish(DesktopCoreFailed(failure));
        _failCommands(intent.revision, failure);
      }
    }
  }

  Future<_LifecycleAchievement> _reconcile(_LifecycleIntent intent) async {
    final unconfirmedLease = _unconfirmedLease;
    if (unconfirmedLease != null) {
      if (intent.target == _LifecycleTarget.closed) {
        await _stopUnconfirmedLease(unconfirmedLease, allowFailure: true);
      } else if (intent.target == _LifecycleTarget.stopped) {
        await _stopUnconfirmedLease(unconfirmedLease, allowFailure: false);
      } else {
        throw _failure(
          code: 'process_exit_unconfirmed',
          phase: DesktopCorePhase.failed,
          revision: intent.revision,
          lease: unconfirmedLease,
        );
      }
    }
    switch (intent.target) {
      case _LifecycleTarget.running:
        final running = _session;
        if (running != null) {
          if (_state is DesktopCoreRunning) {
            return _LifecycleAchievement.runningExisting;
          }
          await _stopSession(
            running,
            intent.revision,
            allowUnconfirmedExit: _terminalRequested,
          );
          if (!_wantsRunning) {
            return _abandonedStart();
          }
        }
        return _startForIntent(intent);
      case _LifecycleTarget.restarted:
        final session = _session;
        if (session != null) {
          await _stopSession(
            session,
            intent.revision,
            allowUnconfirmedExit: _terminalRequested,
          );
        }
        if (!_wantsRunning) {
          return _abandonedStart();
        }
        return _startForIntent(intent);
      case _LifecycleTarget.stopped:
        final session = _session;
        if (session != null) {
          await _stopSession(
            session,
            intent.revision,
            allowUnconfirmedExit: false,
          );
        }
        if (_desired.target == _LifecycleTarget.stopped) {
          _publish(const DesktopCoreIdle());
        }
        return _LifecycleAchievement.idle;
      case _LifecycleTarget.closed:
        final session = _session;
        if (session != null) {
          await _stopSession(
            session,
            intent.revision,
            allowUnconfirmedExit: true,
          );
        }
        await _transportSubscription.cancel();
        await _transport.close();
        _publish(DesktopCoreClosed(intent.revision));
        await _stateController.close();
        await _crashController.close();
        return _LifecycleAchievement.closed;
    }
  }

  bool get _wantsRunning {
    return _desired.target == _LifecycleTarget.running ||
        _desired.target == _LifecycleTarget.restarted;
  }

  Future<_LifecycleAchievement> _startForIntent(_LifecycleIntent intent) async {
    if (await _startSession(intent.revision)) {
      return _LifecycleAchievement.runningFresh;
    }
    return _abandonedStart();
  }

  _LifecycleAchievement _abandonedStart() {
    if (_desired.target == _LifecycleTarget.stopped) {
      _publish(const DesktopCoreIdle());
    }
    return _LifecycleAchievement.idle;
  }

  Future<bool> _startSession(int revision) async {
    final sessionId = sessionIdFactory();
    _publish(DesktopCoreStarting(revision: revision, sessionId: sessionId));
    CoreProcessLease? lease;
    var leaseReleased = false;
    _TransportConnectionWaiter? connectionWaiter;

    Future<void> releaseLease() async {
      final ownedLease = lease;
      if (ownedLease == null || leaseReleased) {
        return;
      }
      leaseReleased = true;
      await _cleanObsoleteLease(ownedLease, revision);
    }

    try {
      if (!await _ensureTransportReady()) {
        return false;
      }
      final launcher = await launcherResolver.resolve();
      if (!_wantsRunning) {
        return false;
      }
      connectionWaiter = _TransportConnectionWaiter(
        _transport.events,
        timeouts.connection,
      );
      lease = await launcher.start(
        sessionId: sessionId,
        address: _transport.address,
      );
      if (lease.sessionId != sessionId) {
        await releaseLease();
        throw _failure(
          code: 'session_mismatch',
          phase: DesktopCorePhase.starting,
          revision: revision,
          lease: lease,
        );
      }
      if (!_wantsRunning) {
        await releaseLease();
        return false;
      }
      final connected = await _waitForConnectionWhileWanted(
        connectionWaiter.future,
      );
      if (connected == null || !_wantsRunning) {
        await releaseLease();
        return false;
      }
      if (verifyPeerPid && connected.pid != lease.pid) {
        await releaseLease();
        throw _failure(
          code: 'peer_pid_mismatch',
          phase: DesktopCorePhase.starting,
          revision: revision,
          lease: lease,
          connectionGeneration: connected.generation,
          cause: StateError(
            'Expected Core PID ${lease.pid}, connected ${connected.pid}',
          ),
        );
      }
      final session = DesktopCoreSession(
        sessionId: sessionId,
        lease: lease,
        connectionGeneration: connected.generation,
      );
      _session = session;
      _sessionDisconnect = _SessionDisconnect(session);
      leaseReleased = true;
      _publish(DesktopCoreRunning(session));
      return true;
    } catch (error, stackTrace) {
      try {
        await releaseLease();
      } on DesktopCoreFailure catch (cleanupFailure) {
        Error.throwWithStackTrace(
          cleanupFailure,
          cleanupFailure.stackTrace ?? stackTrace,
        );
      }
      if (error is DesktopCoreFailure) {
        Error.throwWithStackTrace(error, error.stackTrace ?? stackTrace);
      }
      throw _failure(
        code: 'start_failed',
        phase: DesktopCorePhase.starting,
        revision: revision,
        cause: error,
        stackTrace: stackTrace,
      );
    } finally {
      await connectionWaiter?.cancel();
    }
  }

  Future<bool> _ensureTransportReady() async {
    if (_transport.state == DesktopTransportState.failed ||
        _transport.state == DesktopTransportState.closed ||
        (_transport.state == DesktopTransportState.connected &&
            _session == null)) {
      await _transport.replace(transportFactory());
    }
    if (_transport.state == DesktopTransportState.ready ||
        _transport.state == DesktopTransportState.connected) {
      return true;
    }
    final opening = _transport.open().timeout(timeouts.ready);
    while (_wantsRunning) {
      final changed = _intentChanged.future;
      final result = await Future.any<Object?>([
        opening.then<Object?>((_) => true),
        changed.then<Object?>((_) => false),
      ]);
      if (result == true) {
        return true;
      }
    }
    return false;
  }

  Future<TransportConnected?> _waitForConnectionWhileWanted(
    Future<TransportConnected> connection,
  ) async {
    while (_wantsRunning) {
      final changed = _intentChanged.future;
      final result = await Future.any<Object?>([
        connection,
        changed.then<Object?>((_) => null),
      ]);
      if (result is TransportConnected) {
        return result;
      }
    }
    return null;
  }

  Future<void> _cleanObsoleteLease(CoreProcessLease lease, int revision) async {
    late final CoreProcessStopResult result;
    try {
      result = await lease.stop(timeouts.disconnection);
    } catch (error, stackTrace) {
      _unconfirmedLease = lease;
      throw _failure(
        code: 'process_cleanup_failed',
        phase: DesktopCorePhase.stopping,
        revision: revision,
        lease: lease,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (result.exitConfirmed) {
      if (identical(_unconfirmedLease, lease)) {
        _unconfirmedLease = null;
      }
      return;
    }
    _unconfirmedLease = lease;
    throw _failure(
      code: 'process_exit_unconfirmed',
      phase: DesktopCorePhase.stopping,
      revision: revision,
      lease: lease,
    );
  }

  Future<void> _stopUnconfirmedLease(
    CoreProcessLease lease, {
    required bool allowFailure,
  }) async {
    try {
      final result = await lease.stop(timeouts.disconnection);
      if (result.exitConfirmed) {
        _unconfirmedLease = null;
      } else if (!allowFailure) {
        throw _failure(
          code: 'process_exit_unconfirmed',
          phase: DesktopCorePhase.stopping,
          revision: _desired.revision,
          lease: lease,
        );
      }
    } catch (_) {
      if (!allowFailure) {
        rethrow;
      }
    } finally {
      if (allowFailure) {
        _unconfirmedLease = null;
      }
    }
  }

  Future<void> _stopSession(
    DesktopCoreSession session,
    int revision, {
    required bool allowUnconfirmedExit,
  }) async {
    _publish(DesktopCoreStopping(revision: revision, session: session));
    final disconnected = _disconnectFor(session);
    try {
      final stopResult = await session.lease.stop(timeouts.disconnection);
      if (!stopResult.exitConfirmed) {
        if (!allowUnconfirmedExit) {
          throw _failure(
            code: 'process_exit_unconfirmed',
            phase: DesktopCorePhase.stopping,
            revision: revision,
            session: session,
          );
        }
        _clearSession(session);
        return;
      }
      if (!disconnected.isCompleted) {
        await Future.any<void>([
          disconnected.future,
          Future<void>.delayed(Duration.zero),
        ]);
      }
      if (!disconnected.isCompleted) {
        _clearSession(session);
        if (!_terminalRequested) {
          await _transport.replace(transportFactory());
        }
        return;
      }
      _clearSession(session);
    } on DesktopCoreFailure {
      rethrow;
    } catch (error, stackTrace) {
      if (allowUnconfirmedExit) {
        _clearSession(session);
        return;
      }
      throw _failure(
        code: 'stop_failed',
        phase: DesktopCorePhase.stopping,
        revision: revision,
        session: session,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  _SessionDisconnect _disconnectFor(DesktopCoreSession session) {
    final current = _sessionDisconnect;
    if (current != null && identical(current.session, session)) {
      return current;
    }
    return _sessionDisconnect = _SessionDisconnect(session);
  }

  void _clearSession(DesktopCoreSession session) {
    if (identical(_session, session)) {
      _session = null;
    }
    if (identical(_sessionDisconnect?.session, session)) {
      _sessionDisconnect = null;
    }
  }

  bool _satisfies(_LifecycleAchievement achievement, _LifecycleTarget target) {
    return switch (target) {
      _LifecycleTarget.running =>
        achievement == _LifecycleAchievement.runningExisting ||
            achievement == _LifecycleAchievement.runningFresh,
      _LifecycleTarget.restarted =>
        achievement == _LifecycleAchievement.runningFresh,
      _LifecycleTarget.stopped => achievement == _LifecycleAchievement.idle,
      _LifecycleTarget.closed => achievement == _LifecycleAchievement.closed,
    };
  }

  void _completeCommands(_LifecycleIntent settled) {
    final commands = _pending
        .where((command) => command.intent.revision <= settled.revision)
        .toList(growable: false);
    _pending.removeWhere(
      (command) => command.intent.revision <= settled.revision,
    );
    for (final command in commands) {
      final outcome = command.intent.revision == settled.revision
          ? CoreLifecycleOutcome.applied
          : _targetsCoalesce(command.intent.target, settled.target)
          ? CoreLifecycleOutcome.coalesced
          : CoreLifecycleOutcome.superseded;
      command.completer.complete(
        CoreLifecycleResult(
          revision: command.intent.revision,
          outcome: outcome,
          session: _session,
        ),
      );
    }
  }

  bool _targetsCoalesce(_LifecycleTarget first, _LifecycleTarget settled) {
    final firstRuns =
        first == _LifecycleTarget.running ||
        first == _LifecycleTarget.restarted;
    final settledRuns =
        settled == _LifecycleTarget.running ||
        settled == _LifecycleTarget.restarted;
    return (firstRuns && settledRuns) || first == settled;
  }

  void _failCommands(int revision, DesktopCoreFailure failure) {
    final commands = _pending
        .where((command) => command.intent.revision <= revision)
        .toList(growable: false);
    _pending.removeWhere((command) => command.intent.revision <= revision);
    for (final command in commands) {
      command.completer.completeError(failure, failure.stackTrace);
    }
  }

  void _handleTransportEvent(DesktopTransportEvent event) {
    if (event case TransportDisconnected(:final generation)) {
      _sessionDisconnect?.record(generation);
    }
    final running = _state;
    if (running is! DesktopCoreRunning) {
      return;
    }
    switch (event) {
      case TransportDisconnected(:final generation)
          when generation == running.session.connectionGeneration:
        _handleUnexpectedDisconnect(
          running.session,
          code: 'unexpected_disconnect',
        );
      case TransportFailed(:final error, :final stackTrace):
        _handleUnexpectedDisconnect(
          running.session,
          code: 'transport_failed',
          cause: error,
          stackTrace: stackTrace,
        );
      case TransportReady() || TransportConnected() || TransportDisconnected():
        break;
    }
  }

  void _handleUnexpectedDisconnect(
    DesktopCoreSession session, {
    required String code,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    if (_unexpectedDisconnectOperation != null ||
        !identical(_session, session)) {
      return;
    }
    _clearSession(session);
    final failure = _failure(
      code: code,
      phase: DesktopCorePhase.running,
      revision: _revision,
      session: session,
      cause: cause,
      stackTrace: stackTrace,
    );
    _publish(DesktopCoreFailed(failure));
    if (!_crashController.isClosed) {
      _crashController.add(failure);
    }
    late final Future<void> operation;
    operation = session.lease
        .stop(timeouts.disconnection)
        .then<void>((result) {
          if (!result.exitConfirmed) {
            _unconfirmedLease = session.lease;
          }
        })
        .catchError((_) {
          _unconfirmedLease = session.lease;
        })
        .whenComplete(() {
          if (identical(_unexpectedDisconnectOperation, operation)) {
            _unexpectedDisconnectOperation = null;
          }
        });
    _unexpectedDisconnectOperation = operation;
  }

  DesktopCoreFailure _failure({
    required String code,
    required DesktopCorePhase phase,
    required int revision,
    DesktopCoreSession? session,
    CoreProcessLease? lease,
    int? connectionGeneration,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return DesktopCoreFailure(
      code: code,
      phase: phase,
      revision: revision,
      sessionId: session?.sessionId ?? lease?.sessionId,
      owner: session?.owner ?? lease?.owner,
      pid: session?.pid ?? lease?.pid,
      connectionGeneration:
          connectionGeneration ?? session?.connectionGeneration,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  void _publish(DesktopCoreState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  @override
  Future<DesktopCoreSession> waitUntilRunning(Duration timeout) {
    final current = _state;
    if (current is DesktopCoreRunning) {
      return Future.value(current.session);
    }
    if (current is DesktopCoreFailed) {
      return Future.error(current.failure, current.failure.stackTrace);
    }
    if (current is DesktopCoreClosed) {
      return Future.error(StateError('Desktop Core lifecycle is closed'));
    }
    return states
        .firstWhere(
          (state) =>
              state is DesktopCoreRunning ||
              state is DesktopCoreFailed ||
              state is DesktopCoreClosed,
        )
        .then<DesktopCoreSession>((state) {
          if (state case DesktopCoreRunning(:final session)) {
            return session;
          }
          if (state case DesktopCoreFailed(:final failure)) {
            Error.throwWithStackTrace(
              failure,
              failure.stackTrace ?? StackTrace.current,
            );
          }
          throw StateError('Desktop Core lifecycle is closed');
        })
        .timeout(timeout);
  }
}
