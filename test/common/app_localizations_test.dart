import 'package:dio/dio.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations appLocalizations;

  setUpAll(() async {
    appLocalizations = await AppLocalizations.load(const Locale('en'));
  });

  test('maps badResponse DioException to the network exception message', () {
    final message = networkErrorMessage(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
      ),
      appLocalizations,
    );
    expect(message, appLocalizations.networkException);
  });

  test(
    'maps other DioException types to the unknown network error message',
    () {
      final message = networkErrorMessage(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
        appLocalizations,
      );
      expect(message, appLocalizations.unknownNetworkError);
    },
  );

  test('returns null for non-Dio exceptions', () {
    expect(networkErrorMessage(StateError('boom'), appLocalizations), isNull);
  });

  test('maps Core request failures using the same network categories', () {
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_bad_response',
          message: '503 Service Unavailable',
        ),
        appLocalizations,
      ),
      appLocalizations.networkException,
    );
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_error',
          message: 'request timed out',
        ),
        appLocalizations,
      ),
      appLocalizations.unknownNetworkError,
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
}
