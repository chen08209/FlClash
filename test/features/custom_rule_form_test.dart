import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProfileRules extends ProfileRules {
  _RecordingProfileRules(this.initial);

  final List<Rule> initial;
  final List<Rule> puts = [];
  final List<int> deletes = [];

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void put(Rule rule) => puts.add(rule);

  @override
  void putAll(List<Rule> rules) => puts.addAll(rules);

  @override
  void delAll(Iterable<int> ruleIds) => deletes.addAll(ruleIds);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestCustomData extends Notifier<CustomProfileData> {
  @override
  CustomProfileData build() {
    return const CustomProfileData(ruleTargets: {'DIRECT'});
  }
}

final _testCustomDataProvider =
    NotifierProvider<_TestCustomData, CustomProfileData>(_TestCustomData.new);

class _TestClashProviders extends ClashProviders {
  _TestClashProviders(this.ruleLabels);

  final List<String> ruleLabels;

  @override
  Stream<List<ClashProvider>> build() => Stream.value([
    for (final (index, label) in ruleLabels.indexed)
      ClashProvider(
        id: index,
        label: label,
        url: 'https://example.com/$label.yaml',
      ),
  ]);
}

class _Harness {
  late final ProviderContainer container;
  late final _RecordingProfileRules rules;
  late final Profile profile;

  Future<void> pump(
    WidgetTester tester, {
    List<Rule> initialRules = const [],
    Size size = const Size(1400, 1000),
    List<String> appRuleProviders = const [],
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    profile = Profile.custom(label: 'profile');
    rules = _RecordingProfileRules(initialRules);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profileRulesProvider.overrideWith2((_) => rules),
        customProfileDataProvider(
          profile.id,
        ).overrideWith((ref) => ref.watch(_testCustomDataProvider)),
        clashProvidersProvider.overrideWith(
          () => _TestClashProviders(appRuleProviders),
        ),
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

  Future<void> openAddSheet(WidgetTester tester) =>
      openAddMenuItem(tester, currentAppLocalizations.add);

  Future<void> openAddMenuItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(CommonPopupMenu),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byGlyph(AppGlyphs.check));
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
    // That leaves the row at the viewport's top, under the floating bar.
    await Scrollable.ensureVisible(
      tester.element(find.text(action.name).last),
      alignment: 0.5,
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

  testWidgets('the type sheet leaves out SUB_RULE', (tester) async {
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

    expect(find.text(RuleAction.NOT.name), findsOne);
    expect(find.text(RuleAction.SUB_RULE.name), findsNothing);
  });

  testWidgets('the rule set sheet lists the app rule sets in one list', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester, appRuleProviders: const ['shared', 'app-only']);
    await harness.openAddSheet(tester);
    await harness.selectType(tester, RuleAction.RULE_SET);
    await tester.tap(find.text(currentAppLocalizations.ruleSet));
    await tester.pumpAndSettle();

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(find.text('shared'), findsOne);
    expect(top('shared'), lessThan(top('app-only')));
    expect(
      find.descendant(
        of: find.byType(SelectionSheet<String>),
        matching: find.byType(ListHeader),
      ),
      findsNothing,
    );
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
      find.text(RuleAction.NOT.name),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(RuleAction.NOT.name).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(currentAppLocalizations.proxyType));
    await tester.pumpAndSettle();

    final sheet = find.byType(SelectionSheet<RuleAction>);
    final item = find.descendant(
      of: sheet,
      matching: find.text(RuleAction.NOT.name),
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

  testWidgets('quick actions store the confirmed presets', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    await harness.openAddMenuItem(tester, currentAppLocalizations.quickActions);
    await tester.tap(find.text(currentAppLocalizations.rulePresetLanDirect));
    await tester.pump();
    await tester.tap(find.byTooltip(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(
      harness.rules.puts.map((rule) => rule.rawValue),
      RulePreset.lanDirect.rawRules,
    );
  });

  testWidgets('the bar groups search with sort and adds from one menu', (
    tester,
  ) async {
    final l10n = currentAppLocalizations;
    final harness = _Harness();
    await harness.pump(
      tester,
      initialRules: [
        Rule.parse('DOMAIN-SUFFIX,a.com,DIRECT'),
        Rule.parse('DOMAIN-SUFFIX,b.com,DIRECT'),
      ],
    );

    Finder inBar(Finder finder) =>
        find.descendant(of: find.byType(AppBar), matching: finder);
    final group = find.byType(TonalButtonGroup);
    expect(inBar(group), findsOne);
    for (final tooltip in [l10n.search, l10n.sort]) {
      expect(
        find.descendant(of: group, matching: find.byTooltip(tooltip)),
        findsOne,
      );
    }
    expect(inBar(find.byTooltip(l10n.quickActions)), findsNothing);
    expect(inBar(find.byTooltip(l10n.more)), findsNothing);

    await tester.tap(find.byTooltip(l10n.add));
    await tester.pumpAndSettle();
    final menu = find.byType(CommonPopupMenu);
    for (final label in [l10n.add, l10n.quickActions, l10n.quickEdit]) {
      expect(find.descendant(of: menu, matching: find.text(label)), findsOne);
    }
  });

  testWidgets('the content field keeps focus while its payload turns invalid', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.openAddSheet(tester);
    await harness.selectType(tester, RuleAction.DST_PORT);

    await tester.enterText(find.byType(TextFormField), '80');
    await tester.pump();
    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    expect(editable.widget.focusNode.hasFocus, isTrue);

    await tester.enterText(find.byType(TextFormField), '80x');
    await tester.pump();

    expect(find.byType(InfoMessageButton), findsOne);
    expect(
      tester.state<EditableTextState>(find.byType(EditableText)),
      same(editable),
    );
    expect(editable.widget.focusNode.hasFocus, isTrue);
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
    final sheet = tester.getRect(find.byType(FormRow).first);
    final field = tester.getRect(find.byType(EditableText));
    expect(field.right, lessThanOrEqualTo(sheet.right));
  });
}
