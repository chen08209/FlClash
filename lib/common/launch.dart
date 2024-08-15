import 'dart:async';
import 'dart:io';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';

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

  windowsEnable() async {
    await Process.run(
      'schtasks',
      [
        '/Create',
        '/SC',
        'ONLOGON',
        '/TN',
        appName,
        '/TR',
        Platform.resolvedExecutable,
        '/RL',
        'HIGHEST',
        '/F'
      ],
      runInShell: true,
    );
  }

  Future<bool> disable() async {
    return await launchAtStartup.disable();
  }

  updateStatus(bool value) async {
    final currentEnable =
        Platform.isWindows ? await windowsIsEnable : await isEnable;
    if (value == currentEnable) {
      return;
    }
    if (Platform.isWindows) {
      if (value) {
        enable();
        windowsEnable();
      } else {
        windowsDisable();
      }
      return;
    }
    if (value == true) {
      enable();
    } else {
      disable();
    }
  }
}

final autoLaunch = system.isDesktop ? AutoLaunch() : null;
