import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

// checkAndUpdateAndCopy checks the file system before it refreshes, so its
// failure tests need appPath to resolve to a real, writable directory.
class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

class _ListenerHandoffFailureSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];

  @override
  Future<bool> setCoreRunning(bool running) async {
    coreRunningCalls.add(running);
    if (running) {
      throw StateError('listener handoff failed');
    }
    return true;
  }
}

class _MessageFailureSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];

  @override
  Future<bool> setCoreRunning(bool running) async {
    coreRunningCalls.add(running);
    return true;
  }
}

class TestCommonAction extends CommonAction {
  int trafficUpdates = 0;

  @override
  Future<void> updateTraffic() async {
    trafficUpdates++;
  }
}

class TestSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];
  final List<Completer<void>> pendingCoreCalls = [];
  int trafficResets = 0;
  int applyProfileCalls = 0;
  bool blockCoreCalls = false;
  Error? coreRunningError;
  int authorizeCalls = 0;
  AuthorizeCode authorizeResult = AuthorizeCode.none;

  @override
  Future<AuthorizeCode> authorizeCore() async {
    authorizeCalls++;
    return authorizeResult;
  }

  @override
  Future<bool> setCoreRunning(bool running) async {
    coreRunningCalls.add(running);
    if (blockCoreCalls) {
      final gate = Completer<void>();
      pendingCoreCalls.add(gate);
      await gate.future;
    }
    final error = coreRunningError;
    if (error != null) {
      throw error;
    }
    return true;
  }

  @override
  void resetCoreTraffic() => trafficResets++;

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applyProfileCalls++;
    await preloadInvoke?.call();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(const SetupParams(selectedMap: {}, testUrl: ''));
  });

  late TestSetupAction action;
  late ProviderContainer container;

  setUp(() {
    action = TestSetupAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        setupActionProvider.overrideWith(() => action),
        commonActionProvider.overrideWith(TestCommonAction.new),
      ],
    );
    globalState.container = container;
    globalState.needInitStatus = true;
    container.read(setupActionProvider.notifier);
  });

  tearDown(() async {
    action.blockCoreCalls = false;
    action.coreRunningError = null;
    for (final gate in action.pendingCoreCalls) {
      if (!gate.isCompleted) {
        gate.complete();
      }
    }
    await container.read(setupActionProvider.notifier).setRunning(false);
    container.dispose();
    globalState.needInitStatus = true;
  });

  void markInitialized() {
    container.read(initProvider.notifier).value = true;
  }

  group('setRunning gating', () {
    test('ignores a start request before initialization completes', () async {
      await container.read(setupActionProvider.notifier).setRunning(true);

      expect(action.coreRunningCalls, isEmpty);
      expect(container.read(runTimeProvider), isNull);
    });

    test('an initialize request bypasses the init gate', () async {
      await container
          .read(setupActionProvider.notifier)
          .setRunning(true, initialize: true);

      expect(action.coreRunningCalls, [true]);
      expect(action.applyProfileCalls, 1);
      expect(globalState.needInitStatus, isFalse);
    });

    test('starts the core once initialization is done', () async {
      markInitialized();

      await container.read(setupActionProvider.notifier).setRunning(true);

      expect(action.coreRunningCalls, [true]);
      expect(container.read(runTimeProvider), isNotNull);
    });

    test('a stop request is never gated on initialization', () async {
      await container.read(setupActionProvider.notifier).setRunning(false);

      expect(action.coreRunningCalls, [false]);
    });
  });

  group('run failures', () {
    test('a start the core rejects stops reporting a run time', () async {
      markInitialized();
      action.coreRunningError = StateError('start failed');

      await expectLater(
        container.read(setupActionProvider.notifier).setRunning(true),
        throwsStateError,
      );

      expect(container.read(runTimeProvider), isNull);
    });

    test(
      'a stop the core rejects keeps the run time it started with',
      () async {
        markInitialized();
        await container.read(setupActionProvider.notifier).setRunning(true);
        action.coreRunningError = StateError('stop failed');

        await expectLater(
          container.read(setupActionProvider.notifier).setRunning(false),
          throwsStateError,
        );

        expect(container.read(runTimeProvider), isNotNull);
      },
    );
  });

  group('stop cleanup', () {
    test('resets traffic counters and re-checks the ip', () async {
      markInitialized();
      await container.read(setupActionProvider.notifier).setRunning(true);
      container.read(totalTrafficProvider.notifier).value = const Traffic(
        up: 10,
        down: 20,
      );
      final checkIpBefore = container.read(checkIpNumProvider);

      await container.read(setupActionProvider.notifier).setRunning(false);

      expect(action.trafficResets, 1);
      expect(container.read(trafficsProvider).list, isEmpty);
      expect(container.read(totalTrafficProvider), const Traffic());
      expect(container.read(checkIpNumProvider), checkIpBefore + 1);
      expect(container.read(runTimeProvider), isNull);
    });
  });

  group('suspend', () {
    test('skips starting the core on an excluded SSID', () async {
      container.dispose();
      action = TestSetupAction();
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => action),
          commonActionProvider.overrideWith(TestCommonAction.new),
          excludeSSIDsProvider.overrideWithValue(const ['Office Wi-Fi']),
        ],
      );
      globalState.container = container;
      container.read(initProvider.notifier).value = true;
      container.read(currentSSIDProvider.notifier).value = 'Office Wi-Fi';

      await container.read(setupActionProvider.notifier).setRunning(true);

      expect(action.coreRunningCalls, isEmpty);
    });

    test('still stops the core on an excluded SSID', () async {
      container.dispose();
      action = TestSetupAction();
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => action),
          commonActionProvider.overrideWith(TestCommonAction.new),
          excludeSSIDsProvider.overrideWithValue(const ['Office Wi-Fi']),
        ],
      );
      globalState.container = container;
      container.read(currentSSIDProvider.notifier).value = 'Office Wi-Fi';

      await container.read(setupActionProvider.notifier).setRunning(false);

      expect(action.coreRunningCalls, [false]);
    });
  });

  group('latest-intent arbitration', () {
    test('a superseded stop does not run the post-stop cleanup', () async {
      markInitialized();
      final notifier = container.read(setupActionProvider.notifier);
      action.blockCoreCalls = true;

      final stopping = notifier.setRunning(false);
      await Future<void>.delayed(Duration.zero);
      final starting = notifier.setRunning(true);
      await Future<void>.delayed(Duration.zero);

      action.blockCoreCalls = false;
      for (final gate in action.pendingCoreCalls) {
        if (!gate.isCompleted) {
          gate.complete();
        }
      }
      await Future.wait([stopping, starting]);

      expect(action.coreRunningCalls, [false, true]);
      expect(action.trafficResets, 0);
      expect(container.read(runTimeProvider), isNotNull);
    });

    test('the newest request wins the local running state', () async {
      markInitialized();
      final notifier = container.read(setupActionProvider.notifier);

      await notifier.setRunning(true);
      expect(container.read(runTimeProvider), isNotNull);

      await notifier.setRunning(false);
      expect(container.read(runTimeProvider), isNull);

      await notifier.setRunning(true);
      expect(container.read(runTimeProvider), isNotNull);
      expect(action.coreRunningCalls, [true, false, true]);
    });
  });

  group('initStatus', () {
    test('is a no-op once the status has already been initialized', () async {
      globalState.needInitStatus = false;

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, isEmpty);
      expect(action.applyProfileCalls, 0);
    });

    test('starts the core when autoRun is enabled', () async {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        autoRun: true,
      );

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, [true]);
      expect(globalState.needInitStatus, isFalse);
    });

    test('only applies the profile when autoRun is disabled', () async {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        autoRun: false,
      );

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, isEmpty);
      expect(action.applyProfileCalls, 1);
    });
  });

  group('requestAdmin', () {
    test('never asks for authorization while tun is disabled', () async {
      expect(await action.requestAdmin(false), isTrue);

      expect(action.authorizeCalls, 0);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
    });

    test('does not ask again once the state left none', () async {
      container.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.authorized;

      expect(await action.requestAdmin(true), isTrue);
      expect(action.authorizeCalls, 0);
    });

    test(
      'a successful authorization hands off instead of continuing',
      () async {
        action.authorizeResult = AuthorizeCode.success;

        expect(await action.requestAdmin(true), isFalse);
        expect(action.authorizeCalls, 1);
        expect(
          container.read(authorizedTunEnableProvider),
          TunAuthorizationState.authorized,
        );
      },
    );

    test('a platform without an authorization step continues inline', () async {
      action.authorizeResult = AuthorizeCode.none;

      expect(await action.requestAdmin(true), isTrue);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.authorized,
      );
    });

    test('a failed authorization continues but stays unauthorized', () async {
      action.authorizeResult = AuthorizeCode.error;

      expect(await action.requestAdmin(true), isTrue);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.unauthorized,
      );
    });
  });

  group('recoverMissingProfile', () {
    ProviderContainer buildScoped(List<Profile> profiles, int? profileId) {
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles(profiles)),
          currentProfileIdProvider.overrideWithBuild((_, _) => profileId),
          setupActionProvider.overrideWith(TestSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      return scoped;
    }

    test('a dangling profile id falls back to the first profile', () {
      final profile = Profile.normal(label: 'p').copyWith(id: 1);
      final scoped = buildScoped([profile], 404);

      final recovered = scoped
          .read(setupActionProvider.notifier)
          .recoverMissingProfile();

      expect(recovered?.id, profile.id);
      expect(scoped.read(currentProfileIdProvider), profile.id);
    });

    test('no profiles keeps the stored id untouched', () {
      final scoped = buildScoped(const [], 404);

      expect(
        scoped.read(setupActionProvider.notifier).recoverMissingProfile(),
        isNull,
      );
      expect(scoped.read(currentProfileIdProvider), 404);
    });

    test('an unset id is the first-run state, not a dangling one', () {
      final profile = Profile.normal(label: 'p').copyWith(id: 1);
      final scoped = buildScoped([profile], null);

      expect(
        scoped.read(setupActionProvider.notifier).recoverMissingProfile(),
        isNull,
      );
      expect(scoped.read(currentProfileIdProvider), isNull);
    });
  });

  group('changeMode', () {
    test('records the requested mode', () {
      container.read(setupActionProvider.notifier).changeMode(Mode.direct);

      expect(container.read(patchClashConfigProvider).mode, Mode.direct);
    });

    test('leaving global alone keeps the selected group', () {
      final profile = Profile.normal(
        label: 'p',
      ).copyWith(id: 1, currentGroupName: 'Manual');
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupActionProvider.overrideWith(TestSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      scoped.read(setupActionProvider.notifier).changeMode(Mode.rule);

      expect(scoped.read(currentProfileProvider)?.currentGroupName, 'Manual');
    });

    test('global mode also selects the global group', () {
      final profile = Profile.normal(
        label: 'p',
      ).copyWith(id: 1, currentGroupName: 'Manual');
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupActionProvider.overrideWith(TestSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      scoped.read(setupActionProvider.notifier).changeMode(Mode.global);

      expect(scoped.read(patchClashConfigProvider).mode, Mode.global);
      expect(
        scoped.read(currentProfileProvider)?.currentGroupName,
        GroupName.GLOBAL.name,
      );
    });
  });

  group('applyProfileDebounce', () {
    test('collapses a burst into a single apply', () async {
      final notifier = container.read(setupActionProvider.notifier);

      notifier.applyProfileDebounce(force: true);
      notifier.applyProfileDebounce(force: true);
      notifier.applyProfileDebounce(force: true);
      expect(action.applyProfileCalls, 0);

      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(action.applyProfileCalls, 1);
    });

    test('a stop cancels a pending apply', () async {
      markInitialized();
      final notifier = container.read(setupActionProvider.notifier);

      notifier.applyProfileDebounce(force: true);
      await notifier.setRunning(false);

      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(action.applyProfileCalls, 0);
    });
  });

  group('_setupConfig via the real SetupAction', () {
    late Directory tempDir;
    late String? originalLastConfigMd5;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('setup_action_test');
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
      await AppLocalizations.load(const Locale('en'));
      originalLastConfigMd5 = globalState.lastConfigMd5;
    });

    tearDownAll(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    tearDown(() {
      globalState.lastConfigMd5 = originalLastConfigMd5;
    });

    // profileId: null routes getProfile/setupState around the database and
    // Core.getConfig, isolating the behavior under test.
    const nullProfileSetupState = SetupState(
      profileId: null,
      profileLastUpdateDate: null,
      overwriteType: OverwriteType.standard,
      rules: [],
      proxyGroups: [],
      addedRules: [],
      script: null,
      overrideDns: false,
      dns: Dns(),
    );

    test(
      'a refresh failure still runs core.setupConfig and preloadInvoke',
      () async {
        final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
        final core = _MockCoreHandlerInterface();
        when(() => core.setupConfig(any())).thenAnswer((_) async => '');
        var preloadRan = false;
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(
              force: true,
              preloadInvoke: () async {
                preloadRan = true;
              },
            );

        expect(preloadRan, isTrue);
        verify(() => core.setupConfig(any())).called(1);
      },
    );

    test(
      'a profile that fails to build still pushes the empty config to core',
      () async {
        final profile = Profile.normal(label: 'p');
        final core = _MockCoreHandlerInterface();
        when(() => core.getConfig(any())).thenThrow(Exception('broken yaml'));
        String? pushedConfig;
        when(() => core.setupConfig(any())).thenAnswer((_) async {
          pushedConfig = await File(
            await appPath.configFilePath,
          ).readAsString();
          return '';
        });
        globalState.packageInfo = PackageInfo(
          appName: 'FlClash',
          packageName: 'com.follow.clash',
          version: '0.0.0',
          buildNumber: '0',
        );
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith(
              (_, profileId) =>
                  nullProfileSetupState.copyWith(profileId: profileId),
            ),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        final succeeded = await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);

        expect(succeeded, isFalse);
        expect(pushedConfig, isEmpty);
        expect(scoped.read(currentProfileIdProvider), profile.id);
      },
    );

    test(
      'a config write failure reports setup as failed without calling core',
      () async {
        final configPath = await appPath.configFilePath;
        final configFile = File(configPath);
        if (await configFile.exists()) {
          await configFile.delete();
        }
        final configAsDirectory = Directory(configPath);
        await configAsDirectory.create(recursive: true);

        final core = _MockCoreHandlerInterface();
        when(() => core.setupConfig(any())).thenAnswer((_) async => '');
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        try {
          final succeeded = await scoped
              .read(setupActionProvider.notifier)
              .applyProfile(force: true);

          expect(succeeded, isFalse);
          verifyNever(() => core.setupConfig(any()));
        } finally {
          await configAsDirectory.delete(recursive: true);
        }
      },
    );

    test(
      'a rejected setupConfig without a handoff reports failure, not success',
      () async {
        final core = _MockCoreHandlerInterface();
        when(() => core.setupConfig(any())).thenThrow(StateError('rejected'));
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        final succeeded = await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);

        expect(succeeded, isFalse);
        verify(() => core.setupConfig(any())).called(1);
      },
    );

    test(
      'a listener handoff failure during initialize rolls back running',
      () async {
        final core = _MockCoreHandlerInterface();
        when(() => core.setupConfig(any())).thenAnswer((_) async => '');
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(
              _ListenerHandoffFailureSetupAction.new,
            ),
          ],
        );
        addTearDown(scoped.dispose);
        final handoffAction =
            scoped.read(setupActionProvider.notifier)
                as _ListenerHandoffFailureSetupAction;

        await handoffAction.setRunning(true, initialize: true);

        expect(handoffAction.coreRunningCalls, [true, false]);
        expect(scoped.read(runTimeProvider), isNull);
        verify(() => core.setupConfig(any())).called(1);
      },
    );

    test(
      'a non-empty setupConfig message during initialize rolls back running',
      () async {
        final core = _MockCoreHandlerInterface();
        when(
          () => core.setupConfig(any()),
        ).thenAnswer((_) async => 'config rejected');
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            setupActionProvider.overrideWith(_MessageFailureSetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);
        final messageAction =
            scoped.read(setupActionProvider.notifier)
                as _MessageFailureSetupAction;

        await messageAction.setRunning(true, initialize: true);

        expect(messageAction.coreRunningCalls, [true, false]);
        expect(scoped.read(runTimeProvider), isNull);
        verify(() => core.setupConfig(any())).called(1);
      },
    );
  });
}
