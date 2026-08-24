import 'package:fl_clash/common/window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _windowChannel = MethodChannel('window_manager');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;
  late bool isVisible;

  setUp(() {
    calls = <String>[];
    isVisible = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          calls.add(call.method);
          return switch (call.method) {
            'isVisible' => isVisible,
            'isMinimized' => false,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, null);
  });

  test('is a singleton so every caller drives the same window', () {
    expect(Window(), same(Window()));
  });

  test('show raises the window and puts it back on the taskbar', () async {
    await Window().show();

    expect(calls, containsAllInOrder(<String>['show', 'focus']));
    expect(calls, contains('setSkipTaskbar'));
  });

  test('hide drops the window off the taskbar', () async {
    await Window().hide();

    expect(calls, containsAllInOrder(<String>['hide', 'setSkipTaskbar']));
  });

  test('close asks the platform to close the window', () async {
    await Window().close();

    expect(calls, ['close']);
  });

  test('isVisible reports what the platform answers', () async {
    expect(await Window().isVisible, isTrue);

    isVisible = false;
    expect(await Window().isVisible, isFalse);
  });
}
