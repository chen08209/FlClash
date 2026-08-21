import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/manager/connectivity_manager.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late StreamController<List<ConnectivityResult>> connectivity;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
    connectivity = StreamController<List<ConnectivityResult>>.broadcast();
  });

  tearDown(() async {
    await connectivity.close();
    container.dispose();
  });

  Future<void> pumpManager(
    WidgetTester tester, {
    required SsidReader readSsid,
    void Function(List<ConnectivityResult>)? onConnectivityChanged,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ConnectivityManager(
          connectivityStream: connectivity.stream,
          readSsid: readSsid,
          onConnectivityChanged: onConnectivityChanged,
          child: const SizedBox.shrink(),
        ),
      ),
    );
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
}
