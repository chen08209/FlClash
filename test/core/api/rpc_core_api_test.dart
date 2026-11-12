import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/core/api/rpc_core_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_channel.dart';

void main() {
  late FakeFrameChannel channel;
  late RpcCoreApi api;

  setUp(() {
    channel = FakeFrameChannel();
    final client = CoreClient(channel);
    channel.sentListener = (message) {
      switch (message['method']) {
        case 'core.hello':
          channel.answerHello();
        case 'mitm.exchange':
          channel.answer(message['id'], {
            'result': {'id': 7},
          });
        case 'mitm.body':
          channel.fail(message['id'], {
            'code': -32000,
            'message': 'gone',
            'data': {'kind': 'not_found'},
          });
      }
    };
    channel.connect();
    api = RpcCoreApi(client);
    addTearDown(() async {
      await client.close();
      await channel.close();
    });
  });

  test('an MITM answer reaches the caller without its envelope', () async {
    expect(await api.mitmExchange(7), {'id': 7});
  });

  test('an MITM record the Core has dropped reads as null', () async {
    expect(await api.mitmBody(7, response: true), isNull);
  });
}
