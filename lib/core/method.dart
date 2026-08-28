import 'dart:async';

import 'package:fl_clash/enum/enum.dart';

enum CoreMethod {
  message,
  initClash,
  getIsInit,
  forceGc,
  shutdown,
  validateConfig,
  updateConfig,
  getConfig,
  getProxies,
  changeProxy,
  getTraffic,
  getTotalTraffic,
  getTrafficSnapshot,
  resetTraffic,
  asyncTestDelay,
  getConnections,
  closeConnections,
  resetConnections,
  closeConnection,
  getExternalProviders,
  getExternalProvider,
  updateGeoData,
  updateExternalProvider,
  sideLoadExternalProvider,
  startLog,
  stopLog,
  startListener,
  stopListener,
  getMemory,
  crash,
  setupConfig,
  clearEffect,
  updateDns,
}

class CoreMethodCall {
  final String? id;
  final CoreMethod method;
  final Object? arguments;

  const CoreMethodCall({this.id, required this.method, this.arguments});

  factory CoreMethodCall.fromJson(Map<String, Object?> json) {
    return CoreMethodCall(
      id: json['id'] as String?,
      method: CoreMethod.values.byName(json['method'] as String),
      arguments: json['arguments'],
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'method': method.name,
      'arguments': arguments,
    };
  }
}

class CoreMethodError {
  final String code;
  final String message;
  final Object? details;

  const CoreMethodError({
    required this.code,
    required this.message,
    this.details,
  });

  factory CoreMethodError.fromJson(Map<String, Object?> json) {
    return CoreMethodError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'],
    );
  }

  Map<String, Object?> toJson() {
    return {'code': code, 'message': message, 'details': details};
  }
}

class CoreMethodResponse {
  final String? id;
  final Object? result;
  final CoreMethodError? error;

  const CoreMethodResponse({this.id, this.result, this.error});

  factory CoreMethodResponse.fromJson(Map<String, Object?> json) {
    final error = json['error'];
    return CoreMethodResponse(
      id: json['id'] as String?,
      result: json['result'],
      error: error is Map
          ? CoreMethodError.fromJson(Map<String, Object?>.from(error))
          : null,
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'result': result,
      if (error != null) 'error': error!.toJson(),
    };
  }

  T? unwrap<T>() {
    final error = this.error;
    if (error != null) {
      throw CoreMethodException(
        code: error.code,
        message: error.message,
        details: error.details,
      );
    }
    return result as T?;
  }
}

class CoreMethodException implements Exception {
  final String code;
  final String message;
  final Object? details;

  const CoreMethodException({
    required this.code,
    required this.message,
    this.details,
  });

  bool get isCoreUnavailable =>
      const {'transport_disconnected', 'transport_error'}.contains(code);

  @override
  String toString() => 'CoreMethodException($code, $message, $details)';
}

LogLevel coreFailureLogLevel(Object? error) {
  if (error is TimeoutException) {
    return LogLevel.debug;
  }
  if (error is! CoreMethodException) {
    return LogLevel.warning;
  }
  return error.isCoreUnavailable ? LogLevel.debug : LogLevel.warning;
}
