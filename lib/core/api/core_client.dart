import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

import 'dto.dart';
import 'errors.dart';
import 'frame_channel.dart';

/// A response above this size is decoded off the UI isolate.
const coreOffloadBytes = 51200;

const _defaultTimeout = Duration(minutes: 3);
const _connectTimeout = Duration(seconds: 10);
const _initialCredit = 4;
const _resyncPause = Duration(milliseconds: 50);

final _encoder = JsonUtf8Encoder();
final _decoder = utf8.decoder.fuse(json.decoder);
final _responsePrefix = utf8.encode('{"jsonrpc":"2.0","id":');

typedef Decoder<T> = T Function(Object? result);

/// What one batch of a stream carried. [snapshot] is set on the first frame of
/// a subscription and again after a resync, which means the consumer must drop
/// what it held; [resynced] marks a frame that follows lost events.
final class WatchFrame<S, E> {
  final S? snapshot;
  final List<E> events;
  final int dropped;
  final bool resynced;

  const WatchFrame({
    this.snapshot,
    this.events = const [],
    this.dropped = 0,
    this.resynced = false,
  });
}

class _Pending {
  final Completer<Object?> completer = Completer<Object?>();
  final Decoder<Object?> decode;
  Timer? timer;

  _Pending(this.decode);
}

typedef _Opened<S> = ({int sub, S? snapshot});

/// One JSON-RPC session with a Core: ids, hello, timeouts that cancel,
/// subscriptions with credit. It knows no process and no transport.
final class CoreClient {
  final FrameChannel _channel;
  final String clientVersion;
  final bool debug;
  final Duration connectTimeout;
  late final StreamSubscription<Uint8List> _frameSubscription;
  late final StreamSubscription<ChannelEvent> _eventSubscription;
  final Map<int, _Pending> _pending = {};
  final Set<_Watch<Object?, Object?>> _watches = {};
  final Map<int, _Watch<Object?, Object?>> _watchesBySub = {};
  int _nextId = 0;
  int? _helloGeneration;
  Future<HelloResult>? _hello;
  HelloResult? _session;
  bool _closed = false;

  CoreClient(
    this._channel, {
    this.clientVersion = '',
    this.debug = false,
    this.connectTimeout = _connectTimeout,
  }) {
    _frameSubscription = _channel.frames.listen(
      _onFrame,
      onError: (Object error) => commonPrint.log(
        'Core frame stream error: $error',
        logLevel: LogLevel.debug,
      ),
    );
    _eventSubscription = _channel.events.listen(_onChannelEvent);
  }

  int get pendingCount => _pending.length;

  int get watchCount => _watches.length;

  /// The last hello of the live session, null while there is none.
  HelloResult? get session => _session;

  Future<HelloResult> ready([Duration? timeout]) async {
    if (_closed) {
      throw _unavailable('Core client is closed', 'transport_disconnected');
    }
    final int generation;
    try {
      generation = await _channel.waitUntilConnected(timeout ?? connectTimeout);
    } on TimeoutException {
      throw _unavailable('Core is not connected', 'core_unavailable');
    } on CoreMethodException {
      rethrow;
    } catch (error) {
      throw CoreMethodException(
        code: 'transport_error',
        message: 'Core transport failed',
        details: error.toString(),
      );
    }
    if (_helloGeneration != generation || _hello == null) {
      _helloGeneration = generation;
      _hello = _sayHello(generation);
    }
    return _hello!;
  }

  Future<HelloResult> _sayHello(int generation) async {
    try {
      final call = _begin<HelloResult>(
        'core.hello',
        {
          'protocol': {'min': 1, 'max': 1},
          'client': {'name': 'flclash', 'version': clientVersion},
          if (debug) 'capabilities': ['debug'],
        },
        (result) => HelloResult.fromJson(result as JsonMap),
        connectTimeout,
      );
      final hello = await call.result;
      if (_helloGeneration == generation) {
        _session = hello;
      }
      return hello;
    } catch (_) {
      if (_helloGeneration == generation) {
        _hello = null;
      }
      rethrow;
    }
  }

  Future<T> call<T>(
    String method, {
    Object? params,
    required Decoder<T> decode,
    Duration? timeout,
  }) async {
    final wait = timeout ?? _defaultTimeout;
    await ready(wait < connectTimeout ? wait : connectTimeout);
    return _begin<T>(method, params, decode, wait).result;
  }

  /// Reads a stream's snapshot and unsubscribes at once.
  Future<S> snapshot<S>(
    String method, {
    Object? params,
    required Decoder<S> decode,
    Duration? timeout,
  }) async {
    final wait = timeout ?? _defaultTimeout;
    await ready(wait < connectTimeout ? wait : connectTimeout);
    final call = _begin<_Opened<S>>(method, params, (result) {
      final body = result as JsonMap;
      return (sub: body['sub'] as int, snapshot: decode(body['snapshot']));
    }, wait);
    try {
      final opened = await call.result;
      return opened.snapshot as S;
    } finally {
      _notify('\$/cancel', {'id': call.id});
    }
  }

  /// A stream that opens on listen, gives credit back as batches are consumed,
  /// holds it back while paused, and unsubscribes on cancel. A resync reopens
  /// it by itself; a lost session ends it with an error.
  Stream<WatchFrame<S, E>> watch<S, E>(
    String method, {
    Object? params,
    Decoder<S>? decodeSnapshot,
    required E Function(JsonMap event) decodeEvent,
    bool Function(E event)? isLast,
    int? maxBatchMs,
    int? maxBatchBytes,
  }) {
    final watch = _Watch<S, E>(
      this,
      method,
      {
        ...?(params as Map<String, Object?>?),
        'credit': 0,
        'maxBatchMs': ?maxBatchMs,
        'maxBatchBytes': ?maxBatchBytes,
      },
      decodeSnapshot,
      decodeEvent,
      isLast,
    );
    return watch.stream;
  }

  ({int id, Future<T> result}) _begin<T>(
    String method,
    Object? params,
    Decoder<T> decode,
    Duration timeout,
  ) {
    if (_closed) {
      return (
        id: 0,
        result: Future<T>.error(
          _unavailable('Core client is closed', 'transport_disconnected'),
        ),
      );
    }
    final id = ++_nextId;
    final pending = _Pending(decode);
    _pending[id] = pending;
    pending.timer = Timer(timeout, () {
      if (_pending.remove(id) == null) {
        return;
      }
      _notify('\$/cancel', {'id': id});
      pending.completer.completeError(
        TimeoutException('Core method $method timed out', timeout),
      );
    });
    try {
      _channel.send(
        _encoder.convert({
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          'params': ?params,
        }),
      );
    } catch (error) {
      _pending.remove(id);
      pending.timer?.cancel();
      return (
        id: id,
        result: Future<T>.error(
          CoreMethodException(
            code: 'transport_error',
            message: 'Unable to send $method to Core',
            details: error.toString(),
          ),
        ),
      );
    }
    return (
      id: id,
      result: pending.completer.future.then((value) => value as T),
    );
  }

  void _notify(String method, Map<String, Object?> params) {
    if (_closed) {
      return;
    }
    try {
      _channel.send(
        _encoder.convert({
          'jsonrpc': '2.0',
          'method': method,
          'params': params,
        }),
      );
    } catch (_) {}
  }

  static int? _responseId(Uint8List frame) {
    if (frame.length <= _responsePrefix.length) {
      return null;
    }
    for (var index = 0; index < _responsePrefix.length; index++) {
      if (frame[index] != _responsePrefix[index]) {
        return null;
      }
    }
    var id = 0;
    var cursor = _responsePrefix.length;
    for (; cursor < frame.length; cursor++) {
      final digit = frame[cursor] - 0x30;
      if (digit < 0 || digit > 9) {
        break;
      }
      id = id * 10 + digit;
    }
    return cursor == _responsePrefix.length ? null : id;
  }

  void _onFrame(Uint8List frame) {
    final id = _responseId(frame);
    if (id != null && frame.length >= coreOffloadBytes) {
      final pending = _pending[id];
      if (pending != null) {
        unawaited(_decodeAway(id, frame, pending));
        return;
      }
    }
    final Object? decoded;
    try {
      decoded = _decoder.convert(frame);
    } catch (error) {
      commonPrint.log(
        'Unable to parse a Core frame: $error',
        logLevel: LogLevel.error,
      );
      return;
    }
    if (decoded is! Map) {
      return;
    }
    final message = Map<String, Object?>.from(decoded);
    final method = message['method'];
    if (method is String) {
      if (method == r'$/event') {
        _onEvent(message['params'] as JsonMap);
      }
      return;
    }
    _onResponse(message);
  }

  Future<void> _decodeAway(int id, Uint8List frame, _Pending pending) async {
    final decode = pending.decode;
    Object? outcome;
    try {
      outcome = await Isolate.run(() => _decodeResponse(frame, decode));
    } catch (_) {
      try {
        outcome = _decodeResponse(frame, decode);
      } catch (error) {
        outcome = _Failed(error);
      }
    }
    final current = _pending.remove(id);
    if (current == null) {
      return;
    }
    current.timer?.cancel();
    if (outcome is _Failed) {
      current.completer.completeError(outcome.error);
    } else {
      current.completer.complete(outcome);
    }
  }

  void _onResponse(Map<String, Object?> message) {
    final id = message['id'];
    if (id is! int) {
      return;
    }
    final pending = _pending.remove(id);
    if (pending == null) {
      return;
    }
    pending.timer?.cancel();
    final error = message['error'];
    if (error is Map) {
      pending.completer.completeError(
        CoreMethodException.fromError(Map<String, Object?>.from(error)),
      );
      return;
    }
    try {
      pending.completer.complete(pending.decode(message['result']));
    } catch (error) {
      pending.completer.completeError(_invalidResponse(error));
    }
  }

  void _onEvent(JsonMap params) {
    final sub = params['sub'];
    final watch = sub is int ? _watchesBySub[sub] : null;
    if (watch == null) {
      return;
    }
    watch.receive(params);
  }

  void _onChannelEvent(ChannelEvent event) {
    switch (event) {
      case ChannelConnected():
        break;
      case ChannelDisconnected(:final generation, :final error):
        if (generation != _helloGeneration) {
          return;
        }
        _helloGeneration = null;
        _hello = null;
        _session = null;
        _failAll(
          error == null
              ? _unavailable('Core transport disconnected')
              : CoreMethodException(
                  code: 'transport_error',
                  message: 'Core transport failed',
                  details: error.toString(),
                ),
        );
    }
  }

  void _failAll(CoreMethodException error) {
    final pending = List.of(_pending.values);
    _pending.clear();
    for (final entry in pending) {
      entry.timer?.cancel();
      if (!entry.completer.isCompleted) {
        entry.completer.completeError(error);
      }
    }
    for (final watch in List.of(_watches)) {
      watch.fail(error);
    }
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    _failAll(_unavailable('Core client is closed'));
    await _frameSubscription.cancel();
    await _eventSubscription.cancel();
  }
}

CoreMethodException _unavailable(
  String message, [
  String code = 'transport_disconnected',
]) => CoreMethodException(code: code, message: message);

CoreMethodException _invalidResponse(Object error) => CoreMethodException(
  code: 'invalid_response',
  message: 'Unable to read the Core response',
  details: error.toString(),
);

final class _Failed {
  final Object error;

  const _Failed(this.error);
}

Object? _decodeResponse(Uint8List frame, Decoder<Object?> decode) {
  final message = _decoder.convert(frame) as Map;
  final error = message['error'];
  if (error is Map) {
    throw CoreMethodException.fromError(Map<String, Object?>.from(error));
  }
  try {
    return decode(message['result']);
  } catch (error) {
    throw _invalidResponse(error);
  }
}

final class _Watch<S, E> {
  final CoreClient _client;
  final String _method;
  final Map<String, Object?> _params;
  final Decoder<S>? _decodeSnapshot;
  final E Function(JsonMap event) _decodeEvent;
  final bool Function(E event)? _isLast;
  late final StreamController<WatchFrame<S, E>> _controller;
  int? _requestId;
  int? _sub;
  bool _active = false;
  bool _paused = false;
  bool _resyncing = false;
  int _owed = 0;
  Timer? _reopen;

  _Watch(
    this._client,
    this._method,
    this._params,
    this._decodeSnapshot,
    this._decodeEvent,
    this._isLast,
  ) {
    _controller = StreamController<WatchFrame<S, E>>(
      sync: true,
      onListen: _start,
      onPause: () => _paused = true,
      onResume: _resume,
      onCancel: _stop,
    );
  }

  Stream<WatchFrame<S, E>> get stream => _controller.stream;

  void _start() {
    _active = true;
    _client._watches.add(this as _Watch<Object?, Object?>);
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      await _client.ready();
      if (!_active) {
        return;
      }
      final call = _client._begin<_Opened<S>>(
        _method,
        _params,
        _openedDecoder(_decodeSnapshot),
        _defaultTimeout,
      );
      _requestId = call.id;
      final opened = await call.result;
      _opened(call.id, opened);
    } catch (error) {
      _requestId = null;
      fail(error);
    }
  }

  static Decoder<_Opened<T>> _openedDecoder<T>(Decoder<T>? decode) {
    return (result) {
      final body = result as JsonMap;
      final snapshot = decode == null || body['snapshot'] == null
          ? null
          : decode(body['snapshot']);
      return (sub: body['sub'] as int, snapshot: snapshot);
    };
  }

  void _opened(int requestId, _Opened<S> opened) {
    if (!_active || _requestId != requestId) {
      _client._notify(r'$/cancel', {'id': requestId});
      return;
    }
    _sub = opened.sub;
    _client._watchesBySub[opened.sub] = this as _Watch<Object?, Object?>;
    _client._notify(r'$/credit', {'sub': opened.sub, 'n': _initialCredit});
    final resynced = _resyncing;
    _resyncing = false;
    _controller.add(WatchFrame(snapshot: opened.snapshot, resynced: resynced));
  }

  void receive(JsonMap params) {
    if (!_active) {
      return;
    }
    if (params['resync'] == true) {
      _detach();
      _resyncing = true;
      _reopen = Timer(_resyncPause, () {
        if (_active) {
          unawaited(_open());
        }
      });
      return;
    }
    final events = <E>[];
    var last = false;
    for (final item in params['data'] as List? ?? const []) {
      final E event;
      try {
        event = _decodeEvent(item as JsonMap);
      } catch (error) {
        commonPrint.log(
          'Unable to read a $_method event: $error',
          logLevel: LogLevel.error,
        );
        continue;
      }
      events.add(event);
      last = last || (_isLast?.call(event) ?? false);
    }
    _controller.add(
      WatchFrame(events: events, dropped: params['dropped'] as int? ?? 0),
    );
    if (last) {
      unawaited(_finish());
      return;
    }
    _refill();
  }

  void _refill() {
    final sub = _sub;
    if (sub == null) {
      return;
    }
    _owed++;
    if (_paused || _owed < _initialCredit ~/ 2) {
      return;
    }
    _client._notify(r'$/credit', {'sub': sub, 'n': _owed});
    _owed = 0;
  }

  void _resume() {
    _paused = false;
    final sub = _sub;
    if (sub != null && _owed > 0) {
      _client._notify(r'$/credit', {'sub': sub, 'n': _owed});
      _owed = 0;
    }
  }

  void _detach() {
    final sub = _sub;
    if (sub != null) {
      _client._watchesBySub.remove(sub);
    }
    _sub = null;
    _requestId = null;
    _owed = 0;
  }

  Future<void> _finish() async {
    await _stop();
    await _controller.close();
  }

  Future<void> _stop() async {
    _active = false;
    _client._watches.remove(this);
    _reopen?.cancel();
    final id = _requestId;
    if (id != null) {
      _client._notify(r'$/cancel', {'id': id});
    }
    _detach();
  }

  void fail(Object error) {
    final wasActive = _active;
    _active = false;
    _client._watches.remove(this);
    _reopen?.cancel();
    _detach();
    if (wasActive && !_controller.isClosed) {
      _controller.addError(error);
      unawaited(_controller.close());
    }
  }
}
