part of 'database.dart';

@DataClassName('RawCustomProxy')
@TableIndex(
  name: 'idx_custom_proxies_profile_order',
  columns: {#profileId, #order},
)
class CustomProxies extends Table {
  @override
  String get tableName => 'custom_proxies';

  IntColumn get id => integer()();

  IntColumn get profileId => integer().nullable().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get definition => text().map(const JsonMapConverter())();

  TextColumn get order => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [CustomProxies])
class CustomProxiesDao extends DatabaseAccessor<Database>
    with _$CustomProxiesDaoMixin {
  CustomProxiesDao(super.attachedDatabase);

  Selectable<CustomProxy> query(int profileId) {
    final stmt = customProxies.select();
    stmt.where((row) => row.profileId.equals(profileId));
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
    ]);
    return stmt.map((item) => item.toCustomProxy());
  }

  Selectable<int> count(int profileId) {
    final stmt = customProxies.select();
    stmt.where((row) => row.profileId.equals(profileId));
    return stmt.count;
  }

  Future<int> order(
    int profileId, {
    required CustomProxy proxy,
    required String order,
  }) {
    return customProxies.insertOnConflictUpdate(
      proxy.toCompanion(profileId, order),
    );
  }

  void setAllWithBatch(
    int? profileId,
    Batch batch,
    Iterable<CustomProxy> items,
  ) {
    final keys = indexing.generateNKeys(items.length);
    customProxies.setAll(
      batch,
      items.mapIndexed(
        (index, item) => item.toCompanion(profileId, keys[index]),
      ),
      deleteFilter: (row) => profileId == null
          ? const Constant(true)
          : row.profileId.equals(profileId),
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
    return CustomProxy(
      profileId: profileId,
      id: id,
      definition: definition,
      order: order,
    );
  }
}

extension CustomProxiesCompanionExt on CustomProxy {
  CustomProxiesCompanion toCompanion([int? profileId, String? order]) {
    return CustomProxiesCompanion.insert(
      id: Value(id),
      profileId: Value(this.profileId ?? profileId),
      definition: definition,
      order: Value(order ?? this.order),
    );
  }
}
