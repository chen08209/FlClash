import 'dart:io';

import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/services.dart';

import 'window.dart';

class System {
  static System? _instance;

  System._internal();

  factory System() {
    _instance ??= System._internal();
    return _instance!;
  }

  bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  get isAdmin async {
    if (!Platform.isWindows) return false;
    final result = await Process.run('net', ['session'], runInShell: true);
    return result.exitCode == 0;
  }

  back() async {
    await app?.moveTaskToBack();
    await window?.hide();
  }

  exit() async {
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
    }
    await window?.close();
  }
}

final system = System();
