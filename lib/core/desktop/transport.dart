import 'dart:async';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:rust_api/rust_api.dart';

import 'ipc_auth.dart';

typedef IpcServerBinder = Future<IpcServer> Function(String address);

enum DesktopTransportState { idle, starting, ready, connected, failed, closed }

sealed class DesktopTransportEvent {
  const DesktopTransportEvent();
}

final class TransportReady extends DesktopTransportEvent {
  const TransportReady();
}

final class TransportConnected extends DesktopTransportEvent {
  final int? pid;
  final int generation;

  const TransportConnected({required this.pid, required this.generation});
}

final class TransportDisconnected extends DesktopTransportEvent {
  final int generation;
  final Object? error;

  const TransportDisconnected(this.generation, {this.error});
}

final class TransportFailed extends DesktopTransportEvent {
  final Object error;
  final StackTrace stackTrace;

  const TransportFailed(this.error, this.stackTrace);
}

abstract interface class DesktopCoreTransport {
  String get address;

  DesktopTransportState get state;

  /// Its generation is never reused, not even after a [reset].
  TransportConnected? get connection;

  Stream<DesktopTransportEvent> get events;

  Stream<Uint8List> get frames;

  Future<void> open();

  /// The next connection must prove it holds [sessionId], the token the Core
  /// was started with, before it is reported as connected.
  void expectSession(String sessionId);

  /// Stops listening, which is the only way to drop a connected peer.
  Future<void> reset();

  Future<TransportConnected> waitUntilConnected(Duration timeout);

  void send(List<int> frame);

  Future<void> close();
}

final class IpcCoreTransport implements DesktopCoreTransport {
  @override
  final String address;

  final IpcServerBinder _bind;
  final Duration _handshakeTimeout;
  final StreamController<DesktopTransportEvent> _events =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frames =
      StreamController<Uint8List>.broadcast();

  String? _sessionToken;
  IpcHandshake? _handshake;
  Timer? _handshakeTimer;
  int? _pendingPid;
  DesktopTransportState _state = DesktopTransportState.idle;
  ({IpcServer server, StreamSubscription<IpcEvent> events})? _listener;
  TransportConnected? _connection;
  TransportFailed? _failure;
  Future<void>? _opening;
  Future<void>? _closing;
  Future<void> _serverDropped = Future.value();
  int _generation = 0;
  int _bindAttempt = 0;

  IpcCoreTransport({
    required this.address,
    IpcServerBinder? bind,
    Duration handshakeTimeout = const Duration(seconds: 5),
  }) : _bind = bind ?? _bindIpcServer,
       _handshakeTimeout = handshakeTimeout;

  static Future<IpcServer> _bindIpcServer(String address) {
    return IpcServer.bind(address: address);
  }

  @override
  DesktopTransportState get state => _state;

  @override
  TransportConnected? get connection => _connection;

  @override
  Stream<DesktopTransportEvent> get events => _events.stream;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Future<void> open() {
    return switch (_state) {
      DesktopTransportState.closed => Future.error(
        StateError('IPC transport is closed'),
      ),
      DesktopTransportState.ready ||
      DesktopTransportState.connected => Future.value(),
      DesktopTransportState.starting => _opening!,
      DesktopTransportState.idle ||
      DesktopTransportState.failed => _opening = _open(),
    };
  }

  Future<void> _open() async {
    final attempt = ++_bindAttempt;
    void checkStillWanted() {
      if (attempt != _bindAttempt) {
        throw StateError('IPC transport stopped listening while binding');
      }
    }

    _state = DesktopTransportState.starting;
    _failure = null;
    try {
      await _serverDropped;
      checkStillWanted();
      final server = await _bind(address);
      if (attempt != _bindAttempt) {
        await server.close();
      }
      checkStillWanted();
      _listener = (server: server, events: _listen(server));
      _state = DesktopTransportState.ready;
      commonPrint.log('IPC Ready');
      _events.add(const TransportReady());
    } catch (error, stackTrace) {
      if (attempt == _bindAttempt) {
        _fail(error, stackTrace);
      }
      rethrow;
    }
  }

  StreamSubscription<IpcEvent> _listen(IpcServer server) {
    bool inUse() => identical(server, _listener?.server);
    return server.events().listen(
      (event) {
        if (inUse()) {
          _handleEvent(event);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (inUse()) {
          _fail(error, stackTrace);
        }
      },
      onDone: () {
        if (inUse()) {
          _fail(
            StateError('IPC server stopped unexpectedly'),
            StackTrace.current,
          );
        }
      },
    );
  }

  void _handleEvent(IpcEvent event) {
    switch (event.kind) {
      case IpcEventKind.connected:
        _authenticate(event.pid);
      case IpcEventKind.message:
        final handshake = _handshake;
        if (handshake == null) {
          _frames.add(event.payload);
        } else {
          _continueHandshake(handshake, event.payload);
        }
      case IpcEventKind.disconnected:
        _endHandshake();
        final error = event.error;
        _disconnect(error == null ? null : StateError('IPC error: $error'));
      case IpcEventKind.failed:
        _fail(StateError('IPC error: ${event.error}'), StackTrace.current);
    }
  }

  @override
  void expectSession(String sessionId) {
    _sessionToken = sessionId;
  }

  void _authenticate(int? pid) {
    final token = _sessionToken;
    _sessionToken = null;
    if (token == null) {
      _rejectPeer(const IpcAuthException('no session is expecting a Core'));
      return;
    }
    _pendingPid = pid;
    _handshake = IpcHandshake(token);
    _handshakeTimer = Timer(_handshakeTimeout, () {
      _rejectPeer(const IpcAuthException('the peer did not answer in time'));
    });
  }

  void _continueHandshake(IpcHandshake handshake, Uint8List frame) {
    try {
      final reply = handshake.receive(frame);
      if (reply != null) {
        _listener?.server.send(message: reply);
      }
    } on IpcAuthException catch (error) {
      _rejectPeer(error);
      return;
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
      return;
    }
    if (handshake.isComplete) {
      final pid = _pendingPid;
      _endHandshake();
      _connect(pid);
    }
  }

  void _endHandshake() {
    _handshake = null;
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
    _pendingPid = null;
  }

  /// The server takes one peer at a time and has no call to drop it, so
  /// refusing a peer fails the transport, which drops the server.
  void _rejectPeer(IpcAuthException error) {
    _fail(error, StackTrace.current);
  }

  void _connect(int? pid) {
    commonPrint.log('IPC Connected${pid == null ? '' : ': $pid'}');
    final connection = TransportConnected(pid: pid, generation: ++_generation);
    _connection = connection;
    _state = DesktopTransportState.connected;
    _events.add(connection);
  }

  void _disconnect(Object? error) {
    final connection = _connection;
    if (connection == null) {
      return;
    }
    commonPrint.log(
      'IPC Disconnected${error == null ? '' : ': $error'}',
      logLevel: error == null ? LogLevel.info : LogLevel.warning,
    );
    _connection = null;
    _state = DesktopTransportState.ready;
    _events.add(TransportDisconnected(connection.generation, error: error));
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_state == DesktopTransportState.failed ||
        _state == DesktopTransportState.closed) {
      return;
    }
    _endHandshake();
    commonPrint.log('IPC error: $error', logLevel: LogLevel.debug);
    final failure = TransportFailed(error, stackTrace);
    _connection = null;
    _failure = failure;
    _state = DesktopTransportState.failed;
    _dropServer().ignore();
    _events.add(failure);
  }

  /// Later binds wait for the drop, because a server that is still closing
  /// holds the address. Its event stream is cancelled last: cancelling the
  /// native stream of a server that is still open does not complete.
  Future<void> _dropServer() {
    final listener = _listener;
    _listener = null;
    if (listener == null) {
      return _serverDropped;
    }
    final dropping = _serverDropped.then((_) async {
      try {
        await listener.server.close();
      } finally {
        await listener.events.cancel();
      }
    });
    _serverDropped = dropping.then((_) {}, onError: (Object _) {});
    return dropping;
  }

  @override
  Future<void> reset() async {
    if (_state == DesktopTransportState.closed) {
      throw StateError('IPC transport is closed');
    }
    final binding = _state == DesktopTransportState.starting ? _opening : null;
    _bindAttempt++;
    _endHandshake();
    _disconnect(StateError('IPC transport was reset'));
    _state = DesktopTransportState.idle;
    _failure = null;
    await binding?.then((_) {}, onError: (Object _) {});
    await _dropServer();
  }

  @override
  Future<TransportConnected> waitUntilConnected(Duration timeout) {
    if (_connection case final connection?) {
      return Future.value(connection);
    }
    if (_failure case TransportFailed(:final error, :final stackTrace)) {
      return Future.error(error, stackTrace);
    }
    if (_state == DesktopTransportState.closed) {
      return Future.error(StateError('IPC transport is closed'));
    }
    return events
        .firstWhere(
          (event) => event is TransportConnected || event is TransportFailed,
        )
        .then<TransportConnected>((event) {
          if (event case TransportConnected()) {
            return event;
          }
          final failure = event as TransportFailed;
          Error.throwWithStackTrace(failure.error, failure.stackTrace);
        })
        .timeout(timeout);
  }

  @override
  void send(List<int> frame) {
    final server = _listener?.server;
    if (server == null) {
      throw StateError(
        _state == DesktopTransportState.closed
            ? 'IPC transport is closed'
            : 'IPC transport is not open',
      );
    }
    server.send(message: frame);
  }

  @override
  Future<void> close() {
    return _closing ??= _close();
  }

  Future<void> _close() async {
    _bindAttempt++;
    _state = DesktopTransportState.closed;
    _connection = null;
    _endHandshake();
    try {
      await _dropServer();
    } finally {
      await _events.close();
      await _frames.close();
    }
  }
}
