import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthorizedTunEnable provider', () {
    test('default is none', () {
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
    });

    test('can store authorized and unauthorized results', () {
      final notifier = container.read(authorizedTunEnableProvider.notifier);
      notifier.update((_) => TunAuthorizationState.authorized);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.authorized,
      );
      notifier.update((_) => TunAuthorizationState.unauthorized);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.unauthorized,
      );
    });
  });

  group('Packages provider', () {
    test('default is empty list', () {
      expect(container.read(packagesProvider), isEmpty);
    });

    test('can update state', () {
      const pkg = Package(
        packageName: 'test.app',
        label: 'Test App',
        system: false,
        internet: true,
        lastUpdateTime: 0,
      );
      container.read(packagesProvider.notifier).update((_) => [pkg]);
      expect(container.read(packagesProvider).length, 1);
      expect(container.read(packagesProvider).first.packageName, 'test.app');
    });
  });

  group('Providers provider', () {
    test('setProvider replaces provider with matching name', () {
      final oldProvider = ExternalProvider(
        name: 'Proxy',
        type: 'Proxy',
        count: 1,
        vehicleType: 'HTTP',
        updateAt: DateTime(2026),
      );
      final newProvider = oldProvider.copyWith(count: 2);
      container.read(providersProvider.notifier).update((_) => [oldProvider]);

      container.read(providersProvider.notifier).setProvider(newProvider);

      expect(container.read(providersProvider).single.count, 2);
    });

    test('setProvider ignores null and missing provider names', () {
      final provider = ExternalProvider(
        name: 'Proxy',
        type: 'Proxy',
        count: 1,
        vehicleType: 'HTTP',
        updateAt: DateTime(2026),
      );
      container.read(providersProvider.notifier).update((_) => [provider]);

      container.read(providersProvider.notifier).setProvider(null);
      container
          .read(providersProvider.notifier)
          .setProvider(provider.copyWith(name: 'Other', count: 9));

      expect(container.read(providersProvider).single, provider);
    });
  });

  group('SystemBrightness provider', () {
    test('default is dark', () {
      expect(container.read(systemBrightnessProvider), Brightness.dark);
    });

    test('can update to light', () {
      container
          .read(systemBrightnessProvider.notifier)
          .update((_) => Brightness.light);
      expect(container.read(systemBrightnessProvider), Brightness.light);
    });
  });

  group('LocalIp provider', () {
    test('default is null', () {
      expect(container.read(localIpProvider), null);
    });

    test('can set IP', () {
      container.read(localIpProvider.notifier).update((_) => '192.168.1.1');
      expect(container.read(localIpProvider), '192.168.1.1');
    });
  });

  group('RunTime provider', () {
    test('default is null', () {
      expect(container.read(runTimeProvider), null);
    });

    test('can set runtime', () {
      container.read(runTimeProvider.notifier).update((_) => 3600);
      expect(container.read(runTimeProvider), 3600);
    });
  });

  group('ViewSize provider', () {
    test('default is zero', () {
      expect(container.read(viewSizeProvider), Size.zero);
    });

    test('can update size', () {
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(800, 600));
      final value = container.read(viewSizeProvider);
      expect(value.width, 800);
      expect(value.height, 600);
    });
  });

  group('SideWidth provider', () {
    test('default is 0', () {
      expect(container.read(sideWidthProvider), 0.0);
    });

    test('can update side width', () {
      container.read(sideWidthProvider.notifier).update((_) => 300.0);
      expect(container.read(sideWidthProvider), 300.0);
    });
  });

  group('viewWidth provider (derived)', () {
    test('derives from viewSize width', () {
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(800, 600));
      expect(container.read(viewWidthProvider), 800);
    });
  });

  group('viewHeight provider (derived)', () {
    test('derives from viewSize height', () {
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(800, 600));
      expect(container.read(viewHeightProvider), 600);
    });
  });

  group('Init provider', () {
    test('default is false', () {
      expect(container.read(initProvider), false);
    });

    test('can update to true', () {
      container.read(initProvider.notifier).update((_) => true);
      expect(container.read(initProvider), true);
    });
  });

  group('CurrentPageLabel provider', () {
    test('default is dashboard', () {
      expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
    });

    test('toPage changes page', () {
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.proxies);
      expect(container.read(currentPageLabelProvider), PageLabel.proxies);
    });

    test('toProfiles changes page', () {
      container.read(currentPageLabelProvider.notifier).toProfiles();
      expect(container.read(currentPageLabelProvider), PageLabel.profiles);
    });
  });

  group('NavigationItemsState provider', () {
    test(
      'keeps proxies page visible when profile exists but groups are empty',
      () {
        final profile = Profile.normal(label: 'free nodes', url: 'free.yaml');
        final scopedContainer = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
            groupsProvider.overrideWithBuild((_, _) => []),
          ],
        );
        addTearDown(scopedContainer.dispose);

        final labels = scopedContainer
            .read(navigationItemsStateProvider)
            .value
            .map((item) => item.label);

        expect(labels, contains(PageLabel.proxies));
      },
    );
  });

  group('SortNum provider', () {
    test('default is 0', () {
      expect(container.read(sortNumProvider), 0);
    });

    test('can update', () {
      container.read(sortNumProvider.notifier).update((_) => 5);
      expect(container.read(sortNumProvider), 5);
    });
  });

  group('Version provider', () {
    test('default is 0', () {
      expect(container.read(versionProvider), 0);
    });

    test('can set version', () {
      container.read(versionProvider.notifier).update((_) => 3);
      expect(container.read(versionProvider), 3);
    });
  });

  group('DelayDataSource provider', () {
    test('writes the latest core delay result directly', () {
      final notifier = container.read(delayDataSourceProvider.notifier);

      notifier.setDelay(
        const Delay(url: 'https://test.example', name: 'proxy-a', value: 88),
      );
      notifier.setDelay(
        const Delay(url: 'https://test.example', name: 'proxy-a', value: -1),
      );

      expect(container.read(delayDataSourceProvider), {
        'https://test.example': {'proxy-a': -1},
      });
    });
  });
  group('Groups provider', () {
    test('default is empty', () {
      expect(container.read(groupsProvider), isEmpty);
    });

    test('can set groups', () {
      final groups = [
        const Group(name: 'G1', type: GroupType.Selector, now: 'auto'),
      ];
      container.read(groupsProvider.notifier).update((_) => groups);
      expect(container.read(groupsProvider).length, 1);
      expect(container.read(groupsProvider).first.name, 'G1');
    });

    test('hides stale free node date groups from visible proxy groups', () {
      final today =
          '${DateTime.now().year.toString().padLeft(4, '0')}-'
          '${DateTime.now().month.toString().padLeft(2, '0')}-'
          '${DateTime.now().day.toString().padLeft(2, '0')}';
      final todayIsoGroupName = '${today}T00:00:00Z';
      final freeNodesProfile = freeNodesService.createProfile().copyWith(
        currentGroupName: todayIsoGroupName,
      );
      final scopedContainer = ProviderContainer(
        overrides: [
          currentProfileProvider.overrideWithValue(freeNodesProfile),
          groupsProvider.overrideWithValue([
            const Group(name: freeNodesGroupName, type: GroupType.Selector),
            const Group(
              name: freeNodesTreasureGroupName,
              type: GroupType.Selector,
              hidden: true,
            ),
            const Group(name: '日期 2026-05-30', type: GroupType.Selector),
            Group(name: '日期 $today', type: GroupType.Selector),
            Group(name: todayIsoGroupName, type: GroupType.Selector),
            const Group(name: '香港', type: GroupType.Selector),
            const Group(name: 'GLOBAL', type: GroupType.Selector),
          ]),
        ],
      );
      addTearDown(scopedContainer.dispose);

      final names = scopedContainer
          .read(currentGroupsStateProvider)
          .value
          .map((group) => group.name)
          .toList();

      expect(names, [freeNodesTreasureGroupName, '日期 $today']);
      expect(names.where((name) => name == '日期 $today'), hasLength(1));
      expect(names, isNot(contains(todayIsoGroupName)));
      expect(names, isNot(contains('日期 2026-05-30')));
      expect(names, isNot(contains('香港')));
      expect(names, isNot(contains('GLOBAL')));
      expect(
        scopedContainer.read(proxiesTabStateProvider).currentGroupName,
        '日期 $today',
      );
    });
  });

  group('TotalTraffic provider', () {
    test('default is empty Traffic', () {
      final t = container.read(totalTrafficProvider);
      expect(t.up, 0);
      expect(t.down, 0);
    });
  });

  group('CheckIpNum provider', () {
    test('default is 0', () {
      expect(container.read(checkIpNumProvider), 0);
    });

    test('increment returns previous value and updates state', () {
      final value = container.read(checkIpNumProvider.notifier).add();

      expect(value, 0);
      expect(container.read(checkIpNumProvider), 1);
    });
  });

  group('SortNum provider', () {
    test('increment returns previous value and updates state', () {
      final value = container.read(sortNumProvider.notifier).add();

      expect(value, 0);
      expect(container.read(sortNumProvider), 1);
    });
  });

  group('DelayDataSource provider', () {
    test('sets delay by url and proxy name', () {
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(
            const Delay(name: 'Proxy', url: 'https://test.example', value: 120),
          );

      expect(container.read(delayDataSourceProvider), {
        'https://test.example': {'Proxy': 120},
      });
    });

    test('keeps same state instance when delay value is unchanged', () {
      final notifier = container.read(delayDataSourceProvider.notifier);
      const delay = Delay(name: 'Proxy', url: 'https://test.example', value: 1);
      notifier.setDelay(delay);
      final state = container.read(delayDataSourceProvider);

      notifier.setDelay(delay);

      expect(identical(container.read(delayDataSourceProvider), state), isTrue);
    });
  });

  group('Loading provider', () {
    test('stop without start sets loading false immediately', () async {
      final notifier = container.read(
        loadingProvider(LoadingTag.profiles).notifier,
      );

      await notifier.stop();

      expect(container.read(loadingProvider(LoadingTag.profiles)), false);
    });

    test('stop keeps loading visible for minimum duration', () async {
      final notifier = container.read(
        loadingProvider(LoadingTag.profiles).notifier,
      );

      notifier.start();
      await notifier.stop();

      expect(container.read(loadingProvider(LoadingTag.profiles)), true);

      await Future.delayed(const Duration(milliseconds: 1100));

      expect(container.read(loadingProvider(LoadingTag.profiles)), false);
    });
  });

  group('CoreStatus provider', () {
    test('default is disconnected', () {
      expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    });
  });

  group('NetworkDetection provider', () {
    late HttpClientAdapter originalAdapter;

    setUp(() {
      originalAdapter = request.dio.httpClientAdapter;
    });

    tearDown(() {
      request.dio.httpClientAdapter = originalAdapter;
    });

    test(
      'ignores a canceled stale check after a newer check succeeds',
      () async {
        request.dio.httpClientAdapter = _DelayedCancelIpAdapter();
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            runTimeProvider.overrideWithBuild((_, _) => 1),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(networkDetectionProvider.notifier);
        notifier.startCheck();
        await Future.delayed(commonDuration + const Duration(milliseconds: 50));

        notifier.startCheck();
        await Future.delayed(
          commonDuration + const Duration(milliseconds: 120),
        );

        expect(container.read(networkDetectionProvider).ipInfo?.ip, '2.2.2.2');
        expect(container.read(networkDetectionProvider).isLoading, false);

        await Future.delayed(const Duration(milliseconds: 620));

        expect(container.read(networkDetectionProvider).ipInfo?.ip, '2.2.2.2');
        expect(container.read(networkDetectionProvider).isLoading, false);
      },
    );
  });
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles(this.initial);

  @override
  List<Profile> build() => initial;

  @override
  void put(Profile profile) {
    unawaited(putAndWait(profile));
  }

  @override
  Future<void> putAndWait(Profile profile) async {
    final next = List<Profile>.from(state);
    final index = next.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      next.add(profile);
    } else {
      next[index] = profile;
    }
    state = next;
  }

  @override
  Future<void> del(int id) async {
    state = state.where((profile) => profile.id != id).toList();
  }
}

class _DelayedCancelIpAdapter implements HttpClientAdapter {
  static const _sourceCount = 7;

  int _requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    _requestCount++;
    final batch = ((_requestCount - 1) ~/ _sourceCount) + 1;
    if (batch == 1) {
      final completer = Completer<ResponseBody>();
      cancelFuture?.then((_) {
        Timer(const Duration(milliseconds: 500), () {
          if (completer.isCompleted) return;
          completer.completeError(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: 'cancelled',
            ),
          );
        });
      });
      return completer.future;
    }

    return Future.delayed(
      const Duration(milliseconds: 10),
      () => ResponseBody.fromString(
        '{"ip":"2.2.2.2","country_code":"US"}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}
