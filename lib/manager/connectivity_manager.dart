import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class ConnectivityManager extends StatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    required this.child,
  });

  @override
  State<ConnectivityManager> createState() => _ConnectivityManagerState();
}

class _ConnectivityManagerState extends State<ConnectivityManager> {
  late StreamSubscription subscription;
  // Guards against a slow getSsid() completing after a newer connectivity
  // event has already updated (or cleared) the current SSID.
  int _ssidEpoch = 0;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((results) {
      final epoch = ++_ssidEpoch;
      if (results.contains(ConnectivityResult.wifi)) {
        WifiSsidManager.instance
            .getSsid()
            .then((ssid) {
              if (epoch != _ssidEpoch) {
                return;
              }
              globalState.container.read(currentSSIDProvider.notifier).value =
                  ssid;
              commonPrint.log('Wi-fi SSID: $ssid ', logLevel: LogLevel.info);
            })
            .catchError((Object error) {
              // Keep the last known SSID: clearing it here would un-suspend
              // an excluded network just because the read failed.
              commonPrint.log(
                'get Wi-fi SSID failed: $error',
                logLevel: LogLevel.warning,
              );
            });
      } else {
        globalState.container.read(currentSSIDProvider.notifier).value = null;
      }
      if (widget.onConnectivityChanged != null) {
        widget.onConnectivityChanged!(results);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
