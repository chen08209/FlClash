import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:path/path.dart' as p;

import 'launcher.dart';
import 'model.dart';

final class HelperStartResponse {
  final String sessionId;
  final int pid;

  const HelperStartResponse({required this.sessionId, required this.pid});
}

final class HelperStopResponse {
  final String sessionId;
  final bool stopped;
  final String? reason;

  const HelperStopResponse({
    required this.sessionId,
    required this.stopped,
    this.reason,
  });
}

final class WindowsHelperException implements Exception {
  final String code;
  final String message;
  final Object? details;

  const WindowsHelperException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'WindowsHelperException($code, $message, $details)';
}

final class WindowsHelperClient {
  final Dio _dio;
  final String Function() _expectedHelperPath;
  final String baseUrl;

  WindowsHelperClient({
    Dio? dio,
    String Function()? expectedHelperPath,
    this.baseUrl = 'http://$localhost:$helperPort',
  }) : _dio = dio ?? Dio(),
       _expectedHelperPath = expectedHelperPath ?? _defaultHelperPath;

  static String _defaultHelperPath() {
    final context = p.Context(style: p.Style.windows);
    return context.join(
      context.dirname(Platform.resolvedExecutable),
      '$appHelperService.exe',
    );
  }

  Future<bool> isReady({Duration? timeout, bool logFailure = true}) async {
    if (timeout != null && timeout <= Duration.zero) {
      return false;
    }
    final cancelToken = CancelToken();
    final timeoutTimer = timeout == null
        ? null
        : Timer(
            timeout,
            () => cancelToken.cancel('helper ping deadline exceeded'),
          );
    try {
      final response = await _dio.get<Object?>(
        '$baseUrl/ping',
        cancelToken: cancelToken,
        options: _options(ResponseType.plain),
      );
      final helperPath = response.data;
      if (response.statusCode != HttpStatus.ok || helperPath is! String) {
        _logPingFailure('helper ping returned invalid response', logFailure);
        return false;
      }
      final protocolVersion = response.headers.value(
        helperProtocolVersionHeader,
      );
      if (protocolVersion != helperProtocolVersion) {
        _logPingFailure(
          'helper protocol mismatch: $protocolVersion',
          logFailure,
        );
        return false;
      }
      final matches = p.Context(
        style: p.Style.windows,
      ).equals(helperPath.trim(), _expectedHelperPath());
      if (!matches) {
        _logPingFailure('helper executable path mismatch', logFailure);
      }
      return matches;
    } catch (error) {
      _logPingFailure('helper ping failed: $error', logFailure);
      return false;
    } finally {
      timeoutTimer?.cancel();
    }
  }

  void _logPingFailure(String message, bool enabled) {
    if (enabled) {
      commonPrint.log(message, logLevel: LogLevel.warning);
    }
  }

  Future<HelperStartResponse> start({
    required String address,
    required String sessionId,
  }) async {
    _validateSessionId(sessionId);
    try {
      final response = await _dio.post<Object?>(
        '$baseUrl/start',
        data: {'address': address, 'sessionId': sessionId},
        options: _options(ResponseType.json),
      );
      final data = _responseMap(response, operation: 'start');
      final returnedSession = data['sessionId'];
      final pid = data['pid'];
      if (returnedSession != sessionId || pid is! int || pid <= 0) {
        throw const WindowsHelperException(
          code: 'invalidResponse',
          message: 'Helper returned an invalid start response',
        );
      }
      return HelperStartResponse(
        sessionId: returnedSession as String,
        pid: pid,
      );
    } on WindowsHelperException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error, operation: 'start');
    } catch (error) {
      throw WindowsHelperException(
        code: 'transportError',
        message: 'Unable to start Core through Helper',
        details: error.toString(),
      );
    }
  }

  Future<HelperStopResponse> stop(String sessionId) async {
    _validateSessionId(sessionId);
    try {
      final response = await _dio.post<Object?>(
        '$baseUrl/stop',
        data: {'sessionId': sessionId},
        options: _options(ResponseType.json),
      );
      return _parseStopResponse(response, sessionId);
    } on WindowsHelperException {
      rethrow;
    } on DioException catch (error) {
      final response = error.response;
      if (response?.statusCode == HttpStatus.conflict) {
        final data = _mapFrom(response?.data);
        final reason = data?['reason'];
        if (reason is String) {
          throw WindowsHelperException(
            code: reason,
            message: 'Helper refused to stop the requested Core session',
            details: data,
          );
        }
      }
      throw _mapDioException(error, operation: 'stop');
    } catch (error) {
      throw WindowsHelperException(
        code: 'transportError',
        message: 'Unable to stop Core through Helper',
        details: error.toString(),
      );
    }
  }

  HelperStopResponse _parseStopResponse(
    Response<Object?> response,
    String sessionId,
  ) {
    final data = _responseMap(response, operation: 'stop');
    final returnedSession = data['sessionId'];
    final stopped = data['stopped'];
    final reason = data['reason'];
    if (returnedSession != sessionId ||
        stopped is! bool ||
        (stopped && reason != null) ||
        (!stopped && reason != 'notRunning')) {
      throw const WindowsHelperException(
        code: 'invalidResponse',
        message: 'Helper returned an invalid stop response',
      );
    }
    return HelperStopResponse(
      sessionId: returnedSession as String,
      stopped: stopped,
      reason: reason as String?,
    );
  }

  Map<String, Object?> _responseMap(
    Response<Object?> response, {
    required String operation,
  }) {
    if (response.statusCode != HttpStatus.ok) {
      throw WindowsHelperException(
        code: 'unexpectedStatus',
        message: 'Helper $operation returned HTTP ${response.statusCode}',
        details: response.data,
      );
    }
    final data = _mapFrom(response.data);
    if (data == null) {
      throw WindowsHelperException(
        code: 'invalidResponse',
        message: 'Helper returned an invalid $operation response',
        details: response.data,
      );
    }
    return data;
  }

  WindowsHelperException _mapDioException(
    DioException error, {
    required String operation,
  }) {
    final data = _mapFrom(error.response?.data);
    final code = data?['code'];
    final message = data?['message'];
    if (code is String && message is String) {
      return WindowsHelperException(
        code: code,
        message: message,
        details: data?['details'],
      );
    }
    return WindowsHelperException(
      code: 'transportError',
      message: 'Helper $operation request failed',
      details: error.toString(),
    );
  }

  Map<String, Object?>? _mapFrom(Object? data) {
    if (data is! Map) {
      return null;
    }
    return Map<String, Object?>.from(data);
  }

  void _validateSessionId(String sessionId) {
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(sessionId)) {
      throw const WindowsHelperException(
        code: 'invalidSessionId',
        message: 'Core session ID must be 128-bit lowercase hexadecimal',
      );
    }
  }

  Options _options(ResponseType responseType) {
    return Options(
      responseType: responseType,
      connectTimeout: const Duration(milliseconds: 300),
      receiveTimeout: const Duration(seconds: 2),
    );
  }
}

final class WindowsHelperLauncher implements CoreProcessLauncher {
  final WindowsHelperClient client;

  const WindowsHelperLauncher(this.client);

  @override
  CoreProcessOwner get owner => CoreProcessOwner.windowsHelper;

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    try {
      final response = await client.start(
        address: address,
        sessionId: sessionId,
      );
      return HelperCoreLease(
        sessionId: response.sessionId,
        pid: response.pid,
        client: client,
      );
    } catch (error, stackTrace) {
      try {
        await client.stop(sessionId);
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

typedef HelperReadinessProbe = Future<bool> Function();

final class WindowsHelperLauncherResolver
    implements DesktopCoreLauncherResolver {
  final bool isWindows;
  final CoreProcessLauncher directLauncher;
  final CoreProcessLauncher helperLauncher;
  final HelperReadinessProbe helperReady;

  const WindowsHelperLauncherResolver({
    required this.isWindows,
    required this.directLauncher,
    required this.helperLauncher,
    required this.helperReady,
  });

  @override
  Future<CoreProcessLauncher> resolve() async {
    if (isWindows && await helperReady()) {
      return helperLauncher;
    }
    return directLauncher;
  }
}

final class HelperCoreLease implements CoreProcessLease {
  @override
  final String sessionId;

  @override
  final int pid;

  final WindowsHelperClient _client;
  Future<CoreProcessStopResult>? _stopOperation;

  HelperCoreLease({
    required this.sessionId,
    required this.pid,
    required WindowsHelperClient client,
  }) : _client = client;

  @override
  CoreProcessOwner get owner => CoreProcessOwner.windowsHelper;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) {
    final stopOperation = _stopOperation;
    if (stopOperation != null) {
      return stopOperation;
    }
    final nextOperation = _stop().onError((
      Object error,
      StackTrace stackTrace,
    ) {
      _stopOperation = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
    _stopOperation = nextOperation;
    return nextOperation;
  }

  Future<CoreProcessStopResult> _stop() async {
    final response = await _client.stop(sessionId);
    return CoreProcessStopResult(
      stopped: response.stopped,
      exitConfirmed: true,
    );
  }
}

final windowsHelperClient = WindowsHelperClient();
