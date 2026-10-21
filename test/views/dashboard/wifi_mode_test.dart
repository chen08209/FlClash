import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/wifi_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [safeModeProvider.overrideWithValue(true)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = const Size(412, 915);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: Scaffold(body: SingleChildScrollView(child: WifiModeCard())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard adds, edits and deletes a rule in place', (
    tester,
  ) async {
    await pumpCard(tester);
    await tester.tap(find.byTooltip('Add SSID'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Home Wi-Fi');
    await tester.tap(find.byTooltip('Save').last);
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).rules, {
      'Home Wi-Fi': Mode.direct,
    });
    expect(find.text('Home Wi-Fi'), findsOneWidget);

    await tester.tap(find.text('Home Wi-Fi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Office');
    await tester.tap(find.text('Outbound mode').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Global').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save').last);
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).rules, {
      'Office': Mode.global,
    });

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).rules, isEmpty);
    expect(find.text('Office'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard toggles automation and sets the fallback', (
    tester,
  ) async {
    await pumpCard(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).enabled, isTrue);

    await tester.tap(find.text('Default outbound mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Global').last);
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).fallback, Mode.global);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(container.read(wifiModeSettingProvider).enabled, isFalse);
  });

  testWidgets('all rules remain visible without a nested list', (tester) async {
    await pumpCard(tester);
    container.read(wifiModeSettingProvider.notifier).value = WifiModeSettings(
      rules: {for (var i = 0; i < 12; i++) 'Network $i': Mode.rule},
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scrollable), findsOneWidget);
    await tester.ensureVisible(find.text('Network 11'));
    expect(find.text('Network 11').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
