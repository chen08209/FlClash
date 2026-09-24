part of 'database.dart';

@DataClassName('RawScript')
class Scripts extends Table {
  @override
  String get tableName => 'scripts';

  IntColumn get id => integer()();

  TextColumn get label => text()();

  DateTimeColumn get lastUpdateTime => dateTime()();

  TextColumn get url => text().nullable()();

  IntColumn get order => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [Scripts])
class ScriptsDao extends DatabaseAccessor<Database> with _$ScriptsDaoMixin {
  ScriptsDao(super.attachedDatabase);

  Selectable<Script> query() {
    final stmt = scripts.select();
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return stmt.map((item) => item.toScript());
  }

  Future<void> putAll(Iterable<ScriptsCompanion> items) async {
    await batch((b) async {
      b.insertAllOnConflictUpdate(scripts, items);
    });
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
    return Script(
      id: id,
      label: label,
      lastUpdateTime: lastUpdateTime,
      url: url,
      order: order,
    );
  }
}

extension ScriptsCompanionExt on Script {
  ScriptsCompanion toCompanion([int? order]) {
    return ScriptsCompanion.insert(
      id: Value(id),
      label: label,
      lastUpdateTime: lastUpdateTime,
      url: Value(url),
      order: Value(order ?? this.order),
    );
  }
}
