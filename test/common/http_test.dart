import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/http.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _FakeCertificate implements X509Certificate {
  @override
  String get issuer => 'CN=Untrusted';

  @override
  String get subject => 'CN=example.com';

  @override
  DateTime get startValidity => DateTime(2026);

  @override
  DateTime get endValidity => DateTime(2027);

  @override
  Uint8List get der => Uint8List(0);

  @override
  String get pem => '';

  @override
  Uint8List get sha1 => Uint8List(0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer({
    bool running = true,
    String? currentSsid,
    List<String> excludeSSIDs = const [],
    int mixedPort = 7890,
    bool checkCertificate = true,
  }) {
    final container = ProviderContainer(
      overrides: [excludeSSIDsProvider.overrideWithValue(excludeSSIDs)],
    );
    addTearDown(container.dispose);
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
    container.read(currentSSIDProvider.notifier).value = currentSsid;
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig().copyWith(mixedPort: mixedPort);
    container.read(appSettingProvider.notifier).value = const AppSettingProps()
        .copyWith(checkCertificate: checkCertificate);
    return container;
  }

  final remote = Uri.parse('https://example.com/path');

  test('loopback traffic always bypasses the proxy', () {
    final container = buildContainer();

    expect(
      FlClashHttpOverrides.findProxyFor(
        container,
        Uri.parse('http://$localhost:9090/ui'),
      ),
      'DIRECT',
    );
  });

  test('routes through the mixed port while the core is running', () {
    final container = buildContainer(mixedPort: 7891);

    expect(
      FlClashHttpOverrides.findProxyFor(container, remote),
      'PROXY localhost:7891',
    );
  });

  test('bypasses the proxy when the core is not running', () {
    final container = buildContainer(running: false);

    expect(FlClashHttpOverrides.findProxyFor(container, remote), 'DIRECT');
  });

  test('bypasses the proxy on an excluded SSID', () {
    final container = buildContainer(
      currentSsid: 'Office Wi-Fi',
      excludeSSIDs: const ['Office Wi-Fi'],
    );

    expect(FlClashHttpOverrides.findProxyFor(container, remote), 'DIRECT');
  });

  test('keeps proxying when the current SSID is not excluded', () {
    final container = buildContainer(
      currentSsid: 'Home Wi-Fi',
      excludeSSIDs: const ['Office Wi-Fi'],
    );

    expect(
      FlClashHttpOverrides.findProxyFor(container, remote),
      'PROXY localhost:7890',
    );
  });

  test('an untrusted certificate is rejected by default', () {
    final container = buildContainer();

    expect(
      FlClashHttpOverrides.allowBadCertificate(
        container,
        _FakeCertificate(),
        'example.com',
        443,
      ),
      isFalse,
    );
  });

  test('turning the check off accepts an untrusted certificate', () {
    final container = buildContainer(checkCertificate: false);

    expect(
      FlClashHttpOverrides.allowBadCertificate(
        container,
        _FakeCertificate(),
        'example.com',
        443,
      ),
      isTrue,
    );
  });
}
