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
  Set<Column> get primaryKey => {profileId, name};
}

@DriftAccessor(tables: [ProxyGroups])
class ProxyGroupsDao extends DatabaseAccessor<Database>
    with _$ProxyGroupsDaoMixin {
  ProxyGroupsDao(super.attachedDatabase);

  Selectable<ProxyGroup> all() {
    final stmt = proxyGroups.select();
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
    ]);
    return stmt.map((item) => item.toProxyGroup());
  }
}

extension RawProxyGroupExt on RawProxyGroup {
  ProxyGroup toProxyGroup() {
    return ProxyGroup(
      name: name,
      type: GroupType.parseProfileType(type),
      proxies: proxies,
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
  ProxyGroupsCompanion toCompanion(int profileId) {
    return ProxyGroupsCompanion.insert(
      profileId: Value(profileId),
      name: name,
      type: type.name,
      proxies: Value(proxies),
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
      order: Value(order),
    );
  }
}
