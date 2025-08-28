import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/models/subscription_plan.dart';
import 'package:fl_clash/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 获取订阅套餐列表
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/plan/fetch',
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> plansJson = response.data['data'] as List<dynamic>;
        final plans = plansJson
            .map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>))
            .where((plan) => plan.show == 1) // 只返回显示的套餐
            .toList();
        
        // 按sort字段排序
        plans.sort((a, b) => a.sort.compareTo(b.sort));
        
        return plans;
      } else {
        throw Exception(response.data['message'] ?? '获取套餐列表失败');
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
      throw Exception('获取套餐列表失败：${e.toString()}');
    }
  }

  /// 获取用户订单列表
  Future<List<Order>> getOrderList() async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/order/fetch',
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> ordersJson = response.data['data'] as List<dynamic>;
        final orders = ordersJson
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // 按创建时间倒序排序（最新的在前面）
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return orders;
      } else {
        throw Exception(response.data['message'] ?? '获取订单列表失败');
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
      throw Exception('获取订单列表失败：${e.toString()}');
    }
  }

  /// 获取订单详情
  Future<Order> getOrderDetail(String tradeNo) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/order/detail',
        queryParameters: {
          'trade_no': tradeNo,
        },
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        final orderJson = response.data['data'] as Map<String, dynamic>;
        return Order.fromJson(orderJson);
      } else {
        throw Exception(response.data['message'] ?? '获取订单详情失败');
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
      throw Exception('获取订单详情失败：${e.toString()}');
    }
  }
}
