import 'dart:async';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/common/feature.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window/window.dart' show WindowListener, desktopWindow;

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _windowChannel = MethodChannel('window');

class _RecordingSystemAction extends SystemAction {
  static final calls = <String>[];

  @override
  Future<void> handleClose([bool exit = true]) async {
    calls.add('close');
  }

  @override
  Future<void> handleExit([bool needSave = true]) async {
    calls.add('exit');
  }
}

typedef _BlurRequest = ({bool enabled, Brightness brightness, Color tint});

class _RecordingWindowPort implements WindowPort {
  Rect bounds = const Rect.fromLTWH(0, 0, 1000, 800);
  int shows = 0;
  Completer<void>? geometryGate;
  bool isNormal = true;
  bool supportsPosition = true;
  bool supportsBlur = true;
  final blurRequests = <_BlurRequest>[];

  @override
  Future<bool> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  }) async {
    blurRequests.add((enabled: enabled, brightness: brightness, tint: tint));
    return enabled && supportsBlur;
  }

  @override
  Future<WindowProps?> captureNormalGeometry(WindowProps current) async {
    final capturedBounds = bounds;
    final capturedGate = geometryGate;
    final capturedIsNormal = isNormal;
    await capturedGate?.future;
    if (!capturedIsNormal) {
      return null;
    }
    return current.copyWith(
      width: capturedBounds.width,
      height: capturedBounds.height,
      left: supportsPosition ? capturedBounds.left : current.left,
      top: supportsPosition ? capturedBounds.top : current.top,
    );
  }

  @override
  Future<void> close() async {}

  @override
  void forceExit() {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> toggle() async {}

  @override
  Future<void> show() async {
    shows++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _RecordingWindowPort window;
  late List<MethodCall> windowCalls;
  late bool isAlwaysOnTop;
  late bool isMaximized;
  late bool isFullScreen;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    _RecordingSystemAction.calls.clear();
    windowCalls = [];
    isAlwaysOnTop = false;
    isMaximized = false;
    isFullScreen = false;
    window = _RecordingWindowPort();
    windowPort = window;
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        systemActionProvider.overrideWith(_RecordingSystemAction.new),
      ],
    );
    globalState.container = container;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          windowCalls.add(call);
          if (call.method == 'setAlwaysOnTop') {
            isAlwaysOnTop = call.arguments['value'] as bool;
          }
          return switch (call.method) {
            'isAlwaysOnTop' => isAlwaysOnTop,
            'isMaximized' => isMaximized,
            'isFullScreen' => isFullScreen,
            _ => null,
          };
        });
  });

  tearDown(() {
    windowPort = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, null);
    container.dispose();
  });

  Future<WindowListener> pumpWindowManager(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: WindowManager(child: SizedBox.shrink())),
      ),
    );
    await tester.pump();
    return tester.state(find.byType(WindowManager)) as WindowListener;
  }

  Future<void> settleWindowGeometry(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
  }

  testWidgets('renders its child untouched', (tester) async {
    await pumpWindowManager(tester);

    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('a close request is delegated to the system action', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);

    listener.onWindowClose();
    await tester.pumpAndSettle();

    expect(_RecordingSystemAction.calls, ['close']);
  });

  testWidgets('a terminate request is delegated to the system action', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);

    listener.onWindowShouldTerminate();
    await tester.pumpAndSettle();

    expect(_RecordingSystemAction.calls, ['exit']);
  });

  testWidgets('moving the window records its new position', (tester) async {
    final listener = await pumpWindowManager(tester);
    window.bounds = const Rect.fromLTWH(120, 64, 1000, 800);

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    final setting = container.read(windowSettingProvider);
    expect(setting.left, 120);
    expect(setting.top, 64);
  });

  testWidgets('resizing the window records its new size', (tester) async {
    final listener = await pumpWindowManager(tester);
    window.bounds = const Rect.fromLTWH(0, 0, 1280, 960);

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    final setting = container.read(windowSettingProvider);
    expect(setting.width, 1280);
    expect(setting.height, 960);
  });

  testWidgets('minimize and restore survive without a visible window', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);

    listener.onWindowMinimize();
    listener.onWindowRestore();
    listener.onWindowFocus();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('sidebar blur', () {
    setUp(() => feature = const Feature(sidebarBlur: true));

    tearDown(() => feature = const Feature());

    testWidgets('a disabled feature drops the backdrop despite the setting', (
      tester,
    ) async {
      feature = const Feature();
      await pumpWindowManager(tester);
      await tester.pumpAndSettle();

      expect(container.read(themeSettingProvider).sidebarBlur, isTrue);
      expect(window.blurRequests.single.enabled, isFalse);
      expect(container.read(windowBlurProvider), isFalse);
    });

    testWidgets('is applied on start and mirrored into the provider', (
      tester,
    ) async {
      await pumpWindowManager(tester);
      await tester.pumpAndSettle();

      expect(window.blurRequests, hasLength(1));
      expect(window.blurRequests.single.enabled, isTrue);
      expect(window.blurRequests.single.brightness, Brightness.dark);
      expect(container.read(windowBlurProvider), isTrue);
    });

    testWidgets('a platform without a backdrop leaves the provider off', (
      tester,
    ) async {
      window.supportsBlur = false;
      await pumpWindowManager(tester);
      await tester.pumpAndSettle();

      expect(container.read(windowBlurProvider), isFalse);
    });

    testWidgets('turning the setting off drops the backdrop', (tester) async {
      await pumpWindowManager(tester);
      await tester.pumpAndSettle();

      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(sidebarBlur: false));
      await tester.pumpAndSettle();

      expect(window.blurRequests.last.enabled, isFalse);
      expect(container.read(windowBlurProvider), isFalse);
    });

    testWidgets('a theme mode change reapplies the effect', (tester) async {
      await pumpWindowManager(tester);
      await tester.pumpAndSettle();

      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      expect(window.blurRequests.last.enabled, isTrue);
      expect(window.blurRequests.last.brightness, Brightness.light);
      expect(container.read(windowBlurProvider), isTrue);
    });
  });

  testWidgets('an activate request shows the window through the port', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);

    listener.onWindowActivate();
    listener.onWindowFocus();
    await tester.pump();

    expect(window.shows, 1);
  });

  testWidgets('a move that resolves after disposal is dropped', (tester) async {
    final listener = await pumpWindowManager(tester);
    window.bounds = const Rect.fromLTWH(500, 500, 640, 480);
    final gate = Completer<void>();
    window.geometryGate = gate;

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(container.read(windowSettingProvider).left, isNot(500));
  });

  testWidgets('a resize that resolves after disposal is dropped', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);
    window.bounds = const Rect.fromLTWH(0, 0, 640, 480);
    final gate = Completer<void>();
    window.geometryGate = gate;

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(container.read(windowSettingProvider).width, isNot(640));
  });

  testWidgets('non-normal window bounds are not persisted', (tester) async {
    final listener = await pumpWindowManager(tester);
    window.bounds = const Rect.fromLTWH(0, 0, 1920, 1080);
    window.isNormal = false;

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    expect(container.read(windowSettingProvider).width, isNot(1920));
  });

  testWidgets('Wayland geometry keeps compositor-owned position', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);
    container.read(windowSettingProvider.notifier).value = const WindowProps(
      width: 800,
      height: 600,
      left: 40,
      top: 32,
    );
    window.bounds = const Rect.fromLTWH(0, 0, 1200, 900);
    window.supportsPosition = false;

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    expect(
      container.read(windowSettingProvider),
      const WindowProps(width: 1200, height: 900, left: 40, top: 32),
    );
  });

  testWidgets('a newer geometry event supersedes an older async capture', (
    tester,
  ) async {
    final listener = await pumpWindowManager(tester);
    final firstGate = Completer<void>();
    window.bounds = const Rect.fromLTWH(10, 10, 640, 480);
    window.geometryGate = firstGate;

    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    window.bounds = const Rect.fromLTWH(80, 64, 1200, 900);
    window.geometryGate = null;
    listener.onWindowGeometryChanged();
    await settleWindowGeometry(tester);

    firstGate.complete();
    await tester.pumpAndSettle();

    expect(
      container.read(windowSettingProvider),
      const WindowProps(width: 1200, height: 900, left: 80, top: 64),
    );
  });

  group('WindowHeaderContainer', () {
    testWidgets('wraps its child', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            includeNavigatorKey: false,
            child: WindowHeaderContainer(child: Text('body')),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('body'), findsOneWidget);
    });
  });

  group('WindowHeaderActions', () {
    late ValueNotifier<WindowCaptionState> caption;
    late List<String> pressed;

    setUp(() {
      caption = ValueNotifier(const WindowCaptionState());
      pressed = [];
    });

    tearDown(() {
      caption.dispose();
    });

    Future<void> pumpActions(WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: WindowHeaderActions(
            state: caption,
            onPin: () => pressed.add('pin'),
            onMinimize: () => pressed.add('minimize'),
            onMaximize: () => pressed.add('maximize'),
            onClose: () => pressed.add('close'),
          ),
        ),
      );
      await tester.pump();
    }

    Finder glyph(CaptionGlyph glyph) => find.byWidgetPredicate(
      (widget) => widget is CaptionIcon && widget.glyph == glyph,
    );

    String tooltipOf(WidgetTester tester, Finder icon) {
      return tester
          .widget<IconButton>(
            find.ancestor(of: icon, matching: find.byType(IconButton)),
          )
          .tooltip!;
    }

    testWidgets('names every button for a screen reader', (tester) async {
      await pumpActions(tester);

      expect(
        tooltipOf(tester, find.byGlyph(AppGlyphs.pin)),
        currentAppLocalizations.pinWindow,
      );
      expect(
        tooltipOf(tester, glyph(CaptionGlyph.minimize)),
        currentAppLocalizations.minimize,
      );
      expect(
        tooltipOf(tester, glyph(CaptionGlyph.maximize)),
        currentAppLocalizations.maximize,
      );
      expect(
        tooltipOf(tester, glyph(CaptionGlyph.close)),
        currentAppLocalizations.close,
      );
    });

    testWidgets('the pin and maximize labels follow their state', (
      tester,
    ) async {
      await pumpActions(tester);

      caption.value = const WindowCaptionState(
        isPinned: true,
        isMaximized: true,
      );
      await tester.pump();

      expect(
        tooltipOf(tester, find.byGlyph(AppGlyphs.pin)),
        currentAppLocalizations.unpinWindow,
      );
      expect(
        tooltipOf(tester, glyph(CaptionGlyph.restore)),
        currentAppLocalizations.unmaximize,
      );
    });

    testWidgets('a fullscreen window offers to leave fullscreen first', (
      tester,
    ) async {
      await pumpActions(tester);

      caption.value = const WindowCaptionState(
        isMaximized: true,
        isFullScreen: true,
      );
      await tester.pump();

      expect(glyph(CaptionGlyph.maximize), findsNothing);
      expect(
        tooltipOf(tester, glyph(CaptionGlyph.restore)),
        currentAppLocalizations.exitFullScreen,
      );
    });

    testWidgets('each button reports its own press', (tester) async {
      await pumpActions(tester);

      await tester.tap(find.byGlyph(AppGlyphs.pin));
      await tester.tap(glyph(CaptionGlyph.minimize));
      await tester.tap(glyph(CaptionGlyph.maximize));
      await tester.tap(glyph(CaptionGlyph.close));
      await tester.pump();

      expect(pressed, ['pin', 'minimize', 'maximize', 'close']);
    });
  });

  group('WindowCaptionController', () {
    Future<void> emitWindowEvent(String name) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            _windowChannel.name,
            _windowChannel.codec.encodeMethodCall(
              MethodCall('onEvent', {'name': name}),
            ),
            (_) {},
          );
    }

    Future<WindowCaptionController> pumpController(WidgetTester tester) async {
      final caption = WindowCaptionController();
      addTearDown(caption.dispose);
      await tester.pump();
      return caption;
    }

    List<String> methodsOf(List<MethodCall> calls) =>
        calls.map((call) => call.method).toList();

    testWidgets('starts from the state the window already has', (tester) async {
      isAlwaysOnTop = true;
      isMaximized = true;

      final caption = await pumpController(tester);

      expect(
        caption.value,
        const WindowCaptionState(isPinned: true, isMaximized: true),
      );
    });

    testWidgets('a maximize request only shows once the window reports it', (
      tester,
    ) async {
      final caption = await pumpController(tester);
      windowCalls.clear();

      await caption.toggleMaximized();
      await tester.pump();

      expect(methodsOf(windowCalls), [
        'isFullScreen',
        'isMaximized',
        'maximize',
      ]);
      expect(caption.value.isMaximized, isFalse);

      await emitWindowEvent('maximize');

      expect(caption.value.isMaximized, isTrue);
    });

    testWidgets('a maximized window is asked to restore', (tester) async {
      isMaximized = true;
      final caption = await pumpController(tester);
      windowCalls.clear();

      await caption.toggleMaximized();
      await emitWindowEvent('unmaximize');

      expect(methodsOf(windowCalls), contains('unmaximize'));
      expect(caption.value.isMaximized, isFalse);
    });

    testWidgets('a fullscreen window leaves fullscreen instead of toggling', (
      tester,
    ) async {
      isFullScreen = true;
      isMaximized = true;
      final caption = await pumpController(tester);
      windowCalls.clear();

      await caption.toggleMaximized();

      expect(methodsOf(windowCalls), isNot(contains('maximize')));
      expect(methodsOf(windowCalls), isNot(contains('unmaximize')));
      final leave = windowCalls.singleWhere(
        (call) => call.method == 'setFullScreen',
      );
      expect(leave.arguments, {'value': false});

      await emitWindowEvent('leave-full-screen');

      expect(
        caption.value,
        const WindowCaptionState(isMaximized: true, isFullScreen: false),
      );
    });

    testWidgets('changes made by the window manager itself are mirrored', (
      tester,
    ) async {
      final caption = await pumpController(tester);

      await emitWindowEvent('maximize');
      expect(caption.value.isMaximized, isTrue);

      await emitWindowEvent('enter-full-screen');
      expect(caption.value.isFullScreen, isTrue);

      await emitWindowEvent('leave-full-screen');
      await emitWindowEvent('unmaximize');
      expect(caption.value, const WindowCaptionState());
    });

    testWidgets('pinning reads the applied state back', (tester) async {
      final caption = await pumpController(tester);

      await caption.togglePin();
      expect(caption.value.isPinned, isTrue);

      await caption.togglePin();
      expect(caption.value.isPinned, isFalse);
    });

    testWidgets('disposing stops listening to the window', (tester) async {
      final caption = WindowCaptionController();
      await tester.pump();
      expect(desktopWindow.listeners, contains(caption));

      caption.dispose();

      expect(desktopWindow.listeners, isNot(contains(caption)));
    });
  });
}
