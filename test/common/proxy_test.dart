import 'dart:async';

import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/models/models.dart' show ProxyState;
import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy.dart';

class _FakeProxy implements Proxy {
  final List<String> calls = [];
  Future<bool>? held;
  Error? failure;

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
}

class _FakeStore implements SystemProxyStore {
  _FakeStore(this.applied, this.calls);

  bool applied;
  final List<String> calls;

  @override
  Future<bool> read() async => applied;

  @override
  Future<void> write(bool applied) async {
    calls.add('mark $applied');
    this.applied = applied;
  }
}

ProxyState _state({required bool isStart}) {
  return ProxyState(
    isStart: isStart,
    systemProxy: true,
    bassDomain: const [],
    port: 7890,
  );
}

SystemProxyQueue _queue(_FakeProxy proxy, {bool applied = false}) {
  return SystemProxyQueue(proxy, store: _FakeStore(applied, proxy.calls));
}

void main() {
  test('applies changes in the order they come', () async {
    final proxy = _FakeProxy();
    final queue = _queue(proxy);

    unawaited(queue.apply(_state(isStart: true)));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['mark true', 'start 7890', 'stop', 'mark false']);
  });

  test('close stops last and drops the starts queued before it', () async {
    final proxy = _FakeProxy();
    final queue = _queue(proxy);
    final inFlight = Completer<bool>();
    proxy.held = inFlight.future;

    unawaited(queue.apply(_state(isStart: true)));
    await pumpEventQueue();
    unawaited(queue.apply(_state(isStart: true)));
    final closed = queue.close();
    await pumpEventQueue();
    expect(proxy.calls, ['mark true', 'start 7890']);

    inFlight.complete(true);
    await closed;
    await queue.apply(_state(isStart: true));

    expect(proxy.calls, ['mark true', 'start 7890', 'stop', 'mark false']);
  });

  test('a failing call does not stall the queue', () async {
    final proxy = _FakeProxy();
    final queue = _queue(proxy);
    proxy.failure = StateError('channel gone');

    await queue.apply(_state(isStart: true));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['mark true', 'start 7890', 'stop', 'mark false']);
  });

  test('leaves a proxy it never set alone', () async {
    final proxy = _FakeProxy();
    final queue = _queue(proxy);

    await queue.apply(_state(isStart: false));
    await queue.close();

    expect(proxy.calls, isEmpty);
  });

  test('clears a proxy an earlier run left on', () async {
    final proxy = _FakeProxy();
    final queue = _queue(proxy, applied: true);

    await queue.apply(_state(isStart: false));
    await queue.close();

    expect(proxy.calls, ['stop', 'mark false']);
  });

  test(
    'keeps the mark when a stop fails so the next one tries again',
    () async {
      final proxy = _FakeProxy();
      final queue = _queue(proxy, applied: true);
      proxy.held = Future.value(false);

      await queue.apply(_state(isStart: false));
      await queue.close();

      expect(proxy.calls, ['stop', 'stop', 'mark false']);
    },
  );
}
