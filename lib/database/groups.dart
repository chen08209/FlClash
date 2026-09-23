part of 'database.dart';

@DataClassName('RawProxyGroup')
@TableIndex(
  name: 'idx_profile_name_order',
  columns: {#profileId, #name, #order},
)
class ProxyGroups extends Table {
  @override
  String get tableName => 'proxy_groups';

  IntColumn get id => integer()();

  IntColumn get profileId => integer().nullable().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get proxies =>
      text().map(const StringListConverter()).nullable()();

  TextColumn get use => text().map(const StringListConverter()).nullable()();

  TextColumn get url => text().nullable()();

  IntColumn get interval => integer().nullable()();

  IntColumn get timeout => integer().nullable()();

  IntColumn get maxFailedTimes => integer().nullable()();

  BoolColumn get lazy => boolean().nullable()();

  BoolColumn get disableUDP => boolean().nullable()();

  TextColumn get filter => text().nullable()();

  TextColumn get excludeFilter => text().nullable()();

  TextColumn get excludeType => text().nullable()();

  TextColumn get expectedStatus => text().nullable()();

  BoolColumn get includeAll => boolean().nullable()();

  BoolColumn get includeAllProxies => boolean().nullable()();

  BoolColumn get includeAllProviders => boolean().nullable()();

  BoolColumn get hidden => boolean().nullable()();

  TextColumn get icon => text().nullable()();

  TextColumn get order => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [ProxyGroups])
class ProxyGroupsDao extends DatabaseAccessor<Database>
    with _$ProxyGroupsDaoMixin {
  ProxyGroupsDao(super.attachedDatabase);

  Selectable<ProxyGroup> query(int profileId) {
    final stmt = proxyGroups.select();
    stmt.where((row) => row.profileId.equals(profileId));
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
    ]);
    return stmt.map((item) => item.toProxyGroup());
  }

  Selectable<int> count(int profileId) {
    final stmt = proxyGroups.select();
    stmt.where((row) => row.profileId.equals(profileId));
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
    ]);
    return stmt.count;
  }

  Future<int> order(
    int profileId, {
    required ProxyGroup proxyGroup,
    required String order,
  }) async {
    return proxyGroups.insertOnConflictUpdate(
      proxyGroup.toCompanion(profileId, order),
    );
  }

  Future<void> renameProxies(
    int profileId, {
    required String oldName,
    required String newName,
  }) {
    return customUpdate(
      'UPDATE ${proxyGroups.entityName} '
      'SET ${proxyGroups.proxies.name} = REPLACE(${proxyGroups.proxies.name}, ?, ?) '
      'WHERE ${proxyGroups.profileId.name} = ?',
      variables: [
        Variable.withString('"$oldName"'),
        Variable.withString('"$newName"'),
        Variable.withInt(profileId),
      ],
    );
  }

  void setAllWithBatch(
    int? profileId,
    Batch batch,
    Iterable<ProxyGroup> proxyGroups,
  ) async {
    final keys = indexing.generateNKeys(proxyGroups.length);
    this.proxyGroups.setAll(
      batch,
      proxyGroups.mapIndexed(
        (index, item) => item.toCompanion(profileId, keys[index]),
      ),
      deleteFilter: (row) => profileId == null
          ? const Constant(true)
          : row.profileId.equals(profileId),
      preDelete: true,
    );
  }

  void putAllWithBatch(Batch batch, Iterable<ProxyGroup> proxyGroups) {
    final keys = indexing.generateNKeys(proxyGroups.length);
    batch.insertAllOnConflictUpdate(
      this.proxyGroups,
      proxyGroups.mapIndexed(
        (index, item) => item.toCompanion(null, keys[index]),
      ),
    );
  }
}

extension RawProxyGroupExt on RawProxyGroup {
  ProxyGroup toProxyGroup() {
    return ProxyGroup(
      profileId: profileId,
      id: id,
      name: name,
      type: GroupType.parse(type),
      proxies: proxies,
      use: use,
      url: url,
      interval: interval,
      timeout: timeout,
      maxFailedTimes: maxFailedTimes,
      lazy: lazy,
      disableUDP: disableUDP,
      filter: filter,
      excludeFilter: excludeFilter,
      excludeType: excludeType,
      expectedStatus: expectedStatus,
      includeAll: includeAll,
      includeAllProxies: includeAllProxies,
      includeAllProviders: includeAllProviders,
      hidden: hidden,
      icon: icon,
      order: order,
    );
  }
}

extension ProxyGroupsCompanionExt on ProxyGroup {
  ProxyGroupsCompanion toCompanion([int? profileId, String? order]) {
    return ProxyGroupsCompanion.insert(
      id: Value(id),
      profileId: Value(this.profileId ?? profileId),
      name: name,
      type: type.value,
      proxies: Value(proxies),
      use: Value(use),
      url: Value(url),
      interval: Value(interval),
      timeout: Value(timeout),
      maxFailedTimes: Value(maxFailedTimes),
      lazy: Value(lazy),
      disableUDP: Value(disableUDP),
      filter: Value(filter),
      excludeFilter: Value(excludeFilter),
      excludeType: Value(excludeType),
      expectedStatus: Value(expectedStatus),
      includeAll: Value(includeAll),
      includeAllProxies: Value(includeAllProxies),
      includeAllProviders: Value(includeAllProviders),
      hidden: Value(hidden),
      icon: Value(icon),
      order: Value(order ?? this.order),
    );
  }
}
