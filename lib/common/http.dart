import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlClashHttpOverrides extends HttpOverrides {
  static String handleFindProxy(Uri url) {
    if ([localhost].contains(url.host)) {
      return 'DIRECT';
    }
    final ref = globalState.container;
    final isStart = ref.read(isStartProvider);
    final suspend = ref.read(suspendProvider);
    commonPrint.log('find $url proxy: $isStart');
    if (!isStart || suspend) return 'DIRECT';
    final mixedPort = ref.read(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return 'PROXY localhost:$mixedPort';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return [localhost, 'localhost'].contains(host);
    };
    client.findProxy = handleFindProxy;
    return client;
  }
}
