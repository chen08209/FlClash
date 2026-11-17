import 'dart:async';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:mocktail/mocktail.dart';

class MockCoreApi extends Mock implements CoreApi {}

class MockCoreBackend extends Mock implements CoreBackend {}

typedef CoreMocks = ({
  MockCoreBackend backend,
  MockCoreApi api,
  CoreController controller,
});

/// The model-level helpers of [ModelApi] call [MockCoreApi], so stub the
/// underlying call.
CoreMocks coreMocks() {
  final backend = MockCoreBackend();
  final api = MockCoreApi();
  when(() => backend.api).thenReturn(api);
  when(() => backend.crashes).thenAnswer((_) => const Stream<String>.empty());
  return (
    backend: backend,
    api: api,
    controller: CoreController.scoped(backend),
  );
}

void stubSilentFeeds(MockCoreApi api) {
  registerFallbackValue(LogLevel.info);
  when(() => api.watchDns()).thenAnswer((_) => const Stream.empty());
  when(
    () => api.watchEvents(
      delays: any(named: 'delays'),
      state: any(named: 'state'),
    ),
  ).thenAnswer((_) => const Stream.empty());
  when(() => api.general()).thenAnswer(
    (_) async =>
        const GeneralStateDto(seq: 0, general: GeneralChange(), selections: {}),
  );
  when(
    () => api.watchConnections(maxBatchMs: any(named: 'maxBatchMs')),
  ).thenAnswer((_) => const Stream.empty());
  when(() => api.watchProxies()).thenAnswer((_) => const Stream.empty());
  when(() => api.watchRoute()).thenAnswer((_) => const Stream.empty());
  when(() => api.watchEngineStatus()).thenAnswer((_) => const Stream.empty());
  when(
    () => api.watchLogs(level: any(named: 'level')),
  ).thenAnswer((_) => const Stream.empty());
  when(
    () => api.watchTraffic(
      intervalMs: any(named: 'intervalMs'),
      onlyProxy: any(named: 'onlyProxy'),
    ),
  ).thenAnswer((_) => const Stream.empty());
}
