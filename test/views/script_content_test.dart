import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/script.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/material.dart';
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
    await AppLocalizations.load(const Locale('en'));
  });

  ProviderContainer buildContainer({
    required List<Script> scripts,
    int? selectedScriptId,
  }) {
    final profile = Profile.normal(label: 'p').copyWith(
      id: _profileId,
      overwriteType: OverwriteType.script,
      scriptId: selectedScriptId,
    );
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

  testWidgets('lists every script with the configure entry', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
    );

    await pumpScriptContent(tester);

    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.goToConfigureScript),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders only the header when no script exists', (tester) async {
    container = buildContainer(scripts: const []);

    await pumpScriptContent(tester);

    expect(find.text(currentAppLocalizations.overrideScript), findsOneWidget);
    expect(find.byType(Radio<int>), findsNothing);
  });

  testWidgets('marks the profile script as the selected radio', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
      selectedScriptId: 11,
    );

    await pumpScriptContent(tester);

    final groups = tester
        .widgetList<RadioGroup<int>>(find.byType(RadioGroup<int>))
        .toList();
    expect(groups, hasLength(2));
    expect(groups.every((group) => group.groupValue == 11), isTrue);
  });

  testWidgets('tapping an unselected script selects it', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha'), _script(11, 'beta')],
    );

    await pumpScriptContent(tester);
    await tester.tap(find.text('beta'));
    await tester.pump();

    expect(selectedScriptId(), 11);
  });

  testWidgets('tapping the selected script clears it', (tester) async {
    container = buildContainer(
      scripts: [_script(10, 'alpha')],
      selectedScriptId: 10,
    );

    await pumpScriptContent(tester);
    await tester.tap(find.text('alpha'));
    await tester.pump();

    expect(selectedScriptId(), isNull);
  });

  testWidgets('tapping the radio selects the same script as the tile', (
    tester,
  ) async {
    container = buildContainer(scripts: [_script(10, 'alpha')]);

    await pumpScriptContent(tester);
    await tester.tap(find.byType(Radio<int>));
    await tester.pump();

    expect(selectedScriptId(), 10);
  });
}
