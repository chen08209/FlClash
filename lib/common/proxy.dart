import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' show ProxyState;
import 'package:rust_api/rust_api.dart' as rust_api;

abstract interface class SystemProxy {
  Future<bool> start(int port, List<String> bypassDomain, String? pacScript);

  Future<bool> stop();
}

class _NativeSystemProxy implements SystemProxy {
  const _NativeSystemProxy();

  @override
  Future<bool> start(int port, List<String> bypassDomain, String? pacScript) {
    return rust_api.startSystemProxy(
      port: port,
      bypassDomain: bypassDomain,
      pacScript: pacScript,
    );
  }

  @override
  Future<bool> stop() => rust_api.stopSystemProxy();
}

final systemProxyQueue = system.isDesktop && !safeModeBuild
    ? SystemProxyQueue(const _NativeSystemProxy())
    : null;

/// Exit's stop goes through the same queue as every other change, so a start
/// still waiting behind a slow call cannot turn the proxy back on after it.
/// A stop also clears settings someone else made, so it only undoes a start
/// of this run.
class SystemProxyQueue {
  final SystemProxy _proxy;
  Future<void> _tail = Future.value();
  bool _closed = false;
  bool _applied = false;

  SystemProxyQueue(this._proxy);

  Future<void> apply(ProxyState state) {
    return _enqueue(() async {
      if (_closed) {
        return;
      }
      if (state.isStart && state.systemProxy) {
        _applied = true;
        if (!await _proxy.start(
          state.port,
          state.bassDomain,
          state.pacScript,
        )) {
          _logFailure();
        }
      } else {
        await _stop();
      }
    });
  }

  Future<void> close() {
    _closed = true;
    return _enqueue(_stop);
  }

  Future<void> _stop() async {
    if (!_applied) {
      return;
    }
    if (!await _proxy.stop()) {
      _logFailure();
      return;
    }
    _applied = false;
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
