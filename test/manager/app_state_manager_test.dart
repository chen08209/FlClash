import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_profiles.dart';

class _Core extends Mock implements CoreHandlerInterface {}

class _Setup extends SetupAction {
  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    await preloadInvoke?.call();
    return true;
  }

  @override
  void resetCoreTraffic() {}
}

class _Common extends CommonAction {
  @override
  Future<void> updateTraffic() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _Core core;
  late SetupAction setup;
  late List<String> calls;
  Completer<bool>? startGate;

  setUp(() {
    calls = [];
    core = _Core();
    when(() => core.startListener()).thenAnswer((_) async {
      calls.add('start');
      return await startGate?.future ?? true;
    });
    when(() => core.stopListener()).thenAnswer((_) async {
      calls.add('stop');
      return true;
    });
  });

  tearDown(() {
    debouncer.cancel(FunctionTag.suspend);
    debouncer.cancel(FunctionTag.applyProfile);
    final gate = startGate;
    if (gate != null && !gate.isCompleted) {
      gate.complete(true);
    }
    startGate = null;
    container.dispose();
  });

  Future<void> mount(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(TestProfiles.new),
        setupActionProvider.overrideWith(_Setup.new),
        commonActionProvider.overrideWith(_Common.new),
        networkSettingProvider.overrideWithBuild(
          (_, _) => const NetworkProps(bypassPrivateRoute: false),
        ),
        excludeSSIDsProvider.overrideWithValue(const ['Office Wi-Fi']),
        safeModeProvider.overrideWithValue(false),
      ],
    );
    globalState.container = container;
    container.read(initProvider.notifier).value = true;
    container.read(currentSSIDProvider.notifier).value = 'Office Wi-Fi';
    setup = container.read(setupActionProvider.notifier);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppStateManager(child: SizedBox()),
      ),
    );
    await setup.setRunning(true);
  }

  testWidgets('a delayed Wi-Fi resume cannot restart after a manual stop', (
    tester,
  ) async {
    await mount(tester);
    container.read(currentSSIDProvider.notifier).value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await setup.setRunning(false);
    await tester.pump(const Duration(seconds: 1));

    expect(calls, ['stop']);
    expect(container.read(isStartProvider), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an in-flight Wi-Fi resume is serialized before a manual stop', (
    tester,
  ) async {
    await mount(tester);
    startGate = Completer<bool>();
    container.read(currentSSIDProvider.notifier).value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, ['start']);

    final stopping = setup.setRunning(false);
    await tester.pump();
    expect(calls, ['start']);
    startGate!.complete(true);
    await tester.pump();
    await stopping;

    expect(calls, ['start', 'stop']);
    expect(container.read(isStartProvider), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a delayed Wi-Fi update is cancelled when its manager unmounts', (
    tester,
  ) async {
    await mount(tester);
    container.read(currentSSIDProvider.notifier).value = null;
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    expect(calls, isEmpty);
    await setup.setRunning(false);
  });

  testWidgets('rapid Wi-Fi changes keep the latest suspend state', (
    tester,
  ) async {
    await mount(tester);
    container.read(currentSSIDProvider.notifier).value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    container.read(currentSSIDProvider.notifier).value = 'Office Wi-Fi';
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(calls, ['stop']);
    expect(container.read(isStartProvider), isTrue);
    await setup.setRunning(false);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
