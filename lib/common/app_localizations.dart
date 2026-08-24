import 'package:dio/dio.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/l10n/l10n.dart';

import 'dart:ui';

final currentAppLocalizations = AppLocalizations.current;

String? networkErrorMessage(Object error, AppLocalizations appLocalizations) {
  if (error case CoreMethodException(:final code)) {
    return switch (code) {
      'request_bad_response' => appLocalizations.networkException,
      'request_error' => appLocalizations.unknownNetworkError,
      _ => null,
    };
  }
  if (error is DioException) {
    return error.type == DioExceptionType.badResponse
        ? appLocalizations.networkException
        : appLocalizations.unknownNetworkError;
  }
  return null;
}

String userFacingErrorMessage(Object error, AppLocalizations appLocalizations) {
  return networkErrorMessage(error, appLocalizations) ??
      switch (error) {
        CoreMethodException(:final message) => message,
        _ => error.toString(),
      };
}

Locale? getLocaleForString(String? localString) {
  if (localString == null) return null;
  final localSplit = localString.split('_');
  if (localSplit.length == 1) {
    return Locale(localSplit[0]);
  }
  if (localSplit.length == 2) {
    return Locale(localSplit[0], localSplit[1]);
  }
  if (localSplit.length == 3) {
    return Locale.fromSubtags(
      languageCode: localSplit[0],
      scriptCode: localSplit[1],
      countryCode: localSplit[2],
    );
  }
  return null;
}
