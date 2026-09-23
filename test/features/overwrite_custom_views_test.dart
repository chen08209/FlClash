import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/groups.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

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
  final List<Set<int>> deleted = [];

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}

  @override
  void delAll(Iterable<int> proxyGroupIds) {
    deleted.add(proxyGroupIds.toSet());
  }
}

class _TestOverwriteData extends Notifier<CustomOverwriteDate> {
  @override
  CustomOverwriteDate build() {
    return const CustomOverwriteDate(
      loaded: true,
      ruleTargets: {'DIRECT'},
      proxyNames: ['DIRECT'],
      proxyTypes: {'DIRECT': 'Direct'},
    );
  }

  void setRuleTargets(Set<String> ruleTargets) {
    state = state.copyWith(ruleTargets: ruleTargets);
  }
}

final _testOverwriteDataProvider =
    NotifierProvider<_TestOverwriteData, CustomOverwriteDate>(
      _TestOverwriteData.new,
    );

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<_TestProxyGroups> _pumpProxyGroups(WidgetTester tester) async {
  _setViewport(tester);
  final profile = Profile.normal().copyWith(
    overwriteType: OverwriteType.custom,
  );
  final proxyGroups = List.generate(
    3,
    (index) => ProxyGroup(
      id: 100 + index,
      profileId: profile.id,
      name: 'Group $index',
      type: GroupType.Selector,
      proxies: const ['DIRECT'],
    ),
  );
  final notifier = _TestProxyGroups(proxyGroups);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      proxyGroupsProvider.overrideWith2((_) => notifier),
      customOverwriteDateProvider(profile.id).overrideWithValue(
        CustomOverwriteDate(
          loaded: true,
          proxyNames: const ['DIRECT'],
          proxyTypes: const {'DIRECT': 'Direct'},
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

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: CustomProxyGroupsView(profile.id)),
    ),
  );
  await tester.pump();
  return notifier;
}

void main() {
  testWidgets('groups list rounds only the first and last rows', (
    tester,
  ) async {
    await _pumpProxyGroups(tester);

    final rows = find.byType(DecorationListItem);
    expect(rows, findsNWidgets(3));
    expect(
      find.descendant(of: rows.first, matching: find.byType(Divider)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rows.last, matching: find.byType(Divider)),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('groups list deletes the checked groups', (tester) async {
    final notifier = await _pumpProxyGroups(tester);

    await tester.tap(find.byType(CommonCheckBox).at(0));
    await tester.pump();
    await tester.tap(find.text('Group 2'));
    await tester.pump();
    await tester.tap(find.byTooltip(AppLocalizations.current.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizations.current.confirm));
    await tester.pumpAndSettle();

    expect(notifier.deleted.single, {100, 102});

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('group editor keeps long values inside its rows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profile = Profile.normal().copyWith(
      overwriteType: OverwriteType.custom,
    );
    final proxyGroups = [
      ProxyGroup(
        id: 100,
        profileId: profile.id,
        name: 'a-very-long-proxy-group-name-that-goes-on-and-on',
        type: GroupType.URLTest,
        icon: 'https://example.com/a/very/long/path/to/an/icon/file/name.png',
        filter: '(?i)hk|hong ?kong|an extremely long filter expression here',
        url: 'https://www.gstatic.com/generate_204/a/very/long/url/path',
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(proxyGroups)),
        customOverwriteDateProvider(profile.id).overrideWithValue(
          CustomOverwriteDate(
            loaded: true,
            proxyNames: const ['DIRECT'],
            proxyTypes: const {'DIRECT': 'Direct'},
            proxyGroups: proxyGroups,
            ruleTargets: RuleTarget.baseTargets,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(360, 800));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: CustomProxyGroupsView(profile.id)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(proxyGroups.single.name));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(OverwriteFormRow), findsWidgets);

    await tester.enterText(find.byType(TextFormField).first, 'y' * 400);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('rule invalid state refreshes when rule targets change', (
    tester,
  ) async {
    _setViewport(tester);
    final profile = Profile.normal().copyWith(
      overwriteType: OverwriteType.custom,
    );
    final rules = [
      const Rule(
        id: 1,
        content: 'example.com',
        ruleTarget: 'missing',
        order: '1',
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileCustomRulesProvider.overrideWith2(
          (_) => _TestProfileCustomRules(rules),
        ),
        customOverwriteDateProvider(profile.id).overrideWith((ref) {
          return ref.watch(_testOverwriteDataProvider);
        }),
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
        child: TestApp(child: CustomRulesView(profile.id)),
      ),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.info), findsOneWidget);

    container.read(_testOverwriteDataProvider.notifier).setRuleTargets({
      ...container.read(_testOverwriteDataProvider).ruleTargets,
      'missing',
    });
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.info), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'a rule the core would reject is flagged despite a DIRECT target',
    (tester) async {
      _setViewport(tester);
      final profile = Profile.normal().copyWith(
        overwriteType: OverwriteType.custom,
      );
      final rules = [
        Rule.parse('NETWORK,tcp,DIRECT', id: 1).copyWith(order: '1'),
        Rule.parse('NETWORK,icmp,DIRECT', id: 2).copyWith(order: '2'),
        Rule.parse('RULE-SET,known,DIRECT', id: 3).copyWith(order: '3'),
        Rule.parse('RULE-SET,gone,DIRECT', id: 4).copyWith(order: '4'),
      ];
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestProfileCustomRules(rules),
          ),
          customOverwriteDateProvider(profile.id).overrideWithValue(
            const CustomOverwriteDate(
              loaded: true,
              ruleTargets: {'DIRECT'},
              ruleProviders: {'known'},
            ),
          ),
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
          child: TestApp(child: CustomRulesView(profile.id)),
        ),
      );
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.info), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
