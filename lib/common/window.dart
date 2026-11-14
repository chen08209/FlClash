import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rust_api/window.dart';

class Window implements WindowPort {
  static const _tintOpacity = 0.5;
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
    if (!safeModeBuild) {
      if (system.isWindows) {
        unawaited(protocol.registerWindows(protocolSchemes));
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
    await desktopWindow.setSize(props.savedSize ?? await _defaultSize());
    await desktopWindow.setMinimumSize(const Size(380, 400));
    await _windowPosition(props);
    await desktopWindow.setPreventClose(true);
  }

  Future<Size> _defaultSize() async {
    try {
      final display = await desktopWindow.getPrimaryDisplay();
      return display == null
          ? defaultWindowSize
          : fittedWindowSize(display.workArea.size);
    } catch (_) {
      return defaultWindowSize;
    }
  }

  Future<void> _windowPosition(WindowProps props) async {
    if (!_supportsPosition) {
      return;
    }
    final position = props.left == null || props.top == null
        ? null
        : restoredWindowPosition(
            props,
            displays: await desktopWindow.getDisplays(),
            currentScale: system.isWindows ? _windowScale : null,
          );
    if (position == null) {
      await _center();
    } else {
      await desktopWindow.setPosition(position);
    }
  }

  Future<void> _center() async {
    final size = (await desktopWindow.getBounds()).size;
    await desktopWindow.setPosition(
      await calcWindowPosition(
        size,
        Alignment.center,
        currentScale: system.isWindows ? _windowScale : null,
      ),
    );
  }

  double get _windowScale =>
      PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;

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
      scale: hasValidPosition && system.isWindows
          ? _windowScale
          : current.scale,
    );
  }

  /// A probe that finds no effect is not cached, so a failure at startup
  /// does not pin the toggle to off for the rest of the session.
  Future<WindowEffect> _resolveBlurEffect() async {
    final cached = _blurEffect;
    if (cached != null) {
      return cached;
    }
    // Windows 10's acrylic accent makes the window trail the pointer while it
    // is dragged, so Windows 10 takes the plain accent blur.
    final candidates = system.isMacOS
        ? const [WindowEffect.glass, WindowEffect.blur]
        : const [WindowEffect.mica, WindowEffect.blur];
    for (final effect in candidates) {
      if (await desktopWindow.isEffectSupported(effect)) {
        return _blurEffect = effect;
      }
    }
    return WindowEffect.none;
  }

  /// Only Windows 10's accent blur takes the tint natively; it draws nothing
  /// without one. Every material still keeps the sidebar's own color half over
  /// it, or the rail takes the hue of whatever lies behind the window while
  /// the content beside it keeps the theme's.
  @override
  Future<double?> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  }) async {
    if (system.isLinux) {
      return null;
    }
    final effect = enabled ? await _resolveBlurEffect() : WindowEffect.none;
    await desktopWindow.setEffect(
      effect,
      tint: system.isWindows ? tint.withValues(alpha: _tintOpacity) : null,
      brightness: brightness,
    );
    return effect == WindowEffect.none ? null : _tintOpacity;
  }

  /// Every desktop runner leaves the window hidden until [init] reveals it, so
  /// a failure before that point would leave the error screen with no window.
  Future<void> showInitFailure({required AsyncCallback onExit}) async {
    desktopWindow.addListener(_InitFailureWindowListener(onExit));
    try {
      await desktopWindow.ensureInitialized();
      await desktopWindow.setPreventClose(true);
      await desktopWindow.setTitleBarStyle(TitleBarStyle.normal);
      if (await desktopWindow.isVisible()) {
        return;
      }
      await desktopWindow.setSize(const Size(680, 580));
      await _center();
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
    return desktopWindow.isVisible();
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

@visibleForTesting
Future<Offset> calcWindowPosition(
  Size windowSize,
  Alignment alignment, {
  double? currentScale,
}) async {
  final displays = await desktopWindow.getDisplays();
  final cursor = await desktopWindow.getCursorPosition();
  final currentDisplay =
      displays
          .where((display) => display.bounds.contains(cursor))
          .firstOrNull ??
      await desktopWindow.getPrimaryDisplay();
  if (currentDisplay == null) {
    return Offset.zero;
  }

  final landedSize = currentScale == null
      ? windowSize
      : windowSize * (currentDisplay.scaleFactor / currentScale);
  final visibleSize = currentDisplay.workArea.size;
  final visibleStart = currentDisplay.workArea.topLeft;
  final slack = Offset(
    visibleSize.width - landedSize.width,
    visibleSize.height - landedSize.height,
  );
  return Offset(
    visibleStart.dx + slack.dx / 2 + alignment.x * slack.dx / 2,
    visibleStart.dy + slack.dy / 2 + alignment.y * slack.dy / 2,
  );
}

/// Keeps a margin of the work area around a first window on a small screen.
@visibleForTesting
Size fittedWindowSize(Size visible) => Size(
  math.min(defaultWindowSize.width, visible.width * 0.9),
  math.min(defaultWindowSize.height, visible.height * 0.9),
);

@visibleForTesting
Offset? restoredWindowPosition(
  WindowProps props, {
  required List<DesktopDisplay> displays,
  double? currentScale,
}) {
  final scale = currentScale == null
      ? 1.0
      : (props.scale ?? currentScale) / currentScale;
  final topLeft = Offset(props.left!, props.top!) * scale;
  final size = props.size * scale;
  final titleBar = topLeft & Size(size.width, kHeaderHeight * scale);
  var visibleWidth = 0.0;
  for (final display in displays) {
    final area = display.workArea;
    if (titleBar.top < area.top || titleBar.bottom > area.bottom) {
      continue;
    }
    visibleWidth += math.max(
      0,
      math.min(titleBar.right, area.right) - math.max(titleBar.left, area.left),
    );
  }
  return visibleWidth >= titleBar.width / 2 ? topLeft : null;
}

class _InitFailureWindowListener with WindowListener {
  final AsyncCallback onExit;

  _InitFailureWindowListener(this.onExit);

  @override
  void onWindowClose() => unawaited(onExit());

  @override
  void onWindowShouldTerminate() => unawaited(onExit());
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
