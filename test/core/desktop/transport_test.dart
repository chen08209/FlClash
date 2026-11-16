import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

final class _FakeIpcServer implements IpcServer {
  final StreamController<IpcEvent> _events = StreamController<IpcEvent>();
  final List<List<int>> sent = [];
  Object? sendError;
  Object? closeError;
  int closeCount = 0;

  void _add(
    IpcEventKind kind, {
    int? pid,
    List<int> payload = const [],
    String? error,
  }) {
    _events.add(
      IpcEvent(
        kind: kind,
        pid: pid,
        payload: Uint8List.fromList(payload),
        error: error,
      ),
    );
  }

  void connect([int? pid]) => _add(IpcEventKind.connected, pid: pid);

  void message(List<int> payload) {
    _add(IpcEventKind.message, payload: payload);
  }

  void disconnect([String? error]) {
    _add(IpcEventKind.disconnected, error: error);
  }

  void fail(String error) => _add(IpcEventKind.failed, error: error);

  void end() => unawaited(_events.close());

  @override
  Stream<IpcEvent> events() => _events.stream;

  @override
  void send({required List<int> message}) {
    final error = sendError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    sent.add(message);
  }

  @override
  Future<void> close() async {
    closeCount++;
    end();
    final error = closeError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }

  @override
  void dispose() {}

  @override
  bool get isDisposed => false;
}

void main() {
  group('IpcCoreTransport', () {
    late _FakeIpcServer server;
    late List<String> boundAddresses;
    late IpcCoreTransport transport;

    setUp(() {
      server = _FakeIpcServer();
      boundAddresses = [];
      transport = IpcCoreTransport(
        address: 'test-address',
        bind: (address) async {
          boundAddresses.add(address);
          return server;
        },
      );
    });

    tearDown(() async {
      await transport.close();
    });

    test(
      'emits ready, connected PID, frame, and disconnect generation',
      () async {
        final events = <DesktopTransportEvent>[];
        final subscription = transport.events.listen(events.add);
        await transport.open();
        expect(boundAddresses, ['test-address']);
        expect(transport.state, DesktopTransportState.ready);

        final frame = transport.frames.first;
        server.connect(1234);
        server.message(utf8.encode('payload'));
        expect(await frame, utf8.encode('payload'));
        expect(transport.state, DesktopTransportState.connected);
        server.disconnect();
        await pumpEventQueue();

        expect(events.whereType<TransportReady>(), hasLength(1));
        expect(events.whereType<TransportConnected>().single.pid, 1234);
        expect(events.whereType<TransportConnected>().single.generation, 1);
        final disconnected = events.whereType<TransportDisconnected>().single;
        expect(disconnected.generation, 1);
        expect(disconnected.error, isNull);
        expect(transport.state, DesktopTransportState.ready);
        await subscription.cancel();
      },
    );

    test('opening twice binds once', () async {
      await Future.wait([transport.open(), transport.open()]);
      await transport.open();

      expect(boundAddresses, hasLength(1));
    });

    test('waitUntilConnected waits for a connected event', () async {
      await transport.open();

      final connected = transport.waitUntilConnected(
        const Duration(seconds: 1),
      );
      server.connect(4321);

      expect((await connected).pid, 4321);
      expect(transport.state, DesktopTransportState.connected);
    });

    test('hands outgoing frames to the server', () async {
      await transport.open();

      transport.send(utf8.encode('hello'));

      expect(server.sent, [utf8.encode('hello')]);
    });

    test('refuses to send before it is open and after it is closed', () async {
      expect(() => transport.send(const [1]), throwsStateError);

      await transport.open();
      await transport.close();

      expect(() => transport.send(const [1]), throwsStateError);
      expect(server.sent, isEmpty);
    });

    test('propagates send failures', () async {
      server.sendError = StateError('send failed');
      await transport.open();

      expect(
        () => transport.send(utf8.encode('hello')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'send failed',
          ),
        ),
      );
    });

    test('a failed bind fails open until the next one succeeds', () async {
      var attempts = 0;
      final flakyTransport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) async {
          if (++attempts == 1) {
            throw StateError('bind failed');
          }
          return server;
        },
      );
      final failure = flakyTransport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first;

      await expectLater(flakyTransport.open(), throwsStateError);

      expect((await failure).error.toString(), contains('bind failed'));
      expect(flakyTransport.state, DesktopTransportState.failed);
      await expectLater(
        flakyTransport.waitUntilConnected(const Duration(seconds: 1)),
        throwsStateError,
      );

      await flakyTransport.open();
      expect(flakyTransport.state, DesktopTransportState.ready);
      await flakyTransport.close();
    });

    test('fails when the server stops reporting events', () async {
      await transport.open();
      final failure = transport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first;

      server.end();

      expect((await failure).error.toString(), contains('stopped'));
      expect(transport.state, DesktopTransportState.failed);
    });

    test('a disconnect carries the error that ended the connection', () async {
      await transport.open();
      final disconnected = transport.events
          .where((event) => event is TransportDisconnected)
          .cast<TransportDisconnected>()
          .first;

      server.connect();
      server.disconnect('frame exceeds the limit');

      expect((await disconnected).error.toString(), contains('exceeds'));
      expect(transport.state, DesktopTransportState.ready);
    });

    test('assigns a fresh generation after reconnecting', () async {
      await transport.open();
      final connections = <TransportConnected>[];
      final subscription = transport.events.listen((event) {
        if (event is TransportConnected) {
          connections.add(event);
        }
      });

      server.connect();
      server.disconnect();
      server.connect(4321);
      await pumpEventQueue();

      expect(connections.map((event) => event.generation), [1, 2]);
      expect(connections.last.pid, 4321);
      await subscription.cancel();
    });

    test('close is idempotent', () async {
      await transport.open();

      await transport.close();
      await transport.close();

      expect(server.closeCount, 1);
      expect(transport.state, DesktopTransportState.closed);
      await expectLater(transport.open(), throwsStateError);
      await expectLater(
        transport.waitUntilConnected(const Duration(seconds: 1)),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'IPC transport is closed',
          ),
        ),
      );
    });

    test('closing while binding closes the server that arrives', () async {
      final binding = Completer<void>();
      final bound = Completer<IpcServer>();
      final slowTransport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) {
          binding.complete();
          return bound.future;
        },
      );
      final open = slowTransport.open();
      final rejected = expectLater(open, throwsStateError);
      await binding.future;

      await slowTransport.close();
      bound.complete(server);

      await rejected;
      expect(server.closeCount, 1);
      expect(slowTransport.state, DesktopTransportState.closed);
    });
  });

  group('IpcCoreTransport rebinding', () {
    late List<_FakeIpcServer> servers;
    late IpcCoreTransport transport;

    setUp(() {
      servers = [];
      transport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) async {
          final server = _FakeIpcServer();
          servers.add(server);
          return server;
        },
      );
    });

    tearDown(() async {
      await transport.close();
    });

    test(
      'a server failure drops the server and the next open rebinds',
      () async {
        await transport.open();
        servers.single.connect();
        await pumpEventQueue();
        final events = <DesktopTransportEvent>[];
        final subscription = transport.events.listen(events.add);

        servers.single.fail('accept error');
        servers.single.connect();
        servers.single.message(utf8.encode('late'));
        await pumpEventQueue();

        expect(transport.state, DesktopTransportState.failed);
        expect(transport.connection, isNull);
        final failure = events.single as TransportFailed;
        expect(failure.error.toString(), contains('accept error'));
        expect(servers.single.closeCount, 1);
        expect(() => transport.send(const [1]), throwsStateError);

        await transport.open();
        servers.last.connect(77);
        await pumpEventQueue();

        expect(servers, hasLength(2));
        expect(transport.state, DesktopTransportState.connected);
        expect(transport.connection?.generation, 2);
        expect(events.whereType<TransportConnected>().single.pid, 77);
        await subscription.cancel();
      },
    );

    test('reset drops the peer and keeps subscriptions', () async {
      final events = <DesktopTransportEvent>[];
      final subscription = transport.events.listen(events.add);
      await transport.open();
      servers.single.connect(1234);
      await pumpEventQueue();

      await transport.reset();

      expect(transport.state, DesktopTransportState.idle);
      expect(transport.connection, isNull);
      expect(servers.single.closeCount, 1);
      final disconnected = events.whereType<TransportDisconnected>().single;
      expect(disconnected.generation, 1);
      expect(disconnected.error.toString(), contains('reset'));
      expect(events.whereType<TransportFailed>(), isEmpty);

      await transport.open();
      servers.last.connect(5678);
      await pumpEventQueue();
      transport.send(utf8.encode('hello'));

      expect(servers, hasLength(2));
      expect(servers.first.sent, isEmpty);
      expect(servers.last.sent, [utf8.encode('hello')]);
      final connection = events.whereType<TransportConnected>().last;
      expect(connection.pid, 5678);
      expect(connection.generation, 2);
      await subscription.cancel();
    });

    test('closing before the bind begins never binds', () async {
      final open = transport.open();
      final rejected = expectLater(open, throwsStateError);

      await transport.close();

      await rejected;
      expect(servers, isEmpty);
    });

    test('reset stays usable when the dropped server fails to close', () async {
      await transport.open();
      servers.single.closeError = StateError('close failed');

      await expectLater(
        transport.reset(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'close failed',
          ),
        ),
      );

      await transport.open();
      expect(transport.state, DesktopTransportState.ready);
      expect(servers, hasLength(2));
    });

    test('reset discards a bind in flight and closes its server', () async {
      final binding = Completer<void>();
      final bound = Completer<IpcServer>();
      final server = _FakeIpcServer();
      final slowTransport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) {
          binding.complete();
          return bound.future;
        },
      );
      final rejected = expectLater(slowTransport.open(), throwsStateError);
      await binding.future;

      final reset = slowTransport.reset();
      bound.complete(server);
      await reset;

      await rejected;
      expect(server.closeCount, 1);
      expect(slowTransport.state, DesktopTransportState.idle);
      await slowTransport.close();
    });

    test('reset is refused once the transport is closed', () async {
      await transport.close();

      await expectLater(transport.reset(), throwsStateError);
    });
  });
}
