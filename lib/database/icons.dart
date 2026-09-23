part of 'database.dart';

@DataClassName('IconRecord')
@TableIndex(name: 'last_accessed_url', columns: {#lastAccessed, #url})
class IconRecords extends Table {
  @override
  String get tableName => 'icon_records';

  TextColumn get url => text()();

  IntColumn get lastAccessed => integer()();

  @override
  Set<Column> get primaryKey => {url};
}

@DriftAccessor(tables: [IconRecords])
class IconRecordsDao extends DatabaseAccessor<Database>
    with _$IconRecordsDaoMixin {
  IconRecordsDao(super.attachedDatabase);

  final int maxCapacity = 1000;

  Future<IconRecord?> get(String url) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    return transaction(() async {
      final query = select(iconRecords)..where((t) => t.url.equals(url));
      final record = await query.getSingleOrNull();

      if (record != null) {
        await (update(iconRecords)..where((t) => t.url.equals(url))).write(
          IconRecordsCompanion(lastAccessed: Value(now)),
        );
      }
      return record;
    });
  }

  Future<void> putIfAbsent(String url) async {
    final existing = await (select(
      iconRecords,
    )..where((t) => t.url.equals(url))).getSingleOrNull();
    if (existing != null) return;
    await put(url);
  }

  Future<void> put(String url) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(iconRecords).insertOnConflictUpdate(
        IconRecordsCompanion.insert(url: url, lastAccessed: now),
      );

      final count = await iconRecords.count.getSingle() ?? 0;

      if (count > maxCapacity) {
        final oldestRecords =
            await (select(iconRecords)
                  ..orderBy([
                    (t) => OrderingTerm(
                      expression: t.lastAccessed,
                      mode: OrderingMode.asc,
                    ),
                  ])
                  ..limit(count - maxCapacity))
                .get();

        final oldestUrls = oldestRecords.map((e) => e.url).toList();
        await (delete(iconRecords)..where((t) => t.url.isIn(oldestUrls))).go();
      }
    });
  }

  Future<List<IconRecord>> query(String query) {
    return (select(iconRecords)
          ..where((t) => t.url.contains(query))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.lastAccessed,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }
}
