import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/models/subscription_plan.dart';
import 'package:fl_clash/models/order.dart';
import 'package:fl_clash/models/coupon.dart';
import 'package:fl_clash/models/payment_method.dart';
import 'package:fl_clash/models/ticket.dart';
import 'package:fl_clash/models/ticket_detail.dart';
import 'package:fl_clash/models/traffic_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoint_service.dart';

class AuthService {
  late Dio _dio;
  static const String baseUrl = 'https://origin.huanshen.org/api/v1';
  
  final EndpointService _endpointService = EndpointService();
  
  /// 获取当前API基础URL
  String get _baseUrl => '${_endpointService.currentEndpoint}/api/v1';

  bool _isInitialized = false;
  
  AuthService() {
    // 不在构造函数中初始化Dio，等待端点服务初始化完成
  }
  
  /// 初始化AuthService和端点服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _endpointService.initialize();
    _initDio(); // 使用最优端点初始化Dio
    _isInitialized = true;
    print('AuthService: Initialized with endpoint: ${_endpointService.currentEndpoint}');
  }
  
  /// 确保服务已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
  
  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
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
    
    // 设置代理用于抓包调试
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) {
        return 'PROXY 192.168.31.108:8888';
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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

  /// 验证优惠码
  Future<Coupon> checkCoupon({
    required String code,
    required int planId,
  }) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.post(
        '/user/coupon/check',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode({
          'code': code,
          'plan_id': planId,
        }),
      );

      if (response.data['status'] == 'success') {
        final couponJson = response.data['data'] as Map<String, dynamic>;
        return Coupon.fromJson(couponJson);
      } else {
        throw Exception(response.data['message'] ?? '优惠码验证失败');
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
      throw Exception('优惠码验证失败：${e.toString()}');
    }
  }

  /// 创建订单
  Future<String> createOrder({
    required String period,
    required int planId,
    String? couponCode,
  }) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final requestData = {
        'period': period,
        'plan_id': planId,
      };

      // 只有在提供优惠码时才添加到请求数据中
      if (couponCode != null && couponCode.isNotEmpty) {
        requestData['coupon_code'] = couponCode;
      }

      final response = await _dio.post(
        '/user/order/save',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode(requestData),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] as String; // 返回订单号
      } else {
        throw Exception(response.data['message'] ?? '创建订单失败');
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
      throw Exception('创建订单失败：${e.toString()}');
    }
  }

  // 获取支付方式列表
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/order/getPaymentMethod',
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> methodsJson = response.data['data'] as List<dynamic>;
        return methodsJson.map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data['message'] ?? '获取支付方式失败');
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
      throw Exception('获取支付方式失败：${e.toString()}');
    }
  }

  // 结算订单
  Future<PaymentResult> checkoutOrder({
    required String tradeNo,
    required int methodId,
  }) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.post(
        '/user/order/checkout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode({
          'trade_no': tradeNo,
          'method': methodId,
        }),
      );

      // 结算订单接口返回的数据结构直接就是 PaymentResult 格式
      return PaymentResult.fromJson(response.data as Map<String, dynamic>);
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
      throw Exception('订单结算失败：${e.toString()}');
    }
  }

  // 检查订单状态
  Future<OrderCheckStatus> checkOrderStatus(String tradeNo) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/order/check',
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
        final statusCode = response.data['data'] as int;
        return OrderCheckStatusExtension.fromCode(statusCode);
      } else {
        throw Exception(response.data['message'] ?? '检查订单状态失败');
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
      throw Exception('检查订单状态失败：${e.toString()}');
    }
  }

  // 关闭订单
  Future<bool> cancelOrder(String tradeNo) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.post(
        '/user/order/cancel',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode({
          'trade_no': tradeNo,
        }),
      );

      if (response.data['status'] == 'success') {
        return true;
      } else {
        throw Exception(response.data['message'] ?? '关闭订单失败');
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
      throw Exception('关闭订单失败：${e.toString()}');
    }
  }

  // ===== 工单相关 API =====
  
  /// 获取工单列表
  Future<List<Ticket>> getTicketList() async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/ticket/fetch',
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        List<dynamic> ticketsData = response.data['data'] ?? [];
        return ticketsData.map((ticket) => Ticket.fromJson(ticket)).toList();
      } else {
        throw Exception(response.data['message'] ?? '获取工单列表失败');
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
      throw Exception('获取工单列表失败：${e.toString()}');
    }
  }

  /// 创建工单
  Future<bool> createTicket({
    required String subject,
    required TicketLevel level,
    required String message,
  }) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.post(
        '/user/ticket/save',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode({
          'subject': subject,
          'level': level.code,
          'message': message,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] == true;
      } else {
        throw Exception(response.data['message'] ?? '创建工单失败');
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
      throw Exception('创建工单失败：${e.toString()}');
    }
  }

  /// 获取工单详情
  Future<TicketDetail> getTicketDetail(int ticketId) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/ticket/fetch',
        queryParameters: {
          'id': ticketId,
        },
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        return TicketDetail.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取工单详情失败');
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
      throw Exception('获取工单详情失败：${e.toString()}');
    }
  }

  /// 回复工单
  Future<bool> replyTicket({
    required int ticketId,
    required String message,
  }) async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.post(
        '/user/ticket/reply',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': authData,
          },
        ),
        data: json.encode({
          'id': ticketId,
          'message': message,
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] == true;
      } else {
        throw Exception(response.data['message'] ?? '回复工单失败');
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
      throw Exception('回复工单失败：${e.toString()}');
    }
  }

  // ===== 流量统计相关 API =====
  
  /// 获取流量明细列表
  Future<List<TrafficLog>> getTrafficLogs() async {
    try {
      // 获取授权token
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未登录，请先登录');
      }

      final response = await _dio.get(
        '/user/stat/getTrafficLog',
        options: Options(
          headers: {
            'authorization': authData,
          },
        ),
      );

      if (response.data['status'] == 'success') {
        List<dynamic> trafficData = response.data['data'] ?? [];
        return trafficData.map((traffic) => TrafficLog.fromJson(traffic)).toList();
      } else {
        throw Exception(response.data['message'] ?? '获取流量明细失败');
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
      throw Exception('获取流量明细失败：${e.toString()}');
    }
  }
}
