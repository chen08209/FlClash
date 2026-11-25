import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<Rule>> _readGlobalRules(Database db) =>
    db.rulesDao.queryGlobalRules().get();

Future<List<ProxyGroup>> Function(Database) _readGroups(int profileId) =>
    (db) => db.proxyGroupsDao.query(profileId).get();

Future<List<Rule>> _readGlobalRulesSlowly(Database db) async {
  final rules = await db.rulesDao.queryGlobalRules().get();
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return rules;
}

Rule _rule(int id) => Rule(
  id: id,
  ruleAction: RuleAction.DOMAIN,
  content: '$id.example.com',
  ruleTarget: 'DIRECT',
);

void main() {
  test(
    'readApart falls back to the same isolate for in-memory databases',
    () async {
      final db = Database(NativeDatabase.memory());
      addTearDown(db.close);

      const rule = Rule(
        id: 1,
        ruleAction: RuleAction.DOMAIN,
        content: 'example.com',
        ruleTarget: 'DIRECT',
      );
      await db.rulesDao.putRule(rule);

      final loaded = await db.readApart(_readGlobalRules);
      expect(loaded, [rule]);
    },
  );

  test(
    'readApart and watchApart read file-backed WAL databases off-isolate',
    () async {
      final dir = await Directory.systemTemp.createTemp('flclash_read_apart_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/test.sqlite');
      final db = Database.onFile(file);
      addTearDown(db.close);

      final mode = await db.customSelect('PRAGMA journal_mode').getSingle();
      expect(mode.data.values.first.toString().toLowerCase(), 'wal');

      const firstRule = Rule(
        id: 10,
        ruleAction: RuleAction.DOMAIN,
        content: 'a.example.com',
        ruleTarget: 'DIRECT',
      );
      await db.rulesDao.putRule(firstRule);

      final readOnce = await db.readApart(_readGlobalRules);
      expect(readOnce, [firstRule]);

      final emissions = <List<Rule>>[];
      final secondArrived = Completer<void>();
      final sub = db.watchApart([db.rules], _readGlobalRules).listen((rows) {
        emissions.add(rows);
        if (rows.length == 2 && !secondArrived.isCompleted) {
          secondArrived.complete();
        }
      });
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last, [firstRule]);

      const secondRule = Rule(
        id: 11,
        ruleAction: RuleAction.DOMAIN,
        content: 'b.example.com',
        ruleTarget: 'REJECT',
      );
      await db.rulesDao.putRule(secondRule);
      await secondArrived.future.timeout(const Duration(seconds: 5));

      expect(emissions.last.map((r) => r.id).toSet(), {10, 11});
    },
  );

  test(
    'readApart maps proxy groups with JSON definitions on file DB',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'flclash_groups_apart_',
      );
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/test.sqlite');
      final db = Database.onFile(file);
      addTearDown(db.close);

      await db.profiles.put(
        const Profile(
          id: 7,
          label: 'Custom',
          type: ProfileType.custom,
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      );
      const group = ProxyGroup(
        id: 42,
        profileId: 7,
        name: 'Auto',
        type: GroupType.URLTest,
        proxies: ['NodeA', 'NodeB'],
        url: 'https://www.gstatic.com/generate_204',
        interval: 300,
      );
      await db.proxyGroups.put(group.toCompanion(7));

      final loaded = await db.readApart(_readGroups(7));
      expect(loaded, [group]);
    },
  );

  test('watchApart drops a read that a later change overtook', () async {
    final dir = await Directory.systemTemp.createTemp('flclash_read_apart_');
    addTearDown(() => dir.delete(recursive: true));
    final db = Database.onFile(File('${dir.path}/test.sqlite'));
    addTearDown(db.close);
    await db.rulesDao.putRule(_rule(1));

    final emitted = <Set<int>>[];
    final all = Completer<void>();
    final sub = db.watchApart([db.rules], _readGlobalRulesSlowly).listen((
      rows,
    ) {
      emitted.add({for (final rule in rows) rule.id});
      if (rows.length == 3) {
        all.complete();
      }
    });
    addTearDown(sub.cancel);
    while (emitted.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    await db.rulesDao.putRule(_rule(2));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await db.rulesDao.putRule(_rule(3));
    await all.future.timeout(const Duration(seconds: 10));

    expect(emitted, [
      {1},
      {1, 2, 3},
    ]);
  });
}
