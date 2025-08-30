import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';

/// V2Board 代理管理器
/// 负责管理本地代理的开启和关闭，确保网络请求能够正常通过代理
class V2BoardProxyManager {
  static V2BoardProxyManager? _instance;
  static V2BoardProxyManager get instance => _instance ??= V2BoardProxyManager._();
  
  V2BoardProxyManager._();
  
  static const int _targetProxyPort = 7897;
  bool _isProxyEnabled = false;
  
  /// 获取当前代理状态
  bool get isProxyEnabled => _isProxyEnabled;
  
  /// 获取目标代理端口
  int get targetProxyPort => _targetProxyPort;
  
  /// 初始化代理管理器
  Future<void> initialize() async {
    commonPrint.log('V2BoardProxyManager: Initializing proxy manager');
    
    // 在应用启动时自动开启代理
    await enableProxy();
  }
  
  /// 开启代理 - 相当于 proxy_on() 函数
  Future<bool> enableProxy() async {
    try {
      commonPrint.log('V2BoardProxyManager: Attempting to enable proxy on port $_targetProxyPort');
      
      // 检查代理端口是否可用
      if (await _isPortAvailable(_targetProxyPort)) {
        // 更新 FlClash 配置以使用指定端口
        await _updateClashProxyPort(_targetProxyPort);
        
        // 设置系统代理环境变量
        await _setSystemProxyEnvironment(_targetProxyPort);
        
        _isProxyEnabled = true;
        commonPrint.log('V2BoardProxyManager: Proxy enabled successfully on port $_targetProxyPort');
        return true;
      } else {
        commonPrint.log('V2BoardProxyManager: Port $_targetProxyPort is not available');
        
        // 如果目标端口不可用，尝试使用 FlClash 的默认端口
        final defaultPort = globalState.config.patchClashConfig.mixedPort;
        if (await _isPortAvailable(defaultPort)) {
          await _setSystemProxyEnvironment(defaultPort);
          _isProxyEnabled = true;
          commonPrint.log('V2BoardProxyManager: Using default FlClash port $defaultPort');
          return true;
        }
        
        return false;
      }
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Failed to enable proxy: $e');
      return false;
    }
  }
  
  /// 关闭代理 - 相当于 proxy_off() 函数
  Future<bool> disableProxy() async {
    try {
      commonPrint.log('V2BoardProxyManager: Disabling proxy');
      
      // 清除系统代理环境变量
      await _clearSystemProxyEnvironment();
      
      _isProxyEnabled = false;
      commonPrint.log('V2BoardProxyManager: Proxy disabled successfully');
      return true;
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Failed to disable proxy: $e');
      return false;
    }
  }
  
  /// 检查端口是否可用
  Future<bool> _isPortAvailable(int port) async {
    try {
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 更新 Clash 代理端口配置
  Future<void> _updateClashProxyPort(int port) async {
    try {
      // 更新全局配置中的混合端口
      final currentConfig = globalState.config.patchClashConfig;
      final updatedConfig = currentConfig.copyWith(mixedPort: port);
      
      // 保存更新后的配置
      globalState.config = globalState.config.copyWith(
        patchClashConfig: updatedConfig,
      );
      
      commonPrint.log('V2BoardProxyManager: Updated Clash mixed port to $port');
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Failed to update Clash port: $e');
      rethrow;
    }
  }
  
  /// 设置系统代理环境变量
  Future<void> _setSystemProxyEnvironment(int port) async {
    try {
      final proxyUrl = 'http://127.0.0.1:$port';
      
      // 设置环境变量
      Platform.environment['HTTP_PROXY'] = proxyUrl;
      Platform.environment['HTTPS_PROXY'] = proxyUrl;
      Platform.environment['http_proxy'] = proxyUrl;
      Platform.environment['https_proxy'] = proxyUrl;
      
      commonPrint.log('V2BoardProxyManager: Set system proxy environment to $proxyUrl');
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Failed to set proxy environment: $e');
      rethrow;
    }
  }
  
  /// 清除系统代理环境变量
  Future<void> _clearSystemProxyEnvironment() async {
    try {
      // 清除环境变量
      Platform.environment.remove('HTTP_PROXY');
      Platform.environment.remove('HTTPS_PROXY');
      Platform.environment.remove('http_proxy');
      Platform.environment.remove('https_proxy');
      
      commonPrint.log('V2BoardProxyManager: Cleared system proxy environment');
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Failed to clear proxy environment: $e');
      rethrow;
    }
  }
  
  /// 检查代理连接状态
  Future<bool> checkProxyConnection() async {
    try {
      final client = HttpClient();
      client.findProxy = (uri) {
        if (_isProxyEnabled) {
          final port = globalState.config.patchClashConfig.mixedPort;
          return 'PROXY 127.0.0.1:$port';
        }
        return 'DIRECT';
      };
      
      // 尝试连接测试 URL
      final request = await client.getUrl(Uri.parse('http://www.google.com/generate_204'));
      final response = await request.close();
      await response.drain();
      client.close();
      
      return response.statusCode == 204;
    } catch (e) {
      commonPrint.log('V2BoardProxyManager: Proxy connection check failed: $e');
      return false;
    }
  }
  
  /// 获取当前代理配置信息
  Map<String, dynamic> getProxyInfo() {
    final port = globalState.config.patchClashConfig.mixedPort;
    return {
      'enabled': _isProxyEnabled,
      'port': port,
      'target_port': _targetProxyPort,
      'proxy_url': 'http://127.0.0.1:$port',
    };
  }
  
  /// 重启代理
  Future<bool> restartProxy() async {
    commonPrint.log('V2BoardProxyManager: Restarting proxy');
    await disableProxy();
    await Future.delayed(const Duration(seconds: 1));
    return await enableProxy();
  }
}
