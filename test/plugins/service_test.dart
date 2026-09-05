import 'dart:convert';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingListener with ServiceListener {
  final events = <CoreEvent>[];

  @override
  void onServiceEvent(CoreEvent event) => events.add(event);
}

class _ThrowingListener with ServiceListener {
  var called = false;

  @override
  void onServiceEvent(CoreEvent event) {
    called = true;
    throw StateError('listener boom');
  }
}

class _MutatingListener with ServiceListener {
  final ServiceListener target;

  _MutatingListener(this.target);

  @override
  void onServiceEvent(CoreEvent event) {
    Service().removeListener(target);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = '$packageName/service';
  const channel = MethodChannel(channelName);
  const codec = StandardMethodCodec();

  late List<MethodCall> calls;

  void mockChannel(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return handler(call);
        });
  }

  Future<void> emitFromPlatform(Object? arguments) async {
    final payload = json.encode(
      CoreMethodCall(method: CoreMethod.message, arguments: arguments).toJson(),
    );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channelName,
          codec.encodeMethodCall(MethodCall('event', payload)),
          null,
        );
  }

  setUp(() {
    calls = <MethodCall>[];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
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
            crashlytics: false,
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
        crashlytics: false,
      );

      expect(await Service().syncState(state), 'ok');

      final sent = json.decode(calls.single.arguments as String);
      expect(sent['currentProfileName'], 'profile');
      expect(sent['onlyStatisticsProxy'], isTrue);
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

  group('invokeMethod', () {
    test('encodes the call and decodes the response envelope', () async {
      mockChannel(
        (_) async => json.encode(
          const CoreMethodResponse(id: '7', result: {'up': 1}).toJson(),
        ),
      );

      final response = await Service().invokeMethod(
        const CoreMethodCall(
          id: '7',
          method: CoreMethod.getTraffic,
          arguments: true,
        ),
      );

      final sent =
          json.decode(calls.single.arguments as String) as Map<String, Object?>;
      expect(calls.single.method, 'invokeMethod');
      expect(sent['id'], '7');
      expect(sent['method'], CoreMethod.getTraffic.name);
      expect(
        sent['arguments'],
        isTrue,
        reason: 'arguments stay structured JSON, never a pre-encoded string',
      );
      expect(response!.id, '7');
      expect(response.result, {'up': 1});
      expect(response.error, isNull);
    });

    test('returns null when the platform sends no envelope', () async {
      mockChannel((_) async => null);

      expect(
        await Service().invokeMethod(
          const CoreMethodCall(method: CoreMethod.getTraffic),
        ),
        isNull,
      );
    });

    test('surfaces a Core error inside the envelope', () async {
      mockChannel(
        (_) async => json.encode({
          'id': '1',
          'result': null,
          'error': {'code': 'unavailable', 'message': 'core down'},
        }),
      );

      final response = await Service().invokeMethod(
        const CoreMethodCall(id: '1', method: CoreMethod.getTraffic),
      );

      expect(response!.error, isNotNull);
      expect(response.error!.code, 'unavailable');
      expect(response.error!.message, 'core down');
    });
  });

  group('event dispatch', () {
    test('fans a batched event list out to every listener', () async {
      final first = _RecordingListener();
      final second = _RecordingListener();
      Service().addListener(first);
      Service().addListener(second);
      addTearDown(() {
        Service().removeListener(first);
        Service().removeListener(second);
      });

      await emitFromPlatform([
        {'type': CoreEventType.crash.name, 'data': 'boom'},
        {'type': CoreEventType.loaded.name, 'data': 'provider'},
      ]);

      for (final listener in [first, second]) {
        expect(listener.events.map((event) => event.type), [
          CoreEventType.crash,
          CoreEventType.loaded,
        ]);
        expect(listener.events.first.data, 'boom');
      }
    });

    test('accepts a single event object as well as a list', () async {
      final listener = _RecordingListener();
      Service().addListener(listener);
      addTearDown(() => Service().removeListener(listener));

      await emitFromPlatform({
        'type': CoreEventType.crash.name,
        'data': 'boom',
      });

      expect(listener.events.single.type, CoreEventType.crash);
    });

    test('a throwing listener does not starve the others', () async {
      final throwing = _ThrowingListener();
      final healthy = _RecordingListener();
      Service().addListener(throwing);
      Service().addListener(healthy);
      addTearDown(() {
        Service().removeListener(throwing);
        Service().removeListener(healthy);
      });

      await emitFromPlatform([
        {'type': CoreEventType.crash.name, 'data': 'boom'},
      ]);

      expect(throwing.called, isTrue);
      expect(healthy.events.single.type, CoreEventType.crash);
    });

    test('mutating listeners during dispatch does not throw', () async {
      final second = _RecordingListener();
      final mutating = _MutatingListener(second);
      Service().addListener(mutating);
      Service().addListener(second);
      addTearDown(() {
        Service().removeListener(mutating);
        Service().removeListener(second);
      });

      await expectLater(
        emitFromPlatform([
          {'type': CoreEventType.crash.name, 'data': 'boom'},
        ]),
        completes,
      );
    });

    test('an unparsable event is dropped without losing the batch', () async {
      final listener = _RecordingListener();
      Service().addListener(listener);
      addTearDown(() => Service().removeListener(listener));

      await emitFromPlatform([
        {'type': 'notAnEventType'},
        {'type': CoreEventType.crash.name, 'data': 'boom'},
      ]);

      expect(listener.events.single.type, CoreEventType.crash);
    });

    test('a removed listener stops receiving events', () async {
      final listener = _RecordingListener();
      Service().addListener(listener);
      expect(Service().hasListeners, isTrue);
      Service().removeListener(listener);
      expect(Service().hasListeners, isFalse);

      await emitFromPlatform([
        {'type': CoreEventType.crash.name, 'data': 'boom'},
      ]);

      expect(listener.events, isEmpty);
    });

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
            codec.encodeMethodCall(const MethodCall('event', '')),
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
