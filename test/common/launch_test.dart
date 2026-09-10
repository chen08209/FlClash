import 'package:fl_clash/common/launch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class _FakeLauncher implements LaunchAtStartup {
  bool enabled = false;
  final calls = <String>[];

  @override
  void setup({
    required String appName,
    required String appPath,
    String? packageName,
    List<String> args = const [],
  }) {
    calls.add('setup');
  }

  @override
  Future<bool> isEnabled() async {
    calls.add('isEnabled');
    return enabled;
  }

  @override
  Future<bool> enable() async {
    calls.add('enable');
    enabled = true;
    return true;
  }

  @override
  Future<bool> disable() async {
    calls.add('disable');
    enabled = false;
    return true;
  }
}

void main() {
  late _FakeLauncher launcher;
  late AutoLaunch autoLaunch;

  setUp(() {
    launcher = _FakeLauncher();
    AutoLaunch.launcher = launcher;
    autoLaunch = AutoLaunch();
    launcher.calls.clear();
  });

  tearDownAll(() {
    AutoLaunch.launcher = launchAtStartup;
  });

  test('AutoLaunch is a singleton', () {
    expect(AutoLaunch(), same(autoLaunch));
  });

  test('each call delegates straight to the launcher', () async {
    launcher.enabled = true;
    expect(await autoLaunch.isEnable, isTrue);

    expect(await autoLaunch.disable(), isTrue);
    expect(launcher.enabled, isFalse);

    expect(await autoLaunch.enable(), isTrue);
    expect(launcher.enabled, isTrue);

    expect(launcher.calls, ['isEnabled', 'disable', 'enable']);
  });

  test('a debug build never registers autostart', () async {
    expect(
      kDebugMode,
      isTrue,
      reason: 'flutter test runs in debug; the guard below assumes it.',
    );

    await autoLaunch.updateStatus(true);
    await autoLaunch.updateStatus(false);

    expect(
      launcher.calls,
      isEmpty,
      reason:
          'updateStatus must return before reading or writing the autostart '
          'entry, or every debug run would register the running binary.',
    );
  });
}
