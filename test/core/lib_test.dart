import 'dart:async';
import 'dart:isolate';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/core/api/channels/ffi_channel.dart';
import 'package:fl_clash/core/api/channels/method_channel_channel.dart';
import 'package:fl_clash/core/api/errors.dart';
import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/lib.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/core_mocks.dart';
import '../helpers/test_profiles.dart';

class _RefusingLibrary implements ConcordLibrary {
  @override
  bool initialize() => true;

  @override
  int open(SendPort port) => 0;

  @override
  bool send(int session, Uint8List frame) => false;

  @override
  void close(int session) {}
}

class _FakeService implements Service {
  @override
  final SessionFrameChannel frames;

  _FakeService({SessionFrameChannel? frames})
    : frames =
          frames ?? MethodChannelFrameChannel(const MethodChannel('test/core'));

  final calls = <String>[];

  /// Whether the frames were connected when each call was made.
  final framesLive = <String, bool>{};

  void _record(String call) {
    calls.add(call);
    framesLive[call] = frames.generation != null;
  }

  String initError = '';
  String syncError = '';
  Exception? syncException;
  bool shutdownResult = true;
  bool startResult = true;
  bool stopResult = true;

  Completer<void>? initGate;

  @override
  Future<String> init() async {
    _record('init');
    await initGate?.future;
    return initError;
  }

  @override
  Future<String> syncState(SharedState state) async {
    _record('syncState');
    if (syncException case final exception?) {
      throw exception;
    }
    return syncError;
  }

  @override
  Future<bool> shutdown() async {
    _record('shutdown');
    return shutdownResult;
  }

  @override
  Future<bool> start() async {
    _record('start');
    return startResult;
  }

  @override
  Future<bool> stop() async {
    _record('stop');
    return stopResult;
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
  late MockCoreApi api;
  late CoreLib lib;

  setUpAll(() async {
    loadAppLocalizations(const Locale('en'));
  });

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    service = _FakeService();
    api = MockCoreApi();
    lib = CoreLib.scoped(service, api: api);
  });

  tearDown(() async {
    container.dispose();
    CoreLib.resetInstance();
    await service.frames.close();
  });

  test('exposes the API it was given', () {
    expect(lib.api, same(api));
  });

  group('crashes', () {
    test('reports a session that ends while connected', () async {
      await lib.start();
      final reasons = <String>[];
      final subscription = lib.crashes.listen(reasons.add);

      service.frames.disconnect(StateError('gone'));
      await Future<void>.delayed(Duration.zero);

      expect(reasons, [
        'The app lost its connection to the core: Bad state: gone',
      ]);
      await subscription.cancel();
    });

    test('stays quiet when the lib itself stops the session', () async {
      await lib.start();
      final reasons = <String>[];
      final subscription = lib.crashes.listen(reasons.add);

      await lib.stop();
      await Future<void>.delayed(Duration.zero);

      expect(reasons, isEmpty);
      await subscription.cancel();
    });
  });

  group('start', () {
    test('initializes, connects the frames and syncs shared state', () async {
      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(result.revision, 1);
      expect(service.calls, ['init', 'syncState']);
      expect(service.framesLive, {'init': false, 'syncState': true});
      expect(service.frames.generation, isNotNull);
    });

    test('coalesces a second start while already connected', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(result.revision, 2);
      expect(service.calls, isEmpty);
    });

    test('an initialization error leaves the lib unconnected', () async {
      service.initError = 'init boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'init boom'),
        ),
      );
      expect(service.calls, ['init']);
      expect(service.frames.generation, isNull);

      service.initError = '';
      final retry = await lib.start();
      expect(retry.outcome, CoreLifecycleOutcome.applied);
    });

    test('a sync error disconnects, shuts the service down and '
        'reopens the gate', () async {
      service.syncError = 'sync boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'sync boom'),
        ),
      );
      expect(service.calls, ['init', 'syncState', 'shutdown']);
      expect(service.framesLive['shutdown'], isFalse);
      expect(service.frames.generation, isNull);

      service.syncError = '';
      service.calls.clear();
      final retry = await lib.start();

      expect(retry.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['init', 'syncState']);
    });

    test('a sync the channel fails disconnects as a sync error does', () async {
      service.syncException = PlatformException(code: 'sync');

      await expectLater(lib.start(), throwsA(isA<PlatformException>()));
      expect(service.calls, ['init', 'syncState', 'shutdown']);
      expect(service.frames.generation, isNull);

      service.syncException = null;
      service.calls.clear();
      final retry = await lib.start();

      expect(retry.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['init', 'syncState']);
    });

    test('the VPN options are read once the Core can answer what they ask '
        'of it', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          vpnOptionsProvider.overrideWith((ref) async {
            if (service.frames.generation == null) {
              throw StateError(
                'the options were read before the Core connected',
              );
            }
            return const VpnOptions(
              enable: true,
              port: 7890,
              ipv6: false,
              dnsHijacking: false,
              accessControlProps: AccessControlProps(),
              allowBypass: false,
              systemProxy: false,
              bypassDomain: [],
            );
          }),
        ],
      );
      globalState.container = container;

      final started = await lib.start();

      expect(started.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['init', 'syncState']);
    });

    test('a Core that refuses the session shuts the service down and '
        'leaves the gate open to a retry', () async {
      final refusing = _FakeService(
        frames: FfiFrameChannel(library: _RefusingLibrary.new),
      );
      lib = CoreLib.scoped(refusing, api: api);

      await expectLater(lib.start(), throwsStateError);
      expect(refusing.calls, ['init', 'shutdown']);
      expect(refusing.frames.generation, isNull);
      await refusing.frames.close();
    });
  });

  group('a start still opening', () {
    setUp(() => service.initGate = Completer<void>());

    test('gives way to a close and leaves no session open', () async {
      final start = lib.start();
      await Future<void>.delayed(Duration.zero);
      final close = lib.close();
      service.initGate!.complete();

      expect((await start).outcome, CoreLifecycleOutcome.superseded);
      expect((await close).outcome, CoreLifecycleOutcome.coalesced);
      expect(service.calls, ['init', 'shutdown']);
      expect(service.frames.generation, isNull);
    });

    test('gives way to a stop and leaves no session open', () async {
      final start = lib.start();
      await Future<void>.delayed(Duration.zero);
      final stop = lib.stop();
      service.initGate!.complete();

      expect((await start).outcome, CoreLifecycleOutcome.superseded);
      expect((await stop).outcome, CoreLifecycleOutcome.coalesced);
      expect(service.frames.generation, isNull);
    });

    test('takes a second start as the same one', () async {
      final first = lib.start();
      await Future<void>.delayed(Duration.zero);
      final second = lib.start();
      service.initGate!.complete();

      expect((await first).outcome, CoreLifecycleOutcome.applied);
      expect((await second).outcome, CoreLifecycleOutcome.coalesced);
      expect(service.calls, ['init', 'syncState']);
    });
  });

  group('stop', () {
    test('coalesces when there is nothing connected', () async {
      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(service.calls, isEmpty);
    });

    test('disconnects the frames then shuts the service down', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['shutdown']);
      expect(service.framesLive['shutdown'], isFalse);
      expect(service.frames.generation, isNull);
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

  test('restart stops before starting again on a new session', () async {
    await lib.start();
    final first = service.frames.generation;
    service.calls.clear();

    final result = await lib.restart();

    expect(result.outcome, CoreLifecycleOutcome.applied);
    expect(service.calls, ['shutdown', 'init', 'syncState']);
    expect(service.frames.generation, isNot(first));
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
      service.calls.clear();

      await lib.startListener();
      expect(service.calls, ['start']);

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
    });

    test('a listener stop is answered by the service', () async {
      await lib.start();
      service.calls.clear();

      await lib.stopListener();
      expect(service.calls, ['stop']);

      service.stopResult = false;
      await expectLater(
        lib.stopListener(),
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.code,
            'code',
            'service_refused',
          ),
        ),
      );
    });

    test('neither asks the Core', () async {
      await lib.start();

      await lib.startListener();
      await lib.stopListener();

      verifyZeroInteractions(api);
    });
  });
}
