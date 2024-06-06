import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/plugins/app.dart';

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
    with ClashMessageListener {
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
  void onTun(String fd) {
    proxyManager.setProtect(int.parse(fd));
    super.onTun(fd);
  }

  @override
  void onProcess(Metadata metadata) async {
    var packageName = await app?.getPackageName(metadata);
    globalState.packageNameMap[metadata.uid] = packageName;
    super.onProcess(metadata);
  }
}
