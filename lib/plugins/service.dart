import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';

import '../clash/lib.dart';

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;
  ReceivePort? receiver;

  Service._internal() {
    methodChannel = const MethodChannel("service");
  }

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Future<bool?> init() async {
    return await methodChannel.invokeMethod<bool>("init");
  }

  Future<bool?> destroy() async {
    return await methodChannel.invokeMethod<bool>("destroy");
  }

  Future<bool?> startVpn() async {
    final options = await clashLib?.getAndroidVpnOptions();
    return await methodChannel.invokeMethod<bool>("startVpn", {
      'data': json.encode(options),
    });
  }

  Future<bool?> stopVpn() async {
    return await methodChannel.invokeMethod<bool>("stopVpn");
  }
}

Service? get service => Platform.isAndroid && !globalState.isService ? Service() : null;
