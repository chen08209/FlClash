import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowContainer extends StatefulWidget {
  final Widget child;

  const WindowContainer({
    super.key,
    required this.child,
  });

  @override
  State<WindowContainer> createState() => _WindowContainerState();
}

class _WindowContainerState extends State<WindowContainer>
    with WindowListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await context.appController.handleBackOrExit();
    super.onWindowClose();
  }

  @override
  void onWindowMinimize() async {
    await context.appController.savePreferences();
    super.onWindowMinimize();
  }

  @override
  Future<void> dispose() async {
    windowManager.removeListener(this);
    super.dispose();
  }
}
