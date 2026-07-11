import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';

import 'event.dart';
import 'interface.dart';
import 'method.dart';
import 'transport.dart';

class CoreService extends CoreHandlerInterface {
  static CoreService? _instance;

  late final IPCCoreTransport _transport;
  late final Future<void> _serverInitialization;
  StreamSubscription<String>? _dataSubscription;

  Completer<bool> _shutdownCompleter = Completer();

  final Map<String, Completer<Object?>> _responseCompleters = {};

  Process? _process;
  Future<void>? _startOperation;

  factory CoreService() {
    _instance ??= CoreService._internal();
    return _instance!;
  }

  CoreService._internal() {
    _transport = IPCCoreTransport(
      address: system.isWindows ? windowsPipeName : unixSocketPath,
    );
    _serverInitialization = _initServer();
  }

  void _handleMethodCall(CoreMethodCall call) {
    if (call.method != CoreMethod.message) {
      commonPrint.log(
        'Unknown core callback method: ${call.method.name}',
        logLevel: LogLevel.warning,
      );
      return;
    }
    for (final event in coreEventsFromData(call.arguments)) {
      coreEventManager.sendEvent(event);
    }
  }

  void _handleResponse(CoreMethodResponse response) {
    final id = response.id;
    final completer = id == null ? null : _responseCompleters.remove(id);
    if (completer == null || completer.isCompleted) {
      return;
    }
    final error = response.error;
    if (error != null) {
      completer.completeError(
        CoreMethodException(
          code: error.code,
          message: error.message,
          details: error.details,
        ),
      );
      return;
    }
    completer.complete(response.result);
  }

  Future<void> _initServer() async {
    _transport.onDisconnect = () {
      _clearCompleter();
      _handleInvokeCrashEvent();
      if (!_shutdownCompleter.isCompleted) {
        _shutdownCompleter.complete(true);
      }
    };

    _dataSubscription = _transport.dataStream
        .transform(uint8ListToListIntConverter)
        .transform(utf8.decoder)
        .listen(
          (data) async {
            try {
              final json = await data
                  .trim()
                  .commonToJSON<Map<String, Object?>>();
              if (json.containsKey('method')) {
                _handleMethodCall(CoreMethodCall.fromJson(json));
              } else {
                _handleResponse(CoreMethodResponse.fromJson(json));
              }
            } catch (e) {
              commonPrint.log(
                'Failed to parse transport data: $e',
                logLevel: LogLevel.error,
              );
            }
          },
          onError: (error) {
            commonPrint.log(
              'Transport data stream error: $error',
              logLevel: LogLevel.error,
            );
          },
        );
    await _transport.init();
  }

  void _handleInvokeCrashEvent() {
    coreEventManager.sendEvent(
      const CoreEvent(type: CoreEventType.crash, data: 'core done'),
    );
  }

  Future<void> start() {
    final startOperation = _startOperation;
    if (startOperation != null) {
      return startOperation;
    }
    late final Future<void> operation;
    operation = _start().whenComplete(() {
      if (identical(_startOperation, operation)) {
        _startOperation = null;
      }
    });
    _startOperation = operation;
    return operation;
  }

  Future<void> _start() async {
    await _serverInitialization;
    if (_process != null) {
      await shutdown(false);
    }
    final nextConnection = _transport.waitForNextConnection();
    if (system.isWindows && await system.checkIsAdmin()) {
      final processId = await request.startCoreByHelper(_transport.address);
      if (processId == null) {
        throw StateError('Helper failed to start the core process');
      }
      try {
        await _waitForCoreConnection(nextConnection, processId);
      } catch (_) {
        await request.stopCoreByHelper();
        rethrow;
      }
      return;
    }
    try {
      _process = await Process.start(appPath.corePath, [_transport.address]);
    } catch (e) {
      commonPrint.log(
        'Failed to start core process: $e',
        logLevel: LogLevel.error,
      );
      _handleInvokeCrashEvent();
      rethrow;
    }
    _process?.stdout.listen((_) {});
    _process?.stderr.listen((e) {
      final error = utf8.decode(e);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    });
    try {
      await _waitForCoreConnection(nextConnection, _process!.pid);
    } catch (_) {
      _process?.kill();
      _process = null;
      rethrow;
    }
  }

  Future<void> _waitForCoreConnection(
    Future<int?> nextConnection,
    int expectedProcessId,
  ) async {
    final connectedProcessId = await nextConnection.timeout(
      const Duration(seconds: 10),
    );
    if (system.isWindows && connectedProcessId != expectedProcessId) {
      throw StateError(
        'Unexpected core IPC process: expected $expectedProcessId, '
        'connected ${connectedProcessId ?? 'unknown'}',
      );
    }
  }

  @override
  FutureOr<bool> destroy() async {
    await shutdown(false);
    try {
      await _transport.close();
    } finally {
      await _dataSubscription?.cancel();
      _dataSubscription = null;
    }
    return true;
  }

  Future<void> sendMessage(String message) async {
    await _serverInitialization;
    await _transport.connectionCompleter.future;
    await _transport.send(message);
  }

  @override
  Future<bool> shutdown(bool isUser) async {
    _shutdownCompleter = Completer();
    if (system.isWindows) {
      await request.stopCoreByHelper();
    }
    _transport.disconnected();
    _process?.kill();
    _process = null;
    _clearCompleter();
    if (isUser) {
      return _shutdownCompleter.future;
    } else {
      return true;
    }
  }

  void _clearCompleter() {
    for (final completer in _responseCompleters.values) {
      completer.safeCompleter(null);
    }
    _responseCompleters.clear();
  }

  @override
  Future<String> preload() async {
    try {
      await start();
      return '';
    } catch (e) {
      commonPrint.log('Failed to preload core: $e', logLevel: LogLevel.error);
      return e.toString();
    }
  }

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    final id = nextMethodCallId;
    final completer = Completer<Object?>();
    _responseCompleters[id] = completer;
    try {
      await sendMessage(
        json.encode(
          CoreMethodCall(id: id, method: method, arguments: arguments),
        ),
      );
    } catch (_) {
      _responseCompleters.remove(id);
      return null;
    }
    final result = await completer.future.withTimeout(
      timeout: timeout,
      onLast: () {
        final pendingResponse = _responseCompleters.remove(id);
        pendingResponse?.safeCompleter(null);
      },
      tag: id,
      onTimeout: () => null,
    );
    return result as T?;
  }

  @override
  Completer get completer => _transport.connectionCompleter;
}

final coreService = system.isDesktop ? CoreService() : null;
