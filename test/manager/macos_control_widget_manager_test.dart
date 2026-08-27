import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/manager/macos_control_widget_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('$packageName/macos_control_widget');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialization consumes a pending start action', () async {
    final calls = <MethodCall>[];
    final proxyStates = <ProxyState>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'getPendingAction') {
            return 'start';
          }
          return null;
        });
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => null),
        profilesProvider.overrideWith(() => _TestProfiles([])),
        initProvider.overrideWithBuild((_, _) => false),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (state) async => proxyStates.add(state),
    );
    addTearDown(manager.dispose);
    await manager.init(container);

    final action =
        container.read(setupActionProvider.notifier) as _RecordingSetupAction;
    expect(action.requests, [const _RunRequestRecord(true, true)]);
    expect(calls.map((call) => call.method), contains('getPendingAction'));
    expect(
      calls
          .where((call) => call.method == 'setRunningState')
          .map((call) => call.arguments as Map)
          .map((arguments) => arguments['running']),
      contains(true),
    );
    expect(proxyStates.single.isStart, isTrue);
    expect(proxyStates.single.systemProxy, isTrue);
  });

  test('running state changes are synced to native shared state', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'getPendingAction') {
            return null;
          }
          return null;
        });
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => null),
        profilesProvider.overrideWith(() => _TestProfiles([])),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (_) async {},
    );
    addTearDown(manager.dispose);
    await manager.init(container);
    container.read(runTimeProvider.notifier).value = 1;
    await Future<void>.delayed(Duration.zero);
    container.read(runTimeProvider.notifier).value = null;
    await Future<void>.delayed(Duration.zero);

    expect(
      calls
          .where((call) => call.method == 'setWidgetStatus')
          .map((call) => call.arguments),
      [
        {
          'running': false,
          'profileId': null,
          'profileName': '',
          'hasProfile': false,
        },
        {
          'running': false,
          'profileId': null,
          'profileName': '',
          'hasProfile': false,
        },
        {
          'running': true,
          'profileId': null,
          'profileName': '',
          'hasProfile': false,
        },
        {
          'running': false,
          'profileId': null,
          'profileName': '',
          'hasProfile': false,
        },
      ],
    );
  });

  test('current profile state is synced to native shared state', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'getPendingAction') {
            return null;
          }
          return null;
        });
    final profile = Profile.normal(label: 'US LA GPT');
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => _TestProfiles([profile])),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (_) async {},
    );
    addTearDown(manager.dispose);
    await manager.init(container);
    await Future<void>.delayed(Duration.zero);

    expect(
      calls
          .where((call) => call.method == 'setWidgetStatus')
          .map((call) => call.arguments),
      anyElement(
        isA<Map>()
            .having((arguments) => arguments['running'], 'running', false)
            .having(
              (arguments) => arguments['profileId'],
              'profileId',
              profile.id,
            )
            .having(
              (arguments) => arguments['profileName'],
              'profileName',
              'US LA GPT',
            )
            .having((arguments) => arguments['hasProfile'], 'hasProfile', true),
      ),
    );
  });

  test('silent launch state is read from native shared state', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'isSilentLaunchRequested') {
            return true;
          }
          return null;
        });

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (_) async {},
    );
    addTearDown(manager.dispose);

    expect(await manager.isSilentLaunchRequested(), isTrue);
    expect(calls.map((call) => call.method), ['isSilentLaunchRequested']);
  });

  test('window presentation can be explicitly allowed', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (_) async {},
    );
    addTearDown(manager.dispose);

    await manager.allowWindowPresentation();

    expect(calls.map((call) => call.method), ['allowWindowPresentation']);
  });

  test(
    'pending action retries after native channel becomes available',
    () async {
      final calls = <MethodCall>[];
      final proxyStates = <ProxyState>[];
      var getPendingActionAttempts = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'getPendingAction') {
              getPendingActionAttempts++;
              if (getPendingActionAttempts == 1) {
                throw MissingPluginException();
              }
              return 'start';
            }
            return null;
          });
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => _TestProfiles([])),
          initProvider.overrideWithBuild((_, _) => false),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
        ],
      );
      addTearDown(container.dispose);

      final manager = MacOSControlWidgetManager(
        channel: channel,
        syncProxy: (state) async => proxyStates.add(state),
      );
      addTearDown(manager.dispose);
      await manager.init(container);
      await manager.performPendingAction();

      final action =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      expect(getPendingActionAttempts, 2);
      expect(action.requests, [const _RunRequestRecord(true, true)]);
      expect(proxyStates.single.isStart, isTrue);
      expect(calls.map((call) => call.method), contains('getPendingAction'));
    },
  );

  test('pending refresh action updates the current profile', () async {
    final calls = <MethodCall>[];
    final refreshes = <ProviderContainer>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'getPendingAction') {
            return 'refreshProfile';
          }
          return null;
        });
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => null),
        profilesProvider.overrideWith(() => _TestProfiles([])),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);

    final manager = MacOSControlWidgetManager(
      channel: channel,
      syncProxy: (_) async {},
      refreshCurrentProfile: (container) async => refreshes.add(container),
    );
    addTearDown(manager.dispose);
    await manager.init(container);

    expect(refreshes, [container]);
    expect(calls.map((call) => call.method), contains('getPendingAction'));
  });
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles(this.initial);

  @override
  List<Profile> build() => initial;

  @override
  void put(Profile profile) {
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
  void setAndReorder(List<Profile> profiles) {
    state = List.of(profiles);
  }
}

class _RecordingSetupAction extends SetupAction {
  final requests = <_RunRequestRecord>[];

  @override
  Future<void> setRunning(bool running, {bool initialize = false}) {
    requests.add(_RunRequestRecord(running, initialize));
    ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    return Future.value();
  }
}

class _RunRequestRecord {
  final bool running;
  final bool initialize;

  const _RunRequestRecord(this.running, this.initialize);

  @override
  bool operator ==(Object other) {
    return other is _RunRequestRecord &&
        other.running == running &&
        other.initialize == initialize;
  }

  @override
  int get hashCode => Object.hash(running, initialize);

  @override
  String toString() {
    return '_RunRequestRecord(running: $running, initialize: $initialize)';
  }
}
