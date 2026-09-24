import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';

class _RecordingGlobalRules extends TestGlobalRules {
  _RecordingGlobalRules(super.initial);

  final deleted = <List<int>>[];

  @override
  void delAll(Iterable<int> ruleIds) {
    deleted.add(List<int>.from(ruleIds));
  }
}

Rule _rule(int id, String content) {
  return Rule(
    id: id,
    content: content,
    ruleTarget: 'DIRECT',
    order: id.toString(),
  );
}

Finder _barAction(String tooltip) =>
    find.descendant(of: find.byType(AppBar), matching: find.byTooltip(tooltip));

Future<void> _tapBarAction(WidgetTester tester, String tooltip) async {
  await tester.tap(_barAction(tooltip));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _RecordingGlobalRules rules;

  Future<void> pumpRules(WidgetTester tester, List<Rule> initial) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    rules = _RecordingGlobalRules(initial);
    container = ProviderContainer(
      overrides: [globalRulesProvider.overrideWith(() => rules)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 2400));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AddedRulesView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state without any rule', (tester) async {
    await pumpRules(tester, const []);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(find.text(currentAppLocalizations.add), findsOneWidget);
  });

  testWidgets('lists every rule when the store is populated', (tester) async {
    await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.com')]);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.text('a.com'), findsOneWidget);
    expect(find.text('b.com'), findsOneWidget);
  });

  testWidgets('checking a rule enters selection mode', (tester) async {
    await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.com')]);

    expect(_barAction(currentAppLocalizations.delete), findsNothing);

    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    expect(_barAction(currentAppLocalizations.selectAll), findsOneWidget);
    expect(_barAction(currentAppLocalizations.delete), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
      findsNothing,
    );
  });

  testWidgets('select all covers every rule and toggles back off', (
    tester,
  ) async {
    await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.com')]);

    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();
    await _tapBarAction(tester, currentAppLocalizations.selectAll);
    await _tapBarAction(tester, currentAppLocalizations.delete);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(rules.deleted, [
      unorderedEquals(<int>[1, 2]),
    ]);
  });

  testWidgets('declining the delete dialog keeps every rule', (tester) async {
    await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.com')]);

    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();
    await _tapBarAction(tester, currentAppLocalizations.delete);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();

    expect(rules.deleted, isEmpty);
    expect(_barAction(currentAppLocalizations.delete), findsOneWidget);
  });

  testWidgets('deleting only removes the selected rule', (tester) async {
    await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.com')]);

    await tester.tap(find.byType(CommonCheckBox).last);
    await tester.pumpAndSettle();
    await _tapBarAction(tester, currentAppLocalizations.delete);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(rules.deleted, [
      [2],
    ]);
  });

  group('search', () {
    Future<void> search(WidgetTester tester, String query) async {
      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
    }

    testWidgets('lists only the matching rules and stops reordering', (
      tester,
    ) async {
      await pumpRules(tester, [_rule(1, 'a.com'), _rule(2, 'b.net')]);
      expect(find.byType(ReorderableList), findsOneWidget);

      await search(tester, 'NET');

      expect(find.text('b.net'), findsOneWidget);
      expect(find.text('a.com'), findsNothing);
      expect(find.byType(ReorderableList), findsNothing);
    });

    testWidgets('matches the rule type and the target', (tester) async {
      await pumpRules(tester, [
        _rule(1, 'a.com'),
        const Rule(
          id: 2,
          ruleAction: RuleAction.GEOIP,
          content: 'CN',
          order: '2',
        ),
      ]);

      await search(tester, 'geoip');
      expect(find.text('CN'), findsOneWidget);
      expect(find.text('a.com'), findsNothing);

      await tester.enterText(find.byType(TextField), 'direct');
      await tester.pumpAndSettle();
      expect(find.text('a.com'), findsOneWidget);
      expect(find.text('CN'), findsNothing);
    });

    testWidgets('select all and delete reach only the matches', (tester) async {
      await pumpRules(tester, [
        _rule(1, 'a.com'),
        _rule(2, 'b.com'),
        _rule(3, 'c.net'),
      ]);

      await search(tester, 'com');
      await tester.tap(find.byType(CommonCheckBox).first);
      await tester.pumpAndSettle();
      await _tapBarAction(tester, currentAppLocalizations.selectAll);
      await _tapBarAction(tester, currentAppLocalizations.delete);
      await tester.tap(find.text(currentAppLocalizations.confirm));
      await tester.pumpAndSettle();

      expect(rules.deleted, [
        unorderedEquals(<int>[1, 2]),
      ]);
    });
  });
}
