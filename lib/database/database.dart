import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:path_provider/path_provider.dart';

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

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'database',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
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

  Future<void> setAll<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    Iterable<Insertable<D>> items, {
    required Expression<bool> Function(T tbl) deleteFilter,
  }) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(table, items);
      b.deleteWhere(table, deleteFilter);
    });
  }

  Future<void> putAll<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    Iterable<Insertable<D>> items,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(table, items);
    });
  }
}

final database = Database();
