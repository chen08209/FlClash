import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AppSetting provider', () {
    test('default value is defaultAppSettingProps', () {
      final value = container.read(appSettingProvider);
      expect(value.onlyStatisticsProxy, false);
      expect(value.autoLaunch, false);
      expect(value.closeConnections, true);
      expect(value.isAnimateToPage, true);
    });

    test('can update state', () {
      container
          .read(appSettingProvider.notifier)
          .update((_) => const AppSettingProps(autoLaunch: true));
      final value = container.read(appSettingProvider);
      expect(value.autoLaunch, true);
    });
  });

  group('WindowSetting provider', () {
    test('default value has zero dimensions', () {
      final value = container.read(windowSettingProvider);
      expect(value.width, 0);
      expect(value.height, 0);
    });

    test('can update state', () {
      container
          .read(windowSettingProvider.notifier)
          .update((_) => const WindowProps(width: 1024, height: 768));
      final value = container.read(windowSettingProvider);
      expect(value.width, 1024);
      expect(value.height, 768);
    });
  });

  group('VpnSetting provider', () {
    test('default value has enable true', () {
      final value = container.read(vpnSettingProvider);
      expect(value.enable, true);
      expect(value.systemProxy, true);
    });

    test('can update state', () {
      container
          .read(vpnSettingProvider.notifier)
          .update((_) => const VpnProps(enable: false));
      expect(container.read(vpnSettingProvider).enable, false);
    });
  });

  group('NetworkSetting provider', () {
    test('default values', () {
      final value = container.read(networkSettingProvider);
      expect(value.systemProxy, true);
      expect(value.bypassDomain, defaultBypassDomain);
    });

    test('can update state', () {
      container
          .read(networkSettingProvider.notifier)
          .update((_) => const NetworkProps(systemProxy: false));
      expect(container.read(networkSettingProvider).systemProxy, false);
    });
  });

  group('ThemeSetting provider', () {
    test('default value is dark mode', () {
      final value = container.read(themeSettingProvider);
      expect(value.primaryColor, null);
    });

    test('can update state', () {
      container
          .read(themeSettingProvider.notifier)
          .update((_) => const ThemeProps(primaryColor: 0xFF123456));
      expect(container.read(themeSettingProvider).primaryColor, 0xFF123456);
    });
  });

  group('CurrentProfileId provider', () {
    test('default is null', () {
      expect(container.read(currentProfileIdProvider), null);
    });

    test('can set profile id', () {
      container.read(currentProfileIdProvider.notifier).update((_) => 42);
      expect(container.read(currentProfileIdProvider), 42);
    });
  });

  group('DavSetting provider', () {
    test('default is null', () {
      expect(container.read(davSettingProvider), null);
    });

    test('can update WebDAV settings', () {
      const davProps = DAVProps(
        uri: 'https://dav.example.com',
        user: 'user',
        password: 'secret',
      );

      container.read(davSettingProvider.notifier).update((_) => davProps);

      expect(container.read(davSettingProvider), davProps);
      expect(container.read(configProvider).davProps?.password, 'secret');
    });
  });

  group('OverrideDns provider', () {
    test('default is false', () {
      expect(container.read(overrideDnsProvider), false);
    });

    test('can toggle on', () {
      container.read(overrideDnsProvider.notifier).update((_) => true);
      expect(container.read(overrideDnsProvider), true);
    });
  });

  group('ExcludeSSIDs provider', () {
    test('reorders with final insertion index semantics', () {
      container
          .read(excludeSSIDsProvider.notifier)
          .update((_) => ['Home', 'Office', 'Cafe', 'Hotel']);

      container.read(excludeSSIDsProvider.notifier).update((value) {
        return value.copyAndReorder(1, 3);
      });

      expect(container.read(excludeSSIDsProvider), [
        'Home',
        'Cafe',
        'Hotel',
        'Office',
      ]);
    });
  });

  group('HotKeyActions provider', () {
    test('default is empty list', () {
      expect(container.read(hotKeyActionsProvider), isEmpty);
    });

    test('can update hotkey actions', () {
      const actions = [
        HotKeyAction(
          action: HotAction.start,
          key: 1,
          modifiers: {KeyboardModifier.control},
        ),
      ];

      container.read(hotKeyActionsProvider.notifier).update((_) => actions);

      expect(container.read(hotKeyActionsProvider), actions);
    });
  });

  group('ProxiesStyleSetting provider', () {
    test('default values', () {
      final value = container.read(proxiesStyleSettingProvider);
      expect(value.type, ProxiesType.tab);
    });

    test('can update state', () {
      container
          .read(proxiesStyleSettingProvider.notifier)
          .update(
            (_) => const ProxiesStyleProps(sortType: ProxiesSortType.delay),
          );
      expect(
        container.read(proxiesStyleSettingProvider).sortType,
        ProxiesSortType.delay,
      );
    });
  });

  group('TailscaleSetting provider', () {
    test('default is disabled with no nodes', () {
      final value = container.read(tailscaleSettingProvider);
      expect(value.enable, false);
      expect(value.proxies, isEmpty);
    });

    test('setEnable toggles the feature without touching nodes', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.addOrUpdate(const TailscaleProxy(name: 'ts-node'));
      notifier.setEnable(true);
      final value = container.read(tailscaleSettingProvider);
      expect(value.enable, true);
      expect(value.proxies.length, 1);
    });

    test('setBypassTraffic toggles bypass independently of enable', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.setBypassTraffic(true);
      final value = container.read(tailscaleSettingProvider);
      expect(value.bypassTraffic, true);
      expect(value.enable, false);
    });

    test('setBypassTraffic adds and removes DNS fake-ip filters', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.setBypassTraffic(true);
      expect(
        container.read(patchClashConfigProvider).dns.fakeIpFilter,
        containsAll(tailscaleFakeIpFilters),
      );

      notifier.setBypassTraffic(false);
      final filters = container.read(patchClashConfigProvider).dns.fakeIpFilter;
      for (final filter in tailscaleFakeIpFilters) {
        expect(filters, isNot(contains(filter)));
      }
    });

    test('setBypassTraffic preserves unrelated fake-ip filters', () {
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith.dns(
              fakeIpFilter: ['*.lan', 'custom.example'],
            ),
          );
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.setBypassTraffic(true);
      notifier.setBypassTraffic(false);
      expect(
        container.read(patchClashConfigProvider).dns.fakeIpFilter,
        ['*.lan', 'custom.example'],
      );
    });

    test('addOrUpdate appends a new node', () {
      container
          .read(tailscaleSettingProvider.notifier)
          .addOrUpdate(const TailscaleProxy(name: 'ts-node'));
      final value = container.read(tailscaleSettingProvider);
      expect(value.proxies.length, 1);
      expect(value.proxies.first.name, 'ts-node');
    });

    test('addOrUpdate replaces a node with the same name', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.addOrUpdate(const TailscaleProxy(name: 'ts-node'));
      notifier.addOrUpdate(
        const TailscaleProxy(name: 'ts-node', authKey: 'new-key'),
      );
      final value = container.read(tailscaleSettingProvider);
      expect(value.proxies.length, 1);
      expect(value.proxies.first.authKey, 'new-key');
    });

    test('addOrUpdate renames without duplicating', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.addOrUpdate(const TailscaleProxy(name: 'old-name'));
      notifier.addOrUpdate(
        const TailscaleProxy(name: 'new-name', authKey: 'key'),
        previousName: 'old-name',
      );
      final value = container.read(tailscaleSettingProvider);
      expect(value.proxies.length, 1);
      expect(value.proxies.first.name, 'new-name');
      expect(value.proxies.first.authKey, 'key');
    });

    test('remove deletes a node by name', () {
      final notifier = container.read(tailscaleSettingProvider.notifier);
      notifier.addOrUpdate(const TailscaleProxy(name: 'ts-node'));
      notifier.remove('ts-node');
      expect(container.read(tailscaleSettingProvider).proxies, isEmpty);
    });
  });

  group('configProvider (composite)', () {
    test('composes all sub-providers with defaults', () {
      final config = container.read(configProvider);
      expect(config.appSettingProps.onlyStatisticsProxy, false);
      expect(config.windowProps.width, 0);
      expect(config.vpnProps.enable, true);
      expect(config.networkProps.systemProxy, true);
      expect(config.currentProfileId, null);
      expect(config.overrideDns, false);
      expect(config.hotKeyActions, isEmpty);
      expect(config.patchClashConfig, const PatchClashConfig());
      expect(config.excludeSSIDs, isEmpty);
      expect(config.tailscaleProps.enable, false);
      expect(config.tailscaleProps.proxies, isEmpty);
    });

    test('reflects updated sub-provider values', () {
      container.read(currentProfileIdProvider.notifier).update((_) => 99);
      container.read(overrideDnsProvider.notifier).update((_) => true);
      container
          .read(patchClashConfigProvider.notifier)
          .update((_) => const PatchClashConfig(mixedPort: 7890));
      container
          .read(excludeSSIDsProvider.notifier)
          .update((_) => ['Office Wi-Fi']);

      final config = container.read(configProvider);
      expect(config.currentProfileId, 99);
      expect(config.overrideDns, true);
      expect(config.patchClashConfig.mixedPort, 7890);
      expect(config.excludeSSIDs, ['Office Wi-Fi']);
    });
  });

  group('buildConfigOverrides', () {
    test('produces correct overrides', () {
      const config = Config(
        themeProps: ThemeProps(),
        currentProfileId: 7,
        overrideDns: true,
      );
      final overrides = buildConfigOverrides(config);
      expect(overrides.length, 13);

      final overrideContainer = ProviderContainer(overrides: overrides);
      addTearDown(overrideContainer.dispose);

      expect(overrideContainer.read(currentProfileIdProvider), 7);
      expect(overrideContainer.read(overrideDnsProvider), true);
      expect(
        overrideContainer.read(patchClashConfigProvider),
        config.patchClashConfig,
      );
      expect(overrideContainer.read(excludeSSIDsProvider), config.excludeSSIDs);
      expect(
        overrideContainer.read(appSettingProvider).onlyStatisticsProxy,
        false,
      );
    });
  });
}
