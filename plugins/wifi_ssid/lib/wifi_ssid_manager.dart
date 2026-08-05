import 'package:flutter/services.dart';

/// The platform permission state required to read the current Wi-Fi SSID.
enum WifiSsidPermission { granted, denied, permanentlyDenied }

/// Provides access to the current Wi-Fi SSID and its required permission.
class WifiSsidManager {
  WifiSsidManager._();

  static final WifiSsidManager instance = WifiSsidManager._();

  static const _channel = MethodChannel('wifi_ssid');
  static const _getSsidMethod = 'getSsid';
  static const _checkPermissionMethod = 'checkPermission';
  static const _requestPermissionMethod = 'requestPermission';

  /// Returns the current WiFi SSID, or null if not connected to WiFi.
  Future<String?> getSsid() {
    return _channel.invokeMethod<String>(_getSsidMethod);
  }

  /// Checks whether the required platform permission has been granted.
  Future<WifiSsidPermission> checkPermission() async {
    final result = await _channel.invokeMethod<int>(_checkPermissionMethod);
    return _decodePermission(result);
  }

  /// Requests the required platform permission from the user.
  Future<WifiSsidPermission> requestPermission() async {
    final result = await _channel.invokeMethod<int>(_requestPermissionMethod);
    return _decodePermission(result);
  }

  WifiSsidPermission _decodePermission(int? value) {
    return switch (value) {
      0 => WifiSsidPermission.granted,
      2 => WifiSsidPermission.permanentlyDenied,
      null || 1 => WifiSsidPermission.denied,
      _ => throw PlatformException(
        code: 'INVALID_PERMISSION_STATE',
        message: 'Native wifi_ssid returned an invalid permission state.',
        details: value,
      ),
    };
  }
}

final wifiSsidManager = WifiSsidManager.instance;
