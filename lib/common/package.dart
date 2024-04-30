import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

class AppPackage{

  static AppPackage? _instance;
  Completer<PackageInfo> packageInfoCompleter = Completer();

  AppPackage._internal() {
     PackageInfo.fromPlatform().then(
          (value) => packageInfoCompleter.complete(value),
    );
  }

  factory AppPackage() {
    _instance ??= AppPackage._internal();
    return _instance!;
  }
}

final appPackage = AppPackage();