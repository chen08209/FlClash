import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/services.dart';

class Vpn {
  static Vpn? _instance;
  late MethodChannel methodChannel;
  ReceivePort? receiver;
  ServiceMessageListener? _serviceMessageHandler;

  Vpn._internal() {
    methodChannel = const MethodChannel("vpn");
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

  factory Vpn() {
    _instance ??= Vpn._internal();
    return _instance!;
  }

  Future<bool?> startVpn(port) async {
    final state = clashCore.getState();
    return await methodChannel.invokeMethod<bool>("start", {
      'port': state.mixedPort,
      'args': json.encode(state),
    });
  }

  Future<bool?> stopVpn() async {
    return await methodChannel.invokeMethod<bool>("stop");
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

  onStarted(int? fd) {
    if (receiver != null) {
      receiver!.close();
      receiver == null;
    }
    receiver = ReceivePort();
    receiver!.listen((message) {
      _handleServiceMessage(message);
    });
    clashCore.startTun(fd ?? 0, receiver!.sendPort.nativePort);
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

final vpn = Platform.isAndroid ? Vpn() : null;
