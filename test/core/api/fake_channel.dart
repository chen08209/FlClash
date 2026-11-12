import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/api/frame_channel.dart';

class FakeFrameChannel implements FrameChannel {
  final _frames = StreamController<Uint8List>.broadcast(sync: true);
  final _events = StreamController<ChannelEvent>.broadcast(sync: true);
  final List<Map<String, Object?>> sent = [];
  int? _generation;
  int _next = 0;
  Completer<int>? _waiting;
  bool failSend = false;
  void Function(Map<String, Object?> message)? sentListener;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<ChannelEvent> get events => _events.stream;

  @override
  int? get generation => _generation;

  void connect() {
    final generation = ++_next;
    _generation = generation;
    _events.add(ChannelConnected(generation));
    _waiting?.complete(generation);
    _waiting = null;
  }

  void disconnect({Object? error}) {
    final generation = _generation;
    if (generation == null) {
      return;
    }
    _generation = null;
    _events.add(ChannelDisconnected(generation, error: error));
  }

  @override
  Future<int> waitUntilConnected(Duration timeout) {
    final generation = _generation;
    if (generation != null) {
      return Future.value(generation);
    }
    return (_waiting ??= Completer<int>()).future.timeout(timeout);
  }

  @override
  void send(List<int> frame) {
    if (failSend) {
      throw StateError('closed');
    }
    final message = Map<String, Object?>.from(
      json.decode(utf8.decode(frame)) as Map,
    );
    sent.add(message);
    final listener = sentListener;
    if (listener != null) {
      scheduleMicrotask(() => listener(message));
    }
  }

  @override
  Future<void> close() async {
    await _frames.close();
    await _events.close();
  }

  Iterable<Map<String, Object?>> calls(String method) =>
      sent.where((message) => message['method'] == method);

  Map<String, Object?> lastCall(String method) => calls(method).last;

  void push(Object message) {
    _frames.add(Uint8List.fromList(utf8.encode(json.encode(message))));
  }

  void pushRaw(Uint8List frame) => _frames.add(frame);

  void answer(Object? id, Object? result) =>
      push({'jsonrpc': '2.0', 'id': id, 'result': result});

  void fail(Object? id, Map<String, Object?> error) =>
      push({'jsonrpc': '2.0', 'id': id, 'error': error});

  void answerHello({Map<String, Object?>? extra}) {
    final hello = calls('core.hello').last;
    answer(hello['id'], {...helloBody, ...?extra});
  }

  void event(int sub, List<Object?> data, {Map<String, Object?>? extra}) {
    push({
      'jsonrpc': '2.0',
      'method': r'$/event',
      'params': {'sub': sub, 'data': data, ...?extra},
    });
  }
}

const helloBody = <String, Object?>{
  'protocol': 1,
  'server': {'implementation': 'concord', 'version': '1.0.0', 'build': 'test'},
  'platform': {'os': 'macos', 'privileged': false, 'capabilities': <String>[]},
  'limits': {'maxMessage': 16777216, 'maxBatchBytes': 65536},
  'methods': <String>['core.hello', 'traffic.watch'],
  'features': {'mitm': true, 'ech': false},
  'engine': {'state': 'created'},
};
