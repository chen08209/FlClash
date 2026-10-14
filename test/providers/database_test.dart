import 'dart:async';

import 'package:drift/native.dart';
// `Profiles`, `Scripts` and `ProxyGroups` name both a drift table and a
// notifier, so the schema side is imported behind a prefix.
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

/// Every notifier in `lib/providers/database.dart` writes optimistically: the
/// in-memory state is mutated first and the row is persisted afterwards through
/// [withRollback], which restores the pre-mutation snapshot when the write
/// fails. These tests drive the real drift schema on an in-memory executor so
/// both halves — the optimistic value and the rollback — are observable.
void main() {
  const profileId = 1;

  late db.Database testDatabase;
  late ProviderContainer container;

  Profile profile(int id, {String label = '', int? order}) => Profile(
    id: id,
    label: label,
    autoUpdateDuration: Duration.zero,
    order: order,
  );

  setUp(() async {
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  /// Subscribes to [provider] so it survives auto-dispose for the whole test,
  /// then waits for the backing drift stream to deliver its first row set.
  Future<void> keepAlive(ProviderListenable<Object?> provider) async {
    container.listen(provider, (_, _) {});
    await pumpEventQueue();
  }

  /// Most call sites wrap the persist step in `unawaited(...)`, so the failure
  /// never reaches the caller — it lands in the zone handler, and only after
  /// the rollback has already restored the snapshot.
  Future<Object> captureWriteFailure(FutureOr<void> Function() body) {
    final completer = Completer<Object>();
    runZonedGuarded(() async => body(), (error, _) {
      if (!completer.isCompleted) completer.complete(error);
    });
    return completer.future.timeout(const Duration(seconds: 5));
  }

  /// `customStatement` does not raise a drift table-update notification, so the
  /// streams the notifiers watch keep serving their last good rows — which is
  /// what lets a test observe the rolled-back state rather than an error state.
  Future<void> breakTable(String table) =>
      testDatabase.customStatement('DROP TABLE $table');

  group('withRollback', () {
    test('rolls back with snapshot and rethrows async errors', () async {
      final error = StateError('write failed');
      final previous = [1, 2, 3];
      List<int>? rolledBack;

      await expectLater(
        withRollback(
          snapshot: previous,
          action: () async {
            throw error;
          },
          rollback: (value) => rolledBack = value,
        ),
        throwsA(same(error)),
      );

      expect(rolledBack, previous);
    });

    test('does not roll back when action succeeds', () async {
      var rollbackCalled = false;

      await withRollback(
        snapshot: [1, 2, 3],
        action: () async {},
        rollback: (_) => rollbackCalled = true,
      );

      expect(rollbackCalled, false);
    });
  });

  group('Profiles', () {
    late Profiles notifier;

    setUp(() async {
      await keepAlive(profilesProvider);
      notifier = container.read(profilesProvider.notifier);
    });

    List<Profile> read() => container.read(profilesProvider);

    test('put persists the row and the stream echoes it back', () async {
      notifier.put(profile(1, label: 'First'));

      expect(read().single.label, 'First');
      await pumpEventQueue();

      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.single.label, 'First');
      expect(read().single.label, 'First');
    });

    test(
      'put de-duplicates a label already taken by another profile',
      () async {
        notifier.put(profile(1, label: 'Shared'));
        await pumpEventQueue();

        notifier.put(profile(2, label: 'Shared'));
        await pumpEventQueue();

        final labels = read().map((item) => item.label).toSet();
        expect(labels, {'Shared', 'Shared(1)'});
      },
    );

    test('a read-back during a write keeps the optimistic profile', () async {
      final rows = StreamController<List<Profile>>();
      addTearDown(rows.close);
      final scoped = ProviderContainer(
        overrides: [profilesStreamProvider.overrideWith((_) => rows.stream)],
      );
      addTearDown(scoped.dispose);
      scoped.listen(profilesProvider, (_, _) {});
      rows.add(const []);
      await pumpEventQueue();
      final landing = Completer<void>();
      final held = testDatabase.transaction(() => landing.future);

      scoped.read(profilesProvider.notifier).put(profile(1, label: 'Mine'));
      rows.add([profile(2, label: 'Theirs')]);
      await pumpEventQueue();
      expect(scoped.read(profilesProvider).map((item) => item.id), [1]);

      landing.complete();
      await held;
      await pumpEventQueue();
      rows.add([profile(1, label: 'Mine'), profile(2, label: 'Theirs')]);
      await pumpEventQueue();
      expect(scoped.read(profilesProvider).map((item) => item.id), [1, 2]);
    });

    test('put falls back to the id when the profile has no label', () async {
      // Profile.normal() leaves the label empty when the download exposed no
      // filename, and optimizeLabel is the only thing that names it.
      notifier.put(profile(42));
      await pumpEventQueue();

      expect(read().single.label, '42');
      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.single.label, '42');
    });

    test(
      'put keeps the label when the same profile is written again',
      () async {
        notifier.put(profile(1, label: 'Stable'));
        await pumpEventQueue();

        notifier.put(profile(1, label: 'Stable'));
        await pumpEventQueue();

        expect(read().single.label, 'Stable');
      },
    );

    Profile custom(int id) =>
        profile(id, label: 'Custom $id').copyWith(type: ProfileType.custom);

    test(
      'a new label follows into the groups of every custom profile',
      () async {
        notifier.put(profile(1, label: 'Home'));
        for (final id in [2, 3]) {
          notifier.put(custom(id));
        }
        await pumpEventQueue();
        for (final id in [2, 3]) {
          await testDatabase.proxyGroups.put(
            ProxyGroup(
              id: id,
              name: 'Group',
              type: GroupType.Selector,
              use: const ['Home', 'Other'],
            ).toCompanion(id),
          );
        }

        notifier.put(profile(1, label: 'Away'));
        await pumpEventQueue();

        Future<List<String>?> use(int id) async =>
            (await testDatabase.proxyGroupsDao.query(id).get()).single.use;
        expect(await use(2), ['Away', 'Other']);
        expect(await use(3), ['Away', 'Other']);
      },
    );

    test('a new label follows into the provider options of every custom '
        'profile', () async {
      const options = ProxyProviderOptions(filter: 'HK');
      notifier.put(profile(1, label: 'Home'));
      for (final id in [2, 3]) {
        notifier.put(
          custom(id).copyWith(
            overrides: const ProfileOverrides(
              proxyProviders: {'Home': options},
            ),
          ),
        );
      }
      await pumpEventQueue();

      notifier.put(profile(1, label: 'Away'));
      await pumpEventQueue();

      Map<String, ProxyProviderOptions> optionsOf(int id) =>
          read().firstWhere((item) => item.id == id).overrides.proxyProviders;
      expect(optionsOf(2), {'Away': options});
      expect(optionsOf(3), {'Away': options});
      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.firstWhere((item) => item.id == 3).overrides.proxyProviders, {
        'Away': options,
      });
    });

    test('a custom profile is never a provider, so its label renames '
        'nothing', () async {
      notifier.put(custom(2));
      await pumpEventQueue();
      await testDatabase.proxyGroups.put(
        const ProxyGroup(
          id: 9,
          name: 'Group',
          type: GroupType.Selector,
          use: ['Custom 2'],
        ).toCompanion(2),
      );

      notifier.put(custom(2).copyWith(label: 'Renamed'));
      await pumpEventQueue();

      final group = (await testDatabase.proxyGroupsDao.query(2).get()).single;
      expect(group.use, ['Custom 2']);
    });

    test('put restores the previous list when the write fails', () async {
      notifier.put(profile(1, label: 'Kept'));
      await pumpEventQueue();
      await breakTable('profiles');

      final failure = captureWriteFailure(
        () => notifier.put(profile(2, label: 'Lost')),
      );
      expect(read().map((item) => item.id), [2, 1], reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [1], reason: 'rolled back');
    });

    test('del awaits the write and rethrows after rolling back', () async {
      notifier.put(profile(1, label: 'Kept'));
      await pumpEventQueue();
      await breakTable('profiles');

      await expectLater(notifier.del(1), throwsA(isA<Exception>()));
      expect(read().map((item) => item.id), [1]);
    });

    test('del removes the row when the write succeeds', () async {
      notifier.put(profile(1, label: 'Gone'));
      await pumpEventQueue();

      await notifier.del(1);
      await pumpEventQueue();

      expect(read(), isEmpty);
      expect(await testDatabase.profilesDao.query().get(), isEmpty);
    });

    test('updateProfile ignores an id that is not in state', () async {
      notifier.put(profile(1, label: 'Only'));
      await pumpEventQueue();

      notifier.updateProfile(404, (item) => item.copyWith(label: 'Never'));
      await pumpEventQueue();

      expect(read().single.label, 'Only');
    });

    test('updateProfile applies the builder and persists it', () async {
      notifier.put(profile(1, label: 'Before'));
      await pumpEventQueue();

      notifier.updateProfile(1, (item) => item.copyWith(label: 'After'));
      expect(read().single.label, 'After');
      await pumpEventQueue();

      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.single.label, 'After');
    });

    test(
      'updateProfile restores the previous list when the write fails',
      () async {
        notifier.put(profile(1, label: 'Before'));
        await pumpEventQueue();
        await breakTable('profiles');

        final failure = captureWriteFailure(
          () => notifier.updateProfile(
            1,
            (item) => item.copyWith(label: 'After'),
          ),
        );
        expect(read().single.label, 'After', reason: 'optimistic');

        await failure;
        expect(read().single.label, 'Before', reason: 'rolled back');
      },
    );

    test('reorder only writes the rows whose order actually changed', () async {
      notifier
        ..put(profile(1, label: 'One', order: 0))
        ..put(profile(2, label: 'Two', order: 1));
      await pumpEventQueue();

      notifier.reorder([
        profile(2, label: 'Two', order: 1),
        profile(1, label: 'One', order: 0),
      ]);
      await pumpEventQueue();

      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.map((item) => item.id), [2, 1]);
      expect(rows.map((item) => item.order), [0, 1]);
    });

    test('reorder restores the previous order when the write fails', () async {
      notifier
        ..put(profile(1, label: 'One', order: 0))
        ..put(profile(2, label: 'Two', order: 1));
      await pumpEventQueue();
      await breakTable('profiles');

      final failure = captureWriteFailure(
        () => notifier.reorder([
          profile(2, label: 'Two', order: 1),
          profile(1, label: 'One', order: 0),
        ]),
      );
      expect(read().map((item) => item.id), [2, 1], reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [1, 2], reason: 'rolled back');
    });
  });

  group('Scripts', () {
    late Scripts notifier;

    Script script(int id, String label) =>
        Script(id: id, label: label, lastUpdateTime: DateTime(2026));

    setUp(() async {
      await keepAlive(scriptsProvider);
      notifier = container.read(scriptsProvider.notifier);
    });

    List<Script> read() => notifier.value;

    test('order persists the new positions and lists by them', () async {
      notifier.put(script(1, 'First'));
      await pumpEventQueue();
      notifier.put(script(2, 'Second'));
      await pumpEventQueue();
      notifier.put(script(3, 'Third'));
      await pumpEventQueue();

      notifier.order(2, 0);
      await pumpEventQueue();

      expect(read().map((item) => item.label), ['Third', 'First', 'Second']);
      final rows = await testDatabase.scriptsDao.query().get();
      expect(rows.map((item) => item.label), ['Third', 'First', 'Second']);
      expect(rows.map((item) => item.order), [0, 1, 2]);
    });

    test('a row written around the notifier during a write is read back '
        'once the write settles', () async {
      final landing = Completer<void>();
      final write = notifier.optimisticAsync(read(), () => landing.future);
      await testDatabase.scripts.put(script(1, 'Direct').toCompanion());
      await pumpEventQueue();
      expect(read(), isEmpty);

      landing.complete();
      await write;
      await pumpEventQueue();

      expect(read().map((item) => item.label), ['Direct']);
    });

    test('put appends a new script and replaces an existing one', () async {
      notifier.put(script(1, 'First'));
      await pumpEventQueue();
      notifier.put(script(2, 'Second'));
      await pumpEventQueue();

      expect(read().map((item) => item.label), ['First', 'Second']);

      notifier.put(script(1, 'Renamed'));
      await pumpEventQueue();

      final rows = await testDatabase.scriptsDao.query().get();
      expect(
        rows.map((item) => item.label),
        containsAll(['Renamed', 'Second']),
      );
      expect(rows, hasLength(2));
    });

    test('put restores the previous list when the write fails', () async {
      notifier.put(script(1, 'Kept'));
      await pumpEventQueue();
      await breakTable('scripts');

      final failure = captureWriteFailure(
        () => notifier.put(script(2, 'Lost')),
      );
      expect(read(), hasLength(2), reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.label), ['Kept'], reason: 'rolled back');
    });

    test('del ignores an id that is not in state', () async {
      notifier.put(script(1, 'Only'));
      await pumpEventQueue();
      await breakTable('scripts');

      notifier.del(404);
      await pumpEventQueue();

      expect(read().map((item) => item.label), ['Only']);
    });

    test('del removes the row and rolls back a failed write', () async {
      notifier.put(script(1, 'First'));
      await pumpEventQueue();
      notifier.put(script(2, 'Second'));
      await pumpEventQueue();

      notifier.del(1);
      await pumpEventQueue();
      expect(read().map((item) => item.id), [2]);

      await breakTable('scripts');
      final failure = captureWriteFailure(() => notifier.del(2));
      expect(read(), isEmpty, reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [2], reason: 'rolled back');
    });

    test('put persists the source url and clears it again', () async {
      const url = 'https://example.com/override.js';
      notifier.put(script(1, 'Remote').copyWith(url: url));
      await pumpEventQueue();

      expect((await testDatabase.scriptsDao.get(1).getSingle()).url, url);

      notifier.put(script(1, 'Remote'));
      await pumpEventQueue();

      expect((await testDatabase.scriptsDao.get(1).getSingle()).url, isNull);
    });
  });

  group('GlobalRules', () {
    late GlobalRules notifier;

    setUp(() async {
      await keepAlive(globalRulesProvider);
      notifier = container.read(globalRulesProvider.notifier);
    });

    List<Rule> read() => notifier.value;

    test('put assigns an order to a rule that has none', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();

      expect(read().single.order, isNotNull);
      final rows = await testDatabase.rulesDao.queryGlobalRules().get();
      expect(rows.single.order, isNotNull);
    });

    test('put keeps an order the caller already supplied', () async {
      notifier.put(const Rule(id: 1, content: 'first', order: 'm'));
      await pumpEventQueue();

      expect(read().single.order, 'm');
    });

    test('put prepends so the newest rule sorts first', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'second'));
      await pumpEventQueue();

      final rows = await testDatabase.rulesDao.queryGlobalRules().get();
      expect(rows.map((item) => item.id), [2, 1]);
    });

    test(
      'putAll puts the batch ahead of existing rules in its order',
      () async {
        notifier.put(const Rule(id: 1, content: 'existing'));
        await pumpEventQueue();

        notifier.putAll(const [
          Rule(id: 2, content: 'second'),
          Rule(id: 3, content: 'third'),
        ]);
        expect(read().map((item) => item.id), [2, 3, 1], reason: 'optimistic');
        await pumpEventQueue();

        final rows = await testDatabase.rulesDao.queryGlobalRules().get();
        expect(rows.map((item) => item.id), [2, 3, 1]);
      },
    );

    test('delAll removes every listed rule', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'second'));
      await pumpEventQueue();

      notifier.delAll([1, 2]);
      await pumpEventQueue();

      expect(read(), isEmpty);
      expect(await testDatabase.rulesDao.queryGlobalRules().get(), isEmpty);
    });

    test('delAll restores the previous list when the write fails', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();
      await breakTable('rules');

      final failure = captureWriteFailure(() => notifier.delAll([1]));
      expect(read(), isEmpty, reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [1], reason: 'rolled back');
    });

    test('order moves a rule and rewrites only its order key', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'second'));
      await pumpEventQueue();

      final before = read().map((item) => item.id).toList();
      notifier.order(0, 1);
      await pumpEventQueue();

      final rows = await testDatabase.rulesDao.queryGlobalRules().get();
      expect(rows.map((item) => item.id), before.reversed);
    });
  });

  group('ProfileRules', () {
    late ProfileRules notifier;

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await keepAlive(profileRulesProvider(profileId));
      notifier = container.read(profileRulesProvider(profileId).notifier);
    });

    List<Rule> read() => notifier.value;

    test('put scopes the rule to its profile', () async {
      notifier.put(const Rule(id: 1, content: 'own'));
      await pumpEventQueue();

      expect(read().single.id, 1);
      final scoped = await testDatabase.rulesDao
          .queryProfileRules(profileId)
          .get();
      expect(scoped.single.id, 1);
      expect(
        await testDatabase.rulesDao.queryGlobalRules().get(),
        isEmpty,
        reason: 'a profile rule must not leak into the global rules',
      );
    });

    test('delAll and order round-trip through the profile rules', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'two'));
      await pumpEventQueue();

      final before = read().map((item) => item.id).toList();
      notifier.order(0, 1);
      await pumpEventQueue();
      expect(
        (await testDatabase.rulesDao.queryProfileRules(profileId).get()).map(
          (item) => item.id,
        ),
        before.reversed,
      );

      notifier.delAll([1]);
      await pumpEventQueue();
      expect(read().map((item) => item.id), [2]);
    });

    test('put restores the previous list when the write fails', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      await breakTable('rules');

      final failure = captureWriteFailure(
        () => notifier.put(const Rule(id: 2, content: 'two')),
      );
      expect(read(), hasLength(2), reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [1], reason: 'rolled back');
    });

    test('setAll replaces the list in the order given', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'two'));
      await pumpEventQueue();

      notifier.setAll(const [
        Rule(id: 3, content: 'three'),
        Rule(id: 1, content: 'one'),
      ]);
      expect(read().map((item) => item.id), [3, 1], reason: 'optimistic');
      await pumpEventQueue();

      final rows = await testDatabase.rulesDao
          .queryProfileRules(profileId)
          .get();
      expect(rows.map((item) => item.id), [3, 1]);
    });

    test('delAll restores the previous list when the write fails', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      await breakTable('rules');

      final failure = captureWriteFailure(() => notifier.delAll([1]));
      expect(read(), isEmpty, reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.id), [1], reason: 'rolled back');
    });

    test('a read-back during a write keeps the optimistic rule', () async {
      final gated = _GatedProfileRules();
      final scoped = ProviderContainer(
        overrides: [profileRulesProvider.overrideWith2((_) => gated)],
      );
      addTearDown(scoped.dispose);
      scoped.listen(profileRulesProvider(profileId), (_, _) {});
      await pumpEventQueue();

      gated.put(const Rule(id: 1, content: 'mine'));
      await testDatabase.rulesDao.putRule(
        const Rule(id: 2, content: 'theirs'),
        profileId: profileId,
      );
      await pumpEventQueue();
      expect(gated.value.map((item) => item.id), [1]);

      gated.landing.complete();
      await pumpEventQueue();
      expect(gated.value.map((item) => item.id), unorderedEquals([1, 2]));
    });
  });

  group('CustomProxies', () {
    late CustomProxies notifier;

    setUp(() async {
      await keepAlive(customProxiesProvider);
      notifier = container.read(customProxiesProvider.notifier);
    });

    CustomProxy proxy(int id) => CustomProxy(
      id: id,
      definition: {'name': 'Proxy $id', 'type': 'socks5'},
    );

    test('setAll keeps the dialers of the proxies it keeps', () async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      notifier.put(proxy(1));
      await pumpEventQueue();
      notifier.put(proxy(2));
      await pumpEventQueue();
      await testDatabase.proxyDialersDao.set(profileId, 1, 'Relay');
      await testDatabase.proxyDialersDao.set(profileId, 2, 'Relay');

      notifier.setAll([proxy(3), proxy(1)]);
      expect(notifier.value.map((item) => item.id), [
        3,
        1,
      ], reason: 'optimistic');
      await pumpEventQueue();

      final rows = await testDatabase.customProxiesDao.query().get();
      expect(rows.map((item) => item.id), [3, 1]);
      final dialers = await testDatabase.proxyDialersDao.query(profileId).get();
      expect(dialers.map((item) => item.proxyId), [1]);
    });

    test('renaming a proxy rewrites what custom profiles name it by', () async {
      const standardId = 2;
      const overrides = ProfileOverrides(
        dns: Dns(
          nameserver: [
            'https://dns.example/dns-query#Proxy 1',
            'tls://1.1.1.1#Proxy 2',
          ],
          nameserverPolicy: {
            '+.example.com': '1.1.1.1#Proxy%201, 8.8.8.8',
            '+.other.com': '8.8.8.8;9.9.9.9',
          },
        ),
        ntp: Ntp(dialerProxy: 'Proxy 1'),
      );
      await testDatabase.profilesDao.putAll([
        profile(profileId)
            .copyWith(type: ProfileType.custom, overrides: overrides)
            .toCompanion(),
        profile(standardId).copyWith(overrides: overrides).toCompanion(),
      ]);
      notifier.put(proxy(1));
      await pumpEventQueue();
      notifier.put(proxy(2));
      await pumpEventQueue();
      await testDatabase.proxyGroups.put(
        const ProxyGroup(
          id: 7,
          name: 'Landing',
          type: GroupType.Selector,
          proxies: ['Proxy 1', 'Proxy 2'],
          defaultSelected: 'Proxy 1',
          order: 'a',
        ).toCompanion(profileId),
      );
      for (final (id, owner) in [(8, profileId), (9, standardId)]) {
        await testDatabase.rulesDao.putRule(
          Rule(id: id, content: 'x', ruleTarget: 'Proxy 1', order: 'a'),
          profileId: owner,
        );
      }
      await testDatabase.proxyDialersDao.set(profileId, 2, 'Proxy 1');

      notifier.put(
        proxy(1).copyWith(definition: {'name': 'Renamed', 'type': 'socks5'}),
      );
      await pumpEventQueue();

      final group =
          (await testDatabase.proxyGroupsDao.query(profileId).get()).single;
      expect(group.proxies, ['Renamed', 'Proxy 2']);
      expect(group.defaultSelected, 'Renamed');
      Future<String?> ruleTarget(int owner) async =>
          (await testDatabase.rulesDao.queryProfileRules(owner).get())
              .single
              .ruleTarget;
      expect(await ruleTarget(profileId), 'Renamed');
      expect(await ruleTarget(standardId), 'Proxy 1');
      final dialers = await testDatabase.proxyDialersDao.query(profileId).get();
      expect(dialers.single.target, 'Renamed');
      final [custom, standard] = await testDatabase.profilesDao.query().get();
      expect(custom.overrides.dns.nameserver, [
        'https://dns.example/dns-query#Renamed',
        'tls://1.1.1.1#Proxy 2',
      ]);
      expect(custom.overrides.dns.nameserverPolicy, {
        '+.example.com': '1.1.1.1#Renamed, 8.8.8.8',
        '+.other.com': '8.8.8.8;9.9.9.9',
      });
      expect(custom.overrides.ntp.dialerProxy, 'Renamed');
      expect(standard.overrides, overrides);
    });

    Profile custom(int id, {ProfileOverrides? overrides}) =>
        profile(id, label: 'Custom $id').copyWith(
          type: ProfileType.custom,
          overrides: overrides ?? const ProfileOverrides(),
        );

    Future<void> putGroup(int owner, ProxyGroup group) =>
        testDatabase.proxyGroups.put(group.toCompanion(owner));

    test('renaming a proxy leaves the profiles where a group takes either '
        'name', () async {
      const ntp = ProfileOverrides(
        ntp: Ntp(dialerProxy: 'Proxy 1'),
        ntpOverrideKeys: {NtpOverrideKey.dialerProxy},
      );
      await testDatabase.profilesDao.putAll([
        for (final id in [1, 2, 3]) custom(id, overrides: ntp).toCompanion(),
      ]);
      notifier.put(proxy(1));
      await pumpEventQueue();
      await putGroup(
        1,
        const ProxyGroup(
          id: 11,
          name: 'Landing',
          type: GroupType.Selector,
          proxies: ['Proxy 1'],
        ),
      );
      await putGroup(
        2,
        const ProxyGroup(
          id: 21,
          name: 'Proxy 1',
          type: GroupType.Selector,
          proxies: ['DIRECT'],
        ),
      );
      await putGroup(
        3,
        const ProxyGroup(
          id: 31,
          name: 'Renamed',
          type: GroupType.Selector,
          proxies: ['DIRECT'],
        ),
      );
      for (final owner in [1, 2, 3]) {
        await testDatabase.rulesDao.putRule(
          Rule(
            id: 100 + owner,
            content: 'x',
            ruleTarget: 'Proxy 1',
            order: 'a',
          ),
          profileId: owner,
        );
      }

      notifier.put(
        proxy(1).copyWith(definition: {'name': 'Renamed', 'type': 'socks5'}),
      );
      await pumpEventQueue();

      Future<String?> ruleTarget(int owner) async =>
          (await testDatabase.rulesDao.queryProfileRules(owner).get())
              .single
              .ruleTarget;
      final rows = {
        for (final row in await testDatabase.profilesDao.query().get())
          row.id: row,
      };
      expect(await ruleTarget(1), 'Renamed');
      expect(rows[1]!.overrides.ntp.dialerProxy, 'Renamed');
      for (final owner in [2, 3]) {
        expect(await ruleTarget(owner), 'Proxy 1', reason: '$owner');
        expect(rows[owner]!.overrides, ntp, reason: '$owner');
      }
    });

    test('renaming a proxy moves the picks of the groups listing it', () async {
      await keepAlive(profilesProvider);
      container
          .read(profilesProvider.notifier)
          .put(
            custom(1).copyWith(
              selectedMap: const {'Landing': 'Proxy 1', 'Pool': 'Proxy 1'},
            ),
          );
      await pumpEventQueue();
      notifier.put(proxy(1));
      await pumpEventQueue();
      await putGroup(
        1,
        const ProxyGroup(
          id: 11,
          name: 'Landing',
          type: GroupType.Selector,
          proxies: ['Proxy 1'],
        ),
      );
      await putGroup(
        1,
        const ProxyGroup(
          id: 12,
          name: 'Pool',
          type: GroupType.Selector,
          use: ['Subscription'],
        ),
      );

      notifier.put(
        proxy(1).copyWith(definition: {'name': 'Renamed', 'type': 'socks5'}),
      );
      await pumpEventQueue();

      const picks = {'Landing': 'Renamed', 'Pool': 'Proxy 1'};
      expect(container.read(profilesProvider).single.selectedMap, picks);
      expect(
        (await testDatabase.profilesDao.query().get()).single.selectedMap,
        picks,
      );
    });

    test(
      'a profile written as a proxy is renamed keeps both changes',
      () async {
        const dns = ProfileOverrides(
          dns: Dns(nameserver: ['1.1.1.1#Proxy 1']),
          dnsOverrideKeys: {DnsOverrideKey.nameserver},
        );
        await keepAlive(profilesProvider);
        final profiles = container.read(profilesProvider.notifier);
        profiles.put(custom(1, overrides: dns));
        await pumpEventQueue();
        notifier.put(proxy(1));
        await pumpEventQueue();

        notifier.put(
          proxy(1).copyWith(definition: {'name': 'Renamed', 'type': 'socks5'}),
        );
        profiles.put(
          container
              .read(profilesProvider)
              .single
              .copyWith(currentGroupName: 'Landing'),
        );
        await pumpEventQueue();

        final row = (await testDatabase.profilesDao.query().get()).single;
        expect(row.overrides.dns.nameserver, ['1.1.1.1#Renamed']);
        expect(row.currentGroupName, 'Landing');
        expect(container.read(profilesProvider).single, row);
      },
    );
  });

  group('ClashProviders', () {
    test(
      'renaming a set renames it wherever a custom profile names it',
      () async {
        const overrides = ProfileOverrides(
          dns: Dns(
            nameserverPolicy: {'rule-set:ads,cn': '223.5.5.5'},
            fakeIpFilter: ['rule-set:ads'],
          ),
          dnsOverrideKeys: {
            DnsOverrideKey.nameserverPolicy,
            DnsOverrideKey.fakeIpFilter,
          },
          sniffer: Sniffer(skipDomain: ['rule-set:ads']),
          snifferOverrideKeys: {SnifferOverrideKey.skipDomain},
        );
        await keepAlive(profilesProvider);
        await keepAlive(clashProvidersProvider);
        container
            .read(profilesProvider.notifier)
            .put(
              profile(
                profileId,
                label: 'Custom',
              ).copyWith(type: ProfileType.custom, overrides: overrides),
            );
        final providers = container.read(clashProvidersProvider.notifier);
        providers.put(const ClashProvider(id: 5, label: 'ads'));
        await pumpEventQueue();
        await testDatabase.rulesDao.putRule(
          const Rule(
            id: 9,
            ruleAction: RuleAction.RULE_SET,
            ruleProvider: 'ads',
            ruleTarget: 'REJECT',
            order: 'a',
          ),
          profileId: profileId,
        );

        providers.put(const ClashProvider(id: 5, label: 'block'));
        await pumpEventQueue();

        final rule =
            (await testDatabase.rulesDao.queryProfileRules(profileId).get())
                .single;
        expect(rule.ruleProvider, 'block');
        final row = (await testDatabase.profilesDao.query().get()).single;
        expect(row.overrides.ruleSets, {'block', 'cn'});
        expect(row.overrides.dns.nameserverPolicy.keys, ['rule-set:block,cn']);
        expect(row.overrides.dns.fakeIpFilter, ['rule-set:block']);
        expect(row.overrides.sniffer.skipDomain, ['rule-set:block']);
        expect(container.read(profilesProvider).single, row);
      },
    );
  });

  group('ProfileDisabledRuleIds', () {
    late ProfileDisabledRuleIds notifier;

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await testDatabase.rulesDao.putRule(
        const Rule(id: 7, content: 'toggled', order: 'a'),
      );
      await keepAlive(profileDisabledRuleIdsProvider(profileId));
      notifier = container.read(
        profileDisabledRuleIdsProvider(profileId).notifier,
      );
    });

    List<int> read() => notifier.value;

    test('put disables the rule and del enables it again', () async {
      notifier.put(7);
      expect(read(), [7]);
      await pumpEventQueue();

      expect(
        await testDatabase.rulesDao.queryDisabledRuleIds(profileId).get(),
        [7],
      );

      notifier.del(7);
      await pumpEventQueue();
      expect(read(), isEmpty);
      expect(
        await testDatabase.rulesDao.queryDisabledRuleIds(profileId).get(),
        isEmpty,
      );
    });

    test('put is idempotent for an id that is already disabled', () async {
      notifier.put(7);
      await pumpEventQueue();
      notifier.put(7);
      await pumpEventQueue();

      expect(read(), [7]);
    });

    test('put restores the previous ids when the write fails', () async {
      await breakTable('disabled_rules');

      final failure = captureWriteFailure(() => notifier.put(7));
      expect(read(), [7], reason: 'optimistic');

      await failure;
      expect(read(), isEmpty, reason: 'rolled back');
    });
  });

  group('ProxyGroups', () {
    late ProxyGroups notifier;

    ProxyGroup group(int id, String name, {List<String>? proxies}) =>
        ProxyGroup(
          id: id,
          name: name,
          type: GroupType.Selector,
          proxies: proxies,
        );

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await keepAlive(proxyGroupsProvider(profileId));
      notifier = container.read(proxyGroupsProvider(profileId).notifier);
    });

    List<ProxyGroup> read() => notifier.value;

    test('put assigns an order to a newly added group', () async {
      expect(notifier.put(group(1, 'First')), isTrue);
      await pumpEventQueue();

      expect(read().single.order, isNotNull);
      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      expect(rows.single.name, 'First');
    });

    test('consecutive additions get distinct persisted order keys', () async {
      expect(notifier.put(group(1, 'One')), isTrue);
      await pumpEventQueue();
      expect(notifier.put(group(2, 'Two')), isTrue);
      await pumpEventQueue();

      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      final orders = rows.map((item) => item.order).toList();
      expect(orders, everyElement(isNotNull));
      expect(orders.toSet(), hasLength(2));
      expect(rows.map((item) => item.id), [
        1,
        2,
      ], reason: 'new groups are appended, so the keys must be increasing');
    });

    test('put rejects a second group that reuses an existing name', () async {
      expect(notifier.put(group(1, 'Taken')), isTrue);
      await pumpEventQueue();

      expect(notifier.put(group(2, 'Taken')), isFalse);
      await pumpEventQueue();

      expect(read(), hasLength(1));
    });

    test('renaming a group rewrites the rules that target it', () async {
      expect(notifier.put(group(1, 'Old')), isTrue);
      await pumpEventQueue();
      await testDatabase.rulesDao.putRule(
        const Rule(id: 9, content: 'x', ruleTarget: 'Old', order: 'a'),
        profileId: profileId,
      );

      expect(notifier.put(group(1, 'New')), isTrue);
      await pumpEventQueue();

      final rules = await testDatabase.rulesDao
          .queryProfileRules(profileId)
          .get();
      expect(rules.single.ruleTarget, 'New');
    });

    test('renaming a group rewrites references from sibling groups', () async {
      expect(notifier.put(group(1, 'Old')), isTrue);
      await pumpEventQueue();
      expect(notifier.put(group(2, 'Parent', proxies: ['Old'])), isTrue);
      await pumpEventQueue();

      expect(notifier.put(group(1, 'New')), isTrue);
      await pumpEventQueue();

      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      final parent = rows.firstWhere((item) => item.id == 2);
      expect(parent.proxies, ['New']);
    });

    test('renaming a group keeps every member list readable', () async {
      expect(notifier.put(group(1, ',')), isTrue);
      expect(notifier.put(group(2, 'Old')), isTrue);
      expect(
        notifier.put(group(3, 'Parent', proxies: ['x', 'Old', 'y'])),
        isTrue,
      );
      await pumpEventQueue();

      expect(notifier.put(group(1, 'Comma')), isTrue);
      expect(notifier.put(group(2, 'Say "hi" \\o/')), isTrue);
      expect(read().firstWhere((item) => item.id == 3).proxies, [
        'x',
        'Say "hi" \\o/',
        'y',
      ], reason: 'optimistic');
      await pumpEventQueue();

      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      expect(rows.firstWhere((item) => item.id == 3).proxies, [
        'x',
        'Say "hi" \\o/',
        'y',
      ]);
    });

    test('renaming a group moves its picks, tab and unfolding', () async {
      await testDatabase.profilesDao.putAll([
        profile(profileId)
            .copyWith(
              type: ProfileType.custom,
              selectedMap: const {'Old': 'DIRECT', 'Parent': 'Old'},
              currentGroupName: 'Old',
              unfoldSet: const {'Old', 'Parent'},
            )
            .toCompanion(),
      ]);
      expect(notifier.put(group(1, 'Old')), isTrue);
      expect(notifier.put(group(2, 'Parent', proxies: ['Old'])), isTrue);
      await pumpEventQueue();

      expect(notifier.put(group(1, 'New')), isTrue);
      await pumpEventQueue();

      final row = (await testDatabase.profilesDao.query().get()).single;
      expect(row.selectedMap, {'New': 'DIRECT', 'Parent': 'New'});
      expect(row.currentGroupName, 'New');
      expect(row.unfoldSet, {'New', 'Parent'});
    });

    test('put records the icon so it can be reused later', () async {
      expect(
        notifier.put(group(1, 'Iconic').copyWith(icon: 'https://icon.example')),
        isTrue,
      );
      await pumpEventQueue();

      expect(
        await testDatabase.iconRecordsDao.get('https://icon.example'),
        isNotNull,
      );
    });

    test('delAll removes every listed group', () async {
      expect(notifier.put(group(1, 'Gone')), isTrue);
      await pumpEventQueue();
      expect(notifier.put(group(2, 'AlsoGone')), isTrue);
      await pumpEventQueue();
      expect(notifier.put(group(3, 'Kept')), isTrue);
      await pumpEventQueue();

      notifier.delAll([1, 2]);
      await pumpEventQueue();

      expect(read().map((item) => item.id), [3]);
      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      expect(rows.map((item) => item.id), [3]);
    });

    test('order moves a group and persists the new key', () async {
      expect(notifier.put(group(1, 'One')), isTrue);
      await pumpEventQueue();
      expect(notifier.put(group(2, 'Two')), isTrue);
      await pumpEventQueue();

      final before = read().map((item) => item.id).toList();
      notifier.order(0, 1);
      await pumpEventQueue();

      final rows = await testDatabase.proxyGroupsDao.query(profileId).get();
      expect(rows.map((item) => item.id), before.reversed);
    });

    test('delAll restores the previous list when the write fails', () async {
      expect(notifier.put(group(1, 'Kept')), isTrue);
      await pumpEventQueue();
      await breakTable('proxy_groups');

      final failure = captureWriteFailure(() => notifier.delAll([1]));
      expect(read(), isEmpty, reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.name), ['Kept'], reason: 'rolled back');
    });
  });
}

class _GatedProfileRules extends ProfileRules {
  final landing = Completer<void>();

  @override
  Future<void> persistRule(Rule rule) async {
    await landing.future;
    await super.persistRule(rule);
  }
}
