import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

import 'fakes.dart';

final class _FakeIpcServer implements IpcServer {
  final StreamController<IpcEvent> _events = StreamController<IpcEvent>();
  final List<List<int>> sent = [];
  Object? sendError;
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

    test('a failed bind fails open and the transport', () async {
      final failingTransport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) async => throw StateError('bind failed'),
      );
      final failure = failingTransport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first;

      await expectLater(failingTransport.open(), throwsStateError);

      expect((await failure).error.toString(), contains('bind failed'));
      expect(failingTransport.state, DesktopTransportState.failed);
      await expectLater(failingTransport.open(), throwsStateError);
      await expectLater(
        failingTransport.waitUntilConnected(const Duration(seconds: 1)),
        throwsStateError,
      );
      await failingTransport.close();
    });

    test('a server failure is terminal for the transport', () async {
      await transport.open();
      server.connect();
      await pumpEventQueue();
      final events = <DesktopTransportEvent>[];
      final subscription = transport.events.listen(events.add);

      server.fail('accept error');
      server.connect();
      server.message(utf8.encode('late'));
      await pumpEventQueue();

      expect(transport.state, DesktopTransportState.failed);
      final failure = events.single as TransportFailed;
      expect(failure.error.toString(), contains('accept error'));
      await expectLater(transport.open(), throwsStateError);
      await subscription.cancel();
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
    });

    test('closing while binding closes the server that arrives', () async {
      final bound = Completer<IpcServer>();
      final slowTransport = IpcCoreTransport(
        address: 'test-address',
        bind: (_) => bound.future,
      );
      final open = slowTransport.open();
      final rejected = expectLater(open, throwsStateError);

      await slowTransport.close();
      bound.complete(server);

      await rejected;
      expect(server.closeCount, 1);
      expect(slowTransport.state, DesktopTransportState.closed);
    });
  });

  test(
    'transport binding forwards events after replacing its transport',
    () async {
      final firstServer = _FakeIpcServer();
      final secondServer = _FakeIpcServer();
      final first = IpcCoreTransport(
        address: 'first',
        bind: (_) async => firstServer,
      );
      final second = IpcCoreTransport(
        address: 'second',
        bind: (_) async => secondServer,
      );
      final binding = DesktopCoreTransportBinding(first);
      final connectedEvents = <TransportConnected>[];
      final subscription = binding.events.listen((event) {
        if (event is TransportConnected) {
          connectedEvents.add(event);
        }
      });

      await binding.open();
      await binding.replace(second);
      await binding.open();
      secondServer.connect(5678);
      await pumpEventQueue();
      binding.send(utf8.encode('hello'));

      expect(firstServer.closeCount, 1);
      expect(firstServer.sent, isEmpty);
      expect(secondServer.sent, [utf8.encode('hello')]);
      expect(binding.address, 'second');
      expect(connectedEvents.single.pid, 5678);

      await subscription.cancel();
      await binding.close();
    },
  );

  test('replacing a connected transport emits a typed failure', () async {
    final first = FakeDesktopCoreTransport.connected();
    final second = FakeDesktopCoreTransport();
    final binding = DesktopCoreTransportBinding(first);
    final failure = binding.events
        .where((event) => event is TransportFailed)
        .cast<TransportFailed>()
        .first;

    await binding.replace(second);

    expect((await failure).error.toString(), contains('replaced'));
    await binding.close();
  });

  test(
    'replacement remains usable when the old transport close fails',
    () async {
      final first = FakeDesktopCoreTransport()
        ..closeError = StateError('close failed');
      final second = FakeDesktopCoreTransport();
      final binding = DesktopCoreTransportBinding(first);

      await expectLater(
        binding.replace(second),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'close failed',
          ),
        ),
      );

      expect(binding.address, second.address);
      final ready = binding.events
          .where((event) => event is TransportReady)
          .cast<TransportReady>()
          .first;
      second.ready();
      await ready;
      await binding.close();
    },
  );
}
