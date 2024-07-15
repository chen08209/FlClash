import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proxy/proxy_platform_interface.dart';

class Proxy extends ProxyPlatform {
  static Proxy? _instance;
  late MethodChannel methodChannel;
  ReceivePort? receiver;
  ServiceMessageListener? _serviceMessageHandler;

  Proxy._internal() {
    methodChannel = const MethodChannel("proxy");
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "started":
          final fd = call.arguments;
          onStarted(fd);
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

  Future<bool?> _initService() async {
    return await methodChannel.invokeMethod<bool>("initService");
  }

  handleStop() {
    globalState.stopSystemProxy();
  }

  @override
  Future<bool?> startProxy(port, args) async {
    if (!globalState.isVpnService) {
      return await _initService();
    }
    return await methodChannel
        .invokeMethod<bool>("startProxy", {'port': port, 'args': args});
  }

  @override
  Future<bool?> stopProxy() async {
    clashCore.stopTun();
    final isStop = await methodChannel.invokeMethod<bool>("stopProxy");
    if (isStop == true) {
      startTime = null;
    }
    return isStop;
  }

  Future<bool?> setProtect(int fd) async {
    return await methodChannel.invokeMethod<bool?>("setProtect", {'fd': fd});
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

  onStarted(int? fd) {
    debugPrint("onStarted ==> $fd");
    if (fd == null) return;
    if (receiver != null) {
      receiver!.close();
      receiver == null;
    }
    receiver = ReceivePort();
    receiver!.listen((message) {
      _handleServiceMessage(message);
    });
    clashCore.startTun(fd, receiver!.sendPort.nativePort);
  }

  updateStartTime() {
    startTime = clashCore.getRunTime();
  }

  setServiceMessageHandler(ServiceMessageListener serviceMessageListener) {
    _serviceMessageHandler = serviceMessageListener;
  }

  _handleServiceMessage(String message) {
    final m = ServiceMessage.fromJson(json.decode(message));
    switch (m.type) {
      case ServiceMessageType.protect:
        _serviceMessageHandler?.onProtect(Fd.fromJson(m.data));
      case ServiceMessageType.process:
        _serviceMessageHandler?.onProcess(Process.fromJson(m.data));
      case ServiceMessageType.started:
        _serviceMessageHandler?.onStarted(m.data);
      case ServiceMessageType.loaded:
        _serviceMessageHandler?.onLoaded(m.data);
    }
  }
}

final proxy = Platform.isAndroid ? Proxy() : null;
