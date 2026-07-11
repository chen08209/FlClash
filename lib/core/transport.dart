import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:rust_api/rust_api.dart';

// ── Binary frame types (mirrors Rust ipc.rs) ────────────────────────────────

const _typeReady = 0x00;
const _typeConnected = 0x01;
const _typeDisconnected = 0x02;
const _typeData = 0x03;
const _typeError = 0x04;

typedef IpcServerStarter = Stream<Uint8List> Function(String address);
typedef IpcMessageSender = Future<void> Function(List<int> data);
typedef IpcServerStopper = Future<void> Function();

class IPCCoreTransport {
  final String address;
  final Duration readyTimeout;
  final IpcServerStarter _startServer;
  final IpcMessageSender _sendMessage;
  final IpcServerStopper _stopServer;

  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();
  StreamSubscription<Uint8List>? _subscription;
  Completer<void> _completer = Completer<void>();
  Completer<int?> _connectionSignal = Completer<int?>();
  Completer<void> _readyCompleter = Completer<void>();
  int _connectionGeneration = 0;
  bool _ready = false;
  bool _initialized = false;
  bool _closing = false;

  void Function()? onDisconnect;

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

  Completer<void> get connectionCompleter => _completer;

  Stream<Uint8List> get dataStream => _dataController.stream;

  Future<int?> waitForNextConnection() {
    return _waitForConnectionAfter(_connectionGeneration);
  }

  Future<int?> _waitForConnectionAfter(int connectionGeneration) async {
    int? processId;
    while (_connectionGeneration <= connectionGeneration) {
      processId = await _connectionSignal.future;
    }
    return processId;
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _closing = false;
    try {
      final stream = _startServer(address);
      _subscription = stream.listen(
        _handleFrame,
        onError: _handleStreamError,
        onDone: _handleStreamDone,
        cancelOnError: false,
      );
      await _readyCompleter.future.timeout(readyTimeout);
      _initialized = true;
    } catch (e) {
      commonPrint.log(
        'Failed to start IPC server: $e',
        logLevel: LogLevel.error,
      );
      await _subscription?.cancel();
      _subscription = null;
      rethrow;
    }
  }

  void _handleFrame(Uint8List data) {
    if (data.isEmpty) {
      return;
    }
    final type = data[0];
    final payload = data.length > 1 ? data.sublist(1) : Uint8List(0);
    switch (type) {
      case _typeReady:
        commonPrint.log('IPC Ready');
        _ready = true;
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
        break;
      case _typeConnected:
        final processId = _decodeConnectedProcessId(payload);
        if (payload.isNotEmpty && processId == null) {
          _handleStreamError(
            StateError('Invalid IPC connected frame'),
            StackTrace.current,
          );
          return;
        }
        commonPrint.log(
          'IPC Connected${processId == null ? '' : ': $processId'}',
        );
        _connectionGeneration++;
        final connectionSignal = _connectionSignal;
        _connectionSignal = Completer<int?>();
        connectionSignal.complete(processId);
        if (!_completer.isCompleted) {
          _completer.complete();
        }
        break;
      case _typeDisconnected:
        commonPrint.log('IPC Disconnected');
        disconnected();
        if (!_closing) {
          onDisconnect?.call();
        }
        break;
      case _typeData:
        if (!_dataController.isClosed) {
          _dataController.add(payload);
        }
        break;
      case _typeError:
        final message = utf8.decode(payload, allowMalformed: true);
        final error = StateError('IPC error: $message');
        commonPrint.log(error.message, logLevel: LogLevel.error);
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.completeError(error);
        }
        break;
      default:
        commonPrint.log(
          'IPC unknown frame type: $type',
          logLevel: LogLevel.warning,
        );
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    commonPrint.log('IPC error: $error', logLevel: LogLevel.error);
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error, stackTrace);
    } else if (!_dataController.isClosed) {
      _dataController.addError(error, stackTrace);
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

  void _handleStreamDone() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(
        StateError('IPC server stopped before becoming ready'),
      );
    }
    if (_ready && !_closing) {
      disconnected();
      onDisconnect?.call();
    }
  }

  Future<void> send(String message) {
    return _sendMessage(utf8.encode(message));
  }

  void disconnected() {
    if (_completer.isCompleted) {
      _completer = Completer<void>();
    }
  }

  Future<void> close() async {
    _closing = true;
    try {
      await _stopServer();
    } finally {
      await _subscription?.cancel();
      _subscription = null;
      _ready = false;
      _initialized = false;
      _readyCompleter = Completer<void>();
      _completer = Completer<void>();
      await _dataController.close();
    }
  }
}
