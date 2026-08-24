import 'package:fl_clash/enum/enum.dart';
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

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
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

void main() {
  testWidgets('groups list rounds only the first and last rows', (
    tester,
  ) async {
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

    expect(find.byIcon(Icons.info), findsOneWidget);

    container.read(_testOverwriteDataProvider.notifier).setRuleTargets({
      ...container.read(_testOverwriteDataProvider).ruleTargets,
      'missing',
    });
    await tester.pump();

    expect(find.byIcon(Icons.info), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
