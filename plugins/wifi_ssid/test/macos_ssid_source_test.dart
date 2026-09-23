import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _resolveSource(String relativePath) {
  final direct = File(relativePath);
  if (direct.existsSync()) {
    return direct;
  }
  final inPlugin = File('plugins/wifi_ssid/$relativePath');
  if (inPlugin.existsSync()) {
    return inPlugin;
  }
  return direct;
}

void main() {
  late String pluginSource;

  setUpAll(() {
    pluginSource = _resolveSource(
      'macos/wifi_ssid/Sources/wifi_ssid/WifiSsidPlugin.swift',
    ).readAsStringSync();
  });

  test('macOS reads the SSID off the platform thread', () {
    expect(pluginSource, contains('ssidQueue.async {'));
    expect(pluginSource, contains('DispatchQueue.main.async {'));
    expect(
      pluginSource,
      isNot(contains('result(wifiClient.interface()?.ssid())')),
      reason: 'CoreWLAN reaches wifid over XPC and can stall the window',
    );
  });

  test('macOS skips CoreWLAN without the location permission on macOS 14+', () {
    final getSsidIndex = pluginSource.indexOf('private func getSsid');
    expect(getSsidIndex, isNonNegative);
    final getSsidBody = pluginSource.substring(
      getSsidIndex,
      pluginSource.indexOf('ssidQueue.async {', getSsidIndex),
    );
    expect(
      getSsidBody,
      allOf(
        contains('if #available(macOS 14, *) {'),
        contains(
          'guard mapAuthStatus(locationManager.authorizationStatus) == .granted else {',
        ),
      ),
    );
  });

  test('macOS reports the location permission as granted below macOS 14', () {
    final checkPermissionIndex = pluginSource.indexOf(
      'private func checkPermission',
    );
    final requestPermissionIndex = pluginSource.indexOf(
      'private func requestPermission',
    );
    final locationManagerDidChangeIndex = pluginSource.indexOf(
      'public func locationManagerDidChangeAuthorization',
    );
    expect(checkPermissionIndex, isNonNegative);
    expect(requestPermissionIndex, isNonNegative);
    expect(locationManagerDidChangeIndex, isNonNegative);

    final checkPermissionBody = pluginSource.substring(
      checkPermissionIndex,
      requestPermissionIndex,
    );
    final requestPermissionBody = pluginSource.substring(
      requestPermissionIndex,
      locationManagerDidChangeIndex,
    );
    final belowMacOS14Guard = allOf(
      contains('guard #available(macOS 14, *) else {'),
      contains('result(WifiSsidPermission.granted.rawValue)'),
    );
    expect(
      checkPermissionBody,
      belowMacOS14Guard,
      reason: 'CoreWLAN only requires location authorization on macOS 14+',
    );
    expect(
      requestPermissionBody,
      belowMacOS14Guard,
      reason: 'CoreWLAN only requires location authorization on macOS 14+',
    );
  });
}
