import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';

import '../helpers/app_paths.dart';
import '../helpers/core_mocks.dart';
import '../helpers/preferences.dart';
import '../helpers/test_profiles.dart';

// checkAndUpdateAndCopy checks the file system before it refreshes, so its
// failure tests need appPath to resolve to a real, writable directory.
class _ListenerHandoffFailureSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];

  @override
  Future<void> setCoreRunning(bool running) async {
    coreRunningCalls.add(running);
    if (running) {
      throw StateError('listener handoff failed');
    }
  }
}

class _MessageFailureSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];

  @override
  Future<void> setCoreRunning(bool running) async {
    coreRunningCalls.add(running);
  }
}

class _UnflooredDebounceSetupAction extends SetupAction {
  @override
  Duration get minApplyDebounce => Duration.zero;
}

class _CappedDebounceSetupAction extends _UnflooredDebounceSetupAction {
  @override
  Duration get maxApplyDebounce => const Duration(milliseconds: 300);
}

class TestCommonAction extends CommonAction {
  bool trafficFeed = false;

  @override
  void setTrafficFeed(bool wanted) {
    trafficFeed = wanted;
  }
}

class TestSetupAction extends SetupAction {
  final List<bool> coreRunningCalls = [];
  final List<Completer<void>> pendingCoreCalls = [];
  int trafficResets = 0;
  int applyProfileCalls = 0;
  final List<bool> appliedForce = [];
  Completer<void>? profileGate;
  bool blockCoreCalls = false;
  Error? coreRunningError;
  Exception? coreRunningException;
  Error? applyError;
  final Set<bool> unansweredCoreCalls = {};
  int authorizeCalls = 0;
  AuthorizeCode authorizeResult = AuthorizeCode.none;
  bool desktop = true;
  DateTime? serviceStart;
  Completer<DateTime?>? serviceRead;

  @override
  bool get tunNeedsAuthorization => desktop;

  @override
  Future<DateTime?> serviceStartTime() =>
      serviceRead?.future ?? Future.value(serviceStart);

  @override
  Duration get minApplyDebounce => const Duration(milliseconds: 100);

  @override
  Future<AuthorizeCode> authorizeCore() async {
    authorizeCalls++;
    return authorizeResult;
  }

  @override
  Future<void> setCoreRunning(bool running) async {
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
    final exception = coreRunningException;
    if (exception != null) {
      throw exception;
    }
    if (unansweredCoreCalls.contains(running)) {
      throw const CoreMethodException(code: 'core_unavailable', message: '');
    }
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
    appliedForce.add(force);
    if (profileGate case final gate?) {
      await gate.future;
    }
    if (applyError case final error?) {
      throw error;
    }
    await preloadInvoke?.call();
    return true;
  }
}

class _PortRepairSetupAction extends SetupAction {
  int repairs = 0;

  @override
  Future<void> updateConfigDebounce() async => repairs++;
}

Future<List<WarningInfo>> _applied(MockCoreApi api) => api.applyConfig(
  profilePath: any(named: 'profilePath'),
  overlay: any(named: 'overlay'),
  selection: any(named: 'selection'),
  options: any(named: 'options'),
  host: any(named: 'host'),
);

ProfileInspect _inspected({
  String digest = 'd',
  Map<String, dynamic> config = const {},
  List<String> matchRules = const [],
  int proxies = 0,
  int proxyGroups = 0,
  int rules = 0,
}) => ProfileInspect(
  config: config,
  digest: digest,
  matchRules: matchRules,
  proxies: proxies,
  proxyGroups: proxyGroups,
  rules: rules,
);

GroupInfo _groupInfo(
  String name, {
  String type = 'Selector',
  bool hidden = false,
  List<String> all = const [],
}) => GroupInfo(
  name: name,
  type: type,
  all: all,
  testUrl: '',
  hidden: hidden,
  icon: '',
  emptyFallback: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(const CoreOptionsArg(testUrl: ''));
    registerFallbackValue(const ConfigPatch());
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
    container.read(setupActionProvider.notifier);
  });

  tearDown(() async {
    action.blockCoreCalls = false;
    action.coreRunningError = null;
    action.coreRunningException = null;
    action.unansweredCoreCalls.clear();
    for (final gate in action.pendingCoreCalls) {
      if (!gate.isCompleted) {
        gate.complete();
      }
    }
    await container.read(setupActionProvider.notifier).setRunning(false);
    container.dispose();
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
    });

    test('safe mode runs the profile but never touches the listener', () async {
      final scopedAction = TestSetupAction();
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          commonActionProvider.overrideWith(TestCommonAction.new),
          safeModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(scoped.dispose);
      globalState.container = scoped;
      scoped.read(setupActionProvider.notifier);

      await scoped
          .read(setupActionProvider.notifier)
          .setRunning(true, initialize: true);

      expect(scopedAction.coreRunningCalls, isEmpty);
      expect(scopedAction.applyProfileCalls, 1);
      expect(scoped.read(isStartProvider), isTrue);

      await scoped.read(setupActionProvider.notifier).setRunning(false);

      expect(scopedAction.coreRunningCalls, isEmpty);
      expect(scoped.read(isStartProvider), isFalse);
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

    final unanswered = isA<CoreMethodException>().having(
      (error) => error.code,
      'code',
      'core_unavailable',
    );

    test('a start the core leaves unanswered fails and is undone', () async {
      markInitialized();
      action.unansweredCoreCalls.add(true);

      await expectLater(
        container.read(setupActionProvider.notifier).setRunning(true),
        throwsA(unanswered),
      );

      expect(container.read(isStartProvider), isFalse);
      expect(container.read(runTimeProvider), isNull);
      expect(container.read(runningVpnOptionsProvider), isNull);
    });

    test('a stop the core leaves unanswered fails but stays stopped', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);
      action.unansweredCoreCalls.add(false);

      await expectLater(setup.setRunning(false), throwsA(unanswered));

      expect(container.read(isStartProvider), isFalse);
      expect(container.read(runTimeProvider), isNull);
      expect(container.read(runningVpnOptionsProvider), isNull);
      expect(action.trafficResets, 1);
    });

    test('a stop whose answer the transport drops stays stopped, and the '
        'lost session after it brings nothing back', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);
      action.coreRunningException = const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core transport disconnected',
      );

      await expectLater(
        setup.setRunning(false),
        throwsA(isA<CoreMethodException>()),
      );
      setup.onCoreLost();

      expect(container.read(isStartProvider), isFalse);
      expect(container.read(runTimeProvider), isNull);
      expect(setup.wantsRunning, isFalse);
    });

    test(
      'an initial start the core leaves unanswered is stopped again',
      () async {
        action.unansweredCoreCalls.add(true);

        final applied = await container
            .read(setupActionProvider.notifier)
            .setRunning(true, initialize: true);

        expect(applied, isFalse);
        expect(action.coreRunningCalls, [true, false]);
        expect(container.read(isStartProvider), isFalse);
        expect(container.read(runningVpnOptionsProvider), isNull);
      },
    );

    test('an initial start that fails says why as it turns back', () async {
      loadAppLocalizations(const Locale('en'));
      final banners = <String>[];
      final print = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        const prefix = '[APP] banner: ';
        if (message != null && message.startsWith(prefix)) {
          banners.add(message.substring(prefix.length));
        }
      };
      addTearDown(() => debugPrint = print);
      action.applyError = StateError('authorization helper failed');

      final applied = await container
          .read(setupActionProvider.notifier)
          .setRunning(true, initialize: true);

      expect(applied, isFalse);
      expect(container.read(isStartProvider), isFalse);
      expect(banners, ['Bad state: authorization helper failed']);
    });
  });

  group('stop cleanup', () {
    test('resets traffic counters', () async {
      markInitialized();
      await container.read(setupActionProvider.notifier).setRunning(true);
      container.read(totalTrafficProvider.notifier).value = const Traffic(
        up: 10,
        down: 20,
      );

      await container.read(setupActionProvider.notifier).setRunning(false);

      expect(action.trafficResets, 1);
      expect(container.read(trafficsProvider).list, isEmpty);
      expect(container.read(totalTrafficProvider), const Traffic());
      expect(container.read(runTimeProvider), isNull);
    });
  });

  group('run time ticker', () {
    late ProviderContainer scoped;

    // Built inside each test, on its fake clock: futures made there never
    // settle in the shared tearDown.
    SetupAction buildScoped() {
      scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(TestSetupAction.new),
          commonActionProvider.overrideWith(TestCommonAction.new),
          // Bypassing private addresses computes the routes in Isolate.run, which
          // the fake clock never lets finish.
          networkSettingProvider.overrideWithBuild(
            (_, _) => const NetworkProps(bypassPrivateRoute: false),
          ),
        ],
      );
      addTearDown(scoped.dispose);
      globalState.container = scoped;
      scoped
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(showTrayTitle: false));
      scoped.read(initProvider.notifier).value = true;
      return scoped.read(setupActionProvider.notifier);
    }

    bool trafficFeed() =>
        (scoped.read(commonActionProvider.notifier) as TestCommonAction)
            .trafficFeed;

    int? runTime() => scoped.read(runTimeProvider);

    void setVisible(bool visible) =>
        scoped.read(appVisibleProvider.notifier).value = visible;

    testWidgets('feeds traffic only while the app is visible', (tester) async {
      final setup = buildScoped();
      await setup.setRunning(true);
      expect(trafficFeed(), isTrue);

      final started = runTime()!;
      await tester.pump(const Duration(seconds: 2));
      expect(runTime(), greaterThan(started));

      setVisible(false);
      expect(trafficFeed(), isFalse);
      final hiddenAt = runTime();
      await tester.pump(const Duration(seconds: 5));
      expect(runTime(), hiddenAt);
      expect(scoped.read(isStartProvider), isTrue);

      setVisible(true);
      await tester.pump();
      expect(trafficFeed(), isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(runTime(), greaterThan(hiddenAt!));

      await setup.setRunning(false);
      expect(trafficFeed(), isFalse);
    });

    testWidgets('a lost Core session stops the clock for good', (tester) async {
      final setup = buildScoped();
      await setup.setRunning(true);
      await tester.pump(const Duration(seconds: 2));

      setup.onCoreLost();
      await tester.pump(const Duration(seconds: 3));

      expect(runTime(), isNull);
      expect(trafficFeed(), isFalse);
      expect(scoped.read(isStartProvider), isFalse);
    });

    testWidgets('a start while hidden waits for the app to be shown', (
      tester,
    ) async {
      final setup = buildScoped();
      setVisible(false);
      await setup.setRunning(true);
      await tester.pump(const Duration(seconds: 3));

      expect(scoped.read(runTimeProvider), isNotNull);
      expect(trafficFeed(), isFalse);

      setVisible(true);
      await tester.pump();
      expect(trafficFeed(), isTrue);

      await setup.setRunning(false);
    });

    testWidgets('the macOS menu bar title keeps traffic coming while hidden', (
      tester,
    ) async {
      final setup = buildScoped();
      setVisible(false);
      await setup.setRunning(true);
      await tester.pump(const Duration(seconds: 2));
      expect(trafficFeed(), isFalse);

      scoped
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(showTrayTitle: true));
      await tester.pump(const Duration(seconds: 2));

      expect(trafficFeed(), system.isMacOS);

      await setup.setRunning(false);
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
      expect(container.read(runningVpnOptionsProvider), isNull);
    });

    test('an excluded SSID parks a run and leaving it resumes', () async {
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
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);
      action.coreRunningCalls.clear();

      container.read(currentSSIDProvider.notifier).value = 'Office Wi-Fi';
      setup.syncSuspend();
      await Future<void>.delayed(const Duration(milliseconds: 700));

      expect(action.coreRunningCalls, [false]);
      expect(container.read(isStartProvider), isTrue);
      expect(container.read(runningVpnOptionsProvider), isNull);

      container.read(currentSSIDProvider.notifier).value = 'Home';
      setup.syncSuspend();
      await Future<void>.delayed(const Duration(milliseconds: 700));

      expect(action.coreRunningCalls, [false, true]);
      expect(
        container.read(runningVpnOptionsProvider),
        await container.read(vpnOptionsProvider.future),
      );
    });

    test('an SSID change leaves a stopped run alone', () async {
      markInitialized();
      container.read(setupActionProvider.notifier).syncSuspend();
      await Future<void>.delayed(const Duration(milliseconds: 700));

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

  group('running vpn options', () {
    test('a start keeps what the service starts with until a stop', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      final started = await container.read(vpnOptionsProvider.future);

      await setup.setRunning(true);
      container
          .read(vpnSettingProvider.notifier)
          .update((state) => state.copyWith(ipv6: !state.ipv6));

      expect(container.read(runningVpnOptionsProvider), started);

      await setup.setRunning(false);

      expect(container.read(runningVpnOptionsProvider), isNull);
    });

    test('a start the core rejects keeps nothing', () async {
      markInitialized();
      action.coreRunningError = StateError('listener refused');

      await expectLater(
        container.read(setupActionProvider.notifier).setRunning(true),
        throwsStateError,
      );

      expect(container.read(runningVpnOptionsProvider), isNull);
    });

    test('a restart stops and starts with the current options', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);
      container
          .read(vpnSettingProvider.notifier)
          .update((state) => state.copyWith(ipv6: !state.ipv6));

      await setup.restartVpn();

      expect(action.coreRunningCalls, [true, false, true]);
      expect(container.read(isStartProvider), isTrue);
      expect(
        container.read(runningVpnOptionsProvider),
        await container.read(vpnOptionsProvider.future),
      );
    });

    test('a restart never starts a stopped run', () async {
      markInitialized();

      await container.read(setupActionProvider.notifier).restartVpn();

      expect(action.coreRunningCalls, isEmpty);
      expect(container.read(isStartProvider), isFalse);
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

    test(
      'a superseded start the core leaves unanswered does not fail',
      () async {
        markInitialized();
        final notifier = container.read(setupActionProvider.notifier);
        action.blockCoreCalls = true;
        action.unansweredCoreCalls.add(true);

        final starting = notifier.setRunning(true);
        await Future<void>.delayed(Duration.zero);
        final stopping = notifier.setRunning(false);
        await Future<void>.delayed(Duration.zero);

        action.blockCoreCalls = false;
        for (final gate in action.pendingCoreCalls) {
          if (!gate.isCompleted) {
            gate.complete();
          }
        }

        expect(await Future.wait([starting, stopping]), [true, true]);
        expect(action.coreRunningCalls, [true, false]);
        expect(container.read(isStartProvider), isFalse);
      },
    );

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

  group('a general change the Core reports', () {
    late _PortRepairSetupAction repairing;
    late ProviderContainer scoped;

    setUp(() {
      loadAppLocalizations(const Locale('en'));
      repairing = _PortRepairSetupAction();
      scoped = ProviderContainer(
        overrides: [setupActionProvider.overrideWith(() => repairing)],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mixedPort: 7899));
    });

    test('keeps the mixed port over a 0, takes the rest, and repairs the Core '
        'once', () {
      final banners = <String>[];
      final print = debugPrint;
      debugPrint = (message, {wrapWidth}) => banners.add(message ?? '');
      addTearDown(() => debugPrint = print);

      repairing.adoptCoreGeneral(
        const GeneralChange(mixedPort: 0, allowLan: true),
      );

      final config = scoped.read(patchClashConfigProvider);
      expect(config.mixedPort, 7899);
      expect(config.allowLan, isTrue);
      expect(repairing.repairs, 1);
      expect(
        banners,
        contains(
          '[APP] banner: The mixed port cannot be 0, so it was set back to 7899',
        ),
      );
    });

    test('takes a usable mixed port without a repair', () {
      repairing.adoptCoreGeneral(const GeneralChange(mixedPort: 7900));

      expect(scoped.read(patchClashConfigProvider).mixedPort, 7900);
      expect(repairing.repairs, 0);
    });

    test('reads a find process mode the app does not offer as strict', () {
      FindProcessMode adopted(String? mode) {
        repairing.adoptCoreGeneral(GeneralChange(findProcessMode: mode));
        return scoped.read(patchClashConfigProvider).findProcessMode;
      }

      expect(adopted('always'), FindProcessMode.always);
      expect(adopted(null), FindProcessMode.always);
      expect(adopted('off'), FindProcessMode.strict);
      expect(adopted('always'), FindProcessMode.always);
      expect(adopted('strict'), FindProcessMode.strict);
    });
  });

  group('a lost Core session', () {
    test('ends the run here without a stop and keeps it to resume', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);

      setup.onCoreLost();

      expect(action.coreRunningCalls, [true]);
      expect(container.read(isStartProvider), isFalse);
      expect(container.read(runTimeProvider), isNull);
      expect(container.read(runningVpnOptionsProvider), isNull);
      expect(setup.wantsRunning, isTrue);
    });

    test('a start it cut off cannot bring the run back', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      action.blockCoreCalls = true;
      action.unansweredCoreCalls.add(true);

      final starting = setup.setRunning(true);
      while (action.pendingCoreCalls.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }
      setup.onCoreLost();
      action.pendingCoreCalls.single.complete();

      expect(await starting, isTrue);
      expect(container.read(isStartProvider), isFalse);
      expect(container.read(runningVpnOptionsProvider), isNull);
      expect(setup.wantsRunning, isTrue);
    });

    test('a later stop is the run a restart keeps', () async {
      markInitialized();
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true);
      setup.onCoreLost();

      await setup.setRunning(false);

      expect(setup.wantsRunning, isFalse);
    });

    test('leaves nothing to resume when no run was on', () {
      final setup = container.read(setupActionProvider.notifier);

      setup.onCoreLost();

      expect(setup.wantsRunning, isFalse);
    });
  });

  group('initStatus', () {
    test('is a no-op once the status has already been initialized', () async {
      final setup = container.read(setupActionProvider.notifier);
      await setup.setRunning(true, initialize: true);
      await setup.initStatus();

      expect(action.coreRunningCalls, [true]);
      expect(action.applyProfileCalls, 1);
    });

    test(
      'initialization waits for a start requested before bootstrap finished',
      () async {
        final setup = container.read(setupActionProvider.notifier);
        final gate = action.profileGate = Completer<void>();
        final starting = setup.setRunning(true, initialize: true);
        expect(action.applyProfileCalls, 1);

        var ready = false;
        final initializing = setup.initStatus().then((_) => ready = true);
        await pumpEventQueue();
        expect(ready, isFalse);
        gate.complete();
        await initializing;
        expect(await starting, isTrue);
        expect(action.applyProfileCalls, 1);
      },
    );

    test(
      'a pending service snapshot yields to a start tapped while it loads',
      () async {
        final snapshot = action.serviceRead = Completer<DateTime?>();
        final gate = action.profileGate = Completer<void>();
        final setup = container.read(setupActionProvider.notifier);
        var ready = false;
        final initializing = setup.initStatus().then((_) => ready = true);
        final starting = setup.setRunning(true, initialize: true);
        snapshot.complete(null);
        await pumpEventQueue();
        expect(action.applyProfileCalls, 1);
        expect(ready, isFalse);
        gate.complete();
        await initializing;
        expect(await starting, isTrue);
        expect(container.read(isStartProvider), isTrue);
      },
    );

    test(
      'a stop during startup reports its error to the request that made it',
      () async {
        final setup = container.read(setupActionProvider.notifier);
        await setup.setRunning(true, initialize: true);
        action.unansweredCoreCalls.add(false);
        await expectLater(
          setup.setRunning(false),
          throwsA(isA<CoreMethodException>()),
        );
        await setup.initStatus();
        expect(action.coreRunningCalls, [true, false]);
        expect(action.applyProfileCalls, 1);
      },
    );

    test('starts the core when autoRun is enabled', () async {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        autoRun: true,
      );

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, [true]);
    });

    test('only applies the profile when autoRun is disabled', () async {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        autoRun: false,
      );

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, isEmpty);
      expect(action.applyProfileCalls, 1);
    });

    test('takes over a run the service already has without pushing the config '
        'it runs again, which would make url-test groups re-pick', () async {
      final lastConfigMd5 = globalState.lastConfigMd5;
      addTearDown(() => globalState.lastConfigMd5 = lastConfigMd5);
      await mockPreferences({appliedConfigMd5Key: 'running'});
      action.serviceStart = DateTime.now().subtract(const Duration(minutes: 1));

      await container.read(setupActionProvider.notifier).initStatus();

      expect(action.coreRunningCalls, [true]);
      expect(action.appliedForce, [false]);
      expect(globalState.lastConfigMd5, 'running');
      expect(container.read(isStartProvider), isTrue);
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

    test('safe mode never asks, whatever the tun setting says', () async {
      final scopedAction = TestSetupAction();
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          safeModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);

      expect(await scopedAction.requestAdmin(true), isTrue);
      expect(scopedAction.authorizeCalls, 0);
      expect(
        scoped.read(authorizedTunEnableProvider),
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

    test('a failed authorization keeps the tun setting, pushes tun off and '
        'does not ask again in this run', () async {
      loadAppLocalizations(const Locale('en'));
      final mocks = coreMocks();
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scopedAction = TestSetupAction()
        ..authorizeResult = AuthorizeCode.error;
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          coreHandlerProvider.overrideWithValue(mocks.controller),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith.tun(enable: true));

      await scopedAction.updateConfig();
      await scopedAction.updateConfig();

      final patches = verify(
        () => mocks.api.patchConfig(captureAny()),
      ).captured.cast<ConfigPatch>();
      expect(patches.map((patch) => patch.tun?.enable), [false, false]);
      expect(scoped.read(patchClashConfigProvider).tun.enable, isTrue);
      expect(scoped.read(tunDisabledThisRunProvider), isTrue);
      expect(
        scoped.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
      expect(await scopedAction.requestAdmin(true), isTrue);
      expect(scopedAction.authorizeCalls, 1);

      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(restarted.read(tunDisabledThisRunProvider), isFalse);
    });
  });

  group('a backup restored on another platform', () {
    Config restored(Config backup) => Config.fromJson(
      jsonDecode(jsonEncode(backup.toJson())) as Map<String, Object?>,
    );

    Future<
      ({
        ProviderContainer scoped,
        TestSetupAction action,
        List<ConfigPatch> patches,
        List<String> banners,
      })
    >
    updateOn(Config backup, {required bool desktop}) async {
      loadAppLocalizations(const Locale('en'));
      final printed = <String>[];
      final previousPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
      addTearDown(() => debugPrint = previousPrint);
      final mocks = coreMocks();
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scopedAction = TestSetupAction()
        ..desktop = desktop
        ..authorizeResult = AuthorizeCode.error;
      final scoped = ProviderContainer(
        overrides: [
          ...buildConfigOverrides(restored(backup)),
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          coreHandlerProvider.overrideWithValue(mocks.controller),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);

      await scopedAction.updateConfig();

      return (
        scoped: scoped,
        action: scopedAction,
        patches: verify(
          () => mocks.api.patchConfig(captureAny()),
        ).captured.cast<ConfigPatch>(),
        banners: printed.where((line) => line.contains('banner:')).toList(),
      );
    }

    const desktopBackup = Config(
      themeProps: defaultThemeProps,
      patchClashConfig: PatchClashConfig(tun: Tun(enable: true)),
    );

    test('a desktop one with TUN on asks for nothing on Android and keeps '
        'the setting', () async {
      final run = await updateOn(desktopBackup, desktop: false);

      expect(run.action.authorizeCalls, 0);
      expect(run.banners, isEmpty);
      expect(run.scoped.read(tunDisabledThisRunProvider), isFalse);
      expect(
        run.scoped.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
      expect(run.patches.map((patch) => patch.tun?.enable), [false]);
      expect(run.scoped.read(patchClashConfigProvider).tun.enable, isTrue);
    });

    test('the same one back on desktop still asks for TUN', () async {
      final run = await updateOn(desktopBackup, desktop: true);

      expect(run.action.authorizeCalls, 1);
      expect(run.banners, hasLength(1));
      expect(run.scoped.read(tunDisabledThisRunProvider), isTrue);
    });

    test('an Android one asks for nothing on desktop and keeps its VPN '
        'settings', () async {
      const vpnProps = VpnProps(
        dnsHijacking: true,
        accessControlProps: AccessControlProps(
          enable: true,
          acceptList: ['com.example.app'],
        ),
      );
      final run = await updateOn(
        const Config(themeProps: defaultThemeProps, vpnProps: vpnProps),
        desktop: true,
      );

      expect(run.action.authorizeCalls, 0);
      expect(run.banners, isEmpty);
      expect(run.scoped.read(tunDisabledThisRunProvider), isFalse);
      expect(run.patches.map((patch) => patch.tun?.enable), [false]);
      expect(run.scoped.read(vpnSettingProvider), vpnProps);
    });
  });

  group('updateConfig', () {
    test('safe mode pushes tun disabled even once authorized', () async {
      final mocks = coreMocks();
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scopedAction = TestSetupAction();
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          safeModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(tun: state.tun.copyWith(enable: true)),
          );
      scoped.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.authorized;

      await scopedAction.updateConfig();

      final patch =
          verify(() => mocks.api.patchConfig(captureAny())).captured.single
              as ConfigPatch;
      expect(patch.tun?.enable, isFalse);
      expect(scopedAction.authorizeCalls, 0);
    });

    test('safe mode closes the external controller', () async {
      final mocks = coreMocks();
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scopedAction = TestSetupAction();
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          safeModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              externalController: ExternalControllerStatus.open,
            ),
          );

      await scopedAction.updateConfig();

      final patch =
          verify(() => mocks.api.patchConfig(captureAny())).captured.single
              as ConfigPatch;
      expect(patch.externalController, ExternalControllerStatus.close.value);
      expect(
        scoped.read(patchClashConfigProvider).externalController,
        ExternalControllerStatus.open,
      );
    });

    Future<ConfigPatch> updateWith(PatchClashConfig patchConfig) async {
      final mocks = coreMocks();
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scopedAction = TestSetupAction();
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          setupActionProvider.overrideWith(() => scopedAction),
          coreHandlerProvider.overrideWithValue(mocks.controller),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(setupActionProvider.notifier);
      scoped.read(patchClashConfigProvider.notifier).value = patchConfig;

      await scopedAction.updateConfig();

      return verify(() => mocks.api.patchConfig(captureAny())).captured.single
          as ConfigPatch;
    }

    test('hands the Core the controller secret with the address', () async {
      final patch = await updateWith(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
          secret: 'abc',
        ),
      );

      expect(patch.externalController, ExternalControllerStatus.open.value);
      expect(patch.secret, 'abc');
    });

    test('hands the Core the cross-origin choice with the address', () async {
      final allowed = await updateWith(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
          secret: 'abc',
        ),
      );
      final refused = await updateWith(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
          secret: 'abc',
          externalControllerCors: false,
        ),
      );

      expect(allowed.externalControllerCors?.allowOrigins, ['*']);
      expect(allowed.externalControllerCors?.allowPrivateNetwork, isTrue);
      expect(refused.externalControllerCors?.allowOrigins, isEmpty);
      expect(refused.externalControllerCors?.allowPrivateNetwork, isFalse);
    });

    test('never opens the controller without a secret', () async {
      final patch = await updateWith(
        const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
        ),
      );

      expect(patch.externalController, ExternalControllerStatus.close.value);
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

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(action.applyProfileCalls, 1);
    });

    test('a forced apply stays forced when a plain one follows', () async {
      final notifier = container.read(setupActionProvider.notifier);

      notifier.applyProfileDebounce(force: true);
      notifier.applyProfileDebounce();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      notifier.applyProfileDebounce();
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(action.appliedForce, [true, false]);
    });

    test('a stop cancels a pending apply', () async {
      markInitialized();
      final notifier = container.read(setupActionProvider.notifier);

      notifier.applyProfileDebounce(force: true);
      await notifier.setRunning(false);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(action.applyProfileCalls, 0);

      notifier.applyProfileDebounce();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(action.appliedForce, [false]);
    });
  });

  group('applyIfGlobalRulesUsed', () {
    for (final (name, profile, applies) in [
      ('a profile without a script', Profile.normal(label: 'p'), true),
      (
        'a profile running a script',
        Profile.normal(label: 'p').copyWith(scriptId: 1),
        true,
      ),
      ('a custom profile', Profile.custom(label: 'p'), false),
    ]) {
      test('${applies ? 'applies' : 'leaves alone'} $name', () async {
        final setupAction = TestSetupAction();
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupActionProvider.overrideWith(() => setupAction),
          ],
        );
        addTearDown(scoped.dispose);

        scoped.read(setupActionProvider.notifier).applyIfGlobalRulesUsed();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        expect(setupAction.applyProfileCalls, applies ? 1 : 0);
      });
    }
  });

  group('_setupConfig via the real SetupAction', () {
    late Directory tempDir;
    late String? originalLastConfigMd5;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('setup_action_test');
      await useAppPaths(tempDir);
      loadAppLocalizations(const Locale('en'));
      originalLastConfigMd5 = globalState.lastConfigMd5;
      globalState.packageInfo = PackageInfo(
        appName: 'FlClash',
        packageName: 'com.follow.clash',
        version: '0.0.0',
        buildNumber: '0',
      );
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
      profileType: ProfileType.file,
      rules: [],
      proxyGroups: [],
      addedRules: [],
      script: null,
      overrides: ProfileOverrides(),
    );

    test(
      'a refresh failure still runs core.setupConfig and preloadInvoke',
      () async {
        final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        var preloadRan = false;
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
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
        verify(() => _applied(mocks.api)).called(1);
      },
    );

    test(
      'provider directories it cannot create leave the config applied',
      () async {
        final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
        final providersRoot = File(await appPath.getProvidersRootPath());
        final earlierRoot = Directory(providersRoot.path);
        if (await earlierRoot.exists()) {
          await earlierRoot.delete(recursive: true);
        }
        await providersRoot.parent.create(recursive: true);
        await providersRoot.writeAsString('');
        addTearDown(() => providersRoot.delete());
        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        final succeeded = await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);

        expect(succeeded, isTrue);
        verify(() => _applied(mocks.api)).called(1);
      },
    );

    test(
      'a config the Core took carries the external controller and the '
      'host credential, which the Core never reads from the profile',
      () async {
        final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        when(() => mocks.api.lastWarnings()).thenAnswer((_) async => const []);
        when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
            hostCredentialProvider.overrideWithValue('h:s'),
          ],
        );
        addTearDown(scoped.dispose);
        scoped.listen(patchClashConfigProvider, (_, _) {});
        scoped
            .read(patchClashConfigProvider.notifier)
            .value = const PatchClashConfig(
          externalController: ExternalControllerStatus.open,
          secret: 's',
        );

        expect(
          await scoped
              .read(setupActionProvider.notifier)
              .applyProfile(force: true),
          isTrue,
        );

        final host =
            verify(
                  () => mocks.api.applyConfig(
                    profilePath: any(named: 'profilePath'),
                    overlay: any(named: 'overlay'),
                    selection: any(named: 'selection'),
                    options: any(named: 'options'),
                    host: captureAny(named: 'host'),
                  ),
                ).captured.single
                as Map<String, Object?>;
        expect(host['externalController'], '127.0.0.1:9090');
        expect(host['secret'], 's');
        expect(host['hostCredential'], 'h:s');
        verifyNever(() => mocks.api.patchConfig(any()));
      },
    );

    test('a resume that finds the config already applied still hands the '
        'Core the external controller and the host credential', () async {
      final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
      final mocks = coreMocks();
      when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
      when(() => mocks.api.lastWarnings()).thenAnswer((_) async => const []);
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
          hostCredentialProvider.overrideWithValue('h:s'),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.listen(patchClashConfigProvider, (_, _) {});
      scoped
          .read(patchClashConfigProvider.notifier)
          .value = const PatchClashConfig(
        externalController: ExternalControllerStatus.open,
        secret: 's',
      );
      final action = scoped.read(setupActionProvider.notifier);
      expect(await action.applyProfile(force: true), isTrue);
      clearInteractions(mocks.api);

      expect(await action.applyProfile(), isTrue);

      verifyNever(() => _applied(mocks.api));
      final patch =
          verify(() => mocks.api.patchConfig(captureAny())).captured.single
              as ConfigPatch;
      expect(patch.externalController, '127.0.0.1:9090');
      expect(patch.secret, 's');
      expect(patch.hostCredential, 'h:s');
      expect(
        (patch.toJson()['options']! as Map).containsKey('mitmTrustedCa'),
        isFalse,
        reason: 'options without it give the CA trust back to the config',
      );
    });

    test('the warnings of a setup are kept, whether the Core took it or '
        'rejected it', () async {
      final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
      final mocks = coreMocks();
      const warningInfo = WarningInfo(
        level: 'warning',
        path: 'proxies[1]',
        message: 'unsupported',
      );
      const warning = ConfigWarning(
        level: ConfigWarningLevel.warning,
        path: 'proxies[1]',
        message: 'unsupported',
      );
      var rejecting = false;
      when(() => _applied(mocks.api)).thenAnswer((_) async {
        if (rejecting) {
          throw const CoreMethodException(
            code: 'config_rejected',
            message: 'rejected',
          );
        }
        return const [];
      });
      when(
        () => mocks.api.lastWarnings(),
      ).thenAnswer((_) async => [warningInfo]);
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      final setupAction = scoped.read(setupActionProvider.notifier);
      final warnings = configWarningsStateProvider.notifier;

      expect(await setupAction.applyProfile(force: true), isTrue);
      expect(scoped.read(configWarningsStateProvider), [warning]);

      scoped.read(warnings).value = const [];
      rejecting = true;
      expect(await setupAction.applyProfile(force: true), isFalse);
      expect(scoped.read(configWarningsStateProvider), [warning]);
    });

    test('a resume that finds the config already applied still shows the '
        'warnings the Core kept from it', () async {
      final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
      final mocks = coreMocks();
      when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
      when(() => mocks.api.patchConfig(any())).thenAnswer((_) async => 1);
      when(() => mocks.api.lastWarnings()).thenAnswer(
        (_) async => const [
          WarningInfo(level: 'warning', path: 'proxies[1]', message: 'x'),
        ],
      );
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      scoped.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      final action = scoped.read(setupActionProvider.notifier);
      expect(await action.applyProfile(force: true), isTrue);
      scoped.read(configWarningsStateProvider.notifier).value = const [];
      clearInteractions(mocks.api);

      expect(await action.applyProfile(), isTrue);

      verifyNever(() => _applied(mocks.api));
      expect(scoped.read(configWarningsStateProvider), const [
        ConfigWarning(
          level: ConfigWarningLevel.warning,
          path: 'proxies[1]',
          message: 'x',
        ),
      ]);
    });

    test('a setup against a Core marked stopped leaves no warnings beside '
        'it', () async {
      final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
      final mocks = coreMocks();
      when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
      when(() => mocks.api.lastWarnings()).thenAnswer(
        (_) async => const [
          WarningInfo(level: 'warning', path: 'proxies[1]', message: 'x'),
        ],
      );
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      expect(
        await scoped.read(setupActionProvider.notifier).applyProfile(),
        isTrue,
      );
      expect(scoped.read(coreStatusProvider), CoreStatus.disconnected);
      expect(scoped.read(configWarningsStateProvider), isEmpty);
    });

    test(
      'a Core that cannot report warnings leaves the setup applied',
      () async {
        final profile = Profile.normal(label: 'p', url: 'http://127.0.0.1:9/');
        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        when(() => mocks.api.lastWarnings()).thenThrow(
          const CoreMethodException(code: 'core_unavailable', message: 'gone'),
        );
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        expect(
          await scoped
              .read(setupActionProvider.notifier)
              .applyProfile(force: true),
          isTrue,
        );
        expect(scoped.read(configWarningsStateProvider), isEmpty);
      },
    );

    test(
      'a profile that fails to build still pushes the empty config to core',
      () async {
        final profile = Profile.normal(label: 'p');
        final mocks = coreMocks();
        when(
          () => mocks.api.inspectProfile(any()),
        ).thenThrow(Exception('broken yaml'));
        String? pushedConfig;
        when(() => _applied(mocks.api)).thenAnswer((_) async {
          pushedConfig = await File(
            await appPath.configFilePath,
          ).readAsString();
          return const [];
        });
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith(
              (_, profileId) =>
                  nullProfileSetupState.copyWith(profileId: profileId),
            ),
            coreHandlerProvider.overrideWithValue(mocks.controller),
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

        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        try {
          final succeeded = await scoped
              .read(setupActionProvider.notifier)
              .applyProfile(force: true);

          expect(succeeded, isFalse);
          verifyNever(() => _applied(mocks.api));
        } finally {
          await configAsDirectory.delete(recursive: true);
        }
      },
    );

    test(
      'safe mode writes a closed external controller into the profile',
      () async {
        final profile = Profile.normal(label: 'p');
        final mocks = coreMocks();
        when(
          () => mocks.api.inspectProfile(any()),
        ).thenAnswer((_) async => _inspected());
        Map<String, dynamic>? pushedOverlay;
        when(() => _applied(mocks.api)).thenAnswer((invocation) async {
          pushedOverlay =
              invocation.namedArguments[#overlay] as Map<String, dynamic>?;
          return const [];
        });
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith(
              (_, profileId) =>
                  nullProfileSetupState.copyWith(profileId: profileId),
            ),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
            safeModeProvider.overrideWithValue(true),
          ],
        );
        addTearDown(scoped.dispose);
        scoped
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                externalController: ExternalControllerStatus.open,
              ),
            );

        final succeeded = await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);

        expect(succeeded, isTrue);
        expect(pushedOverlay?['external-controller'], '');
        expect(jsonEncode(pushedOverlay), isNot(contains('9090')));
      },
    );

    test('custom exits of a merged profile read its outbounds once per '
        'profile file', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      var digest = 'd1';
      when(() => mocks.api.inspectProfile(any())).thenAnswer(
        (_) async => _inspected(digest: digest, matchRules: ['MATCH,Final']),
      );
      when(() => mocks.api.profileOutbounds(any())).thenAnswer(
        (_) async => const ProfileOutbounds(
          proxies: [OutboundRef(name: 'HK', type: 'ss')],
          proxyGroups: [OutboundRef(name: 'Final', type: 'select')],
        ),
      );
      final overlays = <Map<String, dynamic>?>[];
      when(() => _applied(mocks.api)).thenAnswer((invocation) async {
        overlays.add(
          invocation.namedArguments[#overlay] as Map<String, dynamic>?,
        );
        return const [];
      });
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, profileId) => nullProfileSetupState.copyWith(
              profileId: profileId,
              addedRules: const [
                Rule(
                  ruleAction: RuleAction.DOMAIN,
                  content: 'a.example',
                  ruleTarget: 'Media',
                  customExit: true,
                ),
                Rule(
                  ruleAction: RuleAction.DOMAIN,
                  content: 'b.example',
                  ruleTarget: 'AI',
                  customExit: true,
                ),
              ],
              exitTargets: const {'AI': 'HK', 'Media': 'Gone'},
            ),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);

      expect(await setupAction.applyProfile(force: true), isTrue);
      expect(overlays.last?['rules'], [
        'DOMAIN,a.example,Final',
        'DOMAIN,b.example,HK',
      ]);
      await setupAction.applyProfile(force: true);
      verify(() => mocks.api.profileOutbounds(any())).called(1);

      digest = 'd2';
      await setupAction.applyProfile(force: true);
      verify(() => mocks.api.profileOutbounds(any())).called(1);
    });

    test('leaving an editor rebuilds the profile only once its inputs '
        'differ from the applied config', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
      var setupState = nullProfileSetupState.copyWith(profileId: profile.id);
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith((_, _) => setupState),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);
      Future<void> leaveEditor() async {
        setupAction.autoApplyProfile();
        SchedulerBinding.instance
          ..handleBeginFrame(null)
          ..handleDrawFrame();
        await pumpEventQueue();
      }

      await setupAction.applyProfile(force: true);
      verify(() => mocks.api.inspectProfile(any())).called(1);

      await leaveEditor();
      verifyNever(() => mocks.api.inspectProfile(any()));

      setupState = setupState.copyWith(exitTargets: {'MATCH': 'DIRECT'});
      scoped.invalidate(setupStateProvider);
      await leaveEditor();
      verify(() => mocks.api.inspectProfile(any())).called(1);
      // Queued behind the rebuild: one that outlasts the pump would compare
      // against the md5 tearDown resets and push into a disposed container.
      await setupAction.applyProfile();
    });

    test('a debounced apply waits as long as the last push to the Core took, '
        'whatever an apply that sent nothing took since', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(() => _applied(mocks.api)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return const [];
      });
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, _) => nullProfileSetupState.copyWith(profileId: profile.id),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(_UnflooredDebounceSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);

      await setupAction.applyProfile(force: true);
      await setupAction.applyProfile();
      verify(() => _applied(mocks.api)).called(1);
      clearInteractions(mocks.api);

      setupAction.applyProfileDebounce(silence: true, force: true);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      verifyNever(() => mocks.api.inspectProfile(any()));
      await Future<void>.delayed(const Duration(seconds: 1));
      verify(() => mocks.api.inspectProfile(any())).called(1);
      // Queued behind the forced push, so the container outlives it.
      await setupAction.applyProfile();
    });

    test('a slow push holds a debounced apply back no longer than the '
        'ceiling', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(() => _applied(mocks.api)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return const [];
      });
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, _) => nullProfileSetupState.copyWith(profileId: profile.id),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(_CappedDebounceSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);

      await setupAction.applyProfile(force: true);
      clearInteractions(mocks.api);

      setupAction.applyProfileDebounce(silence: true, force: true);
      await Future<void>.delayed(const Duration(milliseconds: 650));
      verify(() => mocks.api.inspectProfile(any())).called(1);
      await setupAction.applyProfile();
    });

    test('a config the Core already runs is not pushed again, while the start '
        'riding on it still opens the listeners', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, _) => nullProfileSetupState.copyWith(profileId: profile.id),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);
      await setupAction.applyProfile(force: true);
      final counts = globalState.lastConfigCounts;
      expect(counts, isNotNull);
      globalState.lastConfigCounts = null;

      var listenersOpened = false;
      final applied = await setupAction.applyProfile(
        preloadInvoke: () async {
          listenersOpened = true;
        },
      );

      expect(applied, isTrue);
      expect(listenersOpened, isTrue);
      expect(globalState.lastConfigCounts, counts);
      verify(() => _applied(mocks.api)).called(1);
    });

    test('a config the Core rejected is pushed again once reverted, and the '
        'groups follow the Core through both', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      final profileProxies = ProxyGroupsDto(
        order: const ['Proxy', 'GLOBAL'],
        groups: [
          _groupInfo('Proxy', all: const ['HK-01']),
          _groupInfo('GLOBAL', hidden: true, all: const ['Proxy']),
        ],
        nodes: const [NodeInfo(name: 'HK-01', type: 'ss')],
      );
      final fallbackProxies = ProxyGroupsDto(
        order: const ['GLOBAL'],
        groups: [
          _groupInfo('GLOBAL', hidden: true, all: const ['DIRECT']),
        ],
        nodes: const [NodeInfo(name: 'DIRECT', type: 'Direct')],
      );
      var rejecting = false;
      var coreProxies = profileProxies;
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(() => mocks.api.providers()).thenAnswer((_) async => []);
      when(() => mocks.api.proxyGroups()).thenAnswer((_) async => coreProxies);
      when(() => _applied(mocks.api)).thenAnswer((_) async {
        if (rejecting) {
          coreProxies = fallbackProxies;
          throw const CoreMethodException(
            code: 'config_rejected',
            message: 'invalid hosts',
          );
        }
        coreProxies = profileProxies;
        return const [];
      });
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, profileId) =>
                nullProfileSetupState.copyWith(profileId: profileId),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);
      List<String> shownGroups() => [
        for (final group in scoped.read(currentGroupsStateProvider).value)
          group.name,
      ];
      void setHosts(Map<String, String> hosts) {
        scoped
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(hosts: hosts));
      }

      final originalHosts = scoped.read(patchClashConfigProvider).hosts;
      expect(await setupAction.applyProfile(force: true), isTrue);
      expect(shownGroups(), ['Proxy']);

      rejecting = true;
      setHosts({'example.com': 'not-an-address'});
      expect(await setupAction.applyProfile(), isFalse);
      expect(shownGroups(), isEmpty);

      rejecting = false;
      setHosts(originalHosts);
      expect(await setupAction.applyProfile(), isTrue);
      verify(() => _applied(mocks.api)).called(3);
      expect(shownGroups(), ['Proxy']);
    });

    test('a profile file leaves its bulk sections in the Core and records '
        'what the Core was handed', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      var digest = 'first';
      when(() => mocks.api.inspectProfile(any())).thenAnswer(
        (_) async => _inspected(
          config: const {'mixed-port': 1},
          digest: digest,
          matchRules: const ['MATCH,DIRECT', 'MATCH,Proxy'],
          proxies: 3,
          proxyGroups: 2,
          rules: 5,
        ),
      );
      final pushed = <({String? path, Map<String, dynamic>? overlay})>[];
      when(() => _applied(mocks.api)).thenAnswer((invocation) async {
        pushed.add((
          path: invocation.namedArguments[#profilePath] as String?,
          overlay: invocation.namedArguments[#overlay] as Map<String, dynamic>?,
        ));
        return const [];
      });
      when(() => mocks.api.profileOutbounds(any())).thenAnswer(
        (_) async => const ProfileOutbounds(proxies: [], proxyGroups: []),
      );
      final configFile = File(await appPath.configFilePath);
      await configFile.writeAsString('previous');
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          setupStateProvider.overrideWith(
            (_, profileId) => nullProfileSetupState.copyWith(
              profileId: profileId,
              addedRules: [
                Rule.parse(
                  'DOMAIN,added.test,MATCH',
                ).copyWith(customExit: true),
              ],
            ),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      final setupAction = scoped.read(setupActionProvider.notifier);
      addTearDown(() => globalState.lastConfigCounts = null);

      expect(await setupAction.applyProfile(force: true), isTrue);

      final base = pushed.single;
      expect(base.path, await appPath.getProfilePath(profile.id.toString()));
      final overlay = base.overlay!;
      expect(overlay['rules'], ['DOMAIN,added.test,Proxy']);
      expect(overlay['mixed-port'], isNot(1));
      expect(await configFile.readAsString(), 'previous');
      expect(globalState.lastConfigCounts, (groups: 2, proxies: 3, rules: 6));

      await setupAction.applyProfile();
      expect(pushed, hasLength(1));

      digest = 'second';
      await setupAction.applyProfile();
      expect(pushed, hasLength(2));

      when(() => _applied(mocks.api)).thenAnswer(
        (_) async => throw const CoreMethodException(
          code: 'config_rejected',
          message: 'rejected',
        ),
      );
      digest = 'third';
      expect(await setupAction.applyProfile(), isFalse);
      expect(globalState.lastConfigCounts, (groups: 0, proxies: 0, rules: 0));
    });

    test('the preview shows the config the Core merges', () async {
      final profile = Profile.normal(label: 'p');
      final mocks = coreMocks();
      when(
        () => mocks.api.inspectProfile(any()),
      ).thenAnswer((_) async => _inspected());
      when(
        () => mocks.api.buildProfile(any(), any()),
      ).thenAnswer((_) async => const TextOutput(text: 'proxies: []\n'));
      final scoped = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          setupStateProvider.overrideWith(
            (_, profileId) =>
                nullProfileSetupState.copyWith(profileId: profileId),
          ),
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final yaml = await scoped
          .read(setupActionProvider.notifier)
          .getProfileWithId(profile.id);

      verifyNever(() => mocks.api.readConfig(any()));
      expect(yaml, 'proxies: []\n');
    });

    test(
      'the extend page reads only the outbounds of a profile file',
      () async {
        final profile = Profile.normal(label: 'p');
        final mocks = coreMocks();
        when(() => mocks.api.profileOutbounds(any())).thenAnswer(
          (_) async => const ProfileOutbounds(
            proxies: [OutboundRef(name: 'a', type: 'ss')],
            proxyGroups: [OutboundRef(name: 'g', type: 'select')],
          ),
        );
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            coreHandlerProvider.overrideWithValue(mocks.controller),
          ],
        );
        addTearDown(scoped.dispose);

        final config = await scoped.read(
          clashConfigProvider(profile.id).future,
        );

        verifyNever(() => mocks.api.readConfig(any()));
        expect(
          {
            for (final proxy in config.proxies) proxy.name: proxy.type,
            for (final group in config.proxyGroups) group.name: group.type,
          },
          {'a': 'ss', 'g': GroupType.Selector},
        );
      },
    );

    test(
      'a start applies the profile again only once its inputs changed',
      () async {
        final profile = Profile.normal(label: 'p');
        final mocks = coreMocks();
        when(
          () => mocks.api.inspectProfile(any()),
        ).thenAnswer((_) async => _inspected());
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        when(() => mocks.backend.startListener()).thenAnswer((_) async {});
        when(() => mocks.backend.stopListener()).thenAnswer((_) async {});
        when(() => mocks.api.resetTraffic()).thenAnswer((_) async {});
        final scoped = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            setupStateProvider.overrideWith(
              (_, profileId) =>
                  nullProfileSetupState.copyWith(profileId: profileId),
            ),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            commonActionProvider.overrideWith(TestCommonAction.new),
            setupActionProvider.overrideWith(_UnflooredDebounceSetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);
        scoped.read(initProvider.notifier).value = true;
        final setupAction = scoped.read(setupActionProvider.notifier);
        await setupAction.applyProfile(force: true);
        verify(() => _applied(mocks.api)).called(1);

        await setupAction.setRunning(true);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        verifyNever(() => _applied(mocks.api));

        await setupAction.setRunning(false);
        scoped.read(patchClashConfigProvider.notifier).value = scoped
            .read(patchClashConfigProvider)
            .copyWith(testUrl: 'https://example.com/204');
        await setupAction.setRunning(true);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        verify(() => _applied(mocks.api)).called(1);
        await setupAction.setRunning(false);
      },
    );

    test('a custom profile declares only the proxies and providers it names, '
        'without a profile file', () async {
      final profile = Profile.custom(label: 'p');
      final mocks = coreMocks();
      const appProxy = CustomProxy(
        id: 11,
        definition: {'name': 'mine', 'type': 'socks5', 'server': '::1'},
      );
      const unusedProxy = CustomProxy(
        id: 15,
        definition: {'name': 'spare', 'type': 'socks5', 'server': '::1'},
      );
      const appRule = ClashProvider(
        id: 12,
        label: 'appRules',
        url: 'https://example.com/r.yaml',
        behavior: RuleProviderBehavior.domain,
        format: RuleProviderFormat.yaml,
      );
      final compiled = File(await appRule.compiledPath)
        ..createSync(recursive: true);
      addTearDown(compiled.deleteSync);
      const unusedRule = ClashProvider(
        id: 13,
        label: 'unused',
        url: 'https://example.com/u.yaml',
      );
      const localRule = ClashProvider(
        id: 14,
        label: 'localRules',
        behavior: RuleProviderBehavior.classical,
        format: RuleProviderFormat.yaml,
      );
      const nestedRule = ClashProvider(
        id: 16,
        label: 'nestedRules',
        behavior: RuleProviderBehavior.classical,
        format: RuleProviderFormat.yaml,
      );
      final setupState = nullProfileSetupState.copyWith(
        profileId: profile.id,
        profileType: ProfileType.custom,
        proxyGroups: [
          const ProxyGroup(
            id: 1,
            name: 'g',
            type: GroupType.Selector,
            proxies: ['mine'],
            use: ['sub'],
          ),
        ],
        rules: [
          Rule.parse('RULE-SET,appRules,DIRECT', id: 2),
          Rule.parse('RULE-SET,localRules,DIRECT', id: 3),
          Rule.parse(
            'AND,((RULE-SET,nestedRules),(NETWORK,UDP)),REJECT',
            id: 4,
          ),
        ],
        clashProviders: const [appRule, unusedRule, localRule, nestedRule],
        profileProviders: const {'sub': 42},
        appProxies: const [appProxy, unusedProxy],
      );
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: setupState,
            patchConfig: const PatchClashConfig(),
          );
      final config = loadYaml(res.yaml) as YamlMap;
      final proxyProviders = config['proxy-providers'] as YamlMap;

      verifyNever(() => mocks.api.readConfig(any()));
      expect(proxyProviders.keys, {'sub'});
      expect((config['proxies'] as YamlList).single['name'], 'mine');
      expect(proxyProviders['sub']['type'], 'file');
      expect(proxyProviders['sub']['path'], await appPath.getProfilePath('42'));
      expect((config['proxy-groups'] as YamlList).single['name'], 'g');
      expect(config['rules'], [
        'RULE-SET,appRules,DIRECT',
        'RULE-SET,localRules,DIRECT',
        'AND,((RULE-SET,nestedRules),(NETWORK,UDP)),REJECT',
      ]);
      expect(config['rule-providers'].containsKey('nestedRules'), isTrue);
      final remote = config['rule-providers']['appRules'] as YamlMap;
      expect(remote['type'], 'file');
      expect(remote.containsKey('url'), isFalse);
      expect(remote['behavior'], 'domain');
      expect(remote['format'], 'mrs');
      expect(remote['path'], compiled.path);
      expect(config['rule-providers'].containsKey('unused'), isFalse);
      final local = config['rule-providers']['localRules'] as YamlMap;
      expect(local['type'], 'file');
      expect(local.containsKey('url'), isFalse);
      expect(
        local['path'],
        await appPath.getProviderCachePath(localRule.fileName),
      );
    });

    test('with no profile the config carries the settings and MITM, '
        'and no rule or proxy, so everything goes direct', () async {
      final mocks = coreMocks();
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: nullProfileSetupState,
            patchConfig: const PatchClashConfig(
              mitm: Mitm(enable: true, hostname: ['a.example']),
            ),
          );
      final config = loadYaml(res.yaml) as YamlMap;

      verifyNever(() => mocks.api.readConfig(any()));
      expect(res.base, isNull);
      expect(config['mitm']['enable'], isTrue);
      expect(config['mitm']['hostname'], contains('a.example'));
      expect(config['tun'], isA<YamlMap>());
      expect(config['dns'], isA<YamlMap>());
      expect(config['mode'], 'rule');
      expect(config['rules'], isEmpty);
      expect(config.containsKey('proxies'), isFalse);
    });

    test('a provider a custom profile names carries its options', () async {
      final profile = Profile.custom(label: 'p');
      final mocks = coreMocks();
      final setupState = nullProfileSetupState.copyWith(
        profileId: profile.id,
        profileType: ProfileType.custom,
        proxyGroups: [
          const ProxyGroup(
            id: 1,
            name: 'g',
            type: GroupType.Selector,
            use: ['sub', 'plain'],
          ),
        ],
        profileProviders: const {'sub': 42, 'plain': 43},
        overrides: const ProfileOverrides(
          proxyProviders: {
            'sub': ProxyProviderOptions(
              healthCheck: ProviderHealthCheck(interval: 600),
              filter: 'HK',
              excludeFilter: 'expire',
            ),
          },
        ),
      );
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: setupState,
            patchConfig: const PatchClashConfig(),
          );
      final providers = (loadYaml(res.yaml) as YamlMap)['proxy-providers'];

      expect(providers['sub']['filter'], 'HK');
      expect(providers['sub']['exclude-filter'], 'expire');
      expect(providers['sub']['health-check'], {
        'enable': true,
        'url': defaultTestUrl,
        'interval': 600,
      });
      expect(providers['sub']['type'], 'file');
      expect((providers['plain'] as YamlMap).keys, {'type', 'path'});
    });

    test('a custom profile group taking in every proxy or provider declares '
        'none the profile does not name', () async {
      final profile = Profile.custom(label: 'p');
      final mocks = coreMocks();
      final setupState = nullProfileSetupState.copyWith(
        profileId: profile.id,
        profileType: ProfileType.custom,
        proxyGroups: [
          const ProxyGroup(
            id: 1,
            name: 'g',
            type: GroupType.Selector,
            filter: 'HK',
            includeAllProxies: true,
            includeAllProviders: true,
          ),
          const ProxyGroup(
            id: 2,
            name: 'h',
            type: GroupType.Selector,
            proxies: ['mine'],
            use: ['sub'],
          ),
        ],
        profileProviders: const {'sub': 42, 'plain': 43},
        appProxies: const [
          CustomProxy(id: 11, definition: {'name': 'mine', 'type': 'direct'}),
          CustomProxy(id: 15, definition: {'name': 'spare', 'type': 'direct'}),
        ],
      );
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: setupState,
            patchConfig: const PatchClashConfig(),
          );
      final config = loadYaml(res.yaml) as YamlMap;

      expect((config['proxy-providers'] as YamlMap).keys, {'sub'});
      expect([for (final proxy in config['proxies']) proxy['name']], ['mine']);
      final group = (config['proxy-groups'] as YamlList).first as YamlMap;
      expect(group['include-all-proxies'], isTrue);
      expect(group['include-all-providers'], isTrue);
    });

    test('without a profile the Core still opens the mixed port the Android '
        'VPN advertises as its HTTP proxy', () async {
      final mocks = coreMocks();
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: nullProfileSetupState,
            patchConfig: const PatchClashConfig(mixedPort: 7899),
          );
      final config = loadYaml(res.yaml) as YamlMap;

      verifyNever(() => mocks.api.readConfig(any()));
      expect(config['mixed-port'], 7899);
      expect(config['skip-auth-prefixes'], isEmpty);
      expect(res.md5, isNotEmpty);
    });

    test('only a subscription profile runs its script extension', () async {
      final engine = scriptEvaluator;
      addTearDown(() => scriptEvaluator = engine);
      final evaluated = <String>[];
      scriptEvaluator =
          ({required String script, required String config}) async {
            evaluated.add(script);
            return config;
          };
      final script = await Script(
        id: 77,
        label: 'script',
        lastUpdateTime: DateTime(2026),
      ).save('const main = (config) => config;');
      final mocks = coreMocks();
      when(() => mocks.api.readConfig(any())).thenAnswer(
        (_) async => ConfigReadOutput(config: Map<String, dynamic>.of({})),
      );
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      Future<void> build(ProfileType type) => scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: nullProfileSetupState.copyWith(
              profileId: 5,
              profileType: type,
              script: script,
            ),
            patchConfig: const PatchClashConfig(),
          );

      await build(ProfileType.custom);
      expect(evaluated, isEmpty);
      verifyNever(() => mocks.api.readConfig(any()));

      await build(ProfileType.file);
      expect(evaluated, hasLength(1));
      verify(() => mocks.api.readConfig(any())).called(1);
    });

    test('puts the added rules ahead of what the script returns', () async {
      final engine = scriptEvaluator;
      addTearDown(() => scriptEvaluator = engine);
      scriptEvaluator =
          ({required String script, required String config}) async =>
              json.encode({
                'rules': ['DOMAIN,script.com,DIRECT', 'MATCH,FromScript'],
              });
      final script = await Script(
        id: 78,
        label: 'script',
        lastUpdateTime: DateTime(2026),
      ).save('const main = (config) => config;');
      final mocks = coreMocks();
      when(() => mocks.api.readConfig(any())).thenAnswer(
        (_) async => ConfigReadOutput(
          config: Map<String, dynamic>.of({
            'rules': ['MATCH,FromProfile'],
          }),
        ),
      );
      final scoped = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(mocks.controller),
          setupActionProvider.overrideWith(SetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);

      final res = await scoped
          .read(setupActionProvider.notifier)
          .getProfile(
            setupState: nullProfileSetupState.copyWith(
              profileId: 5,
              script: script,
              addedRules: [
                Rule.parse('DOMAIN,added.com,REJECT', id: 1),
                Rule.parse(
                  'DOMAIN,placeholder.com,MATCH',
                  id: 2,
                ).copyWith(customExit: true),
              ],
            ),
            patchConfig: const PatchClashConfig(),
          );

      expect((loadYaml(res.yaml) as YamlMap)['rules'], [
        'DOMAIN,added.com,REJECT',
        'DOMAIN,placeholder.com,FromScript',
        'DOMAIN,script.com,DIRECT',
        'MATCH,FromScript',
      ]);
    });

    test(
      'a rejected setupConfig without a handoff reports failure, not success',
      () async {
        final mocks = coreMocks();
        when(() => _applied(mocks.api)).thenThrow(StateError('rejected'));
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
            setupActionProvider.overrideWith(SetupAction.new),
          ],
        );
        addTearDown(scoped.dispose);

        final succeeded = await scoped
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);

        expect(succeeded, isFalse);
        verify(() => _applied(mocks.api)).called(1);
      },
    );

    test(
      'a listener handoff failure during initialize rolls back running',
      () async {
        final mocks = coreMocks();
        when(() => mocks.api.resetTraffic()).thenAnswer((_) async {});
        when(() => _applied(mocks.api)).thenAnswer((_) async => const []);
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
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
        verify(() => _applied(mocks.api)).called(1);
      },
    );

    test(
      'a non-empty setupConfig message during initialize rolls back running',
      () async {
        final mocks = coreMocks();
        when(() => mocks.api.resetTraffic()).thenAnswer((_) async {});
        when(() => _applied(mocks.api)).thenAnswer(
          (_) async => throw const CoreMethodException(
            code: 'config_rejected',
            message: 'config rejected',
          ),
        );
        final scoped = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupStateProvider.overrideWith((_, _) => nullProfileSetupState),
            coreHandlerProvider.overrideWithValue(mocks.controller),
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
        verify(() => _applied(mocks.api)).called(1);
      },
    );
  });
}
