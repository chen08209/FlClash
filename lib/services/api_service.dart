import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'https://origin.huanshen.org/api/v1';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'User-Agent': 'PostmanRuntime-ApipostRuntime/1.1.0',
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
    
    // 添加拦截器以自动添加授权头
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final authData = prefs.getString('auth_data');
        if (authData != null) {
          options.headers['authorization'] = authData;
          print('Authorization header set: $authData');
        } else {
          print('No auth_data found in SharedPreferences');
        }
        print('Request URL: ${options.uri}');
        print('Request headers: ${options.headers}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Request error: ${e.message}');
        print('Error response: ${e.response?.data}');
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('/user/info');
      
      // 确保响应是Map类型
      if (response.data is Map<String, dynamic>) {
        if (response.data['status'] == 'success') {
          return response.data['data'];
        }
        throw Exception(response.data['message'] ?? '请求失败');
      } else {
        print('Unexpected response type: ${response.data.runtimeType}');
        print('Response content: ${response.data}');
        throw Exception('服务器返回的数据格式错误');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response!.statusCode}');
        print('Error data: ${e.response!.data}');
      }
      throw Exception('获取用户信息失败: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('获取用户信息失败: $e');
    }
  }

  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    try {
      final response = await _dio.get('/user/getSubscribe');
      
      // 确保响应是Map类型
      if (response.data is Map<String, dynamic>) {
        if (response.data['status'] == 'success') {
          // 保存订阅token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('subscription_token', response.data['data']['token']);
          return response.data['data'];
        }
        throw Exception(response.data['message'] ?? '请求失败');
      } else {
        print('Unexpected response type: ${response.data.runtimeType}');
        print('Response content: ${response.data}');
        throw Exception('服务器返回的数据格式错误');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response!.statusCode}');
        print('Error data: ${e.response!.data}');
      }
      throw Exception('获取订阅信息失败: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('获取订阅信息失败: $e');
    }
  }
}
