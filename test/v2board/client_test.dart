import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fl_clash/v2board/v2board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('V2BoardRemoteConfig', () {
    test('reads and normalizes API domains from OSS JSON', () {
      final config = V2BoardRemoteConfig.decode('''
        {
          "domain": [
            "https://api.example.com/api/v1/",
            "invalid",
            "https://api.example.com/api/v1/"
          ]
        }
      ''');

      expect(config.domains, ['https://api.example.com/api/v1']);
    });

    test('accepts base64 encoded JSON', () {
      final source = base64.encode(
        utf8.encode('{"domain":["https://api.example.com/api/v1"]}'),
      );

      expect(V2BoardRemoteConfig.decode(source).domains, [
        'https://api.example.com/api/v1',
      ]);
    });

    test('rejects config without valid API domains', () {
      expect(
        () => V2BoardRemoteConfig.decode('{"domain":[]}'),
        throwsFormatException,
      );
    });
  });

  group('V2BoardClient', () {
    test('loads OSS domains, logs in, and fetches subscription', () async {
      final transport = _FakeTransport()
        ..gets['https://oss.example.com/config.json'] = {
          'domain': ['https://api.example.com/api/v1/'],
        }
        ..posts['https://api.example.com/api/v1/passport/auth/login'] = {
          'data': {'auth_data': 'session-token'},
        }
        ..gets['https://api.example.com/api/v1/user/getSubscribe'] = {
          'data': {
            'email': 'user@example.com',
            'subscribe_url': 'https://sub.example.com/client?token=abc',
          },
        };
      final client = V2BoardClient(
        transport: transport,
        ossConfigUrl: 'https://oss.example.com/config.json',
      );

      final session = await client.login(
        email: ' user@example.com ',
        password: 'secret',
      );

      expect(session.authData, 'session-token');
      expect(session.email, 'user@example.com');
      expect(session.subscribeUrl, 'https://sub.example.com/client?token=abc');
      expect(transport.postBodies.single, {
        'email': 'user@example.com',
        'password': 'secret',
      });
      expect(transport.getHeaders.last, {'Authorization': 'session-token'});
    });

    test(
      'tries the next OSS API domain when the first is unavailable',
      () async {
        final transport = _FakeTransport()
          ..gets['https://oss.example.com/config.json'] = {
            'domain': [
              'https://first.example.com/api/v1',
              'https://second.example.com/api/v1',
            ],
          }
          ..postErrors['https://first.example.com/api/v1/passport/auth/login'] =
              DioException(
                requestOptions: RequestOptions(path: '/login'),
                type: DioExceptionType.connectionError,
              )
          ..posts['https://second.example.com/api/v1/passport/auth/login'] = {
            'data': {'auth_data': 'second-token'},
          }
          ..gets['https://second.example.com/api/v1/user/getSubscribe'] = {
            'data': {
              'email': 'user@example.com',
              'subscribe_url': 'https://sub.example.com/profile',
            },
          };
        final client = V2BoardClient(
          transport: transport,
          ossConfigUrl: 'https://oss.example.com/config.json',
        );

        final session = await client.login(
          email: 'user@example.com',
          password: 'secret',
        );

        expect(session.authData, 'second-token');
        expect(transport.postUrls, [
          'https://first.example.com/api/v1/passport/auth/login',
          'https://second.example.com/api/v1/passport/auth/login',
        ]);
      },
    );

    test('restore validates auth data through getSubscribe', () async {
      final transport = _FakeTransport()
        ..gets['https://oss.example.com/config.json'] = {
          'domain': ['https://api.example.com/api/v1'],
        }
        ..gets['https://api.example.com/api/v1/user/getSubscribe'] = {
          'data': {
            'email': 'user@example.com',
            'subscribe_url': 'https://sub.example.com/profile',
          },
        };
      final client = V2BoardClient(
        transport: transport,
        ossConfigUrl: 'https://oss.example.com/config.json',
      );

      final session = await client.restore('saved-token');

      expect(session.authData, 'saved-token');
      expect(transport.getHeaders.last, {'Authorization': 'saved-token'});
    });

    test('requires OSS_CONFIG_URL', () async {
      final client = V2BoardClient(
        transport: _FakeTransport(),
        ossConfigUrl: '',
      );

      await expectLater(
        client.login(email: 'user@example.com', password: 'secret'),
        throwsA(
          isA<V2BoardException>().having(
            (error) => error.kind,
            'kind',
            V2BoardExceptionKind.configuration,
          ),
        ),
      );
    });
  });
}

class _FakeTransport implements V2BoardTransport {
  final gets = <String, Object?>{};
  final posts = <String, Object?>{};
  final getErrors = <String, Object>{};
  final postErrors = <String, Object>{};
  final getUrls = <String>[];
  final postUrls = <String>[];
  final getHeaders = <Map<String, Object?>?>[];
  final postBodies = <Map<String, Object?>>[];

  @override
  Future<Object?> get(String url, {Map<String, Object?>? headers}) async {
    getUrls.add(url);
    getHeaders.add(headers);
    final error = getErrors[url];
    if (error != null) throw error;
    return gets[url];
  }

  @override
  Future<Object?> post(
    String url, {
    required Map<String, Object?> data,
    Map<String, Object?>? headers,
  }) async {
    postUrls.add(url);
    postBodies.add(data);
    final error = postErrors[url];
    if (error != null) throw error;
    return posts[url];
  }
}
