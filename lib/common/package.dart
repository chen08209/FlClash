import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
        "$appName/v$version",
        "like ClashMeta v2ray sing-box",
        "Platform/${Platform.operatingSystem}",
      ].join(" ");
}
