import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class AuthService {
  late Dio _dio;
  static const String baseUrl = 'https://origin.huanshen.org/api/v1';

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': '*/*',
        // 重要：移除 'br' 因为Flutter的HttpClient不支持Brotli自动解压
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'User-Agent': 'FlClash/1.0',
      },
    ));
    
    // 绕过代理，直接连接
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) {
        return 'DIRECT';
      };
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
    
    // 添加拦截器用于调试和错误处理
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Auth Request URL: ${options.uri}');
        print('Auth Request headers: ${options.headers}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Auth Response status: ${response.statusCode}');
        print('Auth Response data: ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Auth Request error: ${e.message ?? "Unknown error"}');
        print('Auth Error type: ${e.type}');
        print('Auth Error response: ${e.response?.data}');
        print('Auth Error response headers: ${e.response?.headers}');
        handler.next(e);
      },
    ));
  }

  /// 获取注册配置信息
  Future<Map<String, dynamic>> getRegistrationConfig() async {
    try {
      final response = await _dio.get('/guest/comm/config');
      
      if (response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '获取配置失败');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败，请检查网络设置');
      } else {
        throw Exception('网络错误：${e.message ?? "未知网络错误"}');
      }
    } catch (e) {
      throw Exception('获取配置失败：${e.toString()}');
    }
  }

  /// 发送邮箱验证码
  Future<bool> sendEmailVerificationCode(String email) async {
    try {
      final response = await _dio.post(
        '/passport/comm/sendEmailVerify',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] ?? true;
      } else {
        throw Exception(response.data['message'] ?? '发送验证码失败');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败，请检查网络设置');
      } else {
        throw Exception('网络错误：${e.message ?? "未知网络错误"}');
      }
    } catch (e) {
      throw Exception('发送验证码失败：${e.toString()}');
    }
  }

  /// 注册用户账户
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String emailCode,
    String inviteCode = '',
    String recaptchaData = '',
  }) async {
    try {
      final response = await _dio.post(
        '/passport/auth/register',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
          'password': password,
          'email_code': emailCode,
          'invite_code': inviteCode,
          'recaptcha_data': recaptchaData,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '注册失败');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败，请检查网络设置');
      } else {
        throw Exception('网络错误：${e.message ?? "未知网络错误"}');
      }
    } catch (e) {
      throw Exception('注册失败：${e.toString()}');
    }
  }

  /// 重置密码
  Future<bool> resetPassword({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    try {
      final response = await _dio.post(
        '/passport/auth/forget',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
          'password': password,
          'email_code': emailCode,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] ?? true;
      } else {
        throw Exception(response.data['message'] ?? '重置密码失败');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败，请检查网络设置');
      } else {
        throw Exception('网络错误：${e.message ?? "未知网络错误"}');
      }
    } catch (e) {
      throw Exception('重置密码失败：${e.toString()}');
    }
  }

  /// 用户登录
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/passport/auth/login',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '登录失败');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('网络连接失败，请检查网络设置');
      } else {
        throw Exception('网络错误：${e.message ?? "未知网络错误"}');
      }
    } catch (e) {
      throw Exception('登录失败：${e.toString()}');
    }
  }
}
