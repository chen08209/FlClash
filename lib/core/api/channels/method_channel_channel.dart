import 'dart:async';

import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:flutter/services.dart';

/// Frames to the Android Core travel as `send` calls on the core channel;
/// frames from it arrive on the service channel and are handed to [receive].
final class MethodChannelFrameChannel implements SessionFrameChannel {
  final MethodChannel _channel;
  final StreamController<Uint8List> _frames =
      StreamController<Uint8List>.broadcast();
  final StreamController<ChannelEvent> _events =
      StreamController<ChannelEvent>.broadcast();
  int _generation = 0;
  bool _connected = false;

  MethodChannelFrameChannel(this._channel);

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<ChannelEvent> get events => _events.stream;

  @override
  int? get generation => _connected ? _generation : null;

  void receive(Uint8List frame) => _frames.add(frame);

  @override
  void connect() {
    if (_connected) {
      return;
    }
    _connected = true;
    _events.add(ChannelConnected(++_generation));
  }

  @override
  void disconnect([Object? error]) {
    if (!_connected) {
      return;
    }
    _connected = false;
    _events.add(ChannelDisconnected(_generation, error: error));
  }

  @override
  Future<int> waitUntilConnected(Duration timeout) {
    if (_connected) {
      return Future.value(_generation);
    }
    return events
        .firstWhere((event) => event is ChannelConnected)
        .then((event) => (event as ChannelConnected).generation)
        .timeout(timeout);
  }

  @override
  void send(List<int> frame) {
    final data = frame is Uint8List ? frame : Uint8List.fromList(frame);
    unawaited(
      _channel.invokeMethod<void>('send', data).catchError((Object error) {
        disconnect(error);
      }),
    );
  }

  @override
  Future<void> close() async {
    disconnect();
    await _frames.close();
    await _events.close();
  }
}
