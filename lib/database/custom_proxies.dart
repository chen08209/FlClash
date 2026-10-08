part of 'database.dart';

@DataClassName('RawCustomProxy')
class CustomProxies extends Table {
  @override
  String get tableName => 'custom_proxies';

  IntColumn get id => integer()();

  TextColumn get definition => text().map(const JsonMapConverter())();

  TextColumn get order => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [CustomProxies])
class CustomProxiesDao extends DatabaseAccessor<Database>
    with _$CustomProxiesDaoMixin {
  CustomProxiesDao(super.attachedDatabase);

  Selectable<CustomProxy> query() {
    return customProxies.readable(
      (row) => row.toCustomProxy(),
      orderBy: [
        (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
      ],
    );
  }

  Future<int> order({required CustomProxy proxy, required String order}) {
    return customProxies.insertOnConflictUpdate(proxy.toCompanion(order));
  }

  void setAllWithBatch(Batch batch, Iterable<CustomProxy> items) {
    final keys = indexing.generateNKeys(items.length);
    customProxies.setAll(
      batch,
      items.mapIndexed((index, item) => item.toCompanion(keys[index])),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }

  Future<void> delAll(Iterable<int> ids) {
    return batch((b) {
      customProxies.deleteInChunks(b, ids, (t, chunk) => t.id.isIn(chunk));
    });
  }

  void putAllWithBatch(Batch batch, Iterable<CustomProxy> items) {
    batch.insertAllOnConflictUpdate(
      customProxies,
      items.map((item) => item.toCompanion()),
    );
  }
}

extension RawCustomProxyExt on RawCustomProxy {
  CustomProxy toCustomProxy() {
    return CustomProxy(id: id, definition: definition, order: order);
  }
}

extension CustomProxiesCompanionExt on CustomProxy {
  CustomProxiesCompanion toCompanion([String? order]) {
    return CustomProxiesCompanion.insert(
      id: Value(id),
      definition: definition,
      order: Value(order ?? this.order),
    );
  }
}
