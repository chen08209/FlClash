import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/lib.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

class _FakeService implements Service {
  _FakeService();

  final calls = <String>[];

  String initError = '';
  String syncError = '';
  bool shutdownResult = true;
  bool startResult = true;
  bool stopResult = true;
  CoreMethodResponse? Function(CoreMethodCall call)? onInvokeMethod;

  final invokedCalls = <CoreMethodCall>[];

  @override
  Future<String> init() async {
    calls.add('init');
    return initError;
  }

  @override
  Future<String> syncState(SharedState state) async {
    calls.add('syncState');
    return syncError;
  }

  @override
  Future<bool> shutdown() async {
    calls.add('shutdown');
    return shutdownResult;
  }

  @override
  Future<bool> start() async {
    calls.add('start');
    return startResult;
  }

  @override
  Future<bool> stop() async {
    calls.add('stop');
    return stopResult;
  }

  @override
  Future<CoreMethodResponse> invokeMethod(CoreMethodCall call) async {
    calls.add('invokeMethod:${call.method.wireName}');
    invokedCalls.add(call);
    final response = onInvokeMethod?.call(call);
    if (response == null) {
      throw const CoreMethodException(code: 'no_response', message: '');
    }
    return response;
  }

  @override
  Future<DateTime?> getRunTime() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _FakeService service;
  late CoreLib lib;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    service = _FakeService();
    lib = CoreLib.scoped(service);
  });

  tearDown(() {
    container.dispose();
    CoreLib.resetInstance();
  });

  group('start', () {
    test('initializes, connects and syncs shared state', () async {
      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(result.revision, 1);
      expect(service.calls, ['init', 'syncState']);
    });

    test('coalesces a second start while already connected', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(result.revision, 2);
      expect(service.calls, isEmpty);
    });

    test('an initialization error leaves the handler unconnected', () async {
      service.initError = 'init boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'init boom'),
        ),
      );
      expect(service.calls, ['init']);

      service.initError = '';
      final retry = await lib.start();
      expect(retry.outcome, CoreLifecycleOutcome.applied);
    });

    test('a sync error shuts the service down and reopens the gate', () async {
      service.syncError = 'sync boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'sync boom'),
        ),
      );
      expect(service.calls, ['init', 'syncState', 'shutdown']);

      service.syncError = '';
      service.calls.clear();
      final retry = await lib.start();

      expect(retry.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['init', 'syncState']);
    });
  });

  group('stop', () {
    test('coalesces when there is nothing connected', () async {
      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(service.calls, isEmpty);
    });

    test('shuts the service down once connected', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['shutdown']);
    });

    test('a failed shutdown throws but still closes the gate', () async {
      await lib.start();
      service.shutdownResult = false;

      await expectLater(lib.stop(), throwsA(isA<StateError>()));

      service.shutdownResult = true;
      final again = await lib.stop();
      expect(again.outcome, CoreLifecycleOutcome.coalesced);
    });
  });

  test('restart stops before starting again', () async {
    await lib.start();
    service.calls.clear();

    final result = await lib.restart();

    expect(result.outcome, CoreLifecycleOutcome.applied);
    expect(service.calls, ['shutdown', 'init', 'syncState']);
  });

  group('close', () {
    test('is terminal and rejects later lifecycle intents', () async {
      await lib.start();

      final result = await lib.close();
      expect(result.outcome, CoreLifecycleOutcome.applied);

      await expectLater(lib.start(), throwsA(isA<StateError>()));
      await expectLater(lib.stop(), throwsA(isA<StateError>()));
    });

    test('runs the shutdown once no matter how often it is called', () async {
      await lib.start();
      service.calls.clear();

      final first = lib.close();
      final second = lib.close();

      expect(identical(first, second), isTrue);
      await first;
      await second;

      expect(service.calls, ['shutdown']);
    });
  });

  group('listeners', () {
    test('a listener start is answered by the service', () async {
      await lib.start();
      service.onInvokeMethod = (_) => const CoreMethodResponse(id: '1');

      await lib.startListener();

      service.startResult = false;
      await expectLater(
        lib.startListener(),
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.code,
            'code',
            'service_refused',
          ),
        ),
      );

      service.startResult = true;
      service.onInvokeMethod = (_) => null;
      await lib.startListener();
      expect(service.calls.last, 'start');
    });

    test('a listener stop is answered by the service', () async {
      await lib.start();
      service.onInvokeMethod = (_) => null;

      await lib.stopListener();

      service.stopResult = false;
      await expectLater(
        lib.stopListener(),
        throwsA(isA<CoreMethodException>()),
      );
    });

    test('a listener command the Core refuses still fails', () async {
      await lib.start();
      service.onInvokeMethod = (call) => CoreMethodResponse(
        id: call.id,
        error: const CoreMethodError(code: 'core_error', message: 'busy'),
      );

      await expectLater(
        lib.startListener(),
        throwsA(isA<CoreMethodException>()),
      );
      expect(service.calls, isNot(contains('start')));
    });

    test('stopListener stops the service before the core listener', () async {
      await lib.start();
      service.onInvokeMethod = (_) => const CoreMethodResponse(id: '1');
      service.calls.clear();

      await lib.stopListener();
      expect(service.calls, ['stop', 'invokeMethod:listener.stop']);
    });
  });

  group('invokeMethod', () {
    test('assigns an increasing call id per request', () async {
      await lib.start();
      service.onInvokeMethod = (call) =>
          CoreMethodResponse(id: call.id, result: 'ok');

      await lib.invokeMethod(method: CoreMethod.proxyList);
      await lib.invokeMethod(method: CoreMethod.proxyList);

      expect(service.invokedCalls.map((call) => call.id), ['1', '2']);
    });

    test('unwraps the response payload', () async {
      await lib.start();
      service.onInvokeMethod = (call) =>
          CoreMethodResponse(id: call.id, result: 'payload');

      expect(await lib.invokeMethod(method: CoreMethod.proxyList), 'payload');
    });

    test('fails when the service answers nothing', () async {
      await lib.start();
      service.onInvokeMethod = (_) => null;

      await expectLater(
        lib.invokeMethod(method: CoreMethod.proxyList),
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.code,
            'code',
            'no_response',
          ),
        ),
      );
    });

    testWidgets('gives up instead of hanging when no connection arrives', (
      tester,
    ) async {
      Object? failure;
      final pending = lib
          .invokeMethod(method: CoreMethod.proxyList)
          .catchError((Object error) => failure = error);

      await tester.pump(const Duration(seconds: 11));
      await pending;

      expect(
        failure,
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'core_unavailable',
        ),
      );
      expect(service.calls, isEmpty);
    });
  });
}
