import 'dart:convert';
import 'dart:isolate';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/api/channels/ffi_channel.dart';
import 'package:fl_clash/core/api/channels/method_channel_channel.dart';
import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingStopListener with ServiceListener {
  var stops = 0;
  final failures = <ServiceStartFailure?>[];

  @override
  void onServiceStopped([ServiceStartFailure? failure]) {
    stops++;
    failures.add(failure);
  }
}

class _ThrowingListener with ServiceListener {
  var called = false;

  @override
  void onServiceStopped([ServiceStartFailure? failure]) {
    called = true;
    throw StateError('listener boom');
  }
}

class _MutatingListener with ServiceListener {
  final ServiceListener target;

  _MutatingListener(this.target);

  @override
  void onServiceStopped([ServiceStartFailure? failure]) {
    Service().removeListener(target);
  }
}

class _ReportedLibrary implements ConcordLibrary {
  @override
  bool initialize() => true;

  @override
  int open(SendPort port) => 1;

  @override
  bool send(int session, Uint8List frame) => true;

  @override
  void close(int session) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = '$packageName/service';
  const channel = MethodChannel(channelName);
  const coreChannel = MethodChannel('$packageName/core');
  const codec = StandardMethodCodec();

  late List<MethodCall> calls;

  void mockChannel(
    Future<Object?>? Function(MethodCall call) handler, {
    MethodChannel target = channel,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(target, (call) async {
          calls.add(call);
          return handler(call);
        });
  }

  void mockCoreChannel(Future<Object?>? Function(MethodCall call) handler) =>
      mockChannel(handler, target: coreChannel);

  Future<void> emitFromPlatform(Uint8List frame) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channelName,
          codec.encodeMethodCall(MethodCall('event', frame)),
          null,
        );
  }

  setUpAll(() {
    Service.framesFactory = (core, {onSession}) =>
        MethodChannelFrameChannel(core);
  });

  setUp(() {
    calls = <MethodCall>[];
  });

  tearDown(() {
    for (final target in [channel, coreChannel]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(target, null);
    }
  });

  test('is a singleton so the platform handler is installed once', () {
    expect(Service(), same(Service()));
  });

  group('lifecycle commands', () {
    test('start and stop report the platform result', () async {
      mockChannel((call) async => call.method == 'start');

      expect(await Service().start(), isTrue);
      expect(await Service().stop(), isFalse);
      expect(calls.map((call) => call.method), ['start', 'stop']);
    });

    test('an absent start or stop result is treated as failure', () async {
      mockChannel((_) async => null);

      expect(await Service().start(), isFalse);
      expect(await Service().stop(), isFalse);
    });

    test('an absent shutdown result is treated as success', () async {
      mockChannel((_) async => null);

      expect(
        await Service().shutdown(),
        isTrue,
        reason:
            'shutdown defaults the opposite way from start/stop: a service '
            'that cannot answer is already gone',
      );
    });

    test('init and syncState fall back to an empty payload', () async {
      mockChannel((_) async => null);

      expect(await Service().init(), isEmpty);
      expect(
        await Service().syncState(
          const SharedState(
            stopTip: 'stopTip',
            startTip: 'startTip',
            currentProfileName: 'profile',
            stopText: 'stop',
            onlyStatisticsProxy: false,
          ),
        ),
        isEmpty,
      );
    });

    test('syncState sends the encoded shared state', () async {
      mockChannel((_) async => 'ok');
      const state = SharedState(
        stopTip: 'stopTip',
        startTip: 'startTip',
        currentProfileName: 'profile',
        stopText: 'stop',
        onlyStatisticsProxy: true,
      );

      expect(await Service().syncState(state), 'ok');

      final sent = json.decode(calls.single.arguments as String);
      expect(sent['currentProfileName'], 'profile');
      expect(sent['onlyStatisticsProxy'], isTrue);
      expect(sent, isNot(contains('setupParams')));
    });
  });

  group('stop reports', () {
    late _RecordingStopListener listener;

    Future<void> reportStopped(Object? revision, {String? failure}) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            channelName,
            codec.encodeMethodCall(
              MethodCall('stopped', {'revision': revision, 'failure': failure}),
            ),
            null,
          );
    }

    int lastRevision() => calls.last.arguments as int;

    setUp(() {
      mockChannel((_) async => true);
      listener = _RecordingStopListener();
      Service().addListener(listener);
    });

    tearDown(() => Service().removeListener(listener));

    test('every command carries a revision newer than the last', () async {
      await Service().start();
      final first = lastRevision();
      await Service().stop();

      expect(lastRevision(), greaterThan(first));
    });

    test(
      'a report for the start in force reaches the listeners once',
      () async {
        await Service().start();

        await reportStopped(lastRevision());
        await reportStopped(lastRevision());

        expect(listener.stops, 1);
      },
    );

    test('a start the service gave up names why', () async {
      await Service().start();

      await reportStopped(lastRevision(), failure: 'vpn_permission');

      expect(listener.failures, [ServiceStartFailure.vpnPermission]);
    });

    test('a report older than the newest command is dropped', () async {
      await Service().start();
      final stale = lastRevision();
      await Service().stop();
      await Service().start();

      await reportStopped(stale);

      expect(listener.stops, 0);
    });

    test(
      'a report is dropped while Flutter itself asked for the stop',
      () async {
        await Service().start();
        await Service().stop();

        await reportStopped(lastRevision());

        expect(listener.stops, 0);
      },
    );

    test('a throwing listener does not starve the next one', () async {
      final throwing = _ThrowingListener();
      Service().removeListener(listener);
      Service().addListener(throwing);
      Service().addListener(listener);
      addTearDown(() => Service().removeListener(throwing));
      await Service().start();

      await reportStopped(lastRevision());

      expect(listener.stops, 1);
    });
  });

  group('getRunTime', () {
    test('maps a millisecond stamp to a DateTime', () async {
      final stamp = DateTime.utc(2026, 8, 16).millisecondsSinceEpoch;
      mockChannel((_) async => stamp);

      expect(
        await Service().getRunTime(),
        DateTime.fromMillisecondsSinceEpoch(stamp),
      );
    });

    test('treats zero and a missing stamp as not running', () async {
      mockChannel((_) async => 0);
      expect(await Service().getRunTime(), isNull);

      mockChannel((_) async => null);
      expect(await Service().getRunTime(), isNull);
    });
  });

  group('frames', () {
    test('an event call hands its bytes to the frame channel', () async {
      final received = <Uint8List>[];
      final subscription = Service().frames.frames.listen(received.add);
      addTearDown(subscription.cancel);

      await emitFromPlatform(Uint8List.fromList([1, 2, 3]));
      await emitFromPlatform(Uint8List.fromList([4]));
      await pumpEventQueue();

      expect(received, [
        [1, 2, 3],
        [4],
      ]);
    });

    test('a frame sent to the Core reaches the core channel as send', () async {
      mockCoreChannel((_) async => null);

      Service().frames.send(Uint8List.fromList([9, 8, 7]));
      await pumpEventQueue();

      expect(calls.single.method, 'send');
      expect(calls.single.arguments, Uint8List.fromList([9, 8, 7]));
    });

    test('a frame given as a plain list is sent as bytes', () async {
      mockCoreChannel((_) async => null);

      Service().frames.send([5, 6]);
      await pumpEventQueue();

      expect(calls.single.arguments, isA<Uint8List>());
      expect(calls.single.arguments, [5, 6]);
    });

    test('a failed send ends the connection', () async {
      mockCoreChannel((_) async => throw PlatformException(code: 'gone'));
      final frames = Service().frames..connect();
      addTearDown(frames.disconnect);
      final events = <ChannelEvent>[];
      final subscription = frames.events.listen(events.add);
      addTearDown(subscription.cancel);

      frames.send([1]);
      await pumpEventQueue();

      expect(events.single, isA<ChannelDisconnected>());
      expect(frames.generation, isNull);
    });
  });

  group('ffi frames', () {
    late _ReportedLibrary library;

    setUp(() {
      library = _ReportedLibrary();
      Service.resetInstance();
      Service.framesFactory = (core, {onSession}) =>
          FfiFrameChannel(library: () => library, onSession: onSession);
    });

    tearDown(() async {
      await Service().frames.close();
      Service.resetInstance();
      Service.framesFactory = (core, {onSession}) =>
          MethodChannelFrameChannel(core);
    });

    test('init tells the platform the frames do not use its channel', () async {
      mockChannel((_) async => '');

      await Service().init();

      expect(calls.single.method, 'init');
      expect(calls.single.arguments, 'ffi');
    });

    test('the platform learns the session that opens and ends', () async {
      mockChannel((_) async => null);
      final frames = Service().frames;

      frames.connect();
      frames.disconnect();
      await pumpEventQueue();

      expect(calls.map((call) => call.method), ['session', 'session']);
      expect(calls.map((call) => call.arguments), [1, 0]);
    });

    test('a platform without the report does not break the session', () async {
      mockChannel((_) async => throw MissingPluginException());
      final frames = Service().frames..connect();
      await pumpEventQueue();

      expect(frames.generation, isNotNull);
    });
  });

  group('listeners', () {
    test('a stop report reaches every listener', () async {
      mockChannel((_) async => true);
      final first = _RecordingStopListener();
      final second = _RecordingStopListener();
      Service().addListener(first);
      Service().addListener(second);
      addTearDown(() {
        Service().removeListener(first);
        Service().removeListener(second);
      });
      await Service().start();

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            channelName,
            codec.encodeMethodCall(
              MethodCall('stopped', {'revision': calls.last.arguments}),
            ),
            null,
          );

      expect([first.stops, second.stops], [1, 1]);
    });

    test('mutating listeners during dispatch does not throw', () async {
      mockChannel((_) async => true);
      final second = _RecordingStopListener();
      final mutating = _MutatingListener(second);
      Service().addListener(mutating);
      Service().addListener(second);
      addTearDown(() {
        Service().removeListener(mutating);
        Service().removeListener(second);
      });
      await Service().start();

      await expectLater(
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channelName,
              codec.encodeMethodCall(
                MethodCall('stopped', {'revision': calls.last.arguments}),
              ),
              null,
            ),
        completes,
      );
    });

    test('a removed listener stops receiving reports', () async {
      mockChannel((_) async => true);
      final listener = _RecordingStopListener();
      Service().addListener(listener);
      expect(Service().hasListeners, isTrue);
      Service().removeListener(listener);
      expect(Service().hasListeners, isFalse);
      await Service().start();

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            channelName,
            codec.encodeMethodCall(
              MethodCall('stopped', {'revision': calls.last.arguments}),
            ),
            null,
          );

      expect(listener.stops, 0);
    });
  });

  group('platform handler', () {
    test('an unknown platform method is reported as unimplemented', () async {
      final unknown = await TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .handlePlatformMessage(
            channelName,
            codec.encodeMethodCall(const MethodCall('nope')),
            null,
          );
      final known = await TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .handlePlatformMessage(
            channelName,
            codec.encodeMethodCall(MethodCall('event', Uint8List(0))),
            null,
          );

      expect(
        unknown,
        isNull,
        reason:
            'the handler throws MissingPluginException, which a method channel '
            'answers with a null reply rather than an error envelope',
      );
      expect(known, isNotNull);
    });
  });
}
