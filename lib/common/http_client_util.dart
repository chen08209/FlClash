import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/services/endpoint_service.dart';

/// HTTP客户端工具类
/// 提供统一的HTTP请求接口，避免重复初始化端点服务
class HttpClientUtil {
  static HttpClientUtil? _instance;
  static final EndpointService _endpointService = EndpointService();
  static bool _isInitialized = false;

  // 私有构造函数
  HttpClientUtil._();

  /// 获取单例实例
  static HttpClientUtil get instance {
    _instance ??= HttpClientUtil._();
    return _instance!;
  }

  /// 初始化端点服务（只初始化一次）
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('HttpClientUtil: Initializing endpoint service...');
    await _endpointService.initialize();
    _isInitialized = true;
    print('HttpClientUtil: Initialized with endpoint: ${_endpointService.currentEndpoint}');
  }

  /// 确保已初始化
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 获取当前最佳端点
  static String get currentEndpoint {
    return _endpointService.currentEndpoint;
  }

  /// 获取API基础URL
  static String get baseUrl => '$currentEndpoint/api/v1';

  /// 刷新端点（如果需要）
  static Future<void> refreshEndpoints() async {
    await _endpointService.refresh();
    print('HttpClientUtil: Refreshed endpoint to: ${_endpointService.currentEndpoint}');
  }

  /// 创建配置好的HttpClient
  static HttpClient _createHttpClient() {
    final client = HttpClient();
    client.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
    client.badCertificateCallback = (cert, host, port) => true;
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }

  /// 执行GET请求
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    await _ensureInitialized();
    
    final uri = Uri.parse('$baseUrl$endpoint');
    final finalUri = queryParameters != null 
        ? uri.replace(queryParameters: queryParameters)
        : uri;

    print('HttpClientUtil: GET $finalUri');

    final httpClient = _createHttpClient();
    try {
      final request = await httpClient.getUrl(finalUri);

      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');

      // 添加自定义请求头
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // 添加授权头
      if (requireAuth) {
        final authData = await _getAuthData();
        if (authData != null) {
          request.headers.set('authorization', authData);
        }
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('HttpClientUtil: Response status: ${response.statusCode}');
      
      return _handleResponse(response.statusCode, responseBody);
    } finally {
      httpClient.close();
    }
  }

  /// 执行POST请求
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    await _ensureInitialized();
    
    final uri = Uri.parse('$baseUrl$endpoint');
    print('HttpClientUtil: POST $uri');

    final httpClient = _createHttpClient();
    try {
      final request = await httpClient.postUrl(uri);

      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');

      // 添加自定义请求头
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // 添加授权头
      if (requireAuth) {
        final authData = await _getAuthData();
        if (authData != null) {
          request.headers.set('authorization', authData);
        }
      }

      // 添加请求体
      if (body != null) {
        final jsonBody = json.encode(body);
        request.write(jsonBody);
        print('HttpClientUtil: Request body: $jsonBody');
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('HttpClientUtil: Response status: ${response.statusCode}');
      
      return _handleResponse(response.statusCode, responseBody);
    } finally {
      httpClient.close();
    }
  }

  /// 获取授权数据
  static Future<String?> _getAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_data');
    } catch (e) {
      print('HttpClientUtil: Failed to get auth data: $e');
      return null;
    }
  }

  /// 处理响应
  static Map<String, dynamic> _handleResponse(int statusCode, String responseBody) {
    print('HttpClientUtil: Response body: $responseBody');
    
    try {
      final responseData = json.decode(responseBody);
      
      if (statusCode == 200) {
        return responseData;
      } else if (statusCode >= 400 && statusCode < 500) {
        // 4xx错误（400、422等），通常包含业务错误信息
        if (responseData is Map<String, dynamic>) {
          if (responseData['status'] == 'fail' && responseData['message'] != null) {
            throw Exception(responseData['message']);
          } else if (responseData['message'] != null) {
            throw Exception(responseData['message']);
          }
        }
        throw Exception('客户端请求错误: $statusCode');
      } else {
        throw Exception('服务器错误: $statusCode');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('响应解析失败: $e');
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 重置状态（用于测试）
  static void reset() {
    _isInitialized = false;
    _instance = null;
  }
}
