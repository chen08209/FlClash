import 'dart:async';

import 'package:fl_clash/core/desktop/lifecycle.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/core_mocks.dart';

final class _MockLifecycle extends Mock
    implements DesktopCoreLifecycleController {}

void main() {
  late _MockLifecycle lifecycle;
  late MockCoreApi api;
  late StreamController<DesktopCoreFailure> crashes;
  late CoreService service;

  const result = CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  setUp(() {
    lifecycle = _MockLifecycle();
    api = MockCoreApi();
    crashes = StreamController<DesktopCoreFailure>.broadcast();
    when(() => lifecycle.crashEvents).thenAnswer((_) => crashes.stream);
    when(() => lifecycle.start()).thenAnswer((_) async => result);
    when(() => lifecycle.restart()).thenAnswer((_) async => result);
    when(() => lifecycle.stop()).thenAnswer((_) async => result);
    when(() => lifecycle.close()).thenAnswer((_) async => result);
    service = CoreService.forTesting(lifecycle: lifecycle, api: api);
  });

  tearDown(() async {
    await service.close();
    await crashes.close();
  });

  test('exposes the API it was given', () {
    expect(service.api, same(api));
  });

  test(
    'delegates lifecycle commands without owning platform details',
    () async {
      expect(await service.start(), same(result));
      expect(await service.restart(), same(result));
      expect(await service.stop(), same(result));

      verify(() => lifecycle.start()).called(1);
      verify(() => lifecycle.restart()).called(1);
      verify(() => lifecycle.stop()).called(1);
    },
  );

  test('opens and closes the Core listeners through the API', () async {
    when(() => api.startEngine()).thenAnswer((_) async {});
    when(() => api.stopEngine()).thenAnswer((_) async {});

    await service.startListener();
    await service.stopListener();

    verify(() => api.startEngine()).called(1);
    verify(() => api.stopEngine()).called(1);
  });

  test('reports a lost session in words, with the cause it has', () async {
    final messages = <String>[];
    final logs = <String>[];
    final print = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = print);
    final subscription = service.crashes.listen(messages.add);

    crashes.add(
      const DesktopCoreFailure(
        code: 'unexpected_disconnect',
        phase: DesktopCorePhase.running,
        revision: 2,
        cause: 'pipe closed',
      ),
    );
    crashes.add(
      const DesktopCoreFailure(
        code: 'unexpected_disconnect',
        phase: DesktopCorePhase.running,
        revision: 3,
        sessionId: 'session-token',
        owner: CoreProcessOwner.helper,
        pid: 4242,
        connectionGeneration: 7,
      ),
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(messages, [
      'The app lost its connection to the core: pipe closed',
      'The app lost its connection to the core',
    ]);
    expect(
      logs.last,
      allOf(
        contains('unexpected_disconnect'),
        contains('pid: 4242'),
        contains('generation: 7'),
        isNot(contains('session-token')),
      ),
    );
  });

  test('close coalesces lifecycle cleanup', () async {
    final first = service.close();
    final second = service.close();

    expect(await first, same(result));
    expect(await second, same(result));
    verify(() => lifecycle.close()).called(1);
  });
}
