import 'package:flutter/services.dart';

enum WifiSsidPermission {
  granted,
  denied,
  permanentlyDenied,
}

class WifiSsidManager {
  WifiSsidManager._();

  static final WifiSsidManager instance = WifiSsidManager._();

  final MethodChannel _channel = const MethodChannel('wifi_ssid');

  /// Returns the current WiFi SSID, or null when not connected to WiFi or
  /// the platform denies access.
  ///
  /// Throws on timeout or platform error so callers can tell "not on WiFi"
  /// apart from "could not read": treating a failed read as no-SSID would
  /// resume proxying on a network the user excluded.
  Future<String?> getSsid() async {
    return await _channel
        .invokeMethod<String>('getSsid')
        .timeout(const Duration(seconds: 3));
  }

  /// Checks whether location permission has been granted.
  Future<WifiSsidPermission> checkPermission() async {
    final result = await _channel.invokeMethod<int>('checkPermission');
    return WifiSsidPermission.values[result ?? 1];
  }

  /// Requests location permission from the user.
  Future<WifiSsidPermission> requestPermission() async {
    final result = await _channel.invokeMethod<int>('requestPermission');
    return WifiSsidPermission.values[result ?? 1];
  }
}

final wifiSsidManager = WifiSsidManager.instance;
