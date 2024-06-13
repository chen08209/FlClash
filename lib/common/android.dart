import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/plugins/app.dart';

class Android {
  init() async {
    app?.onExit = () {
      clashCore.shutdown();
      print("adsadda==>");
      exit(0);
    };
  }
}

final android = Platform.isAndroid ? Android() : null;
