import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/core_manager.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _crash = CoreEvent(type: CoreEventType.crash, data: 'boom');

_MockCoreHandlerInterface _coreInterface() {
  final coreInterface = _MockCoreHandlerInterface();
  when(() => coreInterface.startLog()).thenAnswer((_) {});
  when(() => coreInterface.stopLog()).thenAnswer((_) {});
  return coreInterface;
}

Future<ProviderContainer> _pumpCoreManager(
  WidgetTester tester,
  CoreHandlerInterface coreInterface,
) async {
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(
        CoreController.scoped(coreInterface),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        child: StatusManager(child: CoreManager(child: SizedBox())),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('duplicate crash events disconnect the core only once', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.stopLog()).thenAnswer((_) {});
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(coreInterface),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CoreManager(child: SizedBox())),
      ),
    );
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    coreEventManager.sendEvent(_crash);
    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(transitions, [CoreStatus.disconnected]);
    verifyNever(() => coreInterface.stop());

    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('a crash while the app is visible surfaces the message', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(find.text('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a crash is ignored when the core is not connected', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);

    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.connecting);
    expect(transitions, isEmpty);
    expect(find.text('boom'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the log stream follows the openLogs setting', (tester) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);

    verify(() => coreInterface.stopLog()).called(1);
    verifyNever(() => coreInterface.startLog());

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    verify(() => coreInterface.startLog()).called(1);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: false));
    await tester.pump();

    verify(() => coreInterface.stopLog()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('core logs are recorded for the logs view', (tester) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);

    coreEventManager.sendEvent(
      const CoreEvent(
        type: CoreEventType.log,
        data: {'LogLevel': 'info', 'Payload': 'hello'},
      ),
    );
    await tester.pump();

    expect(
      container.read(logsProvider).list.map((log) => log.payload),
      contains('hello'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
