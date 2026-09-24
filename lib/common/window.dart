import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window/window.dart';

class Window implements WindowPort {
  static Window? _instance;
  bool _supportsPosition = false;
  WindowEffect? _blurEffect;
  late final WindowVisibilityController _visibility =
      WindowVisibilityController(
        showWindow: _showWindow,
        hideWindow: _hideWindow,
        isWindowVisible: _isWindowVisible,
        setSkipTaskbar: (skip) => desktopWindow.setSkipTaskbar(skip),
        dockSettleDuration: system.isMacOS
            ? const Duration(seconds: 1)
            : Duration.zero,
      );

  Window._internal();

  factory Window() {
    _instance ??= Window._internal();
    return _instance!;
  }

  Future<void> init(int version, WindowProps props) async {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      commonPrint.log('another instance owns the data directory, exiting');
      exit(0);
    }
    if (!safeModeBuild) {
      if (system.isWindows) {
        for (final scheme in protocolSchemes) {
          protocol.register(scheme);
        }
      }
      if (system.isLinux) {
        unawaited(protocol.registerLinux(protocolSchemes));
      }
    }
    await desktopWindow.ensureInitialized();
    _supportsPosition = !system.isMacOS;
    if (system.isLinux) {
      _supportsPosition = await desktopWindow.isPositionSupported();
    }
    if (!system.isMacOS || version > 10) {
      await desktopWindow.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await desktopWindow.setSize(props.size);
    await desktopWindow.setMinimumSize(const Size(380, 400));
    await _windowPosition(props);
    await desktopWindow.setPreventClose(true);
  }

  Future<void> _windowPosition(WindowProps props) async {
    if (_supportsPosition) {
      final left = props.left;
      final top = props.top;
      if (left == null || top == null) {
        await desktopWindow.setAlignment(Alignment.center);
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
          await desktopWindow.setPosition(Offset(left, top));
        } else {
          await desktopWindow.setAlignment(Alignment.center);
        }
      }
    }
  }

  @override
  Future<WindowProps?> captureNormalGeometry(WindowProps current) async {
    final states = await Future.wait<bool>([
      desktopWindow.isMaximized(),
      desktopWindow.isFullScreen(),
      desktopWindow.isMinimized(),
    ]);
    if (states.any((state) => state)) {
      return null;
    }

    final bounds = await desktopWindow.getBounds();
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

  /// A probe that finds no effect is not cached, so a failure at startup
  /// does not pin the toggle to off for the rest of the session.
  Future<WindowEffect> _resolveBlurEffect() async {
    final cached = _blurEffect;
    if (cached != null) {
      return cached;
    }
    final candidates = system.isMacOS
        ? const [WindowEffect.blur]
        : const [WindowEffect.acrylic, WindowEffect.blur];
    for (final effect in candidates) {
      if (await desktopWindow.isEffectSupported(effect)) {
        return _blurEffect = effect;
      }
    }
    return WindowEffect.none;
  }

  /// Only Windows 10's accent blur uses the tint; it draws nothing without one.
  @override
  Future<bool> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  }) async {
    if (system.isLinux) {
      return false;
    }
    final effect = enabled ? await _resolveBlurEffect() : WindowEffect.none;
    await desktopWindow.setEffect(
      effect,
      tint: system.isWindows
          ? tint.withValues(alpha: kSidebarBlurOpacity)
          : null,
      brightness: brightness,
    );
    return effect != WindowEffect.none;
  }

  /// Every desktop runner leaves the window hidden until [init] reveals it, so
  /// a failure before that point would leave the error screen with no window.
  Future<void> showInitFailure() async {
    try {
      await desktopWindow.ensureInitialized();
      if (await desktopWindow.isVisible()) {
        return;
      }
      await desktopWindow.setSize(const Size(680, 580));
      await desktopWindow.center();
      await desktopWindow.show();
      await desktopWindow.focus();
    } catch (e) {
      commonPrint.log(
        'show init failure window failed ${e.toString()}',
        logLevel: LogLevel.warning,
      );
    }
  }

  @override
  Future<void> show() => _visibility.show();

  @override
  Future<void> hide() => _visibility.hide();

  @override
  Future<void> toggle() => _visibility.toggle();

  Future<void> _showWindow() async {
    await desktopWindow.show();
    await desktopWindow.focus();
  }

  Future<void> _hideWindow() async {
    await desktopWindow.hide();
  }

  Future<bool> _isWindowVisible() async {
    final value = await desktopWindow.isVisible();
    commonPrint.log('window visible check: $value');
    return value;
  }

  @override
  Future<void> close() async {
    await desktopWindow.close();
  }

  @override
  void forceExit() {
    exit(0);
  }
}

/// Serializes visibility requests so a burst of hotkey toggles lands in
/// order, and holds back the Dock-hiding activation policy switch while a
/// preceding regular switch settles: flipping regular → accessory → regular
/// within about a second leaves macOS with stray Dock icons.
class WindowVisibilityController {
  WindowVisibilityController({
    required Future<void> Function() showWindow,
    required Future<void> Function() hideWindow,
    required Future<bool> Function() isWindowVisible,
    required Future<void> Function(bool skip) setSkipTaskbar,
    required this.dockSettleDuration,
  }) : _showWindow = showWindow,
       _hideWindow = hideWindow,
       _isWindowVisible = isWindowVisible,
       _setSkipTaskbar = setSkipTaskbar;

  final Future<void> Function() _showWindow;
  final Future<void> Function() _hideWindow;
  final Future<bool> Function() _isWindowVisible;
  final Future<void> Function(bool skip) _setSkipTaskbar;
  final Duration dockSettleDuration;

  Future<void>? _queue;
  Timer? _dockSettleTimer;
  bool _dockHidePending = false;

  Future<void> show() => _enqueue(_show);

  Future<void> hide() => _enqueue(_hide);

  Future<void> toggle() => _enqueue(() async {
    if (await _isWindowVisible()) {
      await _hide();
    } else {
      await _show();
    }
  });

  Future<void> _enqueue(Future<void> Function() step) {
    final previous = _queue;
    final result = previous == null ? step() : previous.then((_) => step());
    final tail = result.catchError((_) {});
    _queue = tail;
    tail.whenComplete(() {
      if (identical(_queue, tail)) {
        _queue = null;
      }
    });
    return result;
  }

  Future<void> _show() async {
    _dockHidePending = false;
    await _showWindow();
    await _setSkipTaskbar(false);
    _dockSettleTimer?.cancel();
    _dockSettleTimer = dockSettleDuration == Duration.zero
        ? null
        : Timer(dockSettleDuration, _onDockSettled);
  }

  Future<void> _hide() async {
    await _hideWindow();
    if (_dockSettleTimer?.isActive ?? false) {
      _dockHidePending = true;
      return;
    }
    await _setSkipTaskbar(true);
  }

  void _onDockSettled() {
    _dockSettleTimer = null;
    if (!_dockHidePending) {
      return;
    }
    unawaited(
      _enqueue(() async {
        if (!_dockHidePending) {
          return;
        }
        _dockHidePending = false;
        await _setSkipTaskbar(true);
      }),
    );
  }
}

final window = system.isDesktop ? Window() : null;
