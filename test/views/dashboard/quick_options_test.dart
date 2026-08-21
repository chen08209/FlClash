import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/quick_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _CardCase {
  const _CardCase(this.name, this.widget, this.read, {this.initial = false});

  final String name;
  final Widget widget;
  final bool Function(ProviderContainer container) read;
  final bool initial;
}

final _cardCases = <_CardCase>[
  _CardCase(
    'TUN',
    const TUNButton(),
    (container) => container.read(patchClashConfigProvider).tun.enable,
  ),
  _CardCase(
    'system proxy',
    const SystemProxyButton(),
    (container) => container.read(networkSettingProvider).systemProxy,
    initial: true,
  ),
  _CardCase(
    'VPN',
    const VpnButton(),
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
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester, Widget card) async {
    tester.view.physicalSize = const Size(1200, 1000);
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

  group('each card drives its own setting', () {
    for (final testCase in _cardCases) {
      testWidgets('${testCase.name} flips both ways', (tester) async {
        await pumpCard(tester, testCase.widget);

        expect(testCase.read(container), testCase.initial);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(testCase.read(container), !testCase.initial);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(testCase.read(container), testCase.initial);
      });

      testWidgets('${testCase.name} shows the state it reads', (tester) async {
        await pumpCard(tester, testCase.widget);

        expect(
          tester.widget<Switch>(find.byType(Switch)).value,
          testCase.initial,
        );

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Switch>(find.byType(Switch)).value,
          !testCase.initial,
        );
      });
    }
  });

  testWidgets('the three cards stay visually interchangeable', (tester) async {
    final switches = <Switch>[];
    for (final testCase in _cardCases) {
      await pumpCard(tester, testCase.widget);
      switches.add(tester.widget<Switch>(find.byType(Switch)));
    }

    expect(
      switches.map((item) => item.materialTapTargetSize).toSet(),
      hasLength(1),
      reason:
          'These cards render side by side on the dashboard. One of them '
          'carrying a different tap target size is how the copies drifted '
          'apart before they shared a widget.',
    );
  });

  testWidgets('every card labels itself and offers its options', (
    tester,
  ) async {
    for (final testCase in _cardCases) {
      await pumpCard(tester, testCase.widget);

      expect(
        find.text(currentAppLocalizations.options),
        findsOneWidget,
        reason: '${testCase.name} must show the options affordance',
      );
    }
  });
}
