import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class TileListener {
  Future<bool> onStart() async => false;

  Future<bool> onStop() async => false;

  void onDetached() {}
}

class Tile {
  final MethodChannel _channel = const MethodChannel('$packageName/tile');

  Tile._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  static final Tile instance = Tile._();

  final ObserverList<TileListener> _listeners = ObserverList<TileListener>();

  Future<bool> _methodCallHandler(MethodCall call) async {
    if (_listeners.isEmpty) {
      return false;
    }
    var handled = false;
    for (final TileListener listener in _listeners) {
      switch (call.method) {
        case 'start':
          handled = await listener.onStart() || handled;
          break;
        case 'stop':
          handled = await listener.onStop() || handled;
          break;
        case 'detached':
          listener.onDetached();
          break;
      }
    }
    return handled;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(TileListener listener) {
    _listeners.add(listener);
  }

  void removeListener(TileListener listener) {
    _listeners.remove(listener);
  }
}

final tile = system.isAndroid ? Tile.instance : null;
