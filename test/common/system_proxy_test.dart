import 'dart:async';

import 'package:fl_clash/common/proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy.dart';

class _Proxy extends Proxy {
  final List<String> calls = [];
  Completer<void>? startGate;
  Error? startError;
  bool result = true;

  @override
  Future<bool> startProxy(
    int port, [
    List<String> bypassDomain = const [],
  ]) async {
    calls.add('start:$port');
    await startGate?.future;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return result;
  }

  @override
  Future<bool> stopProxy() async {
    calls.add('stop');
    return result;
  }
}

void main() {
  late _Proxy port;
  late SystemProxyCoordinator coordinator;

  setUp(() {
    port = _Proxy();
    coordinator = SystemProxyCoordinator(port);
  });

  Future<void> update(bool enabled, {int port = 7890}) =>
      coordinator.update(enabled: enabled, port: port, bypassDomain: const []);

  test('updates wait for the current native operation', () async {
    port.startGate = Completer<void>();
    final starting = update(true);
    await Future<void>.delayed(Duration.zero);
    final stopping = update(false);
    await Future<void>.delayed(Duration.zero);
    expect(port.calls, ['start:7890']);

    port.startGate!.complete();
    await starting;
    await stopping;
    expect(port.calls, ['start:7890', 'stop']);
  });

  test(
    'shutdown skips queued updates and waits before its final stop',
    () async {
      port.startGate = Completer<void>();
      final starting = update(true);
      await Future<void>.delayed(Duration.zero);
      final queued = update(true, port: 7891);
      final stopping = coordinator.shutdown();
      await Future<void>.delayed(Duration.zero);
      expect(port.calls, ['start:7890']);

      port.startGate!.complete();
      await starting;
      await queued;
      await stopping;
      expect(port.calls, ['start:7890', 'stop']);
    },
  );

  test('shutdown is shared and later updates remain stopped', () async {
    final first = coordinator.shutdown();
    expect(identical(first, coordinator.shutdown()), isTrue);
    expect(identical(first, update(true)), isTrue);
    await first;
    await update(true, port: 7891);
    expect(port.calls, ['stop']);
  });

  test(
    'a failed native update does not block later updates or shutdown',
    () async {
      port.startError = StateError('native start failed');
      await update(true);
      await update(false);
      await coordinator.shutdown();
      expect(port.calls, ['start:7890', 'stop', 'stop']);
    },
  );

  test('false native results do not stall the queue', () async {
    port.result = false;
    await update(true);
    await update(false);
    await coordinator.shutdown();
    expect(port.calls, ['start:7890', 'stop', 'stop']);
  });
}
