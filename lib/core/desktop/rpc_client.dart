import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';

import 'transport.dart';

abstract interface class CoreRpcChannel {
  Future<T?> invoke<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  });

  Future<void> close();
}

final class CoreRpcClient implements CoreRpcChannel {
  final DesktopCoreTransport transport;
  final Map<String, Completer<Object?>> _pending = {};
  late final StreamSubscription<Uint8List> _frameSubscription;
  late final StreamSubscription<DesktopTransportEvent> _eventSubscription;

  int _methodCallId = 0;
  Future<void>? _closeOperation;

  CoreRpcClient(this.transport) {
    _frameSubscription = transport.frames.listen(
      _handleFrame,
      onError: _handleFrameError,
    );
    _eventSubscription = transport.events.listen(_handleTransportEvent);
  }

  int get pendingCount => _pending.length;

  @override
  Future<T?> invoke<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (_closeOperation != null) {
      throw const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core RPC client is closed',
      );
    }
    final id = '${++_methodCallId}';
    final completer = Completer<Object?>();
    _pending[id] = completer;
    final requestTimeout = timeout ?? const Duration(minutes: 3);
    final stopwatch = Stopwatch()..start();
    try {
      await Future.any<Object?>([
        transport.waitUntilConnected(const Duration(seconds: 10)),
        completer.future,
      ]);
      if (completer.isCompleted) {
        return await completer.future as T?;
      }
      await transport.send(
        json.encode(
          CoreMethodCall(id: id, method: method, arguments: arguments),
        ),
      );
      final remainingTimeout = requestTimeout - stopwatch.elapsed;
      if (remainingTimeout <= Duration.zero) {
        throw TimeoutException('Core method ${method.name} timed out');
      }
      return await completer.future.timeout(remainingTimeout) as T?;
    } on TimeoutException {
      _removePending(id, completer);
      return null;
    } on CoreMethodException {
      _pending.remove(id);
      rethrow;
    } catch (error) {
      _removePending(id, completer);
      throw CoreMethodException(
        code: 'transport_error',
        message: 'Unable to send ${method.name} to Core',
        details: error.toString(),
      );
    } finally {
      stopwatch.stop();
    }
  }

  void _removePending(String id, Completer<Object?> completer) {
    final removed = _pending.remove(id);
    if (identical(removed, completer) && !completer.isCompleted) {
      completer.complete(null);
    }
  }

  void _handleFrame(Uint8List frame) {
    try {
      final decoded = json.decode(utf8.decode(frame));
      if (decoded is! Map) {
        throw const FormatException('Core transport data is not an object');
      }
      final data = Map<String, Object?>.from(decoded);
      if (data.containsKey('method')) {
        _handleMethodCall(CoreMethodCall.fromJson(data));
      } else {
        _handleResponse(CoreMethodResponse.fromJson(data));
      }
    } catch (error) {
      commonPrint.log(
        'Failed to parse transport data: $error',
        logLevel: LogLevel.error,
      );
    }
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
    final completer = id == null ? null : _pending.remove(id);
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

  void _handleFrameError(Object error, StackTrace stackTrace) {
    commonPrint.log(
      'Transport data stream error: $error',
      logLevel: LogLevel.debug,
    );
  }

  void _handleTransportEvent(DesktopTransportEvent event) {
    switch (event) {
      case TransportDisconnected():
        _failPending(
          const CoreMethodException(
            code: 'transport_disconnected',
            message: 'Core transport disconnected',
          ),
        );
      case TransportFailed(:final error):
        _failPending(
          CoreMethodException(
            code: 'transport_error',
            message: 'Core transport failed',
            details: error.toString(),
          ),
        );
      case TransportReady() || TransportConnected():
        break;
    }
  }

  void _failPending(CoreMethodException error) {
    final completers = _pending.values.toList(growable: false);
    _pending.clear();
    for (final completer in completers) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    _failPending(
      const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core RPC client is closed',
      ),
    );
    await _frameSubscription.cancel();
    await _eventSubscription.cancel();
  }
}
