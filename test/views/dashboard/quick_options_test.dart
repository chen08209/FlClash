import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/views/dashboard/widgets/quick_options.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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

  testWidgets(
    'system proxy options edit bypass domains and copy a selected command',
    (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      const port = 7891;

      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: StatusManager(
              child: TestApp(child: Scaffold(body: SystemProxyButton())),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(currentAppLocalizations.options));
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.bypassDomain), findsOneWidget);
      expect(find.text(currentAppLocalizations.allowLan), findsOneWidget);
      expect(find.text(currentAppLocalizations.copyEnvVar), findsOneWidget);
      expect(
        tester
            .widget<DropdownButton<ProxyCommandOs>>(
              find.byType(DropdownButton<ProxyCommandOs>),
            )
            .focusColor,
        Colors.transparent,
      );

      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mixedPort: port));
      await tester.tap(find.text(currentAppLocalizations.allowLan));
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).allowLan, isTrue);
      container.read(localIpProvider.notifier).update((_) => '192.168.1.20');
      await tester.pump();

      await tester.tap(find.text(currentAppLocalizations.bypassDomain));
      await tester.pumpAndSettle();
      await tester.tap(find.text(currentAppLocalizations.add).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'example.test');
      await tester.tap(find.text(currentAppLocalizations.confirm));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.back).last);
      await tester.pumpAndSettle();

      expect(
        container.read(networkSettingProvider).bypassDomain,
        contains('example.test'),
      );

      await tester.tap(find.byType(DropdownButton<ProxyCommandOs>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ProxyCommandOs.linux.label).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.copyEnvVar));
      await tester.pumpAndSettle();

      expect(copied, hasLength(1));
      expect(
        copied.single,
        buildProxyEnvCommand(
          port: port,
          os: ProxyCommandOs.linux,
          host: '192.168.1.20',
        ),
      );
      expect(find.text(currentAppLocalizations.copySuccess), findsOneWidget);
    },
  );
}
