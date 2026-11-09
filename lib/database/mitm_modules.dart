part of 'database.dart';

@DataClassName('RawMitmModule')
class MitmModules extends Table {
  @override
  String get tableName => 'mitm_modules';

  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get url => text().nullable()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  IntColumn get order => integer().nullable()();

  TextColumn get arguments => text()
      .map(const StringMapConverter())
      .withDefault(const Constant('{}'))();

  TextColumn get resources => text()
      .map(const StringMapConverter())
      .withDefault(const Constant('{}'))();

  TextColumn get system => text().nullable()();

  IntColumn get scripts => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastUpdateTime => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [MitmModules])
class MitmModulesDao extends DatabaseAccessor<Database>
    with _$MitmModulesDaoMixin {
  MitmModulesDao(super.attachedDatabase);

  Selectable<MitmModule> query() {
    return mitmModules.readable(
      (row) => row.toMitmModule(),
      orderBy: [
        (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
        (t) => OrderingTerm.asc(t.id),
      ],
    );
  }

  Future<void> putAll(Iterable<MitmModulesCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(mitmModules, items);
    });
  }

  void putAllWithBatch(Batch batch, Iterable<MitmModule> modules) {
    batch.insertAllOnConflictUpdate(
      mitmModules,
      modules.map((item) => item.toCompanion()),
    );
  }

  void setAllWithBatch(Batch batch, Iterable<MitmModule> modules) {
    final ids = [for (final module in modules) module.id];
    mitmModules.setAll(
      batch,
      modules.map((item) => item.toCompanion()),
      deleteFilter: (t) => t.id.isNotIn(ids),
    );
  }
}

extension RawMitmModuleExt on RawMitmModule {
  MitmModule toMitmModule() {
    return MitmModule(
      id: id,
      name: name,
      description: description,
      url: url,
      enabled: enabled,
      order: order,
      arguments: arguments,
      resources: resources,
      system: this.system,
      scripts: scripts,
      lastUpdateTime: lastUpdateTime,
    );
  }
}

extension MitmModulesCompanionExt on MitmModule {
  MitmModulesCompanion toCompanion([int? order]) {
    return MitmModulesCompanion.insert(
      id: Value(id),
      name: name,
      description: Value(description),
      url: Value(url),
      enabled: Value(enabled),
      order: Value(order ?? this.order),
      arguments: Value(arguments),
      resources: Value(resources),
      system: Value(this.system),
      scripts: Value(scripts),
      lastUpdateTime: lastUpdateTime,
    );
  }
}
