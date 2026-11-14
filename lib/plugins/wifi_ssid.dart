import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rust_api/rust_api.dart' as rust;

export 'package:rust_api/rust_api.dart' show WifiSsidPermission;

abstract interface class WifiSsidHost {
  Future<String?> getSsid();

  Future<rust.WifiSsidPermission> checkPermission();

  Future<rust.WifiSsidPermission> requestPermission();
}

class AndroidWifiSsidHost implements WifiSsidHost {
  final MethodChannel _channel;

  const AndroidWifiSsidHost([
    this._channel = const MethodChannel('$packageName/wifi_ssid'),
  ]);

  @override
  Future<String?> getSsid() => _channel.invokeMethod<String>('getSsid');

  @override
  Future<rust.WifiSsidPermission> checkPermission() async {
    return _decode(await _channel.invokeMethod<int>('checkPermission'));
  }

  @override
  Future<rust.WifiSsidPermission> requestPermission() async {
    return _decode(await _channel.invokeMethod<int>('requestPermission'));
  }

  rust.WifiSsidPermission _decode(int? value) {
    return switch (value) {
      0 => rust.WifiSsidPermission.granted,
      2 => rust.WifiSsidPermission.permanentlyDenied,
      null || 1 => rust.WifiSsidPermission.denied,
      _ => throw PlatformException(
        code: 'INVALID_PERMISSION_STATE',
        message: 'WifiSsidPlugin returned an invalid permission state.',
        details: value,
      ),
    };
  }
}

class _RustWifiSsidHost implements WifiSsidHost {
  const _RustWifiSsidHost();

  @override
  Future<String?> getSsid() => rust.currentWifiSsid();

  @override
  Future<rust.WifiSsidPermission> checkPermission() {
    return rust.checkWifiSsidPermission();
  }

  @override
  Future<rust.WifiSsidPermission> requestPermission() {
    return rust.requestWifiSsidPermission();
  }
}

/// Android answers from the app's `WifiSsidPlugin`, the desktop from
/// rust_api's `wifi` module.
class WifiSsidManager {
  WifiSsidManager._();

  static final instance = WifiSsidManager._();

  WifiSsidHost _host = system.isAndroid
      ? const AndroidWifiSsidHost()
      : const _RustWifiSsidHost();

  @visibleForTesting
  void resetForTesting(WifiSsidHost host) {
    _host = host;
  }

  /// Null when the device is not on Wi-Fi or the SSID is withheld.
  Future<String?> getSsid() => _host.getSsid();

  Future<rust.WifiSsidPermission> checkPermission() => _host.checkPermission();

  Future<rust.WifiSsidPermission> requestPermission() {
    return _host.requestPermission();
  }
}

final wifiSsidManager = WifiSsidManager.instance;
