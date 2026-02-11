part of 'database.dart';

@DataClassName('RawProxyGroup')
@TableIndex(
  name: 'idx_profile_name_order',
  columns: {#profileId, #name, #order},
)
class ProxyGroups extends Table {
  @override
  String get tableName => 'proxy_groups';

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

  IntColumn get testTimeout => integer().nullable()();

  IntColumn get maxFailedTimes => integer().nullable()();

  BoolColumn get lazy => boolean().nullable()();

  BoolColumn get disableUdp => boolean().nullable()();

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
  Set<Column> get primaryKey => {profileId, name};
}

@DriftAccessor(tables: [ProxyGroups])
class ProxyGroupsDao extends DatabaseAccessor<Database>
    with _$ProxyGroupsDaoMixin {
  ProxyGroupsDao(super.attachedDatabase);

  // Selectable<ProxyGroup> all() {
  //   final stmt = proxyGroups.select();
  //   stmt.orderBy([
  //         (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
  //   ]);
  //   return stmt.map((item) => item.toProfile());
  // }
}
