import 'package:fl_clash/common/window.dart';
import 'package:fl_clash/models/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _windowChannel = MethodChannel('window_manager');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;
  late bool isVisible;
  late bool isMaximized;
  late bool isFullScreen;
  late bool isMinimized;
  late Rect bounds;

  setUp(() {
    calls = <String>[];
    isVisible = true;
    isMaximized = false;
    isFullScreen = false;
    isMinimized = false;
    bounds = const Rect.fromLTWH(20, 30, 1000, 800);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          calls.add(call.method);
          return switch (call.method) {
            'isVisible' => isVisible,
            'isMaximized' => isMaximized,
            'isFullScreen' => isFullScreen,
            'isMinimized' => isMinimized,
            'getBounds' => <String, double>{
              'x': bounds.left,
              'y': bounds.top,
              'width': bounds.width,
              'height': bounds.height,
            },
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

  test(
    'normal geometry captures size without compositor-owned position',
    () async {
      const current = WindowProps(width: 800, height: 600, left: 90, top: 70);

      final geometry = await Window().captureNormalGeometry(current);

      expect(
        geometry,
        const WindowProps(width: 1000, height: 800, left: 90, top: 70),
      );
    },
  );

  test('maximized geometry is not captured', () async {
    isMaximized = true;

    expect(await Window().captureNormalGeometry(const WindowProps()), isNull);
    expect(calls, isNot(contains('getBounds')));
  });

  test('fullscreen and minimized geometry are not captured', () async {
    isFullScreen = true;
    expect(await Window().captureNormalGeometry(const WindowProps()), isNull);

    isFullScreen = false;
    isMinimized = true;
    expect(await Window().captureNormalGeometry(const WindowProps()), isNull);
  });
}
