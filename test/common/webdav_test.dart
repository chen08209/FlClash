import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/webdav.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._responses);

  final ResponseBody Function(RequestOptions options) _responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _responses(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_ScriptedAdapter adapter) => Dio()..httpClientAdapter = adapter;

void main() {
  test(
    'redirect to a different origin drops the Authorization header',
    () async {
      var call = 0;
      final adapter = _ScriptedAdapter((options) {
        call++;
        if (call == 1) {
          return ResponseBody.fromString(
            '',
            302,
            headers: {
              'location': ['http://other.example/target'],
            },
          );
        }
        return ResponseBody.fromString('', 204);
      });
      final transport = DAVTransport(
        uri: 'http://origin.example/base',
        user: 'user',
        password: 'pass',
        dio: _dioWith(adapter),
      );

      await transport.options('probe');

      expect(adapter.requests, hasLength(2));
      expect(adapter.requests[0].headers, contains('authorization'));
      expect(adapter.requests[1].uri.host, 'other.example');
      expect(adapter.requests[1].headers, isNot(contains('authorization')));
    },
  );

  test(
    'redirect within the same origin keeps the Authorization header',
    () async {
      var call = 0;
      final adapter = _ScriptedAdapter((options) {
        call++;
        if (call == 1) {
          return ResponseBody.fromString(
            '',
            302,
            headers: {
              'location': ['http://origin.example/base/moved'],
            },
          );
        }
        return ResponseBody.fromString('', 204);
      });
      final transport = DAVTransport(
        uri: 'http://origin.example/base',
        user: 'user',
        password: 'pass',
        dio: _dioWith(adapter),
      );

      await transport.options('probe');

      expect(adapter.requests, hasLength(2));
      expect(adapter.requests[1].headers, contains('authorization'));
    },
  );

  test(
    'a Digest challenge is found even behind a Basic www-authenticate line',
    () async {
      var call = 0;
      final adapter = _ScriptedAdapter((options) {
        call++;
        if (call == 1) {
          return ResponseBody.fromString(
            '',
            401,
            headers: {
              'www-authenticate': [
                'Basic realm="x"',
                'Digest realm="y", nonce="abc123", qop="auth", opaque="op1"',
              ],
            },
          );
        }
        return ResponseBody.fromString('', 204);
      });
      final transport = DAVTransport(
        uri: 'http://origin.example/base',
        user: 'user',
        password: 'pass',
        dio: _dioWith(adapter),
      );

      await transport.options('probe');

      expect(adapter.requests, hasLength(2));
      final retryAuth = adapter.requests[1].headers['authorization'] as String;
      expect(retryAuth, startsWith('Digest '));
      expect(retryAuth, contains('realm="y"'));
    },
  );
}
