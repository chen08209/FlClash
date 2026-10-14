import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _secretLabel = 'External controller secret';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  Future<void> pumpGeneralView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
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
        .update((_) => const Size(1000, 3000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: GeneralView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapControllerSwitch(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'External controller'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opening the controller shows the secret it was given', (
    tester,
  ) async {
    await pumpGeneralView(tester);
    expect(find.text(_secretLabel), findsNothing);

    await tapControllerSwitch(tester);

    final config = container.read(patchClashConfigProvider);
    expect(config.externalController, ExternalControllerStatus.open);
    expect(config.secret, hasLength(32));
    expect(find.text(_secretLabel), findsOneWidget);
    expect(find.text(config.secret), findsOneWidget);
  });

  testWidgets('a secret typed into the row replaces the generated one', (
    tester,
  ) async {
    await pumpGeneralView(tester);
    await tapControllerSwitch(tester);

    await tester.tap(find.text(_secretLabel));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  my-own-secret ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).secret, 'my-own-secret');
  });

  testWidgets('the row refuses an empty secret', (tester) async {
    await pumpGeneralView(tester);
    await tapControllerSwitch(tester);
    final generated = container.read(patchClashConfigProvider).secret;

    await tester.tap(find.text(_secretLabel));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).secret, generated);
  });

  testWidgets('closing the controller drops the secret and its row', (
    tester,
  ) async {
    await pumpGeneralView(tester);
    await tapControllerSwitch(tester);

    await tapControllerSwitch(tester);

    expect(
      container.read(patchClashConfigProvider).externalController,
      ExternalControllerStatus.close,
    );
    expect(container.read(patchClashConfigProvider).secret, isEmpty);
    expect(find.text(_secretLabel), findsNothing);
  });
}
