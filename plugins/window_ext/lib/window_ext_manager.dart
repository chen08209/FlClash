import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_ext_listener.dart';

class WindowExtManager {
  WindowExtManager._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  static final WindowExtManager instance = WindowExtManager._();

  final MethodChannel _channel = const MethodChannel('window_ext');

  final ObserverList<WindowExtListener> _listeners =
      ObserverList<WindowExtListener>();

  Future<void> _methodCallHandler(MethodCall call) async {
    for (final WindowExtListener listener in _listeners) {
      switch (call.method) {
        case "taskbarCreated":
          listener.onTaskbarCreated();
          break;
        case "shouldTerminate":
          listener.onShouldTerminate();
          break;
      }
    }
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(WindowExtListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WindowExtListener listener) {
    _listeners.remove(listener);
  }
}

final windowExtManager = WindowExtManager.instance;
