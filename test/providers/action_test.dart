import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/views/dashboard/widgets/free_nodes_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('ProfilesAction', () {
    setUp(() async {
      await preferences.setBool(freeNodesDisabledKey, false);
    });

    test('keeps edited profile data when remote update fails', () async {
      final original = Profile.normal(
        label: 'old label',
        url: 'bad-url',
      ).copyWith(sourceUrl: 'https://old.example.com');
      final edited = original.copyWith(
        label: 'new label',
        url: 'still-bad-url',
        sourceUrl: 'https://source.example.com/profile',
      );
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => _TestProfiles([original])),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(profilesProvider).getProfile(original.id),
        original,
      );

      await expectLater(
        container.read(profilesActionProvider.notifier).updateProfile(edited),
        throwsA(anything),
      );

      final profile = container.read(profilesProvider).getProfile(original.id);
      expect(profile?.label, edited.label);
      expect(profile?.url, edited.url);
      expect(profile?.sourceUrl, edited.sourceUrl);
    });

    test('does not delete the built-in free nodes profile', () async {
      final profile = freeNodesService.createProfile();
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profilesProvider.overrideWith(() => _TestProfiles([profile])),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(profilesActionProvider.notifier)
          .deleteProfile(profile.id);

      expect(container.read(profilesProvider), [profile]);
      expect(container.read(currentProfileIdProvider), profile.id);
    });

    test(
      'creates and selects the free nodes profile on first launch',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            profilesProvider.overrideWith(() => _TestProfiles([])),
          ],
        );
        addTearDown(container.dispose);

        final startedVisibleCheck = await container
            .read(profilesActionProvider.notifier)
            .ensureFreeNodesProfile(update: false);

        final profiles = container.read(profilesProvider);
        expect(profiles.length, 1);
        expect(profiles.single.isFreeNodesProfile, true);
        expect(container.read(currentProfileIdProvider), profiles.single.id);
        expect(startedVisibleCheck, false);
        expect(profiles.single.autoUpdate, true);
      },
    );

    test('startup ensure respects disabled free nodes auto update', () async {
      final profile = freeNodesService.createProfile().copyWith(
        autoUpdate: false,
      );
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profilesProvider.overrideWith(() => _TestProfiles([profile])),
        ],
      );
      addTearDown(container.dispose);

      final started = await container
          .read(profilesActionProvider.notifier)
          .ensureFreeNodesProfile();

      expect(started, false);
      expect(container.read(itemProvider(freeNodesProgressKey)), isNull);
    });

    test(
      'keeps and selects free nodes profile when reset is requested',
      () async {
        await preferences.setBool(freeNodesDisabledKey, true);
        final profile = freeNodesService.createProfile();
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
          ],
        );
        addTearDown(container.dispose);
        await container
            .read(profilesActionProvider.notifier)
            .removeFreeNodesProfile(update: false);

        final profiles = container.read(profilesProvider);
        expect(profiles, [profile]);
        expect(container.read(currentProfileIdProvider), profile.id);
        expect(await preferences.getBool(freeNodesDisabledKey), false);
      },
    );

    test(
      'recreates free nodes profile when a legacy delete flag exists',
      () async {
        await preferences.setBool(freeNodesDisabledKey, true);
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            profilesProvider.overrideWith(() => _TestProfiles([])),
          ],
        );
        addTearDown(container.dispose);

        final startedVisibleCheck = await container
            .read(profilesActionProvider.notifier)
            .ensureFreeNodesProfile(update: false);

        final profiles = container.read(profilesProvider);
        expect(profiles.length, 1);
        expect(profiles.single.isFreeNodesProfile, true);
        expect(container.read(currentProfileIdProvider), profiles.single.id);
        expect(await preferences.getBool(freeNodesDisabledKey), false);
        expect(startedVisibleCheck, false);
      },
    );

    test(
      'selects free nodes profile when the saved current profile is stale',
      () async {
        final profile = freeNodesService.createProfile();
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => 404),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
          ],
        );
        addTearDown(container.dispose);

        final startedVisibleCheck = await container
            .read(profilesActionProvider.notifier)
            .ensureFreeNodesProfile(update: false);

        expect(container.read(currentProfileIdProvider), profile.id);
        expect(startedVisibleCheck, false);
      },
    );

    test(
      'does not persist a free nodes profile before remote update succeeds',
      () {
        final normalProfile = Profile.normal(
          label: 'remote',
          url: 'https://example.com/profile.yaml',
        );
        final freeNodesProfile = freeNodesService.createProfile();

        expect(shouldPersistProfileBeforeRemoteUpdate(normalProfile), true);
        expect(shouldPersistProfileBeforeRemoteUpdate(freeNodesProfile), false);
      },
    );

    test(
      'profile selection only checks auto update for a different enabled free nodes profile',
      () {
        expect(
          shouldCheckFreeNodesAutoUpdateOnProfileSelection(
            currentProfileId: 1,
            selectedProfileId: 2,
            isFreeNodesProfile: true,
            autoUpdate: true,
          ),
          true,
        );
        expect(
          shouldCheckFreeNodesAutoUpdateOnProfileSelection(
            currentProfileId: 2,
            selectedProfileId: 2,
            isFreeNodesProfile: true,
            autoUpdate: true,
          ),
          false,
        );
        expect(
          shouldCheckFreeNodesAutoUpdateOnProfileSelection(
            currentProfileId: 1,
            selectedProfileId: 2,
            isFreeNodesProfile: false,
            autoUpdate: true,
          ),
          false,
        );
        expect(
          shouldCheckFreeNodesAutoUpdateOnProfileSelection(
            currentProfileId: 1,
            selectedProfileId: 2,
            isFreeNodesProfile: true,
            autoUpdate: false,
          ),
          false,
        );
      },
    );

    test(
      'selecting a free nodes profile with auto update disabled does not start a check',
      () async {
        final normal = Profile.normal(label: 'normal');
        final freeNodes = freeNodesService.createProfile().copyWith(
          autoUpdate: false,
        );
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => normal.id),
            profilesProvider.overrideWith(
              () => _TestProfiles([normal, freeNodes]),
            ),
          ],
        );
        addTearDown(container.dispose);
        final currentProfileSubscription = container.listen<int?>(
          currentProfileIdProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(currentProfileSubscription.close);

        final checked = await container
            .read(profilesActionProvider.notifier)
            .selectProfile(freeNodes.id);

        expect(container.read(currentProfileIdProvider), freeNodes.id);
        expect(container.read(itemProvider(freeNodesProgressKey)), isNull);
        expect(checked, false);
      },
    );

    test(
      'selecting an enabled free nodes profile checks whether an update is needed',
      () async {
        final normal = Profile.normal(label: 'normal');
        final now = DateTime.now();
        final freeNodes = freeNodesService.createProfile().copyWith(
          lastUpdateDate: now.subtract(const Duration(days: 1)),
          autoUpdate: true,
          subscriptionInfo: const SubscriptionInfo(total: 1),
        );
        final profileFile = await freeNodes.existingFile;
        await profileFile.parent.create(recursive: true);
        await profileFile.writeAsString('''
proxies:
  - {name: test-node, type: ss, server: 127.0.0.1, port: 443, cipher: aes-128-gcm, password: test}
proxy-groups:
  - name: "日期 ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}"
    type: select
    proxies: [test-node]
''');
        final sourceOptions = await freeNodesService.getSourceOptions();
        await preferences.setString(
          freeNodesFetchTimesKey,
          json.encode({
            for (final option in sourceOptions)
              option.id: now.toIso8601String(),
          }),
        );
        addTearDown(() async {
          await preferences.setString(freeNodesFetchTimesKey, '{}');
          if (await profileFile.exists()) await profileFile.delete();
        });
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => normal.id),
            profilesProvider.overrideWith(
              () => _TestProfiles([normal, freeNodes]),
            ),
            groupsProvider.overrideWithBuild(
              (_, _) => const [Group(type: GroupType.Selector, name: 'loaded')],
            ),
          ],
        );
        addTearDown(container.dispose);
        final enabledCurrentProfileSubscription = container.listen<int?>(
          currentProfileIdProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(enabledCurrentProfileSubscription.close);
        final progressSubscription = container.listen<Object?>(
          itemProvider(freeNodesProgressKey),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(progressSubscription.close);

        final checked = await container
            .read(profilesActionProvider.notifier)
            .selectProfile(freeNodes.id);

        final progress = container.read(itemProvider(freeNodesProgressKey));
        expect(container.read(currentProfileIdProvider), freeNodes.id);
        expect(progress, isA<FreeNodesProgress>());
        expect((progress as FreeNodesProgress).operation, '已检查，无需更新');
        expect(progress.done, true);
        expect(checked, true);
      },
    );

    test(
      'duplicate ensure preserves terminal progress until active update cleanup',
      () async {
        final now = DateTime.now();
        final profile = freeNodesService.createProfile().copyWith(
          lastUpdateDate: now,
          autoUpdate: true,
          subscriptionInfo: const SubscriptionInfo(total: 5555),
        );
        final profileFile = await profile.existingFile;
        await profileFile.parent.create(recursive: true);
        await profileFile.writeAsString('''
proxies:
  - {name: test-node, type: ss, server: 127.0.0.1, port: 443, cipher: aes-128-gcm, password: test}
proxy-groups:
  - name: "日期 ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}"
    type: select
    proxies: [test-node]
''');
        final sourceOptions = await freeNodesService.getSourceOptions();
        await preferences.setString(
          freeNodesFetchTimesKey,
          json.encode({
            for (final option in sourceOptions)
              option.id: now.toIso8601String(),
          }),
        );
        addTearDown(() async {
          await preferences.setString(freeNodesFetchTimesKey, '{}');
          if (await profileFile.exists()) await profileFile.delete();
        });
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
            groupsProvider.overrideWithBuild(
              (_, _) => const [Group(type: GroupType.Selector, name: 'loaded')],
            ),
          ],
        );
        addTearDown(container.dispose);
        final progressSubscription = container.listen<Object?>(
          itemProvider(freeNodesProgressKey),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(progressSubscription.close);
        final action = container.read(profilesActionProvider.notifier);

        expect(await action.ensureFreeNodesProfile(), isTrue);
        const terminal = FreeNodesProgress(
          operation: '已完成',
          proxyCount: 5555,
          done: true,
        );
        container.read(itemProvider(freeNodesProgressKey).notifier).value =
            terminal;

        expect(await action.ensureFreeNodesProfile(update: false), isFalse);
        expect(
          container.read(itemProvider(freeNodesProgressKey)),
          same(terminal),
        );
        expect(await action.ensureFreeNodesProfile(), isTrue);
        expect(
          container.read(itemProvider(freeNodesProgressKey)),
          same(terminal),
        );

        await Future<void>.delayed(const Duration(milliseconds: 1300));
      },
    );
  });

  group('SetupAction port selection', () {
    test(
      'uses another mixed port when the preferred port is occupied',
      () async {
        final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(socket.close);

        final resolved = await resolveAvailableMixedPort(socket.port);

        expect(resolved, isNot(socket.port));
        expect(resolved, greaterThan(0));
      },
    );
  });

  group('SetupAction delay test controller', () {
    test(
      'opens only the loopback external controller for Rust delay tests',
      () {
        expect(ExternalControllerStatus.open.value, '127.0.0.1:9090');
        expect(ExternalControllerStatus.close.value, '');
      },
    );

    test(
      'waits until the local delay test controller port is listening',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        final ready = await waitForTcpEndpoint(
          '127.0.0.1:${server.port}',
          timeout: const Duration(milliseconds: 300),
          interval: const Duration(milliseconds: 20),
        );

        expect(ready, true);
      },
    );

    test(
      'does not report an unavailable delay test controller as ready',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final port = server.port;
        await server.close();

        final ready = await waitForTcpEndpoint(
          '127.0.0.1:$port',
          timeout: const Duration(milliseconds: 120),
          interval: const Duration(milliseconds: 20),
        );

        expect(ready, false);
      },
    );
  });

  group('Free nodes auto update decision', () {
    test('uses first-launch progress before async update checks finish', () {
      final progress = buildFreeNodesAutoUpdateStartProgress(
        firstLaunch: true,
        proxyCount: 0,
      );

      expect(progress.operation, '正在首次获取节点');
      expect(progress.proxyCount, 0);
      expect(progress.done, false);
    });

    test(
      'uses check progress before existing-profile update checks finish',
      () {
        final progress = buildFreeNodesAutoUpdateStartProgress(
          firstLaunch: false,
          proxyCount: 5555,
        );

        expect(progress.operation, '正在检查更新');
        expect(progress.proxyCount, 5555);
        expect(progress.done, false);
      },
    );

    test(
      'keeps visible running progress for duplicate auto update requests',
      () {
        final startedAt = DateTime(2026, 6, 20, 9);
        final current = FreeNodesProgress(
          operation: '正在更新到期来源',
          proxyCount: 5555,
          startedAt: startedAt,
        );

        final progress = buildFreeNodesAutoUpdateRunningProgress(
          proxyCount: 5000,
          currentProgress: current,
        );

        expect(progress.operation, '正在更新到期来源');
        expect(progress.proxyCount, 5555);
        expect(progress.startedAt, startedAt);
        expect(progress.done, false);
        expect(progress.error, false);
      },
    );

    test('keeps first-launch operation when auto update starts internally', () {
      final startedAt = DateTime(2026, 6, 20, 9);
      final current = FreeNodesProgress(
        operation: '正在首次获取节点',
        proxyCount: 0,
        startedAt: startedAt,
      );

      final progress = buildFreeNodesAutoUpdateRunningProgress(
        proxyCount: 0,
        currentProgress: current,
      );

      expect(progress.operation, '正在首次获取节点');
      expect(progress.startedAt, startedAt);
      expect(progress.done, false);
      expect(progress.error, false);
    });

    test(
      'creates visible progress when duplicate update has no active progress',
      () {
        final startedAt = DateTime(2026, 6, 20, 9);

        final progress = buildFreeNodesAutoUpdateRunningProgress(
          proxyCount: 5000,
          currentProgress: const FreeNodesProgress(
            operation: '已检查，无需更新',
            done: true,
          ),
          startedAt: startedAt,
        );

        expect(progress.operation, '正在检查更新');
        expect(progress.proxyCount, 5000);
        expect(progress.startedAt, startedAt);
        expect(progress.done, false);
        expect(progress.error, false);
      },
    );

    test('duplicate update preserves a terminal progress state', () {
      const completed = FreeNodesProgress(
        operation: '已完成',
        proxyCount: 5555,
        done: true,
      );

      final progress = buildFreeNodesAutoUpdateRunningProgress(
        proxyCount: 5555,
        currentProgress: completed,
        preserveTerminalProgress: true,
      );

      expect(progress, same(completed));
      expect(progress.done, isTrue);
      expect(progress.operation, '已完成');
    });

    test('uses actual time for no-op auto update checks', () {
      final startedAt = DateTime(2026, 6, 20, 9);
      final finishedAt = startedAt.add(const Duration(seconds: 3));

      final progress = buildFreeNodesAutoUpdateNoopProgress(
        proxyCount: 5555,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );

      expect(progress.operation, '已检查，无需更新');
      expect(progress.proxyCount, 5555);
      expect(progress.done, true);
      expect(progress.startedAt, startedAt);
      expect(progress.finishedAt, finishedAt);
    });

    test(
      'keeps due-source wording while fetch progress reports technical work',
      () {
        final startedAt = DateTime(2026, 6, 20, 9);
        final progress = buildFreeNodesAutoUpdateFetchProgress(
          progress: const FreeNodesProgress(
            operation: 'Rust 高并发获取免费节点',
            completed: 8,
            total: 16,
            proxyCount: 1500,
          ),
          runningOperation: '正在更新到期来源',
          startedAt: startedAt,
          proxyCount: 1200,
        );

        expect(progress.operation, '正在更新到期来源');
        expect(progress.completed, 8);
        expect(progress.total, 16);
        expect(progress.proxyCount, 1500);
        expect(progress.startedAt, startedAt);
        expect(progress.done, false);
        expect(progress.error, false);
      },
    );

    test('keeps automatic first launch wording before first fetch result', () {
      final startedAt = DateTime(2026, 6, 20, 9);
      final progress = buildFreeNodesAutoUpdateFetchProgress(
        progress: const FreeNodesProgress(
          operation: '开始获取节点',
          completed: 0,
          total: 64,
        ),
        runningOperation: '正在首次获取节点',
        startedAt: startedAt,
        proxyCount: 0,
      );

      expect(progress.operation, '正在首次获取节点');
      expect(progress.completed, 0);
      expect(progress.total, 64);
      expect(progress.startedAt, startedAt);
      expect(progress.value, isNull);
    });

    test('uses completed fetch wording after automatic update finishes', () {
      final startedAt = DateTime(2026, 6, 20, 9);
      final progress = buildFreeNodesAutoUpdateFetchProgress(
        progress: FreeNodesProgress(
          operation: '已完成',
          completed: 16,
          total: 16,
          proxyCount: 1800,
          done: true,
          finishedAt: startedAt.add(const Duration(seconds: 7)),
        ),
        runningOperation: '正在更新到期来源',
        startedAt: startedAt,
        proxyCount: 1200,
      );

      expect(progress.operation, '已完成');
      expect(progress.proxyCount, 1800);
      expect(progress.startedAt, startedAt);
      expect(progress.finishedAt, startedAt.add(const Duration(seconds: 7)));
      expect(progress.done, true);
    });

    test('keeps automatic no-op checks visible for a minimum duration', () {
      final startedAt = DateTime(2026, 6, 20, 9);

      expect(
        remainingFreeNodesAutoUpdateVisibleDelay(
          startedAt: startedAt,
          now: startedAt.add(const Duration(milliseconds: 300)),
        ),
        const Duration(milliseconds: 900),
      );
      expect(
        remainingFreeNodesAutoUpdateVisibleDelay(
          startedAt: startedAt,
          now: startedAt.add(const Duration(milliseconds: 1300)),
        ),
        Duration.zero,
      );
    });

    test(
      'checks profile file existence without creating an empty file',
      () async {
        final profile = freeNodesService.createProfile();
        final initialFile = await profile.existingFile;
        if (await initialFile.exists()) {
          await initialFile.delete();
        }
        addTearDown(() async {
          final cleanupFile = await profile.existingFile;
          if (await cleanupFile.exists()) {
            await cleanupFile.delete();
          }
        });

        final checkedFile = await profile.existingFile;

        expect(await checkedFile.exists(), false);

        final createdFile = await profile.file;
        expect(await createdFile.exists(), true);
      },
    );

    test('updates all sources on first launch', () {
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: false,
        hasLastUpdateDate: false,
        hasDueSources: false,
      );

      expect(decision.kind, FreeNodesAutoUpdateKind.firstFetch);
      expect(decision.operation, '正在首次获取节点');
      expect(decision.shouldFetchAllSources, true);
      expect(
        shouldAutoUpdateFreeNodesProfile(
          fileExists: false,
          hasLastUpdateDate: false,
          hasDueSources: false,
        ),
        true,
      );
    });

    test('updates existing free nodes profile when update record is missing', () {
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: true,
        hasLastUpdateDate: false,
        hasDueSources: false,
      );

      expect(decision.kind, FreeNodesAutoUpdateKind.firstFetch);
      expect(decision.operation, '正在首次获取节点');
      expect(decision.shouldFetchAllSources, true);
      expect(
        shouldAutoUpdateFreeNodesProfile(
          fileExists: true,
          hasLastUpdateDate: false,
          hasDueSources: false,
        ),
        true,
        reason:
            'an existing config without lastUpdateDate is still an unverified first-run state',
      );
    });

    test('existing profile checks only when no source is due', () {
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: true,
        hasLastUpdateDate: true,
        hasDueSources: false,
      );

      expect(decision.kind, FreeNodesAutoUpdateKind.checkOnly);
      expect(decision.operation, '正在检查更新');
      expect(decision.shouldFetchAllSources, false);

      expect(
        shouldAutoUpdateFreeNodesProfile(
          fileExists: true,
          hasLastUpdateDate: true,
          hasDueSources: false,
        ),
        false,
      );
    });

    test('updates only due sources regardless of the calendar day', () {
      final decision = resolveFreeNodesAutoUpdateDecision(
        fileExists: true,
        hasLastUpdateDate: true,
        hasDueSources: true,
      );

      expect(decision.kind, FreeNodesAutoUpdateKind.dueSources);
      expect(decision.operation, '正在更新到期来源');
      expect(decision.shouldFetchAllSources, false);
      expect(
        shouldAutoUpdateFreeNodesProfile(
          fileExists: true,
          hasLastUpdateDate: true,
          hasDueSources: true,
        ),
        true,
        reason:
            'source schedules, not app entry or date categories, decide updates',
      );
    });

    test('applies current free nodes after no-op when core groups are empty', () {
      expect(
        shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: true,
          shouldUpdate: false,
          hasLoadedGroups: false,
        ),
        true,
        reason:
            'startup can have a valid free nodes profile file while the core has not loaded any groups yet',
      );
      expect(
        shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: true,
          shouldUpdate: false,
          hasLoadedGroups: true,
        ),
        false,
        reason: 'avoid reloading the core when groups are already available',
      );
      expect(
        shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: false,
          shouldUpdate: false,
          hasLoadedGroups: false,
        ),
        false,
      );
      expect(
        shouldApplyCurrentFreeNodesProfileAfterNoopAutoUpdate(
          isCurrentProfile: true,
          shouldUpdate: true,
          hasLoadedGroups: false,
        ),
        false,
      );
    });

    test(
      'can skip free nodes when startup already triggered visible check',
      () async {
        final profile = freeNodesService.createProfile();
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
          ],
        );
        addTearDown(container.dispose);
        final progressSubscription = container.listen(
          itemProvider(freeNodesProgressKey),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(progressSubscription.close);

        await container
            .read(profilesActionProvider.notifier)
            .autoUpdateProfiles(includeFreeNodes: false);

        expect(container.read(itemProvider(freeNodesProgressKey)), isNull);
        expect(container.read(profilesProvider), [profile]);
      },
    );

    test(
      'existing free nodes startup check is visually updating before no-op finishes',
      () async {
        final now = DateTime.now();
        final sourceOptions = await freeNodesService.getSourceOptions();
        await preferences.setString(
          freeNodesFetchTimesKey,
          json.encode({
            for (final option in sourceOptions)
              if (option.updateIntervalHours < 24)
                option.id: now.toIso8601String(),
          }),
        );
        final profile = freeNodesService.createProfile().copyWith(
          lastUpdateDate: now,
          subscriptionInfo: const SubscriptionInfo(total: 1234),
          autoUpdate: true,
        );
        final profileFile = await profile.file;
        await profileFile.writeAsString(
          'proxies: []\nproxy-groups: []\nrules: []\n',
        );
        addTearDown(() async {
          if (await profileFile.exists()) {
            await profileFile.delete();
          }
        });
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
            profilesProvider.overrideWith(() => _TestProfiles([profile])),
          ],
        );
        addTearDown(container.dispose);

        final startedVisibleCheck = await container
            .read(profilesActionProvider.notifier)
            .ensureFreeNodesProfile();

        final visibleProgress =
            container.read(itemProvider(freeNodesProgressKey))
                as FreeNodesProgress;
        expect(visibleProgress.operation, '正在检查更新');
        expect(
          buildFreeNodesVisibleUpdating(
            progress: visibleProgress,
            isUpdating: false,
          ),
          true,
        );
        expect(
          buildFreeNodesStatusText(
            profile: profile,
            progress: visibleProgress,
            isUpdating: false,
            proxyCount: profile.subscriptionInfo?.total ?? 0,
          ),
          '检查更新中',
        );
        expect(container.read(isUpdatingProvider(profile.updatingKey)), true);
        expect(startedVisibleCheck, true);

        await Future<void>.delayed(Duration.zero);
      },
    );
  });

  group('Reality option sanitation', () {
    test('normalizes public-key and removes invalid short-id', () {
      final config = {
        'proxies': [
          {
            'name': 'bad',
            'type': 'vless',
            'reality-opts': {
              'public-key': '%2DFQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY',
              'short-id': 'Infinity',
            },
          },
          {
            'name': 'good',
            'type': 'vless',
            'reality-opts': {'short-id': 'abcd'},
          },
        ],
      };

      sanitizeRealityShortIds(config);

      final proxies = config['proxies'] as List;
      final badRealityOpts = proxies[0]['reality-opts'] as Map;
      final goodRealityOpts = proxies[1]['reality-opts'] as Map;
      expect(badRealityOpts.containsKey('short-id'), false);
      expect(
        badRealityOpts['public-key'],
        '-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY',
      );
      expect(goodRealityOpts['short-id'], 'abcd');
    });

    test('removes reality opts with invalid public-key', () {
      final config = {
        'proxies': [
          {
            'name': 'bad',
            'type': 'vless',
            'reality-opts': {
              'public-key': 'not-a-public-key',
              'short-id': 'abcd',
            },
          },
        ],
      };

      sanitizeRealityShortIds(config);

      final proxies = config['proxies'] as List;
      expect(proxies[0].containsKey('reality-opts'), false);
    });
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
  void del(int id) {
    state = state.where((profile) => profile.id != id).toList();
  }
}
