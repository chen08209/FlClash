import 'dart:io';

import 'package:fl_clash/models/config.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'protocol.dart';
import 'system.dart';

class Window {
  init(WindowProps props) async {
    if (Platform.isWindows) {
      await WindowsSingleInstance.ensureSingleInstance([], "FlClash");
      protocol.register("clash");
      protocol.register("clashmeta");
      protocol.register("flclash");
    }
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(props.width, props.height),
      minimumSize: const Size(380, 600),
      titleBarStyle: TitleBarStyle.hidden,
    );
    if (props.left != null || props.top != null) {
      await windowManager.setPosition(
        Offset(props.left ?? 0, props.top ?? 0),
      );
    } else {
      await windowManager.setAlignment(Alignment.center);
    }
    // if(Platform.isWindows){
    //   await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    // }
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
