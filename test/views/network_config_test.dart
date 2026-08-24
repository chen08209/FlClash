import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _ToggleCase {
  final String name;
  final Widget widget;
  final bool Function(ProviderContainer container) read;
  final bool initial;

  const _ToggleCase(this.name, this.widget, this.read, {this.initial = false});
}

final _toggleCases = <_ToggleCase>[
  _ToggleCase(
    'VPN',
    const VPNItem(),
    (c) => c.read(vpnSettingProvider).enable,
    initial: true,
  ),
  _ToggleCase(
    'TUN',
    const TUNItem(),
    (c) => c.read(patchClashConfigProvider).tun.enable,
  ),
  _ToggleCase(
    'allow bypass',
    const AllowBypassItem(),
    (c) => c.read(vpnSettingProvider).allowBypass,
    initial: true,
  ),
  _ToggleCase(
    'vpn system proxy',
    const VpnSystemProxyItem(),
    (c) => c.read(vpnSettingProvider).systemProxy,
    initial: true,
  ),
  _ToggleCase(
    'system proxy',
    const SystemProxyItem(),
    (c) => c.read(networkSettingProvider).systemProxy,
    initial: true,
  ),
  _ToggleCase('ipv6', const Ipv6Item(), (c) => c.read(vpnSettingProvider).ipv6),
  _ToggleCase(
    'auto set system dns',
    const AutoSetSystemDnsItem(),
    (c) => c.read(networkSettingProvider).autoSetSystemDns,
    initial: true,
  ),
  _ToggleCase(
    'dns hijacking',
    const DNSHijackingItem(),
    (c) => c.read(vpnSettingProvider).dnsHijacking,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  Future<void> pumpItem(WidgetTester tester, Widget item) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: ListView(children: [item])),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('toggles write to their own setting', () {
    for (final testCase in _toggleCases) {
      testWidgets('${testCase.name} flips both ways', (tester) async {
        await pumpItem(tester, testCase.widget);

        expect(testCase.read(container), testCase.initial);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(testCase.read(container), !testCase.initial);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(testCase.read(container), testCase.initial);
      });
    }
  });

  group('option pickers', () {
    testWidgets('the stack picker writes the chosen tun stack', (tester) async {
      await pumpItem(tester, const TunStackItem());
      final initial = container.read(patchClashConfigProvider).tun.stack;
      final target = TunStack.values.firstWhere((item) => item != initial);

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(target.name).last);
      await tester.pumpAndSettle();

      expect(container.read(patchClashConfigProvider).tun.stack, target);
    });

    testWidgets('the route mode picker writes the chosen mode', (tester) async {
      await pumpItem(tester, const RouteModeItem());
      final initial = container.read(networkSettingProvider).routeMode;
      final target = RouteMode.values.firstWhere((item) => item != initial);

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(_routeModeLabel(target)).last);
      await tester.pumpAndSettle();

      expect(container.read(networkSettingProvider).routeMode, target);
    });
  });

  group('route address visibility', () {
    testWidgets('is hidden while bypassing private addresses', (tester) async {
      container
          .read(networkSettingProvider.notifier)
          .update(
            (state) => state.copyWith(routeMode: RouteMode.bypassPrivate),
          );

      await pumpItem(tester, const RouteAddressItem());

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('is shown for every other route mode', (tester) async {
      container
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith(routeMode: RouteMode.config));

      await pumpItem(tester, const RouteAddressItem());

      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}

String _routeModeLabel(RouteMode mode) {
  return switch (mode) {
    RouteMode.config => 'Use config',
    RouteMode.bypassPrivate => 'Bypass private route address',
  };
}
