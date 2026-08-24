import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/rule.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

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
                result = await showDialog<Rule>(
                  context: context,
                  builder: (_) => const AddOrEditRuleDialog(),
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

    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();
    expect(find.text(l10n.emptyTip(l10n.content)), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'example.com');
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();

    expect(find.byType(AddOrEditRuleDialog), findsNothing);
    expect(result, isNotNull);
    expect(result!.ruleAction, RuleAction.DOMAIN);
    expect(result!.content, 'example.com');
    expect(result!.ruleTarget, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('edit rule keeps the id and prefills the fields', (tester) async {
    Rule? result;
    const rule = Rule(
      id: 42,
      ruleAction: RuleAction.GEOIP,
      content: 'CN',
      ruleTarget: 'GEOIP',
      noResolve: true,
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
                result = await showDialog<Rule>(
                  context: context,
                  builder: (_) => const AddOrEditRuleDialog(rule: rule),
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
    await tester.tap(find.text(AppLocalizations.current.confirm));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 42);
    expect(result!.content, 'US');
    expect(result!.ruleAction, RuleAction.GEOIP);
    expect(result!.noResolve, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
