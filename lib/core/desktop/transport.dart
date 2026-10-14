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

  Stream<DesktopTransportEvent> get events;

  Stream<Uint8List> get frames;

  Future<void> open();

  Future<TransportConnected> waitUntilConnected(Duration timeout);

  void send(List<int> frame);

  Future<void> close();
}

final class DesktopCoreTransportBinding implements DesktopCoreTransport {
  DesktopCoreTransport _transport;
  final StreamController<DesktopTransportEvent> _eventController =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();
  StreamSubscription<DesktopTransportEvent>? _eventSubscription;
  StreamSubscription<Uint8List>? _frameSubscription;
  Future<void>? _closeOperation;

  DesktopCoreTransportBinding(DesktopCoreTransport transport)
    : _transport = transport {
    _bind(transport);
  }

  void _bind(DesktopCoreTransport transport) {
    _eventSubscription = transport.events.listen(
      _eventController.add,
      onError: _eventController.addError,
    );
    _frameSubscription = transport.frames.listen(
      _frameController.add,
      onError: _frameController.addError,
    );
  }

  Future<void> _unbind() async {
    await _eventSubscription?.cancel();
    await _frameSubscription?.cancel();
    _eventSubscription = null;
    _frameSubscription = null;
  }

  @override
  String get address => _transport.address;

  @override
  DesktopTransportState get state => _transport.state;

  @override
  Stream<DesktopTransportEvent> get events => _eventController.stream;

  @override
  Stream<Uint8List> get frames => _frameController.stream;

  Future<void> replace(DesktopCoreTransport next) async {
    if (_closeOperation != null) {
      throw StateError('IPC transport binding is closed');
    }
    final previous = _transport;
    if (previous.state == DesktopTransportState.connected) {
      _eventController.add(
        TransportFailed(
          StateError('Connected IPC transport was replaced'),
          StackTrace.current,
        ),
      );
    }
    await _unbind();
    try {
      await previous.close();
    } finally {
      _transport = next;
      _bind(next);
    }
  }

  @override
  Future<void> open() => _transport.open();

  @override
  Future<TransportConnected> waitUntilConnected(Duration timeout) {
    return _transport.waitUntilConnected(timeout);
  }

  @override
  void send(List<int> frame) => _transport.send(frame);

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    await _unbind();
    try {
      await _transport.close();
    } finally {
      await _eventController.close();
      await _frameController.close();
    }
  }
}

final class IpcCoreTransport implements DesktopCoreTransport {
  @override
  final String address;

  final IpcServerBinder _bind;
  final StreamController<DesktopTransportEvent> _eventController =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  IpcServer? _server;
  StreamSubscription<IpcEvent>? _subscription;
  Future<void>? _openOperation;
  Future<void>? _closeOperation;
  DesktopTransportState _state = DesktopTransportState.idle;
  TransportConnected? _connection;
  TransportFailed? _failure;
  int _connectionGeneration = 0;

  IpcCoreTransport({required this.address, IpcServerBinder? bind})
    : _bind = bind ?? _bindIpcServer;

  static Future<IpcServer> _bindIpcServer(String address) {
    return IpcServer.bind(address: address);
  }

  @override
  DesktopTransportState get state => _state;

  @override
  Stream<DesktopTransportEvent> get events => _eventController.stream;

  @override
  Stream<Uint8List> get frames => _frameController.stream;

  @override
  Future<void> open() {
    if (_state == DesktopTransportState.closed) {
      return Future.error(StateError('IPC transport is closed'));
    }
    final failure = _failure;
    if (failure != null) {
      return Future.error(failure.error, failure.stackTrace);
    }
    return _openOperation ??= _open();
  }

  Future<void> _open() async {
    _state = DesktopTransportState.starting;
    try {
      final server = await _bind(address);
      if (_state == DesktopTransportState.closed) {
        await server.close();
        throw StateError('IPC transport is closed');
      }
      _server = server;
      _state = DesktopTransportState.ready;
      commonPrint.log('IPC Ready');
      _eventController.add(const TransportReady());
      _subscription = server.events().listen(
        _handleEvent,
        onError: _fail,
        onDone: _handleDone,
      );
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
      rethrow;
    }
  }

  bool get _isTerminal =>
      _state == DesktopTransportState.failed ||
      _state == DesktopTransportState.closed;

  void _handleEvent(IpcEvent event) {
    if (_isTerminal) {
      return;
    }
    switch (event.kind) {
      case IpcEventKind.connected:
        _connect(event.pid);
      case IpcEventKind.message:
        _frameController.add(event.payload);
      case IpcEventKind.disconnected:
        _disconnect(event.error);
      case IpcEventKind.failed:
        _fail(StateError('IPC error: ${event.error}'), StackTrace.current);
    }
  }

  void _connect(int? pid) {
    commonPrint.log('IPC Connected${pid == null ? '' : ': $pid'}');
    final connection = TransportConnected(
      pid: pid,
      generation: ++_connectionGeneration,
    );
    _connection = connection;
    _state = DesktopTransportState.connected;
    _eventController.add(connection);
  }

  void _disconnect(String? error) {
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
    _eventController.add(
      TransportDisconnected(
        connection.generation,
        error: error == null ? null : StateError('IPC error: $error'),
      ),
    );
  }

  void _handleDone() {
    _fail(StateError('IPC server stopped unexpectedly'), StackTrace.current);
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_isTerminal) {
      return;
    }
    commonPrint.log('IPC error: $error', logLevel: LogLevel.debug);
    final failure = TransportFailed(error, stackTrace);
    _connection = null;
    _failure = failure;
    _state = DesktopTransportState.failed;
    _eventController.add(failure);
  }

  @override
  Future<TransportConnected> waitUntilConnected(Duration timeout) {
    final connection = _connection;
    if (connection != null) {
      return Future.value(connection);
    }
    final failure = _failure;
    if (failure != null) {
      return Future.error(failure.error, failure.stackTrace);
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
    if (_state == DesktopTransportState.closed) {
      throw StateError('IPC transport is closed');
    }
    final server = _server;
    if (server == null) {
      throw StateError('IPC transport is not open');
    }
    server.send(message: frame);
  }

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    _state = DesktopTransportState.closed;
    _connection = null;
    try {
      await _server?.close();
    } finally {
      await _subscription?.cancel();
      await _eventController.close();
      await _frameController.close();
    }
  }
}
