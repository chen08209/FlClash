import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/window.dart';
import 'package:fl_clash/models/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';

const _windowChannel = MethodChannel('window');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;
  late List<MethodCall> methodCalls;
  late bool isVisible;
  late bool isMaximized;
  late bool isFullScreen;
  late bool isMinimized;
  late Rect bounds;

  setUp(() {
    calls = <String>[];
    methodCalls = <MethodCall>[];
    isVisible = true;
    isMaximized = false;
    isFullScreen = false;
    isMinimized = false;
    bounds = const Rect.fromLTWH(20, 30, 1000, 800);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          calls.add(call.method);
          methodCalls.add(call);
          return switch (call.method) {
            'isEffectSupported' => true,
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

  testWidgets('show raises the window and puts it back on the taskbar', (
    tester,
  ) async {
    await Window().show();

    expect(
      calls,
      containsAllInOrder(<String>['show', 'focus', 'setSkipTaskbar']),
    );
    await tester.pump(const Duration(seconds: 1));
  });

  test('hide drops the window off the taskbar', () async {
    await Window().hide();

    expect(calls, containsAllInOrder(<String>['hide', 'setSkipTaskbar']));
  });

  // Runs before any probe succeeds: the singleton caches a supported effect.
  test('an unsupported probe is retried the next time blur is on', () async {
    const tint = Color(0xFF112233);
    if (Platform.isLinux) {
      return;
    }
    var supported = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          methodCalls.add(call);
          return call.method == 'isEffectSupported' ? supported : null;
        });

    final first = await Window().setBlur(
      enabled: true,
      brightness: Brightness.dark,
      tint: tint,
    );
    supported = true;
    final second = await Window().setBlur(
      enabled: true,
      brightness: Brightness.dark,
      tint: tint,
    );

    expect(first, isFalse);
    expect(second, isTrue);
    expect(
      methodCalls.where((call) => call.method == 'isEffectSupported'),
      hasLength(Platform.isWindows ? 3 : 2),
    );
    expect(methodCalls.last.arguments['effect'], isNot('none'));
  });

  test('blur respects the platform effect support and brightness', () async {
    const tint = Color(0xFF112233);
    final active = await Window().setBlur(
      enabled: true,
      brightness: Brightness.dark,
      tint: tint,
    );

    if (Platform.isLinux) {
      expect(active, isFalse);
      expect(methodCalls, isEmpty);
      return;
    }

    expect(active, isTrue);
    expect(calls.last, 'setEffect');
    expect(methodCalls.last.arguments, {
      'effect': Platform.isWindows ? 'acrylic' : 'blur',
      'tint': Platform.isWindows
          ? tint.withValues(alpha: kSidebarBlurOpacity).toARGB32()
          : null,
      'brightness': 'dark',
    });
  });

  test('blur off sets the effect back to none', () async {
    const tint = Color(0xFF112233);
    final active = await Window().setBlur(
      enabled: false,
      brightness: Brightness.light,
      tint: tint,
    );

    expect(active, isFalse);
    if (Platform.isLinux) {
      expect(methodCalls, isEmpty);
      return;
    }

    expect(methodCalls.last.arguments, {
      'effect': 'none',
      'tint': Platform.isWindows
          ? tint.withValues(alpha: kSidebarBlurOpacity).toARGB32()
          : null,
      'brightness': 'light',
    });
  });

  test('close asks the platform to close the window', () async {
    await Window().close();

    expect(calls, ['close']);
  });

  testWidgets('toggle hides a visible window and shows a hidden one', (
    tester,
  ) async {
    await Window().toggle();

    expect(
      calls,
      containsAllInOrder(<String>['isVisible', 'hide', 'setSkipTaskbar']),
    );

    calls.clear();
    isVisible = false;
    await Window().toggle();

    expect(
      calls,
      containsAllInOrder(<String>['isVisible', 'show', 'setSkipTaskbar']),
    );
    await tester.pump(const Duration(seconds: 1));
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

  group('restoredWindowPosition', () {
    const primary = Display(
      id: 'primary',
      size: Size(1920, 1080),
      visiblePosition: Offset.zero,
      scaleFactor: 1,
    );
    // 2560x1440 physical at 150%, right of the primary: screen_retriever
    // divides its origin by its own scale.
    const secondary = Display(
      id: 'secondary',
      size: Size(1707, 960),
      visiblePosition: Offset(1280, 0),
      scaleFactor: 1.5,
    );

    test('places a window saved on a 150% monitor back on it', () {
      const props = WindowProps(
        width: 800,
        height: 600,
        left: 2200 / 1.5,
        top: 150 / 1.5,
        scale: 1.5,
      );

      final position = restoredWindowPosition(
        props,
        displays: const [primary, secondary],
        currentScale: 1,
      );

      expect(position!.dx, closeTo(2200, 0.001));
      expect(position.dy, closeTo(150, 0.001));
    });

    test('rejects a position no display shows any more', () {
      const props = WindowProps(
        width: 800,
        height: 600,
        left: 2200,
        top: 100,
        scale: 1,
      );

      expect(
        restoredWindowPosition(
          props,
          displays: const [primary],
          currentScale: 1,
        ),
        isNull,
      );
    });

    test('reads a position saved without a scale at the current one', () {
      const props = WindowProps(width: 800, height: 600, left: 100, top: 50);

      expect(
        restoredWindowPosition(
          props,
          displays: const [primary],
          currentScale: 1.25,
        ),
        const Offset(100, 50),
      );
    });

    test('keeps logical coordinates where the platform has them', () {
      const props = WindowProps(
        width: 800,
        height: 600,
        left: 1500,
        top: 100,
        scale: 2,
      );

      expect(
        restoredWindowPosition(props, displays: const [primary, secondary]),
        const Offset(1500, 100),
      );
    });
  });

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

  test('the init failure window closes and quits through onExit', () async {
    var exits = 0;

    await Window().showInitFailure(onExit: () async => exits++);

    MethodCall callOf(String method) =>
        methodCalls.firstWhere((call) => call.method == method);
    expect(callOf('setPreventClose').arguments, {'value': true});
    expect(
      (callOf('setTitleBarStyle').arguments as Map)['style'],
      'normal',
      reason: 'the error screen draws no window header of its own',
    );

    for (final event in ['close', 'should-terminate']) {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            _windowChannel.name,
            _windowChannel.codec.encodeMethodCall(
              MethodCall('onEvent', {'name': event}),
            ),
            null,
          );
    }
    expect(
      exits,
      2,
      reason:
          'the macOS runner cancels every quit and closing its last window '
          'leaves the process running, so both have to end in onExit',
    );
  });
}
