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
