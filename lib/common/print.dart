import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/cupertino.dart';

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  log(String? payload) {
    debugPrint("[FlClash] $payload");
    if (globalState.isService) {
      return;
    }
    globalState.appController.appFlowingState.logs.add(Log(
      logLevel: LogLevel.info,
      payload: payload,
    ));
  }
}

final commonPrint = CommonPrint();
