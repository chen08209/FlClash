import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

import 'core.dart';

abstract mixin class ClashMessageListener {
  void onLog(Log log) {}

  void onTun(Fd fd) {}

  void onDelay(Delay delay) {}

  void onProcess(Process process) {}

  void onRequest(Connection connection) {}

  void onNow(Now now) {}

  void onRun(String runTime) {}

  void onLoaded(String groupName) {}
}

class ClashMessage {
  StreamSubscription? subscription;

  ClashMessage._() {
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    subscription = ClashCore.receiver.listen((message) {
      final m = Message.fromJson(json.decode(message));
      for (final ClashMessageListener listener in _listeners) {
        switch (m.type) {
          case MessageType.log:
            listener.onLog(Log.fromJson(m.data));
            break;
          case MessageType.tun:
            listener.onTun(Fd.fromJson(m.data));
            break;
          case MessageType.delay:
            listener.onDelay(Delay.fromJson(m.data));
            break;
          case MessageType.process:
            listener.onProcess(Process.fromJson(m.data));
            break;
          case MessageType.now:
            listener.onNow(Now.fromJson(m.data));
            break;
          case MessageType.request:
            listener.onRequest(Connection.fromJson(m.data));
            break;
          case MessageType.run:
            listener.onRun(m.data);
            break;
          case MessageType.loaded:
            listener.onLoaded(m.data);
            break;
        }
      }
    });
  }

  static final ClashMessage instance = ClashMessage._();

  final ObserverList<ClashMessageListener> _listeners =
      ObserverList<ClashMessageListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ClashMessageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ClashMessageListener listener) {
    _listeners.remove(listener);
  }
}

final clashMessage = ClashMessage.instance;
