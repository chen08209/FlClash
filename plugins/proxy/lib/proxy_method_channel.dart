import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'proxy_platform_interface.dart';

/// An implementation of [ProxyPlatform] that uses method channels.
class MethodChannelProxy extends ProxyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('proxy');

  MethodChannelProxy();

  @override
  Future<bool?> startProxy(int port, List<String> bypassDomain) async {
    return await methodChannel.invokeMethod<bool>("StartProxy", {
      'port': port,
      'bypassDomain': bypassDomain,
    });
  }

  @override
  Future<bool?> stopProxy() async {
    return await methodChannel.invokeMethod<bool>("StopProxy");
  }
}
