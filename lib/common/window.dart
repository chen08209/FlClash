import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'protocol.dart';
import 'system.dart';

class Window {
  init() async {
    if (Platform.isWindows) {
      await WindowsSingleInstance.ensureSingleInstance([], "FlClash");
      protocol.register("clash");
      protocol.register("clashmeta");
      protocol.register("flclash");
    }
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 600),
      minimumSize: Size(400, 600),
      center: true,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
    });
  }

  show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  close() async {
    exit(0);
  }

  hide() async {
    await windowManager.hide();
  }
}

final window = system.isDesktop ? Window() : null;
