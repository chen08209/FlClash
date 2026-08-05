import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/groups.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxies.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxy_providers.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/rules.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

void main() {
  final cases = <String, Widget>{
    'dashboard': const DashboardView(),
    'proxies': const ProxiesView(),
    'profiles': const ProfilesView(),
    'requests': const RequestsView(),
    'resources': const ResourcesView(),
    'logs': const LogsView(),
    'tools': const ToolsView(),
    'basic config': const ConfigView(),
    'dns config': const Scaffold(body: DnsListView()),
    'network config': const Scaffold(body: NetworkListView()),
    'advanced config': const AdvancedConfigView(),
    'on demand config': const OnDemandView(),
    'theme': const ThemeView(),
    'application settings': const ApplicationSettingView(),
    'backup and restore': const BackupAndRestore(),
    'hotkeys': const HotKeyView(),
    'access control': const AccessView(),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key} renders its default state', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
      );
      addTearDown(container.dispose);
      globalState.container = container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestApp(child: entry.value),
        ),
      );
      await tester.pump();
      if (entry.key == 'access control') {
        await tester.pump(const Duration(milliseconds: 301));
      }
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        for (var index = 0; index < 8; index++) {
          await tester.drag(scrollables.first, const Offset(0, -700));
          await tester.pump();
        }
      }

      expect(find.byWidget(entry.value), findsOneWidget);
      expect(tester.takeException(), null);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  final toolDestinations = <String, Type>{
    'Theme': ThemeView,
    'Backup and Restore': BackupAndRestore,
    'Basic configuration': ConfigView,
    'Advanced configuration': AdvancedConfigView,
    'Application': ApplicationSettingView,
  };

  for (final entry in toolDestinations.entries) {
    testWidgets('tools opens ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: ToolsView()),
        ),
      );
      await tester.pump();

      final target = find.text(entry.key);
      await tester.scrollUntilVisible(
        target,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(target);
      await tester.pumpAndSettle();

      expect(find.byType(entry.value), findsOneWidget);
      expect(tester.takeException(), null);
    });
  }

  testWidgets('user agent dialog applies a preset', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 800));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: Scaffold(body: ListView(children: const [UaItem()])),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('User-Agent'));
    await tester.pumpAndSettle();
    expect(find.text('clash-verge/v2.4.2'), findsOneWidget);

    await tester.tap(find.text('clash-verge/v2.4.2'));
    await tester.pumpAndSettle();

    expect(
      container.read(patchClashConfigProvider).globalUa,
      'clash-verge/v2.4.2',
    );
    expect(tester.takeException(), null);
  });

  testWidgets('DNS mode options update the patch configuration', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 800));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: Scaffold(body: DnsModeItem())),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DNS mode'));
    await tester.pumpAndSettle();
    expect(find.text('fakeIp'), findsWidgets);

    await tester.tap(find.text('fakeIp').last);
    await tester.pumpAndSettle();

    expect(
      container.read(patchClashConfigProvider).dns.enhancedMode,
      DnsMode.fakeIp,
    );

    final previousOverride = container.read(overrideDnsProvider);
    final previousDns = container.read(patchClashConfigProvider).dns;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(
          child: Scaffold(
            body: Column(
              children: [
                OverrideItem(),
                StatusItem(),
                PreferH3Item(),
                IPv6Item(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Override Dns'));
    await tester.pump();
    await tester.tap(find.text('Status'));
    await tester.pump();
    await tester.tap(find.text('PreferH3'));
    await tester.pump();
    await tester.tap(find.text('IPv6'));
    await tester.pump();

    expect(container.read(overrideDnsProvider), !previousOverride);
    expect(
      container.read(patchClashConfigProvider).dns.enable,
      !previousDns.enable,
    );
    expect(
      container.read(patchClashConfigProvider).dns.preferH3,
      !previousDns.preferH3,
    );
    expect(
      container.read(patchClashConfigProvider).dns.ipv6,
      !previousDns.ipv6,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('proxies renders populated tab and list layouts', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      currentGroupName: 'Selector',
      selectedMap: {'Selector': 'Proxy 1'},
      unfoldSet: {'Selector'},
    );
    final proxies = List.generate(
      24,
      (index) => Proxy(name: 'Proxy $index', type: 'Direct'),
    );
    final group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Proxy 1',
      all: proxies,
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => _TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [group]),
        ),
        groupsProvider.overrideWithValue([group]),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: ProxiesView()),
      ),
    );
    await tester.pump();

    expect(container.read(proxiesTabStateProvider).groups, [group]);
    expect(find.byType(ProxiesTabView), findsOneWidget);
    expect(find.byType(ProxyGroupView), findsOneWidget);

    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.list));
    await tester.pump();
    expect(find.byType(ProxiesListView), findsOneWidget);

    final scrollables = find.byType(Scrollable);
    for (var index = 0; index < 8; index++) {
      await tester.drag(
        scrollables.last,
        const Offset(0, -700),
        warnIfMissed: false,
      );
      await tester.pump();
    }
    expect(tester.takeException(), null);
  });

  testWidgets('custom overwrite editors render populated data', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      overwriteType: OverwriteType.custom,
    );
    final proxyGroups = List.generate(
      8,
      (index) => ProxyGroup(
        id: 100 + index,
        profileId: profile.id,
        name: 'Group $index',
        type: GroupType.Selector,
        proxies: const ['DIRECT'],
      ),
    );
    final rules = List.generate(
      12,
      (index) => Rule(
        id: 200 + index,
        content: 'example$index.com',
        ruleTarget: 'DIRECT',
        order: index.toString(),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => _TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileCustomRulesProvider.overrideWith2(
          (_) => _TestProfileCustomRules(rules),
        ),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(proxyGroups)),
        proxyGroupProvider.overrideWithBuild((_, _) => proxyGroups.first),
        clashConfigProvider(profile.id).overrideWithValue(
          const AsyncData(
            ClashConfig(
              proxies: [Proxy(name: 'DIRECT', type: 'Direct')],
              proxyProviders: ['provider'],
            ),
          ),
        ),
        customOverwriteDateProvider(profile.id).overrideWithValue(
          CustomOverwriteDate(
            proxies: const [Proxy(name: 'DIRECT', type: 'Direct')],
            proxyGroups: proxyGroups,
            proxyProviders: const {'provider'},
            ruleTargets: {
              ...RuleTarget.baseTargets,
              ...proxyGroups.map((group) => group.name),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));

    final views = <Widget>[
      CustomRulesView(profile.id),
      CustomProxyGroupsView(profile.id),
      SheetProvider(
        type: SheetType.page,
        child: ProfileIdProvider(
          profileId: profile.id,
          child: const EditProxiesView(),
        ),
      ),
      SheetProvider(
        type: SheetType.page,
        child: ProfileIdProvider(
          profileId: profile.id,
          child: const EditProxyProvidersView(),
        ),
      ),
    ];

    for (final view in views) {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestApp(child: view),
        ),
      );
      await tester.pump();
      expect(find.byWidget(view), findsOneWidget);
      expect(tester.takeException(), null);

      if (view is CustomRulesView) {
        final list = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );
        list.onReorderItem!(0, 1);
        await tester.pump();

        await tester.tap(find.byType(Checkbox).first);
        await tester.pump();
        expect(find.text('Select all'), findsOneWidget);
        await tester.tap(find.text('Select all'));
        await tester.pump();
        await tester.tap(find.text('Select all'));
        await tester.pump();
        expect(find.text('Add'), findsOneWidget);

        container
            .read(viewSizeProvider.notifier)
            .update((_) => const Size(500, 1000));
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        expect(find.byType(SheetViewport), findsOneWidget);
        globalState.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        container
            .read(viewSizeProvider.notifier)
            .update((_) => const Size(1400, 1000));
      }

      if (view is CustomProxyGroupsView) {
        final list = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );
        list.onReorderItem!(0, 1);
        await tester.pump();

        container
            .read(viewSizeProvider.notifier)
            .update((_) => const Size(500, 1000));
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        expect(find.byType(SheetViewport), findsOneWidget);
        globalState.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        container
            .read(viewSizeProvider.notifier)
            .update((_) => const Size(1400, 1000));
      }
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles([this.initial = const []]);

  @override
  List<Profile> build() => initial;
}

class _TestProfileCustomRules extends ProfileCustomRules {
  final List<Rule> initial;

  _TestProfileCustomRules(this.initial);

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        globalState.theme = CommonTheme.of(context, 1);
        return child!;
      },
      home: child,
    );
  }
}
