part of 'database.dart';

@DataClassName('RawClashProvider')
class ClashProviders extends Table {
  @override
  String get tableName => 'clash_providers';

  IntColumn get id => integer()();

  TextColumn get kind => textEnum<ProviderKind>()();

  TextColumn get label => text()();

  TextColumn get url => text()();

  TextColumn get behavior => textEnum<RuleProviderBehavior>().nullable()();

  TextColumn get format => textEnum<RuleProviderFormat>().nullable()();

  IntColumn get order => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [ClashProviders])
class ClashProvidersDao extends DatabaseAccessor<Database>
    with _$ClashProvidersDaoMixin {
  ClashProvidersDao(super.attachedDatabase);

  SimpleSelectStatement<$ClashProvidersTable, RawClashProvider>
  _orderedSelect() {
    final stmt = clashProviders.select();
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return stmt;
  }

  Selectable<ClashProvider> query(ProviderKind kind) {
    final stmt = _orderedSelect()..where((t) => t.kind.equalsValue(kind));
    return stmt.map((item) => item.toClashProvider());
  }

  Selectable<ClashProvider> queryAll() {
    return _orderedSelect().map((item) => item.toClashProvider());
  }

  Selectable<String> fileNames() {
    return clashProviders.select().map(
      (item) => item.toClashProvider().fileName,
    );
  }

  Future<void> putAll(Iterable<ClashProvidersCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(clashProviders, items);
    });
  }

  void putAllWithBatch(Batch batch, Iterable<ClashProvider> providers) {
    batch.insertAllOnConflictUpdate(
      clashProviders,
      providers.map((item) => item.toCompanion()),
    );
  }

  void setAllWithBatch(Batch batch, Iterable<ClashProvider> providers) {
    clashProviders.setAll(
      batch,
      providers.map((provider) => provider.toCompanion()),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }
}

extension RawClashProviderExt on RawClashProvider {
  ClashProvider toClashProvider() {
    return ClashProvider(
      id: id,
      kind: kind,
      label: label,
      url: url,
      behavior: behavior,
      format: format,
      order: order,
    );
  }
}

extension ClashProvidersCompanionExt on ClashProvider {
  ClashProvidersCompanion toCompanion([int? order]) {
    return ClashProvidersCompanion.insert(
      id: Value(id),
      kind: kind,
      label: label,
      url: url,
      behavior: Value(behavior),
      format: Value(format),
      order: Value(order ?? this.order),
    );
  }
}
