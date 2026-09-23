import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

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
    await testDatabase.profiles.put(profile.toCompanion());
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        setupActionProvider.overrideWith(() => setup),
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

  test('a proxy provider no group uses does not reapply', () async {
    action().putProvider(proxies);
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

    action().putProvider(proxies);
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

    action().putProvider(proxies.copyWith(label: 'Renamed'), previous: proxies);
    await pumpEventQueue();

    expect(setup.applies, 1);
  });

  test('deleting a rule set a rule references reapplies', () async {
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

    action().delProvider(rules);
    await pumpEventQueue();

    expect(setup.applies, 1);
  });

  test('a rule set no rule references does not reapply', () async {
    action().putProvider(rules);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test('a standard overwrite never reapplies for a provider', () async {
    container.read(currentProfileIdProvider.notifier).value = null;

    action().putProvider(proxies);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });
}
