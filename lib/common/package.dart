import 'dart:async';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

class AppPackage {
  static AppPackage? _instance;

  Completer<PackageInfo> packageInfoCompleter = Completer();

  AppPackage._internal() {
    PackageInfo.fromPlatform().then(
      (value) => packageInfoCompleter.complete(value),
    );
  }

  Future<String> getUa() async {
    final packageInfo = await packageInfoCompleter.future;
    final uas = [
      "$appName/v${packageInfo.version}",
      "clash-verge/v1.6.6",
      "Platform/${Platform.operatingSystem}",
    ];
    return uas.join(" ");
  }

  factory AppPackage() {
    _instance ??= AppPackage._internal();
    return _instance!;
  }
}

final appPackage = AppPackage();
