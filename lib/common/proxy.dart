import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:proxy/proxy.dart';

final proxy = system.isDesktop && !safeModeBuild
    ? SystemProxyCoordinator(Proxy())
    : null;

class SystemProxyCoordinator {
  final Proxy _proxy;
  Future<void>? _pendingUpdate;
  Future<void>? _shutdownOperation;

  SystemProxyCoordinator(this._proxy);

  Future<void> update({
    required bool enabled,
    required int port,
    required List<String> bypassDomain,
  }) {
    final shutdownOperation = _shutdownOperation;
    if (shutdownOperation != null) {
      return shutdownOperation;
    }
    final operation = (_pendingUpdate ?? Future<void>.value())
        .then((_) async {
          if (_shutdownOperation != null) {
            return;
          }
          final result = enabled
              ? await _proxy.startProxy(port, bypassDomain)
              : await _proxy.stopProxy();
          if (!result) {
            commonPrint.log(
              'update system proxy failed',
              logLevel: LogLevel.warning,
            );
          }
        })
        .catchError((Object error) {
          commonPrint.log(
            'update system proxy failed: $error',
            logLevel: LogLevel.warning,
          );
        });
    _pendingUpdate = operation;
    return operation;
  }

  Future<void> shutdown() {
    return _shutdownOperation ??= (_pendingUpdate ?? Future<void>.value()).then(
      (_) async {
        if (!await _proxy.stopProxy()) {
          commonPrint.log(
            'stop system proxy failed',
            logLevel: LogLevel.warning,
          );
        }
      },
    );
  }
}

String proxyEnvCommand(int port, {required bool isWindows}) {
  final url = 'http://127.0.0.1:$port';
  return isWindows ? 'set \$env:all_proxy=$url' : 'export all_proxy=$url';
}
