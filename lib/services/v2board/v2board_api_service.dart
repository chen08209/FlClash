import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/v2board/models/v2board_models.dart';
import 'package:fl_clash/services/v2board/storage/token_storage.dart';

/// V2Board API 服务类
/// 负责与 V2Board 后端进行通信，包括用户认证、用户信息获取、订阅管理等
class V2BoardApiService {
  static V2BoardApiService? _instance;
  static V2BoardApiService get instance => _instance ??= V2BoardApiService._();
  
  V2BoardApiService._();
  
  late final Dio _dio;
  late final TokenStorage _tokenStorage;
  
  String? _baseUrl;
  String? get baseUrl => _baseUrl;
  
  /// 初始化服务
  Future<void> initialize({required String baseUrl}) async {
    _baseUrl = baseUrl;
    _tokenStorage = TokenStorage();
    await _tokenStorage.initialize();
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': browserUa,
      },
    ));
    
    // 添加请求拦截器，自动添加 token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 如果是 401 错误，清除 token
        if (error.response?.statusCode == 401) {
          await _tokenStorage.clearToken();
        }
        handler.next(error);
      },
    ));
    
    // 添加日志拦截器（仅在调试模式下）
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => commonPrint.log('V2Board API: $obj'),
    ));
  }
  
  /// 用户登录
  Future<V2BoardLoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/v2/passport/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final loginResponse = V2BoardBaseResponse<V2BoardLoginData>.fromJson(
        response.data,
        (json) => json != null ? V2BoardLoginData.fromJson(json as Map<String, dynamic>) : V2BoardLoginData(),
      );
      
      // 保存 token
      if (loginResponse.data?.authData != null) {
        await _tokenStorage.saveToken(loginResponse.data!.authData!);
      }
      
      return loginResponse;
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 获取用户信息
  Future<V2BoardUserResponse> getUserInfo() async {
    try {
      final response = await _dio.get('/api/v2/user/me');
      return V2BoardBaseResponse<V2BoardUser>.fromJson(
        response.data,
        (json) => json != null ? V2BoardUser.fromJson(json as Map<String, dynamic>) : V2BoardUser(),
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 获取用户订阅信息
  Future<V2BoardSubscriptionResponse> getSubscriptions() async {
    try {
      final response = await _dio.get('/api/v2/user/subscriptions');
      return V2BoardBaseResponse<List<V2BoardSubscription>>.fromJson(
        response.data,
        (json) => json != null
          ? (json as List).map((item) => V2BoardSubscription.fromJson(item as Map<String, dynamic>)).toList()
          : <V2BoardSubscription>[],
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 获取 Clash 订阅链接
  Future<String> getClashSubscriptionUrl() async {
    try {
      final response = await _dio.get('/api/v2/user/getSubscribe');
      final data = response.data;
      
      if (data is Map<String, dynamic> && 
          data.containsKey('data') && 
          data['data'] is Map<String, dynamic>) {
        final subscribeData = data['data'] as Map<String, dynamic>;
        if (subscribeData.containsKey('subscribe_url')) {
          return subscribeData['subscribe_url'] as String;
        }
      }
      
      throw V2BoardApiException('Invalid subscription response format');
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 重置订阅链接
  Future<String> resetSubscriptionUrl() async {
    try {
      final response = await _dio.post('/api/v2/user/resetSecurity');
      final data = response.data;
      
      if (data is Map<String, dynamic> && 
          data.containsKey('data') && 
          data['data'] is Map<String, dynamic>) {
        final subscribeData = data['data'] as Map<String, dynamic>;
        if (subscribeData.containsKey('subscribe_url')) {
          return subscribeData['subscribe_url'] as String;
        }
      }
      
      throw V2BoardApiException('Invalid reset subscription response format');
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 获取套餐列表
  Future<V2BoardPlansResponse> getPlans() async {
    try {
      final response = await _dio.get('/api/v2/user/plan/fetch');
      return V2BoardBaseResponse<List<V2BoardPlan>>.fromJson(
        response.data,
        (json) => json != null
          ? (json as List).map((item) => V2BoardPlan.fromJson(item as Map<String, dynamic>)).toList()
          : <V2BoardPlan>[],
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 创建订单
  Future<V2BoardOrderResponse> createOrder({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    try {
      final data = {
        'plan_id': planId,
        'period': period,
      };
      
      if (couponCode != null && couponCode.isNotEmpty) {
        data['coupon_code'] = couponCode;
      }
      
      final response = await _dio.post('/api/v2/user/order/save', data: data);
      return V2BoardBaseResponse<V2BoardOrder>.fromJson(
        response.data,
        (json) => json != null ? V2BoardOrder.fromJson(json as Map<String, dynamic>) : V2BoardOrder(),
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 获取支付方式
  Future<V2BoardPaymentMethodsResponse> getPaymentMethods() async {
    try {
      final response = await _dio.get('/api/v2/user/order/getPaymentMethod');
      return V2BoardBaseResponse<List<V2BoardPaymentMethod>>.fromJson(
        response.data,
        (json) => json != null
          ? (json as List).map((item) => V2BoardPaymentMethod.fromJson(item as Map<String, dynamic>)).toList()
          : <V2BoardPaymentMethod>[],
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 检查订单状态
  Future<V2BoardOrderStatusResponse> checkOrderStatus(String tradeNo) async {
    try {
      final response = await _dio.get('/api/v2/user/order/check', 
        queryParameters: {'trade_no': tradeNo});
      return V2BoardBaseResponse<V2BoardOrderStatus>.fromJson(
        response.data,
        (json) => json != null ? V2BoardOrderStatus.fromJson(json as Map<String, dynamic>) : V2BoardOrderStatus(),
      );
    } on DioException catch (e) {
      throw V2BoardApiException.fromDioError(e);
    }
  }
  
  /// 登出
  Future<void> logout() async {
    try {
      await _dio.post('/api/v2/passport/auth/logout');
    } catch (e) {
      // 忽略登出错误，继续清除本地 token
    } finally {
      await _tokenStorage.clearToken();
    }
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null;
  }
  
  /// 获取当前 token
  Future<String?> getCurrentToken() async {
    return await _tokenStorage.getToken();
  }
}
