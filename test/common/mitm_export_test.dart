import 'dart:convert';

import 'package:fl_clash/common/mitm_export.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _exchange = MitmExchange(
  id: 1,
  start: DateTime.utc(2026, 10, 28, 1, 2, 3, 456),
  duration: 50,
  ttfb: 20,
  method: 'POST',
  url: 'https://a.test:8443/api?q=1&q=2',
  proto: 'HTTP/2.0',
  status: 200,
  requestSize: 9,
  responseSize: 7,
  connection: 'connection-1',
  requestHeader: const {
    'Accept-Encoding': ['gzip, br'],
    'Content-Length': ['9'],
    'Content-Type': ['application/json'],
    'Host': ['a.test:8443'],
    'X-Note': ["it's"],
  },
  responseHeader: const {
    'Content-Type': ['text/plain'],
  },
);

MitmBody _body(List<int> bytes, {bool truncated = false}) =>
    MitmBody(data: base64Encode(bytes), truncated: truncated);

void main() {
  test(
    'a request and a response copy as HTTP text, a binary body as Base64',
    () {
      final request = mitmRawRequest((
        _exchange,
        MitmBody(data: base64Encode(utf8.encode('a=1'))),
      ));
      expect(request, startsWith('POST /api?q=1&q=2 HTTP/2.0\n'));
      expect(request, endsWith('\n\na=1'));
      final response = mitmRawResponse((
        _exchange,
        MitmBody(data: base64Encode([0, 1])),
      ));
      expect(response, startsWith('HTTP/2.0 200'));
      expect(response, endsWith('\n\nAAE='));
    },
  );

  group('cURL', () {
    test('sends the headers and the body again, quoted for the shell', () {
      expect(
        mitmCurl(_exchange, _body(utf8.encode('{"a":"\'"}'))),
        "curl 'https://a.test:8443/api?q=1&q=2' \\\n"
        "  -H 'Accept-Encoding: gzip, br' \\\n"
        "  -H 'Content-Type: application/json' \\\n"
        "  -H 'X-Note: it'\\''s' \\\n"
        '  --compressed \\\n'
        "  --data-raw '{\"a\":\"'\\''\"}'",
      );
    });

    test(
      'names the method curl would not pick, and pipes in a binary body',
      () {
        final put = _exchange.copyWith(method: 'PUT', requestHeader: const {});
        expect(
          mitmCurl(put, _body([0, 1, 2])),
          "printf '%s' 'AAEC' | base64 --decode | "
          "curl 'https://a.test:8443/api?q=1&q=2' \\\n"
          "  -X 'PUT' \\\n"
          '  --data-binary @-',
        );
        expect(
          mitmCurl(put.copyWith(method: 'GET'), null),
          "curl 'https://a.test:8443/api?q=1&q=2'",
        );
        expect(
          mitmCurl(put.copyWith(method: 'HEAD'), null),
          "curl 'https://a.test:8443/api?q=1&q=2' \\\n  --head",
        );
      },
    );
  });

  group('HAR', () {
    Map<String, Object?> entryOf(MitmBody? request, MitmBody? response) {
      final har =
          jsonDecode(mitmHar((_exchange, request, response, '1.0.0')))
              as Map<String, Object?>;
      final log = har['log']! as Map<String, Object?>;
      expect(log['version'], '1.2');
      expect(log['creator'], {'name': 'FlClash', 'version': '1.0.0'});
      return (log['entries']! as List).single as Map<String, Object?>;
    }

    test('holds the request, its timings and both bodies', () {
      final entry = entryOf(
        _body(utf8.encode('{"a":1}')),
        _body(utf8.encode('ok'), truncated: true),
      );
      expect(entry['startedDateTime'], '2026-10-28T01:02:03.456Z');
      expect(entry['time'], 50);
      expect(entry['timings'], {'send': 0, 'wait': 20, 'receive': 30});
      final request = entry['request']! as Map<String, Object?>;
      expect(request['queryString'], [
        {'name': 'q', 'value': '1'},
        {'name': 'q', 'value': '2'},
      ]);
      expect(request['postData'], {
        'mimeType': 'application/json',
        'text': '{"a":1}',
      });
      final response = entry['response']! as Map<String, Object?>;
      expect(response['status'], 200);
      expect(response['content'], {
        'size': 2,
        'mimeType': 'text/plain',
        'text': 'ok',
        'comment': 'truncated',
      });
    });

    test('carries a body that is not text as Base64', () {
      final entry = entryOf(null, _body([0, 255]));
      final request = entry['request']! as Map<String, Object?>;
      expect(request.containsKey('postData'), isFalse);
      final response = entry['response']! as Map<String, Object?>;
      expect(response['content'], {
        'size': 2,
        'mimeType': 'text/plain',
        'text': 'AP8=',
        'encoding': 'base64',
      });
    });
  });
}
