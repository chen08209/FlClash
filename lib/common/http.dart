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

  static bool handleBadCertificate(String host) {
    // Local endpoints (helper/core) are ours and always trusted.
    if (host == localhost || host == 'localhost' || host == '::1') {
      return true;
    }
    // Everything else must present a valid certificate, otherwise anyone on
    // the network could swap a subscription profile or read WebDAV
    // credentials. Users with a self-hosted server can opt back in.
    return globalState.container
        .read(appSettingProvider)
        .allowInsecureCertificate;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, host, _) => handleBadCertificate(host);
    client.findProxy = handleFindProxy;
    return client;
  }
}
