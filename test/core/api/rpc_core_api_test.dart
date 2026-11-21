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
              'script': [
                {
                  'index': 0,
                  'view': {
                    'type': 'script',
                    'name': 'n',
                    'kind': 'httpResponse',
                    'path': 'n.js',
                    'pattern': '^https://a',
                    'requiresBody': true,
                    'binaryBody': false,
                    'timeoutMs': 10000,
                  },
                },
              ],
              'map-local': [
                {
                  'index': 0,
                  'view': {
                    'type': 'mapLocal',
                    'pattern': '^https://b',
                    'dataType': 'text',
                    'data': '{}',
                    'status': 200,
                    'headers': [
                      {'name': 'X-A', 'value': '1'},
                    ],
                    'contentType': 'application/json',
                  },
                },
              ],
            },
          });
        case 'rule.list':
          channel.answer(message['id'], {
            'rules': [
              {'type': 'DOMAIN', 'payload': 'a.test', 'target': 'Proxy'},
              {'type': 'MATCH', 'payload': '', 'target': 'DIRECT'},
            ],
          });
        case 'mitm.query':
          channel.answer(message['id'], {
            'capturing': true,
            'since': '2026-11-21T08:00:00Z',
            'version': 9,
            'oldest': 3,
            'held': 2,
            'matched': 1,
            'exchanges': [
              {
                'id': 4,
                'start': '2026-11-21T08:00:01Z',
                'duration': 12,
                'method': 'GET',
                'url': 'https://a.test/x',
                'status': 404,
                'request-size': 0,
                'response-size': 5,
                'host': 'a.test',
                'path': '/x',
                'status-class': '4xx',
                'kind': 'json',
                'action-kinds': ['header-rewrite', 'map-local'],
                'answer': 'map-local',
                'connection-id': 21,
                'app': {'process': 'curl'},
              },
            ],
            'next': 3,
            'unmatched': [2],
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
        script: ['n'],
        mapLocal: ['b'],
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
    expect(check.views[MitmList.script], {
      0: const MitmLineView.script(
        name: 'n',
        kind: 'httpResponse',
        path: 'n.js',
        pattern: '^https://a',
        requiresBody: true,
        timeoutMs: 10000,
      ),
    });
    expect(check.views[MitmList.mapLocal], {
      0: const MitmLineView.mapLocal(
        pattern: '^https://b',
        dataType: 'text',
        data: '{}',
        status: 200,
        headers: [MitmHeader(name: 'X-A', value: '1')],
        contentType: 'application/json',
      ),
    });
  });

  test('the rules in force read in match order', () async {
    final rules = await api.getRules();
    expect(rules.length, 2);
    expect(rules.holds(0, type: 'DOMAIN', payload: 'a.test'), isTrue);
    expect(rules.holds(1, type: 'DOMAIN', payload: 'a.test'), isFalse);
  });

  test(
    'a page of the HTTP capture reads as the request page wants it',
    () async {
      final page = await api.queryMitmExchanges(limit: 50);
      expect(page.capturing, isTrue);
      expect(page.since, DateTime.utc(2026, 11, 21, 8));
      expect(
        (page.version, page.oldest, page.held, page.matched),
        (9, 3, 2, 1),
      );
      expect(page.next, 3);
      expect(page.unmatched, [2]);
      final exchange = page.exchanges.single;
      expect(exchange.statusClass, '4xx');
      expect(exchange.kind, 'json');
      expect(exchange.actionKinds, ['header-rewrite', 'map-local']);
      expect(exchange.answer, 'map-local');
      expect(exchange.connectionId, 21);
      expect(exchange.app?.process, 'curl');
      expect(exchange.start, DateTime.utc(2026, 11, 21, 8, 0, 1));
    },
  );

  test('an MITM record the Core has dropped reads as null', () async {
    expect(await api.mitmBody(7, response: true), isNull);
  });
}
