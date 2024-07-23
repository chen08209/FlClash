import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class ClashMessageContainer extends StatefulWidget {
  final Widget child;

  const ClashMessageContainer({
    super.key,
    required this.child,
  });

  @override
  State<ClashMessageContainer> createState() => _ClashMessageContainerState();
}

class _ClashMessageContainerState extends State<ClashMessageContainer>
    with AppMessageListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
  }

  @override
  Future<void> dispose() async {
    clashMessage.removeListener(this);
    super.dispose();
  }

  @override
  void onDelay(Delay delay) {
    final appController = globalState.appController;
    appController.setDelay(delay);
    super.onDelay(delay);
  }

  @override
  void onLog(Log log) {
    globalState.appController.appState.addLog(log);
    super.onLog(log);
  }

  @override
  void onRequest(Connection connection) async {
    globalState.appController.appState.addRequest(connection);
    super.onRequest(connection);
  }

  @override
  void onLoaded(String groupName) {
    final appController = globalState.appController;
    final currentSelectedMap = appController.config.currentSelectedMap;
    final proxyName = currentSelectedMap[groupName];
    if (proxyName == null) return;
    globalState.changeProxy(
      config: appController.config,
      groupName: groupName,
      proxyName: proxyName,
    );
    appController.addCheckIpNumDebounce();
    super.onLoaded(proxyName);
  }

  @override
  void onStarted(String runTime) {
    super.onStarted(runTime);
    proxy?.updateStartTime();
    final appController = globalState.appController;
    appController.rawApplyProfile().then((_) {
      appController.addCheckIpNumDebounce();
    });
  }
}
