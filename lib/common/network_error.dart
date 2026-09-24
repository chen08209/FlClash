import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/webdav.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/l10n/l10n.dart';

enum _Kind {
  timeout,
  hostLookup,
  connection,
  tls,
  httpStatus,
  cancelled,
  unknown,
}

final class _Failure {
  final _Kind kind;
  final int? statusCode;
  final String? detail;

  const _Failure(this.kind, {this.detail}) : statusCode = null;

  const _Failure.httpStatus(int this.statusCode)
    : kind = _Kind.httpStatus,
      detail = null;
}

String? networkErrorMessage(Object error, AppLocalizations appLocalizations) {
  final failure = _failureOf(error);
  return failure == null ? null : _messageOf(failure, appLocalizations);
}

/// Bare socket and timeout exceptions are left alone: outside an HTTP request
/// they come from the local Core or Helper channel, where "check your network"
/// would send the user the wrong way.
_Failure? _failureOf(Object error) {
  return switch (error) {
    DioException() => _fromDio(error),
    DAVException(:final statusCode?) => _Failure.httpStatus(statusCode),
    DAVException() => const _Failure(_Kind.connection),
    CoreMethodException() => _fromCore(error),
    _ => null,
  };
}

_Failure _fromDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout:
      return const _Failure(_Kind.timeout);
    case DioExceptionType.badCertificate:
      return const _Failure(_Kind.tls);
    case DioExceptionType.cancel:
      return const _Failure(_Kind.cancelled);
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      return statusCode != null
          ? _Failure.httpStatus(statusCode)
          : const _Failure(_Kind.unknown);
    case DioExceptionType.connectionError || DioExceptionType.unknown:
      return _fromTransport(error.error) ??
          _Failure(
            error.type == DioExceptionType.connectionError
                ? _Kind.connection
                : _Kind.unknown,
            detail: _detailOf(error),
          );
  }
}

_Failure? _fromTransport(Object? cause) {
  return switch (cause) {
    TlsException() => const _Failure(_Kind.tls),
    TimeoutException() => const _Failure(_Kind.timeout),
    SocketException(:final message)
        when message.startsWith('Failed host lookup') =>
      const _Failure(_Kind.hostLookup),
    SocketException() || HttpException() => const _Failure(_Kind.connection),
    _ => null,
  };
}

String? _detailOf(DioException error) {
  final message = error.message?.trim();
  if (message != null && message.isNotEmpty) {
    return message;
  }
  return error.error?.toString();
}

_Failure? _fromCore(CoreMethodException error) {
  final details = error.details;
  final reason = details is Map ? details['reason'] : null;
  final statusCode = switch (details) {
    {'statusCode': final int code} => code,
    _ => int.tryParse(error.message.split(' ').first),
  };
  return switch (error.code) {
    'request_bad_response' when statusCode != null => _Failure.httpStatus(
      statusCode,
    ),
    'request_bad_response' || 'request_error' => _Failure(switch (reason) {
      'timeout' => _Kind.timeout,
      'dns' => _Kind.hostLookup,
      'tls' => _Kind.tls,
      'connection' => _Kind.connection,
      _ => _Kind.unknown,
    }, detail: error.message),
    _ => null,
  };
}

String _messageOf(_Failure failure, AppLocalizations appLocalizations) {
  return switch (failure.kind) {
    _Kind.timeout => appLocalizations.networkTimeoutError,
    _Kind.hostLookup => appLocalizations.networkHostLookupError,
    _Kind.connection => appLocalizations.networkConnectionError,
    _Kind.tls => appLocalizations.networkTlsError,
    _Kind.cancelled => appLocalizations.networkCancelledError,
    _Kind.httpStatus => _httpStatusMessage(
      failure.statusCode ?? 0,
      appLocalizations,
    ),
    _Kind.unknown => switch (failure.detail) {
      final detail? when detail.isNotEmpty =>
        appLocalizations.networkRequestFailed(detail),
      _ => appLocalizations.unknownNetworkError,
    },
  };
}

String _httpStatusMessage(int statusCode, AppLocalizations appLocalizations) {
  return switch (statusCode) {
    401 || 403 || 407 => appLocalizations.networkAccessDeniedError(statusCode),
    404 || 410 => appLocalizations.networkNotFoundError(statusCode),
    429 => appLocalizations.networkRateLimitedError,
    >= 500 && <= 599 => appLocalizations.networkServerError(statusCode),
    _ => appLocalizations.networkBadResponseError(statusCode),
  };
}
