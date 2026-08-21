import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:rust_api/rust_api.dart';

const _typeReady = 0x00;
const _typeConnected = 0x01;
const _typeDisconnected = 0x02;
const _typeData = 0x03;
const _typeError = 0x04;

typedef IpcServerStarter = Stream<Uint8List> Function(String address);
typedef IpcMessageSender = Future<void> Function(List<int> data);
typedef IpcServerStopper = Future<void> Function();

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

  const TransportDisconnected(this.generation);
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

  Future<void> send(String message);

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
    if (previous.state == DesktopTransportState.connected &&
        !_eventController.isClosed) {
      _eventController.add(
        TransportFailed(
          StateError('Connected IPC transport was replaced'),
          StackTrace.current,
        ),
      );
    }
    await _eventSubscription?.cancel();
    await _frameSubscription?.cancel();
    _eventSubscription = null;
    _frameSubscription = null;
    Object? closeError;
    StackTrace? closeStackTrace;
    try {
      await previous.close();
    } catch (error, stackTrace) {
      closeError = error;
      closeStackTrace = stackTrace;
    }
    _transport = next;
    _bind(next);
    if (closeError != null) {
      Error.throwWithStackTrace(closeError, closeStackTrace!);
    }
  }

  @override
  Future<void> open() => _transport.open();

  @override
  Future<TransportConnected> waitUntilConnected(Duration timeout) {
    return _transport.waitUntilConnected(timeout);
  }

  @override
  Future<void> send(String message) => _transport.send(message);

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    await _eventSubscription?.cancel();
    await _frameSubscription?.cancel();
    _eventSubscription = null;
    _frameSubscription = null;
    try {
      await _transport.close();
    } finally {
      await _eventController.close();
      await _frameController.close();
    }
  }
}

final class IPCCoreTransport implements DesktopCoreTransport {
  @override
  final String address;

  final Duration readyTimeout;
  final IpcServerStarter _startServer;
  final IpcMessageSender _sendMessage;
  final IpcServerStopper _stopServer;

  final StreamController<DesktopTransportEvent> _eventController =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  StreamSubscription<Uint8List>? _subscription;
  Future<void>? _openOperation;
  Future<void>? _closeOperation;
  DesktopTransportState _state = DesktopTransportState.idle;
  TransportConnected? _connection;
  TransportFailed? _failure;
  int _connectionGeneration = 0;

  IPCCoreTransport({
    required this.address,
    this.readyTimeout = const Duration(seconds: 10),
    IpcServerStarter? startServer,
    IpcMessageSender? sendMessage,
    IpcServerStopper? stopServer,
  }) : _startServer = startServer ?? _restartIpcServer,
       _sendMessage = sendMessage ?? _sendIpcMessage,
       _stopServer = stopServer ?? stopIpcServer;

  static Stream<Uint8List> _restartIpcServer(String address) {
    return restartIpcServer(name: address);
  }

  static Future<void> _sendIpcMessage(List<int> data) {
    return sendIpcMessage(data: data);
  }

  @override
  DesktopTransportState get state => _state;

  @override
  Stream<DesktopTransportEvent> get events => _eventController.stream;

  @override
  Stream<Uint8List> get frames => _frameController.stream;

  @override
  Future<void> open() {
    if (_state == DesktopTransportState.ready ||
        _state == DesktopTransportState.connected) {
      return Future.value();
    }
    if (_state == DesktopTransportState.closed) {
      return Future.error(StateError('IPC transport is closed'));
    }
    return _openOperation ??= _open();
  }

  Future<void> _open() async {
    _state = DesktopTransportState.starting;
    final readiness = events.firstWhere(
      (event) => event is TransportReady || event is TransportFailed,
    );
    try {
      _subscription = _startServer(address).listen(
        _handleFrame,
        onError: _handleStreamError,
        onDone: _handleStreamDone,
        cancelOnError: false,
      );
      final event = await readiness.timeout(readyTimeout);
      if (event case TransportFailed(:final error, :final stackTrace)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    } catch (error, stackTrace) {
      if (_state != DesktopTransportState.failed &&
          _state != DesktopTransportState.closed) {
        _fail(error, stackTrace);
      }
      await _subscription?.cancel();
      _subscription = null;
      rethrow;
    }
  }

  void _handleFrame(Uint8List data) {
    if (data.isEmpty || _state == DesktopTransportState.closed) {
      return;
    }
    final type = data[0];
    final payload = data.length > 1
        ? Uint8List.sublistView(data, 1)
        : Uint8List(0);
    switch (type) {
      case _typeReady:
        commonPrint.log('IPC Ready');
        _failure = null;
        _state = DesktopTransportState.ready;
        _eventController.add(const TransportReady());
      case _typeConnected:
        final processId = _decodeConnectedProcessId(payload);
        if (payload.isNotEmpty && processId == null) {
          _fail(StateError('Invalid IPC connected frame'), StackTrace.current);
          return;
        }
        commonPrint.log(
          'IPC Connected${processId == null ? '' : ': $processId'}',
        );
        _failure = null;
        _connectionGeneration++;
        _connection = TransportConnected(
          pid: processId,
          generation: _connectionGeneration,
        );
        _state = DesktopTransportState.connected;
        _eventController.add(_connection!);
      case _typeDisconnected:
        _disconnect();
      case _typeData:
        if (!_frameController.isClosed) {
          _frameController.add(payload);
        }
      case _typeError:
        final message = utf8.decode(payload, allowMalformed: true);
        _fail(StateError('IPC error: $message'), StackTrace.current);
      default:
        commonPrint.log(
          'IPC unknown frame type: $type',
          logLevel: LogLevel.warning,
        );
    }
  }

  int? _decodeConnectedProcessId(Uint8List payload) {
    if (payload.isEmpty) {
      return null;
    }
    if (payload.length != Uint32List.bytesPerElement) {
      return null;
    }
    final processId = ByteData.sublistView(payload).getUint32(0, Endian.little);
    return processId == 0 ? null : processId;
  }

  void _disconnect() {
    final connection = _connection;
    if (connection == null) {
      return;
    }
    commonPrint.log('IPC Disconnected');
    _connection = null;
    _state = DesktopTransportState.ready;
    _eventController.add(TransportDisconnected(connection.generation));
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _fail(error, stackTrace);
  }

  void _handleStreamDone() {
    if (_state == DesktopTransportState.closed) {
      return;
    }
    _disconnect();
    _fail(StateError('IPC server stopped unexpectedly'), StackTrace.current);
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_state == DesktopTransportState.failed ||
        _state == DesktopTransportState.closed) {
      return;
    }
    commonPrint.log('IPC error: $error', logLevel: LogLevel.debug);
    _state = DesktopTransportState.failed;
    _failure = TransportFailed(error, stackTrace);
    _eventController.add(_failure!);
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
  Future<void> send(String message) {
    if (_state == DesktopTransportState.closed) {
      return Future.error(StateError('IPC transport is closed'));
    }
    return _sendMessage(utf8.encode(message));
  }

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    if (_state == DesktopTransportState.closed) {
      return;
    }
    _state = DesktopTransportState.closed;
    _connection = null;
    try {
      await _stopServer();
    } finally {
      await _subscription?.cancel();
      _subscription = null;
      await _eventController.close();
      await _frameController.close();
    }
  }
}
