import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProfileCustomRules extends ProfileCustomRules {
  _RecordingProfileCustomRules(this.initial);

  final List<Rule> initial;
  final List<Rule> puts = [];

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void put(Rule rule) => puts.add(rule);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestOverwriteData extends Notifier<CustomOverwriteDate> {
  @override
  CustomOverwriteDate build() {
    return const CustomOverwriteDate(
      ruleTargets: {'DIRECT'},
      proxies: [Proxy(name: 'DIRECT', type: 'Direct')],
    );
  }
}

final _testOverwriteDataProvider =
    NotifierProvider<_TestOverwriteData, CustomOverwriteDate>(
      _TestOverwriteData.new,
    );

class _Harness {
  late final ProviderContainer container;
  late final _RecordingProfileCustomRules rules;
  late final Profile profile;

  Future<void> pump(WidgetTester tester) async {
    const size = Size(1400, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    profile = Profile.normal(label: 'profile');
    rules = _RecordingProfileCustomRules(const []);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileCustomRulesProvider.overrideWith2((_) => rules),
        customOverwriteDateProvider(
          profile.id,
        ).overrideWith((ref) => ref.watch(_testOverwriteDataProvider)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: CustomRulesView(profile.id)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('the add sheet opens with the basic info form', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.basicInfo), findsOne);
    expect(find.text(l10n.proxyType), findsOne);
    expect(find.text(l10n.content), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('saving without content is rejected and nothing is stored', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);
    await harness.save(tester);

    expect(find.text(currentAppLocalizations.contentNotEmpty), findsOne);
    expect(harness.rules.puts, isEmpty);
  });

  // Rule.init() seeds ruleTarget with DIRECT, so the empty-target guard is only
  // reachable through SUB_RULE, where realTarget reads the unset subRule.
  testWidgets('a SUB_RULE without a sub rule is rejected', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();
    // SUB_RULE sits far down a lazily built list, so scroll it into existence.
    await tester.scrollUntilVisible(
      find.text(RuleAction.SUB_RULE.name),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(RuleAction.SUB_RULE.name).last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.pumpAndSettle();
    await harness.save(tester);

    expect(find.text(currentAppLocalizations.subRuleNotEmpty), findsOne);
    expect(harness.rules.puts, isEmpty);
  });

  testWidgets('a complete rule is stored with a generated id', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.pumpAndSettle();

    // Pick the only available target through the target selection sheet.
    await tester.tap(find.text(currentAppLocalizations.splitStrategy));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DIRECT').last);
    await tester.pumpAndSettle();

    await harness.save(tester);

    expect(harness.rules.puts, hasLength(1));
    final stored = harness.rules.puts.single;
    expect(stored.content, 'example.com');
    expect(stored.ruleTarget, 'DIRECT');
    expect(stored.id, isNot(-1), reason: 'a new rule gets a snowflake id');
  });
}
