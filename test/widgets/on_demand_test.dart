import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import '../helpers/test_app.dart';

class _TestExcludeSSIDs extends ExcludeSSIDs {
  _TestExcludeSSIDs(this._initial);

  final List<String> _initial;

  @override
  List<String> build() => _initial;
}

class _TestLocationPermissions extends LocationPermissions {
  _TestLocationPermissions(this._initial);

  final WifiSsidPermission _initial;

  @override
  WifiSsidPermission build() => _initial;
}

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    List<String> ssids = const [],
    WifiSsidPermission permission = WifiSsidPermission.denied,
    bool isAndroid = false,
    bool isMacOS = false,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        excludeSSIDsProvider.overrideWith(() => _TestExcludeSSIDs(ssids)),
        locationPermissionsProvider.overrideWith(
          () => _TestLocationPermissions(permission),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: OnDemandView(isAndroid: isAndroid, isMacOS: isMacOS),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty list shows the placeholder and only the add action', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('SSIDs is empty'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('every excluded SSID is rendered', (tester) async {
    await pumpView(tester, ssids: ['Home', 'Office']);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text('SSIDs is empty'), findsNothing);
  });

  testWidgets('selecting an item swaps the header into selection mode', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('select all takes every SSID, and pressing it again clears', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(container.read(itemsProvider(_viewKey(tester))), {'Home', 'Office'});

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('deleting removes the selected SSIDs and clears the selection', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(container.read(excludeSSIDsProvider), ['Office']);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('the location prerequisite reflects a denied permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.denied,
      isMacOS: true,
    );

    expect(find.bySemanticsLabel('Tap to authorize'), findsOneWidget);
    expect(find.bySemanticsLabel('Authorized'), findsNothing);
  });

  testWidgets('the location prerequisite reflects a granted permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.granted,
      isMacOS: true,
    );

    expect(find.bySemanticsLabel('Authorized'), findsOneWidget);
    expect(find.bySemanticsLabel('Tap to authorize'), findsNothing);
  });

  testWidgets('Android also asks to be left out of battery optimization', (
    tester,
  ) async {
    await pumpView(tester, isAndroid: true);

    expect(find.text('Ignore Battery Optimization'), findsOneWidget);
    expect(find.text('Location Permission'), findsOneWidget);
  });

  testWidgets('a desktop that is not macOS asks for no prerequisite', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('Ignore Battery Optimization'), findsNothing);
    expect(find.text('Location Permission'), findsNothing);
    expect(find.bySemanticsLabel('Tap to authorize'), findsNothing);
  });
}

/// The view keys its shared selection notifier by [UniqueKeyStateMixin.key], so
/// a test has to read the same id off the mounted state.
String _viewKey(WidgetTester tester) {
  final state = tester.state(find.byType(OnDemandView)) as dynamic;
  return state.key as String;
}
