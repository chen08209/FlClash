import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/rules.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProfileCustomRules extends ProfileCustomRules {
  _RecordingProfileCustomRules(this.initial);

  final List<Rule> initial;
  final List<Rule> puts = [];
  final List<int> deletes = [];

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void put(Rule rule) => puts.add(rule);

  @override
  void delAll(Iterable<int> ruleIds) => deletes.addAll(ruleIds);

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
}

final _testOverwriteDataProvider =
    NotifierProvider<_TestOverwriteData, CustomOverwriteDate>(
      _TestOverwriteData.new,
    );

class _Harness {
  late final ProviderContainer container;
  late final _RecordingProfileCustomRules rules;
  late final Profile profile;

  Future<void> pump(
    WidgetTester tester, {
    List<Rule> initialRules = const [],
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    profile = Profile.normal(label: 'profile');
    rules = _RecordingProfileCustomRules(initialRules);
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

  Future<void> selectType(WidgetTester tester, RuleAction action) async {
    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(action.name),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(action.name).last);
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

  testWidgets('a MATCH rule saves without a content field', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(RuleAction.MATCH.name),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(RuleAction.MATCH.name).last);
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.content), findsNothing);

    await harness.save(tester);

    expect(find.text(currentAppLocalizations.contentNotEmpty), findsNothing);
    expect(harness.rules.puts, hasLength(1));
    final stored = harness.rules.puts.single;
    expect(stored.ruleAction, RuleAction.MATCH);
    expect(stored.ruleTarget, 'DIRECT');
    expect(stored.rawValue, 'MATCH,DIRECT');
  });

  testWidgets('the type sheet opens scrolled to the selected action', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(RuleAction.SUB_RULE.name),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(RuleAction.SUB_RULE.name).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();

    final sheet = find.byType(OverwriteSelectionSheet<RuleAction>);
    final item = find.descendant(
      of: sheet,
      matching: find.text(RuleAction.SUB_RULE.name),
    );
    expect(item, findsOne);
    final viewport = tester.getRect(
      find.descendant(of: sheet, matching: find.byType(CustomScrollView)),
    );
    final itemRect = tester.getRect(item);
    expect(itemRect.top, greaterThanOrEqualTo(viewport.top));
    expect(itemRect.bottom, lessThanOrEqualTo(viewport.bottom));
  });

  testWidgets('a complete rule is stored with a generated id', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.pumpAndSettle();

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

  testWidgets('the additional parameter switches toggle and are stored', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);
    await harness.selectType(tester, RuleAction.IP_CIDR);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.additionalParameters), findsOne);
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    expect(tester.widgetList<Switch>(switches).map((s) => s.value), [
      false,
      false,
    ]);

    await tester.tap(switches.at(0));
    await tester.pumpAndSettle();
    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();

    expect(tester.widgetList<Switch>(switches).map((s) => s.value), [
      true,
      true,
    ]);

    await tester.enterText(find.byType(TextFormField), '1.1.1.1/32');
    await tester.pumpAndSettle();
    await harness.save(tester);

    final stored = harness.rules.puts.single;
    expect(stored.noResolve, isTrue);
    expect(stored.src, isTrue);
    expect(stored.rawValue, 'IP-CIDR,1.1.1.1/32,DIRECT,src,no-resolve');
  });

  testWidgets('deleting from the edit sheet removes the rule', (tester) async {
    final harness = _Harness();
    final rule = Rule.parse('DOMAIN-SUFFIX,example.com,DIRECT');
    await harness.pump(tester, initialRules: [rule]);

    await tester.tap(find.text('example.com'));
    await tester.pumpAndSettle();
    final l10n = currentAppLocalizations;
    expect(find.text(l10n.editRule), findsOne);

    await tester.tap(find.text(l10n.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();

    expect(harness.rules.deletes, [rule.id]);
    expect(find.text(l10n.editRule), findsNothing);
  });

  testWidgets('long targets and contents stay inside the rows', (tester) async {
    final harness = _Harness();
    final rules = [
      Rule.parse(
        'SUB-RULE,(DOMAIN,example.com),a-very-long-sub-rule-name-that-goes-on',
      ),
      Rule.parse(
        r'PROCESS-NAME-REGEX,^very-long-process-name-[0-9]{1,3}\.exe$,DIRECT',
      ),
    ];
    await harness.pump(tester, initialRules: rules, size: const Size(360, 800));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(RuleAction.PROCESS_NAME_REGEX.name));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField), 'x' * 400);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final sheet = tester.getRect(find.byType(OverwriteFormRow).first);
    final field = tester.getRect(find.byType(EditableText));
    expect(field.right, lessThanOrEqualTo(sheet.right));
  });
}
