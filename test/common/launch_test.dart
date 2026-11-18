import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/launch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_api/rust_api.dart';

class _RustApi extends Mock implements RustLibApi {}

class _FakeEntry implements AutostartEntry {
  bool enabled = false;
  final calls = <String>[];

  @override
  Future<bool> isEnabled() async {
    calls.add('isEnabled');
    return enabled;
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    calls.add(enabled ? 'enable' : 'disable');
    this.enabled = enabled;
    return true;
  }
}

void main() {
  late _FakeEntry entry;
  late AutostartEntry systemEntry;
  late AutoLaunch autoLaunch;

  setUpAll(() {
    systemEntry = AutoLaunch.entry;
  });

  setUp(() {
    entry = _FakeEntry();
    AutoLaunch.entry = entry;
    autoLaunch = AutoLaunch();
  });

  tearDownAll(() {
    AutoLaunch.entry = systemEntry;
  });

  test('AutoLaunch is a singleton', () {
    expect(AutoLaunch(), same(autoLaunch));
  });

  test('each call delegates straight to the entry', () async {
    entry.enabled = true;
    expect(await autoLaunch.isEnable, isTrue);

    expect(await autoLaunch.disable(), isTrue);
    expect(entry.enabled, isFalse);

    expect(await autoLaunch.enable(), isTrue);
    expect(entry.enabled, isTrue);

    expect(entry.calls, ['isEnabled', 'disable', 'enable']);
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
      entry.calls,
      isEmpty,
      reason:
          'updateStatus must return before reading or writing the autostart '
          'entry, or every debug run would register the running binary.',
    );
  });

  test('the system entry registers by id under a display name', () async {
    final api = _RustApi();
    RustLib.initMock(api: api);
    final executable = Platform.resolvedExecutable;
    when(
      () => api.crateApiLaunchIsAutostartEnabled(
        id: any(named: 'id'),
        executable: any(named: 'executable'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => api.crateApiLaunchSetAutostart(
        id: any(named: 'id'),
        displayName: any(named: 'displayName'),
        executable: any(named: 'executable'),
        enabled: any(named: 'enabled'),
      ),
    ).thenAnswer((_) async => true);

    expect(await systemEntry.isEnabled(), isTrue);
    expect(await systemEntry.setEnabled(true), isTrue);

    verify(
      () => api.crateApiLaunchIsAutostartEnabled(
        id: appName,
        executable: executable,
      ),
    ).called(1);
    verify(
      () => api.crateApiLaunchSetAutostart(
        id: appName,
        displayName: appName,
        executable: executable,
        enabled: true,
      ),
    ).called(1);
  });
}
