import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

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
    windowExtManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await appController.handleBackOrExit();
    super.onWindowClose();
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    commonPrint.log('focus');
    render?.resume();
  }

  @override
  Future<void> onShouldTerminate() async {
    await appController.handleExit();
    super.onShouldTerminate();
  }

  @override
  void onWindowMoved() {
    super.onWindowMoved();
    windowManager.getPosition().then((offset) {
      ref.read(windowSettingProvider.notifier);
      // .update((state) => state.copyWith(top: offset.dy, left: offset.dx));
    });
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    ref
        .read(windowSettingProvider.notifier)
        .update(
          (state) => state.copyWith(width: size.width, height: size.height),
        );
  }

  @override
  void onWindowMinimize() async {
    appController.savePreferencesDebounce();
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
  Future<void> dispose() async {
    windowManager.removeListener(this);
    windowExtManager.removeListener(this);
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
        if ((version <= 10 || !isMobileView) && system.isMacOS) {
          return child!;
        }
        return Stack(
          children: [
            Column(
              children: [
                SizedBox(height: kHeaderHeight),
                Expanded(flex: 1, child: child!),
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
  bool _manuallyMaximized =
      false; // Track bounds-based manual maximize state
  Rect? _savedBounds; // Save window bounds before maximizing
  bool _isUpdatingMaximized =
      false; // Prevent concurrent maximize/unmaximize operations

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  Future<void> _initNotifier() async {
    isMaximizedNotifier.value = await windowManager.isMaximized();
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  @override
  void dispose() {
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    // Prevent concurrent execution to avoid race conditions
    if (_isUpdatingMaximized) return;
    _isUpdatingMaximized = true;

    try {
      final isMaximized = system.isWindows
          ? _windowsBoundsMaximized
          : await windowManager.isMaximized();

      if (isMaximized) {
        // Unmaximize and restore previous size
        if (system.isWindows) {
          if (_savedBounds != null) {
            // Restore saved window bounds if we have them
            try {
              await windowManager.setBounds(_savedBounds!);
              // Only clear saved bounds after successful restoration
              _savedBounds = null;
            } catch (e) {
              // If restoration fails, keep saved bounds and try unmaximize
              commonPrint.log('Failed to restore saved bounds: $e');
              await windowManager.unmaximize();
            }
          } else {
            // Window was maximized externally (e.g., Win+Up, drag to edge)
            // Use system unmaximize, then verify the actual state
            await windowManager.unmaximize();
            final actuallyMaximized = await windowManager.isMaximized();
            if (actuallyMaximized) {
              // If still maximized, window might be in snap state
              // Restore to a default reasonable size
              try {
                final display = await screenRetriever.getPrimaryDisplay();
                final visibleSize = display.visibleSize ?? display.size;

                // Validate display size before using it
                if (visibleSize.width > 0 && visibleSize.height > 0) {
                  await windowManager.setSize(
                    Size(visibleSize.width * 0.8, visibleSize.height * 0.8),
                  );
                  await windowManager.center();
                } else {
                  // Invalid display size, use hardcoded fallback
                  commonPrint.log(
                    'Invalid display size, using fallback dimensions',
                  );
                  await windowManager.setSize(const Size(1280, 720));
                  await windowManager.center();
                }
              } catch (e) {
                // Failed to get display info, use fallback size
                commonPrint.log('Failed to get display info: $e');
                await windowManager.setSize(const Size(1280, 720));
                await windowManager.center();
              }
            }
          }
          _windowsBoundsMaximized = false;
          isMaximizedNotifier.value = false;
        } else {
          // Non-Windows platforms: use standard unmaximize
          await windowManager.unmaximize();
          _windowsBoundsMaximized = false;
          isMaximizedNotifier.value = false;
        }
      } else {
        // Maximize window
        if (system.isWindows) {
          // Save current window bounds
          final currentPosition = await windowManager.getPosition();
          final currentSize = await windowManager.getSize();
          _savedBounds = Rect.fromLTWH(
            currentPosition.dx,
            currentPosition.dy,
            currentSize.width,
            currentSize.height,
          );

          // Determine which display the window is currently on by finding
          // the display that contains the window's center point
          final windowCenter = Offset(
            currentPosition.dx + currentSize.width / 2,
            currentPosition.dy + currentSize.height / 2,
          );

          final displays = await screenRetriever.getAllDisplays();
          Display? targetDisplay;

          for (final display in displays) {
            final displayBounds = Rect.fromLTWH(
              display.visiblePosition?.dx ?? 0,
              display.visiblePosition?.dy ?? 0,
              display.visibleSize?.width ?? display.size.width,
              display.visibleSize?.height ?? display.size.height,
            );
            if (displayBounds.contains(windowCenter)) {
              targetDisplay = display;
              break;
            }
          }

          // Fallback to primary display if window is not on any display
          targetDisplay ??= await screenRetriever.getPrimaryDisplay();

          // Validate display information before using it
          final visiblePosition = targetDisplay.visiblePosition ?? Offset.zero;
          final visibleSize = targetDisplay.visibleSize ?? targetDisplay.size;

          // Ensure we have valid dimensions
          if (visibleSize.width <= 0 || visibleSize.height <= 0) {
            // Display information is invalid, fallback to native maximize
            commonPrint.log(
              'Invalid display dimensions, using native maximize',
            );
            await windowManager.maximize();
            _windowsBoundsMaximized = false;
            isMaximizedNotifier.value = await windowManager.isMaximized();
          } else {
            await windowManager.setBounds(
              Rect.fromLTWH(
                visiblePosition.dx,
                visiblePosition.dy,
                visibleSize.width,
                visibleSize.height,
              ),
            );
            _windowsBoundsMaximized = true;
            isMaximizedNotifier.value = true;
          }
        } else {
          await windowManager.maximize();
          isMaximizedNotifier.value = await windowManager.isMaximized();
        }
      }
    } finally {
      _isUpdatingMaximized = false;
    }
  }

  Future<void> _updatePin() async {
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            _updatePin();
          },
          icon: ValueListenableBuilder(
            valueListenable: isPinNotifier,
            builder: (_, value, _) {
              return value
                  ? const Icon(Icons.push_pin)
                  : const Icon(Icons.push_pin_outlined);
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
            builder: (_, value, _) {
              return value
                  ? const Icon(Icons.filter_none, size: 20)
                  : const Icon(Icons.crop_square);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            appController.handleBackOrExit();
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
                color: context.colorScheme.secondary.opacity15,
                alignment: Alignment.centerLeft,
                height: kHeaderHeight,
              ),
            ),
          ),
          if (system.isMacOS)
            const Text(appName)
          else ...[
            Positioned(right: 0, child: _buildActions()),
          ],
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
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Transform.translate(
        offset: Offset(0, -1),
        child: Image.asset('assets/images/icon.png', width: 34, height: 34),
      ),
    );
  }
}
