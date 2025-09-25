import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/models/models.dart';
import 'endpoint_service.dart';

class ApiServiceV2 {
  static const String baseUrl = 'https://origin.huanshen.org/api/v1';
  
  final EndpointService _endpointService = EndpointService();
  
  /// 获取当前API基础URL
  String get _baseUrl => '${_endpointService.currentEndpoint}/api/v1';
  
  /// 初始化API服务和端点服务
  Future<void> initialize() async {
    await _endpointService.initialize();
    print('ApiServiceV2: Initialized with endpoint: ${_endpointService.currentEndpoint}');
  }
  
  /// 刷新端点
  Future<void> refreshEndpoints() async {
    await _endpointService.refresh();
    print('ApiServiceV2: Refreshed endpoint to: ${_endpointService.currentEndpoint}');
  }

  Future<Map<String, dynamic>> _makeRequest(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未找到授权信息，请重新登录');
      }

      print('Making request to: $_baseUrl$endpoint');
      print('Authorization: $authData');

      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.getUrl(Uri.parse('$_baseUrl$endpoint'));
      
      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('authorization', authData);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      
      // 安全解析响应体，无论状态码是什么
      Map<String, dynamic> data;
      try {
        data = json.decode(responseBody);
      } catch (e) {
        throw Exception('服务器返回了无效的响应格式');
      }
      
      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          return data['data'];
        } else if (data['status'] == 'fail') {
          // API业务逻辑错误，抛出服务器返回的具体错误消息
          throw Exception(data['message'] ?? '操作失败');
        } else {
          throw Exception(data['message'] ?? '请求失败');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx错误（400、422等），通常包含业务错误信息
        if (data['status'] == 'fail' && data['message'] != null) {
          throw Exception(data['message']);
        } else if (data['message'] != null) {
          throw Exception(data['message']);
        } else {
          throw Exception('客户端请求错误: ${response.statusCode}');
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

  Future<dynamic> _makeSimpleRequest(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未找到授权信息，请重新登录');
      }

      print('Making simple request to: $_baseUrl$endpoint');
      print('Authorization: $authData');

      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.getUrl(Uri.parse('$_baseUrl$endpoint'));
      
      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('authorization', authData);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      
      // 解析响应体，无论状态码是什么
      final responseData = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return responseData['data']; // 直接返回data，可能是任何类型
        } else if (responseData['status'] == 'fail') {
          // API业务逻辑错误，抛出服务器返回的具体错误消息
          throw Exception(responseData['message'] ?? '操作失败');
        } else {
          throw Exception(responseData['message'] ?? '请求失败');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx错误（400、422等），通常包含业务错误信息
        if (responseData['status'] == 'fail' && responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else if (responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else {
          throw Exception('客户端请求错误: ${response.statusCode}');
        }
      } else {
        throw Exception('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      print('Simple Request error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _makeDirectRequest(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未找到授权信息，请重新登录');
      }

      print('Making direct request to: $_baseUrl$endpoint');
      print('Authorization: $authData');

      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.getUrl(Uri.parse('$_baseUrl$endpoint'));
      
      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('authorization', authData);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      
      // 解析响应体，无论状态码是什么
      final responseData = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return responseData; // 直接返回整个响应
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx错误（400、422等），通常包含业务错误信息
        if (responseData['status'] == 'fail' && responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else if (responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else {
          throw Exception('客户端请求错误: ${response.statusCode}');
        }
      } else {
        throw Exception('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      print('Direct Request error: $e');
      rethrow;
    }
  }

  Future<dynamic> _makePostRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString('auth_data');
      
      if (authData == null) {
        throw Exception('未找到授权信息，请重新登录');
      }

      print('Making POST request to: $_baseUrl$endpoint');
      print('Authorization: $authData');
      print('Data: $data');

      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.postUrl(Uri.parse('$_baseUrl$endpoint'));
      
      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('authorization', authData);
      
      // 写入请求体
      final jsonData = json.encode(data);
      request.add(utf8.encode(jsonData));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      
      // 解析响应体，无论状态码是什么
      final responseData = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return responseData['data']; // 直接返回data，可能是任何类型
        } else if (responseData['status'] == 'fail') {
          // API业务逻辑错误，抛出服务器返回的具体错误消息
          throw Exception(responseData['message'] ?? '操作失败');
        } else {
          throw Exception(responseData['message'] ?? '请求失败');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx错误（400、422等），通常包含业务错误信息
        if (responseData['status'] == 'fail' && responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else if (responseData['message'] != null) {
          throw Exception(responseData['message']);
        } else {
          throw Exception('客户端请求错误: ${response.statusCode}');
        }
      } else {
        throw Exception('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      print('POST Request error: $e');
      rethrow;
    }
  }

  // 获取邀请信息
  Future<InviteInfo> getInviteInfo() async {
    try {
      final data = await _makeRequest('/user/invite/fetch');
      return InviteInfo.fromJson(data);
    } catch (e) {
      throw Exception('获取邀请信息失败: $e');
    }
  }

  // 获取佣金发放记录
  Future<InviteDetailsResponse> getInviteDetails({int current = 1, int pageSize = 10}) async {
    try {
      // 直接获取响应，因为这个API直接返回{data: [...], total: 1}格式
      final response = await _makeDirectRequest('/user/invite/details?current=$current&page_size=$pageSize');
      
      // 检查响应状态
      if (response['status'] == 'success') {
        return InviteDetailsResponse.fromJson(response);
      } else if (response['status'] == 'fail') {
        // API业务逻辑错误，抛出服务器返回的具体错误消息
        throw Exception(response['message'] ?? '获取佣金记录失败');
      } else {
        // 如果没有status字段，直接尝试解析（兼容直接返回data的格式）
        return InviteDetailsResponse.fromJson(response);
      }
    } catch (e) {
      throw Exception('获取佣金记录失败: $e');
    }
  }

  // 生成邀请码
  Future<bool> generateInviteCode() async {
    try {
      // 使用简单请求，因为返回的data是bool类型
      final data = await _makeSimpleRequest('/user/invite/save');
      return data == true;
    } catch (e) {
      throw Exception('生成邀请码失败: $e');
    }
  }

  // 佣金转为余额
  Future<bool> transferCommissionToBalance(int transferAmount) async {
    try {
      final data = await _makePostRequest('/user/transfer', {
        'transfer_amount': transferAmount,
      });
      return data == true;
    } catch (e) {
      throw Exception('佣金转换失败: $e');
    }
  }

  // 佣金提现
  Future<bool> withdrawCommission(String withdrawMethod, String withdrawAccount) async {
    try {
      final data = await _makePostRequest('/user/ticket/withdraw', {
        'withdraw_method': withdrawMethod,
        'withdraw_account': withdrawAccount,
      });
      return data == true;
    } catch (e) {
      throw Exception('佣金提现失败: $e');
    }
  }
}
