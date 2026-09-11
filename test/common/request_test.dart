import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._response);

  final ResponseBody Function(RequestOptions options, int requestNumber)
  _response;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _response(options, requests.length);
  }

  @override
  void close({bool force = false}) {}
}

Request _requestWith(
  _ScriptedAdapter adapter, {
  Future<List<InternetAddress>> Function(String host)? resolveHost,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return Request(clashDio: dio, resolveHost: resolveHost);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getTextResponseForUrl propagates the typed DioException', () async {
    // flutter_test's mocked HttpClient answers every request with HTTP 400,
    // which Dio surfaces as a badResponse DioException.
    await expectLater(
      request.getTextResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('getFileResponseForUrl propagates the typed DioException', () async {
    await expectLater(
      request.getFileResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('follows a redirect whose host resolves publicly', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      if (requestNumber == 1) {
        return ResponseBody.fromString(
          '',
          HttpStatus.found,
          headers: {
            'location': ['https://cdn.example/profile'],
          },
        );
      }
      return ResponseBody.fromString('profile', HttpStatus.ok);
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) async => [InternetAddress('93.184.216.34')],
    );

    final response = await client.getTextResponseForUrl(
      'https://origin.example/profile',
    );

    expect(response.data, 'profile');
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.last.uri, Uri.parse('https://cdn.example/profile'));
  });

  test('resolves a relative redirect before validating it', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      if (requestNumber == 1) {
        return ResponseBody.fromString(
          '',
          HttpStatus.temporaryRedirect,
          headers: {
            'location': ['/moved'],
          },
        );
      }
      return ResponseBody.fromString('profile', HttpStatus.ok);
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) async => [InternetAddress('93.184.216.34')],
    );

    await client.getTextResponseForUrl('https://origin.example/profile');

    expect(
      adapter.requests.last.uri,
      Uri.parse('https://origin.example/moved'),
    );
  });

  test('rejects redirect targets on local networks', () async {
    final targets = [
      'http://127.0.0.1:47890/logs',
      'http://10.0.0.1/',
      'http://169.254.169.254/',
      'http://192.168.1.1/',
      'http://198.18.0.1/',
      'http://localhost/',
      'http://service.localhost/',
      'http://[::1]/',
      'http://[fd00::1]/',
      'http://[fe80::1]/',
      'http://[::ffff:127.0.0.1]/',
      'http://2130706433/',
    ];

    for (final target in targets) {
      final adapter = _ScriptedAdapter((options, requestNumber) {
        return ResponseBody.fromString(
          '',
          HttpStatus.found,
          headers: {
            'location': [target],
          },
        );
      });
      final client = _requestWith(
        adapter,
        resolveHost: (_) async => [InternetAddress.loopbackIPv4],
      );

      await expectLater(
        client.getTextResponseForUrl('https://origin.example/profile'),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.type,
                'type',
                DioExceptionType.badResponse,
              )
              .having(
                (error) => error.message,
                'message',
                'Profile redirect target is not allowed',
              ),
        ),
        reason: target,
      );
      expect(adapter.requests, hasLength(1), reason: target);
    }
  });

  test('rejects a hostname when any resolved address is private', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      return ResponseBody.fromString(
        '',
        HttpStatus.found,
        headers: {
          'location': ['https://internal.example/profile'],
        },
      );
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) async => [
        InternetAddress('93.184.216.34'),
        InternetAddress('10.0.0.1'),
      ],
    );

    await expectLater(
      client.getTextResponseForUrl('https://origin.example/profile'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(1));
  });

  test('allows a public hostname resolved through Clash fake IP DNS', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      if (requestNumber == 1) {
        return ResponseBody.fromString(
          '',
          HttpStatus.found,
          headers: {
            'location': ['https://cdn.example/profile'],
          },
        );
      }
      return ResponseBody.fromString('profile', HttpStatus.ok);
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) async => [InternetAddress('198.18.0.1')],
    );

    final response = await client.getTextResponseForUrl(
      'https://origin.example/profile',
    );

    expect(response.data, 'profile');
    expect(adapter.requests, hasLength(2));
  });

  test('rejects a redirect target that cannot be resolved', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      return ResponseBody.fromString(
        '',
        HttpStatus.found,
        headers: {
          'location': ['https://missing.example/profile'],
        },
      );
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) => throw const SocketException('lookup failed'),
    );

    await expectLater(
      client.getTextResponseForUrl('https://origin.example/profile'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(1));
  });

  test('rejects redirects without a usable HTTP location', () async {
    final locations = <String?>[null, '', 'file:///tmp/profile'];

    for (final location in locations) {
      final adapter = _ScriptedAdapter((options, requestNumber) {
        return ResponseBody.fromString(
          '',
          HttpStatus.found,
          headers: {
            if (location != null) 'location': [location],
          },
        );
      });
      final client = _requestWith(adapter);

      await expectLater(
        client.getTextResponseForUrl('https://origin.example/profile'),
        throwsA(isA<DioException>()),
        reason: '$location',
      );
      expect(adapter.requests, hasLength(1), reason: '$location');
    }
  });

  test('stops after five redirects', () async {
    final adapter = _ScriptedAdapter((options, requestNumber) {
      return ResponseBody.fromString(
        '',
        HttpStatus.found,
        headers: {
          'location': ['https://public.example/$requestNumber'],
        },
      );
    });
    final client = _requestWith(
      adapter,
      resolveHost: (_) async => [InternetAddress('93.184.216.34')],
    );

    await expectLater(
      client.getTextResponseForUrl('https://origin.example/profile'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(6));
  });
}
