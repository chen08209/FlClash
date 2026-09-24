import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Alignment, Brightness;
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window/src/title_bar_style.dart';
import 'package:window/src/window_effect.dart';
import 'package:window/src/window_event.dart';
import 'package:window/src/window_listener.dart';

class DesktopWindow {
  DesktopWindow._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static final DesktopWindow instance = DesktopWindow._();

  static const MethodChannel _channel = MethodChannel('window');

  final ObserverList<WindowListener> _listeners =
      ObserverList<WindowListener>();

  List<WindowListener> get listeners => List<WindowListener>.of(_listeners);

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(WindowListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WindowListener listener) {
    _listeners.remove(listener);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onEvent') {
      throw MissingPluginException('${call.method} is not an event');
    }
    final arguments = call.arguments;
    final event = WindowEvent.fromWireName(
      arguments is Map ? arguments['name'] : null,
    );
    if (event == null) {
      return;
    }
    for (final listener in listeners) {
      if (!_listeners.contains(listener)) {
        continue;
      }
      listener.onWindowEvent(event);
      _dispatch(listener, event);
    }
  }

  void _dispatch(WindowListener listener, WindowEvent event) {
    switch (event) {
      case WindowEvent.close:
        listener.onWindowClose();
      case WindowEvent.focus:
        listener.onWindowFocus();
      case WindowEvent.blur:
        listener.onWindowBlur();
      case WindowEvent.show:
        listener.onWindowShow();
      case WindowEvent.hide:
        listener.onWindowHide();
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
    }
  }

  Future<T> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    final result = await _channel.invokeMethod<T>(method, arguments);
    if (result == null) {
      throw PlatformException(
        code: 'bad_result',
        message: '$method answered null',
      );
    }
    return result;
  }

  Future<void> _call(String method, [Map<String, Object?>? arguments]) {
    return _channel.invokeMethod<void>(method, arguments);
  }

  Future<void> ensureInitialized() => _call('ensureInitialized');

  Future<void> show({bool inactive = false}) {
    return _call('show', {'inactive': inactive});
  }

  Future<void> hide() => _call('hide');

  Future<bool> isVisible() => _invoke<bool>('isVisible');

  Future<void> focus() => _call('focus');

  Future<void> close() => _call('close');

  Future<void> setPreventClose(bool value) {
    return _call('setPreventClose', {'value': value});
  }

  Future<bool> isMaximized() => _invoke<bool>('isMaximized');

  Future<void> maximize() => _call('maximize');

  Future<void> unmaximize() => _call('unmaximize');

  Future<bool> isMinimized() => _invoke<bool>('isMinimized');

  Future<void> minimize() => _call('minimize');

  Future<void> restore() => _call('restore');

  Future<bool> isFullScreen() => _invoke<bool>('isFullScreen');

  Future<void> setFullScreen(bool value) {
    return _call('setFullScreen', {'value': value});
  }

  Future<Rect> getBounds() async {
    final data = await _invoke<Map<Object?, Object?>>('getBounds');
    return Rect.fromLTWH(
      (data['x'] as num).toDouble(),
      (data['y'] as num).toDouble(),
      (data['width'] as num).toDouble(),
      (data['height'] as num).toDouble(),
    );
  }

  Future<void> setBounds({Offset? position, Size? size}) {
    final arguments = <String, Object?>{
      'x': position?.dx,
      'y': position?.dy,
      'width': size?.width,
      'height': size?.height,
    }..removeWhere((_, value) => value == null);
    return _call('setBounds', arguments);
  }

  Future<Size> getSize() async => (await getBounds()).size;

  Future<void> setSize(Size size) => setBounds(size: size);

  Future<Offset> getPosition() async => (await getBounds()).topLeft;

  Future<bool> isPositionSupported() => _invoke<bool>('isPositionSupported');

  Future<void> setPosition(Offset position) => setBounds(position: position);

  Future<void> setAlignment(Alignment alignment) async {
    final position = await calcWindowPosition(await getSize(), alignment);
    await setPosition(position);
  }

  Future<void> center() => setAlignment(Alignment.center);

  Future<void> setMinimumSize(Size size) {
    return _call('setMinimumSize', {
      'width': size.width,
      'height': size.height,
    });
  }

  Future<bool> isAlwaysOnTop() => _invoke<bool>('isAlwaysOnTop');

  Future<void> setAlwaysOnTop(bool value) {
    return _call('setAlwaysOnTop', {'value': value});
  }

  Future<void> setTitleBarStyle(
    TitleBarStyle style, {
    bool windowButtonVisibility = true,
  }) {
    return _call('setTitleBarStyle', {
      'style': style.name,
      'windowButtonVisibility': windowButtonVisibility,
    });
  }

  Future<void> setSkipTaskbar(bool value) {
    return _call('setSkipTaskbar', {'value': value});
  }

  Future<void> setRoundedCorners(bool value) {
    return _call('setRoundedCorners', {'value': value});
  }

  Future<bool> isEffectSupported(WindowEffect effect) {
    return _invoke<bool>('isEffectSupported', {'effect': effect.name});
  }

  /// [brightness] picks the light or dark material; null follows the system.
  Future<void> setEffect(
    WindowEffect effect, {
    Color? tint,
    Brightness? brightness,
  }) {
    return _call('setEffect', {
      'effect': effect.name,
      'tint': tint?.toARGB32(),
      'brightness': brightness?.name,
    });
  }

  Future<void> startDragging() => _call('startDragging');
}

final DesktopWindow desktopWindow = DesktopWindow.instance;

/// Positions [windowSize] inside the work area of the display under the
/// cursor, falling back to the primary display.
@visibleForTesting
Future<Offset> calcWindowPosition(Size windowSize, Alignment alignment) async {
  final primaryDisplay = await screenRetriever.getPrimaryDisplay();
  final allDisplays = await screenRetriever.getAllDisplays();
  final cursorScreenPoint = await screenRetriever.getCursorScreenPoint();

  final currentDisplay = allDisplays.firstWhere((display) {
    final visiblePosition = display.visiblePosition;
    if (visiblePosition == null) {
      return false;
    }
    return Rect.fromLTWH(
      visiblePosition.dx,
      visiblePosition.dy,
      display.size.width,
      display.size.height,
    ).contains(cursorScreenPoint);
  }, orElse: () => primaryDisplay);

  final visibleSize = currentDisplay.visibleSize ?? currentDisplay.size;
  final visibleStart = currentDisplay.visiblePosition ?? Offset.zero;
  final slack = Offset(
    visibleSize.width - windowSize.width,
    visibleSize.height - windowSize.height,
  );
  return Offset(
    visibleStart.dx + slack.dx / 2 + alignment.x * slack.dx / 2,
    visibleStart.dy + slack.dy / 2 + alignment.y * slack.dy / 2,
  );
}
