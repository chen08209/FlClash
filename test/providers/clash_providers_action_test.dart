import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show basenameWithoutExtension;
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _RecordingSetupAction extends SetupAction {
  int applies = 0;

  @override
  void applyProfileDebounce({bool silence = false, bool force = false}) {
    applies++;
  }
}

/// Only a change the current custom overwrite can see is worth a reapply.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profileId = 1;
  const standardProfileId = 2;
  const proxies = ClashProvider(
    id: 10,
    kind: ProviderKind.proxy,
    label: 'Shared nodes',
    url: 'https://example.com/nodes.yaml',
  );
  const rules = ClashProvider(
    id: 11,
    kind: ProviderKind.rule,
    label: 'Ad block',
    behavior: RuleProviderBehavior.domain,
    format: RuleProviderFormat.text,
  );

  late Directory home;
  late db.Database testDatabase;
  late ProviderContainer container;
  late _RecordingSetupAction setup;
  late Map<int, Map<String, dynamic>> subscriptions;

  setUpAll(() {
    home = Directory.systemTemp.createTempSync('flclash-providers-action-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    AppPath.downloadDirectory = () async => home;
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() async {
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    setup = _RecordingSetupAction();
    const profile = Profile(
      id: profileId,
      label: 'Custom',
      autoUpdateDuration: Duration.zero,
      overwriteType: OverwriteType.custom,
    );
    const standardProfile = Profile(
      id: standardProfileId,
      label: 'Standard',
      autoUpdateDuration: Duration.zero,
    );
    await testDatabase.profiles.put(profile.toCompanion());
    await testDatabase.profiles.put(standardProfile.toCompanion());
    subscriptions = {};
    final core = _MockCoreHandlerInterface();
    when(() => core.getConfig(any())).thenAnswer((invocation) async {
      final path = invocation.positionalArguments.single as String;
      return subscriptions[int.parse(basenameWithoutExtension(path))] ?? {};
    });
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([profile, standardProfile]),
        ),
        setupActionProvider.overrideWith(() => setup),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    container.listen(currentProfileProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value = profileId;
    container.listen(clashProvidersProvider(ProviderKind.proxy), (_, _) {});
    container.listen(clashProvidersProvider(ProviderKind.rule), (_, _) {});
    await pumpEventQueue();
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  ClashProvidersAction action() =>
      container.read(clashProvidersActionProvider.notifier);

  Future<void> useIn(int owner, String name, {required int id}) async {
    await testDatabase.proxyGroups.put(
      ProxyGroup(
        id: id,
        name: 'Auto',
        type: GroupType.URLTest,
        use: [name],
        order: 'a',
      ).toCompanion(owner),
    );
  }

  Future<void> ruleSetIn(int owner, String name, {required int id}) async {
    await testDatabase.rulesDao.putProfileCustomRule(
      owner,
      Rule(
        id: id,
        ruleAction: RuleAction.RULE_SET,
        ruleProvider: name,
        ruleTarget: 'DIRECT',
        order: 'a',
      ),
    );
  }

  Future<List<String>?> useOf(int owner) async =>
      (await testDatabase.proxyGroupsDao.query(owner).get()).single.use;

  Future<String?> ruleSetOf(int owner) async =>
      (await testDatabase.rulesDao.queryProfileCustomRules(owner).get())
          .single
          .ruleProvider;

  test('a proxy provider no group uses does not reapply', () async {
    await action().putProvider(proxies);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test('a proxy provider a group uses reapplies', () async {
    await testDatabase.proxyGroups.put(
      const ProxyGroup(
        id: 20,
        name: 'Auto',
        type: GroupType.URLTest,
        use: ['Shared nodes'],
        order: 'a',
      ).toCompanion(profileId),
    );

    await action().putProvider(proxies);
    await pumpEventQueue();

    expect(setup.applies, 1);
  });

  test('renaming a used provider reapplies under its old name', () async {
    await testDatabase.proxyGroups.put(
      const ProxyGroup(
        id: 20,
        name: 'Auto',
        type: GroupType.URLTest,
        use: ['Shared nodes'],
        order: 'a',
      ).toCompanion(profileId),
    );

    await action().putProvider(
      proxies.copyWith(label: 'Renamed'),
      previous: proxies,
    );
    await pumpEventQueue();

    expect(setup.applies, 1);
  });

  test('a rule set a rule still references is kept', () async {
    await testDatabase.rulesDao.putProfileCustomRule(
      profileId,
      const Rule(
        id: 30,
        ruleAction: RuleAction.RULE_SET,
        ruleProvider: 'Ad block',
        ruleTarget: 'DIRECT',
        order: 'a',
      ),
    );
    await testDatabase.clashProvidersDao.putAll([rules.toCompanion()]);
    await pumpEventQueue();

    final users = await action().delProvider(rules);
    await pumpEventQueue();

    expect(users.map((profile) => profile.id), [profileId]);
    expect(
      (await testDatabase.clashProvidersDao.query(ProviderKind.rule).get()).map(
        (provider) => provider.id,
      ),
      [rules.id],
    );
    expect(setup.applies, 0);
  });

  test('a provider names every profile whose groups still use it', () async {
    for (final (id, owner) in [(20, profileId), (21, standardProfileId)]) {
      await testDatabase.proxyGroups.put(
        ProxyGroup(
          id: id,
          name: 'Auto',
          type: GroupType.URLTest,
          use: const ['Shared nodes'],
          order: 'a',
        ).toCompanion(owner),
      );
    }

    expect(
      (await action().profilesUsing(proxies)).map((profile) => profile.id),
      [profileId, standardProfileId],
    );
    expect(await action().profilesUsing(rules), isEmpty);
  });

  test('a proxy provider a profile of its name stands in for can go', () async {
    await testDatabase.proxyGroups.put(
      const ProxyGroup(
        id: 20,
        name: 'Auto',
        type: GroupType.URLTest,
        use: ['Shared nodes'],
        order: 'a',
      ).toCompanion(profileId),
    );
    await testDatabase.clashProvidersDao.putAll([proxies.toCompanion()]);
    container
        .read(profilesProvider.notifier)
        .put(
          const Profile(
            id: 3,
            label: 'Shared nodes',
            autoUpdateDuration: Duration.zero,
          ),
        );
    await pumpEventQueue();

    expect(await action().delProvider(proxies), isEmpty);
    await pumpEventQueue();

    expect(
      await testDatabase.clashProvidersDao.query(ProviderKind.proxy).get(),
      isEmpty,
    );
  });

  test('a rule set no rule references does not reapply', () async {
    await action().putProvider(rules);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test('a standard overwrite never reapplies for a provider', () async {
    container.read(currentProfileIdProvider.notifier).value = null;

    await action().putProvider(proxies);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test(
    'a subscription with the name keeps its profile off the users',
    () async {
      await useIn(profileId, 'Shared nodes', id: 20);
      await useIn(standardProfileId, 'Shared nodes', id: 21);
      await ruleSetIn(standardProfileId, 'Ad block', id: 30);
      subscriptions[standardProfileId] = {
        'proxy-providers': {'Shared nodes': <String, dynamic>{}},
        'rule-providers': {'Ad block': <String, dynamic>{}},
      };

      expect(
        (await action().profilesUsing(proxies)).map((profile) => profile.id),
        [profileId],
      );
      expect(await action().profilesUsing(rules), isEmpty);
    },
  );

  test('a rename follows only the references that reach the app one', () async {
    await testDatabase.clashProvidersDao.putAll([
      proxies.toCompanion(),
      rules.toCompanion(),
    ]);
    await useIn(profileId, 'Shared nodes', id: 20);
    await useIn(standardProfileId, 'Shared nodes', id: 21);
    await ruleSetIn(profileId, 'Ad block', id: 30);
    await ruleSetIn(standardProfileId, 'Ad block', id: 31);
    subscriptions[standardProfileId] = {
      'proxy-providers': {'Shared nodes': <String, dynamic>{}},
      'rule-providers': {'Ad block': <String, dynamic>{}},
    };
    await pumpEventQueue();

    expect(
      await action().putProvider(
        proxies.copyWith(label: 'Renamed "nodes"'),
        previous: proxies,
      ),
      isEmpty,
    );
    expect(
      await action().putProvider(
        rules.copyWith(label: 'Renamed rules'),
        previous: rules,
      ),
      isEmpty,
    );
    await pumpEventQueue();

    expect(await useOf(profileId), ['Renamed "nodes"']);
    expect(await useOf(standardProfileId), ['Shared nodes']);
    expect(await ruleSetOf(profileId), 'Renamed rules');
    expect(await ruleSetOf(standardProfileId), 'Ad block');
  });

  test('a rename onto a name a user subscription has is refused', () async {
    await testDatabase.clashProvidersDao.putAll([proxies.toCompanion()]);
    await useIn(profileId, 'Shared nodes', id: 20);
    subscriptions[profileId] = {
      'proxy-providers': {'Taken': <String, dynamic>{}},
    };
    await pumpEventQueue();

    final conflicts = await action().putProvider(
      proxies.copyWith(label: 'Taken'),
      previous: proxies,
    );
    await pumpEventQueue();

    expect(conflicts.map((profile) => profile.id), [profileId]);
    expect(
      (await testDatabase.clashProvidersDao.query(ProviderKind.proxy).get())
          .single
          .label,
      'Shared nodes',
    );
    expect(await useOf(profileId), ['Shared nodes']);
    expect(setup.applies, 0);
  });

  group('a profile as a provider', () {
    const home = Profile(
      id: 3,
      label: 'Home',
      autoUpdateDuration: Duration.zero,
    );

    setUp(() async {
      container.read(profilesProvider.notifier).put(home);
      await useIn(profileId, 'Home', id: 20);
      await useIn(standardProfileId, 'Home', id: 21);
      subscriptions[standardProfileId] = {
        'proxy-providers': {'Home': <String, dynamic>{}},
      };
    });

    tearDown(() => feature = const Feature());

    ProfilesAction profiles() =>
        container.read(profilesActionProvider.notifier);

    test('has no users while custom providers are off', () async {
      expect(await profiles().providerUsers(home), isEmpty);
      final rename = await profiles().providerRename(
        home,
        home.copyWith(label: 'Away'),
      );
      expect(rename.renameIn, isEmpty);
    });

    test('is used by the profiles its label reaches', () async {
      feature = const Feature(customProviders: true);

      expect(
        (await profiles().providerUsers(home)).map((profile) => profile.id),
        [profileId],
      );
      final rename = await profiles().providerRename(
        home,
        home.copyWith(label: 'Away'),
      );
      expect(rename.renameIn.map((profile) => profile.id), [profileId]);
      expect(rename.conflicts, isEmpty);
    });

    test('cannot take a label a user subscription has', () async {
      feature = const Feature(customProviders: true);
      subscriptions[profileId] = {
        'proxy-providers': {'Away': <String, dynamic>{}},
      };

      final rename = await profiles().providerRename(
        home,
        home.copyWith(label: 'Away'),
      );
      expect(rename.conflicts.map((profile) => profile.id), [profileId]);
    });
  });
}
