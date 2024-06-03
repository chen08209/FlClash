import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/services.dart';
import 'package:proxy/proxy_platform_interface.dart';

class Proxy extends ProxyPlatform {
  static Proxy? _instance;
  late MethodChannel methodChannel;
  late ReceivePort receiver;

  Proxy._internal() {
    methodChannel = const MethodChannel("proxy");
    receiver = ReceivePort()
      ..listen(
        (message) {
          setProtect(int.parse(message));
        },
      );
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "startAfter":
          int fd = call.arguments;
          startAfterHook(fd);
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  factory Proxy() {
    _instance ??= Proxy._internal();
    return _instance!;
  }

  @override
  Future<bool?> startProxy(int port, String? args) async {
    return await methodChannel
        .invokeMethod<bool>("StartProxy", {'port': port, 'args': args});
  }

  @override
  Future<bool?> stopProxy() async {
    clashCore.stopTun();
    final isStop = await methodChannel.invokeMethod<bool>("StopProxy");
    if (isStop == true) {
      startTime = null;
    }
    return isStop;
  }

  Future<bool?> setProtect(int fd) async {
    return await methodChannel.invokeMethod<bool?>("SetProtect", {'fd': fd});
  }

  Future<int?> getRunTimeStamp() async {
    return await methodChannel.invokeMethod<int?>("GetRunTimeStamp");
  }

  Future<bool?> startForeground({
    required String title,
    required String content,
  }) async {
    return await methodChannel.invokeMethod<bool?>("startForeground", {
      'title': title,
      'content': content,
    });
  }

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  startAfterHook(int? fd) {
    if (!isStart && fd != null) {
      clashCore.startTun(fd);
      updateStartTime();
    }
  }

  updateStartTime() async {
    startTime = await getRunTime();
  }

  Future<DateTime?> getRunTime() async {
    final runTimeStamp = await getRunTimeStamp();
    return runTimeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(runTimeStamp)
        : null;
  }
}

final proxy = Platform.isAndroid ? Proxy() : null;
