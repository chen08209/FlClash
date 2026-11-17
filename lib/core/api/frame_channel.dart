import 'dart:async';
import 'dart:typed_data';

sealed class ChannelEvent {
  const ChannelEvent();
}

final class ChannelConnected extends ChannelEvent {
  final int generation;

  const ChannelConnected(this.generation);
}

final class ChannelDisconnected extends ChannelEvent {
  final int generation;
  final Object? error;

  const ChannelDisconnected(this.generation, {this.error});
}

abstract interface class FrameChannel {
  Stream<Uint8List> get frames;

  Stream<ChannelEvent> get events;

  int? get generation;

  Future<int> waitUntilConnected(Duration timeout);

  void send(List<int> frame);

  Future<void> close();
}

/// A new generation is a new session with the Core.
abstract interface class SessionFrameChannel implements FrameChannel {
  void connect();

  void disconnect([Object? error]);
}
