import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/plugins/battery.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/on_demand.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class _AndroidBatteryOptimizationIgnored extends BatteryOptimizationIgnored {
  @override
  BatteryOptimization? get plugin => BatteryOptimization.instance;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('location permission', () {
    const channel = MethodChannel('wifi_ssid');
    late ProviderContainer container;
    late List<String> calls;

    void answer(Future<Object?> Function(MethodCall call) handler) {
      messenger.setMockMethodCallHandler(channel, (call) {
        calls.add(call.method);
        return handler(call);
      });
    }

    ProviderContainer excluding(List<String> ssids) {
      return ProviderContainer(
        overrides: [excludeSSIDsProvider.overrideWithValue(ssids)],
      );
    }

    LocationPermissions notifier() {
      return container.read(locationPermissionsProvider.notifier);
    }

    setUp(() {
      calls = [];
      container = excluding(const ['Office Wi-Fi']);
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      container.dispose();
    });

    test('asks for the permission once a network is excluded', () async {
      answer(
        (call) async => switch (call.method) {
          'checkPermission' => 1,
          _ => 0,
        },
      );

      await notifier().refresh();

      expect(calls, ['checkPermission', 'requestPermission']);
      expect(
        container.read(locationPermissionsProvider),
        WifiSsidPermission.granted,
      );
    });

    test('a safe mode build neither checks nor requests location', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          excludeSSIDsProvider.overrideWithValue(const ['Office Wi-Fi']),
          safeModeProvider.overrideWithValue(true),
        ],
      );
      answer((_) async => 0);

      await notifier().refresh();

      expect(calls, isEmpty);
      expect(
        container.read(locationPermissionsProvider),
        WifiSsidPermission.denied,
      );
    });

    test('nothing is asked while no network is excluded', () async {
      container.dispose();
      container = excluding(const []);
      answer((_) async => 1);

      await notifier().refresh();

      expect(calls, ['checkPermission']);
    });

    test('auto-requests at most once per session while denied', () async {
      answer((_) async => 1);

      await notifier().refresh();
      await notifier().refresh();

      expect(calls.where((call) => call == 'requestPermission').length, 1);
    });

    test('an empty excluded list re-arms the auto-request', () async {
      container.dispose();
      container = ProviderContainer();
      answer((_) async => 1);

      await notifier().refresh();
      container.read(excludeSSIDsProvider.notifier).value = const ['Office'];
      await notifier().refresh();
      await notifier().refresh();
      container.read(excludeSSIDsProvider.notifier).value = const [];
      await notifier().refresh();
      container.read(excludeSSIDsProvider.notifier).value = const ['Office'];
      await notifier().refresh();

      expect(calls.where((call) => call == 'requestPermission').length, 2);
    });

    test('a failed auto-request is retried on the next refresh', () async {
      answer((call) async {
        if (call.method == 'requestPermission') {
          throw PlatformException(code: 'IN_PROGRESS');
        }
        return 1;
      });

      await expectLater(notifier().refresh(), completes);
      await notifier().refresh();

      expect(calls.where((call) => call == 'requestPermission').length, 2);
    });

    test('a check keeps a permanent denial until it sees the grant', () async {
      container.dispose();
      container = excluding(const []);
      var checked = 1;
      answer(
        (call) async => switch (call.method) {
          'requestPermission' => 2,
          _ => checked,
        },
      );

      await notifier().request();
      await notifier().refresh();
      expect(
        container.read(locationPermissionsProvider),
        WifiSsidPermission.permanentlyDenied,
      );

      checked = 0;
      await notifier().refresh();
      expect(
        container.read(locationPermissionsProvider),
        WifiSsidPermission.granted,
      );
    });

    test('a request made while one is showing answers null', () async {
      final prompt = Completer<Object?>();
      answer((_) => prompt.future);

      final first = notifier().request();
      final second = await notifier().request();
      prompt.complete(0);

      expect(second, isNull);
      expect(await first, WifiSsidPermission.granted);
      expect(calls, ['requestPermission']);
    });
  });

  group('battery optimization', () {
    const methodChannel = MethodChannel('$packageName/battery');
    const eventChannel = EventChannel('$packageName/battery/optimization');
    late ProviderContainer container;
    late List<String> calls;
    late MockStreamHandlerEventSink events;
    late bool listening;

    void answer(Future<Object?> Function(MethodCall call) handler) {
      messenger.setMockMethodCallHandler(methodChannel, (call) {
        calls.add(call.method);
        return handler(call);
      });
    }

    Future<void> watch() async {
      container.listen(batteryOptimizationIgnoredProvider, (_, _) {});
      await pumpEventQueue();
    }

    bool? ignored() => container.read(batteryOptimizationIgnoredProvider).value;

    setUp(() {
      calls = [];
      listening = false;
      messenger.setMockStreamHandler(
        eventChannel,
        MockStreamHandler.inline(
          onListen: (_, sink) {
            listening = true;
            events = sink;
            sink.success(false);
          },
          onCancel: (_) => listening = false,
        ),
      );
      container = ProviderContainer(
        overrides: [
          batteryOptimizationIgnoredProvider.overrideWith(
            _AndroidBatteryOptimizationIgnored.new,
          ),
        ],
      );
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(methodChannel, null);
      messenger.setMockStreamHandler(eventChannel, null);
      container.dispose();
    });

    test('follows the allowlist while watched and stops after', () async {
      await watch();
      expect(ignored(), isFalse);

      events.success(true);
      await pumpEventQueue();
      expect(ignored(), isTrue);

      container.dispose();
      await pumpEventQueue();
      expect(listening, isFalse);
      container = ProviderContainer();
    });

    test(
      'a request waits for the user and the answer comes from the stream',
      () async {
        answer((_) async {
          events.success(true);
          return null;
        });
        await watch();

        await container
            .read(batteryOptimizationIgnoredProvider.notifier)
            .request();
        await pumpEventQueue();

        expect(calls, ['requestIgnoreOptimizations']);
        expect(ignored(), isTrue);
      },
    );

    test('a second tap while the prompt is up asks once', () async {
      final prompt = Completer<Object?>();
      answer((_) => prompt.future);
      await watch();
      final notifier = container.read(
        batteryOptimizationIgnoredProvider.notifier,
      );

      final first = notifier.request();
      await notifier.request();
      prompt.complete();
      await first;

      expect(calls, ['requestIgnoreOptimizations']);
    });

    test('coming back to the app leaves the state to the stream', () async {
      answer((_) async => null);
      await watch();

      container.read(appVisibleProvider.notifier).value = false;
      container.read(appVisibleProvider.notifier).value = true;
      await pumpEventQueue();

      expect(calls, isEmpty);
      expect(ignored(), isFalse);
    });

    test('a platform without the prompt counts as exempt', () async {
      container.dispose();
      container = ProviderContainer();

      await watch();

      expect(ignored(), isTrue);
      expect(listening, isFalse);
    });
  });
}
