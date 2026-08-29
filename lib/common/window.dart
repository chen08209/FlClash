import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class Window implements WindowPort {
  static Window? _instance;
  bool _supportsPosition = false;

  Window._internal();

  factory Window() {
    _instance ??= Window._internal();
    return _instance!;
  }

  Future<void> init(int version, WindowProps props) async {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      await singleInstanceLock.requestActivation();
      exit(0);
    }
    if (system.isWindows) {
      protocol.register('clash');
      protocol.register('clashmeta');
      protocol.register('flclash');
    }
    await windowManager.ensureInitialized();
    _supportsPosition = !system.isMacOS;
    if (system.isLinux) {
      _supportsPosition = await windowManager.isPositionSupported();
    }
    final WindowOptions windowOptions = WindowOptions(
      size: props.size,
      minimumSize: const Size(380, 400),
    );
    if (!system.isMacOS || version > 10) {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await windowManager.setMaximizable(true);
    // On Linux the compositor only honors positioning after the window is shown;
    // elsewhere position it pre-show to avoid a visible jump.
    if (!system.isLinux) {
      await _windowPosition(props);
    }
    await windowManager.waitUntilReadyToShow(windowOptions);
    if (system.isLinux) {
      await _windowPosition(props);
    }
    await windowManager.setPreventClose(true);
    singleInstanceLock.activationRequests.listen((_) => show());
  }

  Future<void> _windowPosition(WindowProps props) async {
    if (_supportsPosition) {
      final left = props.left;
      final top = props.top;
      if (left == null || top == null) {
        await windowManager.setAlignment(Alignment.center);
      } else {
        final size = props.size;
        final right = left + size.width;
        final bottom = top + size.height;
        final displays = await screenRetriever.getAllDisplays();
        final isPositionValid = displays.any((display) {
          final visiblePosition = display.visiblePosition;
          if (visiblePosition == null) {
            return false;
          }
          final displayBounds = Rect.fromLTWH(
            visiblePosition.dx,
            visiblePosition.dy,
            display.size.width,
            display.size.height,
          );
          return displayBounds.contains(Offset(left, top)) ||
              displayBounds.contains(Offset(right, bottom));
        });
        if (isPositionValid) {
          await windowManager.setPosition(Offset(left, top));
        } else {
          await windowManager.setAlignment(Alignment.center);
        }
      }
    }
  }

  @override
  Future<WindowProps?> captureNormalGeometry(WindowProps current) async {
    final states = await Future.wait<bool>([
      windowManager.isMaximized(),
      windowManager.isFullScreen(),
      windowManager.isMinimized(),
    ]);
    if (states.any((state) => state)) {
      return null;
    }

    final bounds = await windowManager.getBounds();
    if (!bounds.width.isFinite ||
        !bounds.height.isFinite ||
        bounds.width <= 0 ||
        bounds.height <= 0) {
      return null;
    }
    final hasValidPosition =
        bounds.left.isFinite && bounds.top.isFinite && _supportsPosition;
    return current.copyWith(
      width: bounds.width,
      height: bounds.height,
      left: hasValidPosition ? bounds.left : current.left,
      top: hasValidPosition ? bounds.top : current.top,
    );
  }

  /// Every desktop runner leaves the window hidden until [init] reveals it, so
  /// a failure before that point would leave the error screen with no window.
  Future<void> showInitFailure() async {
    try {
      await windowManager.ensureInitialized();
      if (await windowManager.isVisible()) {
        return;
      }
      await windowManager.waitUntilReadyToShow(
        const WindowOptions(size: Size(680, 580), center: true),
      );
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      commonPrint.log(
        'show init failure window failed ${e.toString()}',
        logLevel: LogLevel.warning,
      );
    }
  }

  @override
  Future<void> show() async {
    render?.resume();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setSkipTaskbar(false);
  }

  @override
  Future<bool> get isVisible async {
    final value = await windowManager.isVisible();
    commonPrint.log('window visible check: $value');
    return value;
  }

  @override
  Future<void> close() async {
    await windowManager.close();
  }

  @override
  void forceExit() {
    exit(0);
  }

  @override
  Future<void> hide() async {
    render?.pause();
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }
}

final window = system.isDesktop ? Window() : null;
