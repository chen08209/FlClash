import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstant {
  final packageName = "com.follow.clash";
  final name = "FlClash";
  final httpTimeoutDuration = const Duration(milliseconds: 5000);
  final moreDuration = const Duration(milliseconds: 100);
  final defaultUpdateDuration = const Duration(days: 1);
  final mmdbFileName = "geoip.metadb";
  final profilesDirectoryName = "profiles";
  final configFileName = "config.yaml";
  final localhost = "127.0.0.1";
  final clashKey = "clash";
  final configKey = "config";
  final listItemPadding = const EdgeInsets.symmetric(horizontal: 16);
  final dialogCommonWidth = 300;
  final repository = "chen08209/FlClash";
  final filter = ImageFilter.blur(
    sigmaX: 5,
    sigmaY: 5,
    tileMode: TileMode.mirror,
  );
  final defaultPrimaryColor = Colors.brown;
}

final appConstant = AppConstant();
