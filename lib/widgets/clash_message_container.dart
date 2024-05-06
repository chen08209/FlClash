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
    context.appController.setDelay(delay);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.updateSortNumDebounce ??= debounce<Function()>(
            () {
          context.appController.appState.sortNum++;
        },
        milliseconds: appConstant.httpTimeoutDuration.inMilliseconds,
      );
      globalState.updateSortNumDebounce!();
    });
    super.onDelay(delay);
  }

  @override
  void onLog(Log log) {
    debugPrint("$log");
    context.appController.appState.addLog(log);
    super.onLog(log);
  }

  @override
  void onTun(String fd) {
    proxyManager.setProtect(int.parse(fd));
    super.onTun(fd);
  }

  @override
  void onNow(Now now) {
    List<Group> groups = List.from(context.appController.appState.groups);
    final index = groups.indexWhere(
      (element) => element.name == now.name,
    );
    if (index == -1 || groups[index].now == now.value) return;
    groups[index] = groups[index].copyWith(now: now.value);
    context.appController.appState.groups = groups;
    super.onNow(now);
  }

  @override
  void onProcess(Metadata metadata) async {
    var packageName = await app?.getPackageName(metadata);
    globalState.packageNameMap[metadata.uid] = packageName;
    super.onProcess(metadata);
  }
}
