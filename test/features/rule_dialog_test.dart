import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Finder _banner(String text) =>
    find.descendant(of: find.byType(ErrorBanner), matching: find.text(text));

void main() {
  testWidgets('add rule validates content and returns the entered rule', (
    tester,
  ) async {
    Rule? result;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showFormSheet<Rule>(
                  context: context,
                  builder: (_) => const RuleForm(),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.current;

    await tester.tap(find.widgetWithText(TextButton, l10n.save));
    await tester.pumpAndSettle();
    expect(_banner(l10n.emptyTip(l10n.content)), findsOneWidget);
    expect(result, isNull);

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.pumpAndSettle();
    expect(find.byType(ErrorBanner), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, l10n.save));
    await tester.pumpAndSettle();

    expect(find.byType(RuleForm), findsNothing);
    expect(result, isNotNull);
    expect(result!.ruleAction, RuleAction.DOMAIN);
    expect(result!.content, 'example.com');
    expect(result!.ruleTarget, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('every built-in target is a valid rule target', (tester) async {
    for (final target in RuleTarget.baseTargetNames) {
      await tester.pumpWidget(
        TestApp(
          child: Material(
            child: RuleItem(
              isSelected: false,
              rule: Rule(content: 'example.com', ruleTarget: target),
              onSelected: () {},
              onEdit: (_) {},
            ),
          ),
        ),
      );

      expect(find.text(target), findsOneWidget);
      expect(find.byType(IconButton), findsNothing, reason: target);
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a rule without content centers its action', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Material(
          child: Center(
            child: SizedBox(
              width: 600,
              height: 64,
              child: RuleItem(
                isSelected: false,
                rule: const Rule(
                  ruleAction: RuleAction.MATCH,
                  ruleTarget: 'DIRECT',
                ),
                onSelected: () {},
                onEdit: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.text(RuleAction.MATCH.name)).dy,
      moreOrLessEquals(tester.getCenter(find.byType(RuleItem)).dy, epsilon: 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a long target yields width to the action on one line', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Material(
          child: Center(
            child: SizedBox(
              width: 480,
              height: 64,
              child: RuleItem(
                isSelected: false,
                rule: const Rule(
                  ruleAction: RuleAction.DOMAIN_KEYWORD,
                  content: 'example',
                  ruleTarget: 'Singapore-Auto-Select',
                ),
                onSelected: () {},
                onEdit: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final action = tester.renderObject<RenderParagraph>(
      find.text(RuleAction.DOMAIN_KEYWORD.name),
    );
    expect(action.didExceedMaxLines, isFalse);
    expect(action.size.height, action.getMinIntrinsicHeight(double.infinity));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('selecting MATCH target shows the label but stores MATCH', (
    tester,
  ) async {
    Rule? result;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showFormSheet<Rule>(
                  context: context,
                  builder: (_) => const RuleForm(),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.current;

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.tap(find.text(l10n.splitStrategy));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.matchTarget).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.matchTarget).last);
    await tester.pumpAndSettle();
    expect(find.text(l10n.matchTarget), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, l10n.save));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.ruleTarget, 'MATCH');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('edit rule keeps the id and order and prefills the fields', (
    tester,
  ) async {
    Rule? result;
    const rule = Rule(
      id: 42,
      ruleAction: RuleAction.GEOIP,
      content: 'CN',
      ruleTarget: 'GEOIP',
      noResolve: true,
      order: 'a5',
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showFormSheet<Rule>(
                  context: context,
                  builder: (_) => const RuleForm(rule: rule),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('CN'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'US');
    await tester.tap(
      find.widgetWithText(TextButton, AppLocalizations.current.save),
    );
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 42);
    expect(result!.order, 'a5');
    expect(result!.content, 'US');
    expect(result!.ruleAction, RuleAction.GEOIP);
    expect(result!.noResolve, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a payload the core would refuse is held at the field', (
    tester,
  ) async {
    Rule? result;
    const rule = Rule(
      id: 7,
      ruleAction: RuleAction.DST_PORT,
      content: '443',
      ruleTarget: 'DIRECT',
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showFormSheet<Rule>(
                  context: context,
                  builder: (_) => const RuleForm(rule: rule),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.current;

    await tester.enterText(find.byType(TextFormField), 'https');
    await tester.tap(find.widgetWithText(TextButton, l10n.save));
    await tester.pumpAndSettle();
    expect(_banner(l10n.invalidRangeContent), findsOneWidget);
    expect(result, isNull);

    await tester.enterText(find.byType(TextFormField), '80/443');
    await tester.tap(find.widgetWithText(TextButton, l10n.save));
    await tester.pumpAndSettle();
    expect(result?.content, '80/443');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
