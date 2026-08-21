import 'package:fl_clash/common/permission.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('wifi_ssid');
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        excludeSSIDsProvider.overrideWithValue(const ['Office Wi-Fi']),
      ],
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    container.dispose();
  });

  test('maps permission results to the correct UI follow-up', () {
    expect(
      getLocationPermissionFollowUp(WifiSsidPermission.granted),
      LocationPermissionFollowUp.none,
    );
    expect(
      getLocationPermissionFollowUp(WifiSsidPermission.denied),
      LocationPermissionFollowUp.showDeniedMessage,
    );
    expect(
      getLocationPermissionFollowUp(WifiSsidPermission.permanentlyDenied),
      LocationPermissionFollowUp.openSettings,
    );
  });

  test(
    'refreshes current SSID immediately after permission is granted',
    () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            return switch (call.method) {
              'checkPermission' => 1,
              'requestPermission' => 0,
              'getSsid' => 'Office Wi-Fi',
              _ => null,
            };
          });

      await Permissions.test(
        supportsLocationPermissions: true,
      ).checkLocationPermissions(container.read);

      expect(calls, ['checkPermission', 'requestPermission', 'getSsid']);
      expect(
        container.read(locationPermissionsProvider),
        WifiSsidPermission.granted,
      );
      expect(container.read(currentSSIDProvider), 'Office Wi-Fi');
    },
  );

  test('does not read SSID when permission remains denied', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return 1;
        });

    await Permissions.test(
      supportsLocationPermissions: true,
    ).checkLocationPermissions(container.read);

    expect(calls, ['checkPermission', 'requestPermission']);
    expect(
      container.read(locationPermissionsProvider),
      WifiSsidPermission.denied,
    );
    expect(container.read(currentSSIDProvider), isNull);
  });
}
