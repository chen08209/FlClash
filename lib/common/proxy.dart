import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' show ProxyState;
import 'package:proxy/proxy.dart';

final proxy = system.isDesktop && !safeModeBuild ? Proxy() : null;

final systemProxyQueue = proxy == null ? null : SystemProxyQueue(proxy!);

abstract interface class SystemProxyStore {
  Future<bool> read();

  Future<void> write(bool applied);
}

final class PreferencesSystemProxyStore implements SystemProxyStore {
  const PreferencesSystemProxyStore();

  @override
  Future<bool> read() => preferences.getSystemProxyApplied();

  @override
  Future<void> write(bool applied) =>
      preferences.saveSystemProxyApplied(applied);
}

/// Exit's stop goes through the same queue as every other change, so a start
/// still waiting behind a slow call cannot turn the proxy back on after it.
/// A stop also clears settings someone else made, so it only runs while the
/// mark written before each start says FlClash set the proxy.
class SystemProxyQueue {
  final Proxy _proxy;
  final SystemProxyStore _store;
  Future<void> _tail = Future.value();
  bool _closed = false;
  bool? _applied;

  SystemProxyQueue(
    this._proxy, {
    SystemProxyStore store = const PreferencesSystemProxyStore(),
  }) : _store = store;

  Future<void> apply(ProxyState state) {
    return _enqueue(() async {
      if (_closed) {
        return;
      }
      if (state.isStart && state.systemProxy) {
        await _start(state.port, state.bassDomain);
      } else {
        await _stop();
      }
    });
  }

  Future<void> close() {
    _closed = true;
    return _enqueue(_stop);
  }

  Future<void> _start(int port, List<String> bypassDomain) async {
    if (!await _isApplied()) {
      await _mark(true);
    }
    if (!await _proxy.startProxy(port, bypassDomain)) {
      _logFailure();
    }
  }

  Future<void> _stop() async {
    if (!await _isApplied()) {
      return;
    }
    if (!await _proxy.stopProxy()) {
      _logFailure();
      return;
    }
    await _mark(false);
  }

  Future<bool> _isApplied() async => _applied ??= await _store.read();

  Future<void> _mark(bool applied) async {
    _applied = applied;
    await _store.write(applied);
  }

  void _logFailure() {
    commonPrint.log('update system proxy failed', logLevel: LogLevel.warning);
  }

  Future<void> _enqueue(Future<void> Function() task) {
    return _tail = _tail.then((_) => task()).catchError((Object error) {
      commonPrint.log(
        'update system proxy failed: $error',
        logLevel: LogLevel.warning,
      );
    });
  }
}

String proxyEnvCommand(int port, {required bool isWindows}) {
  final url = 'http://127.0.0.1:$port';
  return isWindows ? 'set \$env:all_proxy=$url' : 'export all_proxy=$url';
}
