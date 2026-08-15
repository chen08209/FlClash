import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/launcher.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/desktop/transport.dart';

final class FakeDesktopCoreTransport implements DesktopCoreTransport {
  @override
  final String address;

  final List<String> sentMessages = [];
  Object? sendError;
  final StreamController<DesktopTransportEvent> _eventController =
      StreamController<DesktopTransportEvent>.broadcast();
  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  @override
  DesktopTransportState state;

  TransportConnected? _connection;
  TransportFailed? _failure;
  Object? closeError;
  Future<void>? _closeOperation;
  final Completer<void> _closed = Completer<void>();
  int closeCount = 0;

  FakeDesktopCoreTransport({
    this.address = 'test-address',
    this.state = DesktopTransportState.idle,
  });

  factory FakeDesktopCoreTransport.connected({
    String address = 'test-address',
    int? pid = 1234,
  }) {
    final transport = FakeDesktopCoreTransport(
      address: address,
      state: DesktopTransportState.connected,
    );
    transport._connection = TransportConnected(pid: pid, generation: 1);
    return transport;
  }

  @override
  Stream<DesktopTransportEvent> get events => _eventController.stream;

  @override
  Stream<Uint8List> get frames => _frameController.stream;

  @override
  Future<void> open() async {
    if (state == DesktopTransportState.closed) {
      throw StateError('IPC transport is closed');
    }
    if (state == DesktopTransportState.ready ||
        state == DesktopTransportState.connected) {
      return;
    }
    state = DesktopTransportState.starting;
    final event = await events.firstWhere(
      (event) => event is TransportReady || event is TransportFailed,
    );
    if (event case TransportFailed(:final error, :final stackTrace)) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void ready() {
    state = DesktopTransportState.ready;
    _eventController.add(const TransportReady());
  }

  void connect({int? pid, int generation = 1}) {
    final connection = TransportConnected(pid: pid, generation: generation);
    _connection = connection;
    state = DesktopTransportState.connected;
    _eventController.add(connection);
  }

  void disconnect(int generation) {
    if (_connection?.generation == generation) {
      _connection = null;
      state = DesktopTransportState.ready;
    }
    _eventController.add(TransportDisconnected(generation));
  }

  void addJson(Map<String, Object?> value) {
    addFrame(Uint8List.fromList(utf8.encode(jsonEncode(value))));
  }

  void addFrame(Uint8List value) {
    _frameController.add(value);
  }

  void fail(Object error, [StackTrace? stackTrace]) {
    state = DesktopTransportState.failed;
    _failure = TransportFailed(error, stackTrace ?? StackTrace.current);
    _eventController.add(_failure!);
  }

  @override
  Future<TransportConnected> waitUntilConnected(Duration timeout) {
    final connection = _connection;
    if (connection != null) {
      return Future.value(connection);
    }
    final failure = _failure;
    if (failure != null) {
      return Future.error(failure.error, failure.stackTrace);
    }
    return events
        .firstWhere(
          (event) => event is TransportConnected || event is TransportFailed,
        )
        .then<TransportConnected>((event) {
          if (event case TransportConnected()) {
            return event;
          }
          final failure = event as TransportFailed;
          Error.throwWithStackTrace(failure.error, failure.stackTrace);
        })
        .timeout(timeout);
  }

  @override
  Future<void> send(String message) async {
    if (state == DesktopTransportState.closed) {
      throw StateError('IPC transport is closed');
    }
    final error = sendError;
    if (error != null) {
      throw error;
    }
    sentMessages.add(message);
  }

  @override
  Future<void> close() {
    return _closeOperation ??= _close();
  }

  Future<void> _close() async {
    closeCount++;
    state = DesktopTransportState.closed;
    _connection = null;
    await _eventController.close();
    await _frameController.close();
    if (!_closed.isCompleted) {
      _closed.complete();
    }
    final error = closeError;
    if (error != null) {
      throw error;
    }
  }

  Future<void> get closed => _closed.future;
}

final class FakeProcessLease implements CoreProcessLease {
  @override
  final String sessionId;

  @override
  final CoreProcessOwner owner;

  @override
  final int pid;

  CoreProcessStopResult stopResult;
  Completer<void>? stopGate;
  final Completer<void> _stopStarted = Completer<void>();
  int stopCount = 0;

  FakeProcessLease({
    required this.owner,
    required this.pid,
    this.sessionId = '0123456789abcdef0123456789abcdef',
    this.stopResult = const CoreProcessStopResult(
      stopped: true,
      exitConfirmed: true,
    ),
  });

  Future<void> get stopStarted => _stopStarted.future;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) async {
    stopCount++;
    if (!_stopStarted.isCompleted) {
      _stopStarted.complete();
    }
    await stopGate?.future;
    return stopResult;
  }
}

final class FakeLauncher implements CoreProcessLauncher {
  final FakeProcessLease lease;
  Completer<void>? startGate;
  Object? startError;
  final Completer<void> _started = Completer<void>();
  int startCount = 0;

  FakeLauncher({required CoreProcessOwner owner, required int pid})
    : lease = FakeProcessLease(owner: owner, pid: pid);

  FakeLauncher.withLease(this.lease);

  Future<void> get started => _started.future;

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    startCount++;
    if (!_started.isCompleted) {
      _started.complete();
    }
    await startGate?.future;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return lease;
  }
}

final class MutableLauncherResolver implements DesktopCoreLauncherResolver {
  CoreProcessLauncher launcher;
  int resolveCount = 0;

  MutableLauncherResolver(this.launcher);

  @override
  Future<CoreProcessLauncher> resolve() async {
    resolveCount++;
    return launcher;
  }
}
