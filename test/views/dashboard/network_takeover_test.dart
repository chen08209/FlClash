import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/network_takeover.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _RowCase {
  const _RowCase(
    this.name,
    this.card,
    this.title,
    this.read, {
    this.initial = false,
  });

  final String name;
  final Widget card;
  final String title;
  final bool Function(ProviderContainer container) read;
  final bool initial;
}

final _rowCases = <_RowCase>[
  _RowCase(
    'system proxy',
    const NetworkTakeoverCard(),
    'System proxy',
    (container) => container.read(networkSettingProvider).systemProxy,
    initial: true,
  ),
  _RowCase(
    'TUN',
    const NetworkTakeoverCard(),
    'TUN',
    (container) => container.read(patchClashConfigProvider).tun.enable,
  ),
  _RowCase(
    'VPN',
    const VpnCard(),
    'VPN',
    (container) => container.read(vpnSettingProvider).enable,
    initial: true,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester, Widget card) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: ListView(children: [card])),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder switchOf(_RowCase testCase) =>
      find.byType(DashboardSwitch).at(testCase.name == 'TUN' ? 1 : 0);

  for (final testCase in _rowCases) {
    testWidgets('the ${testCase.name} switch flips its setting both ways', (
      tester,
    ) async {
      await pumpCard(tester, testCase.card);

      expect(testCase.read(container), testCase.initial);
      expect(
        tester.widget<DashboardSwitch>(switchOf(testCase)).value,
        testCase.initial,
      );

      await tester.tap(switchOf(testCase));
      await tester.pumpAndSettle();
      expect(testCase.read(container), !testCase.initial);
      expect(
        tester.widget<DashboardSwitch>(switchOf(testCase)).value,
        !testCase.initial,
      );

      await tester.tap(switchOf(testCase));
      await tester.pumpAndSettle();
      expect(testCase.read(container), testCase.initial);
    });

    testWidgets('tapping the ${testCase.name} row flips it in place', (
      tester,
    ) async {
      await pumpCard(tester, testCase.card);

      await tester.tap(find.text(testCase.title).last);
      await tester.pumpAndSettle();

      expect(find.byType(CommonScaffold), findsNothing);
      expect(testCase.read(container), !testCase.initial);
    });
  }

  testWidgets('on glass a held switch turns its thumb into a lens', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const LiquidGlassScope(enabled: true, child: NetworkTakeoverCard()),
    );
    final tun = switchOf(_rowCases[1]);
    Finder lensOf(Finder toggle) =>
        find.descendant(of: toggle, matching: find.byType(LiquidGlass));

    expect(find.byType(LiquidGlass), findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(tun));
    await tester.pump(kPressTimeout);
    await tester.pump(const Duration(milliseconds: 100));
    expect(lensOf(tun), findsOneWidget);
    expect(lensOf(switchOf(_rowCases[0])), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).tun.enable, isTrue);
    expect(find.byType(LiquidGlass), findsNothing);
  });

  testWidgets('a row says what it is set to', (tester) async {
    await pumpCard(tester, const NetworkTakeoverCard());

    expect(find.text('Port 7890'), findsOneWidget);
    expect(find.text(currentAppLocalizations.disabled), findsOneWidget);

    await tester.tap(switchOf(_rowCases[1]));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.enabled), findsOneWidget);
  });

  testWidgets('narrow tiles drop their icons together before a title is cut '
      'short', (tester) async {
    Future<void> pumpTile(
      double width, [
      TakeoverSwitch kind = TakeoverSwitch.systemProxy,
    ]) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: 56,
                  child: DashboardDensityScope(
                    density: DashboardDensity.compact,
                    scale: 1,
                    child: NetworkTakeoverTile(kind),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpTile(400);
    expect(find.byType(ShapeBadge), findsOneWidget);

    await pumpTile(160);
    expect(find.byType(ShapeBadge), findsNothing);
    expect(find.byType(DashboardSwitch), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('System proxy')).dx,
      dashboardCardPadding(DashboardDensity.compact).left,
    );
    expect(tester.takeException(), isNull);

    await pumpTile(200, TakeoverSwitch.tun);
    expect(find.byType(ShapeBadge), findsNothing);
  });
}
