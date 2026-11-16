import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/core/spill.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart' show compute, visibleForTesting;

import 'transport.dart';

/// How many timeout windows a request may be extended across while Core keeps
/// answering other requests, before it fails regardless.
const _maxTimeoutExtension = 3;

const _maxExtensionGrace = Duration(seconds: 30);

const _connectTimeout = Duration(seconds: 10);

final _requestEncoder = JsonUtf8Encoder();
final _frameDecoder = utf8.decoder.fuse(json.decoder);

Map<String, Object?> _decodeFrame(Uint8List frame) {
  final decoded = _frameDecoder.convert(frame);
  if (decoded is! Map) {
    throw const FormatException('Core transport data is not an object');
  }
  return Map<String, Object?>.from(decoded);
}

Map<String, Object?> _decodeFrameWithModels(
  (Uint8List, Map<String, CoreResultModel>) request,
) {
  final (frame, models) = request;
  final data = _decodeFrame(frame);
  if (data.containsKey('method')) {
    return data;
  }
  return withResultModel(models[data['id']], data);
}

abstract interface class CoreRpcChannel {
  Future<Object?> invoke({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
    CoreResultModel? model,
  });

  Future<void> close();
}

final class CoreRpcClient implements CoreRpcChannel {
  final DesktopCoreTransport transport;
  final Duration extensionGrace;
  final Map<String, ({Completer<Object?> completer, CoreResultModel? model})>
  _pending = {};
  late final StreamSubscription<Uint8List> _frameSubscription;
  late final StreamSubscription<DesktopTransportEvent> _eventSubscription;

  /// Frames and transport events in arrival order. A frame decoded in an
  /// isolate holds back what came after it, so a disconnect cannot fail a
  /// response that arrived before it.
  final Queue<Object> _inbox = Queue();
  var _drainingInbox = false;

  int _methodCallId = 0;
  Future<void>? _closeOperation;

  /// Time since Core last answered any request. A method timeout is a liveness
  /// guard for a stalled link (a restart mid-flight, a stream that stopped
  /// carrying data), not a budget for how long a single method may take — so a
  /// request that is still waiting while Core demonstrably keeps replying to
  /// its siblings gets its window re-armed instead of being failed.
  final Stopwatch _sinceLastResponse = Stopwatch()..start();

  CoreRpcClient(
    this.transport, {
    @visibleForTesting this.extensionGrace = _maxExtensionGrace,
  }) {
    _frameSubscription = transport.frames.listen(
      _receive,
      onError: _handleFrameError,
    );
    _eventSubscription = transport.events.listen(_receiveEvent);
  }

  int get pendingCount => _pending.length;

  @override
  Future<Object?> invoke({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
    CoreResultModel? model,
  }) async {
    if (_closeOperation != null) {
      throw const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core RPC client is closed',
      );
    }
    final id = '${++_methodCallId}';
    final completer = Completer<Object?>();
    _pending[id] = (
      completer: completer,
      model: model ?? coreResultModelOf(method),
    );
    final requestTimeout = timeout ?? const Duration(minutes: 3);
    final stopwatch = Stopwatch()..start();
    try {
      await Future.any<Object?>([
        transport.waitUntilConnected(_shorter(_connectTimeout, requestTimeout)),
        completer.future,
      ]);
      if (completer.isCompleted) {
        return await completer.future;
      }
      if (stopwatch.elapsed >= requestTimeout) {
        throw TimeoutException('Core method ${method.wireName} timed out');
      }
      transport.send(
        _requestEncoder.convert(
          CoreMethodCall(id: id, method: method, arguments: arguments),
        ),
      );
      return await _awaitResponse(
        method: method,
        completer: completer,
        idleTimeout: requestTimeout,
        elapsed: stopwatch,
      );
    } on TimeoutException {
      commonPrint.log(
        'Core method ${method.wireName} timed out after '
        '${stopwatch.elapsedMilliseconds}ms',
        logLevel: LogLevel.warning,
      );
      _removePending(id, completer);
      rethrow;
    } on CoreMethodException {
      _pending.remove(id);
      rethrow;
    } catch (error) {
      _removePending(id, completer);
      throw CoreMethodException(
        code: 'transport_error',
        message: 'Unable to send ${method.wireName} to Core',
        details: error.toString(),
      );
    } finally {
      stopwatch.stop();
    }
  }

  /// Waits for [completer], re-arming the window every time Core proves the
  /// link is still alive by answering some other request, so a slow method is
  /// not failed on behalf of a healthy link. Two things still end the wait:
  /// [idleTimeout] of silence, and a hard deadline set by whichever of
  /// [_maxTimeoutExtension] windows and [extensionGrace] on top binds first —
  /// a Core answering everything except this request has to surface as well.
  Future<Object?> _awaitResponse({
    required CoreMethod method,
    required Completer<Object?> completer,
    required Duration idleTimeout,
    required Stopwatch elapsed,
  }) async {
    final hardDeadline = _shorter(
      idleTimeout * _maxTimeoutExtension,
      idleTimeout + extensionGrace,
    );
    while (true) {
      // Silence is measured from the last response or from this request's own
      // start, whichever is later: an idle app must not shorten a fresh window.
      final silence = _shorter(_sinceLastResponse.elapsed, elapsed.elapsed);
      final remaining = _shorter(
        idleTimeout - silence,
        hardDeadline - elapsed.elapsed,
      );
      if (remaining <= Duration.zero) {
        throw TimeoutException('Core method ${method.wireName} timed out');
      }
      try {
        return await completer.future.timeout(remaining);
      } on TimeoutException {
        continue;
      }
    }
  }

  static Duration _shorter(Duration a, Duration b) => a < b ? a : b;

  void _removePending(String id, Completer<Object?> completer) {
    final removed = _pending.remove(id);
    if (identical(removed?.completer, completer) && !completer.isCompleted) {
      completer.complete(null);
    }
  }

  void _receiveEvent(DesktopTransportEvent event) {
    final error = switch (event) {
      TransportDisconnected() => const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core transport disconnected',
      ),
      TransportFailed(:final error) => CoreMethodException(
        code: 'transport_error',
        message: 'Core transport failed',
        details: error.toString(),
      ),
      TransportReady() || TransportConnected() => null,
    };
    if (error != null) {
      _receive((error: error, pending: _pending.keys.toList()));
    }
  }

  void _receive(Object item) {
    _inbox.add(item);
    if (!_drainingInbox) {
      unawaited(_drainInbox());
    }
  }

  Future<void> _drainInbox() async {
    _drainingInbox = true;
    try {
      while (_inbox.isNotEmpty) {
        switch (_inbox.removeFirst()) {
          case final Uint8List frame when frame.length < coreIsolateDecodeBytes:
            _handleFrame(frame);
          case final Uint8List frame:
            await _handleLargeFrame(frame);
          case (
            error: final CoreMethodException error,
            pending: final List<String> pending,
          ):
            _failPending(error, pending);
        }
      }
    } finally {
      _drainingInbox = false;
    }
  }

  void _handleFrame(Uint8List frame) {
    try {
      _handleData(_decodeFrameWithModels((frame, _pendingModels())));
    } catch (error) {
      _logParseFailure(error);
    }
  }

  Future<void> _handleLargeFrame(Uint8List frame) async {
    final models = _pendingModels();
    try {
      _handleData(await compute(_decodeFrameWithModels, (frame, models)));
    } catch (error) {
      _logParseFailure(error);
    }
  }

  Map<String, CoreResultModel> _pendingModels() => {
    for (final MapEntry(:key, :value) in _pending.entries) key: ?value.model,
  };

  void _handleData(Map<String, Object?> data) {
    if (data.containsKey('method')) {
      _handleMethodCall(CoreMethodCall.fromJson(data));
    } else {
      _handleResponse(CoreMethodResponse.fromJson(data));
    }
  }

  void _logParseFailure(Object error) {
    commonPrint.log(
      'Failed to parse transport data: $error',
      logLevel: LogLevel.error,
    );
  }

  void _handleMethodCall(CoreMethodCall call) {
    if (call.method != CoreMethod.message) {
      commonPrint.log(
        'Unknown core callback method: ${call.method.wireName}',
        logLevel: LogLevel.warning,
      );
      return;
    }
    for (final event in coreEventsFromData(call.arguments)) {
      coreEventManager.sendEvent(event);
    }
  }

  void _handleResponse(CoreMethodResponse response) {
    // Proof of life for every pending request, including a late response whose
    // own caller already gave up.
    _sinceLastResponse
      ..reset()
      ..start();
    final id = response.id;
    final pending = id == null ? null : _pending.remove(id);
    final completer = pending?.completer;
    if (pending == null || completer == null || completer.isCompleted) {
      unawaited(discardSpilledResponse(response));
      return;
    }
    if (response.file != null) {
      unawaited(
        resolveSpilledResponse(
          response,
          model: pending.model,
        ).then((resolved) => _complete(completer, resolved)),
      );
      return;
    }
    _complete(completer, response);
  }

  void _complete(Completer<Object?> completer, CoreMethodResponse response) {
    if (completer.isCompleted) {
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

  void _failPending(CoreMethodException error, [Iterable<String>? ids]) {
    final completers = [
      for (final id in ids ?? _pending.keys.toList())
        ?_pending.remove(id)?.completer,
    ];
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
