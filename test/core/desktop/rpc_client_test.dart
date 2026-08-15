import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/rpc_client.dart';
import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<Map<String, Object?>> _sentRequest(
  FakeDesktopCoreTransport transport,
) async {
  await pumpEventQueue();
  return jsonDecode(transport.sentMessages.single) as Map<String, Object?>;
}

void main() {
  test('correlates a response and ignores a late duplicate', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);
    final request = await _sentRequest(transport);

    transport.addJson({'id': request['id'], 'result': true});
    expect(await invocation, isTrue);
    transport.addJson({'id': request['id'], 'result': false});
    await pumpEventQueue();

    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('disconnect fails every pending request exactly once', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);
    await _sentRequest(transport);

    transport.disconnect(1);

    await expectLater(
      invocation,
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'transport_disconnected',
        ),
      ),
    );
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('maps a Core error envelope to CoreMethodException', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);
    final request = await _sentRequest(transport);

    transport.addJson({
      'id': request['id'],
      'error': {
        'code': 'core_error',
        'message': 'Core rejected the request',
        'details': 'details',
      },
    });

    await expectLater(
      invocation,
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.details, 'details', 'details'),
      ),
    );
    await client.close();
    await transport.close();
  });

  test('maps send failures to a transport error', () async {
    final transport = FakeDesktopCoreTransport.connected()
      ..sendError = StateError('send failed');
    final client = CoreRpcClient(transport);

    await expectLater(
      client.invoke<bool>(method: CoreMethod.getIsInit),
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'transport_error',
        ),
      ),
    );
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('request timeout cleans only that pending request', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);

    final result = await client.invoke<bool>(
      method: CoreMethod.getIsInit,
      timeout: Duration.zero,
    );

    expect(result, isNull);
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('waiting for a connection never outlives the request timeout', () async {
    final transport = FakeDesktopCoreTransport();
    final client = CoreRpcClient(transport);
    final stopwatch = Stopwatch()..start();

    final result = await client.invoke<bool>(
      method: CoreMethod.asyncTestDelay,
      timeout: const Duration(milliseconds: 150),
    );

    expect(result, isNull);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
    expect(transport.sentMessages, isEmpty);
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('a silent link times out the pending request', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);

    final result = await client.invoke<bool>(
      method: CoreMethod.getIsInit,
      timeout: const Duration(milliseconds: 150),
    );

    expect(result, isNull);
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });

  test('a pending request survives while Core answers its siblings', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    const timeout = Duration(milliseconds: 300);

    final slow = client.invoke<bool>(
      method: CoreMethod.asyncTestDelay,
      timeout: timeout,
    );
    final sibling = client.invoke<bool>(
      method: CoreMethod.asyncTestDelay,
      timeout: timeout,
    );
    await pumpEventQueue();
    final requests = transport.sentMessages
        .map((message) => jsonDecode(message) as Map<String, Object?>)
        .toList();
    expect(requests, hasLength(2));

    await Future<void>.delayed(const Duration(milliseconds: 200));
    transport.addJson({'id': requests[1]['id'], 'result': true});
    expect(await sibling, isTrue);

    // Past the original window, but the link proved itself 200ms in.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(client.pendingCount, 1);
    transport.addJson({'id': requests[0]['id'], 'result': true});
    expect(await slow, isTrue);

    await client.close();
    await transport.close();
  });

  test('extension is capped so a wedged request still fails', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    const timeout = Duration(milliseconds: 200);

    final wedged = client.invoke<bool>(
      method: CoreMethod.asyncTestDelay,
      timeout: timeout,
    );
    await pumpEventQueue();
    final request = jsonDecode(transport.sentMessages.first) as Map;

    // Core stays chatty about everything except this request.
    final chatter = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => transport.addJson({'id': 'other', 'result': true}),
    );
    addTearDown(chatter.cancel);

    expect(await wedged, isNull);
    expect(client.pendingCount, 0);
    expect(request['id'], isNotNull);

    await client.close();
    await transport.close();
  });

  test(
    'a long request budget stops extending once the grace is spent',
    () async {
      const timeout = Duration(milliseconds: 200);
      const grace = Duration(milliseconds: 100);
      expect(timeout + grace, lessThan(timeout * 3));

      final transport = FakeDesktopCoreTransport.connected();
      final client = CoreRpcClient(transport, extensionGrace: grace);

      final stopwatch = Stopwatch()..start();
      final wedged = client.invoke<bool>(
        method: CoreMethod.getIsInit,
        timeout: timeout,
      );
      final chatter = Timer.periodic(
        const Duration(milliseconds: 30),
        (_) => transport.addJson({'id': 'other', 'result': true}),
      );
      addTearDown(chatter.cancel);

      expect(await wedged, isNull);
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
      expect(client.pendingCount, 0);

      await client.close();
      await transport.close();
    },
  );

  test('malformed data does not terminate response processing', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    transport.addFrame(Uint8List.fromList(utf8.encode('{invalid')));
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);
    final request = await _sentRequest(transport);

    transport.addJson({'id': request['id'], 'result': true});

    expect(await invocation, isTrue);
    await client.close();
    await transport.close();
  });

  test('forwards Core message events', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    final listener = _LoadedListener();
    coreEventManager.addListener(listener);

    transport.addJson({
      'method': CoreMethod.message.name,
      'arguments': {'type': 'loaded', 'data': 'provider-a'},
    });

    expect(await listener.loaded.future, 'provider-a');
    coreEventManager.removeListener(listener);
    await client.close();
    await transport.close();
  });

  test('close fails pending requests and is idempotent', () async {
    final transport = FakeDesktopCoreTransport.connected();
    final client = CoreRpcClient(transport);
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);
    await _sentRequest(transport);

    final failure = expectLater(
      invocation,
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'transport_disconnected',
        ),
      ),
    );
    await client.close();
    await client.close();

    await failure;
    expect(client.pendingCount, 0);
    await transport.close();
  });

  test('transport failure before connection fails without waiting', () async {
    final transport = FakeDesktopCoreTransport();
    final client = CoreRpcClient(transport);
    final invocation = client.invoke<bool>(method: CoreMethod.getIsInit);

    transport.fail(StateError('bind failed'));

    await expectLater(
      invocation,
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'transport_error',
        ),
      ),
    );
    expect(client.pendingCount, 0);
    await client.close();
    await transport.close();
  });
}

final class _LoadedListener with CoreEventListener {
  final Completer<String> loaded = Completer<String>();

  @override
  void onLoaded(String providerName) {
    loaded.complete(providerName);
  }
}
