import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class App {
  static App? _instance;
  late MethodChannel methodChannel;
  Function()? onExit;

  App._internal() {
    methodChannel = const MethodChannel('app');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'exit':
          if (onExit != null) {
            await onExit!();
          }
        case 'getText':
          try {
            return Intl.message(call.arguments as String);
          } catch (_) {
            return '';
          }
        default:
          throw MissingPluginException();
      }
    });
  }

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<bool?> moveTaskToBack() async {
    return await methodChannel.invokeMethod<bool>('moveTaskToBack');
  }

  Future<List<Package>> getPackages() async {
    final packagesString =
        await methodChannel.invokeMethod<String>('getPackages');
    return Isolate.run<List<Package>>(() {
      final List<dynamic> packagesRaw =
          packagesString != null ? json.decode(packagesString) : [];
      return packagesRaw.map((e) => Package.fromJson(e)).toSet().toList();
    });
  }

  Future<List<String>> getChinaPackageNames() async {
    final packageNamesString =
        await methodChannel.invokeMethod<String>('getChinaPackageNames');
    return Isolate.run<List<String>>(() {
      final List<dynamic> packageNamesRaw =
          packageNamesString != null ? json.decode(packageNamesString) : [];
      return packageNamesRaw.map((e) => e.toString()).toList();
    });
  }

  Future<bool> openFile(String path) async {
    return await methodChannel.invokeMethod<bool>('openFile', {
          'path': path,
        }) ??
        false;
  }

  Future<ImageProvider?> getPackageIcon(String packageName) async {
    final base64 = await methodChannel.invokeMethod<String>('getPackageIcon', {
      'packageName': packageName,
    });
    if (base64 == null) {
      return null;
    }
    return MemoryImage(base64Decode(base64));
  }

  Future<bool?> tip(String? message) async {
    return await methodChannel.invokeMethod<bool>('tip', {
      'message': '$message',
    });
  }

  Future<bool?> initShortcuts() async {
    return await methodChannel.invokeMethod<bool>(
      'initShortcuts',
      appLocalizations.toggle,
    );
  }

  Future<bool?> updateExcludeFromRecents(bool value) async {
    return await methodChannel.invokeMethod<bool>('updateExcludeFromRecents', {
      'value': value,
    });
  }
}

final app = system.isAndroid ? App() : null;
