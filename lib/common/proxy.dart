import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' show ProxyState;
import 'package:proxy/proxy.dart';

final proxy = system.isDesktop && !safeModeBuild ? Proxy() : null;

final systemProxyQueue = proxy == null ? null : SystemProxyQueue(proxy!);

typedef LoopbackFreeProbe = Future<bool> Function(int port);

/// Exit's stop goes through the same queue as every other change, so a start
/// still waiting behind a slow call cannot turn the proxy back on after it.
/// A stop also clears settings someone else made, so it only undoes a start
/// of this run.
class SystemProxyQueue {
  final Proxy _proxy;
  final LoopbackFreeProbe _loopbackFree;
  Future<void> _tail = Future.value();
  bool _closed = false;
  bool _applied = false;

  SystemProxyQueue(this._proxy, {LoopbackFreeProbe? loopbackFree})
    : _loopbackFree = loopbackFree ?? _isLoopbackFree;

  /// Undoes a start that a run which never reached its exit cleanup left.
  Future<void> recoverStale() {
    return _enqueue(() async {
      if (_closed) {
        return;
      }
      final port = await _proxy.readLoopbackProxyPort();
      if (port == null || !await _loopbackFree(port)) {
        return;
      }
      if (!await _proxy.stopProxy()) {
        _logFailure();
        return;
      }
      commonPrint.log(
        'cleared the system proxy left on 127.0.0.1:$port',
        logLevel: LogLevel.warning,
      );
    });
  }

  Future<void> apply(ProxyState state) {
    return _enqueue(() async {
      if (_closed) {
        return;
      }
      if (state.isStart && state.systemProxy) {
        _applied = true;
        if (!await _proxy.startProxy(state.port, state.bassDomain)) {
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
    if (!await _proxy.stopProxy()) {
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

Future<bool> _isLoopbackFree(int port) async {
  try {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await socket.close();
    return true;
  } on SocketException {
    return false;
  }
}

String proxyEnvCommand(int port, {required bool isWindows}) {
  final url = 'http://127.0.0.1:$port';
  return isWindows ? 'set \$env:all_proxy=$url' : 'export all_proxy=$url';
}
