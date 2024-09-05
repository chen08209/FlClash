import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../state.dart';

class FlClashHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, __, ___) => true;
    client.findProxy = (url) {
      debugPrint("find $url");
      final port = globalState.appController.clashConfig.mixedPort;
      final isStart = globalState.appController.appState.isStart;
      if (!isStart) return "DIRECT";
      return "PROXY localhost:$port";
    };
    return client;
  }
}
