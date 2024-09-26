import 'dart:async';
import 'dart:io';
import 'package:fl_clash/models/models.dart' hide Process;
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';
import 'windows.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launchAtStartup.setup(
      appName: appName,
      appPath: Platform.resolvedExecutable,
    );
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  Future<bool> get isEnable async {
    return await launchAtStartup.isEnabled();
  }

  Future<bool> get windowsIsEnable async {
    final res = await Process.run(
      'schtasks',
      ['/Query', '/TN', appName, '/V', "/FO", "LIST"],
      runInShell: true,
    );
    return res.stdout.toString().contains(Platform.resolvedExecutable);
  }

  Future<bool> enable() async {
    if (Platform.isWindows) {
      await windowsDisable();
    }
    return await launchAtStartup.enable();
  }

  windowsDisable() async {
    final res = await Process.run(
      'schtasks',
      [
        '/Delete',
        '/TN',
        appName,
        '/F',
      ],
      runInShell: true,
    );
    return res.exitCode == 0;
  }

  Future<bool> windowsEnable() async {
    await disable();
    return await windows?.registerTask(appName) ?? false;
  }

  Future<bool> disable() async {
    return await launchAtStartup.disable();
  }

  updateStatus(AutoLaunchState state) async {
    final isAdminAutoLaunch = state.isAdminAutoLaunch;
    final isAutoLaunch = state.isAutoLaunch;
    if (Platform.isWindows && isAdminAutoLaunch) {
      if (await windowsIsEnable == isAutoLaunch) return;
      if (isAutoLaunch) {
        final isEnable = await windowsEnable();
        if (!isEnable) {
          enable();
        }
      } else {
        windowsDisable();
      }
      return;
    }
    if (await isEnable == isAutoLaunch) return;
    if (isAutoLaunch == true) {
      enable();
    } else {
      disable();
    }
  }
}

final autoLaunch = system.isDesktop ? AutoLaunch() : null;
