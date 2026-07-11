import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _sessionId = '0123456789abcdef0123456789abcdef';

void main() {
  test(
    'start returns a Helper lease identity with matching session and PID',
    () async {
      final adapter = _ResponseAdapter((options) {
        expect(options.path, endsWith('/start'));
        expect(options.data, {
          'address': r'\\.\pipe\FlClashCore_abc',
          'sessionId': _sessionId,
        });
        return _jsonResponse({'sessionId': _sessionId, 'pid': 6456});
      });
      final client = _client(adapter);

      final response = await client.start(
        address: r'\\.\pipe\FlClashCore_abc',
        sessionId: _sessionId,
      );

      expect(response.pid, 6456);
      expect(response.sessionId, _sessionId);
    },
  );

  test('start rejects a response for another session', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => _jsonResponse({
          'sessionId': 'fedcba9876543210fedcba9876543210',
          'pid': 6456,
        }),
      ),
    );

    await expectLater(
      client.start(address: 'test-address', sessionId: _sessionId),
      throwsA(
        isA<WindowsHelperException>().having(
          (error) => error.code,
          'code',
          'invalidResponse',
        ),
      ),
    );
  });

  test('matching stop parses a confirmed response', () async {
    final adapter = _ResponseAdapter((options) {
      expect(options.path, endsWith('/stop'));
      expect(options.data, {'sessionId': _sessionId});
      return _jsonResponse({'sessionId': _sessionId, 'stopped': true});
    });
    final client = _client(adapter);

    final response = await client.stop(_sessionId);

    expect(response.sessionId, _sessionId);
    expect(response.stopped, isTrue);
    expect(response.reason, isNull);
  });

  test('stop rejects an unknown unconfirmed reason', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => _jsonResponse({
          'sessionId': _sessionId,
          'stopped': false,
          'reason': 'unknown',
        }),
      ),
    );

    await expectLater(
      client.stop(_sessionId),
      throwsA(
        isA<WindowsHelperException>().having(
          (error) => error.code,
          'code',
          'invalidResponse',
        ),
      ),
    );
  });

  test('session mismatch is typed and never reported as stopped', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => _jsonResponse({
          'sessionId': _sessionId,
          'stopped': false,
          'reason': 'sessionMismatch',
        }, statusCode: 409),
      ),
    );

    await expectLater(
      client.stop(_sessionId),
      throwsA(
        isA<WindowsHelperException>().having(
          (error) => error.code,
          'code',
          'sessionMismatch',
        ),
      ),
    );
  });

  test('Helper lease stops only its immutable session', () async {
    final requestedSessions = <Object?>[];
    final client = _client(
      _ResponseAdapter((options) {
        if (options.path.endsWith('/start')) {
          return _jsonResponse({'sessionId': _sessionId, 'pid': 6456});
        }
        requestedSessions.add(options.data);
        return _jsonResponse({
          'sessionId': _sessionId,
          'stopped': false,
          'reason': 'notRunning',
        });
      }),
    );
    final launcher = WindowsHelperLauncher(client);
    final lease = await launcher.start(
      sessionId: _sessionId,
      address: 'test-address',
    );

    final result = await lease.stop(const Duration(seconds: 1));

    expect(lease.owner, CoreProcessOwner.windowsHelper);
    expect(lease.pid, 6456);
    expect(requestedSessions, [
      {'sessionId': _sessionId},
    ]);
    expect(result.stopped, isFalse);
    expect(result.exitConfirmed, isTrue);
  });

  test('Helper lease retries stop after a transport failure', () async {
    var stopRequests = 0;
    final client = _client(
      _ResponseAdapter((options) {
        if (options.path.endsWith('/start')) {
          return _jsonResponse({'sessionId': _sessionId, 'pid': 6456});
        }
        stopRequests++;
        if (stopRequests == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return _jsonResponse({
          'sessionId': _sessionId,
          'stopped': false,
          'reason': 'notRunning',
        });
      }),
    );
    final launcher = WindowsHelperLauncher(client);
    final lease = await launcher.start(
      sessionId: _sessionId,
      address: 'test-address',
    );

    await expectLater(
      lease.stop(const Duration(seconds: 1)),
      throwsA(
        isA<WindowsHelperException>().having(
          (error) => error.code,
          'code',
          'transportError',
        ),
      ),
    );
    final result = await lease.stop(const Duration(seconds: 1));

    expect(stopRequests, 2);
    expect(result.stopped, isFalse);
    expect(result.exitConfirmed, isTrue);
  });

  test(
    'Helper launcher compensates an uncertain start with exact stop',
    () async {
      final requests = <RequestOptions>[];
      final client = _client(
        _ResponseAdapter((options) {
          requests.add(options);
          if (options.path.endsWith('/start')) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            );
          }
          return _jsonResponse({
            'sessionId': _sessionId,
            'stopped': false,
            'reason': 'notRunning',
          });
        }),
      );
      final launcher = WindowsHelperLauncher(client);

      await expectLater(
        launcher.start(sessionId: _sessionId, address: 'test-address'),
        throwsA(isA<WindowsHelperException>()),
      );

      expect(requests.map((request) => request.path), [
        endsWith('/start'),
        endsWith('/stop'),
      ]);
      expect(requests.last.data, {'sessionId': _sessionId});
    },
  );

  test('ping requires protocol 5 and the expected Helper path', () async {
    final adapter = _ResponseAdapter(
      (_) => ResponseBody.fromString(
        r'C:\Program Files\FlClash\FlClashHelperService.exe',
        200,
        headers: {
          helperProtocolVersionHeader: [helperProtocolVersion],
          Headers.contentTypeHeader: ['text/plain'],
        },
      ),
    );
    final client = _client(
      adapter,
      expectedHelperPath: () =>
          r'C:\Program Files\FlClash\FlClashHelperService.exe',
    );

    expect(await client.isReady(), isTrue);
  });

  test('invalid session IDs are rejected before the request', () async {
    final adapter = _ResponseAdapter(
      (_) => _jsonResponse({'sessionId': _sessionId, 'pid': 1}),
    );
    final client = _client(adapter);

    await expectLater(
      client.start(address: 'test-address', sessionId: 'ABCDEF'),
      throwsA(isA<WindowsHelperException>()),
    );
    expect(adapter.requestCount, 0);
  });

  test(
    'Windows launcher resolver uses Helper only while it is ready',
    () async {
      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 1);
      final helper = FakeLauncher(
        owner: CoreProcessOwner.windowsHelper,
        pid: 2,
      );
      var helperReady = true;
      final resolver = WindowsHelperLauncherResolver(
        isWindows: true,
        directLauncher: direct,
        helperLauncher: helper,
        helperReady: () async => helperReady,
      );

      expect(await resolver.resolve(), same(helper));
      helperReady = false;
      expect(await resolver.resolve(), same(direct));
    },
  );

  test('non-Windows launcher resolver never probes Helper', () async {
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 1);
    final helper = FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 2);
    var readyCalls = 0;
    final resolver = WindowsHelperLauncherResolver(
      isWindows: false,
      directLauncher: direct,
      helperLauncher: helper,
      helperReady: () async {
        readyCalls++;
        return true;
      },
    );

    expect(await resolver.resolve(), same(direct));
    expect(readyCalls, 0);
  });
}

WindowsHelperClient _client(
  _ResponseAdapter adapter, {
  String Function()? expectedHelperPath,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return WindowsHelperClient(
    dio: dio,
    expectedHelperPath: expectedHelperPath ?? () => r'C:\Helper.exe',
  );
}

ResponseBody _jsonResponse(Map<String, Object?> body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

final class _ResponseAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) response;
  int requestCount = 0;

  _ResponseAdapter(this.response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return response(options);
  }

  @override
  void close({bool force = false}) {}
}
