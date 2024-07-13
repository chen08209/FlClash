import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

import 'core.dart';

class ClashMessage {
  StreamSubscription? subscription;

  ClashMessage._() {
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    subscription = ClashCore.receiver.listen((message) {
      final m = AppMessage.fromJson(json.decode(message));
      for (final AppMessageListener listener in _listeners) {
        switch (m.type) {
          case AppMessageType.log:
            listener.onLog(Log.fromJson(m.data));
            break;
          case AppMessageType.delay:
            listener.onDelay(Delay.fromJson(m.data));
            break;
          case AppMessageType.request:
            listener.onRequest(Connection.fromJson(m.data));
            break;
          case AppMessageType.started:
            listener.onStarted(m.data);
            break;
          case AppMessageType.loaded:
            listener.onLoaded(m.data);
            break;
        }
      }
    });
  }

  static final ClashMessage instance = ClashMessage._();

  final ObserverList<AppMessageListener> _listeners =
      ObserverList<AppMessageListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(AppMessageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(AppMessageListener listener) {
    _listeners.remove(listener);
  }
}

final clashMessage = ClashMessage.instance;
