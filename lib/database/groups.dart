part of 'database.dart';

@DataClassName('RawProxyGroup')
@TableIndex(
  name: 'idx_proxy_groups_profile_order',
  columns: {#profileId, #order},
)
class ProxyGroups extends Table {
  @override
  String get tableName => 'proxy_groups';

  IntColumn get id => integer()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get proxies =>
      text().map(const StringListConverter()).nullable()();

  TextColumn get use => text().map(const StringListConverter()).nullable()();

  TextColumn get definition => text().withDefault(const Constant('{}'))();

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

  /// In Dart, as a SQL replace on the JSON list breaks on quotes and commas.
  Future<void> rewrite(
    Iterable<ProxyGroup> groups,
    ProxyGroup Function(ProxyGroup group) rewrite,
  ) async {
    for (final group in groups) {
      final next = rewrite(group);
      if (next != group) {
        await (proxyGroups.update()..where((t) => t.id.equals(group.id))).write(
          next.toCompanion(),
        );
      }
    }
  }

  Selectable<String> names({int? except}) {
    final query = selectOnly(proxyGroups, distinct: true)
      ..addColumns([proxyGroups.name]);
    if (except != null) {
      query.where(proxyGroups.profileId.equals(except).not());
    }
    return query.map((row) => row.read(proxyGroups.name)!);
  }

  Future<Set<int>> profileIdsUsing(String provider) async {
    final query = selectOnly(proxyGroups)
      ..addColumns([proxyGroups.profileId, proxyGroups.use])
      ..where(proxyGroups.use.isNotNull());
    return {
      for (final row in await query.get())
        if (row.readWithConverter(proxyGroups.use)!.contains(provider))
          row.read(proxyGroups.profileId)!,
    };
  }

  Future<void> renameUse(
    Iterable<int> profileIds, {
    required String oldName,
    required String newName,
  }) async {
    if (profileIds.isEmpty) {
      return;
    }
    final rows =
        await (proxyGroups.select()
              ..where((t) => t.profileId.isIn(profileIds) & t.use.isNotNull()))
            .get();
    for (final row in rows) {
      final use = row.use!;
      if (!use.contains(oldName)) {
        continue;
      }
      await (proxyGroups.update()..where((t) => t.id.equals(row.id))).write(
        ProxyGroupsCompanion(
          use: Value([
            for (final name in use) name == oldName ? newName : name,
          ]),
        ),
      );
    }
  }

  void setAllWithBatch(Batch batch, Iterable<ProxyGroup> proxyGroups) {
    final keys = indexing.generateNKeys(proxyGroups.length);
    this.proxyGroups.setAll(
      batch,
      proxyGroups.mapIndexed(
        (index, item) => item.toCompanion(null, keys[index]),
      ),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }

  void setProfileGroupsWithBatch(
    int profileId,
    Batch batch,
    Iterable<ProxyGroup> proxyGroups,
  ) {
    this.proxyGroups.setAll(
      batch,
      proxyGroups.map((item) => item.toCompanion(profileId)),
      deleteFilter: (t) => t.profileId.equals(profileId),
      preDelete: true,
    );
  }

  Future<void> delAll(Iterable<int> ids) {
    return batch((b) {
      proxyGroups.deleteInChunks(b, ids, (t, chunk) => t.id.isIn(chunk));
    });
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

const _proxyGroupColumnKeys = {
  'profileId',
  'id',
  'name',
  'type',
  'proxies',
  'use',
  'order',
};

extension RawProxyGroupExt on RawProxyGroup {
  ProxyGroup toProxyGroup() {
    final options = decodeOrRestoreDefault(
      'proxy group options',
      () => Map<String, Object?>.from(json.decode(definition)),
      () => const <String, Object?>{},
    );
    return decodeSalvaging(
      'proxy group options',
      options,
      (options) => ProxyGroup.fromJson({
        ...options,
        'profileId': profileId,
        'id': id,
        'name': name,
        'type': type,
        'proxies': proxies,
        'use': use,
        'order': order,
      }),
    );
  }
}

extension ProxyGroupsCompanionExt on ProxyGroup {
  ProxyGroupsCompanion toCompanion([int? profileId, String? order]) {
    return ProxyGroupsCompanion.insert(
      id: Value(id),
      profileId: (this.profileId ?? profileId)!,
      name: name,
      type: type.value,
      proxies: Value(proxies),
      use: Value(use),
      definition: Value(
        json.encode({
          for (final MapEntry(:key, :value) in toJson().entries)
            if (value != null && !_proxyGroupColumnKeys.contains(key))
              key: value,
        }),
      ),
      order: Value(order ?? this.order),
    );
  }
}
