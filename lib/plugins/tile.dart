import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class TileListener {
  void onStart() {}

  void onStop() {}

  void onDetached() {}
}

class Tile {
  final MethodChannel _channel = const MethodChannel('$packageName/tile');

  Tile._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  static final Tile instance = Tile._();

  final ObserverList<TileListener> _listeners = ObserverList<TileListener>();

  Future<void> _methodCallHandler(MethodCall call) async {
    for (final TileListener listener in List.of(_listeners)) {
      try {
        switch (call.method) {
          case 'start':
            listener.onStart();
            break;
          case 'stop':
            listener.onStop();
            break;
          case 'detached':
            listener.onDetached();
            break;
        }
      } catch (error) {
        commonPrint.log(
          'Unable to dispatch Tile event ${call.method}: $error',
          logLevel: LogLevel.error,
        );
      }
    }
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
