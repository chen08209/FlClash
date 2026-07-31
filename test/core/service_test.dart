import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/core/service.dart';
import 'package:fl_clash/core/transport.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _frame(int type, [List<int> payload = const []]) {
  return Uint8List.fromList([type, ...payload]);
}

void main() {
  test('CoreService exposes transport send failures', () async {
    final events = StreamController<Uint8List>();
    final transport = IPCCoreTransport(
      address: 'test-address',
      startServer: (_) => events.stream,
      sendMessage: (_) async => throw StateError('send failed'),
      stopServer: () async {},
    );
    final service = CoreService.forTesting(transport);

    events.add(_frame(0x00));
    events.add(_frame(0x01));

    await expectLater(
      service.invokeMethod<Object?>(method: CoreMethod.getIsInit),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'transport_error')
            .having(
              (error) => error.details,
              'details',
              contains('send failed'),
            ),
      ),
    );

    await transport.close();
    await events.close();
  });

  test('CoreService completes a successful response', () async {
    final events = StreamController<Uint8List>();
    late IPCCoreTransport transport;
    transport = IPCCoreTransport(
      address: 'test-address',
      startServer: (_) => events.stream,
      sendMessage: (data) async {
        final request = jsonDecode(utf8.decode(data)) as Map<String, Object?>;
        events.add(
          _frame(
            0x03,
            utf8.encode(jsonEncode({'id': request['id'], 'result': true})),
          ),
        );
      },
      stopServer: () async {},
    );
    final service = CoreService.forTesting(transport);

    events.add(_frame(0x00));
    events.add(_frame(0x01));

    expect(
      await service.invokeMethod<bool>(method: CoreMethod.getIsInit),
      isTrue,
    );

    await transport.close();
    await events.close();
  });

  test(
    'CoreService waits for expected shutdown without reporting crash',
    () async {
      final events = StreamController<Uint8List>();
      final transport = IPCCoreTransport(
        address: 'test-address',
        startServer: (_) => events.stream,
        sendMessage: (_) async {},
        stopServer: () async {},
      );
      final listener = _CrashListener();
      coreEventManager.addListener(listener);
      final service = CoreService.forTesting(
        transport,
        stopCore: () async {
          events.add(_frame(0x02));
          return true;
        },
      );

      events.add(_frame(0x00));
      events.add(_frame(0x01));
      await transport.connectionCompleter.future;

      expect(await service.shutdown(true), isTrue);
      await pumpEventQueue();
      expect(listener.messages, isEmpty);

      coreEventManager.removeListener(listener);
      await transport.close();
      await events.close();
    },
  );
}

class _CrashListener with CoreEventListener {
  final List<String> messages = [];

  @override
  void onCrash(String message) {
    messages.add(message);
  }
}
