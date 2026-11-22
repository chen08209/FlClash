import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../helpers/host_scaffold.dart';

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
    'dns hijacking',
    const DNSHijackingItem(),
    (c) => c.read(vpnSettingProvider).dnsHijacking,
  ),
  _ToggleCase(
    'bypass private route',
    const BypassPrivateRouteItem(),
    (c) => c.read(networkSettingProvider).bypassPrivateRoute,
    initial: true,
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
          child: HostScaffold(body: ListView(children: [item])),
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
    testWidgets('the interface name mode picker writes the chosen mode', (
      tester,
    ) async {
      await pumpItem(tester, const InterfaceNameModeItem());
      final initial = container
          .read(patchClashConfigProvider)
          .interfaceNameMode;
      final target = InterfaceNameMode.values.firstWhere(
        (item) => item != initial,
      );

      await tester.tap(find.byType(ListRow).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(_interfaceNameModeLabel(target)).last);
      await tester.pumpAndSettle();

      expect(
        container.read(patchClashConfigProvider).interfaceNameMode,
        target,
      );
    });
  });

  testWidgets('the Windows-only bypass entry says so and deletes like any', (
    tester,
  ) async {
    container.read(networkSettingProvider.notifier).value = const NetworkProps(
      bypassDomain: ['localhost', windowsLocalBypass],
    );
    await pumpItem(tester, const BypassDomainItem());
    final l = currentAppLocalizations;

    await tester.tap(find.text(l.bypassDomain));
    await tester.pumpAndSettle();
    expect(find.text(windowsLocalBypass), findsOneWidget);
    expect(find.text(l.bypassLocalWindowsOnly), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.save));
    await tester.pumpAndSettle();

    expect(container.read(networkSettingProvider).bypassDomain, ['localhost']);
  });

  group('network options items', () {
    List<Type> types({
      required bool isDesktop,
      bool isCustomInterfaceName = true,
    }) {
      return networkOptionsItems(
        isDesktop: isDesktop,
        isCustomInterfaceName: isCustomInterfaceName,
      ).map((item) => item.runtimeType).toList();
    }

    test('interface name rows appear only on desktop', () {
      final desktopTypes = types(isDesktop: true);
      expect(desktopTypes, contains(InterfaceNameModeItem));
      expect(desktopTypes, contains(InterfaceNameItem));

      final androidTypes = types(isDesktop: false);
      expect(androidTypes, isNot(contains(InterfaceNameModeItem)));
      expect(androidTypes, isNot(contains(InterfaceNameItem)));
    });

    test('the interface name row is listed only for the custom mode', () {
      expect(
        types(isDesktop: true, isCustomInterfaceName: false),
        isNot(contains(InterfaceNameItem)),
      );
    });
  });

  group('tun settings', () {
    test('Android sets the routes its VPN service starts with', () {
      final types = tunItems().map((item) => item.runtimeType);
      expect(types, contains(BypassPrivateRouteItem));
      expect(types, contains(RouteAddressItem));
      expect(tunItems(), hasLength(5));
    });

    Widget desktopSection({bool isWindows = false}) =>
        TunSection(isDesktop: true, isLinux: false, isWindows: isWindows);

    void setOverrideKeys(Set<TunOverrideKey> keys) {
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(tunOverrideKeys: keys));
    }

    testWidgets('desktop adds an override from the last row of the section', (
      tester,
    ) async {
      await pumpItem(tester, desktopSection());
      final l = currentAppLocalizations;
      expect(find.text(l.bypassPrivateRoute), findsOneWidget);
      expect(find.text('MTU'), findsNothing);
      expect(find.textContaining(l.tunOverrideDesc), findsOneWidget);

      await tester.tap(find.text(l.addOverrideEntry));
      await tester.pumpAndSettle();
      expect(find.text(l.strictRoute), findsNothing);
      await tester.tap(find.text('MTU'));
      await tester.pumpAndSettle();
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      final config = container.read(patchClashConfigProvider);
      expect(config.tunOverrideKeys, {TunOverrideKey.mtu});
      expect(config.tunOverride.mtu, defaultTunMtu);
      expect(find.text('MTU'), findsOneWidget);
    });

    testWidgets('a listed override leaves the section with its button', (
      tester,
    ) async {
      setOverrideKeys({TunOverrideKey.strictRoute});
      await pumpItem(tester, desktopSection(isWindows: true));
      final l = currentAppLocalizations;
      expect(find.text(l.strictRoute), findsOneWidget);
      expect(find.textContaining(l.strictRouteDesc), findsOneWidget);

      await tester.tap(find.byTooltip(l.remove));
      await tester.pumpAndSettle();

      expect(container.read(patchClashConfigProvider).tunOverrideKeys, isEmpty);
      expect(find.text(l.strictRoute), findsNothing);
    });

    testWidgets('the add row leaves once every offered key is listed', (
      tester,
    ) async {
      setOverrideKeys(
        appTunOverrideSpec(isLinux: false, isWindows: false).values.toSet(),
      );
      await pumpItem(tester, desktopSection());

      expect(find.text(currentAppLocalizations.addOverrideEntry), findsNothing);
    });

    testWidgets('a number shows the core default and resets to it', (
      tester,
    ) async {
      await pumpItem(tester, tunItems().first);
      final l = currentAppLocalizations;
      expect(find.text('9000'), findsOneWidget);

      await tester.tap(find.text('MTU'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1400');
      await tester.tap(find.text(l.submit));
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).tun.mtu, 1400);

      await tester.tap(find.text('MTU'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.reset));
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).tun.mtu, 9000);
    });

    testWidgets('only what Concord runs is offered before the Core reports, '
        'and a Core without the TUN congestion controls hides them', (
      tester,
    ) async {
      Future<void> openCongestion() async {
        await pumpItem(tester, tunItems()[1]);
        await tester.tap(
          find.text(currentAppLocalizations.congestionController),
        );
        await tester.pumpAndSettle();
      }

      await openCongestion();
      expect(find.text('bbr'), findsOneWidget);
      expect(find.text('bbr3'), findsNothing);

      container
          .read(coreCapabilitiesStateProvider.notifier)
          .value = const CoreCapabilities(
        implementation: 'concord',
        version: '0.1.0',
        proxyTypes: {'ss'},
        transports: {'ws'},
        ruleTypes: {'MATCH'},
      );
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      await openCongestion();

      expect(find.text('reno'), findsOneWidget);
      expect(find.text('bbr'), findsNothing);
      expect(find.text('bbr3'), findsNothing);
    });

    test('keep-alive rows stay off Android and the mark is Linux only', () {
      expect(outboundItems(isDesktop: false, isLinux: false), isEmpty);
      expect(outboundItems(isDesktop: true, isLinux: false), hasLength(3));
      expect(outboundItems(isDesktop: true, isLinux: true), hasLength(4));
    });
  });
}

String _interfaceNameModeLabel(InterfaceNameMode mode) {
  return switch (mode) {
    InterfaceNameMode.clear => 'Clear',
    InterfaceNameMode.follow => 'Follow config',
    InterfaceNameMode.custom => 'Custom',
  };
}
