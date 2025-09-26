import 'dart:convert';
import 'dart:io';

/// 基础HTTP客户端工具类
/// 用于EndpointService等底层服务，避免循环依赖
class BaseHttpClient {
  /// 创建配置好的HttpClient
  static HttpClient _createHttpClient() {
    final client = HttpClient();
    client.findProxy = (uri) => 'PROXY 192.168.31.108:8888';
    client.badCertificateCallback = (cert, host, port) => true;
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }

  /// 执行GET请求（用于端点获取等基础操作）
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    print('BaseHttpClient: GET $url');

    final httpClient = _createHttpClient();
    try {
      final request = await httpClient.getUrl(Uri.parse(url));

      // 设置请求头
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');

      // 添加自定义请求头
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('BaseHttpClient: Response status: ${response.statusCode}');
      
      return _handleResponse(response.statusCode, responseBody);
    } finally {
      httpClient.close();
    }
  }

  /// 测试端点延迟
  static Future<int> testEndpointLatency(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final httpClient = _createHttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse('$endpoint/api/v1/client/version'));
        request.headers.set('Accept', 'application/json');
        request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
        
        final response = await request.close();
        await response.drain(); // 读取并丢弃响应体
        
        stopwatch.stop();
        final latency = stopwatch.elapsedMilliseconds;
        
        print('BaseHttpClient: Endpoint $endpoint latency: ${latency}ms');
        return latency;
      } finally {
        httpClient.close();
      }
    } catch (e) {
      stopwatch.stop();
      print('BaseHttpClient: Error testing $endpoint: $e');
      return 999999; // 表示离线或超时
    }
  }

  /// 处理响应
  static Map<String, dynamic> _handleResponse(int statusCode, String responseBody) {
    print('BaseHttpClient: Response body: $responseBody');
    
    try {
      final responseData = json.decode(responseBody);
      
      if (statusCode == 200) {
        return responseData;
      } else {
        throw Exception('HTTP错误: $statusCode');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('响应解析失败: $e');
    }
  }
}
