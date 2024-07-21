import 'dart:io';

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
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: kHeaderHeight,
            ),
            Expanded(
              flex: 1,
              child: _autoLaunchContainer(widget.child),
            ),
          ],
        ),
        const WindowHeader(),
      ],
    );
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

class WindowHeader extends StatefulWidget {
  const WindowHeader({super.key});

  @override
  State<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends State<WindowHeader> {
  final isMaximizedNotifier = ValueNotifier<bool>(false);
  final isPinNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  _initNotifier() async {
    isMaximizedNotifier.value = await windowManager.isMaximized();
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  @override
  void dispose() {
    super.dispose();
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
  }

  _updateMaximized() {
    isMaximizedNotifier.value = !isMaximizedNotifier.value;
    switch (isMaximizedNotifier.value) {
      case true:
        windowManager.maximize();
      case false:
        windowManager.unmaximize();
    }
  }

  _updatePin() {
    isPinNotifier.value = !isPinNotifier.value;
    windowManager.setAlwaysOnTop(isPinNotifier.value);
  }

  _buildActions() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            _updatePin();
          },
          icon: ValueListenableBuilder(
            valueListenable: isPinNotifier,
            builder: (_, value, ___) {
              return value
                  ? const Icon(
                      Icons.push_pin,
                    )
                  : const Icon(
                      Icons.push_pin_outlined,
                    );
            },
          ),
        ),
        IconButton(
          onPressed: () {
            windowManager.minimize();
          },
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          onPressed: () async {
            _updateMaximized();
          },
          icon: ValueListenableBuilder(
            valueListenable: isMaximizedNotifier,
            builder: (_, value, ___) {
              return value
                  ? const Icon(
                      Icons.filter_none,
                      size: 20,
                    )
                  : const Icon(
                      Icons.crop_square,
                    );
            },
          ),
        ),
        IconButton(
          onPressed: () {
            windowManager.close();
          },
          icon: const Icon(Icons.close),
        ),
        // const SizedBox(
        //   width: 8,
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            child: GestureDetector(
              onPanStart: (_) {
                windowManager.startDragging();
              },
              onDoubleTap: () {
                _updateMaximized();
              },
              child: Container(
                color: context.colorScheme.surface,
                alignment: Alignment.centerLeft,
                height: kHeaderHeight,
              ),
            ),
          ),
          if (!Platform.isMacOS) ...[
            const Positioned(
              left: 0,
              child: AppIcon(),
            ),
            Positioned(
              right: 0,
              child: _buildActions(),
            ),
          ]
        ],
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircleAvatar(
              foregroundImage: AssetImage("assets/images/icon.png"),
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            appName,
          ),
        ],
      ),
    );
  }
}
