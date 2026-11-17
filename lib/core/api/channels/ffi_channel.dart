import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/core/api/frame_channel.dart';

/// The C ABI of `libconcord.so` that sessions go through.
abstract interface class ConcordLibrary {
  bool initialize();

  /// Opens a session whose messages are posted to [port]; 0 when the Core refuses.
  int open(SendPort port);

  /// False when the session is gone.
  bool send(int session, Uint8List frame);

  void close(int session);
}

final class NativeConcordLibrary implements ConcordLibrary {
  final int Function(Pointer<Void>) _initialize;
  final int Function(int) _open;
  final int Function(int, Pointer<Uint8>, int) _send;
  final void Function(int) _close;

  NativeConcordLibrary._(this._initialize, this._open, this._send, this._close);

  /// The library Kotlin loaded: the same image, so the Core it started is the one reached here.
  factory NativeConcordLibrary.open() {
    final library = DynamicLibrary.open('libconcord.so');
    return NativeConcordLibrary._(
      library.lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('concord_init_dart_api', isLeaf: true),
      library.lookupFunction<Uint64 Function(Int64), int Function(int)>(
        'concord_open',
        isLeaf: true,
      ),
      library.lookupFunction<
        Int32 Function(Uint64, Pointer<Uint8>, UintPtr),
        int Function(int, Pointer<Uint8>, int)
      >('concord_send', isLeaf: true),
      library.lookupFunction<Void Function(Uint64), void Function(int)>(
        'concord_close',
        isLeaf: true,
      ),
    );
  }

  @override
  bool initialize() => _initialize(NativeApi.initializeApiDLData) == 0;

  @override
  int open(SendPort port) => _open(port.nativePort);

  @override
  bool send(int session, Uint8List frame) {
    final buffer = calloc<Uint8>(frame.length);
    try {
      buffer.asTypedList(frame.length).setAll(0, frame);
      return _send(session, buffer, frame.length) != 0;
    } finally {
      calloc.free(buffer);
    }
  }

  @override
  void close(int session) => _close(session);
}

/// Frames travel as C calls into the Core and as messages to a [ReceivePort] out of it.
/// A port that is gone makes the Core end the session, so an isolate that dies without
/// closing it releases everything it subscribed to.
final class FfiFrameChannel implements SessionFrameChannel {
  final ConcordLibrary Function() _openLibrary;
  final void Function(int session)? _onSession;
  final StreamController<Uint8List> _frames =
      StreamController<Uint8List>.broadcast();
  final StreamController<ChannelEvent> _events =
      StreamController<ChannelEvent>.broadcast();
  ConcordLibrary? _library;
  ReceivePort? _port;
  int _session = 0;
  int _generation = 0;

  FfiFrameChannel({
    ConcordLibrary Function()? library,
    void Function(int session)? onSession,
  }) : _openLibrary = library ?? NativeConcordLibrary.open,
       _onSession = onSession;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<ChannelEvent> get events => _events.stream;

  @override
  int? get generation => _session == 0 ? null : _generation;

  @override
  void connect() {
    if (_session != 0) {
      return;
    }
    final library = _library ?? _initialized();
    final port = ReceivePort();
    final session = library.open(port.sendPort);
    if (session == 0) {
      port.close();
      throw StateError('The Core did not open a session');
    }
    port.listen(_onMessage);
    _port = port;
    _session = session;
    _events.add(ChannelConnected(++_generation));
    _onSession?.call(session);
  }

  ConcordLibrary _initialized() {
    final library = _openLibrary();
    if (!library.initialize()) {
      throw StateError('The Dart API could not be linked to the Core');
    }
    return _library = library;
  }

  void _onMessage(Object? message) {
    if (message is Uint8List) {
      _frames.add(message);
    }
  }

  @override
  void disconnect([Object? error]) {
    final session = _session;
    if (session == 0) {
      return;
    }
    _session = 0;
    _library?.close(session);
    _port?.close();
    _port = null;
    _events.add(ChannelDisconnected(_generation, error: error));
    _onSession?.call(0);
  }

  @override
  Future<int> waitUntilConnected(Duration timeout) {
    final live = generation;
    if (live != null) {
      return Future.value(live);
    }
    return events
        .firstWhere((event) => event is ChannelConnected)
        .then((event) => (event as ChannelConnected).generation)
        .timeout(timeout);
  }

  @override
  void send(List<int> frame) {
    final session = _session;
    if (session == 0) {
      throw StateError('The Core session is closed');
    }
    final data = frame is Uint8List ? frame : Uint8List.fromList(frame);
    if (!_library!.send(session, data)) {
      disconnect(StateError('The Core ended the session'));
    }
  }

  @override
  Future<void> close() async {
    disconnect();
    await _frames.close();
    await _events.close();
  }
}
