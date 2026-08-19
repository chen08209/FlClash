import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _sessionId = '0123456789abcdef0123456789abcdef';
const _coreSha256 =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

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

  test('ping requires protocol 6 and the expected Helper path', () async {
    final adapter = _ResponseAdapter((options) {
      expect(options.queryParameters, {'coreSha256': _coreSha256});
      return ResponseBody.fromString(
        r'C:\Program Files\FlClash\FlClashHelperService.exe',
        200,
        headers: {
          helperProtocolVersionHeader: [helperProtocolVersion],
          Headers.contentTypeHeader: ['text/plain'],
        },
      );
    });
    final client = _client(
      adapter,
      expectedHelperPath: () =>
          r'C:\Program Files\FlClash\FlClashHelperService.exe',
    );

    expect(await client.readiness(), WindowsHelperReadiness.ready);
  });

  test('connection refusal reports a not-ready Helper', () async {
    final client = _client(
      _ResponseAdapter(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      ),
    );

    expect(await client.readiness(), WindowsHelperReadiness.notReady);
  });

  test('ping rejects a Helper with the wrong protocol', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => ResponseBody.fromString(
          r'C:\Helper.exe',
          HttpStatus.ok,
          headers: {
            helperProtocolVersionHeader: ['5'],
            Headers.contentTypeHeader: ['text/plain'],
          },
        ),
      ),
    );

    expect(await client.readiness(), WindowsHelperReadiness.notReady);
  });

  test('ping rejects a Helper at the wrong path', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => ResponseBody.fromString(
          r'C:\OtherHelper.exe',
          HttpStatus.ok,
          headers: {
            helperProtocolVersionHeader: [helperProtocolVersion],
            Headers.contentTypeHeader: ['text/plain'],
          },
        ),
      ),
    );

    expect(await client.readiness(), WindowsHelperReadiness.notReady);
  });

  test(
    'ping rejects a Helper built for another Core without hashing',
    () async {
      final client = _client(
        _ResponseAdapter(
          (_) => _jsonResponse({
            'code': 'coreSha256Mismatch',
            'message': 'Core SHA256 mismatch',
          }, statusCode: HttpStatus.conflict),
        ),
      );

      expect(await client.readiness(), WindowsHelperReadiness.notReady);
    },
  );

  test(
    'ping reports a not-ready Helper when the Core is inaccessible',
    () async {
      final client = _client(
        _ResponseAdapter(
          (_) => ResponseBody.fromString(
            'Core executable not found',
            HttpStatus.conflict,
            headers: {
              helperProtocolVersionHeader: [helperProtocolVersion],
              Headers.contentTypeHeader: ['text/plain'],
            },
          ),
        ),
      );

      expect(await client.readiness(), WindowsHelperReadiness.notReady);
    },
  );

  test(
    'ping reports notReady for a conflict with an unknown protocol',
    () async {
      final client = _client(
        _ResponseAdapter(
          (_) => ResponseBody.fromString(
            'unrecognized conflict body',
            HttpStatus.conflict,
            headers: {
              helperProtocolVersionHeader: ['5'],
              Headers.contentTypeHeader: ['text/plain'],
            },
          ),
        ),
      );

      expect(await client.readiness(), WindowsHelperReadiness.notReady);
    },
  );

  test('missing manifest never probes the Helper', () async {
    final adapter = _ResponseAdapter(
      (_) => throw StateError('ping should not be sent'),
    );
    final client = _client(adapter, readCoreSha256: () async => '');

    expect(await client.readiness(), WindowsHelperReadiness.manifestMissing);
    expect(adapter.requestCount, 0);
  });

  test('the bundled manifest SHA is read only once across probes', () async {
    var reads = 0;
    final client = _client(
      _ResponseAdapter(
        (_) => ResponseBody.fromString(
          r'C:\Helper.exe',
          HttpStatus.ok,
          headers: {
            helperProtocolVersionHeader: [helperProtocolVersion],
            Headers.contentTypeHeader: ['text/plain'],
          },
        ),
      ),
      readCoreSha256: () async {
        reads++;
        return _coreSha256;
      },
    );

    expect(await client.readiness(), WindowsHelperReadiness.ready);
    expect(await client.readiness(), WindowsHelperReadiness.ready);
    expect(reads, 1);
  });

  test('an unreadable manifest is retried on the next probe', () async {
    var reads = 0;
    final client = _client(
      _ResponseAdapter(
        (_) => ResponseBody.fromString(
          r'C:\Helper.exe',
          HttpStatus.ok,
          headers: {
            helperProtocolVersionHeader: [helperProtocolVersion],
            Headers.contentTypeHeader: ['text/plain'],
          },
        ),
      ),
      readCoreSha256: () async {
        reads++;
        return reads == 1 ? '' : _coreSha256;
      },
    );

    expect(await client.readiness(), WindowsHelperReadiness.manifestMissing);
    expect(await client.readiness(), WindowsHelperReadiness.ready);
    expect(reads, 2);
  });

  test('a throwing manifest read reports a missing manifest', () async {
    final adapter = _ResponseAdapter(
      (_) => throw StateError('ping should not be sent'),
    );
    final client = _client(
      adapter,
      readCoreSha256: () async => throw const FileSystemException('locked'),
    );

    expect(await client.readiness(), WindowsHelperReadiness.manifestMissing);
    expect(adapter.requestCount, 0);
  });

  test('an HTTP Helper response reports notReady', () async {
    final client = _client(
      _ResponseAdapter(
        (_) => ResponseBody.fromString('broken helper', HttpStatus.badGateway),
      ),
    );

    expect(await client.readiness(), WindowsHelperReadiness.notReady);
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
      var helperReadiness = WindowsHelperReadiness.ready;
      final resolver = WindowsHelperLauncherResolver(
        isWindows: true,
        directLauncher: direct,
        helperLauncher: helper,
        helperReady: () async => helperReadiness,
      );

      final resolved = await resolver.resolve();
      expect(resolved, isA<FallbackCoreLauncher>());
      final fallback = resolved as FallbackCoreLauncher;
      expect(fallback.primary, same(helper));
      expect(fallback.fallback, same(direct));
      helperReadiness = WindowsHelperReadiness.notReady;
      expect(await resolver.resolve(), same(direct));
      helperReadiness = WindowsHelperReadiness.manifestMissing;
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
        return WindowsHelperReadiness.ready;
      },
    );

    expect(await resolver.resolve(), same(direct));
    expect(readyCalls, 0);
  });

  group('FallbackCoreLauncher', () {
    test('returns the Helper lease when the Helper starts the Core', () async {
      final helper = FakeLauncher(
        owner: CoreProcessOwner.windowsHelper,
        pid: 2,
      );
      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 3);
      final launcher = FallbackCoreLauncher(primary: helper, fallback: direct);

      final lease = await launcher.start(
        sessionId: _sessionId,
        address: 'test-address',
      );

      expect(lease, same(helper.lease));
      expect(helper.startCount, 1);
      expect(direct.startCount, 0);
    });

    test(
      'falls back to the direct Core when the Helper cannot verify the Core',
      () async {
        final helper =
            FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 2)
              ..startError = const WindowsHelperException(
                code: 'coreVerificationFailed',
                message: 'Core executable SHA256 mismatch',
              );
        final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 3);
        final launcher = FallbackCoreLauncher(
          primary: helper,
          fallback: direct,
        );

        final lease = await launcher.start(
          sessionId: _sessionId,
          address: 'test-address',
        );

        expect(lease, same(direct.lease));
        expect(lease.owner, CoreProcessOwner.direct);
        expect(helper.startCount, 1);
        expect(direct.startCount, 1);
      },
    );

    test(
      'falls back to the direct Core when the Helper fails to spawn the Core',
      () async {
        final helper =
            FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 2)
              ..startError = const WindowsHelperException(
                code: 'processLaunchFailed',
                message: 'unable to spawn the Core',
              );
        final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 3);
        final launcher = FallbackCoreLauncher(
          primary: helper,
          fallback: direct,
        );

        final lease = await launcher.start(
          sessionId: _sessionId,
          address: 'test-address',
        );

        expect(lease, same(direct.lease));
        expect(lease.owner, CoreProcessOwner.direct);
        expect(helper.startCount, 1);
        expect(direct.startCount, 1);
      },
    );

    test('does not fall back for ambiguous Helper start failures', () async {
      final helper = FakeLauncher(owner: CoreProcessOwner.windowsHelper, pid: 2)
        ..startError = const WindowsHelperException(
          code: 'transportError',
          message: 'Helper start request failed',
        );
      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 3);
      final launcher = FallbackCoreLauncher(primary: helper, fallback: direct);

      await expectLater(
        launcher.start(sessionId: _sessionId, address: 'test-address'),
        throwsA(isA<WindowsHelperException>()),
      );
      expect(helper.startCount, 1);
      expect(direct.startCount, 0);
    });
  });
}

WindowsHelperClient _client(
  _ResponseAdapter adapter, {
  String Function()? expectedHelperPath,
  Future<String> Function()? readCoreSha256,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return WindowsHelperClient(
    dio: dio,
    expectedHelperPath: expectedHelperPath ?? () => r'C:\Helper.exe',
    readCoreSha256: readCoreSha256 ?? () async => _coreSha256,
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
