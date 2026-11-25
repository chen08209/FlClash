library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/rust/api/window.dart' as native;
import 'src/rust/api/window.dart' show TitleBarStyle, WindowEffect;

export 'src/rust/api/window.dart'
    show TitleBarStyle, WindowEffect, WindowSignal;

enum WindowEvent {
  close,
  maximize,
  unmaximize,
  minimize,
  restore,
  geometryChanged,
  enterFullScreen,
  leaveFullScreen,
  shouldTerminate,
  activate,

  /// The screens went dark or the session locked, whether or not the window
  /// is shown; a menu bar item can't be seen either.
  screensUnseen,
  screensSeen,
}

/// [bounds] and [workArea] are in the units of [DesktopWindow.getBounds]: on
/// Windows that is physical pixels over the window's current scale for every
/// display, whatever its own [scaleFactor].
@immutable
class DesktopDisplay {
  const DesktopDisplay({
    required this.bounds,
    required this.workArea,
    this.scaleFactor = 1,
    this.isPrimary = false,
  });

  final Rect bounds;

  final Rect workArea;

  final double scaleFactor;

  final bool isPrimary;
}

abstract mixin class WindowListener {
  void onWindowClose() {}

  void onWindowMaximize() {}

  void onWindowUnmaximize() {}

  void onWindowMinimize() {}

  void onWindowRestore() {}

  void onWindowGeometryChanged() {}

  void onWindowEnterFullScreen() {}

  void onWindowLeaveFullScreen() {}

  void onWindowShouldTerminate() {}

  void onWindowActivate() {}

  void onWindowScreensUnseen() {}

  void onWindowScreensSeen() {}

  void onWindowEvent(WindowEvent event) {}
}

/// The desktop window around the Flutter view, driven by rust_api's window
/// module. Coordinates and sizes are logical pixels with a top-left origin.
abstract class DesktopWindow {
  DesktopWindow();

  static DesktopWindow _instance = _NativeDesktopWindow();

  static DesktopWindow get instance => _instance;

  @visibleForTesting
  static set instance(DesktopWindow value) => _instance = value;

  final ObserverList<WindowListener> _listeners =
      ObserverList<WindowListener>();

  List<WindowListener> get listeners => List<WindowListener>.of(_listeners);

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(WindowListener listener) => _listeners.add(listener);

  void removeListener(WindowListener listener) => _listeners.remove(listener);

  @protected
  void dispatch(WindowEvent event) {
    for (final listener in listeners) {
      if (!_listeners.contains(listener)) {
        continue;
      }
      listener.onWindowEvent(event);
      switch (event) {
        case WindowEvent.close:
          listener.onWindowClose();
        case WindowEvent.maximize:
          listener.onWindowMaximize();
        case WindowEvent.unmaximize:
          listener.onWindowUnmaximize();
        case WindowEvent.minimize:
          listener.onWindowMinimize();
        case WindowEvent.restore:
          listener.onWindowRestore();
        case WindowEvent.geometryChanged:
          listener.onWindowGeometryChanged();
        case WindowEvent.enterFullScreen:
          listener.onWindowEnterFullScreen();
        case WindowEvent.leaveFullScreen:
          listener.onWindowLeaveFullScreen();
        case WindowEvent.shouldTerminate:
          listener.onWindowShouldTerminate();
        case WindowEvent.activate:
          listener.onWindowActivate();
        case WindowEvent.screensUnseen:
          listener.onWindowScreensUnseen();
        case WindowEvent.screensSeen:
          listener.onWindowScreensSeen();
      }
    }
  }

  /// Binds to the window that hosts the Flutter view and leaves it hidden.
  /// Every other call needs it.
  Future<void> ensureInitialized();

  Future<void> show();

  Future<void> hide();

  Future<bool> isVisible();

  Future<void> focus();

  /// Runs the close path; with prevent-close set only [WindowEvent.close]
  /// fires.
  Future<void> close();

  Future<void> setPreventClose(bool value);

  Future<bool> isMaximized();

  Future<void> maximize();

  Future<void> unmaximize();

  Future<bool> isMinimized();

  Future<void> minimize();

  Future<bool> isFullScreen();

  Future<void> setFullScreen(bool value);

  Future<Rect> getBounds();

  /// Keeps whatever is not given; never changes z-order or focus.
  Future<void> setBounds({Offset? position, Size? size});

  Future<void> setSize(Size size) => setBounds(size: size);

  Future<void> setPosition(Offset position) => setBounds(position: position);

  Future<List<DesktopDisplay>> getDisplays();

  Future<DesktopDisplay?> getPrimaryDisplay() async {
    final displays = await getDisplays();
    if (displays.isEmpty) {
      return null;
    }
    return displays.firstWhere(
      (display) => display.isPrimary,
      orElse: () => displays.first,
    );
  }

  Future<Offset> getCursorPosition();

  /// False on Wayland, where the compositor owns placement.
  Future<bool> isPositionSupported();

  Future<void> setMinimumSize(Size size);

  Future<bool> isAlwaysOnTop();

  Future<void> setAlwaysOnTop(bool value);

  Future<void> setTitleBarStyle(TitleBarStyle style);

  Future<void> setSkipTaskbar(bool value);

  Future<void> setRoundedCorners(bool value);

  Future<bool> isEffectSupported(WindowEffect effect);

  /// [brightness] picks the light or dark material; null follows the system.
  Future<void> setEffect(
    WindowEffect effect, {
    Color? tint,
    Brightness? brightness,
  });

  Future<void> startDragging();
}

DesktopWindow get desktopWindow => DesktopWindow.instance;

/// The lifecycle state a signal reports, or null for a [WindowEvent] of the
/// same name.
@visibleForTesting
AppLifecycleState? lifecycleOfSignal(native.WindowSignal signal) {
  return switch (signal) {
    native.WindowSignal.lifecycleHidden => AppLifecycleState.hidden,
    native.WindowSignal.lifecycleInactive => AppLifecycleState.inactive,
    native.WindowSignal.lifecycleResumed => AppLifecycleState.resumed,
    _ => null,
  };
}

class _NativeDesktopWindow extends DesktopWindow {
  StreamSubscription<native.WindowSignal>? _signals;

  void _onSignal(native.WindowSignal signal) {
    final lifecycle = lifecycleOfSignal(signal);
    if (lifecycle != null) {
      _sendLifecycle(lifecycle);
      return;
    }
    dispatch(WindowEvent.values.byName(signal.name));
  }

  /// Delivered the way the engine delivers its own, where the engine's view of
  /// the window keeps an unseen window rendering.
  void _sendLifecycle(AppLifecycleState state) {
    ServicesBinding.instance.channelBuffers.push(
      SystemChannels.lifecycle.name,
      const StringCodec().encodeMessage(state.toString()),
      (_) {},
    );
  }

  @override
  Future<void> ensureInitialized() {
    _signals ??= native.windowSignals().listen(_onSignal);
    return native.windowEnsureInitialized();
  }

  @override
  Future<void> show() => native.windowShow();

  @override
  Future<void> hide() => native.windowHide();

  @override
  Future<bool> isVisible() => native.windowIsVisible();

  @override
  Future<void> focus() => native.windowFocus();

  @override
  Future<void> close() => native.windowClose();

  @override
  Future<void> setPreventClose(bool value) {
    return native.windowSetPreventClose(value: value);
  }

  @override
  Future<bool> isMaximized() => native.windowIsMaximized();

  @override
  Future<void> maximize() => native.windowMaximize();

  @override
  Future<void> unmaximize() => native.windowUnmaximize();

  @override
  Future<bool> isMinimized() => native.windowIsMinimized();

  @override
  Future<void> minimize() => native.windowMinimize();

  @override
  Future<bool> isFullScreen() => native.windowIsFullScreen();

  @override
  Future<void> setFullScreen(bool value) {
    return native.windowSetFullScreen(value: value);
  }

  @override
  Future<Rect> getBounds() async => _rect(await native.windowGetBounds());

  @override
  Future<void> setBounds({Offset? position, Size? size}) {
    return native.windowSetBounds(
      x: position?.dx,
      y: position?.dy,
      width: size?.width,
      height: size?.height,
    );
  }

  @override
  Future<List<DesktopDisplay>> getDisplays() async {
    final displays = await native.windowGetDisplays();
    return [
      for (final display in displays)
        DesktopDisplay(
          bounds: _rect(display.bounds),
          workArea: _rect(display.workArea),
          scaleFactor: display.scaleFactor,
          isPrimary: display.primary,
        ),
    ];
  }

  static Rect _rect(native.WindowBounds bounds) {
    return Rect.fromLTWH(bounds.x, bounds.y, bounds.width, bounds.height);
  }

  @override
  Future<Offset> getCursorPosition() async {
    final point = await native.windowGetCursorPosition();
    return Offset(point.x, point.y);
  }

  @override
  Future<bool> isPositionSupported() => native.windowIsPositionSupported();

  @override
  Future<void> setMinimumSize(Size size) {
    return native.windowSetMinimumSize(width: size.width, height: size.height);
  }

  @override
  Future<bool> isAlwaysOnTop() => native.windowIsAlwaysOnTop();

  @override
  Future<void> setAlwaysOnTop(bool value) {
    return native.windowSetAlwaysOnTop(value: value);
  }

  @override
  Future<void> setTitleBarStyle(TitleBarStyle style) {
    return native.windowSetTitleBarStyle(style: style);
  }

  @override
  Future<void> setSkipTaskbar(bool value) {
    return native.windowSetSkipTaskbar(value: value);
  }

  @override
  Future<void> setRoundedCorners(bool value) {
    return native.windowSetRoundedCorners(value: value);
  }

  @override
  Future<bool> isEffectSupported(WindowEffect effect) {
    return native.windowIsEffectSupported(effect: effect);
  }

  @override
  Future<void> setEffect(
    WindowEffect effect, {
    Color? tint,
    Brightness? brightness,
  }) {
    return native.windowSetEffect(
      effect: effect,
      tint: tint?.toARGB32(),
      brightness: switch (brightness) {
        Brightness.light => native.WindowBrightness.light,
        Brightness.dark => native.WindowBrightness.dark,
        null => null,
      },
    );
  }

  @override
  Future<void> startDragging() => native.windowStartDragging();
}
