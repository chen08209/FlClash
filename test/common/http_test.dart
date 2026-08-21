import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/http.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer({
    bool running = true,
    String? currentSsid,
    List<String> excludeSSIDs = const [],
    int mixedPort = 7890,
  }) {
    final container = ProviderContainer(
      overrides: [excludeSSIDsProvider.overrideWithValue(excludeSSIDs)],
    );
    addTearDown(container.dispose);
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
    container.read(currentSSIDProvider.notifier).value = currentSsid;
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig().copyWith(mixedPort: mixedPort);
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
}
