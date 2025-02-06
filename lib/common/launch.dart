import 'dart:async';
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';
import 'package:fl_clash/plugins/app.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    if (system.isDesktop) {
      launchAtStartup.setup(
        appName: appName,
        appPath: Platform.resolvedExecutable,
      );
    }
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  Future<bool> get isEnable async {
    if (system.isDesktop) {
      return await launchAtStartup.isEnabled();
    } else {
      return (await app?.isAutoStartEnabled())!;
    }
  }

  Future<bool> enable() async {
    if (system.isDesktop) {
      return await launchAtStartup.enable();
    } else {
      return (await app?.setAutoStartEnabled(true))!;
    }
  }

  Future<bool> disable() async {
    if (system.isDesktop) {
      return await launchAtStartup.disable();
    } else {
      return (await app?.setAutoStartEnabled(false))!;
    }
  }

  updateStatus(bool isAutoLaunch) async {
    if (await isEnable == isAutoLaunch) return;
    if (isAutoLaunch == true) {
      enable();
    } else {
      disable();
    }
  }
}

final autoLaunch = AutoLaunch();
