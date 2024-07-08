import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App {
  static App? _instance;
  MethodChannel? methodChannel;
  Function()? onExit;

  App._internal() {
    if (Platform.isAndroid) {
      methodChannel = const MethodChannel("app");
      methodChannel!.setMethodCallHandler((call) async {
        switch (call.method) {
          case "exit":
            if (onExit != null) {
              await onExit!();
            }
            break;
          case "gc":
            clashCore.requestGc();
            break;
          default:
            throw MissingPluginException();
        }
      });
    }
  }

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<bool?> moveTaskToBack() async {
    return await methodChannel?.invokeMethod<bool>("moveTaskToBack");
  }

  Future<List<Package>> getPackages() async {
    final packagesString =
    await methodChannel?.invokeMethod<String>("getPackages");
    return Isolate.run<List<Package>>(() {
      final List<dynamic> packagesRaw =
      packagesString != null ? json.decode(packagesString) : [];
      return packagesRaw.map((e) => Package.fromJson(e)).toList();
    });
  }

  Future<ImageProvider?> getPackageIcon(String packageName) async {
    final base64 = await methodChannel?.invokeMethod<String>("getPackageIcon", {
      "packageName": packageName,
    });
    if (base64 == null) {
      return null;
    }
    return MemoryImage(base64Decode(base64));
  }

  Future<bool?> tip(String? message) async {
    return await methodChannel?.invokeMethod<bool>("tip", {
      "message": "$message",
    });
  }

  Future<bool?> updateExcludeFromRecents(bool value) async {
    return await methodChannel?.invokeMethod<bool>("updateExcludeFromRecents", {
      "value": value,
    });
  }

  Future<String?> resolverProcess(Process process) async {
    return await methodChannel?.invokeMethod<String>("resolverProcess", {
      "data": json.encode(process),
    });
  }
}

final app = Platform.isAndroid ? App() : null;
