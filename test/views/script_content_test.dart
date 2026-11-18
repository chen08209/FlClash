import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/profiles/extend/script.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

Script _script(int id, String label) {
  return Script(id: id, label: label, lastUpdateTime: DateTime(2026));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    loadAppLocalizations(const Locale('en'));
  });

  ProviderContainer buildContainer({
    required List<Script> scripts,
    int? selectedScriptId,
  }) {
    final profile = Profile.normal(
      label: 'p',
    ).copyWith(id: _profileId, scriptId: selectedScriptId);
    final built = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
        scriptsProvider.overrideWith(() => TestScripts(scripts)),
      ],
    );
    addTearDown(built.dispose);
    globalState.container = built;
    return built;
  }

  Future<void> pumpScriptContent(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ProfileIdProvider(
            profileId: _profileId,
            child: CustomScrollView(slivers: [ScriptContent()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  int? selectedScriptId() {
    return container.read(profilesProvider).getProfile(_profileId)?.scriptId;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.text(currentAppLocalizations.extendScript));
    await tester.pumpAndSettle();
  }

  testWidgets('shows no script and the configure entry', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
    );

    await pumpScriptContent(tester);

    expect(find.text(currentAppLocalizations.none), findsOneWidget);
    expect(find.text('alpha'), findsNothing);
    expect(
      find.text(currentAppLocalizations.goToConfigureScript),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the configure row opens the scripts', (tester) async {
    container = buildContainer(scripts: [_script(10, 'alpha')]);

    await pumpScriptContent(tester);
    await tester.tap(find.text(currentAppLocalizations.goToConfigureScript));
    await tester.pumpAndSettle();

    expect(find.byType(ScriptsView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers only no script when none exists', (tester) async {
    container = buildContainer(scripts: const []);

    await pumpScriptContent(tester);
    await openMenu(tester);

    expect(find.text(currentAppLocalizations.none), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the profile script on its row', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
      selectedScriptId: 11,
    );

    await pumpScriptContent(tester);

    expect(find.text('beta'), findsOneWidget);
    expect(find.text(currentAppLocalizations.none), findsNothing);
  });

  testWidgets('shows a deleted script as no script', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha')],
      selectedScriptId: 99,
    );

    await pumpScriptContent(tester);

    expect(find.text(currentAppLocalizations.none), findsOneWidget);
  });

  testWidgets('choosing a script from the menu selects it', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
    );

    await pumpScriptContent(tester);
    await openMenu(tester);
    await tester.tap(find.text('beta'));
    await tester.pumpAndSettle();

    expect(selectedScriptId(), 11);
  });

  testWidgets('choosing no script clears it', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha')],
      selectedScriptId: 10,
    );

    await pumpScriptContent(tester);
    await openMenu(tester);
    await tester.tap(find.text(currentAppLocalizations.none));
    await tester.pumpAndSettle();

    expect(selectedScriptId(), isNull);
  });
}
