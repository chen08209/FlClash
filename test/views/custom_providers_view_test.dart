import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

class _TestProxyGroups extends ProxyGroups {
  _TestProxyGroups(this.groups);

  final List<ProxyGroup> groups;

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(groups);
}

class _TestProfileRules extends ProfileRules {
  _TestProfileRules(this.rules);

  final List<Rule> rules;

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(rules);
}

class _TestClashProviders extends ClashProviders {
  @override
  Stream<List<ClashProvider>> build() => Stream.value(const [
    ClashProvider(
      id: 1,
      label: 'cn',
      url: 'https://example.com/cn.yaml',
      behavior: RuleProviderBehavior.domain,
    ),
  ]);
}

class _TestCustomProxies extends CustomProxies {
  @override
  Stream<List<CustomProxy>> build() => Stream.value(const []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProvider(
      Directory.systemTemp.createTempSync('custom_providers').path,
    );
  });

  Future<void> pumpView(
    WidgetTester tester, {
    List<ProxyGroup> groups = const [],
    List<Rule> rules = const [],
    ProfileOverrides overrides = const ProfileOverrides(),
    bool loaded = true,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            Profile(
              id: _profileId,
              label: 'mine',
              type: ProfileType.custom,
              autoUpdateDuration: Duration.zero,
              overrides: overrides,
            ),
            Profile.normal(
              label: 'sub',
              url: 'https://example.com/sub',
            ).copyWith(id: 2, lastUpdateDate: DateTime.now()),
          ]),
        ),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(groups)),
        profileRulesProvider.overrideWith2((_) => _TestProfileRules(rules)),
        clashProvidersProvider.overrideWith(_TestClashProviders.new),
        customProxiesProvider.overrideWith(_TestCustomProxies.new),
        customProfileDataProvider(_profileId).overrideWithValue(
          loaded
              ? const CustomProfileData(
                  proxyProviders: {'sub'},
                  ruleProviders: {'cn'},
                )
              : null,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: CustomProvidersView(_profileId)),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  ProfileOverrides overrides() =>
      container.read(profilesProvider).getProfile(_profileId)!.overrides;

  testWidgets('lists the providers its groups and rules name', (tester) async {
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(
          id: 1,
          name: 'g',
          type: GroupType.Selector,
          use: ['sub', 'gone'],
        ),
      ],
      rules: [
        Rule.parse('RULE-SET,cn,DIRECT', id: 2),
        Rule.parse('RULE-SET,missing,DIRECT', id: 3),
      ],
    );
    final l = currentAppLocalizations;

    for (final name in ['sub', 'gone', 'cn', 'missing']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.text(l.proxies), findsOneWidget);
    expect(find.text(l.rules), findsOneWidget);
    expect(find.byType(LastUpdateTimeText), findsOneWidget);
    expect(find.text('https://example.com/sub'), findsNothing);
    expect(find.byType(InfoMessageButton), findsNWidgets(2));
  });

  testWidgets('marks no provider missing until the profile data loads', (
    tester,
  ) async {
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(id: 1, name: 'g', type: GroupType.Selector, use: ['gone']),
      ],
      rules: [Rule.parse('RULE-SET,missing,DIRECT', id: 2)],
      loaded: false,
    );

    expect(find.text('gone'), findsOneWidget);
    expect(find.text('missing'), findsOneWidget);
    expect(find.byType(InfoMessageButton), findsNothing);
  });

  testWidgets('a provider sets only the options added in its sheet', (
    tester,
  ) async {
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(id: 1, name: 'g', type: GroupType.Selector, use: ['sub']),
      ],
    );
    final l = currentAppLocalizations;

    await tester.tap(find.byTooltip(l.edit));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byTooltip(l.quickEdit), findsNothing);

    await tester.tap(find.text(l.addSettingEntry));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.testInterval));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '600');
    await tester.tap(find.byTooltip(l.save));
    await tester.pumpAndSettle();

    expect(
      overrides().proxyProviders['sub'],
      const ProxyProviderOptions(
        healthCheck: ProviderHealthCheck(interval: 600),
      ),
    );
  });

  testWidgets('an override starts at the value it is added to set', (
    tester,
  ) async {
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(id: 1, name: 'g', type: GroupType.Selector, use: ['sub']),
      ],
    );
    final l = currentAppLocalizations;

    await tester.tap(find.byTooltip(l.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.addSettingEntry));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UDP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.ipVersion));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.save));
    await tester.pumpAndSettle();

    expect(
      overrides().proxyProviders['sub'],
      const ProxyProviderOptions(
        proxyOverride: ProviderOverride(udp: true, ipVersion: IpVersion.dual),
      ),
    );
  });

  testWidgets('filters are picked from the presets as member rows', (
    tester,
  ) async {
    final hongKong = defaultFilters.first;
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(id: 1, name: 'g', type: GroupType.Selector, use: ['sub']),
      ],
      overrides: const ProfileOverrides(
        proxyProviders: {'sub': ProxyProviderOptions(excludeFilter: 'x')},
      ),
    );
    final l = currentAppLocalizations;
    final picker = find.byWidgetPredicate(
      (widget) =>
          widget.runtimeType.toString() ==
          '_MemberPicker<ProxyProviderOptions>',
    );

    await tester.tap(find.byTooltip(l.edit));
    await tester.pumpAndSettle();
    expect(find.text('x'), findsOneWidget);
    await tester.tap(find.text(l.addFilters));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: picker,
        matching: find.textContaining('${l.filters} ('),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: picker, matching: find.text(hongKong.label)),
    );
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(hongKong.label), findsOneWidget);

    final excluded = find.ancestor(
      of: find.text('x'),
      matching: find.byType(DecorationListItem),
    );
    await tester.tap(
      find.descendant(of: excluded, matching: find.byTooltip(l.remove)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.save));
    await tester.pumpAndSettle();

    expect(
      overrides().proxyProviders['sub'],
      ProxyProviderOptions(filter: hongKong.regex),
    );
  });

  testWidgets('tapping a provider opens the same sheet', (tester) async {
    await pumpView(
      tester,
      groups: const [
        ProxyGroup(id: 1, name: 'g', type: GroupType.Selector, use: ['sub']),
      ],
    );
    final l = currentAppLocalizations;

    await tester.tap(find.text('sub'));
    await tester.pumpAndSettle();
    expect(find.text(l.addSettingEntry), findsOneWidget);
  });

  testWidgets('a rule set is listed without opening its options', (
    tester,
  ) async {
    await pumpView(tester, rules: [Rule.parse('RULE-SET,cn,DIRECT', id: 2)]);

    await tester.tap(find.text('cn'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('an empty page says it has no providers', (tester) async {
    await pumpView(tester);

    final l = currentAppLocalizations;
    expect(find.text(l.nullTip(l.providers)), findsOneWidget);
  });
}
