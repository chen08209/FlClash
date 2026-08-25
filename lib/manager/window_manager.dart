import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/launch.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.autoLaunch), (
      prev,
      next,
    ) {
      if (prev != next) {
        debouncer.call(FunctionTag.autoLaunch, () {
          autoLaunch?.updateStatus(next);
        });
      }
    });
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await ref.read(systemActionProvider.notifier).handleClose();
    super.onWindowClose();
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    commonPrint.log('focus');
    render?.resume();
  }

  @override
  Future<void> onWindowShouldTerminate() async {
    await ref.read(systemActionProvider.notifier).handleExit();
    super.onWindowShouldTerminate();
  }

  @override
  void onWindowMoved() {
    super.onWindowMoved();
    windowManager.getPosition().then((offset) {
      if (!mounted) {
        return;
      }
      ref
          .read(windowSettingProvider.notifier)
          .update((state) => state.copyWith(top: offset.dy, left: offset.dx));
    });
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    if (!mounted) {
      return;
    }
    ref
        .read(windowSettingProvider.notifier)
        .update(
          (state) => state.copyWith(width: size.width, height: size.height),
        );
  }

  @override
  void onWindowMinimize() async {
    ref.read(storeActionProvider.notifier).savePreferencesDebounce();
    commonPrint.log('minimize');
    render?.pause();
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    commonPrint.log('restore');
    render?.resume();
    super.onWindowRestore();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final isMobileView = ref.watch(isMobileViewProvider);
        final version = ref.watch(versionProvider);
        final showsHeader = showsWindowHeader(
          isDesktop: system.isDesktop,
          isMacOS: system.isMacOS,
          version: version,
          isMobileView: isMobileView,
        );
        if (!showsHeader) {
          return child!;
        }
        return WindowHeaderLayout(
          height: kHeaderHeight,
          header: const WindowHeader(),
          child: child!,
        );
      },
      child: child,
    );
  }
}

class WindowHeaderLayout extends StatelessWidget {
  const WindowHeaderLayout({
    super.key,
    required this.height,
    required this.header,
    required this.child,
  });

  final double height;
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay.wrap(
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: height),
              Expanded(flex: 1, child: child),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: header),
        ],
      ),
    );
  }
}

class WindowHeader extends ConsumerStatefulWidget {
  const WindowHeader({super.key});

  @override
  ConsumerState<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends ConsumerState<WindowHeader> {
  final isMaximizedNotifier = ValueNotifier<bool>(false);
  final isPinNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  Future<void> _initNotifier() async {
    final isMaximized = await windowManager.isMaximized();
    final isPin = await windowManager.isAlwaysOnTop();
    if (!mounted) return;
    isMaximizedNotifier.value = isMaximized;
    isPinNotifier.value = isPin;
  }

  @override
  void dispose() {
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.unmaximize();
      if (system.isWindows) {
        unawaited(windowManager.setWindowCornerPreference(round: true));
      }
    } else {
      await windowManager.maximize();
      if (system.isWindows) {
        unawaited(windowManager.setWindowCornerPreference(round: false));
      }
    }
    final res = await windowManager.isMaximized();
    if (mounted) {
      isMaximizedNotifier.value = res;
    }
  }

  Future<void> _updatePin() async {
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    final res = await windowManager.isAlwaysOnTop();
    if (!mounted) return;
    isPinNotifier.value = res;
  }

  @override
  Widget build(BuildContext context) {
    return WindowHeaderBar(
      height: kHeaderHeight,
      onDragStart: windowManager.startDragging,
      onDoubleTap: _updateMaximized,
      title: system.isMacOS ? const Text(appName) : null,
      actions: system.isMacOS
          ? null
          : WindowHeaderActions(
              isPinNotifier: isPinNotifier,
              isMaximizedNotifier: isMaximizedNotifier,
              onPin: _updatePin,
              onMinimize: windowManager.minimize,
              onMaximize: _updateMaximized,
              onClose: () {
                ref.read(systemActionProvider.notifier).handleClose();
              },
            ),
    );
  }
}

class WindowHeaderBar extends StatelessWidget {
  const WindowHeaderBar({
    super.key,
    required this.height,
    required this.onDragStart,
    required this.onDoubleTap,
    this.title,
    this.actions,
  });

  final double height;
  final VoidCallback onDragStart;
  final VoidCallback onDoubleTap;
  final Widget? title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (_) {
                  onDragStart();
                },
                onDoubleTap: onDoubleTap,
                child: ColoredBox(
                  color: context.colorScheme.secondary.opacity15,
                ),
              ),
            ),
            if (title != null)
              Positioned.fill(
                child: IgnorePointer(child: Center(child: title)),
              ),
            if (actions != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: IconButtonTheme(
                  data: IconButtonThemeData(
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: WidgetStatePropertyAll(Size.square(height)),
                      maximumSize: WidgetStatePropertyAll(Size.square(height)),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    ),
                  ),
                  child: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WindowHeaderActions extends StatelessWidget {
  const WindowHeaderActions({
    super.key,
    required this.isPinNotifier,
    required this.isMaximizedNotifier,
    required this.onPin,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
  });

  final ValueNotifier<bool> isPinNotifier;
  final ValueNotifier<bool> isMaximizedNotifier;
  final VoidCallback onPin;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: isPinNotifier,
          builder: (_, value, _) {
            return IconButton(
              tooltip: value
                  ? appLocalizations.unpinWindow
                  : appLocalizations.pinWindow,
              onPressed: onPin,
              icon: value
                  ? const Icon(Icons.push_pin)
                  : const Icon(Icons.push_pin_outlined),
            );
          },
        ),
        IconButton(
          tooltip: appLocalizations.minimize,
          onPressed: onMinimize,
          icon: const Icon(Icons.remove),
        ),
        ValueListenableBuilder(
          valueListenable: isMaximizedNotifier,
          builder: (_, value, _) {
            return IconButton(
              tooltip: value
                  ? appLocalizations.unmaximize
                  : appLocalizations.maximize,
              onPressed: onMaximize,
              icon: value
                  ? const Icon(Icons.filter_none, size: 20)
                  : const Icon(Icons.crop_square),
            );
          },
        ),
        IconButton(
          tooltip: appLocalizations.close,
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: AppShape.md,
      ),
      padding: const EdgeInsets.all(8),
      child: Transform.translate(
        offset: const Offset(0, -1),
        child: Image.asset('assets/images/icon.png', width: 34, height: 34),
      ),
    );
  }
}
