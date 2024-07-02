import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
        "$appName/v$version",
        "clash-verge/v1.6.6",
        "Platform/${Platform.operatingSystem}",
      ].join(" ");
}
