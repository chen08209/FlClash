import 'dart:async';

import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/actions/system_exit.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class TestSystemAction extends SystemAction {
  final List<String> calls = [];
  final List<bool> cleanupNeedSave = [];
  Completer<void>? closeCoreGate;
  Object? cleanupError;
  Duration watchdog = const Duration(hours: 1);

  @override
  Duration get exitWatchdogDuration => watchdog;

  @override
  Future<void> cleanupExitResources(bool needSave) async {
    calls.add('cleanup');
    cleanupNeedSave.add(needSave);
    final error = cleanupError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }

  @override
  Future<void> closeWindow() async => calls.add('window');

  @override
  Future<void> closeCore() async {
    calls.add('core');
    final gate = closeCoreGate;
    if (gate != null) {
      await gate.future;
    }
  }

  @override
  Future<void> exitApplication() async => calls.add('exit');
}

void main() {
  test('coalesces repeated exit requests and runs cleanup once', () async {
    final closeCoreCompleter = Completer<void>();
    final calls = <String>[];
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(hours: 1),
      closeWindow: () async => calls.add('window'),
      closeCore: () async {
        calls.add('core');
        await closeCoreCompleter.future;
      },
      exitApplication: () async => calls.add('exit'),
    );

    final first = coordinator.exit(cleanup: () async => calls.add('cleanup'));
    final second = coordinator.exit(
      cleanup: () async => calls.add('unexpected cleanup'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(identical(first, second), isTrue);
    expect(calls, ['cleanup', 'window', 'core']);

    closeCoreCompleter.complete();
    await Future.wait([first, second]);

    expect(calls, ['cleanup', 'window', 'core', 'exit']);
  });

  test('watchdog and normal completion share one application exit', () async {
    final closeCoreCompleter = Completer<void>();
    var exitCount = 0;
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(milliseconds: 1),
      closeWindow: () async {},
      closeCore: () => closeCoreCompleter.future,
      exitApplication: () async => exitCount++,
    );

    final operation = coordinator.exit(cleanup: () async {});
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(exitCount, 1);
    closeCoreCompleter.complete();
    await operation;
    expect(exitCount, 1);
  });

  test('cleanup failure does not skip window or Core shutdown', () async {
    final calls = <String>[];
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(hours: 1),
      closeWindow: () async => calls.add('window'),
      closeCore: () async => calls.add('core'),
      exitApplication: () async => calls.add('exit'),
    );

    await expectLater(
      coordinator.exit(
        cleanup: () async {
          calls.add('cleanup');
          throw StateError('cleanup failed');
        },
      ),
      throwsStateError,
    );

    expect(calls, ['cleanup', 'window', 'core', 'exit']);
  });

  group('SystemAction exit orchestration', () {
    late TestSystemAction action;
    late ProviderContainer container;

    setUp(() {
      action = TestSystemAction();
      container = ProviderContainer(
        overrides: [systemActionProvider.overrideWith(() => action)],
      );
      globalState.container = container;
      container.read(systemActionProvider.notifier);
    });

    tearDown(() {
      final gate = action.closeCoreGate;
      if (gate != null && !gate.isCompleted) {
        gate.complete();
      }
      container.dispose();
    });

    SystemAction notifier() => container.read(systemActionProvider.notifier);

    test('runs cleanup, window, Core and application exit in order', () async {
      await notifier().handleExit();

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
      expect(action.cleanupNeedSave, [false]);
    });

    test('forwards the save request to resource cleanup', () async {
      await notifier().handleExit(true);

      expect(action.cleanupNeedSave, [true]);
    });

    test('concurrent exit requests share one shutdown', () async {
      action.closeCoreGate = Completer<void>();

      final first = notifier().handleExit();
      final second = notifier().handleExit(true);
      await Future<void>.delayed(Duration.zero);

      expect(action.calls, ['cleanup', 'window', 'core']);

      action.closeCoreGate!.complete();
      await Future.wait([first, second]);

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
      expect(action.cleanupNeedSave, [false]);
    });

    test('a later exit request never restarts a finished shutdown', () async {
      await notifier().handleExit();
      await notifier().handleExit();

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
    });

    test(
      'the watchdog exits the application when Core shutdown hangs',
      () async {
        action.watchdog = const Duration(milliseconds: 1);
        action.closeCoreGate = Completer<void>();

        final operation = notifier().handleExit();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(action.calls, ['cleanup', 'window', 'core', 'exit']);

        action.closeCoreGate!.complete();
        await operation;

        expect(
          action.calls.where((call) => call == 'exit').length,
          1,
          reason: 'the watchdog and normal completion share one exit',
        );
      },
    );

    test('a cleanup failure still closes the window, Core and app', () async {
      action.cleanupError = StateError('cleanup failed');

      await expectLater(notifier().handleExit(), throwsStateError);

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
    });
  });

  group('SystemAction setting toggles', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      globalState.container = container;
    });

    tearDown(() => container.dispose());

    test('updateTun flips the patched Core tun flag', () {
      final before = container.read(patchClashConfigProvider).tun.enable;

      container.read(systemActionProvider.notifier).updateTun();

      expect(container.read(patchClashConfigProvider).tun.enable, !before);
    });

    test('updateSystemProxy flips the system proxy flag', () {
      final before = container.read(networkSettingProvider).systemProxy;

      container.read(systemActionProvider.notifier).updateSystemProxy();

      expect(container.read(networkSettingProvider).systemProxy, !before);
    });

    test('updateAutoLaunch flips the auto launch flag', () {
      final before = container.read(appSettingProvider).autoLaunch;

      container.read(systemActionProvider.notifier).updateAutoLaunch();

      expect(container.read(appSettingProvider).autoLaunch, !before);
    });
  });
}
