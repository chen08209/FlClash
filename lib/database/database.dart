import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'clash_providers.dart';
part 'converter.dart';
part 'custom_proxies.dart';
part 'generated/database.g.dart';
part 'groups.dart';
part 'icons.dart';
part 'links.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Scripts,
    Rules,
    ProfileRuleLinks,
    ProxyGroups,
    IconRecords,
    ClashProviders,
    CustomProxies,
  ],
  daos: [
    ProfilesDao,
    ScriptsDao,
    RulesDao,
    ProxyGroupsDao,
    IconRecordsDao,
    ClashProvidersDao,
    CustomProxiesDao,
  ],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 10;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(proxyGroups);
          await m.createTable(iconRecords);
          await _resetOrders();
          await _migrateRules(m);
        }
        if (from < 3) {
          await _addColumnIfMissing(m, profiles, profiles.matchTarget);
        }
        if (from < 4) {
          await _addColumnIfMissing(m, scripts, scripts.url);
        }
        if (from < 5) {
          await _addColumnIfMissing(m, scripts, scripts.order);
        }
        if (from < 6) {
          await _createTableIfMissing(m, clashProviders);
        }
        if (from < 7) {
          await _addColumnIfMissing(m, proxyGroups, proxyGroups.tolerance);
          await _addColumnIfMissing(m, proxyGroups, proxyGroups.strategy);
        }
        if (from < 8) {
          await m.alterTable(TableMigration(clashProviders));
        }
        // Ahead of the version 9 step, whose purge reaches every table.
        if (from < 10) {
          await _createTableIfMissing(m, customProxies);
        }
        if (from < 9) {
          await _purgeOrphans();
        }
      },
      beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    );
  }

  /// Drift rewinds user_version on downgrade but keeps the tables it added.
  Future<void> _createTableIfMissing(Migrator m, TableInfo table) async {
    final tableInfo = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    if (tableInfo.isNotEmpty) {
      return;
    }
    await m.createTable(table);
  }

  /// Drift rewinds user_version on downgrade but keeps the columns it added.
  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final tableInfo = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final exists = tableInfo.any(
      (row) => row.read<String>('name') == column.name,
    );
    if (exists) {
      return;
    }
    await m.addColumn(table, column);
  }

  Future<void> _migrateRules(Migrator m) async {
    final tableInfo = await customSelect('PRAGMA table_info(rules)').get();
    final columnNames = tableInfo
        .map((row) => row.read<String>('name'))
        .toList();
    if (columnNames.isEmpty) {
      await m.createTable(rules);
      return;
    } else if (columnNames.contains('rule_action')) {
      return;
    }
    await customStatement(
      'ALTER TABLE rules ADD COLUMN rule_action TEXT NOT NULL DEFAULT ""',
    );
    await customStatement('ALTER TABLE rules ADD COLUMN content TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN rule_target TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN rule_provider TEXT');
    await customStatement('ALTER TABLE rules ADD COLUMN sub_rule TEXT');
    await customStatement(
      'ALTER TABLE rules ADD COLUMN no_resolve INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement(
      'ALTER TABLE rules ADD COLUMN src INTEGER NOT NULL DEFAULT 0',
    );
    final oldRows = await customSelect('SELECT id, value FROM rules').get();
    for (final row in oldRows) {
      final id = row.read<int>('id');
      final value = row.read<String>('value');
      final parsed = Rule.parse(value, id: id);
      await customStatement(
        'UPDATE rules SET rule_action = ?, content = ?, rule_target = ?, rule_provider = ?, sub_rule = ?, no_resolve = ?, src = ? WHERE id = ?',
        [
          parsed.ruleAction.name,
          parsed.content,
          parsed.ruleTarget,
          parsed.ruleProvider,
          parsed.subRule,
          parsed.noResolve ? 1 : 0,
          parsed.src ? 1 : 0,
          id,
        ],
      );
    }
    await customStatement('ALTER TABLE rules DROP COLUMN value');
    await m.createIndex(idxRuleTarget);
  }

  Future<void> _resetOrders() async {
    await rulesDao.resetOrders();
  }

  Future<void> restore(
    List<Profile> profiles,
    List<Script> scripts,
    List<Rule> rules,
    List<ProfileRuleLink> links,
    List<ProxyGroup> proxyGroups, {
    List<ClashProvider> clashProviders = const [],
    List<CustomProxy> customProxies = const [],
    bool isOverride = false,
  }) async {
    if (profiles.isEmpty &&
        scripts.isEmpty &&
        rules.isEmpty &&
        links.isEmpty &&
        proxyGroups.isEmpty &&
        clashProviders.isEmpty &&
        customProxies.isEmpty) {
      return;
    }
    await transaction(() async {
      // Backups taken while foreign keys were off may carry orphaned rows.
      await customStatement('PRAGMA defer_foreign_keys = ON');
      await batch((b) {
        if (isOverride) {
          profilesDao.setAllWithBatch(b, profiles);
          scriptsDao.setAllWithBatch(b, scripts);
          rulesDao.restoreWithBatch(b, rules, links);
          proxyGroupsDao.setAllWithBatch(null, b, proxyGroups);
          customProxiesDao.setAllWithBatch(null, b, customProxies);
          clashProvidersDao.setAllWithBatch(b, clashProviders);
          return;
        }
        profilesDao.putAllWithBatch(
          b,
          profiles.map((item) => item.toCompanion()),
        );
        scriptsDao.putAllWithBatch(b, scripts);
        rulesDao.mergeWithBatch(b, rules, links);
        proxyGroupsDao.putAllWithBatch(b, proxyGroups);
        customProxiesDao.putAllWithBatch(b, customProxies);
        clashProvidersDao.putAllWithBatch(b, clashProviders);
      });
      await _purgeOrphans();
    });
  }

  Future<void> deleteProfile(int profileId) {
    return transaction(() async {
      await profiles.remove((t) => t.id.equals(profileId));
      await rulesDao.delUnlinkedRules();
    });
  }

  Future<void> _purgeOrphans() async {
    final profileIds = selectOnly(profiles)..addColumns([profiles.id]);
    final ruleIds = selectOnly(rules)..addColumns([rules.id]);
    await profileRuleLinks.remove(
      (t) =>
          t.ruleId.isNotInQuery(ruleIds) |
          (t.profileId.isNotNull() & t.profileId.isNotInQuery(profileIds)),
    );
    await proxyGroups.remove(
      (t) => t.profileId.isNotNull() & t.profileId.isNotInQuery(profileIds),
    );
    await customProxies.remove(
      (t) => t.profileId.isNotNull() & t.profileId.isNotInQuery(profileIds),
    );
    await rulesDao.delUnlinkedRules();
  }

  Future<void> setProfileCustomData(
    int profileId,
    List<CustomProxy> proxies,
    List<ProxyGroup> groups,
    List<Rule> rules,
  ) async {
    await batch((b) {
      customProxiesDao.setAllWithBatch(profileId, b, proxies);
      proxyGroupsDao.setAllWithBatch(profileId, b, groups);
      rulesDao.setCustomRulesWithBatch(profileId, b, rules);
    });
  }
}

// SQLite builds before 3.32 cap a statement at 999 bound parameters.
const _maxBoundValues = 900;

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
    bool preDelete = false,
  }) async {
    if (preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
    batch.insertAllOnConflictUpdate(this, items);
    if (!preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
  }

  void deleteInChunks<V extends Object>(
    Batch batch,
    Iterable<V> values,
    Expression<bool> Function(Tbl tbl, List<V> chunk) filter,
  ) {
    for (final chunk in values.chunks(_maxBoundValues)) {
      batch.deleteWhere(this, (tbl) => filter(tbl, chunk));
    }
  }

  Selectable<int?> get count {
    final countExp = countAll();
    final query = select().addColumns([countExp]);
    return query.map((row) => row.read(countExp));
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return insertOnConflictUpdate(item);
  }
}

extension SimpleSelectStatementExt<T extends HasResultSet, D>
    on SimpleSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    final query = addColumns([countExp]);
    return query.map((row) => row.read(countExp)!);
  }
}

extension JoinedSelectStatementExt<T extends HasResultSet, D>
    on JoinedSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    addColumns([countExp]);
    return map((row) => row.read(countExp)!);
  }
}

Database _database = Database();

Database get database => _database;

@visibleForTesting
set database(Database value) => _database = value;
