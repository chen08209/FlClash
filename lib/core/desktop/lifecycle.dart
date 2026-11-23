import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

import 'launcher.dart';
import 'model.dart';
import 'transport.dart';

abstract interface class DesktopCoreLifecycleController {
  Stream<DesktopCoreFailure> get crashEvents;

  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();
}

enum _Goal { running, stopped, closed }

final class _Intent {
  final int revision;
  final _Goal goal;

  /// A restart: only a Core that came up after this intent was issued will do.
  final bool fresh;

  const _Intent(this.revision, this.goal, {this.fresh = false});

  bool keeps(_Live core) {
    return goal == _Goal.running && (!fresh || core.epoch >= revision);
  }
}

final class _Command {
  final _Intent intent;
  final Completer<CoreLifecycleResult> completer =
      Completer<CoreLifecycleResult>();

  _Command(this.intent);
}

sealed class _Core {
  const _Core();
}

final class _Absent extends _Core {
  const _Absent();
}

final class _Live extends _Core {
  final DesktopCoreSession session;

  /// The newest revision issued before its launcher was chosen.
  final int epoch;

  const _Live(this.session, this.epoch);
}

/// A process still to be stopped: one being stopped now, lost to a crash, or
/// whose exit could not be confirmed. Nothing starts while it remains.
final class _Leftover extends _Core {
  final CoreProcessLease lease;

  const _Leftover(this.lease);
}

final class DesktopCoreLifecycle implements DesktopCoreLifecycleController {
  final DesktopCoreTransport transport;
  final DesktopCoreLauncherResolver launcherResolver;
  final DesktopCoreTimeouts timeouts;
  final String Function() sessionIdFactory;
  final bool verifyPeerPid;

  final StreamController<DesktopCoreState> _states =
      StreamController<DesktopCoreState>.broadcast();
  final StreamController<DesktopCoreFailure> _crashes =
      StreamController<DesktopCoreFailure>.broadcast();
  final List<_Command> _commands = [];
  late final StreamSubscription<DesktopTransportEvent> _transportEvents;

  DesktopCoreState _state = const DesktopCoreIdle();
  _Core _core = const _Absent();
  _Intent _desired = const _Intent(0, _Goal.stopped);
  Completer<void> _desiredChanged = Completer<void>();
  Future<CoreLifecycleResult>? _closing;
  int _revision = 0;
  bool _working = false;
  bool _crashCleanupDue = false;

  DesktopCoreLifecycle({
    required this.transport,
    required this.launcherResolver,
    this.timeouts = const DesktopCoreTimeouts(),
    this.sessionIdFactory = createCoreSessionId,
    this.verifyPeerPid = false,
  }) {
    _transportEvents = transport.events.listen(_handleTransportEvent);
  }

  DesktopCoreState get state => _state;

  Stream<DesktopCoreState> get states => _states.stream;

  @override
  Stream<DesktopCoreFailure> get crashEvents => _crashes.stream;

  @override
  Future<CoreLifecycleResult> start() => _submit(_Goal.running);

  @override
  Future<CoreLifecycleResult> restart() => _submit(_Goal.running, fresh: true);

  @override
  Future<CoreLifecycleResult> stop() => _submit(_Goal.stopped);

  @override
  Future<CoreLifecycleResult> close() => _closing ??= _submit(_Goal.closed);

  bool get _wantsCore => _desired.goal == _Goal.running;

  bool get _closingDown => _desired.goal == _Goal.closed;

  Future<CoreLifecycleResult> _submit(_Goal goal, {bool fresh = false}) {
    if (_closingDown) {
      return Future.error(
        DesktopCoreFailure(
          code: 'lifecycle_closed',
          phase: DesktopCorePhase.closed,
          revision: _revision,
        ),
      );
    }
    final command = _Command(_Intent(++_revision, goal, fresh: fresh));
    _commands.add(command);
    _desired = command.intent;
    final changed = _desiredChanged;
    _desiredChanged = Completer<void>();
    changed.complete();
    _wake();
    return command.completer.future;
  }

  void _wake() {
    if (_working) {
      return;
    }
    _working = true;
    unawaited(_work());
  }

  Future<void> _work() async {
    try {
      while (true) {
        if (_crashCleanupDue) {
          _crashCleanupDue = false;
          await _cleanUpAfterCrash();
        } else if (_commands.isNotEmpty) {
          await _pursue(_desired);
        } else {
          break;
        }
      }
    } finally {
      _working = false;
    }
  }

  Future<void> _pursue(_Intent intent) async {
    try {
      await _reconcile(intent);
      final latest = _desired;
      if (_satisfies(latest)) {
        _settle(latest);
      }
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
      final superseded = _desired.revision != intent.revision;
      if (!superseded) {
        _publish(DesktopCoreFailed(failure));
      }
      // Commands a close superseded wait for the close and settle with it.
      if (!superseded || !_closingDown) {
        _failCommands(intent.revision, failure);
      }
    }
  }

  Future<void> _reconcile(_Intent intent) async {
    switch (_core) {
      case final _Live core when intent.keeps(core):
        return;
      case _Live(:final session):
        _publish(
          DesktopCoreStopping(revision: intent.revision, session: session),
        );
        _core = _Leftover(session.lease);
        await _release(session.lease, intent.revision);
      case _Leftover(:final lease):
        await _release(lease, intent.revision);
      case _Absent():
        break;
    }
    if (intent.goal == _Goal.closed) {
      await _shutDown(intent.revision);
    } else if (intent.goal == _Goal.running && _wantsCore) {
      await _start(intent.revision);
    }
  }

  bool _satisfies(_Intent intent) {
    return switch (intent.goal) {
      _Goal.running => switch (_core) {
        final _Live core => intent.keeps(core),
        _ => false,
      },
      _Goal.stopped => _core is _Absent,
      _Goal.closed => _state is DesktopCoreClosed,
    };
  }

  Future<void> _start(int revision) async {
    final sessionId = sessionIdFactory();
    _publish(DesktopCoreStarting(revision: revision, sessionId: sessionId));
    CoreProcessLease? lease;
    try {
      if (transport.connection != null ||
          transport.state == DesktopTransportState.starting) {
        await transport.reset();
      }
      final listening = await _whileWanted(
        transport.open().timeout(timeouts.ready).then((_) => true),
      );
      if (listening == null) {
        return;
      }
      final launchEpoch = _revision;
      final launcher = await launcherResolver.resolve();
      if (!_wantsCore) {
        return;
      }
      lease = await launcher.start(
        sessionId: sessionId,
        address: transport.address,
      );
      if (lease.sessionId != sessionId) {
        throw _failure(
          code: 'session_mismatch',
          phase: DesktopCorePhase.starting,
          revision: revision,
          lease: lease,
        );
      }
      final connection = await _whileWanted(
        transport.waitUntilConnected(timeouts.connection),
      );
      if (connection == null || !_wantsCore) {
        return;
      }
      if (verifyPeerPid && connection.pid != lease.pid) {
        throw _failure(
          code: 'peer_pid_mismatch',
          phase: DesktopCorePhase.starting,
          revision: revision,
          lease: lease,
          connectionGeneration: connection.generation,
          cause: StateError(
            'Expected Core PID ${lease.pid}, connected ${connection.pid}',
          ),
        );
      }
      final session = DesktopCoreSession(
        sessionId: sessionId,
        lease: lease,
        connectionGeneration: connection.generation,
      );
      lease = null;
      _core = _Live(session, launchEpoch);
      _publish(DesktopCoreRunning(session));
    } on DesktopCoreFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw _failure(
        code: 'start_failed',
        phase: DesktopCorePhase.starting,
        revision: revision,
        cause: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (lease != null) {
        await _release(lease, revision);
      }
    }
  }

  /// Completes with [operation], or with null once no Core is wanted any more.
  Future<T?> _whileWanted<T extends Object>(Future<T> operation) async {
    while (_wantsCore) {
      final result = await Future.any<T?>([
        operation,
        _desiredChanged.future.then((_) => null),
      ]);
      if (result != null) {
        return result;
      }
    }
    operation.ignore();
    return null;
  }

  /// Gives [lease] up once its process is confirmed gone. Until then it stays
  /// the leftover Core, unless the application is exiting anyway.
  Future<void> _release(CoreProcessLease lease, int revision) async {
    try {
      final result = await lease.stop(timeouts.disconnection);
      if (!result.exitConfirmed) {
        throw _failure(
          code: 'process_exit_unconfirmed',
          phase: DesktopCorePhase.stopping,
          revision: revision,
          lease: lease,
        );
      }
    } catch (error, stackTrace) {
      if (_closingDown) {
        _core = const _Absent();
        return;
      }
      _core = _Leftover(lease);
      if (error is DesktopCoreFailure) {
        rethrow;
      }
      throw _failure(
        code: 'stop_failed',
        phase: DesktopCorePhase.stopping,
        revision: revision,
        lease: lease,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    _core = const _Absent();
    await _dropStalePeer();
  }

  /// With no Core owned, a peer the transport still holds is a dead one whose
  /// disconnect has not arrived. It usually comes with the exit, so the event
  /// loop gets one turn to deliver it before the listener is rebuilt.
  Future<void> _dropStalePeer() async {
    if (_closingDown) {
      return;
    }
    if (transport.connection != null) {
      await Future<void>.delayed(Duration.zero);
    }
    if (transport.connection != null) {
      await transport.reset();
    }
  }

  Future<void> _shutDown(int revision) async {
    await _transportEvents.cancel();
    await transport.close();
    _publish(DesktopCoreClosed(revision));
    await _states.close();
    await _crashes.close();
  }

  void _settle(_Intent settled) {
    if (settled.goal == _Goal.stopped) {
      _publish(const DesktopCoreIdle());
    }
    final session = switch (_core) {
      _Live(:final session) => session,
      _ => null,
    };
    for (final _Command(:intent, :completer) in _take(settled.revision)) {
      completer.complete(
        CoreLifecycleResult(
          revision: intent.revision,
          outcome: intent.revision == settled.revision
              ? CoreLifecycleOutcome.applied
              : intent.goal == settled.goal
              ? CoreLifecycleOutcome.coalesced
              : CoreLifecycleOutcome.superseded,
          session: session,
        ),
      );
    }
  }

  void _failCommands(int revision, DesktopCoreFailure failure) {
    for (final command in _take(revision)) {
      command.completer.completeError(failure, failure.stackTrace);
    }
  }

  List<_Command> _take(int revision) {
    final taken = _commands
        .takeWhile((command) => command.intent.revision <= revision)
        .toList(growable: false);
    _commands.removeRange(0, taken.length);
    return taken;
  }

  void _handleTransportEvent(DesktopTransportEvent event) {
    final core = _core;
    if (core is! _Live) {
      return;
    }
    final session = core.session;
    switch (event) {
      case TransportDisconnected(:final generation, :final error)
          when generation == session.connectionGeneration:
        _lose(session, code: 'unexpected_disconnect', cause: error);
      case TransportFailed(:final error, :final stackTrace):
        _lose(
          session,
          code: 'transport_failed',
          cause: error,
          stackTrace: stackTrace,
        );
      case TransportReady() || TransportConnected() || TransportDisconnected():
        break;
    }
  }

  void _lose(
    DesktopCoreSession session, {
    required String code,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    _core = _Leftover(session.lease);
    final failure = _failure(
      code: code,
      phase: DesktopCorePhase.running,
      revision: _revision,
      lease: session.lease,
      connectionGeneration: session.connectionGeneration,
      cause: cause,
      stackTrace: stackTrace,
    );
    _publish(DesktopCoreFailed(failure));
    _crashes.add(failure);
    _crashCleanupDue = true;
    _wake();
  }

  Future<void> _cleanUpAfterCrash() async {
    if (_core case _Leftover(:final lease)) {
      try {
        await _release(lease, _revision);
      } catch (error) {
        // The lease stays the leftover Core and the next intent retries it.
        commonPrint.log(
          'Leftover Core ${lease.pid} not released: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    }
  }

  DesktopCoreFailure _failure({
    required String code,
    required DesktopCorePhase phase,
    required int revision,
    CoreProcessLease? lease,
    int? connectionGeneration,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return DesktopCoreFailure(
      code: code,
      phase: phase,
      revision: revision,
      sessionId: lease?.sessionId,
      owner: lease?.owner,
      pid: lease?.pid,
      connectionGeneration: connectionGeneration,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  void _publish(DesktopCoreState state) {
    _state = state;
    _states.add(state);
  }
}
