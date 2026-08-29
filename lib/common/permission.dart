import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid_manager.dart';

enum LocationPermissionFollowUp { none, showDeniedMessage, openSettings }

LocationPermissionFollowUp getLocationPermissionFollowUp(
  WifiSsidPermission permission,
) {
  return switch (permission) {
    WifiSsidPermission.granted => LocationPermissionFollowUp.none,
    WifiSsidPermission.denied => LocationPermissionFollowUp.showDeniedMessage,
    WifiSsidPermission.permanentlyDenied =>
      LocationPermissionFollowUp.openSettings,
  };
}

class Permissions {
  static Permissions? _instance;

  Permissions._internal({bool Function()? supportsLocationPermissions})
    : _supportsLocationPermissions =
          supportsLocationPermissions ??
          (() => system.isAndroid || system.isMacOS);

  factory Permissions() {
    _instance ??= Permissions._internal();
    return _instance!;
  }

  @visibleForTesting
  factory Permissions.test({required bool supportsLocationPermissions}) {
    return Permissions._internal(
      supportsLocationPermissions: () => supportsLocationPermissions,
    );
  }

  final bool Function() _supportsLocationPermissions;

  bool _isRequestingLocation = false;
  bool needWaitingBatteryOptimizationSettings = false;

  void check(ProviderReader read) {
    checkLocationPermissions(read);
    checkBatteryOptimizationDisable(read);
  }

  Future<void> checkBatteryOptimizationDisable(ProviderReader read) async {
    await _checkBatteryOptimizationDisable(read);
  }

  Future<void> _checkBatteryOptimizationDisable(ProviderReader read) async {
    const tag = LoadingTag.batteryOptimization;
    try {
      if (needWaitingBatteryOptimizationSettings) {
        read(loadingProvider(tag).notifier).value = true;
      }
      read(
        batteryOptimizationDisableProvider.notifier,
      ).value = await retry<bool>(
        task: () async {
          return await app?.isBatteryOptimizationDisabled() ?? false;
        },
        retryIf: (res) => res == false,
        delay: const Duration(milliseconds: 500),
        maxAttempts: needWaitingBatteryOptimizationSettings ? 5 : 1,
      );
    } finally {
      read(loadingProvider(tag).notifier).value = false;
      needWaitingBatteryOptimizationSettings = false;
    }
  }

  Future<void> checkLocationPermissions(ProviderReader read) async {
    if (!_supportsLocationPermissions()) {
      return;
    }
    final res = await WifiSsidManager.instance.checkPermission();
    final current = read(locationPermissionsProvider);
    if (res == WifiSsidPermission.granted ||
        current != WifiSsidPermission.permanentlyDenied) {
      read(locationPermissionsProvider.notifier).value = res;
    }
    final needRequestPermission = read(
      excludeSSIDsProvider.select((state) => state.isNotEmpty),
    );
    if (res == WifiSsidPermission.denied &&
        needRequestPermission &&
        !_isRequestingLocation) {
      try {
        _isRequestingLocation = true;
        final res = await WifiSsidManager.instance.requestPermission();
        read(locationPermissionsProvider.notifier).value = res;
        if (res == WifiSsidPermission.granted) {
          final ssid = await WifiSsidManager.instance.getSsid();
          read(currentSSIDProvider.notifier).value = ssid;
        }
      } finally {
        _isRequestingLocation = false;
      }
    }
  }
}

final permissions = Permissions();
