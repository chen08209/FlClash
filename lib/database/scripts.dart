part of 'database.dart';

@DataClassName('RawScript')
class Scripts extends Table {
  @override
  String get tableName => 'scripts';

  IntColumn get id => integer()();

  TextColumn get label => text()();

  DateTimeColumn get lastUpdateTime => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [Scripts])
class ScriptsDao extends DatabaseAccessor<Database> with _$ScriptsDaoMixin {
  ScriptsDao(super.attachedDatabase);

  Selectable<Script> query() {
    return scripts.select().map((item) => item.toScript());
  }

  Selectable<Script> get(int scriptId) {
    final stmt = scripts.select();
    stmt.where((t) => t.id.equals(scriptId));
    return stmt.map((it) => it.toScript());
  }

  Selectable<String> fileNames() {
    final query = scripts.selectOnly()..addColumns([scripts.id]);
    return query.map((row) => '${row.read(scripts.id)}.js');
  }

  Future<void> setAll(Iterable<Script> scripts) async {
    await batch((b) async {
      await setAllWithBatch(b, scripts);
    });
  }

  void putAllWithBatch(Batch batch, Iterable<Script> scripts) {
    batch.insertAllOnConflictUpdate(
      this.scripts,
      scripts.map((item) => item.toCompanion()),
    );
  }

  Future<void> setAllWithBatch(Batch batch, Iterable<Script> scripts) async {
    final List<ScriptsCompanion> items = [];
    final List<int> ids = [];
    for (final script in scripts) {
      ids.add(script.id);
      items.add(script.toCompanion());
    }
    this.scripts.setAll(batch, items, deleteFilter: (t) => t.id.isNotIn(ids));
  }
}

extension RawScriptExt on RawScript {
  Script toScript() {
    return Script(id: id, label: label, lastUpdateTime: lastUpdateTime);
  }
}

extension ScriptsCompanionExt on Script {
  ScriptsCompanion toCompanion() {
    return ScriptsCompanion.insert(
      id: Value(id),
      label: label,
      lastUpdateTime: lastUpdateTime,
    );
  }
}
