import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxies.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxy_providers.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  ProviderContainer buildContainer(ProxyGroup group) {
    final profile = Profile.normal(
      label: 'p',
    ).copyWith(id: _profileId, overwriteType: OverwriteType.custom);
    final built = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
        proxyGroupProvider.overrideWithBuild((_, _) => group),
        clashConfigProvider(_profileId).overrideWithValue(
          const AsyncData(
            ClashConfig(
              proxies: [Proxy(name: 'DIRECT', type: 'Direct')],
              proxyProviders: ['provider-a'],
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
          .widget<SliverReorderableList>(find.byType(SliverReorderableList))
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

    testWidgets('reordering rewrites the use list', (tester) async {
      container = buildContainer(_group(use: ['provider-a', 'provider-b']));

      await pumpEditView(tester, const EditProxyProvidersView());
      tester
          .widget<SliverReorderableList>(find.byType(SliverReorderableList))
          .onReorderItem!(0, 1);
      await tester.pump();

      expect(container.read(proxyGroupProvider).use, [
        'provider-b',
        'provider-a',
      ]);
    });
  });
}
