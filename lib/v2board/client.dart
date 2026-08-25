import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';

import 'models.dart';

const defaultV2BoardOssConfigUrl = String.fromEnvironment('OSS_CONFIG_URL');

abstract interface class V2BoardTransport {
  Future<Object?> get(String url, {Map<String, Object?>? headers});

  Future<Object?> post(
    String url, {
    required Map<String, Object?> data,
    Map<String, Object?>? headers,
  });
}

class DioV2BoardTransport implements V2BoardTransport {
  final Dio _dio;

  DioV2BoardTransport({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: httpTimeoutDuration,
              receiveTimeout: httpTimeoutDuration,
              sendTimeout: httpTimeoutDuration,
              headers: {'User-Agent': browserUa},
            ),
          );

  @override
  Future<Object?> get(String url, {Map<String, Object?>? headers}) async {
    final response = await _dio.get<Object>(
      url,
      options: Options(headers: headers),
    );
    return response.data;
  }

  @override
  Future<Object?> post(
    String url, {
    required Map<String, Object?> data,
    Map<String, Object?>? headers,
  }) async {
    final response = await _dio.post<Object>(
      url,
      data: data,
      options: Options(headers: headers),
    );
    return response.data;
  }
}

abstract interface class V2BoardAuthenticator {
  Future<V2BoardSession> login({
    required String email,
    required String password,
  });

  Future<V2BoardSession> restore(String authData);
}

class V2BoardClient implements V2BoardAuthenticator {
  final V2BoardTransport _transport;
  final String ossConfigUrl;

  V2BoardClient({
    V2BoardTransport? transport,
    this.ossConfigUrl = defaultV2BoardOssConfigUrl,
  }) : _transport = transport ?? DioV2BoardTransport();

  Future<V2BoardRemoteConfig> fetchRemoteConfig() async {
    final url = ossConfigUrl.trim();
    if (!_isHttpUrl(url)) {
      throw const V2BoardException(
        'OSS_CONFIG_URL is not configured',
        kind: V2BoardExceptionKind.configuration,
      );
    }
    try {
      return V2BoardRemoteConfig.decode(await _transport.get(url));
    } on V2BoardException {
      rethrow;
    } on Object catch (error) {
      throw V2BoardException(
        _errorMessage(error),
        kind: V2BoardExceptionKind.configuration,
      );
    }
  }

  @override
  Future<V2BoardSession> login({
    required String email,
    required String password,
  }) async {
    final config = await fetchRemoteConfig();
    V2BoardException? lastError;
    for (final domain in config.domains) {
      try {
        final response = _asMap(
          await _transport.post(
            _endpoint(domain, '/passport/auth/login'),
            data: {'email': email.trim(), 'password': password},
          ),
        );
        _ensureSuccess(response);
        final data = _asMap(response['data']);
        final authData = data['auth_data'];
        if (authData is! String || authData.isEmpty) {
          throw const V2BoardException('Login response has no auth_data');
        }
        return _getSession(
          domain: domain,
          authData: authData,
          fallbackEmail: email.trim(),
        );
      } on Object catch (error) {
        lastError = _mapError(error);
      }
    }
    throw lastError ?? const V2BoardException('No V2Board API is available');
  }

  @override
  Future<V2BoardSession> restore(String authData) async {
    final config = await fetchRemoteConfig();
    V2BoardException? lastError;
    for (final domain in config.domains) {
      try {
        return await _getSession(domain: domain, authData: authData);
      } on Object catch (error) {
        lastError = _mapError(error);
      }
    }
    throw lastError ?? const V2BoardException('No V2Board API is available');
  }

  Future<V2BoardSession> _getSession({
    required String domain,
    required String authData,
    String fallbackEmail = '',
  }) async {
    final response = _asMap(
      await _transport.get(
        _endpoint(domain, '/user/getSubscribe'),
        headers: {'Authorization': authData},
      ),
    );
    _ensureSuccess(response);
    final data = _asMap(response['data']);
    final subscribeUrl = data['subscribe_url'];
    if (subscribeUrl is! String || !_isHttpUrl(subscribeUrl)) {
      throw const V2BoardException('Account has no valid subscription URL');
    }
    final email = data['email'];
    return V2BoardSession(
      authData: authData,
      email: email is String && email.isNotEmpty ? email : fallbackEmail,
      subscribeUrl: subscribeUrl,
    );
  }

  static void _ensureSuccess(Map<String, Object?> response) {
    final code = response['code'];
    if (code is num && code != 200) {
      throw V2BoardException(
        _messageFromMap(response) ?? 'V2Board request failed',
      );
    }
  }

  static Map<String, Object?> _asMap(Object? value) {
    final decoded = value is String ? jsonDecode(value) : value;
    if (decoded is! Map) {
      throw const V2BoardException('V2Board returned an invalid response');
    }
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  static String _endpoint(String domain, String path) {
    return '${domain.replaceFirst(RegExp(r'/+$'), '')}$path';
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static V2BoardException _mapError(Object error) {
    if (error is V2BoardException) return error;
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final body = error.response?.data;
      final message = body is Map ? _messageFromMap(_asMap(body)) : null;
      return V2BoardException(
        message ?? _errorMessage(error),
        kind: statusCode == 401 || statusCode == 403
            ? V2BoardExceptionKind.unauthorized
            : V2BoardExceptionKind.network,
      );
    }
    return V2BoardException(_errorMessage(error));
  }

  static String? _messageFromMap(Map<String, Object?> value) {
    for (final key in ['message', 'msg', 'error']) {
      final message = value[key];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  static String _errorMessage(Object error) {
    if (error is DioException) {
      return error.message ?? 'Network request failed';
    }
    return error.toString();
  }
}

enum V2BoardExceptionKind { configuration, network, unauthorized, response }

class V2BoardException implements Exception {
  final String message;
  final V2BoardExceptionKind kind;

  const V2BoardException(
    this.message, {
    this.kind = V2BoardExceptionKind.response,
  });

  @override
  String toString() => message;
}

final v2BoardClient = V2BoardClient();
