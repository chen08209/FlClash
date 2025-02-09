import 'dart:io';

import 'package:fl_clash/common/common.dart';

import '../state.dart';

class FlClashHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, __, ___) => true;
    client.findProxy = (url) {
      if ([localhost].contains(url.host)) {
        return "DIRECT";
      }
      final port = globalState.config.patchClashConfig.mixedPort;
      final isStart = globalState.appState.runTime != null;
      commonPrint.log("find $url proxy:$isStart");
      if (!isStart) return "DIRECT";
      return "PROXY localhost:$port";
    };
    return client;
  }
}
