part of 'database.dart';

@DataClassName('RawProxyDialer')
class ProxyDialers extends Table {
  @override
  String get tableName => 'proxy_dialers';

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  IntColumn get proxyId =>
      integer().references(CustomProxies, #id, onDelete: KeyAction.cascade)();

  TextColumn get target => text()();

  @override
  Set<Column> get primaryKey => {profileId, proxyId};
}

@DriftAccessor(tables: [ProxyDialers])
class ProxyDialersDao extends DatabaseAccessor<Database>
    with _$ProxyDialersDaoMixin {
  ProxyDialersDao(super.attachedDatabase);

  Selectable<ProxyDialer> query(int profileId) {
    return proxyDialers.readable(
      (row) => row.toProxyDialer(),
      where: (t) => t.profileId.equals(profileId),
    );
  }

  Future<void> set(int profileId, int proxyId, String? target) async {
    if (target == null) {
      await proxyDialers.remove(
        (t) => t.profileId.equals(profileId) & t.proxyId.equals(proxyId),
      );
      return;
    }
    await proxyDialers.put(
      ProxyDialer(
        profileId: profileId,
        proxyId: proxyId,
        target: target,
      ).toCompanion(),
    );
  }

  void setProfileDialersWithBatch(
    int profileId,
    Batch batch,
    Map<int, String> dialers,
  ) {
    proxyDialers.setAll(
      batch,
      [
        for (final MapEntry(:key, :value) in dialers.entries)
          ProxyDialer(
            profileId: profileId,
            proxyId: key,
            target: value,
          ).toCompanion(),
      ],
      deleteFilter: (t) => t.profileId.equals(profileId),
      preDelete: true,
    );
  }

  Future<void> renameTarget(
    int profileId, {
    required String oldName,
    required String newName,
  }) {
    final stmt = proxyDialers.update();
    stmt.where((t) => t.profileId.equals(profileId) & t.target.equals(oldName));
    return stmt.write(ProxyDialersCompanion(target: Value(newName)));
  }

  Future<Map<int, Set<String>>> targetsNaming(Set<String> names) async {
    final query = selectOnly(proxyDialers, distinct: true)
      ..addColumns([proxyDialers.profileId, proxyDialers.target])
      ..where(proxyDialers.target.isIn(names));
    final targets = <int, Set<String>>{};
    for (final row in await query.get()) {
      targets
          .putIfAbsent(row.read(proxyDialers.profileId)!, () => {})
          .add(row.read(proxyDialers.target)!);
    }
    return targets;
  }

  void setAllWithBatch(Batch batch, Iterable<ProxyDialer> items) {
    proxyDialers.setAll(
      batch,
      items.map((item) => item.toCompanion()),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }

  void putAllWithBatch(Batch batch, Iterable<ProxyDialer> items) {
    batch.insertAllOnConflictUpdate(
      proxyDialers,
      items.map((item) => item.toCompanion()),
    );
  }
}

extension RawProxyDialerExt on RawProxyDialer {
  ProxyDialer toProxyDialer() {
    return ProxyDialer(profileId: profileId, proxyId: proxyId, target: target);
  }
}

extension ProxyDialersCompanionExt on ProxyDialer {
  ProxyDialersCompanion toCompanion() {
    return ProxyDialersCompanion.insert(
      profileId: profileId,
      proxyId: proxyId,
      target: target,
    );
  }
}
