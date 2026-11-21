import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/api/core_api.dart';
import 'package:fl_clash/core/api/dto.dart';
import 'package:fl_clash/core/api/errors.dart';
import 'package:fl_clash/core/api/mapping.dart';
import 'package:fl_clash/core/api/model_api.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/app_paths.dart';
import '../helpers/core_mocks.dart';

const _options = CoreOptions(testUrl: 'http://x.com');

const _applied = CoreLifecycleResult(
  revision: 1,
  outcome: CoreLifecycleOutcome.applied,
);

void main() {
  late CoreMocks mocks;
  late CoreController controller;
  late MockCoreApi api;

  setUpAll(() {
    registerFallbackValue(const ConfigPatch());
    registerFallbackValue(const CoreOptionsArg(testUrl: ''));
    registerFallbackValue(<JsonMap>[]);
  });

  setUp(() {
    mocks = coreMocks();
    controller = mocks.controller;
    api = mocks.api;
    CoreController.resetInstance();
  });

  tearDown(CoreController.resetInstance);

  group('CoreController singleton', () {
    test('test constructor injects the backend', () {
      final instance = CoreController.test(mocks.backend);

      expect(instance, isA<CoreController>());
      expect(instance.api, same(api));
    });

    test('resetInstance allows fresh construction', () {
      CoreController.test(mocks.backend);
      CoreController.resetInstance();
      final instance = CoreController.test(mocks.backend);
      expect(instance, isA<CoreController>());
    });
  });

  group('lifecycle methods', () {
    test('start, restart, stop, and close delegate to the backend', () async {
      final backend = mocks.backend;
      when(backend.start).thenAnswer((_) async => _applied);
      when(backend.restart).thenAnswer((_) async => _applied);
      when(backend.stop).thenAnswer((_) async => _applied);
      when(backend.close).thenAnswer((_) async => _applied);

      expect(await controller.start(), same(_applied));
      expect(await controller.restart(), same(_applied));
      expect(await controller.stop(), same(_applied));
      expect(await controller.close(), same(_applied));

      verify(backend.start).called(1);
      verify(backend.restart).called(1);
      verify(backend.stop).called(1);
      verify(backend.close).called(1);
    });

    test('listener commands delegate to the backend', () async {
      when(mocks.backend.startListener).thenAnswer((_) async {});
      when(mocks.backend.stopListener).thenAnswer((_) async {});

      await controller.startListener();
      await controller.stopListener();

      verify(mocks.backend.startListener).called(1);
      verify(mocks.backend.stopListener).called(1);
    });

    test('crashes come from the backend', () {
      final crashes = StreamController<String>.broadcast();
      addTearDown(crashes.close);
      when(() => mocks.backend.crashes).thenAnswer((_) => crashes.stream);

      expectLater(controller.crashes, emits('core done'));
      crashes.add('core done');
    });
  });

  group('init', () {
    late Directory home;

    setUp(() async {
      home = Directory.systemTemp.createTempSync('controller_init_test');
      await useAppPaths(home);
      for (final name in [MMDB, GEOSITE]) {
        File('${home.path}/$name').writeAsStringSync('geo');
      }
    });

    tearDown(() => home.deleteSync(recursive: true));

    test('hands the home directory and SDK level to the Core', () async {
      when(
        () => api.init(
          home: any(named: 'home'),
          sdkInt: any(named: 'sdkInt'),
        ),
      ).thenAnswer((_) async {});

      await controller.init(34);

      verify(() => api.init(home: home.path, sdkInt: 34)).called(1);
    });

    test('surfaces what the Core refuses', () async {
      when(
        () => api.init(
          home: any(named: 'home'),
          sdkInt: any(named: 'sdkInt'),
        ),
      ).thenThrow(const CoreMethodException(code: 'busy', message: 'busy'));

      await expectLater(
        controller.init(34),
        throwsA(isA<CoreMethodException>()),
      );
    });
  });

  group('config methods', () {
    test('validateConfig reports the first issue', () async {
      when(() => api.validateConfig('/path')).thenAnswer(
        (_) async => const [
          IssueInfo(message: 'bad'),
          IssueInfo(message: 'worse'),
        ],
      );

      expect(await controller.validateConfig('/path'), 'bad');
      verify(() => api.validateConfig('/path')).called(1);
    });

    test('validateConfig is null for a valid config', () async {
      when(() => api.validateConfig('/path')).thenAnswer((_) async => const []);

      expect(await controller.validateConfig('/path'), isNull);
    });

    group('validateProfile', () {
      late Directory dir;
      late String path;

      setUp(() {
        dir = Directory.systemTemp.createTempSync('validate_profile_test');
        path = '${dir.path}/profile.yaml';
        when(() => api.validateConfig(path)).thenAnswer((_) async => const []);
      });

      tearDown(() => dir.deleteSync(recursive: true));

      test('decrypts an age-encrypted config in place', () async {
        File(
          path,
        ).writeAsStringSync('-----BEGIN AGE ENCRYPTED FILE-----\nYWdl\n');
        when(
          () => api.decryptConfig(path, 'AGE-SECRET-KEY-1A'),
        ).thenAnswer((_) async => const TextOutput(text: 'proxies: []'));

        expect(
          await controller.validateProfile(path, 'AGE-SECRET-KEY-1A'),
          isNull,
        );
        expect(File(path).readAsStringSync(), 'proxies: []');
      });

      test('asks for a key an encrypted config lacks', () async {
        File(
          path,
        ).writeAsStringSync('-----BEGIN AGE ENCRYPTED FILE-----\nYWdl\n');

        await expectLater(
          controller.validateProfile(path),
          throwsA(isA<AgeSecretKeyRequiredException>()),
        );
        verifyNever(() => api.decryptConfig(any(), any()));
      });

      test('leaves a plain config as it is', () async {
        File(path).writeAsStringSync('proxies: []');

        expect(
          await controller.validateProfile(path, 'AGE-SECRET-KEY-1A'),
          isNull,
        );
        verifyNever(() => api.decryptConfig(any(), any()));
        verifyNever(() => api.convertSubscription(any()));
        expect(File(path).readAsStringSync(), 'proxies: []');
      });

      group('a config the Core rejects', () {
        setUp(() {
          File(path).writeAsStringSync('vmess://abc');
          var rewritten = false;
          when(() => api.validateConfig(path)).thenAnswer(
            (_) async => rewritten
                ? const []
                : const [IssueInfo(message: 'not a config')],
          );
          when(() => api.convertSubscription(path)).thenAnswer((_) async {
            rewritten = true;
            return [
              {'name': 'a', 'type': 'ss'},
            ];
          });
        });

        test('is rewritten from the share links it holds', () async {
          expect(await controller.validateProfile(path), isNull);

          expect(File(path).readAsStringSync(), contains('proxies'));
          expect(File(path).readAsStringSync(), contains('name: "a"'));
        });

        test('keeps its first issue when it holds no proxies', () async {
          when(
            () => api.convertSubscription(path),
          ).thenAnswer((_) async => const []);

          expect(await controller.validateProfile(path), 'not a config');
          expect(File(path).readAsStringSync(), 'vmess://abc');
        });

        test('keeps its first issue when conversion fails', () async {
          when(() => api.convertSubscription(path)).thenThrow(
            const CoreMethodException(code: 'rejected', message: 'no'),
          );

          expect(await controller.validateProfile(path), 'not a config');
          expect(File(path).readAsStringSync(), 'vmess://abc');
        });
      });
    });

    test('validateConfigWithData validates a temporary copy', () async {
      final home = Directory.systemTemp.createTempSync('validate_data_test');
      addTearDown(() => home.deleteSync(recursive: true));
      await useAppPaths(home);
      String? validated;
      when(() => api.validateConfig(any())).thenAnswer((invocation) async {
        validated = invocation.positionalArguments.single as String;
        expect(File(validated!).readAsStringSync(), 'a: 1');
        return const [IssueInfo(message: 'bad')];
      });

      expect(await controller.validateConfigWithData('a: 1'.codeUnits), 'bad');
      expect(File(validated!).existsSync(), isFalse);
    });

    test('updateConfig hands the patch to the Core', () async {
      const patch = ConfigPatch(mixedPort: 7890, allowLan: true);
      when(() => api.patchConfig(any())).thenAnswer((_) async => 1);

      await controller.updateConfig(patch);

      verify(() => api.patchConfig(patch)).called(1);
    });

    group('setupConfig', () {
      void stubApply() {
        when(
          () => api.applyConfig(
            profilePath: any(named: 'profilePath'),
            overlay: any(named: 'overlay'),
            selection: any(named: 'selection'),
            options: any(named: 'options'),
            host: any(named: 'host'),
          ),
        ).thenAnswer((_) async => const []);
      }

      test('applies the profile with its overlay and selection', () async {
        stubApply();
        const params = SetupParams(
          base: SetupBase(path: '/p.yaml', overlay: {'mode': 'global'}),
          selectedMap: {'G': 'P'},
          options: _options,
        );

        await controller.setupConfig(params: params);

        verify(
          () => api.applyConfig(
            profilePath: '/p.yaml',
            overlay: {'mode': 'global'},
            selection: {'G': 'P'},
            options: any(
              named: 'options',
              that: isA<CoreOptionsArg>().having(
                (options) => options.testUrl,
                'testUrl',
                'http://x.com',
              ),
            ),
          ),
        ).called(1);
      });

      test('hands the host settings on with the apply', () async {
        stubApply();
        const host = {'secret': 's', 'hostCredential': 'h:s'};

        await controller.setupConfig(
          params: const SetupParams(
            selectedMap: {},
            options: _options,
            host: host,
          ),
        );

        verify(
          () => api.applyConfig(
            profilePath: null,
            overlay: null,
            selection: const {},
            options: any(named: 'options'),
            host: host,
          ),
        ).called(1);
      });

      test('applies the config in the home directory without a base', () async {
        stubApply();

        await controller.setupConfig(
          params: const SetupParams(selectedMap: {}, options: _options),
        );

        verify(
          () => api.applyConfig(
            profilePath: null,
            overlay: null,
            selection: const {},
            options: any(named: 'options'),
          ),
        ).called(1);
      });

      test('waits for asynchronous preload', () async {
        const params = SetupParams(selectedMap: {}, options: _options);
        final preloadCompleter = Completer<void>();
        final events = <String>[];
        when(
          () => api.applyConfig(
            profilePath: any(named: 'profilePath'),
            overlay: any(named: 'overlay'),
            selection: any(named: 'selection'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) {
          events.add('setup');
          return Future.value(const []);
        });

        final setupFuture = controller.setupConfig(
          params: params,
          preloadInvoke: () async {
            events.add('preload');
            await preloadCompleter.future;
          },
        );
        var completed = false;
        unawaited(setupFuture.then((_) => completed = true));
        await Future<void>.delayed(Duration.zero);

        expect(events, ['setup', 'preload']);
        expect(completed, isFalse);

        preloadCompleter.complete();
        await setupFuture;
        expect(completed, isTrue);
      });

      test('surfaces what the Core refuses', () async {
        when(
          () => api.applyConfig(
            profilePath: any(named: 'profilePath'),
            overlay: any(named: 'overlay'),
            selection: any(named: 'selection'),
            options: any(named: 'options'),
          ),
        ).thenThrow(const CoreMethodException(code: 'rejected', message: 'x'));

        await expectLater(
          controller.setupConfig(
            params: const SetupParams(selectedMap: {}, options: _options),
          ),
          throwsA(isA<CoreMethodException>()),
        );
      });
    });
  });

  group('lists the Core is not asked for when empty', () {
    test('validateProxies', () async {
      expect(await controller.validateProxies(const []), isEmpty);
      verifyNever(() => api.validateProxies(any()));
    });

    test('validateFilters', () async {
      expect(await controller.validateFilters(const []), isEmpty);
      verifyNever(() => api.validateFilters(any()));
    });

    test('encodeShareLinks', () async {
      expect(await controller.encodeShareLinks(const []), isEmpty);
      verifyNever(() => api.encodeLinks(any()));
    });

    test('decodeShareLinks', () async {
      expect(await controller.decodeShareLinks(const []), isEmpty);
      verifyNever(() => api.decodeLinks(any()));
    });
  });

  group('lists the Core is asked for', () {
    test('validateProxies returns the issues by index', () async {
      final proxies = [
        {'name': 'a'},
      ];
      when(
        () => api.validateProxies(proxies),
      ).thenAnswer((_) async => {0: 'missing type'});

      expect(await controller.validateProxies(proxies), {0: 'missing type'});
    });

    test('validateFilters returns the issues by index', () async {
      when(
        () => api.validateFilters(['(']),
      ).thenAnswer((_) async => {0: 'bad regex'});

      expect(await controller.validateFilters(['(']), {0: 'bad regex'});
    });

    test('encodeShareLinks returns the links', () async {
      final proxies = [
        {'name': 'a'},
      ];
      when(() => api.encodeLinks(proxies)).thenAnswer((_) async => ['ss://a']);

      expect(await controller.encodeShareLinks(proxies), ['ss://a']);
    });

    test('decodeShareLinks returns the proxies of each line', () async {
      when(() => api.decodeLinks(['ss://a'])).thenAnswer(
        (_) async => [
          [
            {'name': 'a'},
          ],
        ],
      );

      expect(await controller.decodeShareLinks(['ss://a']), [
        [
          {'name': 'a'},
        ],
      ]);
    });
  });

  group('profile queries', () {
    late Directory home;

    setUp(() async {
      home = Directory.systemTemp.createTempSync('controller_profile_test');
      await useAppPaths(home);
    });

    tearDown(() => home.deleteSync(recursive: true));

    Future<String> profilePath(int id) => appPath.getProfilePath('$id');

    test('readConfig reads the profile of the id', () async {
      final path = await profilePath(7);
      when(
        () => api.readConfig(path),
      ).thenAnswer((_) async => const ConfigReadOutput(config: {'port': 1}));

      expect(await controller.readConfig(7), {'port': 1});
    });

    test('readConfig is empty when the Core returns no config', () async {
      when(
        () => api.readConfig(any()),
      ).thenAnswer((_) async => const ConfigReadOutput());

      expect(await controller.readConfig(7), isEmpty);
    });

    test('getProfileOutbounds lists names and types', () async {
      final path = await profilePath(7);
      when(() => api.profileOutbounds(path)).thenAnswer(
        (_) async => const ProfileOutbounds(
          proxies: [OutboundRef(name: 'a', type: 'ss')],
          proxyGroups: [OutboundRef(name: 'G', type: 'select')],
        ),
      );

      expect(await controller.getProfileOutbounds(7), {
        'proxies': [
          {'name': 'a', 'type': 'ss'},
        ],
        'proxy-groups': [
          {'name': 'G', 'type': 'select'},
        ],
      });
    });

    test('buildProfile returns the text the Core built', () async {
      const base = SetupBase(path: '/p.yaml', overlay: {'mode': 'global'});
      when(
        () => api.buildProfile('/p.yaml', {'mode': 'global'}),
      ).thenAnswer((_) async => const TextOutput(text: 'mode: global'));

      expect(await controller.buildProfile(base), 'mode: global');
    });

    test('buildProfile is empty when the Core returns no text', () async {
      when(
        () => api.buildProfile(any(), any()),
      ).thenAnswer((_) async => const TextOutput());

      expect(
        await controller.buildProfile(
          const SetupBase(path: '/p.yaml', overlay: {}),
        ),
        isEmpty,
      );
    });

    test('getProfileBase drops the rules from the config', () async {
      final path = await profilePath(7);
      when(() => api.inspectProfile(path)).thenAnswer(
        (_) async => const ProfileInspect(
          config: {
            'port': 1,
            'rule': ['MATCH,DIRECT'],
          },
          digest: 'd',
          matchRules: ['MATCH,DIRECT'],
          proxies: 2,
          proxyGroups: 1,
          rules: 3,
        ),
      );

      final result = await controller.getProfileBase(7);

      expect(result.path, path);
      expect(result.base.config, {'port': 1});
      expect(result.base.digest, 'd');
      expect(result.base.proxies, 2);
      expect(result.base.proxyGroups, 1);
      expect(result.base.rules, 3);
    });
  });

  group('getProxiesGroups', () {
    test('builds the groups the Core lists', () async {
      when(() => api.proxyGroups()).thenAnswer(
        (_) async => const ProxyGroupsDto(
          order: ['G'],
          groups: [
            GroupInfo(
              name: 'G',
              type: 'Selector',
              now: 'a',
              all: ['a'],
              testUrl: '',
              hidden: false,
              icon: '',
              emptyFallback: '',
            ),
          ],
          nodes: [NodeInfo(name: 'a', type: 'ss')],
        ),
      );

      final groups = await controller.getProxiesGroups(
        sortType: ProxiesSortType.none,
        delayMap: const {},
        selectedMap: const {},
        defaultTestUrl: 'http://t',
      );

      expect(groups.map((group) => group.name), ['G']);
      expect(groups.single.now, 'a');
      expect(groups.single.all.map((proxy) => proxy.name), ['a']);
    });

    test('keeps a smart group', () async {
      when(() => api.proxyGroups()).thenAnswer(
        (_) async => const ProxyGroupsDto(
          order: ['S'],
          groups: [
            GroupInfo(
              name: 'S',
              type: 'Smart',
              now: 'a',
              all: ['a'],
              testUrl: '',
              hidden: false,
              icon: '',
              emptyFallback: '',
            ),
          ],
          nodes: [NodeInfo(name: 'a', type: 'ss')],
        ),
      );

      final groups = await controller.getProxiesGroups(
        sortType: ProxiesSortType.none,
        delayMap: const {},
        selectedMap: const {},
        defaultTestUrl: 'http://t',
      );

      expect(groups.single.type, GroupType.Smart);
    });

    test('is empty when the Core lists no groups', () async {
      when(
        () => api.proxyGroups(),
      ).thenAnswer((_) async => const ProxyGroupsDto());

      expect(
        await controller.getProxiesGroups(
          sortType: ProxiesSortType.none,
          delayMap: const {},
          selectedMap: const {},
          defaultTestUrl: 'http://t',
        ),
        isEmpty,
      );
    });
  });

  group('model views of the API', () {
    test('a route check is read as the stamp and sent as its hits', () {
      final check = routeCheckOf(
        const RouteCheckResult(
          stamp: RouteStampDto(epoch: 3, version: 2),
          held: [true],
        ),
      );
      final hit = routeHitDtoOf(
        const RouteHit(host: 'example.com:443', exit: 'HK-01'),
      );

      expect(check.coreEpoch, 3);
      expect(check.routeVersion, 2);
      expect(check.held, [true]);
      expect(hit.host, 'example.com:443');
      expect(hit.exit, 'HK-01');
    });

    test('getExternalProviders maps the providers', () async {
      when(() => api.providers()).thenAnswer(
        (_) async => const [
          ProviderInfo(
            name: 'provider1',
            type: ProviderKindDto.proxy,
            vehicleType: 'HTTP',
            count: 5,
            path: 'p.yaml',
          ),
        ],
      );

      final result = await api.getExternalProviders();

      expect(result.length, 1);
      expect(result.first.name, 'provider1');
      expect(result.first.type, 'Proxy');
      expect(result.first.count, 5);
    });

    test('getExternalProviders handles an empty list', () async {
      when(() => api.providers()).thenAnswer((_) async => const []);

      expect(await api.getExternalProviders(), isEmpty);
    });

    test('getExternalProvider returns null when missing', () async {
      when(() => api.provider(any())).thenAnswer((_) async => null);

      expect(await api.getExternalProvider('test'), isNull);
    });

    test('getMemoryStats reads the resident size', () async {
      when(
        () => api.stats(),
      ).thenAnswer((_) async => const CoreStats(rss: 2048));

      expect((await api.getMemoryStats()).rss, 2048);
    });

    test('a delay result is read as a delay', () {
      final delay = delayOf(
        const DelayResult(name: 'P1', url: 'test.com', value: 100),
      );

      expect(delay.name, 'P1');
      expect(delay.value, 100);
    });
  });
}
