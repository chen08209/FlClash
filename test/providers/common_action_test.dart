import 'dart:async';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/core_mocks.dart';

const runningVersion = '0.8.96';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoreMocks mocks;

  setUp(() => mocks = coreMocks());

  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: runningVersion,
      buildNumber: '1',
    );
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [coreHandlerProvider.overrideWithValue(mocks.controller)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CommonAction.updateMode', () {
    test('advances through every mode and wraps back to the first', () {
      final container = buildContainer();
      final action = container.read(commonActionProvider.notifier);
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.values.first));

      final seen = <Mode>[container.read(patchClashConfigProvider).mode];
      for (var i = 0; i < Mode.values.length; i++) {
        action.updateMode();
        seen.add(container.read(patchClashConfigProvider).mode);
      }

      expect(seen.sublist(0, Mode.values.length), Mode.values);
      expect(seen.last, Mode.values.first, reason: 'wraps after the last mode');
    });
  });

  group('CommonAction.updateSpeedStatistics', () {
    test('toggles the tray title flag both ways', () {
      final container = buildContainer();
      final action = container.read(commonActionProvider.notifier);
      final initial = container.read(appSettingProvider).showTrayTitle;

      action.updateSpeedStatistics();
      expect(container.read(appSettingProvider).showTrayTitle, !initial);

      action.updateSpeedStatistics();
      expect(container.read(appSettingProvider).showTrayTitle, initial);
    });
  });

  group('CommonAction.setTrafficFeed', () {
    late StreamController<TrafficSample> feed;

    ProviderContainer buildFeedContainer({bool connected = true}) {
      final container = buildContainer();
      container.read(commonActionProvider);
      if (connected) {
        container.read(coreStatusProvider.notifier).value =
            CoreStatus.connected;
      }
      return container;
    }

    void stubFeed() {
      when(
        () => mocks.api.watchTraffic(
          intervalMs: any(named: 'intervalMs'),
          onlyProxy: any(named: 'onlyProxy'),
        ),
      ).thenAnswer((_) => feed.stream);
    }

    setUp(() {
      feed = StreamController<TrafficSample>.broadcast();
      stubFeed();
    });

    tearDown(() => feed.close());

    test('records the sampled traffic and the running total', () async {
      final container = buildFeedContainer();
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(onlyStatisticsProxy: true));

      container.read(commonActionProvider.notifier).setTrafficFeed(true);
      feed.add(
        const TrafficSample(up: 10, down: 20, totalUp: 100, totalDown: 200),
      );
      await pumpEventQueue();

      expect(container.read(trafficsProvider).list.last.up, 10);
      expect(container.read(trafficsProvider).list.last.down, 20);
      expect(
        container.read(totalTrafficProvider),
        const Traffic(up: 100, down: 200),
      );
      verify(
        () => mocks.api.watchTraffic(intervalMs: 1000, onlyProxy: true),
      ).called(1);
    });

    test('does not subscribe while the core is not connected', () async {
      final container = buildFeedContainer(connected: false);

      container.read(commonActionProvider.notifier).setTrafficFeed(true);
      await pumpEventQueue();

      expect(feed.hasListener, isFalse);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await pumpEventQueue();

      expect(feed.hasListener, isTrue);
    });

    test('ends the subscription when the feed is turned off', () async {
      final container = buildFeedContainer();
      final action = container.read(commonActionProvider.notifier);

      action.setTrafficFeed(true);
      await pumpEventQueue();
      expect(feed.hasListener, isTrue);

      action.setTrafficFeed(false);
      await pumpEventQueue();
      expect(feed.hasListener, isFalse);
    });

    test('turning the feed on twice subscribes once', () async {
      final container = buildFeedContainer();
      final action = container.read(commonActionProvider.notifier);

      action
        ..setTrafficFeed(true)
        ..setTrafficFeed(true);

      verify(
        () => mocks.api.watchTraffic(
          intervalMs: any(named: 'intervalMs'),
          onlyProxy: any(named: 'onlyProxy'),
        ),
      ).called(1);
    });

    test('resubscribes with the new filter when it changes', () async {
      final container = buildFeedContainer();
      container.read(commonActionProvider.notifier).setTrafficFeed(true);

      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(onlyStatisticsProxy: true));

      verify(
        () => mocks.api.watchTraffic(intervalMs: 1000, onlyProxy: true),
      ).called(1);
    });

    test('keeps the total untouched when the feed fails', () async {
      final container = buildFeedContainer();
      final before = container.read(totalTrafficProvider);
      container.read(commonActionProvider.notifier).setTrafficFeed(true);

      feed.addError(StateError('core down'));
      await pumpEventQueue();

      expect(container.read(totalTrafficProvider), before);
      expect(feed.hasListener, isTrue);
    });
  });

  group('CommonAction.autoCheckUpdate', () {
    test('returns without a network call when the setting is off', () async {
      final container = buildContainer();
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(autoCheckUpdate: false));

      await expectLater(
        container.read(commonActionProvider.notifier).autoCheckUpdate(),
        completion(isFalse),
      );
    });
  });
}
