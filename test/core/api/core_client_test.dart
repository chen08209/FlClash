import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/core/api/dto.dart';
import 'package:fl_clash/core/api/errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_channel.dart';

Future<void> settle() => Future<void>.delayed(Duration.zero);

JsonMap _object(Object? value) => value as JsonMap;

void main() {
  late FakeFrameChannel channel;
  late CoreClient client;

  setUp(() {
    channel = FakeFrameChannel();
    client = CoreClient(channel, clientVersion: '1.2.3');
  });

  tearDown(() async {
    await client.close();
    await channel.close();
  });

  Future<void> connect() async {
    channel.connect();
    await settle();
  }

  group('hello', () {
    test('says hello once per session with the protocol range', () async {
      await connect();
      final first = client.ready();
      await settle();
      final hello = channel.lastCall('core.hello');
      expect(hello['params'], {
        'protocol': {'min': 1, 'max': 1},
        'client': {'name': 'flclash', 'version': '1.2.3'},
      });
      channel.answerHello();
      expect((await first).implementation, 'concord');
      await client.ready();
      expect(channel.calls('core.hello'), hasLength(1));
      expect(client.session?.version, '1.0.0');
    });

    test('asks for the debug capability only when built to', () async {
      final debugClient = CoreClient(channel, debug: true);
      await connect();
      final ready = debugClient.ready();
      await settle();
      expect(
        channel.lastCall('core.hello')['params'],
        containsPair('capabilities', ['debug']),
      );
      channel.answerHello();
      await ready;
      await debugClient.close();
    });

    test('says hello again after the session changes', () async {
      await connect();
      final first = client.ready();
      await settle();
      channel.answerHello();
      await first;
      channel
        ..disconnect()
        ..connect();
      await settle();
      expect(client.session, isNull);
      final second = client.ready();
      await settle();
      expect(channel.calls('core.hello'), hasLength(2));
      channel.answerHello();
      await second;
    });

    test('reports a Core that never connects as unavailable', () async {
      final slow = CoreClient(channel, connectTimeout: Duration.zero);
      await expectLater(
        slow.ready(),
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.code,
            'code',
            'core_unavailable',
          ),
        ),
      );
      await slow.close();
    });
  });

  group('call', () {
    Future<Future<Object?>> callStatus({Duration? timeout}) async {
      await connect();
      final result = client.call<Object?>(
        'engine.state',
        decode: (result) => _object(result)['state'] as String,
        timeout: timeout,
      );
      await settle();
      channel.answerHello();
      await settle();
      return result;
    }

    test('sends the request and decodes the result', () async {
      final result = await callStatus();
      final request = channel.lastCall('engine.state');
      expect(request, isNot(contains('params')));
      channel.answer(request['id'], {'state': 'running'});
      expect(await result, 'running');
    });

    test(
      'raises the kind of an error answer, narrowed by its reason',
      () async {
        final result = await callStatus();
        final id = channel.lastCall('engine.state')['id'];
        channel.fail(id, {
          'code': -32000,
          'message': 'rule set is empty',
          'data': {'kind': 'rejected', 'reason': 'rule_set_empty'},
        });
        await expectLater(
          result,
          throwsA(
            isA<CoreMethodException>()
                .having((error) => error.code, 'code', 'rule_set_empty')
                .having((error) => error.kind, 'kind', 'rejected'),
          ),
        );
      },
    );

    test('cancels the call in the Core when it times out', () async {
      final result = await callStatus(
        timeout: const Duration(milliseconds: 40),
      );
      final id = channel.lastCall('engine.state')['id'];
      await expectLater(result, throwsA(isA<TimeoutException>()));
      expect(channel.lastCall(r'$/cancel')['params'], {'id': id});
      channel.answer(id, {'state': 'late'});
      await settle();
      expect(client.pendingCount, 0);
    });

    test('fails calls in flight when the session is lost', () async {
      final result = await callStatus();
      channel.disconnect();
      await expectLater(
        result,
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.isCoreUnavailable,
            'isCoreUnavailable',
            isTrue,
          ),
        ),
      );
      expect(client.pendingCount, 0);
    });

    test('reports a result the decoder cannot read as invalid', () async {
      final result = await callStatus();
      final id = channel.lastCall('engine.state')['id'];
      channel.answer(id, {'unexpected': true});
      await expectLater(
        result,
        throwsA(
          isA<CoreMethodException>().having(
            (error) => error.code,
            'code',
            'invalid_response',
          ),
        ),
      );
    });

    test('decodes a large response off the UI isolate', () async {
      await connect();
      final result = client.call<(int, String?)>(
        'connection.list',
        decode: (result) => (
          (_object(result)['items'] as List).length,
          Isolate.current.debugName,
        ),
      );
      await settle();
      channel.answerHello();
      await settle();
      final id = channel.lastCall('connection.list')['id'];
      final items = List.generate(3000, (index) => 'connection-$index-padding');
      final frame = utf8.encode(
        json.encode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {'items': items},
        }),
      );
      expect(frame.length, greaterThan(coreOffloadBytes));
      channel.pushRaw(Uint8List.fromList(frame));
      final (count, isolateName) = await result;
      expect(count, 3000);
      expect(isolateName, isNot('main'));
    });

    test('decodes a small response on the calling isolate', () async {
      await connect();
      final result = client.call<String?>(
        'engine.state',
        decode: (_) => Isolate.current.debugName,
      );
      await settle();
      channel.answerHello();
      await settle();
      channel.answer(channel.lastCall('engine.state')['id'], {});
      expect(await result, 'main');
    });
  });

  group('watch', () {
    Future<(Stream<WatchFrame<JsonMap, int>>, int)> open({
      Map<String, Object?>? params,
      bool Function(int event)? isLast,
      int? maxBatchMs,
    }) async {
      await connect();
      final stream = client.watch<JsonMap, int>(
        'traffic.watch',
        params: params,
        decodeSnapshot: _object,
        decodeEvent: (event) => event['n'] as int,
        isLast: isLast,
        maxBatchMs: maxBatchMs,
      );
      return (stream, 0);
    }

    Future<int> answerOpen({Object? snapshot = const {'total': 1}}) async {
      await settle();
      channel.answerHello();
      await settle();
      final request = channel.lastCall('traffic.watch');
      channel.answer(request['id'], {'sub': 7, 'snapshot': snapshot});
      await settle();
      return request['id'] as int;
    }

    test('opens on listen with the options and gives its credit once it '
        'has the sub', () async {
      final (stream, _) = await open(
        params: {'intervalMs': 1000},
        maxBatchMs: 250,
      );
      expect(channel.calls('traffic.watch'), isEmpty);
      final frames = <WatchFrame<JsonMap, int>>[];
      final subscription = stream.listen(frames.add);
      await answerOpen();
      expect(channel.lastCall('traffic.watch')['params'], {
        'intervalMs': 1000,
        'credit': 0,
        'maxBatchMs': 250,
      });
      expect(channel.lastCall(r'$/credit')['params'], {'sub': 7, 'n': 4});
      expect(frames.single.snapshot, {'total': 1});
      await subscription.cancel();
    });

    test('delivers events and gives credit back in chunks', () async {
      final (stream, _) = await open();
      final frames = <WatchFrame<JsonMap, int>>[];
      final subscription = stream.listen(frames.add);
      await answerOpen();
      channel.event(7, [
        {'n': 1},
        {'n': 2},
      ]);
      expect(frames.last.events, [1, 2]);
      expect(channel.calls(r'$/credit'), hasLength(1));
      channel.event(
        7,
        [
          {'n': 3},
        ],
        extra: {'dropped': 4},
      );
      expect(frames.last.dropped, 4);
      expect(channel.lastCall(r'$/credit')['params'], {'sub': 7, 'n': 2});
      await subscription.cancel();
    });

    test('withholds credit while paused and returns it on resume', () async {
      final (stream, _) = await open();
      final subscription = stream.listen((_) {});
      await answerOpen();
      subscription.pause();
      for (var index = 0; index < 3; index++) {
        channel.event(7, [
          {'n': index},
        ]);
      }
      expect(channel.calls(r'$/credit'), hasLength(1));
      subscription.resume();
      await settle();
      expect(channel.lastCall(r'$/credit')['params'], {'sub': 7, 'n': 3});
      await subscription.cancel();
    });

    test('cancels the subscription in the Core when cancelled', () async {
      final (stream, _) = await open();
      final subscription = stream.listen((_) {});
      final id = await answerOpen();
      await subscription.cancel();
      expect(channel.lastCall(r'$/cancel')['params'], {'id': id});
      channel.event(7, [
        {'n': 1},
      ]);
      expect(client.watchCount, 0);
    });

    test('reads a large snapshot off the UI isolate', () async {
      await connect();
      final stream = client.watch<(int, String?), int>(
        'connection.watch',
        decodeSnapshot: (snapshot) => (
          (_object(snapshot)['items'] as List).length,
          Isolate.current.debugName,
        ),
        decodeEvent: (event) => event['n'] as int,
      );
      final opened = Completer<(int, String?)?>();
      final subscription = stream.listen((frame) {
        if (!opened.isCompleted) {
          opened.complete(frame.snapshot);
        }
      });
      await settle();
      channel.answerHello();
      await settle();
      final id = channel.lastCall('connection.watch')['id'];
      final items = List.generate(3000, (index) => 'connection-$index-padding');
      final frame = utf8.encode(
        json.encode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'sub': 7,
            'snapshot': {'items': items},
          },
        }),
      );
      expect(frame.length, greaterThan(coreOffloadBytes));
      channel.pushRaw(Uint8List.fromList(frame));

      final (count, isolateName) = (await opened.future)!;
      expect(count, 3000);
      expect(isolateName, isNot('main'));
      expect(channel.lastCall(r'$/credit')['params'], {'sub': 7, 'n': 4});
      await subscription.cancel();
    });

    test('opens again after a resync and says so', () async {
      final (stream, _) = await open();
      final frames = <WatchFrame<JsonMap, int>>[];
      final subscription = stream.listen(frames.add);
      await answerOpen();
      channel.push({
        'jsonrpc': '2.0',
        'method': r'$/event',
        'params': {'sub': 7, 'resync': true},
      });
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final reopened = channel.calls('traffic.watch').last;
      expect(channel.calls('traffic.watch'), hasLength(2));
      channel.answer(reopened['id'], {
        'sub': 8,
        'snapshot': {'total': 9},
      });
      await settle();
      expect(frames.last.snapshot, {'total': 9});
      expect(frames.last.resynced, isTrue);
      channel.event(8, [
        {'n': 5},
      ]);
      expect(frames.last.events, [5]);
      await subscription.cancel();
    });

    test('ends with an error when the session is lost', () async {
      final (stream, _) = await open();
      final errors = <Object>[];
      final done = Completer<void>();
      stream.listen((_) {}, onError: errors.add, onDone: done.complete);
      await answerOpen();
      channel.disconnect();
      await done.future;
      expect(errors.single, isA<CoreMethodException>());
      expect(client.watchCount, 0);
    });

    test('closes after the event that ends it', () async {
      final (stream, _) = await open(isLast: (event) => event == 0);
      final frames = <WatchFrame<JsonMap, int>>[];
      final done = Completer<void>();
      stream.listen(frames.add, onDone: done.complete);
      await answerOpen();
      channel.event(7, [
        {'n': 3},
        {'n': 0},
      ]);
      await done.future;
      expect(frames.last.events, [3, 0]);
    });

    test('reports a failed open as an error', () async {
      final (stream, _) = await open();
      final errors = <Object>[];
      stream.listen((_) {}, onError: errors.add);
      await settle();
      channel.answerHello();
      await settle();
      channel.fail(channel.lastCall('traffic.watch')['id'], {
        'code': -32000,
        'message': 'no',
        'data': {'kind': 'unsupported'},
      });
      await settle();
      expect((errors.single as CoreMethodException).code, 'unsupported');
      expect(client.watchCount, 0);
    });

    test('ends with an error when the session is lost while it waits to '
        'open again after a resync', () async {
      final (stream, _) = await open();
      final errors = <Object>[];
      stream.listen((_) {}, onError: errors.add);
      await answerOpen();
      channel.push({
        'jsonrpc': '2.0',
        'method': r'$/event',
        'params': {'sub': 7, 'resync': true},
      });
      channel.disconnect();
      await settle();
      expect(errors.single, isA<CoreMethodException>());
      expect(client.watchCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(channel.calls('traffic.watch'), hasLength(1));
    });

    test('ends with an error as soon as the client closes while it waits '
        'for the Core', () async {
      final stream = client.watch<JsonMap, int>(
        'traffic.watch',
        decodeEvent: (event) => event['n'] as int,
      );
      final errors = <Object>[];
      stream.listen((_) {}, onError: errors.add);
      await settle();

      await client.close();
      await settle();

      expect(errors.single, isA<CoreMethodException>());
      expect(client.watchCount, 0);
    });

    test('skips an event it cannot read and still gives the credit '
        'back', () async {
      final (stream, _) = await open();
      final frames = <WatchFrame<JsonMap, int>>[];
      final subscription = stream.listen(frames.add);
      await answerOpen();
      channel.event(7, [
        {'n': 'not a number'},
        {'n': 1},
      ]);
      channel.event(7, [
        {'n': 2},
      ]);
      expect(frames.map((frame) => frame.events), [
        isEmpty,
        [1],
        [2],
      ]);
      expect(channel.lastCall(r'$/credit')['params'], {'sub': 7, 'n': 2});
      await subscription.cancel();
    });
  });

  group('snapshot', () {
    test('reads the snapshot and unsubscribes at once', () async {
      await connect();
      final result = client.snapshot<int>(
        'proxy.watch',
        decode: (snapshot) => _object(snapshot)['n'] as int,
      );
      await settle();
      channel.answerHello();
      await settle();
      final id = channel.lastCall('proxy.watch')['id'];
      channel.answer(id, {
        'sub': 3,
        'snapshot': {'n': 42},
      });
      expect(await result, 42);
      expect(channel.lastCall(r'$/cancel')['params'], {'id': id});
    });
  });
}
