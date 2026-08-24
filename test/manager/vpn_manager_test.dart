import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/manager/vpn_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
    globalState.lastVpnState = null;
  });

  tearDown(() {
    container.dispose();
    globalState.lastVpnState = null;
  });

  Future<void> pumpVpnManager(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (_, child) {
            return StatusManager(child: VpnManager(child: child!));
          },
          home: const SizedBox(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> drainTimers(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('shows a tip when the vpn state changes while started', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    container.read(runTimeProvider.notifier).value = 1;

    container
        .read(vpnSettingProvider.notifier)
        .update((_) => const VpnProps(enable: false));
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );
    await drainTimers(tester);
  });

  testWidgets('does not show a tip when not started', (tester) async {
    await pumpVpnManager(tester);

    container
        .read(vpnSettingProvider.notifier)
        .update((_) => const VpnProps(enable: false));
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );
    await drainTimers(tester);
  });

  testWidgets('does not repeat the tip for the same vpn state', (tester) async {
    await pumpVpnManager(tester);
    container.read(runTimeProvider.notifier).value = 1;

    container
        .read(vpnSettingProvider.notifier)
        .update((_) => const VpnProps(enable: false));
    await tester.pump();
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );

    globalState.lastVpnState = container.read(vpnStateProvider);
    container
        .read(vpnSettingProvider.notifier)
        .update((_) => const VpnProps(enable: true));
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );
    await drainTimers(tester);
  });
}
