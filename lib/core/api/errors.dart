import 'dart:async';

import 'package:fl_clash/enum/enum.dart';

/// [code] is the protocol's error kind, narrowed to a rejection's `reason`
/// when it names one.
class CoreMethodException implements Exception {
  final String code;
  final String message;
  final Object? details;

  const CoreMethodException({
    required this.code,
    required this.message,
    this.details,
  });

  factory CoreMethodException.fromError(Map<String, Object?> error) {
    final data = error['data'];
    final fields = data is Map ? Map<String, Object?>.from(data) : null;
    final kind = fields?['kind'] as String? ?? 'internal';
    final reason = fields?['reason'];
    return CoreMethodException(
      code: reason is String && reason.isNotEmpty ? reason : kind,
      message: error['message'] as String? ?? '',
      details: fields,
    );
  }

  bool get isCoreUnavailable => const {
    'transport_disconnected',
    'transport_error',
    'core_unavailable',
  }.contains(code);

  String get kind => switch (details) {
    {'kind': final String kind} => kind,
    _ => code,
  };

  @override
  String toString() => 'CoreMethodException($code, $message, $details)';
}

/// A Core that never answered, as opposed to one that answered with an error.
bool isUnansweredCoreError(Object? error) => switch (error) {
  TimeoutException() => true,
  CoreMethodException(:final isCoreUnavailable) => isCoreUnavailable,
  _ => false,
};

LogLevel coreFailureLogLevel(Object? error) {
  if (error is TimeoutException) {
    return LogLevel.debug;
  }
  if (error is! CoreMethodException) {
    return LogLevel.warning;
  }
  return error.isCoreUnavailable || error.code == 'cancelled'
      ? LogLevel.debug
      : LogLevel.warning;
}
