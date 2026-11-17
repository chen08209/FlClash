import 'dart:async';
import 'dart:typed_data';

import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:fl_clash/core/desktop/transport.dart';

final class SocketFrameChannel implements FrameChannel {
  final DesktopCoreTransport transport;
  final StreamController<ChannelEvent> _events =
      StreamController<ChannelEvent>.broadcast();
  late final StreamSubscription<DesktopTransportEvent> _subscription;
  int? _generation;

  SocketFrameChannel(this.transport) {
    _subscription = transport.events.listen(_onTransportEvent);
  }

  @override
  Stream<Uint8List> get frames => transport.frames;

  @override
  Stream<ChannelEvent> get events => _events.stream;

  @override
  int? get generation => _generation;

  void _onTransportEvent(DesktopTransportEvent event) {
    switch (event) {
      case TransportConnected(:final generation):
        _generation = generation;
        _events.add(ChannelConnected(generation));
      case TransportDisconnected(:final generation, :final error):
        _generation = null;
        _events.add(ChannelDisconnected(generation, error: error));
      case TransportFailed(:final error):
        final generation = _generation;
        _generation = null;
        if (generation != null) {
          _events.add(ChannelDisconnected(generation, error: error));
        }
      case TransportReady():
        break;
    }
  }

  @override
  Future<int> waitUntilConnected(Duration timeout) async {
    final connected = await transport.waitUntilConnected(timeout);
    return connected.generation;
  }

  @override
  void send(List<int> frame) => transport.send(frame);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _events.close();
  }
}
