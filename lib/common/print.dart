import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {LogLevel logLevel = LogLevel.info}) {
    final payload = '[APP] $text';
    debugPrint(payload);
    if (!appController.isAttach) {
      return;
    }
    appController.addLog(Log.app(payload).copyWith(logLevel: logLevel));
  }
}

final commonPrint = CommonPrint();
