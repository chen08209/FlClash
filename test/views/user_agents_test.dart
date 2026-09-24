import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/user_agents.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  String? selected() => container.read(patchClashConfigProvider).globalUa;

  List<String> saved() => container.read(appSettingProvider).userAgents;

  Finder menuOf(String userAgent) => find.descendant(
    of: find.ancestor(
      of: find.text(userAgent),
      matching: find.byType(ListTile),
    ),
    matching: find.byTooltip(currentAppLocalizations.more),
  );

  Future<void> pumpView(WidgetTester tester, {String? globalUa}) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 1600));
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(globalUa: globalUa));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: UserAgentsView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submitInput(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the default and the presets, default without a menu', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text(currentAppLocalizations.defaultText), findsOneWidget);
    for (final userAgent in defaultUserAgents) {
      expect(find.text(userAgent), findsOneWidget);
    }
    expect(
      find.byTooltip(currentAppLocalizations.more),
      findsNWidgets(defaultUserAgents.length),
    );
  });

  testWidgets('tapping a row selects it and the default clears it', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text(defaultUserAgents.last));
    await tester.pumpAndSettle();
    expect(selected(), defaultUserAgents.last);

    await tester.tap(find.text(currentAppLocalizations.defaultText));
    await tester.pumpAndSettle();
    expect(selected(), isNull);
  });

  testWidgets('adding appends without changing the selection', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submitInput(tester, '  CustomUA/1.0  ');

    expect(saved(), [...defaultUserAgents, 'CustomUA/1.0']);
    expect(selected(), isNull);
    expect(find.text('CustomUA/1.0'), findsOneWidget);
  });

  testWidgets('adding rejects an empty or duplicate value', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submitInput(tester, '   ');
    expect(
      find.text(
        currentAppLocalizations.emptyTip(currentAppLocalizations.userAgent),
      ),
      findsOneWidget,
    );

    await submitInput(tester, defaultUserAgents.first);
    expect(
      find.text(
        currentAppLocalizations.existsTip(currentAppLocalizations.userAgent),
      ),
      findsOneWidget,
    );
    expect(saved(), defaultUserAgents);
  });

  testWidgets('editing the selected value keeps it selected', (tester) async {
    await pumpView(tester, globalUa: defaultUserAgents.first);

    await tester.tap(menuOf(defaultUserAgents.first));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.edit));
    await tester.pumpAndSettle();
    await submitInput(tester, 'clash-verge/v3.0.0');

    expect(saved(), ['clash-verge/v3.0.0', defaultUserAgents.last]);
    expect(selected(), 'clash-verge/v3.0.0');
  });

  testWidgets('deleting the selected value falls back to the default', (
    tester,
  ) async {
    await pumpView(tester, globalUa: defaultUserAgents.last);

    await tester.tap(menuOf(defaultUserAgents.last));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved(), [defaultUserAgents.first]);
    expect(selected(), isNull);
    expect(find.text(defaultUserAgents.last), findsNothing);
  });

  testWidgets('shows a selected value that is missing from the list', (
    tester,
  ) async {
    await pumpView(tester, globalUa: 'Legacy/1.0');

    expect(find.text('Legacy/1.0'), findsOneWidget);
    expect(saved(), defaultUserAgents);

    await tester.tap(menuOf(defaultUserAgents.first));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved(), [defaultUserAgents.last, 'Legacy/1.0']);
    expect(selected(), 'Legacy/1.0');
  });
}
