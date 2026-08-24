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

  /// Runs [body] in a guarded zone and completes with the error the failed
  /// write reported.
  ///
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

  /// Makes every subsequent write to [table] fail.
  ///
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

    test('setAndReorder replaces the whole list', () async {
      notifier.put(profile(1, label: 'One'));
      await pumpEventQueue();

      notifier.setAndReorder([profile(2, label: 'Two', order: 0)]);
      expect(read().map((item) => item.id), [2]);
      await pumpEventQueue();

      final rows = await testDatabase.profilesDao.query().get();
      expect(rows.map((item) => item.id), [2]);
    });

    test('reorder only writes the rows whose order actually changed', () async {
      notifier.setAndReorder([
        profile(1, label: 'One', order: 0),
        profile(2, label: 'Two', order: 1),
      ]);
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
      notifier.setAndReorder([
        profile(1, label: 'One', order: 0),
        profile(2, label: 'Two', order: 1),
      ]);
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

    test('isExits matches on label', () async {
      notifier.put(script(1, 'Known'));
      await pumpEventQueue();

      expect(notifier.isExits('Known'), isTrue);
      expect(notifier.isExits('Unknown'), isFalse);
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
      final rows = await testDatabase.rulesDao.queryGlobalAddedRules().get();
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

      final rows = await testDatabase.rulesDao.queryGlobalAddedRules().get();
      expect(rows.map((item) => item.id), [2, 1]);
    });

    test('delAll removes every listed rule', () async {
      notifier.put(const Rule(id: 1, content: 'first'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'second'));
      await pumpEventQueue();

      notifier.delAll([1, 2]);
      await pumpEventQueue();

      expect(read(), isEmpty);
      expect(
        await testDatabase.rulesDao.queryGlobalAddedRules().get(),
        isEmpty,
      );
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

      final rows = await testDatabase.rulesDao.queryGlobalAddedRules().get();
      expect(rows.map((item) => item.id), before.reversed);
    });
  });

  group('ProfileCustomRules', () {
    late ProfileCustomRules notifier;

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await keepAlive(profileCustomRulesProvider(profileId));
      notifier = container.read(profileCustomRulesProvider(profileId).notifier);
    });

    List<Rule> read() => notifier.value;

    test('put scopes the rule to its profile', () async {
      notifier.put(const Rule(id: 1, content: 'custom'));
      await pumpEventQueue();

      expect(read().single.id, 1);
      final scoped = await testDatabase.rulesDao
          .queryProfileCustomRules(profileId)
          .get();
      expect(scoped.single.id, 1);
      expect(
        await testDatabase.rulesDao.queryGlobalAddedRules().get(),
        isEmpty,
        reason: 'a custom rule must not leak into the global scene',
      );
    });

    test('delAll and order round-trip through the profile scene', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'two'));
      await pumpEventQueue();

      final before = read().map((item) => item.id).toList();
      notifier.order(0, 1);
      await pumpEventQueue();
      expect(
        (await testDatabase.rulesDao.queryProfileCustomRules(profileId).get())
            .map((item) => item.id),
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
  });

  group('ProfileAddedRules', () {
    late ProfileAddedRules notifier;

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await keepAlive(profileAddedRulesProvider(profileId));
      notifier = container.read(profileAddedRulesProvider(profileId).notifier);
    });

    List<Rule> read() => notifier.value;

    test('put scopes the rule to its profile', () async {
      notifier.put(const Rule(id: 1, content: 'added'));
      await pumpEventQueue();

      final scoped = await testDatabase.rulesDao
          .queryProfileAddedRules(profileId)
          .get();
      expect(scoped.single.id, 1);
      expect(
        await testDatabase.rulesDao.queryProfileCustomRules(profileId).get(),
        isEmpty,
        reason: 'added and custom are separate scenes of the same table',
      );
    });

    test('order rewrites the order key within the added scene', () async {
      notifier.put(const Rule(id: 1, content: 'one'));
      await pumpEventQueue();
      notifier.put(const Rule(id: 2, content: 'two'));
      await pumpEventQueue();

      final before = read().map((item) => item.id).toList();
      notifier.order(0, 1);
      await pumpEventQueue();

      expect(
        (await testDatabase.rulesDao.queryProfileAddedRules(profileId).get())
            .map((item) => item.id),
        before.reversed,
      );
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
  });

  group('ProfileDisabledRuleIds', () {
    late ProfileDisabledRuleIds notifier;

    setUp(() async {
      await testDatabase.profilesDao.putAll([profile(profileId).toCompanion()]);
      await testDatabase.rulesDao.putProfileAddedRule(
        profileId,
        const Rule(id: 7, content: 'toggled', order: 'a'),
      );
      await keepAlive(profileDisabledRuleIdsProvider(profileId));
      notifier = container.read(
        profileDisabledRuleIdsProvider(profileId).notifier,
      );
    });

    List<int> read() => notifier.value;

    test('put links the rule and del unlinks it', () async {
      notifier.put(7);
      expect(read(), [7]);
      await pumpEventQueue();

      expect(
        (await testDatabase.rulesDao.queryProfileDisabledRules(profileId).get())
            .map((item) => item.id),
        [7],
      );

      notifier.del(7);
      await pumpEventQueue();
      expect(read(), isEmpty);
      expect(
        await testDatabase.rulesDao.queryProfileDisabledRules(profileId).get(),
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
      await breakTable('profile_rule_mapping');

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
      expect(
        rows.map((item) => item.id),
        [1, 2],
        reason: 'new groups are appended, so the keys must be increasing',
      );
    });

    test('put rejects a second group that reuses an existing name', () async {
      expect(notifier.put(group(1, 'Taken')), isTrue);
      await pumpEventQueue();

      expect(notifier.put(group(2, 'Taken')), isFalse);
      await pumpEventQueue();

      expect(read(), hasLength(1));
    });

    test('renaming a group rewrites the custom rules that target it', () async {
      expect(notifier.put(group(1, 'Old')), isTrue);
      await pumpEventQueue();
      await testDatabase.rulesDao.putProfileCustomRule(
        profileId,
        const Rule(id: 9, content: 'x', ruleTarget: 'Old', order: 'a'),
      );

      expect(notifier.put(group(1, 'New')), isTrue);
      await pumpEventQueue();

      final rules = await testDatabase.rulesDao
          .queryProfileCustomRules(profileId)
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

    test('del removes the group', () async {
      expect(notifier.put(group(1, 'Gone')), isTrue);
      await pumpEventQueue();

      notifier.del('Gone');
      await pumpEventQueue();

      expect(read(), isEmpty);
      expect(await testDatabase.proxyGroupsDao.query(profileId).get(), isEmpty);
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

    test('del restores the previous list when the write fails', () async {
      expect(notifier.put(group(1, 'Kept')), isTrue);
      await pumpEventQueue();
      await breakTable('proxy_groups');

      final failure = captureWriteFailure(() => notifier.del('Kept'));
      expect(read(), isEmpty, reason: 'optimistic');

      await failure;
      expect(read().map((item) => item.name), ['Kept'], reason: 'rolled back');
    });
  });
}
