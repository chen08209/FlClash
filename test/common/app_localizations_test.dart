import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/network_error.dart';
import 'package:fl_clash/common/webdav.dart';
import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/core/desktop/launch_policy.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations appLocalizations;

  setUpAll(() async {
    appLocalizations = await AppLocalizations.load(const Locale('en'));
  });

  DioException dioError(
    DioExceptionType type, {
    int? statusCode,
    Object? cause,
  }) {
    final options = RequestOptions(path: '/');
    return DioException(
      requestOptions: options,
      type: type,
      error: cause,
      response: statusCode == null
          ? null
          : Response<void>(requestOptions: options, statusCode: statusCode),
    );
  }

  group('Dio failures name their cause', () {
    final cases = <String, (DioException, String Function(AppLocalizations))>{
      'timeout': (
        dioError(DioExceptionType.receiveTimeout),
        (l) => l.networkTimeoutError,
      ),
      'host lookup': (
        dioError(
          DioExceptionType.connectionError,
          cause: const SocketException("Failed host lookup: 'sub.example'"),
        ),
        (l) => l.networkHostLookupError,
      ),
      'refused connection': (
        dioError(
          DioExceptionType.connectionError,
          cause: const SocketException('Connection refused'),
        ),
        (l) => l.networkConnectionError,
      ),
      'TLS handshake': (
        dioError(
          DioExceptionType.unknown,
          cause: const HandshakeException('CERTIFICATE_VERIFY_FAILED'),
        ),
        (l) => l.networkTlsError,
      ),
      'bad certificate': (
        dioError(DioExceptionType.badCertificate),
        (l) => l.networkTlsError,
      ),
      'HTTP 403': (
        dioError(DioExceptionType.badResponse, statusCode: 403),
        (l) => l.networkAccessDeniedError(403),
      ),
      'HTTP 404': (
        dioError(DioExceptionType.badResponse, statusCode: 404),
        (l) => l.networkNotFoundError(404),
      ),
      'HTTP 429': (
        dioError(DioExceptionType.badResponse, statusCode: 429),
        (l) => l.networkRateLimitedError,
      ),
      'HTTP 502': (
        dioError(DioExceptionType.badResponse, statusCode: 502),
        (l) => l.networkServerError(502),
      ),
      'HTTP 400': (
        dioError(DioExceptionType.badResponse, statusCode: 400),
        (l) => l.networkBadResponseError(400),
      ),
    };
    for (final MapEntry(key: name, value: (error, expected)) in cases.entries) {
      test(name, () {
        expect(
          networkErrorMessage(error, appLocalizations),
          expected(appLocalizations),
        );
      });
    }
  });

  test('keeps the detail of an unclassified Dio failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/'),
      error: const FormatException('bad body'),
      message: 'bad body',
    );
    expect(
      networkErrorMessage(error, appLocalizations),
      appLocalizations.networkRequestFailed('bad body'),
    );
  });

  test('leaves bare socket and timeout errors to the caller', () {
    expect(
      networkErrorMessage(const SocketException('refused'), appLocalizations),
      isNull,
    );
    expect(
      networkErrorMessage(TimeoutException('core'), appLocalizations),
      isNull,
    );
    expect(networkErrorMessage(StateError('boom'), appLocalizations), isNull);
  });

  test('maps WebDAV status failures like any HTTP response', () {
    expect(
      networkErrorMessage(
        const DAVException(method: 'PUT', path: '/a', statusCode: 401),
        appLocalizations,
      ),
      appLocalizations.networkAccessDeniedError(401),
    );
  });

  test('maps Core request failures by their reason and status', () {
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_bad_response',
          message: '403 Forbidden',
          details: {'providerName': 'sub', 'statusCode': 403},
        ),
        appLocalizations,
      ),
      appLocalizations.networkAccessDeniedError(403),
    );
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_bad_response',
          message: '503 Service Unavailable',
        ),
        appLocalizations,
      ),
      appLocalizations.networkServerError(503),
    );
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_error',
          message: 'context deadline exceeded',
          details: {'reason': 'timeout'},
        ),
        appLocalizations,
      ),
      appLocalizations.networkTimeoutError,
    );
    expect(
      networkErrorMessage(
        const CoreMethodException(code: 'request_error', message: 'odd'),
        appLocalizations,
      ),
      appLocalizations.networkRequestFailed('odd'),
    );
  });

  test('uses the Core message for non-request failures', () {
    expect(
      userFacingErrorMessage(
        const CoreMethodException(
          code: 'provider_update_error',
          message: 'proxy 0: unsupported type',
        ),
        appLocalizations,
      ),
      'proxy 0: unsupported type',
    );
  });

  group('policy-blocked Core launch', () {
    const blocked = DesktopCoreFailure(
      code: 'start_failed',
      phase: DesktopCorePhase.starting,
      revision: 1,
      cause: HelperException(
        code: 'processLaunchFailed',
        message: 'spawn failed',
        details: {'osError': 577},
      ),
    );

    tearDown(() {
      smartAppControlStateReader = readSmartAppControlState;
    });

    test('names Smart App Control when it is on', () {
      smartAppControlStateReader = () => SmartAppControlState.on;

      expect(
        userFacingErrorMessage(blocked, appLocalizations),
        appLocalizations.coreBlockedBySmartAppControlTip,
      );
    });

    test('names the generic policy with its error code otherwise', () {
      smartAppControlStateReader = () => SmartAppControlState.off;

      expect(
        userFacingErrorMessage(blocked, appLocalizations),
        appLocalizations.coreBlockedByPolicyTip(577),
      );
    });

    test('leaves other start failures on the raw description', () {
      smartAppControlStateReader = () => SmartAppControlState.on;
      const timedOut = DesktopCoreFailure(
        code: 'start_failed',
        phase: DesktopCorePhase.starting,
        revision: 1,
        cause: HelperException(
          code: 'transportError',
          message: 'Helper start request failed',
        ),
      );

      expect(
        userFacingErrorMessage(timedOut, appLocalizations),
        timedOut.toString(),
      );
    });
  });
}
