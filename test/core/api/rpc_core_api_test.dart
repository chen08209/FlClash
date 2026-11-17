import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/core/api/model_api.dart';
import 'package:fl_clash/core/api/rpc_core_api.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
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
        case 'mitm.validate':
          channel.answer(message['id'], {
            'issues': {
              'hostname': [
                {'index': 0, 'kind': 'invalid', 'message': 'bad port'},
              ],
            },
            'views': {
              'hostname': [
                {
                  'index': 0,
                  'view': {
                    'type': 'hosts',
                    'entries': [
                      {'host': 'a.example.com', 'exclude': true},
                    ],
                  },
                },
              ],
              'url-rewrite': [
                {
                  'index': 1,
                  'view': {'type': 'fromALaterCore'},
                },
              ],
            },
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

  test('a partly applied MITM line has both its issue and its view', () async {
    final check = await api.checkMitmRules(
      const MitmRules(
        hostname: ['-a.example.com, a.example.com:x'],
        urlRewrite: ['', 'later'],
      ),
    );

    expect(check.issues, {
      MitmList.hostname: {0: 'bad port'},
    });
    expect(check.views[MitmList.hostname], {
      0: const MitmLineView.hosts(
        entries: [MitmHostEntry(host: 'a.example.com', exclude: true)],
      ),
    });
    expect(check.views[MitmList.urlRewrite], isEmpty);
  });

  test('an MITM record the Core has dropped reads as null', () async {
    expect(await api.mitmBody(7, response: true), isNull);
  });
}
