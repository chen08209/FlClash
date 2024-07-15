import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _WindowContainerState extends State<WindowContainer> with WindowListener {
  _autoLaunchContainer(Widget child) {
    return Selector<Config, bool>(
      selector: (_, config) => config.autoLaunch,
      builder: (_, isAutoLaunch, child) {
        autoLaunch?.updateStatus(isAutoLaunch);
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _autoLaunchContainer(widget.child);
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await globalState.appController.handleBackOrExit();
    super.onWindowClose();
  }

  @override
  Future<void> onWindowMoved() async {
    super.onWindowMoved();
    final offset = await windowManager.getPosition();
    final config = globalState.appController.config;
    config.windowProps = config.windowProps.copyWith(
      top: offset.dy,
      left: offset.dx,
    );
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    final config = globalState.appController.config;
    config.windowProps = config.windowProps.copyWith(
      width: size.width,
      height: size.height,
    );
  }

  @override
  void onWindowMinimize() async {
    await globalState.appController.savePreferences();
    super.onWindowMinimize();
  }

  @override
  Future<void> dispose() async {
    windowManager.removeListener(this);
    super.dispose();
  }
}
