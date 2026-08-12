import 'dart:io';

import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyManager extends ConsumerStatefulWidget {
  final Widget child;

  const ProxyManager({super.key, required this.child});

  @override
  ConsumerState createState() => _ProxyManagerState();
}

class _ProxyManagerState extends ConsumerState<ProxyManager> {
  Future<void> _pendingUpdate = Future.value();
  ProxyState? _target;

  // The core binds the mixed port asynchronously; pointing the OS proxy at
  // a port nothing listens on cuts the whole system off the network.
  Future<bool> _isPortListening(int port) async {
    try {
      final socket = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(milliseconds: 500),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _updateProxy(ProxyState proxyState) async {
    final isStart = proxyState.isStart;
    final systemProxy = proxyState.systemProxy;
    final port = proxyState.port;
    bool? result;
    if (isStart && systemProxy) {
      // Keep waiting rather than giving up: nothing re-triggers this until
      // the proxy state itself changes again.
      while (!await _isPortListening(port)) {
        if (!mounted || _target != proxyState) {
          commonPrint.log(
            'system proxy not applied: 127.0.0.1:$port is not listening',
            logLevel: LogLevel.warning,
          );
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      result = await proxy?.startProxy(port, proxyState.bassDomain);
    } else {
      result = await proxy?.stopProxy();
    }
    if (result == false) {
      commonPrint.log('update system proxy failed', logLevel: LogLevel.warning);
    }
  }

  void _scheduleUpdateProxy(ProxyState proxyState) {
    _target = proxyState;
    _pendingUpdate = _pendingUpdate
        .then((_) => _updateProxy(proxyState))
        .catchError((Object error) {
          commonPrint.log(
            'update system proxy failed: $error',
            logLevel: LogLevel.warning,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxyStateProvider, (prev, next) {
      if (prev != next) {
        _scheduleUpdateProxy(next);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
