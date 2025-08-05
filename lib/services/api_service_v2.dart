import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceV2 {
  static const String baseUrl = 'https://origin.huanshen.org/api/v1';

  Future<Map<String, dynamic>> _makeRequest(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未找到授权信息，请重新登录');
      }

      print('Making request to: $baseUrl$endpoint');
      print('Authorization: $authData');

      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'DIRECT';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.getUrl(Uri.parse('$baseUrl$endpoint'));
      
      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('authorization', authData);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? '请求失败');
        }
      } else {
        throw Exception('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      return await _makeRequest('/user/info');
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    try {
      final data = await _makeRequest('/user/getSubscribe');
      
      // 保存订阅token
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('subscription_token', data['token']);
      }
      
      return data;
    } catch (e) {
      throw Exception('获取订阅信息失败: $e');
    }
  }
}
