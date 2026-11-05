import 'dart:async';

import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/models/models.dart' show ProxyState;
import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy.dart';

class _FakeProxy implements Proxy {
  final List<String> calls = [];
  Future<bool>? held;
  Error? failure;
  int? loopbackPort;

  Future<bool> _call(String name) async {
    calls.add(name);
    final error = failure;
    failure = null;
    if (error != null) {
      throw error;
    }
    final result = held ?? Future.value(true);
    held = null;
    return result;
  }

  @override
  Future<bool> startProxy(int port, [List<String> bypassDomain = const []]) {
    return _call('start $port');
  }

  @override
  Future<bool> stopProxy() => _call('stop');

  @override
  Future<int?> readLoopbackProxyPort() async => loopbackPort;
}

ProxyState _state({required bool isStart}) {
  return ProxyState(
    isStart: isStart,
    systemProxy: true,
    bassDomain: const [],
    port: 7890,
  );
}

void main() {
  test('applies changes in the order they come', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    unawaited(queue.apply(_state(isStart: true)));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('close stops last and drops the starts queued before it', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);
    final inFlight = Completer<bool>();
    proxy.held = inFlight.future;

    unawaited(queue.apply(_state(isStart: true)));
    await pumpEventQueue();
    unawaited(queue.apply(_state(isStart: true)));
    final closed = queue.close();
    await pumpEventQueue();
    expect(proxy.calls, ['start 7890']);

    inFlight.complete(true);
    await closed;
    await queue.apply(_state(isStart: true));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('a failing call does not stall the queue', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);
    proxy.failure = StateError('channel gone');

    await queue.apply(_state(isStart: true));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('leaves a proxy it never set alone', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    await queue.apply(_state(isStart: false));
    await queue.close();

    expect(proxy.calls, isEmpty);
  });

  test('tries a failed stop again on close', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    await queue.apply(_state(isStart: true));
    proxy.held = Future.value(false);
    await queue.apply(_state(isStart: false));
    await queue.close();
    await queue.close();

    expect(proxy.calls, ['start 7890', 'stop', 'stop']);
  });

  group('recoverStale', () {
    test('clears a system proxy a killed run left on a dead port', () async {
      final proxy = _FakeProxy()..loopbackPort = 7890;
      final queue = SystemProxyQueue(proxy, loopbackFree: (_) async => true);

      await queue.recoverStale();

      expect(proxy.calls, ['stop']);
    });

    test('leaves a proxy another process still answers for', () async {
      final proxy = _FakeProxy()..loopbackPort = 7890;
      final queue = SystemProxyQueue(proxy, loopbackFree: (_) async => false);

      await queue.recoverStale();

      expect(proxy.calls, isEmpty);
    });

    test('clears nothing when no loopback proxy is set', () async {
      final proxy = _FakeProxy();
      final queue = SystemProxyQueue(
        proxy,
        loopbackFree: (_) async => fail('nothing to probe'),
      );

      await queue.recoverStale();

      expect(proxy.calls, isEmpty);
    });

    test('a failed clear does not stall the queue', () async {
      final proxy = _FakeProxy()
        ..loopbackPort = 7890
        ..failure = StateError('gone');
      final queue = SystemProxyQueue(proxy, loopbackFree: (_) async => true);

      await queue.recoverStale();
      await queue.apply(_state(isStart: true));

      expect(proxy.calls, ['stop', 'start 7890']);
    });
  });
}
