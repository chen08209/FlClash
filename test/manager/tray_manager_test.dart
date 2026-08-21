import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/tray_manager.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tray/tray.dart';

import '../helpers/test_profiles.dart';

const _trayChannel = MethodChannel('tray');
const _windowChannel = MethodChannel('window_manager');
const _codec = StandardMethodCodec();

class _RecordingSystemAction extends SystemAction {
  static int updateTrayCount = 0;

  @override
  Future<void> updateTray() async {
    updateTrayCount++;
  }
}

class _FailingSystemAction extends SystemAction {
  @override
  Future<void> updateTray() async {
    throw StateError('tray boom');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late List<String> windowCalls;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    _RecordingSystemAction.updateTrayCount = 0;
    windowCalls = <String>[];
    Tray.instance.resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trayChannel, (call) async => true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowChannel, (call) async {
          windowCalls.add(call.method);
          return call.method == 'isMinimized' ? false : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_trayChannel, null)
      ..setMockMethodCallHandler(_windowChannel, null);
    container.dispose();
  });

  Future<void> emitTrayEvent(String event, [Object? arguments]) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          _trayChannel.name,
          _codec.encodeMethodCall(MethodCall(event, arguments)),
          null,
        );
  }

  Future<void> pumpTrayManager(
    WidgetTester tester, {
    SystemAction Function()? systemAction,
  }) async {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        systemActionProvider.overrideWith(
          systemAction ?? _RecordingSystemAction.new,
        ),
      ],
    );
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrayManager(child: SizedBox.shrink())),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders its child untouched', (tester) async {
    await pumpTrayManager(tester);

    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('activating the icon brings the window back', (tester) async {
    await pumpTrayManager(tester);
    windowCalls.clear();

    await emitTrayEvent('onIconActivated');
    await tester.pumpAndSettle();

    expect(windowCalls, containsAll(<String>['show', 'focus']));
  });

  testWidgets('a menu request is forwarded to the tray', (tester) async {
    await pumpTrayManager(tester);

    await emitTrayEvent('onMenuRequested');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a tray state change pushes the tray forward', (tester) async {
    await pumpTrayManager(tester);
    _RecordingSystemAction.updateTrayCount = 0;

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mixedPort: state.mixedPort + 1));
    await tester.pumpAndSettle();

    expect(_RecordingSystemAction.updateTrayCount, 1);
  });

  testWidgets('an unchanged tray state does not touch the tray', (
    tester,
  ) async {
    await pumpTrayManager(tester);
    _RecordingSystemAction.updateTrayCount = 0;

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mixedPort: state.mixedPort));
    await tester.pumpAndSettle();

    expect(_RecordingSystemAction.updateTrayCount, 0);
  });

  testWidgets('a failed tray update is reported instead of thrown', (
    tester,
  ) async {
    await pumpTrayManager(tester, systemAction: _FailingSystemAction.new);

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mixedPort: state.mixedPort + 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('tray events stop being handled after disposal', (tester) async {
    await pumpTrayManager(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    windowCalls.clear();

    await emitTrayEvent('onIconActivated');
    await tester.pumpAndSettle();

    expect(windowCalls, isEmpty);
  });
}
