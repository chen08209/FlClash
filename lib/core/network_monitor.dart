import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Network state monitor for SSID-based policy switching
class NetworkStateMonitor {
  static final NetworkStateMonitor _instance = NetworkStateMonitor._internal();
  factory NetworkStateMonitor() => _instance;
  NetworkStateMonitor._internal();

  final _connectivity = Connectivity();
  final _networkInfo = NetworkInfo();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  static const _macLocationChannel = MethodChannel(
    'com.flclash/location_permission',
  );

  String _currentNetworkType = '';
  String _currentSsid = '';
  String _currentWifiIp = '';
  bool _hasLocationPermission = false;

  Function(String networkType, String ssid, String wifiIp)?
  onNetworkStateChanged;

  /// Check and request location permission (required for getting WiFi SSID)
  Future<bool> _checkAndRequestPermission() async {
    try {
      // On macOS Sonoma+, CWWiFiClient.ssid() requires CLLocationManager
      // authorization. We use a native MethodChannel to request it.
      if (Platform.isMacOS) {
        return await _requestMacOSLocationPermission();
      }

      // Android permission flow
      // First check locationAlways permission (includes locationWhenInUse)
      var alwaysStatus = await Permission.locationAlways.status;

      if (alwaysStatus.isGranted) {
        _hasLocationPermission = true;
        commonPrint.log(
          'NetworkStateMonitor: Location Always permission granted',
        );
        return true;
      }

      // Check if we have locationWhenInUse permission
      var whenInUseStatus = await Permission.locationWhenInUse.status;

      if (whenInUseStatus.isGranted) {
        // We have When In Use, now request Always
        commonPrint.log(
          'NetworkStateMonitor: Requesting location Always permission',
        );
        alwaysStatus = await Permission.locationAlways.request();

        if (alwaysStatus.isGranted) {
          _hasLocationPermission = true;
          commonPrint.log(
            'NetworkStateMonitor: Location Always permission granted',
          );
          return true;
        } else {
          // Even if Always is denied, we still have When In Use
          _hasLocationPermission = true;
          commonPrint.log(
            'NetworkStateMonitor: Location When In Use permission granted (Always denied)',
          );
          return true;
        }
      }

      // Request When In Use permission first
      if (whenInUseStatus.isDenied) {
        commonPrint.log(
          'NetworkStateMonitor: Requesting location When In Use permission',
        );
        whenInUseStatus = await Permission.locationWhenInUse.request();

        if (whenInUseStatus.isGranted) {
          _hasLocationPermission = true;
          commonPrint.log(
            'NetworkStateMonitor: Location When In Use permission granted',
          );

          // Now request Always permission
          commonPrint.log(
            'NetworkStateMonitor: Requesting location Always permission',
          );
          alwaysStatus = await Permission.locationAlways.request();

          if (alwaysStatus.isGranted) {
            commonPrint.log(
              'NetworkStateMonitor: Location Always permission granted',
            );
          } else {
            commonPrint.log(
              'NetworkStateMonitor: Location Always permission denied, using When In Use',
            );
          }

          return true;
        } else if (whenInUseStatus.isPermanentlyDenied) {
          commonPrint.log(
            'NetworkStateMonitor: Location permission permanently denied. '
            'Please enable it in Settings.',
          );
          return false;
        } else {
          commonPrint.log(
            'NetworkStateMonitor: Location When In Use permission denied',
          );
          return false;
        }
      }

      if (whenInUseStatus.isPermanentlyDenied) {
        commonPrint.log(
          'NetworkStateMonitor: Location permission permanently denied. '
          'Please enable it in Settings.',
        );
        return false;
      }

      return false;
    } catch (e) {
      commonPrint.log('NetworkStateMonitor: Error checking permission: $e');
      return false;
    }
  }

  /// Request location permission on macOS via native CLLocationManager
  Future<bool> _requestMacOSLocationPermission() async {
    try {
      final status = await _macLocationChannel.invokeMethod<String>(
        'requestLocationPermission',
      );
      commonPrint.log(
        'NetworkStateMonitor: macOS location permission status: $status',
      );
      _hasLocationPermission = status == 'granted';
      if (!_hasLocationPermission) {
        commonPrint.log(
          'NetworkStateMonitor: macOS location permission not granted ($status). '
          'WiFi SSID will not be available. '
          'Please grant location permission in System Settings > '
          'Privacy & Security > Location Services.',
        );
      }
      return _hasLocationPermission;
    } catch (e) {
      commonPrint.log(
        'NetworkStateMonitor: Error requesting macOS location permission: $e',
      );
      return false;
    }
  }

  /// Start monitoring network state changes
  Future<void> startMonitoring() async {
    commonPrint.log('NetworkStateMonitor: Starting network monitoring');

    // Check and request location permission first
    await _checkAndRequestPermission();

    // Get initial state
    await _updateNetworkState();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      commonPrint.log('NetworkStateMonitor: Connectivity changed: $results');
      _updateNetworkState();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    commonPrint.log('NetworkStateMonitor: Stopping network monitoring');
    _subscription?.cancel();
    _subscription = null;
  }

  /// Update network state and notify if changed
  Future<void> _updateNetworkState() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final networkType = _getNetworkType(results);
      final ssid = await _getSsid(results);
      final wifiIp = await _getWifiIp(results);

      if (networkType != _currentNetworkType ||
          ssid != _currentSsid ||
          wifiIp != _currentWifiIp) {
        _currentNetworkType = networkType;
        _currentSsid = ssid;
        _currentWifiIp = wifiIp;
        onNetworkStateChanged?.call(networkType, ssid, wifiIp);
      }
    } catch (e) {
      commonPrint.log('NetworkStateMonitor: Error updating network state: $e');
    }
  }

  /// Convert ConnectivityResult to network type string
  String _getNetworkType(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'none';
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return 'cellular';
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return 'ethernet';
    }
    return 'other';
  }

  /// Get SSID for WiFi networks
  Future<String> _getSsid(List<ConnectivityResult> results) async {
    if (!results.contains(ConnectivityResult.wifi)) {
      return '';
    }

    // On macOS, system handles permission automatically
    // On Android/iOS, check if we have location permission
    if (!Platform.isMacOS && !_hasLocationPermission) {
      commonPrint.log(
        'NetworkStateMonitor: Cannot get SSID without location permission',
      );
      return '';
    }

    try {
      final wifiName = await _networkInfo.getWifiName();
      // Remove quotes if present (iOS returns SSID with quotes)
      return wifiName?.replaceAll('"', '') ?? '';
    } catch (e) {
      commonPrint.log('NetworkStateMonitor: Error getting SSID: $e');
      return '';
    }
  }

  /// Get WiFi IP (local IP address)
  Future<String> _getWifiIp(List<ConnectivityResult> results) async {
    if (!results.contains(ConnectivityResult.wifi)) {
      return '';
    }

    try {
      await Future.delayed(Duration(milliseconds: 360));
      final wifiIp = await utils.getLocalIpAddress();
      return wifiIp ?? '';
    } catch (e) {
      commonPrint.log('NetworkStateMonitor: Error getting WiFi IP: $e');
      return '';
    }
  }
}
