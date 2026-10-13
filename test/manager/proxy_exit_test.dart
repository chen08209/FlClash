import 'dart:async';
import 'dart:io';

import 'package:fl_clash/manager/proxy_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _ExitAction extends SystemAction {
  final Completer<void> closingCore = Completer<void>();

  @override
  Duration get exitWatchdogDuration => const Duration(hours: 1);

  @override
  Future<void> closeWindow() async {}

  @override
  Future<void> closeCore() => closingCore.future;

  @override
  Future<void> exitApplication() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpProxyManager(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ProxyManager(child: SizedBox(key: Key('child'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void enableSystemProxy({required bool running, int mixedPort = 7890}) {
    container.read(networkSettingProvider.notifier).value = const NetworkProps()
        .copyWith(systemProxy: true);
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig().copyWith(mixedPort: mixedPort);
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
  }

  testWidgets(
    'exit leaves the system proxy stopped after pending and later updates',
    (tester) async {
      final firstStop = Completer<void>();
      final calls = <String>[];
      var enabled = false;
      final binding = TestDefaultBinaryMessengerBinding.instance;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('proxy'),
        (call) async {
          calls.add(call.method);
          if (calls.length == 1) {
            await firstStop.future;
          }
          enabled = call.method == 'StartProxy';
          return true;
        },
      );
      addTearDown(() {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('proxy'),
          null,
        );
      });
      container.dispose();
      final action = _ExitAction();
      container = ProviderContainer(
        overrides: [systemActionProvider.overrideWith(() => action)],
      );
      globalState.container = container;
      container.read(systemActionProvider.notifier);

      await pumpProxyManager(tester);
      expect(calls, ['StopProxy']);
      enableSystemProxy(running: true);
      await tester.pump();
      final exiting = action.handleExit(false);
      await tester.pump();
      firstStop.complete();
      await tester.pump();
      action.closingCore.complete();
      await exiting;
      await tester.pump();

      expect(calls, ['StopProxy', 'StopProxy']);
      expect(enabled, isFalse);
      enableSystemProxy(running: false);
      await tester.pump();
      enableSystemProxy(running: true);
      await tester.pumpAndSettle();
      expect(calls, ['StopProxy', 'StopProxy']);
      expect(enabled, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    skip: !Platform.isWindows,
  );
}
