import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/launch.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window/window.dart';

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
  int _windowBlurRevision = 0;

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
    ref.listenManual(windowBlurRequestProvider, (prev, next) {
      if (prev != next) {
        unawaited(_applyWindowBlur(next));
      }
    }, fireImmediately: true);
    desktopWindow.addListener(this);
  }

  Future<void> _applyWindowBlur(WindowBlurRequest request) async {
    final port = windowPort;
    if (port == null) {
      return;
    }
    final revision = ++_windowBlurRevision;
    bool active;
    try {
      active = await port.setBlur(
        enabled: request.enabled,
        brightness: request.brightness,
        tint: request.tint,
      );
    } catch (error) {
      commonPrint.log(
        'Window blur failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      active = false;
    }
    if (!mounted || revision != _windowBlurRevision) {
      return;
    }
    ref.read(windowBlurProvider.notifier).value = active;
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
  }

  /// Another launch, or a Dock reopen, asked for the window.
  @override
  void onWindowActivate() {
    super.onWindowActivate();
    unawaited(windowPort?.show());
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
  void onWindowGeometryChanged() {
    super.onWindowGeometryChanged();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMaximize() {
    _invalidateWindowGeometryCapture();
    super.onWindowMaximize();
    if (system.isWindows) {
      unawaited(desktopWindow.setRoundedCorners(false));
    }
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    if (system.isWindows) {
      unawaited(desktopWindow.setRoundedCorners(true));
    }
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
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    commonPrint.log('restore');
    super.onWindowRestore();
    _scheduleWindowGeometryCapture();
  }

  @override
  void dispose() {
    _invalidateWindowGeometryCapture();
    desktopWindow.removeListener(this);
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

@immutable
class WindowCaptionState {
  const WindowCaptionState({
    this.isPinned = false,
    this.isMaximized = false,
    this.isFullScreen = false,
  });

  final bool isPinned;
  final bool isMaximized;
  final bool isFullScreen;

  WindowCaptionState copyWith({
    bool? isPinned,
    bool? isMaximized,
    bool? isFullScreen,
  }) {
    return WindowCaptionState(
      isPinned: isPinned ?? this.isPinned,
      isMaximized: isMaximized ?? this.isMaximized,
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WindowCaptionState &&
        other.isPinned == isPinned &&
        other.isMaximized == isMaximized &&
        other.isFullScreen == isFullScreen;
  }

  @override
  int get hashCode => Object.hash(isPinned, isMaximized, isFullScreen);
}

/// Maximize and fullscreen are written only from window events: the window
/// manager can change both on its own, and on Linux a maximize request is
/// applied later, so reading the state back right after the call is stale.
class WindowCaptionController extends ValueNotifier<WindowCaptionState>
    with WindowListener {
  WindowCaptionController() : super(const WindowCaptionState()) {
    desktopWindow.addListener(this);
    unawaited(_syncFromWindow());
  }

  bool _disposed = false;

  Future<void> _syncFromWindow() async {
    final states = await Future.wait<bool>([
      desktopWindow.isAlwaysOnTop(),
      desktopWindow.isMaximized(),
      desktopWindow.isFullScreen(),
    ]);
    _set(
      WindowCaptionState(
        isPinned: states[0],
        isMaximized: states[1],
        isFullScreen: states[2],
      ),
    );
  }

  void _set(WindowCaptionState state) {
    if (_disposed) return;
    value = state;
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    _set(value.copyWith(isMaximized: true));
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _set(value.copyWith(isMaximized: false));
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _set(value.copyWith(isFullScreen: true));
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _set(value.copyWith(isFullScreen: false));
  }

  Future<void> toggleMaximized() async {
    if (await desktopWindow.isFullScreen()) {
      await desktopWindow.setFullScreen(false);
    } else if (await desktopWindow.isMaximized()) {
      await desktopWindow.unmaximize();
    } else {
      await desktopWindow.maximize();
    }
  }

  Future<void> togglePin() async {
    final isPinned = await desktopWindow.isAlwaysOnTop();
    await desktopWindow.setAlwaysOnTop(!isPinned);
    _set(value.copyWith(isPinned: await desktopWindow.isAlwaysOnTop()));
  }

  @override
  void dispose() {
    _disposed = true;
    desktopWindow.removeListener(this);
    super.dispose();
  }
}

class WindowHeader extends ConsumerStatefulWidget {
  const WindowHeader({super.key});

  @override
  ConsumerState<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends ConsumerState<WindowHeader> {
  final caption = WindowCaptionController();

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translucent =
        ref.watch(windowBlurProvider) && !ref.watch(isMobileViewProvider);
    return WindowHeaderBar(
      height: kHeaderHeight,
      translucent: translucent,
      onDragStart: desktopWindow.startDragging,
      onDoubleTap: caption.toggleMaximized,
      title: system.isMacOS ? const Text(appName) : null,
      actions: system.isMacOS
          ? null
          : WindowHeaderActions(
              state: caption,
              onPin: caption.togglePin,
              onMinimize: desktopWindow.minimize,
              onMaximize: caption.toggleMaximized,
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
    this.translucent = false,
    this.title,
    this.actions,
  });

  final double height;
  final VoidCallback onDragStart;
  final VoidCallback onDoubleTap;
  final bool translucent;
  final Widget? title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: translucent ? Colors.transparent : null,
      shape: translucent
          ? null
          : Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
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
                  color: translucent
                      ? colorScheme.surfaceContainer.withValues(
                          alpha: kSidebarBlurOpacity,
                        )
                      : colorScheme.surfaceContainerHighest,
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
                      minimumSize: WidgetStatePropertyAll(
                        getCaptionButtonSize(height),
                      ),
                      maximumSize: WidgetStatePropertyAll(
                        getCaptionButtonSize(height),
                      ),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      shape: const WidgetStatePropertyAll(AppShape.none),
                      foregroundColor: WidgetStatePropertyAll(
                        context.colorScheme.onSurface,
                      ),
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
    required this.state,
    required this.onPin,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
  });

  final ValueListenable<WindowCaptionState> state;
  final VoidCallback onPin;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (_, state, _) {
        final (maximizeGlyph, maximizeTooltip) = switch (state) {
          WindowCaptionState(isFullScreen: true) => (
            CaptionGlyph.restore,
            appLocalizations.exitFullScreen,
          ),
          WindowCaptionState(isMaximized: true) => (
            CaptionGlyph.restore,
            appLocalizations.unmaximize,
          ),
          _ => (CaptionGlyph.maximize, appLocalizations.maximize),
        };
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                tooltip: state.isPinned
                    ? appLocalizations.unpinWindow
                    : appLocalizations.pinWindow,
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(CircleBorder()),
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  maximumSize: WidgetStatePropertyAll(Size.infinite),
                  iconSize: WidgetStatePropertyAll(pinIconSize),
                ),
                onPressed: onPin,
                icon: AnimatedGlyph(
                  glyph: AppGlyphs.pin,
                  filled: state.isPinned,
                ),
              ),
            ),
            IconButton(
              tooltip: appLocalizations.minimize,
              onPressed: onMinimize,
              icon: const CaptionIcon(CaptionGlyph.minimize),
            ),
            IconButton(
              tooltip: maximizeTooltip,
              onPressed: onMaximize,
              icon: CaptionIcon(maximizeGlyph),
            ),
            IconButton(
              tooltip: appLocalizations.close,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? context.colorScheme.error : null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? context.colorScheme.onError : null;
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.pressed)
                      ? context.colorScheme.onError.opacity12
                      : Colors.transparent;
                }),
              ),
              onPressed: onClose,
              icon: const CaptionIcon(CaptionGlyph.close),
            ),
          ],
        );
      },
    );
  }
}
