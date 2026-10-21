import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/manager/connectivity_manager.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/on_demand.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

void main() {
  late ProviderContainer container;
  late StreamController<List<ConnectivityResult>> connectivity;

  setUp(() {
    container = ProviderContainer(
      overrides: [currentProfileProvider.overrideWithValue(null)],
    );
    container.listen(configProvider, (_, _) {});
    globalState.container = container;
    connectivity = StreamController<List<ConnectivityResult>>.broadcast();
  });

  tearDown(() async {
    await connectivity.close();
    container.dispose();
  });

  Future<void> excludeNetworks(List<String> ssids) async {
    container.read(excludeSSIDsProvider.notifier).value = ssids;
    await Future<void>.value();
  }

  Future<void> pumpManager(
    WidgetTester tester, {
    required SsidReader readSsid,
    void Function(List<ConnectivityResult>)? onConnectivityChanged,
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    List<String> excludeSSIDs = const ['Home'],
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ConnectivityManager(
          connectivityStream: connectivity.stream,
          readSsid: readSsid,
          checkConnectivity: checkConnectivity,
          onConnectivityChanged: onConnectivityChanged,
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await excludeNetworks(excludeSSIDs);
  }

  String? currentSsid() => container.read(currentSSIDProvider);

  testWidgets('publishes the SSID once Wi-Fi is up', (tester) async {
    await pumpManager(tester, readSsid: () async => 'Home');

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();

    expect(currentSsid(), 'Home');
  });

  testWidgets('clears the SSID when Wi-Fi drops', (tester) async {
    await pumpManager(tester, readSsid: () async => 'Home');

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    connectivity.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();

    expect(currentSsid(), isNull);
  });

  testWidgets('does not read the SSID while off Wi-Fi', (tester) async {
    var reads = 0;
    await pumpManager(
      tester,
      readSsid: () async {
        reads++;
        return 'Home';
      },
    );

    connectivity.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();

    expect(reads, 0);
  });

  testWidgets('does not read the SSID while no network is excluded', (
    tester,
  ) async {
    var reads = 0;
    await pumpManager(
      tester,
      excludeSSIDs: const [],
      readSsid: () async {
        reads++;
        return 'Home';
      },
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();

    expect(reads, 0);
    expect(currentSsid(), isNull);
  });

  testWidgets('reads the SSID as soon as the first network is excluded', (
    tester,
  ) async {
    await pumpManager(
      tester,
      excludeSSIDs: const [],
      readSsid: () async => 'Home',
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentSsid(), isNull);

    await excludeNetworks(const ['Office']);
    await tester.pumpAndSettle();

    expect(currentSsid(), 'Home');
  });

  testWidgets('reads the SSID again once location permission is granted', (
    tester,
  ) async {
    const channel = MethodChannel('wifi_ssid');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async => 0);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    var permitted = false;
    await pumpManager(tester, readSsid: () async => permitted ? 'Home' : null);

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentSsid(), isNull);

    permitted = true;
    await container.read(locationPermissionsProvider.notifier).request();
    await tester.pumpAndSettle();

    expect(
      container.read(locationPermissionsProvider),
      WifiSsidPermission.granted,
    );
    expect(currentSsid(), 'Home');
  });

  testWidgets('drops the SSID when the last excluded network is removed', (
    tester,
  ) async {
    var reads = 0;
    await pumpManager(
      tester,
      readSsid: () async {
        reads++;
        return 'Home';
      },
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentSsid(), 'Home');

    await excludeNetworks(const []);
    await tester.pumpAndSettle();

    expect(currentSsid(), isNull);
    expect(reads, 1, reason: 'clearing the list must not re-read the SSID');
  });

  testWidgets('a failing native read does not escape as an unhandled error', (
    tester,
  ) async {
    await pumpManager(
      tester,
      readSsid: () async => throw Exception('Context not available'),
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(currentSsid(), isNull);
  });

  testWidgets('a failure clears a previously published SSID', (tester) async {
    var shouldFail = false;
    await pumpManager(
      tester,
      readSsid: () async {
        if (shouldFail) throw Exception('WifiManager not available');
        return 'Home';
      },
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentSsid(), 'Home');

    shouldFail = true;
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();

    expect(currentSsid(), isNull);
  });

  testWidgets('a slow read cannot overwrite a newer one', (tester) async {
    final gates = <Completer<String?>>[
      Completer<String?>(),
      Completer<String?>(),
    ];
    var index = 0;
    await pumpManager(tester, readSsid: () => gates[index++].future);

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();

    gates[1].complete('Office');
    await tester.pumpAndSettle();
    expect(currentSsid(), 'Office');

    gates[0].complete('Home');
    await tester.pumpAndSettle();

    expect(
      currentSsid(),
      'Office',
      reason: 'the first read resolved last but is stale',
    );
  });

  testWidgets('a slow read cannot resurrect the SSID after Wi-Fi drops', (
    tester,
  ) async {
    final gate = Completer<String?>();
    await pumpManager(tester, readSsid: () => gate.future);

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();
    connectivity.add([ConnectivityResult.none]);
    await tester.pump();

    gate.complete('Home');
    await tester.pumpAndSettle();

    expect(currentSsid(), isNull);
  });

  testWidgets('a safe mode build never reads the SSID', (tester) async {
    container.dispose();
    container = ProviderContainer(
      overrides: [safeModeProvider.overrideWithValue(true)],
    );
    globalState.container = container;
    var reads = 0;
    await pumpManager(
      tester,
      readSsid: () async {
        reads++;
        return 'Home';
      },
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();

    expect(reads, 0);
    expect(currentSsid(), isNull);
  });

  testWidgets('forwards every result to the callback', (tester) async {
    final seen = <List<ConnectivityResult>>[];
    await pumpManager(
      tester,
      readSsid: () async => 'Home',
      onConnectivityChanged: seen.add,
    );

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    connectivity.add([ConnectivityResult.none]);
    await tester.pumpAndSettle();

    expect(seen, [
      [ConnectivityResult.wifi],
      [ConnectivityResult.none],
    ]);
  });

  testWidgets('a read that resolves after disposal is dropped', (tester) async {
    final gate = Completer<String?>();
    await pumpManager(tester, readSsid: () => gate.future);

    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete('Home');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
  Future<void> enableModes(
    WidgetTester tester, {
    Mode fallback = Mode.rule,
  }) async {
    container.read(wifiModeSettingProvider.notifier).value = WifiModeSettings(
      enabled: true,
      rules: const {'ASUS395': Mode.direct, 'Office': Mode.global},
      fallback: fallback,
    );
    await tester.pumpAndSettle();
  }

  Mode currentMode() => container.read(patchClashConfigProvider).mode;

  testWidgets('switches all three modes without an excluded SSID', (
    tester,
  ) async {
    var ssid = 'ASUS395';
    await pumpManager(tester, readSsid: () async => ssid, excludeSSIDs: []);
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.direct);
    expect(container.read(suspendProvider), isFalse);

    ssid = 'Office';
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.global);

    ssid = 'asus395';
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.rule, reason: 'SSID matching is case sensitive');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('uses the fallback when Wi-Fi drops or the SSID cannot be read', (
    tester,
  ) async {
    String? ssid = 'ASUS395';
    await pumpManager(tester, readSsid: () async => ssid);
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.direct);
    ssid = null;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.rule);
    ssid = 'ASUS395';
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.direct);
    connectivity.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.rule);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('keeps a manual mode until the network changes', (tester) async {
    var ssid = 'ASUS395';
    await pumpManager(tester, readSsid: () async => ssid);
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.rule));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.rule);
    ssid = 'Office';
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.global);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disabling automation cancels polling and mode changes', (
    tester,
  ) async {
    var reads = 0;
    await pumpManager(
      tester,
      excludeSSIDs: [],
      readSsid: () async {
        reads++;
        return 'ASUS395';
      },
    );
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    final previousReads = reads;
    container
        .read(wifiModeSettingProvider.notifier)
        .update((state) => state.copyWith(enabled: false));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    expect(reads, previousReads);
    expect(currentMode(), Mode.direct);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('applies changes to a rule for the connected SSID', (
    tester,
  ) async {
    await pumpManager(
      tester,
      readSsid: () async => 'ASUS395',
      excludeSSIDs: ['ASUS395'],
    );
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(container.read(suspendProvider), isFalse);
    container
        .read(wifiModeSettingProvider.notifier)
        .update((state) => state.copyWith(rules: {'ASUS395': Mode.global}));
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.global);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reads connectivity on startup without waiting for an event', (
    tester,
  ) async {
    await pumpManager(
      tester,
      readSsid: () async => 'ASUS395',
      checkConnectivity: () async => [ConnectivityResult.wifi],
    );
    await enableModes(tester);
    expect(currentMode(), Mode.direct);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a late SSID read cannot change mode after leaving Wi-Fi', (
    tester,
  ) async {
    final gate = Completer<String?>();
    await pumpManager(tester, readSsid: () => gate.future);
    await enableModes(tester);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();
    connectivity.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();
    gate.complete('ASUS395');
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.rule);
    expect(currentSsid(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('a failed read and a timeout apply the configured fallback', (
    tester,
  ) async {
    var hanging = false;
    final gate = Completer<String?>();
    await pumpManager(
      tester,
      readSsid: () {
        if (hanging) return gate.future;
        return Future.error(StateError('unavailable'));
      },
    );
    await enableModes(tester, fallback: Mode.global);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentMode(), Mode.global);
    hanging = true;
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(currentMode(), Mode.global);
    await tester.pumpWidget(const SizedBox.shrink());
    gate.complete('ASUS395');
    await tester.pumpAndSettle();
  });

  testWidgets('safe mode never applies automation', (tester) async {
    container.dispose();
    container = ProviderContainer(
      overrides: [safeModeProvider.overrideWithValue(true)],
    );
    container.listen(configProvider, (_, _) {});
    globalState.container = container;
    var reads = 0;
    await pumpManager(
      tester,
      readSsid: () async {
        reads++;
        return 'ASUS395';
      },
    );
    await enableModes(tester, fallback: Mode.direct);
    connectivity.add([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    expect(reads, 0);
    expect(currentMode(), Mode.rule);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('resuming reads the network again', (tester) async {
    var ssid = 'ASUS395';
    var checks = 0;
    await pumpManager(
      tester,
      readSsid: () async => ssid,
      checkConnectivity: () async {
        checks++;
        return [ConnectivityResult.wifi];
      },
    );
    await enableModes(tester);
    expect(currentMode(), Mode.direct);
    ssid = 'Office';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(checks, 2);
    expect(currentMode(), Mode.global);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a late startup network check cannot override a newer event', (
    tester,
  ) async {
    final gate = Completer<List<ConnectivityResult>>();
    await pumpManager(
      tester,
      readSsid: () async => 'ASUS395',
      checkConnectivity: () => gate.future,
    );
    await enableModes(tester);
    connectivity.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();
    gate.complete([ConnectivityResult.wifi]);
    await tester.pumpAndSettle();
    expect(currentSsid(), isNull);
    expect(currentMode(), Mode.rule);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
