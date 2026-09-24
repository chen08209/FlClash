import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/groups.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxies.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxy_providers.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/super_reorderable_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

const _appProvider = ClashProvider(
  id: 9,
  kind: ProviderKind.proxy,
  label: 'Shared nodes',
  url: 'https://example.com/nodes.yaml',
);

class _TestClashProviders extends ClashProviders {
  @override
  Stream<List<ClashProvider>> build(ProviderKind kind) => Stream.value(
    kind == ProviderKind.proxy ? const [_appProvider] : const [],
  );
}

ProxyGroup _group({
  List<String>? proxies,
  List<String>? use,
  bool? includeAllProxies,
  bool? includeAllProviders,
}) {
  return ProxyGroup(
    id: 100,
    profileId: _profileId,
    name: 'Group',
    type: GroupType.Selector,
    proxies: proxies,
    use: use,
    includeAllProxies: includeAllProxies,
    includeAllProviders: includeAllProviders,
  );
}

Finder _rowOf(String title) => find
    .ancestor(of: find.text(title), matching: find.byType(OverwriteFormRow))
    .first;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => feature = const Feature(customProviders: true, customProxies: true),
  );
  tearDown(() => feature = const Feature());

  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  ProviderContainer buildContainer(
    ProxyGroup group, {
    List<String> proxyProviders = const ['provider-a'],
  }) {
    final profile = Profile.normal(
      label: 'p',
    ).copyWith(id: _profileId, overwriteType: OverwriteType.custom);
    final built = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        clashProvidersProvider.overrideWith2((_) => _TestClashProviders()),
        currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
        proxyGroupProvider.overrideWithBuild((_, _) => group),
        clashConfigProvider(_profileId).overrideWithValue(
          AsyncData(
            ClashConfig(
              proxies: const [Proxy(name: 'DIRECT', type: 'Direct')],
              proxyProviders: proxyProviders,
            ),
          ),
        ),
      ],
    );
    addTearDown(built.dispose);
    globalState.container = built;
    built.read(viewSizeProvider.notifier).update((_) => const Size(1400, 1000));
    return built;
  }

  Future<void> pumpEditView(WidgetTester tester, Widget view) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: SheetProvider(
            type: SheetType.page,
            child: ProfileIdProvider(profileId: _profileId, child: view),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('EditProxiesView', () {
    testWidgets('lists the selected proxies', (tester) async {
      container = buildContainer(_group(proxies: ['DIRECT', 'REJECT']));

      await pumpEditView(tester, const EditProxiesView());

      expect(find.text('DIRECT'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the proxies empty state when none are selected', (
      tester,
    ) async {
      container = buildContainer(_group(proxies: const []));

      await pumpEditView(tester, const EditProxiesView());

      expect(find.text(currentAppLocalizations.proxiesEmpty), findsOneWidget);
    });

    testWidgets('the include toggle reflects includeAllProxies', (
      tester,
    ) async {
      container = buildContainer(
        _group(proxies: const [], includeAllProxies: true),
      );

      await pumpEditView(tester, const EditProxiesView());

      expect(
        find.text(currentAppLocalizations.includeAllProxies),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('toggling the switch flips includeAllProxies only', (
      tester,
    ) async {
      container = buildContainer(
        _group(proxies: const [], includeAllProxies: false),
      );

      await pumpEditView(tester, const EditProxiesView());
      await tester.tap(find.byType(Switch));
      await tester.pump();

      final group = container.read(proxyGroupProvider);
      expect(group.includeAllProxies, isTrue);
      expect(group.includeAllProviders, isNull);
    });

    testWidgets('reordering rewrites the proxies list', (tester) async {
      container = buildContainer(_group(proxies: ['DIRECT', 'REJECT']));

      await pumpEditView(tester, const EditProxiesView());
      tester
          .widget<SliverReorderableList>(
            find.byType(SuperSliverReorderableList),
          )
          .onReorderItem!(0, 1);
      await tester.pump();

      expect(container.read(proxyGroupProvider).proxies, ['REJECT', 'DIRECT']);
    });
  });

  group('EditProxyProvidersView', () {
    testWidgets('lists the selected providers', (tester) async {
      container = buildContainer(_group(use: ['provider-a']));

      await pumpEditView(tester, const EditProxyProvidersView());

      expect(find.text('provider-a'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the providers empty state when none are selected', (
      tester,
    ) async {
      container = buildContainer(_group(use: const []));

      await pumpEditView(tester, const EditProxyProvidersView());

      expect(
        find.text(currentAppLocalizations.proxyProvidersEmpty),
        findsOneWidget,
      );
    });

    testWidgets('the include toggle reflects includeAllProviders', (
      tester,
    ) async {
      container = buildContainer(
        _group(use: const [], includeAllProviders: true),
      );

      await pumpEditView(tester, const EditProxyProvidersView());

      expect(
        find.text(currentAppLocalizations.includeAllProxyProviders),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('toggling the switch flips includeAllProviders only', (
      tester,
    ) async {
      container = buildContainer(
        _group(use: const [], includeAllProviders: false),
      );

      await pumpEditView(tester, const EditProxyProvidersView());
      await tester.tap(find.byType(Switch));
      await tester.pump();

      final group = container.read(proxyGroupProvider);
      expect(group.includeAllProviders, isTrue);
      expect(group.includeAllProxies, isNull);
    });

    testWidgets('the add picker separates app-level providers', (tester) async {
      container = buildContainer(_group(use: const []));

      await pumpEditView(tester, const AddProxyProvidersView());

      expect(
        find.text(currentAppLocalizations.appProxyProviders),
        findsOneWidget,
      );
      expect(find.text('Shared nodes'), findsOneWidget);
      expect(find.text('p'), findsOneWidget);
      expect(find.text('provider-a'), findsOneWidget);
    });

    testWidgets('the add picker keeps a name the subscription has its own', (
      tester,
    ) async {
      container = buildContainer(
        _group(use: const []),
        proxyProviders: const ['provider-a', 'Shared nodes'],
      );

      await pumpEditView(tester, const AddProxyProvidersView());

      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      final appSection = top(currentAppLocalizations.appProxyProviders);
      expect(find.text('Shared nodes'), findsOneWidget);
      expect(top('Shared nodes'), lessThan(appSection));
      expect(
        find.text(currentAppLocalizations.appProviderShadowed),
        findsOneWidget,
      );
      expect(top('p'), greaterThan(appSection));
      expect(find.text(currentAppLocalizations.profile), findsOneWidget);
    });

    testWidgets('the selected providers say where each one resolves', (
      tester,
    ) async {
      container = buildContainer(
        _group(use: ['provider-a', 'Shared nodes', 'p']),
      );

      await pumpEditView(tester, const EditProxyProvidersView());

      for (final source in [
        currentAppLocalizations.providerSourceSubscription,
        currentAppLocalizations.app,
        currentAppLocalizations.profile,
      ]) {
        expect(find.text(source), findsOneWidget, reason: source);
      }
    });

    testWidgets('with custom providers off the selected show no source', (
      tester,
    ) async {
      feature = const Feature();
      container = buildContainer(_group(use: ['provider-a']));

      await pumpEditView(tester, const EditProxyProvidersView());

      expect(find.text('provider-a'), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.providerSourceSubscription),
        findsNothing,
      );
    });

    testWidgets('with custom providers off the add picker lists only the '
        'subscription', (tester) async {
      feature = const Feature();
      container = buildContainer(
        _group(use: const []),
        proxyProviders: const ['provider-a', 'Shared nodes'],
      );

      await pumpEditView(tester, const AddProxyProvidersView());

      expect(find.text('provider-a'), findsOneWidget);
      expect(find.text('Shared nodes'), findsOneWidget);
      expect(find.text('p'), findsNothing);
      expect(
        find.text(currentAppLocalizations.appProxyProviders),
        findsNothing,
      );
      expect(
        find.text(currentAppLocalizations.appProviderShadowed),
        findsNothing,
      );
    });

    testWidgets('reordering rewrites the use list', (tester) async {
      container = buildContainer(_group(use: ['provider-a', 'provider-b']));

      await pumpEditView(tester, const EditProxyProvidersView());
      tester
          .widget<SliverReorderableList>(
            find.byType(SuperSliverReorderableList),
          )
          .onReorderItem!(0, 1);
      await tester.pump();

      expect(container.read(proxyGroupProvider).use, [
        'provider-b',
        'provider-a',
      ]);
    });
  });

  group('EditProxyGroupView', () {
    testWidgets('shows lazy on, as the core defaults it', (tester) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());

      final lazy = tester.widget<Switch>(
        find.descendant(
          of: _rowOf(currentAppLocalizations.testWhenUsed),
          matching: find.byType(Switch),
        ),
      );
      expect(lazy.value, isTrue);
    });

    testWidgets('does not offer the relay type the core removed', (
      tester,
    ) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.tap(find.text(currentAppLocalizations.proxyType));
      await tester.pumpAndSettle();

      expect(find.text(GroupType.Selector.name), findsWidgets);
      expect(find.text(GroupType.LoadBalance.name), findsOneWidget);
      expect(find.text(GroupType.Relay.name), findsNothing);
    });

    testWidgets('offers tolerance only to a url-test group', (tester) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());
      expect(find.text(currentAppLocalizations.tolerance), findsNothing);

      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(type: GroupType.URLTest));
      await tester.pump();

      expect(find.text(currentAppLocalizations.tolerance), findsOneWidget);
      expect(find.text(currentAppLocalizations.strategy), findsNothing);
    });

    testWidgets('offers strategy only to a load-balance group', (tester) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());
      container
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(type: GroupType.LoadBalance));
      await tester.pump();

      expect(find.text(currentAppLocalizations.strategy), findsOneWidget);
      expect(
        find.text(LoadBalanceStrategy.consistentHashing.value),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text(currentAppLocalizations.strategy));
      await tester.pump();
      await tester.tap(find.text(currentAppLocalizations.strategy));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LoadBalanceStrategy.roundRobin.value));
      await tester.pumpAndSettle();

      expect(
        container.read(proxyGroupProvider).strategy,
        LoadBalanceStrategy.roundRobin,
      );
    });

    testWidgets('writes the timeout the core reads in milliseconds', (
      tester,
    ) async {
      container = buildContainer(_group());

      await pumpEditView(tester, const EditProxyGroupView());
      await tester.ensureVisible(find.text(currentAppLocalizations.timeout));
      await tester.pump();
      await tester.enterText(
        find.descendant(
          of: _rowOf(currentAppLocalizations.timeout),
          matching: find.byType(TextFormField),
        ),
        '2500',
      );
      await tester.pump();

      expect(container.read(proxyGroupProvider).timeout, 2500);
      expect(find.text('ms'), findsWidgets);
    });
  });
}
