import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _StubSetupAction extends SetupAction {
  static String yaml = '';
  static final requested = <int>[];

  @override
  Future<String> getProfileWithId(int profileId) async {
    requested.add(profileId);
    return yaml;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    _StubSetupAction.yaml = 'mixed-port: 7890';
    _StubSetupAction.requested.clear();
    container = ProviderContainer(
      overrides: [setupActionProvider.overrideWith(_StubSetupAction.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
  });

  // The editor blinks its caret forever, so `pumpAndSettle` never returns; and
  // `encodeYamlTask` hands the encode to a real isolate, which only runs
  // outside the fake-async zone.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  Future<void> pumpPreview(WidgetTester tester, Profile profile) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          child: PreviewProfileView(profile: profile),
        ),
      ),
    );
    await settle(tester);
  }

  EditorPage editor(WidgetTester tester) {
    return tester.widget<EditorPage>(find.byType(EditorPage));
  }

  testWidgets('asks for the profile it was given and shows its yaml', (
    tester,
  ) async {
    await pumpPreview(
      tester,
      const Profile(id: 7, label: 'home', autoUpdateDuration: Duration.zero),
    );

    expect(_StubSetupAction.requested, [7]);
    expect(editor(tester).title, 'home');
    expect(editor(tester).content, contains('mixed-port'));
  });

  testWidgets('renders the editor before the content arrives', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: PreviewProfileView(
            profile: Profile(
              id: 7,
              label: 'home',
              autoUpdateDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );

    expect(editor(tester).content, isNull);

    await settle(tester);

    expect(editor(tester).content, isNotNull);
  });

  testWidgets('an unlabelled profile falls back to its id', (tester) async {
    await pumpPreview(
      tester,
      const Profile(id: 42, autoUpdateDuration: Duration.zero),
    );

    expect(editor(tester).title, '42');
  });

  testWidgets('a profile that resolves after disposal is dropped', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: PreviewProfileView(
            profile: Profile(
              id: 7,
              label: 'home',
              autoUpdateDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: SizedBox.shrink(),
        ),
      ),
    );
    await settle(tester);

    expect(tester.takeException(), isNull);
  });
}
