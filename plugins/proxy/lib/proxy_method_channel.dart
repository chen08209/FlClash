import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'proxy_platform_interface.dart';

/// An implementation of [ProxyPlatform] that uses method channels.
class MethodChannelProxy extends ProxyPlatform {
  static const _startProxyMethod = 'StartProxy';
  static const _stopProxyMethod = 'StopProxy';

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('proxy');

  @override
  Future<bool> startProxy(int port, List<String> bypassDomain) async {
    return await methodChannel.invokeMethod<bool>(_startProxyMethod, {
          'port': port,
          'bypassDomain': bypassDomain,
        }) ??
        false;
  }

  @override
  Future<bool> stopProxy() async {
    return await methodChannel.invokeMethod<bool>(_stopProxyMethod) ?? false;
  }
}
