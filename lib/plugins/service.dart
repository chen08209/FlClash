import 'dart:async';
import 'dart:isolate';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/system.dart';
import 'package:flutter/services.dart';

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;
  ReceivePort? receiver;

  Service._internal() {
    methodChannel = const MethodChannel('$packageName/service');
  }

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Future<T?> invokeAction<T>(String data) async {
    return await methodChannel.invokeMethod<T>('invokeAction', data);
  }

  Future<bool> start<T>() async {
    return await methodChannel.invokeMethod<bool>('start') ?? false;
  }

  Future<bool> stop<T>() async {
    return await methodChannel.invokeMethod<bool>('stop') ?? false;
  }

  Future<DateTime?> getRuntime<T>() async {
    final ms = await methodChannel.invokeMethod<int>('getRuntime') ?? 0;
    if (ms == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

Service? get service => system.isAndroid ? Service() : null;
