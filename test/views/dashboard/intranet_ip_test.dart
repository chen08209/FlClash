import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/intranet_ip.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [localIpProvider.overrideWithBuild((_, _) => '192.168.1.23')],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    DashboardDensity density = DashboardDensity.compact,
  }) async {
    final desktop = density.isDesktop;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: const Locale('en'),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: desktop ? 208 : 380,
                height: desktop ? 152 : null,
                child: DashboardDensityScope(
                  density: density,
                  scale: 1,
                  child: const IntranetIpCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the switch lets the network proxy through this device', (
    tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('192.168.1.23'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);

    await tester.tap(find.byType(DashboardSwitch));
    await tester.pump();

    expect(container.read(patchClashConfigProvider).allowLan, isTrue);
    expect(find.text('Port 7890'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('copies the address with the port once the network may use it', (
    tester,
  ) async {
    String? copied;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await pumpCard(tester);

    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();
    expect(copied, '192.168.1.23');

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(allowLan: true));
    await tester.pump();
    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();
    expect(copied, '192.168.1.23:7890');
    await tester.pumpAndSettle();
  });

  testWidgets('without a network there is nothing to copy', (tester) async {
    container.read(localIpProvider.notifier).update((_) => '');
    await pumpCard(tester, density: DashboardDensity.mobile);

    expect(find.text('No network'), findsOneWidget);
    final copy = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Copy'),
        matching: find.byType(IconButton),
      ),
    );
    expect(copy.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
