import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';

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
}

final service = Platform.isAndroid ? Service() : null;
