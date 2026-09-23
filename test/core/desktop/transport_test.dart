import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/transport.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Uint8List _frame(int type, [List<int> payload = const []]) {
  return Uint8List.fromList([type, ...payload]);
}

Uint8List _processIdPayload(int processId) {
  return Uint8List(4)
    ..buffer.asByteData().setUint32(0, processId, Endian.little);
}

void main() {
  group('IPCCoreTransport typed events', () {
    late StreamController<Uint8List> rawEvents;
    late List<List<int>> sentMessages;
    late int stopCount;
    late IPCCoreTransport transport;

    setUp(() {
      rawEvents = StreamController<Uint8List>();
      sentMessages = [];
      stopCount = 0;
      transport = IPCCoreTransport(
        address: 'test-address',
        startServer: (_) => rawEvents.stream,
        sendMessage: (data) async => sentMessages.add(data),
        stopServer: () async => stopCount++,
      );
    });

    tearDown(() async {
      await transport.close();
      if (!rawEvents.isClosed) {
        await rawEvents.close();
      }
    });

    test(
      'emits ready, connected PID, frame, and disconnect generation',
      () async {
        final events = <DesktopTransportEvent>[];
        final subscription = transport.events.listen(events.add);
        final open = transport.open();
        rawEvents.add(_frame(0x00));
        await open;

        final frame = transport.frames.first;
        rawEvents.add(_frame(0x01, _processIdPayload(1234)));
        rawEvents.add(_frame(0x03, utf8.encode('payload')));
        expect(await frame, utf8.encode('payload'));
        rawEvents.add(_frame(0x02));
        await pumpEventQueue();

        expect(events.whereType<TransportReady>(), hasLength(1));
        expect(events.whereType<TransportConnected>().single.pid, 1234);
        expect(events.whereType<TransportConnected>().single.generation, 1);
        expect(events.whereType<TransportDisconnected>().single.generation, 1);
        expect(transport.state, DesktopTransportState.ready);
        await subscription.cancel();
      },
    );

    test('waitUntilConnected waits for a typed connected event', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      final connected = transport.waitUntilConnected(
        const Duration(seconds: 1),
      );
      rawEvents.add(_frame(0x01, _processIdPayload(4321)));

      expect((await connected).pid, 4321);
      expect(transport.state, DesktopTransportState.connected);
    });

    test('forwards outgoing messages after ready', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      await transport.send('hello');

      expect(sentMessages, [utf8.encode('hello')]);
    });

    test('emits startup failure and fails open', () async {
      final failures = transport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first;
      final open = transport.open();
      rawEvents.add(_frame(0x04, utf8.encode('bind failed')));

      await expectLater(open, throwsA(isA<StateError>()));
      expect((await failures).error.toString(), contains('bind failed'));
      expect(transport.state, DesktopTransportState.failed);
    });

    test('fails when the Rust event stream closes before ready', () async {
      final open = transport.open();
      await rawEvents.close();

      await expectLater(open, throwsA(isA<StateError>()));
      expect(transport.state, DesktopTransportState.failed);
    });

    test('rejects an invalid connected process ID frame', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      final failure = transport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first;
      rawEvents.add(_frame(0x01, [0x01]));

      expect((await failure).error.toString(), contains('Invalid IPC'));
      expect(transport.state, DesktopTransportState.failed);
    });

    test('propagates send failures', () async {
      final failingTransport = IPCCoreTransport(
        address: 'test-address',
        startServer: (_) => rawEvents.stream,
        sendMessage: (_) async => throw StateError('send failed'),
        stopServer: () async => stopCount++,
      );
      final open = failingTransport.open();
      rawEvents.add(_frame(0x00));
      await open;

      await expectLater(
        failingTransport.send('hello'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'send failed',
          ),
        ),
      );
      await failingTransport.close();
    });

    test('assigns a fresh generation after reconnecting', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      final connections = <TransportConnected>[];
      final subscription = transport.events.listen((event) {
        if (event is TransportConnected) {
          connections.add(event);
        }
      });
      rawEvents.add(_frame(0x01));
      rawEvents.add(_frame(0x02));
      rawEvents.add(_frame(0x01, _processIdPayload(4321)));
      await pumpEventQueue();

      expect(connections.map((event) => event.generation), [1, 2]);
      expect(connections.last.pid, 4321);
      await subscription.cancel();
    });

    test('a data frame hands out a view rather than a copy', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      final frame = transport.frames.first;
      final source = _frame(0x03, utf8.encode('payload'));
      rawEvents.add(source);

      final payload = await frame;
      expect(payload, utf8.encode('payload'));
      expect(payload.offsetInBytes, 1);
      source[1] = 0x5a;
      expect(payload[0], 0x5a);
    });

    test(
      'a recovered transport stops answering with the old failure',
      () async {
        final open = transport.open();
        rawEvents.add(_frame(0x00));
        await open;

        rawEvents.add(_frame(0x04, utf8.encode('boom')));
        await pumpEventQueue();
        expect(transport.state, DesktopTransportState.failed);
        await expectLater(
          transport.waitUntilConnected(const Duration(seconds: 1)),
          throwsA(isA<StateError>()),
        );

        rawEvents.add(_frame(0x00));
        rawEvents.add(_frame(0x01, _processIdPayload(4321)));
        await pumpEventQueue();

        final connected = await transport.waitUntilConnected(
          const Duration(seconds: 1),
        );
        expect(connected.pid, 4321);
      },
    );

    test('close is idempotent', () async {
      final open = transport.open();
      rawEvents.add(_frame(0x00));
      await open;

      await transport.close();
      await transport.close();

      expect(stopCount, 1);
      expect(transport.state, DesktopTransportState.closed);
    });
  });

  test(
    'transport binding forwards events after replacing its transport',
    () async {
      final firstEvents = StreamController<Uint8List>();
      final secondEvents = StreamController<Uint8List>();
      var firstStopCount = 0;
      final first = IPCCoreTransport(
        address: 'first',
        startServer: (_) => firstEvents.stream,
        sendMessage: (_) async {},
        stopServer: () async => firstStopCount++,
      );
      final second = IPCCoreTransport(
        address: 'second',
        startServer: (_) => secondEvents.stream,
        sendMessage: (_) async {},
        stopServer: () async {},
      );
      final binding = DesktopCoreTransportBinding(first);
      final connectedEvents = <TransportConnected>[];
      final subscription = binding.events.listen((event) {
        if (event is TransportConnected) {
          connectedEvents.add(event);
        }
      });

      final firstOpen = binding.open();
      firstEvents.add(_frame(0x00));
      await firstOpen;
      await binding.replace(second);
      final secondOpen = binding.open();
      secondEvents.add(_frame(0x00));
      await secondOpen;
      secondEvents.add(_frame(0x01, _processIdPayload(5678)));
      await pumpEventQueue();

      expect(firstStopCount, 1);
      expect(binding.address, 'second');
      expect(connectedEvents.single.pid, 5678);

      await subscription.cancel();
      await binding.close();
      await firstEvents.close();
      await secondEvents.close();
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
