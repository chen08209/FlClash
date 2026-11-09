import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/vpn_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/banner.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/test_app.dart';

class _RestartRecordingSetupAction extends SetupAction {
  int restarts = 0;

  @override
  Future<void> restartVpn() async {
    restarts++;
  }
}

void main() {
  late ProviderContainer container;
  late _RestartRecordingSetupAction setupAction;

  setUp(() {
    setupAction = _RestartRecordingSetupAction();
    container = ProviderContainer(
      overrides: [
        setupActionProvider.overrideWith(() => setupAction),
        // Bypassing private addresses computes the routes in Isolate.run, which
        // the fake clock never lets finish.
        networkSettingProvider.overrideWithBuild(
          (_, _) => const NetworkProps(bypassPrivateRoute: false),
        ),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpVpnManager(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: HostApp(
          navigatorKey: globalState.navigatorKey,
          builder: (_, child) {
            return BannerHost(
              stacked: false,
              topInset: 0,
              child: VpnManager(child: child!),
            );
          },
          home: const SizedBox(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  Future<void> outlastTip(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> drainTimers(WidgetTester tester) async {
    await outlastTip(tester);
    await tester.pumpWidget(const SizedBox.shrink());
  }

  void startService() {
    container.read(runningVpnOptionsProvider.notifier).value = container
        .read(vpnOptionsProvider)
        .requireValue;
  }

  void updateVpn(VpnProps Function(VpnProps state) update) {
    container.read(vpnSettingProvider.notifier).update(update);
  }

  Finder tip() => find.text(currentAppLocalizations.vpnConfigChangeDetected);

  testWidgets('a change the running service reads asks for a restart', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    startService();

    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);
    expect(tip(), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(tip());
    await tester.pump();
    expect(setupAction.restarts, 1);
    await drainTimers(tester);
  });

  testWidgets('a mixed port change asks for a restart under a system proxy', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    startService();

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mixedPort: state.mixedPort + 1));
    await settle(tester);

    expect(tip(), findsOneWidget);
    await drainTimers(tester);
  });

  testWidgets('a route change asks once its routes are computed', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    startService();

    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            tun: state.tun.copyWith(routeAddress: const ['10.0.0.0/8']),
          ),
        );
    await tester.pump();
    expect(container.read(vpnOptionsProvider).isLoading, isTrue);
    expect(tip(), findsNothing);

    for (var i = 0; i < 100 && tip().evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(tip(), findsOneWidget);
    await drainTimers(tester);
  });

  testWidgets('no tip while no service is running', (tester) async {
    await pumpVpnManager(tester);

    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);

    expect(tip(), findsNothing);
    await drainTimers(tester);
  });

  testWidgets('no tip for what the service never reads', (tester) async {
    await pumpVpnManager(tester);
    startService();

    updateVpn(
      (state) => state.copyWith(
        accessControlProps: state.accessControlProps.copyWith(
          sort: AccessSortType.name,
          isFilterSystemApp: !state.accessControlProps.isFilterSystemApp,
        ),
      ),
    );
    await settle(tester);

    expect(tip(), findsNothing);
    await drainTimers(tester);
  });

  testWidgets('changing back to what the service runs asks for nothing', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    startService();

    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);
    expect(tip(), findsOneWidget);
    await outlastTip(tester);
    expect(tip(), findsNothing);

    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);

    expect(tip(), findsNothing);
    await drainTimers(tester);
  });

  testWidgets('a restart measures later changes against the new options', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    startService();
    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);
    await outlastTip(tester);
    expect(tip(), findsNothing);

    startService();
    updateVpn((state) => state.copyWith(ipv6: !state.ipv6));
    await settle(tester);

    expect(tip(), findsOneWidget);
    await drainTimers(tester);
  });
}
