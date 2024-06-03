import 'package:fl_clash/common/datetime.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:proxy/proxy.dart' as proxy_plugin;
import 'package:proxy/proxy_platform_interface.dart';

class ProxyManager {
  static ProxyManager? _instance;
  late ProxyPlatform _proxy;

  ProxyManager._internal() {
    _proxy = proxy ?? proxy_plugin.Proxy();
  }

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  DateTime? get startTime => _proxy.startTime;

  Future<bool?> startProxy({required int port, String? args}) async {
    return await _proxy.startProxy(port, args);
  }

  Future<bool?> stopProxy() async {
    return await _proxy.stopProxy();
  }

  Future<DateTime?> updateStartTime() async {
    if (_proxy is! Proxy) return null;
    return await (_proxy as Proxy).updateStartTime();
  }

  Future<bool?> setProtect(int fd) async {
    if (_proxy is! Proxy) return null;
    return await (_proxy as Proxy).setProtect(fd);
  }

  Future<bool?> startForeground({
    required String title,
    required String content,
  }) async {
    if (_proxy is! Proxy) return null;
    return await (_proxy as Proxy)
        .startForeground(title: title, content: content);
  }

  factory ProxyManager() {
    _instance ??= ProxyManager._internal();
    return _instance!;
  }
}

final proxyManager = ProxyManager();
