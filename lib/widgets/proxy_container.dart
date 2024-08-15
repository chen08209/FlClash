import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxyContainer extends StatelessWidget {
  final Widget child;

  const ProxyContainer({super.key, required this.child});

  _updateProxy(ProxyState proxyState) {
    final isStart = proxyState.isStart;
    final systemProxy = proxyState.systemProxy;
    final port = proxyState.port;
    if (isStart && systemProxy) {
      proxy?.startProxy(port);
    }else{
      proxy?.stopProxy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<AppState, Config, ClashConfig, ProxyState>(
      selector: (_, appState, config, clashConfig) => ProxyState(
        isStart: appState.isStart,
        systemProxy: config.desktopProps.systemProxy,
        port: clashConfig.mixedPort,
      ),
      builder: (_, state, child) {
        _updateProxy(state);
        return child!;
      },
      child: child,
    );
  }
}
