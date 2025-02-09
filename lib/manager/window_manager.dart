import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener, WindowExtListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      appSettingProvider.select((state) => state.autoLaunch),
      (prev, next) {
        if (prev != next) {
          debouncer.call(
            DebounceTag.autoLaunch,
            () {
              autoLaunch?.updateStatus(next);
            },
          );
        }
      },
    );
    windowExtManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await globalState.appController.handleBackOrExit();
    super.onWindowClose();
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    render?.resume();
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    render?.pause();
  }

  @override
  Future<void> onShouldTerminate() async {
    await globalState.appController.handleExit();
    super.onShouldTerminate();
  }

  @override
  Future<void> onWindowMoved() async {
    super.onWindowMoved();
    final offset = await windowManager.getPosition();
    ref.read(windowSettingProvider.notifier).updateState(
          (state) => state.copyWith(
            top: offset.dy,
            left: offset.dx,
          ),
        );
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    ref.read(windowSettingProvider.notifier).updateState(
          (state) => state.copyWith(
            width: size.width,
            height: size.height,
          ),
        );
  }

  @override
  void onWindowMinimize() async {
    globalState.appController.savePreferencesDebounce();
    super.onWindowMinimize();
  }

  @override
  Future<void> onTaskbarCreated() async {
    globalState.appController.updateTray(true);
    super.onTaskbarCreated();
  }

  @override
  Future<void> dispose() async {
    windowManager.removeListener(this);
    windowExtManager.removeListener(this);
    super.dispose();
  }
}

class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final version = ref.watch(versionProvider);
        if (version <= 10 && Platform.isMacOS) {
          return child!;
        }
        return Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: kHeaderHeight,
                ),
                Expanded(
                  flex: 1,
                  child: child!,
                ),
              ],
            ),
            const WindowHeader(),
          ],
        );
      },
      child: child,
    );
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
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    super.dispose();
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
            globalState.appController.handleBackOrExit();
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
                color: context.colorScheme.secondary.toSoft,
                alignment: Alignment.centerLeft,
                height: kHeaderHeight,
              ),
            ),
          ),
          if (Platform.isMacOS)
            const Text(
              appName,
            )
          else ...[
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
