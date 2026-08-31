import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/launch.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

const _windowGeometryDelay = Duration(milliseconds: 120);

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener {
  Timer? _windowGeometryTimer;
  int _windowGeometryRevision = 0;

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

  void _scheduleWindowGeometryCapture() {
    final revision = ++_windowGeometryRevision;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = Timer(_windowGeometryDelay, () {
      _windowGeometryTimer = null;
      unawaited(_captureWindowGeometry(revision));
    });
  }

  Future<void> _captureWindowGeometry(int revision) async {
    final port = windowPort;
    if (port == null || !mounted) {
      return;
    }
    final current = ref.read(windowSettingProvider);
    WindowProps? geometry;
    try {
      geometry = await port.captureNormalGeometry(current);
    } catch (error) {
      commonPrint.log(
        'Window geometry capture failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return;
    }
    if (!mounted || revision != _windowGeometryRevision || geometry == null) {
      return;
    }
    ref.read(windowSettingProvider.notifier).value = geometry;
  }

  void _invalidateWindowGeometryCapture() {
    _windowGeometryRevision++;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = null;
  }

  @override
  void onWindowMove() {
    super.onWindowMove();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMoved() {
    super.onWindowMoved();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowResize() {
    super.onWindowResize();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMaximize() {
    _invalidateWindowGeometryCapture();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowEnterFullScreen() {
    _invalidateWindowGeometryCapture();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMinimize() async {
    _invalidateWindowGeometryCapture();
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
    _scheduleWindowGeometryCapture();
  }

  @override
  void dispose() {
    _invalidateWindowGeometryCapture();
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
      shape: Border(
        bottom: BorderSide(color: context.colorScheme.outlineVariant),
      ),
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
                  color: context.colorScheme.surfaceContainerHighest,
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
