import 'dart:async';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:rust_api/rust_api.dart';

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
  final StreamController<DesktopTransportEvent> _events =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frames =
      StreamController<Uint8List>.broadcast();

  DesktopTransportState _state = DesktopTransportState.idle;
  ({IpcServer server, StreamSubscription<IpcEvent> events})? _listener;
  TransportConnected? _connection;
  TransportFailed? _failure;
  Future<void>? _opening;
  Future<void>? _closing;
  Future<void> _serverDropped = Future.value();
  int _generation = 0;
  int _bindAttempt = 0;

  IpcCoreTransport({required this.address, IpcServerBinder? bind})
    : _bind = bind ?? _bindIpcServer;

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
        _connect(event.pid);
      case IpcEventKind.message:
        _frames.add(event.payload);
      case IpcEventKind.disconnected:
        final error = event.error;
        _disconnect(error == null ? null : StateError('IPC error: $error'));
      case IpcEventKind.failed:
        _fail(StateError('IPC error: ${event.error}'), StackTrace.current);
    }
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
    try {
      await _dropServer();
    } finally {
      await _events.close();
      await _frames.close();
    }
  }
}
