import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class EndpointService {
  static const String _bestEndpointKey = 'best_endpoint';
  
  // 内置端点列表
  static const List<String> _builtInEndpoints = [
    'http://54.179.34.137:58647',
    'http://54.179.34.137',
    'http://52.79.128.168',
    'http://52.79.128.168:9954',
    'http://18.183.98.217',
    'http://18.183.98.217:5475',
    'http://20.2.140.29',
    'http://20.2.140.29:4456',
    'https://origin.huanshen.org',
    'https://www.huanshen.org',
    'https://www.hsnode.org',
  ];

  static final EndpointService _instance = EndpointService._internal();
  
  factory EndpointService() => _instance;
  
  EndpointService._internal();

  String? _currentEndpoint;
  List<EndpointInfo> _cachedEndpoints = [];

  /// 获取当前最优端点
  String get currentEndpoint => _currentEndpoint ?? _builtInEndpoints.first;

  /// 获取缓存的端点列表
  List<EndpointInfo> get cachedEndpoints => _cachedEndpoints;

  /// 初始化端点服务
  Future<void> initialize() async {
    print('EndpointService: Initializing...');
    
    // 每次启动都重新获取和测试端点
    print('EndpointService: Fetching and testing endpoints...');
    await _fetchAndTestEndpoints();
  }

  /// 强制刷新端点列表并重新测试
  Future<void> refresh() async {
    print('EndpointService: Force refreshing endpoints...');
    await _fetchAndTestEndpoints();
  }

  /// 测试单个端点的延迟
  Future<int> testEndpointLatency(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      print('EndpointService: Testing endpoint: $endpoint');
      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'DIRECT';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      httpClient.connectionTimeout = const Duration(seconds: 10);
      
      final request = await httpClient.getUrl(Uri.parse('$endpoint/api/v2/open/endpoint/test'));
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;
      
      print('EndpointService: $endpoint response (${response.statusCode}) in ${latency}ms: $responseBody');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(responseBody);
          if (responseData['code'] == 200 && responseData['data'] == 'ok') {
            return latency;
          }
        } catch (e) {
          print('EndpointService: Failed to parse response from $endpoint: $e');
        }
      }
      
      return 999999; // 返回一个很大的延迟表示失败
    } catch (e) {
      stopwatch.stop();
      print('EndpointService: Error testing $endpoint: $e');
      return 999999;
    }
  }

  /// 获取端点列表并测试延迟
  Future<void> _fetchAndTestEndpoints() async {
    final List<EndpointInfo> allEndpoints = [];
    
    // 首先使用内置端点获取服务器端点列表
    String? workingEndpoint;
    for (final builtInEndpoint in _builtInEndpoints) {
      try {
        print('EndpointService: Trying to fetch endpoint list from: $builtInEndpoint');
        final endpoints = await _fetchEndpointList(builtInEndpoint);
        if (endpoints.isNotEmpty) {
          allEndpoints.addAll(endpoints);
          workingEndpoint = builtInEndpoint;
          print('EndpointService: Successfully fetched ${endpoints.length} endpoints from $builtInEndpoint');
          break;
        }
      } catch (e) {
        print('EndpointService: Failed to fetch from $builtInEndpoint: $e');
        continue;
      }
    }
    
    // 如果无法从服务器获取端点列表，使用内置端点
    if (allEndpoints.isEmpty) {
      print('EndpointService: Using built-in endpoints as fallback');
      for (int i = 0; i < _builtInEndpoints.length; i++) {
        allEndpoints.add(EndpointInfo(
          id: i + 1,
          name: 'Built-in-${i + 1}',
          point: _builtInEndpoints[i],
          tags: 'built-in',
          isActive: 1,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          responseTime: DateTime.now().toIso8601String(),
          priority: 0,
        ));
      }
    }
    
    // 测试所有端点的延迟
    print('EndpointService: Testing ${allEndpoints.length} endpoints...');
    final List<EndpointInfo> testedEndpoints = [];
    
    for (final endpoint in allEndpoints) {
      if (endpoint.isActive == 1) {
        final latency = await testEndpointLatency(endpoint.point);
        testedEndpoints.add(endpoint.copyWith(
          latencyMs: latency,
          isOnline: latency < 999999,
          lastTestedAt: DateTime.now().toIso8601String(),
        ));
      }
    }
    
    // 按延迟排序
    testedEndpoints.sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
    
    print('EndpointService: Endpoint test results:');
    for (final endpoint in testedEndpoints) {
      print('  ${endpoint.name}: ${endpoint.point} - ${endpoint.latencyMs}ms (${endpoint.isOnline ? 'online' : 'offline'})');
    }
    
    _cachedEndpoints = testedEndpoints;
    await _selectBestEndpoint();
  }

  /// 从指定端点获取端点列表
  Future<List<EndpointInfo>> _fetchEndpointList(String endpoint) async {
    final httpClient = HttpClient();
    httpClient.findProxy = (uri) => 'DIRECT';
    httpClient.badCertificateCallback = (cert, host, port) => true;
    httpClient.connectionTimeout = const Duration(seconds: 15);
    
    final request = await httpClient.getUrl(Uri.parse('$endpoint/api/v2/open/endpoint/list'));
    request.headers.set('Accept', 'application/json');
    request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);
      if (responseData['code'] == 200) {
        final endpointResponse = EndpointListResponse.fromJson(responseData);
        return endpointResponse.data;
      }
    }
    
    throw Exception('Failed to fetch endpoint list from $endpoint');
  }

  /// 选择最佳端点
  Future<void> _selectBestEndpoint() async {
    if (_cachedEndpoints.isEmpty) {
      _currentEndpoint = _builtInEndpoints.first;
      print('EndpointService: No cached endpoints, using default: $_currentEndpoint');
      return;
    }
    
    // 找到延迟最低且在线的端点
    final onlineEndpoints = _cachedEndpoints.where((e) => e.isOnline).toList();
    if (onlineEndpoints.isEmpty) {
      _currentEndpoint = _builtInEndpoints.first;
      print('EndpointService: No online endpoints, using default: $_currentEndpoint');
      return;
    }
    
    final bestEndpoint = onlineEndpoints.first;
    _currentEndpoint = bestEndpoint.point;
    
    print('EndpointService: Selected best endpoint: $_currentEndpoint (${bestEndpoint.latencyMs}ms)');
    
    // 保存最佳端点
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bestEndpointKey, _currentEndpoint!);
    
    // 提交使用日志
    await _submitUsageLog(bestEndpoint.id);
  }

  /// 提交端点使用日志
  Future<void> _submitUsageLog(int endpointId) async {
    try {
      if (_currentEndpoint == null) return;
      
      print('EndpointService: Submitting usage log for endpoint $endpointId');
      
      final httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'DIRECT';
      httpClient.badCertificateCallback = (cert, host, port) => true;
      
      final request = await httpClient.postUrl(Uri.parse('$_currentEndpoint/api/v2/open/endpoint/saveLog'));
      request.headers.set('Accept', '*/*');
      request.headers.set('Accept-Encoding', 'gzip, deflate, br');
      request.headers.set('Connection', 'keep-alive');
      request.headers.set('User-Agent', 'PostmanRuntime-ApipostRuntime/1.1.0');
      request.headers.set('content-type', 'multipart/form-data; boundary=----formdata-boundary');
      
      final formData = '------formdata-boundary\r\n'
          'Content-Disposition: form-data; name="endpointId"\r\n'
          '\r\n'
          '$endpointId\r\n'
          '------formdata-boundary--\r\n';
      
      request.add(utf8.encode(formData));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('EndpointService: Usage log response: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('EndpointService: Failed to submit usage log: $e');
    }
  }


  /// 重新测试所有缓存的端点
  Future<void> retestEndpoints() async {
    if (_cachedEndpoints.isEmpty) {
      await _fetchAndTestEndpoints();
      return;
    }
    
    print('EndpointService: Retesting ${_cachedEndpoints.length} cached endpoints...');
    final List<EndpointInfo> testedEndpoints = [];
    
    for (final endpoint in _cachedEndpoints) {
      final latency = await testEndpointLatency(endpoint.point);
      testedEndpoints.add(endpoint.copyWith(
        latencyMs: latency,
        isOnline: latency < 999999,
        lastTestedAt: DateTime.now().toIso8601String(),
      ));
    }
    
    // 按延迟排序
    testedEndpoints.sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
    
    _cachedEndpoints = testedEndpoints;
    await _selectBestEndpoint();
  }

  /// 手动设置当前端点
  Future<void> setCurrentEndpoint(String endpoint) async {
    _currentEndpoint = endpoint;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bestEndpointKey, endpoint);
    print('EndpointService: Manually set current endpoint to: $endpoint');
  }

  /// 清除状态
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestEndpointKey);
    _cachedEndpoints.clear();
    _currentEndpoint = null;
    print('EndpointService: State cleared');
  }
}
