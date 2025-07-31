import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/state.dart';

import 'system.dart';

class Android {
  Future<void> init() async {
    await service?.init();
    await service?.syncAndroidState(globalState.getAndroidState());
  }
}

final android = system.isAndroid ? Android() : null;
