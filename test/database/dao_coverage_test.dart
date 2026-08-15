import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database database;

  setUp(() {
    database = Database(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'profiles DAO round-trips fields, ordering, filenames, and setAll',
    () async {
      final first = Profile(
        id: 1,
        label: 'First',
        currentGroupName: 'Selector',
        url: 'https://first.example',
        lastUpdateDate: DateTime(2026, 1, 2),
        autoUpdateDuration: const Duration(hours: 6),
        subscriptionInfo: const SubscriptionInfo(
          upload: 1,
          download: 2,
          total: 3,
          expire: 4,
        ),
        autoUpdate: false,
        selectedMap: const {'Selector': 'Proxy'},
        unfoldSet: const {'Selector'},
        overwriteType: OverwriteType.custom,
        scriptId: 7,
        order: 1,
      );
      const second = Profile(
        id: 2,
        label: 'Second',
        autoUpdateDuration: Duration.zero,
        order: 0,
      );

      await database.profilesDao.putAll([
        first.toCompanion(),
        second.toCompanion(),
      ]);

      final profiles = await database.profilesDao.query().get();
      expect(profiles.map((profile) => profile.id), [2, 1]);
      expect(profiles.last, first);
      expect(await database.profilesDao.fileNames().get(), [
        '1.yaml',
        '2.yaml',
      ]);
      expect(await database.profiles.count.getSingle(), 2);

      final replacement = first.copyWith(label: 'Replaced', order: 0);
      await database.profilesDao.setAll([replacement]);

      expect(await database.profilesDao.query().get(), [replacement]);
      expect(await database.profiles.remove((table) => table.id.equals(1)), 1);
      expect(await database.profiles.count.getSingle(), 0);
    },
  );

  test(
    'generated table managers create, filter, order, and update rows',
    () async {
      final date = DateTime.utc(2026, 7, 26);
      await database.managers.profiles.create(
        (row) => row(
          label: 'Managed profile',
          url: 'https://example.com/profile.yaml',
          overwriteType: OverwriteType.custom,
          autoUpdateDurationMillis: 60000,
          autoUpdate: true,
          selectedMap: const {'Proxy': 'DIRECT'},
          unfoldSet: const {'Proxy'},
        ),
      );
      await database.managers.scripts.create(
        (row) => row(label: 'Managed script', lastUpdateTime: date),
      );
      await database.managers.rules.create(
        (row) => row(
          ruleAction: RuleAction.DOMAIN,
          content: const Value('example.com'),
          ruleTarget: const Value('DIRECT'),
        ),
      );
      await database.managers.profileRuleLinks.create(
        (row) => row(id: 'managed', profileId: const Value(1), ruleId: 1),
      );
      await database.managers.proxyGroups.create(
        (row) => row(
          profileId: const Value(1),
          name: 'Managed group',
          type: GroupType.Selector.name,
          proxies: const Value(['DIRECT']),
        ),
      );
      await database.managers.iconRecords.create(
        (row) => row(url: 'https://example.com/icon.png', lastAccessed: 1),
      );

      final profiles = await database.managers.profiles
          .filter((row) => row.label.contains('Managed'))
          .orderBy((row) => row.label.asc())
          .get();
      expect(profiles.single.label, 'Managed profile');

      await database.managers.profiles
          .filter((row) => row.id.equals(profiles.single.id))
          .update((row) => row(label: const Value('Updated profile')));
      expect(
        (await database.managers.profiles
                .filter((row) => row.currentGroupName.isNull())
                .getSingle())
            .label,
        'Updated profile',
      );

      expect(
        await database.managers.scripts
            .filter((row) => row.lastUpdateTime.equals(date))
            .getSingle(),
        isA<RawScript>(),
      );
      expect(
        await database.managers.rules
            .filter((row) => row.content.equals('example.com'))
            .getSingle(),
        isA<RawRule>(),
      );
      expect(
        await database.managers.profileRuleLinks
            .filter((row) => row.scene.isNull())
            .getSingle(),
        isA<RawProfileRuleLink>(),
      );
      expect(
        await database.managers.proxyGroups
            .filter((row) => row.proxies.isNotNull())
            .getSingle(),
        isA<RawProxyGroup>(),
      );
      expect(
        await database.managers.iconRecords
            .filter((row) => row.lastAccessed.equals(1))
            .getSingle(),
        isA<IconRecord>(),
      );

      final profileWithReferences = await database.managers.profiles
          .withReferences(
            (prefetch) =>
                prefetch(profileRuleLinksRefs: true, proxyGroupsRefs: true),
          )
          .getSingle();
      expect(
        await profileWithReferences.$2.profileRuleLinksRefs.get(),
        hasLength(1),
      );
      expect(
        await profileWithReferences.$2.proxyGroupsRefs.get(),
        hasLength(1),
      );

      final ruleWithReferences = await database.managers.rules
          .withReferences((prefetch) => prefetch(profileRuleLinksRefs: true))
          .getSingle();
      expect(
        await ruleWithReferences.$2.profileRuleLinksRefs.get(),
        hasLength(1),
      );

      final linkWithReferences = await database.managers.profileRuleLinks
          .withReferences((prefetch) => prefetch(profileId: true, ruleId: true))
          .getSingle();
      expect((await linkWithReferences.$2.profileId?.getSingle())?.id, 1);
      expect((await linkWithReferences.$2.ruleId.getSingle()).id, 1);

      final groupWithReferences = await database.managers.proxyGroups
          .withReferences((prefetch) => prefetch(profileId: true))
          .getSingle();
      expect((await groupWithReferences.$2.profileId?.getSingle())?.id, 1);
    },
  );

  test(
    'scripts DAO supports insert, update, lookup, filenames, and replacement',
    () async {
      final first = Script(
        id: 10,
        label: 'First',
        lastUpdateTime: DateTime(2026),
      );
      final second = Script(
        id: 11,
        label: 'Second',
        lastUpdateTime: DateTime(2026, 2),
      );

      await database.scripts.put(first.toCompanion());
      expect(await database.scriptsDao.get(10).getSingle(), first);
      expect(await database.scriptsDao.fileNames().get(), ['10.js']);

      await database.scripts.put(
        first.copyWith(label: 'Updated').toCompanion(),
      );
      expect((await database.scriptsDao.get(10).getSingle()).label, 'Updated');

      await database.scriptsDao.setAll([second]);
      expect(await database.scriptsDao.query().get(), [second]);
      expect(await database.scriptsDao.get(10).getSingleOrNull(), null);
    },
  );

  test(
    'proxy groups DAO round-trips all options and rewrites proxy names',
    () async {
      const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
      const first = ProxyGroup(
        id: 20,
        name: 'Primary',
        type: GroupType.URLTest,
        proxies: ['Old', 'Backup'],
        use: ['provider'],
        interval: 60,
        lazy: true,
        disableUDP: true,
        url: 'https://group.example',
        timeout: 3000,
        maxFailedTimes: 2,
        filter: 'include',
        excludeFilter: 'exclude',
        excludeType: 'Direct',
        expectedStatus: '204',
        includeAll: true,
        includeAllProxies: false,
        includeAllProviders: true,
        hidden: false,
        icon: 'https://icon.example',
        order: 'a',
      );
      const second = ProxyGroup(
        id: 21,
        name: 'Secondary',
        type: GroupType.Selector,
        proxies: ['Primary'],
        order: 'b',
      );
      await database.profiles.put(profile.toCompanion());
      await database.proxyGroups.put(first.toCompanion(profile.id));
      await database.proxyGroups.put(second.toCompanion(profile.id));

      final groups = await database.proxyGroupsDao.query(profile.id).get();
      expect(groups.first, first.copyWith(profileId: profile.id));
      expect(await database.proxyGroupsDao.count(profile.id).getSingle(), 2);

      await database.proxyGroupsDao.renameProxies(
        profile.id,
        oldName: 'Primary',
        newName: 'Renamed',
      );
      expect(
        (await database.proxyGroupsDao.query(profile.id).get()).last.proxies,
        ['Renamed'],
      );

      await database.proxyGroupsDao.order(
        profile.id,
        proxyGroup: second,
        order: '0',
      );
      expect(
        (await database.proxyGroupsDao.query(profile.id).get()).first.name,
        'Secondary',
      );

      await database.batch((batch) {
        database.proxyGroupsDao.setAllWithBatch(profile.id, batch, [first]);
      });
      expect(
        (await database.proxyGroupsDao.query(profile.id).get()).single.name,
        'Primary',
      );
    },
  );

  test(
    'rules DAO handles global, added, custom, disabled, order, and rename',
    () async {
      const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
      const global = Rule(
        id: 30,
        ruleAction: RuleAction.DOMAIN,
        content: 'global.example',
        ruleTarget: 'DIRECT',
        order: 'b',
      );
      const added = Rule(
        id: 31,
        ruleAction: RuleAction.IP_CIDR,
        content: '10.0.0.0/8',
        ruleTarget: 'Proxy',
        noResolve: true,
        src: true,
        order: 'a',
      );
      const custom = Rule(
        id: 32,
        ruleAction: RuleAction.RULE_SET,
        ruleProvider: 'provider',
        ruleTarget: 'OldGroup',
        order: 'c',
      );
      await database.profiles.put(profile.toCompanion());
      await database.rulesDao.putGlobalRule(global);
      await database.rulesDao.putProfileAddedRule(profile.id, added);
      await database.rulesDao.putProfileCustomRule(profile.id, custom);

      expect(await database.rulesDao.queryGlobalAddedRules().get(), [global]);
      expect(await database.rulesDao.queryProfileAddedRules(profile.id).get(), [
        added,
      ]);
      expect(
        await database.rulesDao.queryProfileCustomRules(profile.id).get(),
        [custom],
      );
      expect(
        await database.rulesDao.profileCustomRulesCount(profile.id).getSingle(),
        1,
      );

      await database.rulesDao.putDisabledLink(profile.id, global.id);
      expect(
        (await database.rulesDao.queryProfileDisabledRules(profile.id).get())
            .single
            .id,
        global.id,
      );
      expect(
        (await database.rulesDao.queryAddedRules(profile.id).get()).map(
          (rule) => rule.id,
        ),
        [added.id],
      );
      expect(
        await database.rulesDao.delDisabledLink(profile.id, global.id),
        isTrue,
      );

      await database.rulesDao.orderGlobalRule(ruleId: global.id, order: '0');
      await database.rulesDao.orderProfileAddedRule(
        profile.id,
        ruleId: added.id,
        order: '1',
      );
      await database.rulesDao.orderProfileCustomRule(
        profile.id,
        ruleId: custom.id,
        order: '2',
      );
      await database.rulesDao.renameCustomRuleTarget(
        profile.id,
        oldName: 'OldGroup',
        newName: 'NewGroup',
      );
      expect(
        (await database.rulesDao.queryProfileCustomRules(profile.id).get())
            .single
            .ruleTarget,
        'NewGroup',
      );

      await database.rulesDao.resetOrders();
      await database.rulesDao.delRules([added.id, custom.id]);
      expect(
        await database.rulesDao.queryProfileAddedRules(profile.id).get(),
        isEmpty,
      );
      expect(
        await database.rulesDao.queryProfileCustomRules(profile.id).get(),
        isEmpty,
      );
    },
  );

  test('database restore and custom data replace related records', () async {
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    final script = Script(
      id: 40,
      label: 'Script',
      lastUpdateTime: DateTime(2026),
    );
    const rule = Rule(id: 41, content: 'example.com', ruleTarget: 'DIRECT');
    const link = ProfileRuleLink(
      profileId: 1,
      ruleId: 41,
      scene: RuleScene.custom,
    );
    const group = ProxyGroup(
      id: 42,
      profileId: 1,
      name: 'Group',
      type: GroupType.Selector,
      proxies: ['DIRECT'],
    );

    await database.restore([profile], [script], [rule], [link], [
      group,
    ], isOverride: true);
    expect(await database.profilesDao.query().get(), [
      profile.copyWith(order: 0),
    ]);
    expect(await database.scriptsDao.query().get(), [script]);
    final restoredRules = await database.rulesDao
        .queryProfileCustomRules(profile.id)
        .get();
    expect(restoredRules.single.id, rule.id);
    expect(restoredRules.single.order, isNot(equals(null)));
    final restoredGroups = await database.proxyGroupsDao
        .query(profile.id)
        .get();
    expect(restoredGroups.single.id, group.id);
    expect(restoredGroups.single.profileId, profile.id);
    expect(restoredGroups.single.order, isNot(equals(null)));

    const replacementRule = Rule(
      id: 43,
      content: 'replacement.example',
      ruleTarget: 'Group',
    );
    const replacementGroup = ProxyGroup(
      id: 44,
      name: 'Replacement',
      type: GroupType.Fallback,
    );
    await database.setProfileCustomData(
      profile.id,
      [replacementGroup],
      [replacementRule],
    );
    expect(
      (await database.rulesDao.queryProfileCustomRules(profile.id).get())
          .single
          .id,
      replacementRule.id,
    );
    expect(
      (await database.proxyGroupsDao.query(profile.id).get()).single.id,
      replacementGroup.id,
    );
  });

  test(
    'icon records update access time, avoid duplicates, and filter queries',
    () async {
      await database.iconRecordsDao.put('https://example.com/a.png');
      await database.iconRecordsDao.putIfAbsent('https://example.com/a.png');
      await database.iconRecordsDao.putIfAbsent('https://other.com/b.png');

      final before = await database.iconRecordsDao.query('example.com');
      expect(before.map((record) => record.url), ['https://example.com/a.png']);
      final record = await database.iconRecordsDao.get(
        'https://example.com/a.png',
      );
      expect(record?.url, 'https://example.com/a.png');
      expect(await database.iconRecordsDao.get('missing'), null);
      expect(await database.iconRecords.count.getSingle(), 2);
    },
  );
}
