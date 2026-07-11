import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/transport.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _frame(int type, [List<int> payload = const []]) {
  return Uint8List.fromList([type, ...payload]);
}

Uint8List _processIdPayload(int processId) {
  return Uint8List(4)
    ..buffer.asByteData().setUint32(0, processId, Endian.little);
}

void main() {
  test('Windows Core pipe uses a 128-bit random suffix', () {
    const prefix = r'\\.\pipe\FlClashCore_';
    expect(windowsPipeName, startsWith(prefix));
    expect(
      windowsPipeName.substring(prefix.length),
      matches(RegExp(r'^[0-9a-f]{32}$')),
    );
  });

  group('IPCCoreTransport', () {
    late StreamController<Uint8List> events;
    late List<List<int>> sentMessages;
    late Object? sendError;
    late int stopCount;
    late bool transportClosed;
    late IPCCoreTransport transport;

    setUp(() {
      events = StreamController<Uint8List>();
      sentMessages = [];
      sendError = null;
      stopCount = 0;
      transportClosed = false;
      transport = IPCCoreTransport(
        address: 'test-address',
        startServer: (_) => events.stream,
        sendMessage: (data) async {
          final error = sendError;
          if (error != null) {
            throw error;
          }
          sentMessages.add(data);
        },
        stopServer: () async => stopCount++,
      );
    });

    tearDown(() async {
      if (!transportClosed) {
        await transport.close();
      }
      if (!events.isClosed) {
        await events.close();
      }
    });

    test('waits for ready and forwards outgoing messages', () async {
      final initFuture = transport.init();
      events.add(_frame(0x00));

      await initFuture;
      await transport.send('hello');

      expect(sentMessages, [utf8.encode('hello')]);

      await transport.close();
      transportClosed = true;
      expect(stopCount, 1);
    });

    test('propagates startup error frames', () async {
      final initFuture = transport.init();
      events.add(_frame(0x04, utf8.encode('bind failed')));

      await expectLater(
        initFuture,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('bind failed'),
          ),
        ),
      );
    });

    test('fails when the Rust event stream closes before ready', () async {
      var disconnected = false;
      transport.onDisconnect = () => disconnected = true;
      final initFuture = transport.init();
      await events.close();

      await expectLater(
        initFuture,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('before becoming ready'),
          ),
        ),
      );
      expect(disconnected, isFalse);
    });

    test('propagates send failures', () async {
      sendError = StateError('send failed');
      final initFuture = transport.init();
      events.add(_frame(0x00));
      await initFuture;

      await expectLater(
        transport.send('hello'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'send failed',
          ),
        ),
      );
    });

    test('forwards data and reports client disconnection', () async {
      var disconnected = false;
      transport.onDisconnect = () => disconnected = true;
      final initFuture = transport.init();
      events.add(_frame(0x00));
      await initFuture;

      final dataFuture = transport.dataStream.first;
      events.add(_frame(0x03, utf8.encode('payload')));
      expect(await dataFuture, utf8.encode('payload'));

      events.add(_frame(0x02));
      await pumpEventQueue();
      expect(disconnected, isTrue);
    });

    test('waits for a fresh connection across a disconnection', () async {
      final initFuture = transport.init();
      events.add(_frame(0x00));
      await initFuture;

      events.add(_frame(0x01));
      await transport.connectionCompleter.future;

      var reconnected = false;
      final nextConnection = transport.waitForNextConnection().then((
        processId,
      ) {
        reconnected = true;
        return processId;
      });

      await pumpEventQueue();
      expect(reconnected, isFalse);

      events.add(_frame(0x02));
      await pumpEventQueue();
      expect(reconnected, isFalse);

      events.add(_frame(0x01, _processIdPayload(4321)));
      expect(await nextConnection, 4321);
      expect(reconnected, isTrue);
    });

    test('returns the connected client process ID', () async {
      final initFuture = transport.init();
      events.add(_frame(0x00));
      await initFuture;

      final nextConnection = transport.waitForNextConnection();
      events.add(_frame(0x01, _processIdPayload(1234)));

      expect(await nextConnection, 1234);
    });

    test(
      'does not abandon connection waiters on repeated disconnects',
      () async {
        final initFuture = transport.init();
        events.add(_frame(0x00));
        await initFuture;

        final connection = transport.connectionCompleter.future;
        transport.disconnected();
        events.add(_frame(0x02));
        await pumpEventQueue();

        events.add(_frame(0x01));
        await connection;
      },
    );
  });
}
