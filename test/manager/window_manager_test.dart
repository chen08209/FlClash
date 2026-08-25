import 'dart:async';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart' show WindowListener;

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _windowChannel = MethodChannel('window_manager');

class _RecordingSystemAction extends SystemAction {
  static final calls = <String>[];

  @override
  Future<void> handleClose([bool exit = true]) async {
    calls.add('close');
  }

  @override
  Future<void> handleExit([bool needSave = false]) async {
    calls.add('exit');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late Rect bounds;
  Completer<void>? boundsGate;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    _RecordingSystemAction.calls.clear();
    bounds = const Rect.fromLTWH(0, 0, 1000, 800);
    boundsGate = null;
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        systemActionProvider.overrideWith(_RecordingSystemAction.new),
      ],
    );
    globalState.container = container;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          if (call.method == 'getBounds') {
            await boundsGate?.future;
            return <String, double>{
              'x': bounds.left,
              'y': bounds.top,
              'width': bounds.width,
              'height': bounds.height,
            };
          }
          if (call.method == 'isMaximized' || call.method == 'isAlwaysOnTop') {
            return false;
          }
          return null;
        });
  });

  tearDown(() {
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
    bounds = const Rect.fromLTWH(120, 64, 1000, 800);

    listener.onWindowMoved();
    await tester.pumpAndSettle();

    final setting = container.read(windowSettingProvider);
    expect(setting.left, 120);
    expect(setting.top, 64);
  });

  testWidgets('resizing the window records its new size', (tester) async {
    final listener = await pumpWindowManager(tester);
    bounds = const Rect.fromLTWH(0, 0, 1280, 960);

    listener.onWindowResized();
    await tester.pumpAndSettle();

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

  testWidgets('a move that resolves after disposal is dropped', (tester) async {
    final listener = await pumpWindowManager(tester);
    bounds = const Rect.fromLTWH(500, 500, 640, 480);
    final gate = Completer<void>();
    boundsGate = gate;

    listener.onWindowMoved();
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
    bounds = const Rect.fromLTWH(0, 0, 640, 480);
    final gate = Completer<void>();
    boundsGate = gate;

    listener.onWindowResized();
    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(container.read(windowSettingProvider).width, isNot(640));
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

  testWidgets('AppIcon renders the bundled application icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppIcon()));

    expect(find.byType(Image), findsOneWidget);
  });

  group('WindowHeaderActions', () {
    late ValueNotifier<bool> isPin;
    late ValueNotifier<bool> isMaximized;
    late List<String> pressed;

    setUp(() {
      isPin = ValueNotifier(false);
      isMaximized = ValueNotifier(false);
      pressed = [];
    });

    tearDown(() {
      isPin.dispose();
      isMaximized.dispose();
    });

    Future<void> pumpActions(WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: WindowHeaderActions(
            isPinNotifier: isPin,
            isMaximizedNotifier: isMaximized,
            onPin: () => pressed.add('pin'),
            onMinimize: () => pressed.add('minimize'),
            onMaximize: () => pressed.add('maximize'),
            onClose: () => pressed.add('close'),
          ),
        ),
      );
      await tester.pump();
    }

    String tooltipOf(WidgetTester tester, IconData icon) {
      return tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(icon),
              matching: find.byType(IconButton),
            ),
          )
          .tooltip!;
    }

    testWidgets('names every button for a screen reader', (tester) async {
      await pumpActions(tester);

      expect(
        tooltipOf(tester, Icons.push_pin_outlined),
        currentAppLocalizations.pinWindow,
      );
      expect(tooltipOf(tester, Icons.remove), currentAppLocalizations.minimize);
      expect(
        tooltipOf(tester, Icons.crop_square),
        currentAppLocalizations.maximize,
      );
      expect(tooltipOf(tester, Icons.close), currentAppLocalizations.close);
    });

    testWidgets('the pin and maximize labels follow their state', (
      tester,
    ) async {
      await pumpActions(tester);

      isPin.value = true;
      isMaximized.value = true;
      await tester.pump();

      expect(
        tooltipOf(tester, Icons.push_pin),
        currentAppLocalizations.unpinWindow,
      );
      expect(
        tooltipOf(tester, Icons.filter_none),
        currentAppLocalizations.unmaximize,
      );
    });

    testWidgets('each button reports its own press', (tester) async {
      await pumpActions(tester);

      await tester.tap(find.byIcon(Icons.push_pin_outlined));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.crop_square));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(pressed, ['pin', 'minimize', 'maximize', 'close']);
    });
  });
}
