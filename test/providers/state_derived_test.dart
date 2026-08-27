import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('group derivation sanitizes runtime state and respects clash mode', () {
    final groups = [
      const Group(
        name: 'Visible',
        type: GroupType.Selector,
        now: 'Selected',
        hidden: false,
        all: [Proxy(name: 'Selected', type: 'Direct', now: 'runtime')],
      ),
      const Group(name: 'Hidden', type: GroupType.Selector, hidden: true),
      Group(name: GroupName.GLOBAL.name, type: GroupType.Selector),
    ];
    container.read(groupsProvider.notifier).update((_) => groups);
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.rule));

    final ruleGroups = container.read(currentGroupsStateProvider).value;
    expect(ruleGroups.map((group) => group.name), ['Visible']);
    expect(ruleGroups.single.now, isEmpty);
    expect(ruleGroups.single.all.single.now, isEmpty);

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.global));
    expect(container.read(currentGroupsStateProvider).value, hasLength(3));

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.direct));
    expect(container.read(currentGroupsStateProvider).value, isEmpty);
  });

  test('navigation providers select items for width and current page', () {
    container
        .read(viewSizeProvider.notifier)
        .update((_) => Size(maxMobileWidth.toDouble(), 800));
    final mobile = container.read(currentNavigationItemsStateProvider).value;
    expect(
      mobile.map((item) => item.label),
      containsAll([PageLabel.dashboard, PageLabel.profiles, PageLabel.tools]),
    );
    expect(
      mobile.map((item) => item.label),
      isNot(contains(PageLabel.connections)),
    );

    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 800));
    container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.connections);
    final desktop = container.read(navigationStateProvider);
    expect(desktop.viewMode, ViewMode.desktop);
    expect(desktop.currentIndex, greaterThan(0));
    expect(
      desktop.navigationItems[desktop.currentIndex].label,
      PageLabel.connections,
    );

    container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.resources);
    expect(container.read(navigationStateProvider).currentIndex, 0);
  });

  test('layout and page state providers compose their dependencies', () {
    final profile = Profile.normal(label: 'Primary');
    _profiles(container).replace([profile]);
    container.read(currentProfileIdProvider.notifier).update((_) => profile.id);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 800));
    container.read(sideWidthProvider.notifier).update((_) => 200);

    final profiles = container.read(profilesStateProvider);
    expect(profiles.profiles.single.label, 'Primary');
    expect(profiles.currentProfileId, profile.id);

    final dashboard = container.read(dashboardStateProvider);
    expect(dashboard.dashboardWidgets, isNotEmpty);

    final actions = container.read(proxiesActionsStateProvider);
    expect(actions.pageLabel, PageLabel.dashboard);
    expect(actions.hasProviders, isFalse);
    expect(actions.type, ProxiesType.tab);
  });

  test(
    'proxy list and tab providers filter groups and preserve selections',
    () {
      final profile = Profile.normal().copyWith(
        currentGroupName: 'Group B',
        unfoldSet: {'Group A'},
      );
      final groups = [
        const Group(
          name: 'Group A',
          type: GroupType.Selector,
          hidden: false,
          all: [
            Proxy(name: 'Alpha', type: 'Direct'),
            Proxy(name: 'Beta', type: 'Direct'),
          ],
        ),
        const Group(
          name: 'Group B',
          type: GroupType.URLTest,
          hidden: false,
          testUrl: 'https://group.test',
          all: [Proxy(name: 'Gamma', type: 'Direct')],
        ),
      ];
      _profiles(container).replace([profile]);
      container
          .read(currentProfileIdProvider.notifier)
          .update((_) => profile.id);
      container.read(groupsProvider.notifier).update((_) => groups);
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.rule));
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(900, 800));

      expect(container.read(filterGroupsStateProvider('')).value, hasLength(2));
      final filtered = container.read(filterGroupsStateProvider('ALP')).value;
      expect(filtered, hasLength(1));
      expect(filtered.single.all.single.name, 'Alpha');

      container
          .read(queryProvider(QueryTag.proxies).notifier)
          .update((_) => 'ga');
      final list = container.read(proxiesListStateProvider);
      expect(list.groups.single.name, 'Group B');
      expect(list.currentUnfoldSet, {'Group A'});

      final tab = container.read(proxiesTabStateProvider);
      expect(tab.currentGroupName, 'Group B');
      expect(tab.groups.single.all.single.name, 'Gamma');
      final controller = container.read(proxiesTabControllerStateProvider);
      expect(controller.groupNames, ['Group B']);
      expect(controller.currentGroupName, 'Group B');

      final selector = container.read(
        proxyGroupSelectorStateProvider('Group A', 'be'),
      );
      expect(selector.proxies.single.name, 'Beta');
      expect(selector.groupType, GroupType.Selector);

      final missing = container.read(
        proxyGroupSelectorStateProvider('Missing', ''),
      );
      expect(missing.proxies, isEmpty);
      expect(missing.groupType, GroupType.Selector);
    },
  );

  test('runtime, VPN, tray, and DNS states follow live state', () {
    container
        .read(runTimeProvider.notifier)
        .update((_) => DateTime(2026).millisecondsSinceEpoch);
    container
        .read(networkSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            systemProxy: false,
            bypassDomain: const ['localhost'],
            autoSetSystemDns: true,
          ),
        );
    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: 8899,
            mode: Mode.global,
            tun: state.tun.copyWith(enable: true),
          ),
        );
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);

    container
        .read(authorizedTunEnableProvider.notifier)
        .update((_) => TunAuthorizationState.authorized);

    final proxy = container.read(proxyStateProvider);
    expect(proxy.isStart, isTrue);
    expect(proxy.systemProxy, isFalse);
    expect(proxy.bassDomain, ['localhost']);
    expect(proxy.port, 8899);
    expect(container.read(isStartProvider), isTrue);

    final tray = container.read(trayStateProvider);
    expect(tray.mode, Mode.global);
    expect(tray.port, 8899);
    expect(tray.tunEnable, isTrue);
    expect(tray.isStart, isTrue);

    final vpn = container.read(vpnStateProvider);
    expect(vpn.stack, container.read(patchClashConfigProvider).tun.stack);
    expect(vpn.vpnProps, container.read(vpnSettingProvider));

    expect(container.read(shouldPatchSystemDnsProvider), isTrue);

    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(autoSetSystemDns: false));
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);
    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(autoSetSystemDns: true));

    container
        .read(authorizedTunEnableProvider.notifier)
        .update((_) => TunAuthorizationState.unauthorized);
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);

    container.read(excludeSSIDsProvider.notifier).update((_) => ['Office']);
    container.read(currentSSIDProvider.notifier).update((_) => 'Office');
    expect(container.read(suspendProvider), isTrue);
    expect(container.read(proxyStateProvider).isStart, isFalse);
  });

  test('selection and delay providers resolve groups and profile state', () {
    final profile = Profile.normal().copyWith(
      selectedMap: {'Selector': 'Leaf'},
      unfoldSet: {'Selector'},
    );
    const groups = [
      Group(
        name: 'Selector',
        type: GroupType.Selector,
        all: [Proxy(name: 'Leaf', type: 'Direct')],
      ),
    ];
    _profiles(container).replace([profile]);
    container.read(currentProfileIdProvider.notifier).update((_) => profile.id);
    container.read(groupsProvider.notifier).update((_) => groups);
    container
        .read(delayDataSourceProvider.notifier)
        .setDelay(
          const Delay(
            name: 'Leaf',
            url: 'https://www.gstatic.com/generate_204',
            value: 42,
          ),
        );

    expect(container.read(selectedMapProvider), {'Selector': 'Leaf'});
    expect(container.read(unfoldSetProvider), {'Selector'});
    expect(container.read(proxyNameProvider('Selector')), 'Leaf');
    expect(container.read(selectedProxyNameProvider('Selector')), 'Leaf');
    expect(
      container.read(realSelectedProxyStateProvider('Selector')).proxyName,
      'Leaf',
    );
    expect(container.read(delayProvider(proxyName: 'Selector')), 42);
    expect(
      container.read(
        proxyDescProvider(const Proxy(name: 'Selector', type: 'Selector')),
      ),
      'Selector(Leaf)',
    );
    expect(
      container.read(
        proxyDescProvider(const Proxy(name: 'Leaf', type: 'Direct')),
      ),
      'Direct',
    );
  });

  test('theme and simple derived providers cover fallback branches', () {
    expect(container.read(currentBrightnessProvider), Brightness.dark);
    container
        .read(systemBrightnessProvider.notifier)
        .update((_) => Brightness.light);
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(themeMode: ThemeMode.system));
    expect(container.read(currentBrightnessProvider), Brightness.light);

    final fallback = container.read(
      genColorSchemeProvider(Brightness.light, ignoreConfig: true),
    );
    expect(fallback.brightness, Brightness.light);
    final explicit = container.read(
      genColorSchemeProvider(Brightness.dark, color: Colors.purple),
    );
    expect(explicit.brightness, Brightness.dark);

    expect(
      container.read(realTestUrlProvider('https://custom.test')),
      'https://custom.test',
    );
    expect(container.read(isCurrentPageProvider(PageLabel.dashboard)), isTrue);
    expect(
      container.read(
        isCurrentPageProvider(
          PageLabel.logs,
          handler: (_, viewMode) => viewMode == ViewMode.mobile,
        ),
      ),
      isTrue,
    );
  });

  test('package, hotkey, profile, and overwrite providers expose defaults', () {
    const package = Package(
      packageName: 'app.example',
      label: 'Example',
      system: false,
      internet: true,
      lastUpdateTime: 1,
    );
    container.read(packagesProvider.notifier).update((_) => [package]);
    final packageList = container.read(packageListSelectorStateProvider);
    expect(packageList.packages, [package]);
    expect(
      packageList.accessControlProps,
      container.read(vpnSettingProvider).accessControlProps,
    );

    const action = HotKeyAction(
      action: HotAction.start,
      key: 1,
      modifiers: {KeyboardModifier.control},
    );
    container.read(hotKeyActionsProvider.notifier).update((_) => [action]);
    expect(container.read(getHotKeyActionProvider(HotAction.start)), action);
    expect(
      container.read(getHotKeyActionProvider(HotAction.tun)).action,
      HotAction.tun,
    );

    final profile = Profile.normal().copyWith(
      overwriteType: OverwriteType.custom,
    );
    _profiles(container).replace([profile]);
    expect(container.read(profileProvider(profile.id)), profile);
    expect(
      container.read(overwriteTypeProvider(profile.id)),
      OverwriteType.custom,
    );
    expect(container.read(overwriteTypeProvider(-1)), OverwriteType.standard);

    expect(
      container.read(accessControlStateProvider),
      const AccessControlProps(),
    );
  });

  test('shared state follows the locale whose messages are loaded', () async {
    container.listen(sharedStateProvider, (_, _) {});
    await AppLocalizations.load(const Locale('en'));
    container.read(loadedLocaleProvider.notifier).value = const Locale('en');
    final en = container.read(sharedStateProvider);

    await AppLocalizations.load(const Locale('zh', 'CN'));
    addTearDown(() => AppLocalizations.load(const Locale('en')));
    expect(container.read(sharedStateProvider).stopText, en.stopText);

    container.read(loadedLocaleProvider.notifier).value = const Locale(
      'zh',
      'CN',
    );
    final zh = container.read(sharedStateProvider);
    expect(zh.stopText, isNot(en.stopText));
    expect(zh.stopTip, isNot(en.stopTip));
    expect(zh.startTip, isNot(en.startTip));
  });
}

TestProfiles _profiles(ProviderContainer container) {
  return container.read(profilesProvider.notifier) as TestProfiles;
}
