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
        type: ProfileType.url,
        extendType: ExtendType.script,
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

  test('profiles query skips a row it cannot read and keeps it', () async {
    const readable = Profile(
      id: 1,
      label: 'Readable',
      autoUpdateDuration: Duration.zero,
    );
    await database.profilesDao.putAll([readable.toCompanion()]);
    await database.customStatement(
      'INSERT INTO profiles (id, type, label, url, extend_type, '
      'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
      "VALUES (2, 'future', 'Future', '', 'standard', 0, 1, '{}', '[]')",
    );

    expect(await database.profilesDao.query().get(), [readable]);
    expect(await database.profilesDao.ids().get(), [1, 2]);
  });

  test('provider queries skip a row they cannot read', () async {
    await database.customStatement(
      'INSERT INTO clash_providers (id, kind, label, url, behavior) VALUES '
      "(1, 'rule', 'Kept', 'https://a.example', 'domain'), "
      "(2, 'rule', 'Future', 'https://b.example', 'future')",
    );

    final providers = await database.clashProvidersDao.query().get();
    expect(providers.map((provider) => provider.id), [1]);
    expect(await database.clashProvidersDao.fileNames().get(), [
      providers.single.fileName,
      const ClashProvider(id: 2, label: '', url: 'https://b.example').fileName,
    ]);
  });

  test('rule queries fail on a row they cannot read', () async {
    await database.customStatement(
      'INSERT INTO rules (id, rule_action, content, rule_target) '
      "VALUES (1, 'DOMAIN', 'example.com', 'DIRECT'), "
      "(2, 'FUTURE', 'example.org', 'DIRECT')",
    );

    await expectLater(
      database.rulesDao.queryGlobalRules().get(),
      throwsA(anything),
    );
  });

  test('profiles query resets damaged JSON columns of a profile', () async {
    await database.customStatement(
      'INSERT INTO profiles (id, type, label, url, extend_type, '
      'auto_update_duration_millis, auto_update, selected_map, unfold_set, '
      'subscription_info, overrides) '
      "VALUES (1, 'url', 'Damaged', '', 'standard', 0, 1, 'x', '{}', '[', '{')",
    );

    final profile = (await database.profilesDao.query().get()).single;
    expect(profile.label, 'Damaged');
    expect(profile.selectedMap, isEmpty);
    expect(profile.unfoldSet, isEmpty);
    expect(profile.subscriptionInfo, null);
    expect(profile.overrides, const ProfileOverrides());
  });

  test('proxy groups query resets damaged options of a group', () async {
    await database.customStatement(
      'INSERT INTO profiles (id, type, label, url, extend_type, '
      'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
      "VALUES (1, 'custom', 'Mine', '', 'standard', 0, 1, '{}', '[]')",
    );
    await database.customStatement(
      'INSERT INTO proxy_groups (id, profile_id, name, type, proxies, '
      'definition) VALUES '
      "(1, 1, 'Broken', 'select', '[', '{'), "
      '''(2, 1, 'Typed', 'url-test', NULL, '{"interval":"x","hidden":true}')''',
    );

    final [broken, typed] = await database.proxyGroupsDao.query(1).get();
    expect(
      broken,
      const ProxyGroup(
        profileId: 1,
        id: 1,
        name: 'Broken',
        type: GroupType.Selector,
        proxies: [],
      ),
    );
    expect(typed.interval, null);
    expect(typed.hidden, true);
  });

  test(
    'generated table managers create, filter, order, and update rows',
    () async {
      final date = DateTime.utc(2026, 7, 26);
      await database.managers.profiles.create(
        (row) => row(
          type: ProfileType.custom,
          label: 'Managed profile',
          url: 'https://example.com/profile.yaml',
          extendType: ExtendType.standard,
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
          profileId: const Value(1),
          ruleAction: RuleAction.DOMAIN,
          content: const Value('example.com'),
          ruleTarget: const Value('DIRECT'),
        ),
      );
      await database.managers.disabledRules.create(
        (row) => row(profileId: 1, ruleId: 1),
      );
      await database.managers.proxyGroups.create(
        (row) => row(
          profileId: 1,
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
        await database.managers.disabledRules
            .filter((row) => row.ruleId.id.equals(1))
            .getSingle(),
        isA<RawDisabledRule>(),
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
            (prefetch) => prefetch(
              rulesRefs: true,
              disabledRulesRefs: true,
              proxyGroupsRefs: true,
            ),
          )
          .getSingle();
      expect(await profileWithReferences.$2.rulesRefs.get(), hasLength(1));
      expect(
        await profileWithReferences.$2.disabledRulesRefs.get(),
        hasLength(1),
      );
      expect(
        await profileWithReferences.$2.proxyGroupsRefs.get(),
        hasLength(1),
      );

      final ruleWithReferences = await database.managers.rules
          .withReferences(
            (prefetch) => prefetch(profileId: true, disabledRulesRefs: true),
          )
          .getSingle();
      expect((await ruleWithReferences.$2.profileId?.getSingle())?.id, 1);
      expect(await ruleWithReferences.$2.disabledRulesRefs.get(), hasLength(1));

      final groupWithReferences = await database.managers.proxyGroups
          .withReferences((prefetch) => prefetch(profileId: true))
          .getSingle();
      expect((await groupWithReferences.$2.profileId.getSingle()).id, 1);
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
        tolerance: 50,
        strategy: LoadBalanceStrategy.stickySessions,
        hashKey: 'in-user',
        defaultSelected: 'Old',
        emptyFallback: 'Old',
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
        defaultSelected: 'Primary',
        emptyFallback: 'Primary',
        order: 'b',
      );
      await database.profiles.put(profile.toCompanion());
      await database.proxyGroups.put(first.toCompanion(profile.id));
      await database.proxyGroups.put(second.toCompanion(profile.id));

      final groups = await database.proxyGroupsDao.query(profile.id).get();
      expect(groups.first, first.copyWith(profileId: profile.id));
      expect(
        (await (database.select(
          database.proxyGroups,
        )..where((t) => t.id.equals(second.id))).getSingle()).definition,
        '{"default-selected":"Primary","empty-fallback":"Primary"}',
      );
      expect(await database.proxyGroupsDao.count(profile.id).getSingle(), 2);

      await database.proxyGroupsDao.rewrite(
        groups,
        (group) => group.renamedProxies({'Primary': 'Renamed'}),
      );
      final renamed = await database.proxyGroupsDao.query(profile.id).get();
      expect(renamed.last.proxies, ['Renamed']);
      expect(renamed.last.defaultSelected, 'Renamed');
      expect(renamed.last.emptyFallback, 'Renamed');
      expect(renamed.first.defaultSelected, 'Old');
      expect(renamed.first.emptyFallback, 'Old');

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
        database.proxyGroupsDao.setAllWithBatch(batch, [
          first.copyWith(profileId: profile.id),
        ]);
      });
      expect(
        (await database.proxyGroupsDao.query(profile.id).get()).single.name,
        'Primary',
      );
    },
  );

  test(
    'rules DAO keeps global and profile rules apart, disables, orders and renames',
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
      const ruleSet = Rule(
        id: 32,
        ruleAction: RuleAction.RULE_SET,
        ruleProvider: 'provider',
        ruleTarget: 'OldGroup',
        order: 'c',
      );
      await database.profiles.put(profile.toCompanion());
      await database.rulesDao.putRule(global);
      await database.rulesDao.putRule(added, profileId: profile.id);
      await database.rulesDao.putRule(ruleSet, profileId: profile.id);

      expect(await database.rulesDao.queryGlobalRules().get(), [global]);
      expect(await database.rulesDao.queryProfileRules(profile.id).get(), [
        added.copyWith(profileId: profile.id),
        ruleSet.copyWith(profileId: profile.id),
      ]);
      expect(
        await database.rulesDao.profileRulesCount(profile.id).getSingle(),
        2,
      );
      expect(
        (await database.rulesDao.queryAddedRules(profile.id).get()).map(
          (rule) => rule.id,
        ),
        [added.id, ruleSet.id, global.id],
      );

      await database.rulesDao.putDisabled(profile.id, global.id);
      expect(await database.rulesDao.queryDisabledRuleIds(profile.id).get(), [
        global.id,
      ]);
      expect(
        (await database.rulesDao.queryAddedRules(profile.id).get()).map(
          (rule) => rule.id,
        ),
        isNot(contains(global.id)),
      );
      expect(await database.rulesDao.delDisabled(profile.id, global.id), 1);
      expect(
        await database.rulesDao.queryDisabledRuleIds(profile.id).get(),
        isEmpty,
      );

      await database.rulesDao.order(ruleId: ruleSet.id, order: '0');
      expect(
        (await database.rulesDao.queryProfileRules(profile.id).get()).first.id,
        ruleSet.id,
      );

      await database.rulesDao.renameRuleTarget(
        profile.id,
        oldName: 'OldGroup',
        newName: 'NewGroup',
      );
      expect(
        (await database.rulesDao.queryProfileRules(profile.id).get())
            .first
            .ruleTarget,
        'NewGroup',
      );

      await database.rulesDao.delRules([added.id, ruleSet.id]);
      expect(
        await database.rulesDao.queryProfileRules(profile.id).get(),
        isEmpty,
      );
      expect(await database.rulesDao.queryGlobalRules().get(), [global]);
    },
  );

  test('setting a profile\'s rules replaces only its own', () async {
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    const other = Profile(id: 2, autoUpdateDuration: Duration.zero);
    const global = Rule(id: 1, content: 'global.example', ruleTarget: 'A');
    const kept = Rule(id: 2, content: 'kept.example', ruleTarget: 'A');
    const stale = Rule(id: 3, content: 'stale.example', ruleTarget: 'A');
    const fresh = Rule(id: 4, content: 'fresh.example', ruleTarget: 'A');
    await database.profilesDao.putAll([
      profile.toCompanion(),
      other.toCompanion(),
    ]);
    await database.rulesDao.putRule(global);
    await database.rulesDao.putRule(kept, profileId: other.id);
    await database.rulesDao.putRule(stale, profileId: profile.id);

    await database.batch((b) {
      database.rulesDao.setProfileRulesWithBatch(profile.id, b, [fresh]);
    });

    final rows = {
      for (final row in await database.rules.all().get()) row.id: row.profileId,
    };
    expect(rows, {global.id: null, kept.id: other.id, fresh.id: profile.id});
    expect(
      (await database.rulesDao.queryProfileRules(profile.id).get())
          .single
          .order,
      isNot(equals(null)),
    );
  });

  test('delRules deletes more rules than one statement can bind', () async {
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    final rules = List.generate(
      33000,
      (index) => Rule(
        id: index + 1,
        ruleAction: RuleAction.DOMAIN,
        content: 'rule$index.example',
        ruleTarget: 'DIRECT',
      ),
    );
    await database.profiles.put(profile.toCompanion());
    await database.batch((b) {
      database.rulesDao.setProfileRulesWithBatch(profile.id, b, rules);
    });

    await database.rulesDao.delRules(rules.map((rule) => rule.id));

    expect(
      await database.rulesDao.profileRulesCount(profile.id).getSingle(),
      0,
    );
  });

  test('deleting a profile takes its rules, disables and groups', () async {
    const gone = Profile(id: 1, autoUpdateDuration: Duration.zero);
    const kept = Profile(id: 2, autoUpdateDuration: Duration.zero);
    const global = Rule(id: 10, content: 'global.example', ruleTarget: 'A');
    const own = Rule(id: 11, content: 'own.example', ruleTarget: 'A');
    const other = Rule(id: 12, content: 'other.example', ruleTarget: 'A');
    await database.profilesDao.putAll([gone.toCompanion(), kept.toCompanion()]);
    await database.rulesDao.putRule(global);
    await database.rulesDao.putRule(own, profileId: gone.id);
    await database.rulesDao.putDisabled(gone.id, global.id);
    await database.rulesDao.putRule(other, profileId: kept.id);
    for (final profile in [gone, kept]) {
      await database.proxyGroups.put(
        ProxyGroup(
          id: profile.id,
          name: 'Group',
          type: GroupType.Selector,
        ).toCompanion(profile.id),
      );
    }

    await database.deleteProfile(gone.id);

    final ruleIds = await database.rules.all().map((row) => row.id).get();
    expect(ruleIds, unorderedEquals([global.id, other.id]));
    expect(await database.disabledRules.count.getSingle(), 0);
    final groups = await database.proxyGroups.all().get();
    expect(groups.map((group) => group.profileId), [kept.id]);
  });

  test('deleting a rule takes the disables naming it', () async {
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    const rule = Rule(id: 10, content: 'global.example', ruleTarget: 'A');
    await database.profiles.put(profile.toCompanion());
    await database.rulesDao.putRule(rule);
    await database.rulesDao.putDisabled(profile.id, rule.id);

    await database.rulesDao.delRules([rule.id]);

    expect(await database.disabledRules.count.getSingle(), 0);
  });

  test(
    'dialers follow their profile and proxy and survive a restore',
    () async {
      const home = CustomProxy(id: 30, definition: {'name': 'Home'});
      const work = CustomProxy(id: 31, definition: {'name': 'Work'});
      const dialers = [
        ProxyDialer(profileId: 1, proxyId: 30, target: 'Relay'),
        ProxyDialer(profileId: 1, proxyId: 31, target: 'Relay'),
        ProxyDialer(profileId: 2, proxyId: 30, target: 'Other'),
      ];
      Future<List<ProxyDialer>> all() => database
          .select(database.proxyDialers)
          .map((row) => row.toProxyDialer())
          .get();

      for (final isOverride in [false, true]) {
        await database.restore(
          const [
            Profile(id: 1, autoUpdateDuration: Duration.zero),
            Profile(id: 2, autoUpdateDuration: Duration.zero),
          ],
          const [],
          const [],
          const [],
          const [],
          customProxies: const [home, work],
          proxyDialers: const [
            ...dialers,
            ProxyDialer(profileId: 99, proxyId: 30, target: 'Orphan'),
          ],
          isOverride: isOverride,
        );

        expect(
          await all(),
          unorderedEquals(dialers),
          reason: 'isOverride: $isOverride',
        );
      }

      await database.proxyDialersDao.renameTarget(
        1,
        oldName: 'Relay',
        newName: 'Front',
      );
      await database.customProxiesDao.delAll([work.id]);
      await database.deleteProfile(2);

      expect(await all(), const [
        ProxyDialer(profileId: 1, proxyId: 30, target: 'Front'),
      ]);

      await database.proxyDialersDao.set(1, home.id, null);

      expect(await all(), isEmpty);
    },
  );

  test('renaming a provider rewrites only the listed profiles', () async {
    const oldName = 'Old "nodes"';
    const newName = r'New \nodes';
    for (final id in [1, 2]) {
      await database.profiles.put(
        Profile(
          id: id,
          type: ProfileType.custom,
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      );
      await database.proxyGroups.put(
        ProxyGroup(
          id: id,
          name: 'Group',
          type: GroupType.Selector,
          use: const [oldName, 'Old', 'Kept'],
        ).toCompanion(id),
      );
      await database.rulesDao.putRule(
        Rule(
          id: 10 + id,
          ruleAction: RuleAction.RULE_SET,
          ruleProvider: oldName,
          ruleTarget: 'DIRECT',
        ),
        profileId: id,
      );
    }

    await database.proxyGroupsDao.renameUse(
      const [],
      oldName: 'Kept',
      newName: newName,
    );
    await database.proxyGroupsDao.renameUse(
      const [1],
      oldName: oldName,
      newName: newName,
    );
    await database.rulesDao.renameRuleProvider(
      const [1],
      oldName: oldName,
      newName: newName,
    );

    Future<List<String>?> use(int id) async =>
        (await database.proxyGroupsDao.query(id).get()).single.use;
    Future<String?> ruleSet(int id) async =>
        (await database.rulesDao.queryProfileRules(id).get())
            .single
            .ruleProvider;
    expect(await use(1), [newName, 'Old', 'Kept']);
    expect(await use(2), [oldName, 'Old', 'Kept']);
    expect(await ruleSet(1), newName);
    expect(await ruleSet(2), oldName);
  });

  test(
    'a logic rule nesting an app rule set uses it and follows a rename',
    () async {
      await database.profiles.put(
        const Profile(
          id: 1,
          type: ProfileType.custom,
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      );
      await database.rulesDao.putRule(
        Rule.parse('AND,((RULE-SET,Ads),(NETWORK,UDP)),REJECT', id: 10),
        profileId: 1,
      );
      await database.rulesDao.putRule(
        Rule.parse('AND,((RULE-SET,Ads-old),(NETWORK,UDP)),REJECT', id: 11),
        profileId: 1,
      );

      expect(await database.rulesDao.profileIdsUsingRuleProvider('Ads'), {1});
      expect(
        await database.rulesDao.profileIdsUsingRuleProvider('Ad'),
        isEmpty,
      );

      await database.rulesDao.renameRuleProvider(
        const [1],
        oldName: 'Ads',
        newName: 'Ad block',
      );

      expect(
        [
          for (final rule in await database.rulesDao.queryProfileRules(1).get())
            rule.rawValue,
        ],
        unorderedEquals([
          'AND,((RULE-SET,Ad block),(NETWORK,UDP)),REJECT',
          'AND,((RULE-SET,Ads-old),(NETWORK,UDP)),REJECT',
        ]),
      );
    },
  );

  test('only custom profiles count as using an app rule set', () async {
    for (final (id, type) in [(1, ProfileType.custom), (2, ProfileType.url)]) {
      await database.profiles.put(
        Profile(
          id: id,
          type: type,
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      );
      await database.rulesDao.putRule(
        Rule(
          id: id,
          ruleAction: RuleAction.RULE_SET,
          ruleProvider: 'Ads',
          ruleTarget: 'REJECT',
        ),
        profileId: id,
      );
    }

    expect(await database.rulesDao.profileIdsUsingRuleProvider('Ads'), {1});
  });

  test('a restore drops the orphans an older backup carries', () async {
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    const rule = Rule(
      id: 10,
      profileId: 1,
      content: 'kept.example',
      ruleTarget: 'A',
    );
    const orphan = Rule(
      id: 11,
      profileId: 99,
      content: 'orphan.example',
      ruleTarget: 'A',
    );

    for (final isOverride in [false, true]) {
      await database.restore(
        [profile],
        const [],
        [rule, orphan],
        const [
          DisabledRule(profileId: 1, ruleId: 404),
          DisabledRule(profileId: 99, ruleId: 10),
        ],
        const [
          ProxyGroup(id: 1, profileId: 1, name: 'A', type: GroupType.Selector),
          ProxyGroup(id: 2, profileId: 99, name: 'B', type: GroupType.Selector),
        ],
        isOverride: isOverride,
      );

      final ruleIds = await database.rules.all().map((row) => row.id).get();
      expect(ruleIds, [rule.id], reason: 'isOverride: $isOverride');
      expect(await database.disabledRules.count.getSingle(), 0);
      final groups = await database.proxyGroups.all().get();
      expect(groups.map((group) => group.id), [1]);
    }
  });

  test(
    'an override restore replaces more rules than one statement can bind',
    () async {
      const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
      const stale = Rule(
        id: 1,
        profileId: 1,
        content: 'stale.example',
        ruleTarget: 'DIRECT',
      );
      await database.restore(
        [profile],
        const [],
        [stale],
        const [],
        const [],
        isOverride: true,
      );

      final rules = List.generate(
        33000,
        (index) => Rule(
          id: index + 2,
          profileId: profile.id,
          content: 'rule$index.example',
          ruleTarget: 'DIRECT',
        ),
      );
      await database.restore(
        [profile],
        const [],
        rules,
        const [],
        const [],
        isOverride: true,
      );

      expect(
        await database.rulesDao.profileRulesCount(profile.id).getSingle(),
        rules.length,
      );
      expect(await database.rules.count.getSingle(), rules.length);
    },
  );

  test(
    'a compatible restore keeps records the backup does not carry',
    () async {
      const keptProfile = Profile(id: 1, autoUpdateDuration: Duration.zero);
      const keptRule = Rule(
        id: 41,
        profileId: 1,
        content: 'kept.example',
        ruleTarget: 'DIRECT',
      );
      const keptGroup = ProxyGroup(
        id: 42,
        profileId: 1,
        name: 'Kept',
        type: GroupType.Selector,
      );
      await database.restore([keptProfile], const [], [keptRule], const [], [
        keptGroup,
      ], isOverride: true);

      const backupProfile = Profile(id: 2, autoUpdateDuration: Duration.zero);
      const backupGroup = ProxyGroup(
        id: 43,
        profileId: 2,
        name: 'Backup',
        type: GroupType.Selector,
      );
      await database.restore(
        [backupProfile],
        const [],
        const [],
        const [],
        [backupGroup],
      );

      expect(
        (await database.rulesDao.queryProfileRules(1).get()).single.id,
        keptRule.id,
      );
      expect(
        (await database.proxyGroupsDao.query(1).get()).single.id,
        keptGroup.id,
      );
      expect(
        (await database.proxyGroupsDao.query(2).get()).single.id,
        backupGroup.id,
      );
    },
  );

  test(
    'a groups-only backup does not clear the rules of other profiles',
    () async {
      const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
      const rule = Rule(
        id: 41,
        profileId: 1,
        content: 'kept.example',
        ruleTarget: 'DIRECT',
      );
      await database.restore(
        [profile],
        const [],
        [rule],
        const [],
        const [],
        isOverride: true,
      );

      const group = ProxyGroup(
        id: 42,
        profileId: 1,
        name: 'Group',
        type: GroupType.Selector,
      );
      await database.restore(const [], const [], const [], const [], [group]);

      expect(
        (await database.rulesDao.queryProfileRules(1).get()).single.id,
        rule.id,
      );
      expect(
        (await database.proxyGroupsDao.query(1).get()).single.id,
        group.id,
      );
    },
  );

  test('clash providers DAO skips proxy rows, orders, and replaces', () async {
    const rules = ClashProvider(
      id: 51,
      label: 'Rules',
      url: 'https://rules.example',
      behavior: RuleProviderBehavior.domain,
      format: RuleProviderFormat.mrs,
    );
    const earlier = ClashProvider(
      id: 52,
      label: 'Earlier',
      url: 'https://earlier.example',
      order: 0,
    );
    const local = ClashProvider(id: 53, label: 'Local', order: 2);

    await database.clashProvidersDao.putAll([
      ...[rules, earlier, local].map((item) => item.toCompanion()),
      ClashProvidersCompanion.insert(
        id: const Value(50),
        kind: ProviderKind.proxy,
        label: 'Proxies',
        url: 'https://proxies.example',
      ),
    ]);

    expect(await database.clashProvidersDao.query().get(), [
      earlier,
      local,
      rules,
    ]);
    expect(
      await database.clashProvidersDao.fileNames().get(),
      unorderedEquals([rules, earlier, local].map((item) => item.fileName)),
    );

    await database.restore(
      const [],
      const [],
      const [],
      const [],
      const [],
      clashProviders: const [rules],
      isOverride: true,
    );
    expect(await database.clashProvidersDao.query().get(), [rules]);
  });

  test('database restore replaces related records', () async {
    const profile = Profile(
      id: 1,
      type: ProfileType.custom,
      autoUpdateDuration: Duration.zero,
    );
    final script = Script(
      id: 40,
      label: 'Script',
      lastUpdateTime: DateTime(2026),
    );
    const global = Rule(id: 45, content: 'global.example', ruleTarget: 'A');
    const rule = Rule(
      id: 41,
      profileId: 1,
      content: 'example.com',
      ruleTarget: 'DIRECT',
    );
    const group = ProxyGroup(
      id: 42,
      profileId: 1,
      name: 'Group',
      type: GroupType.Selector,
      proxies: ['DIRECT'],
    );

    await database.restore(
      [profile],
      [script],
      [global, rule],
      const [DisabledRule(profileId: 1, ruleId: 45)],
      [group],
      isOverride: true,
    );
    expect(await database.profilesDao.query().get(), [
      profile.copyWith(order: 0),
    ]);
    expect(await database.scriptsDao.query().get(), [script]);
    final restoredRules = await database.rulesDao
        .queryProfileRules(profile.id)
        .get();
    expect(restoredRules.single.id, rule.id);
    expect(restoredRules.single.order, isNot(equals(null)));
    expect(await database.rulesDao.queryDisabledRuleIds(profile.id).get(), [
      global.id,
    ]);
    final restoredGroups = await database.proxyGroupsDao
        .query(profile.id)
        .get();
    expect(restoredGroups.single.id, group.id);
    expect(restoredGroups.single.profileId, profile.id);
    expect(restoredGroups.single.order, isNot(equals(null)));
  });

  test('icon records evict down to their capacity', () async {
    final dao = database.iconRecordsDao;
    for (var index = 0; index <= dao.maxCapacity; index++) {
      await dao.put('https://example.com/$index.png');
    }

    expect(await database.iconRecords.count.getSingle(), dao.maxCapacity);
  });

  test(
    'icon records update access time, avoid duplicates, and filter queries',
    () async {
      await database.iconRecordsDao.put('https://example.com/a.png');
      await database.iconRecordsDao.put('https://example.com/a.png');
      await database.iconRecordsDao.put('https://other.com/b.png');

      final before = await database.iconRecordsDao.query('example.com');
      expect(before.map((record) => record.url), ['https://example.com/a.png']);
      final record = await database.iconRecordsDao.get(
        'https://example.com/a.png',
      );
      expect(record?.url, 'https://example.com/a.png');
      expect(await database.iconRecordsDao.get('missing'), null);
      expect(await database.iconRecords.count.getSingle(), 2);

      await database.iconRecordsDao.del('https://example.com/a.png');

      expect(
        (await database.iconRecordsDao.query('')).map((record) => record.url),
        ['https://other.com/b.png'],
      );
    },
  );

  test('icon sets round-trip their icons and keep their order', () async {
    const icons = [
      IconSetIcon(name: 'Hong_Kong.png', url: 'https://example.com/hk.png'),
      IconSetIcon(name: 'Japan.svg', url: 'https://example.com/jp.svg'),
    ];
    await database.iconSetsDao.putAll([
      const IconSet(
        id: 2,
        name: 'Second',
        icons: icons,
        order: 0,
      ).toCompanion(),
      const IconSet(
        id: 1,
        name: 'First',
        url: 'https://example.com/set.json',
      ).toCompanion(),
      const IconSet(id: 3, name: 'Unordered').toCompanion(1),
    ]);

    final iconSets = await database.iconSetsDao.query().get();

    expect(iconSets.map((iconSet) => iconSet.id), [2, 3, 1]);
    expect(iconSets.first.icons, icons);
    expect(iconSets.last.url, 'https://example.com/set.json');
  });
}
