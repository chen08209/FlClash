import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class VpnListener {
  void onDnsChanged(String dns) {}
}

class Vpn {
  static Vpn? _instance;
  late MethodChannel methodChannel;
  FutureOr<String> Function()? handleGetStartForegroundParams;

  Vpn._internal() {
    methodChannel = const MethodChannel('vpn');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'gc':
          clashCore.requestGc();
        case 'getStartForegroundParams':
          if (handleGetStartForegroundParams != null) {
            return await handleGetStartForegroundParams!();
          }
          return '';
        case 'status':
          return clashLibHandler?.getRunTime() != null;
        default:
          for (final VpnListener listener in _listeners) {
            switch (call.method) {
              case 'dnsChanged':
                final dns = call.arguments as String;
                listener.onDnsChanged(dns);
            }
          }
      }
    });
  }

  factory Vpn() {
    _instance ??= Vpn._internal();
    return _instance!;
  }

  final ObserverList<VpnListener> _listeners = ObserverList<VpnListener>();

  Future<bool?> start(AndroidVpnOptions options) async {
    return await methodChannel.invokeMethod<bool>('start', {
      'data': json.encode(options),
    });
  }

  Future<bool?> stop() async {
    return await methodChannel.invokeMethod<bool>('stop');
  }

  void addListener(VpnListener listener) {
    _listeners.add(listener);
  }

  void removeListener(VpnListener listener) {
    _listeners.remove(listener);
  }
}

Vpn? get vpn => globalState.isService ? Vpn() : null;
