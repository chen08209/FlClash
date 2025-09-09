import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/state.dart';

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

  Future<Map<String, dynamic>> getLatestSubscriptionInfo() async {
    try {
      // 获取保存的订阅token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('subscription_token');
      
      if (token == null) {
        throw Exception('未找到订阅Token，请重新获取订阅信息');
      }
      
      final data = await _makeRequest('/client/subscribe?token=$token');
      return data;
    } catch (e) {
      print('Failed to get latest subscription info: $e');
      // 如果获取最新订阅信息失败，回退到用户信息
      return await getUserInfo();
    }
  }

  // 更新服务器订阅（用于支付完成后）
  Future<void> updateServerSubscription() async {
    try {
      print('ApiServiceV2: Starting server subscription update...');
      
      // 获取订阅信息和订阅链接
      final subscriptionInfo = await getSubscriptionInfo();
      final subscribeUrl = subscriptionInfo['subscribe_url'];
      
      if (subscribeUrl == null || subscribeUrl.isEmpty) {
        print('ApiServiceV2: No subscription URL found');
        return;
      }
      
      print('ApiServiceV2: Subscription URL found: $subscribeUrl');
      
      // 这里需要调用VPN配置更新逻辑
      // 由于这个方法在服务类中，我们通过GlobalState来调用
      final globalState = GlobalState();
      if (globalState.appController != null) {
        await globalState.appController!.updateServerSubscriptionAfterPayment(subscribeUrl);
      }
      
      print('ApiServiceV2: Server subscription update completed');
    } catch (e) {
      print('ApiServiceV2: Failed to update server subscription: $e');
      throw Exception('更新服务器订阅失败: $e');
    }
  }
}
