import 'package:flutter_test/flutter_test.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_ext/window_ext_platform_interface.dart';
import 'package:window_ext/window_ext_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowExtPlatform
    with MockPlatformInterfaceMixin
    implements WindowExtPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WindowExtPlatform initialPlatform = WindowExtPlatform.instance;

  test('$MethodChannelWindowExt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowExt>());
  });

  test('getPlatformVersion', () async {
    WindowExt windowExtPlugin = WindowExt();
    MockWindowExtPlatform fakePlatform = MockWindowExtPlatform();
    WindowExtPlatform.instance = fakePlatform;

    expect(await windowExtPlugin.getPlatformVersion(), '42');
  });
}
