import 'dart:io';

import 'package:fl_clash/plugins/app.dart';

class Android {
  init() async {
    app?.onExit = () {};
  }
}

final android = Platform.isAndroid ? Android() : null;
