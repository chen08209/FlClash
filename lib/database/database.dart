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
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  Future<int> put<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    Insertable<D> item,
  ) async {
    return await table.insertOnConflictUpdate(item);
  }

  Future<int> remove<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    Expression<bool> Function(T tbl) filter,
  ) async {
    return await (table.delete()..where(filter)).go();
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
}

final database = Database();
