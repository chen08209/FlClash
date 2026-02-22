import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

part 'generated/database.g.dart';
part 'links.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';

@DriftDatabase(
  tables: [Profiles, Scripts, Rules, ProfileRuleLinks],
  daos: [ProfilesDao, ScriptsDao, RulesDao],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(profiles, profiles.loginPassword);
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  Future<void> restore(
    List<Profile> profiles,
    List<Script> scripts,
    List<Rule> rules,
    List<ProfileRuleLink> links, {
    bool isOverride = false,
  }) async {
    if (profiles.isNotEmpty ||
        scripts.isNotEmpty ||
        rules.isNotEmpty ||
        links.isNotEmpty) {
      await batch((b) {
        isOverride
            ? profilesDao.setAllWithBatch(b, profiles)
            : profilesDao.putAllWithBatch(
                b,
                profiles.map((item) => item.toCompanion()),
              );
        scriptsDao.setAllWithBatch(b, scripts);
        rulesDao.restoreWithBatch(b, rules, links);
      });
    }
  }
}

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
  }) async {
    batch.insertAllOnConflictUpdate(this, items);
    batch.deleteWhere(this, deleteFilter);
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return await (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return await insertOnConflictUpdate(item);
  }
}

final database = Database();
