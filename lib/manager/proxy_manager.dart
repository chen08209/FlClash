import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxyManager extends StatelessWidget {
  final Widget child;

  const ProxyManager({super.key, required this.child});

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
    return Selector3<AppFlowingState, Config, ClashConfig, ProxyState>(
      selector: (_, appFlowingState, config, clashConfig) => ProxyState(
        isStart: appFlowingState.isStart,
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
