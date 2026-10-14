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
      final record = await iconRecords
          .readable((row) => row, where: (t) => t.url.equals(url))
          .getSingleOrNull();

      if (record != null) {
        await (update(iconRecords)..where((t) => t.url.equals(url))).write(
          IconRecordsCompanion(lastAccessed: Value(now)),
        );
      }
      return record;
    });
  }

  Future<void> put(String url) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(iconRecords).insertOnConflictUpdate(
        IconRecordsCompanion.insert(url: url, lastAccessed: now),
      );

      final count = await iconRecords.count.getSingle() ?? 0;

      if (count > maxCapacity) {
        final oldestUrls = selectOnly(iconRecords)
          ..addColumns([iconRecords.url])
          ..orderBy([OrderingTerm.asc(iconRecords.lastAccessed)])
          ..limit(count - maxCapacity);
        await (delete(
          iconRecords,
        )..where((t) => t.url.isInQuery(oldestUrls))).go();
      }
    });
  }

  Future<void> del(String url) {
    return iconRecords.remove((t) => t.url.equals(url));
  }

  Future<List<IconRecord>> query(String query) {
    return iconRecords
        .readable(
          (row) => row,
          where: (t) => t.url.contains(query),
          orderBy: [
            (t) => OrderingTerm(
              expression: t.lastAccessed,
              mode: OrderingMode.desc,
            ),
          ],
        )
        .get();
  }
}

@DataClassName('RawIconSet')
class IconSets extends Table {
  @override
  String get tableName => 'icon_sets';

  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get url => text()();

  TextColumn get icons => text().map(const IconSetIconsConverter())();

  DateTimeColumn get lastUpdateTime => dateTime().nullable()();

  IntColumn get order => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [IconSets])
class IconSetsDao extends DatabaseAccessor<Database> with _$IconSetsDaoMixin {
  IconSetsDao(super.attachedDatabase);

  Selectable<IconSet> query() {
    return iconSets.readable(
      (row) => row.toIconSet(),
      orderBy: [
        (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
        (t) => OrderingTerm.asc(t.id),
      ],
    );
  }

  Future<void> putAll(Iterable<IconSetsCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(iconSets, items);
    });
  }
}

extension RawIconSetExt on RawIconSet {
  IconSet toIconSet() {
    return IconSet(
      id: id,
      name: name,
      url: url,
      icons: icons,
      lastUpdateTime: lastUpdateTime,
      order: order,
    );
  }
}

extension IconSetsCompanionExt on IconSet {
  IconSetsCompanion toCompanion([int? order]) {
    return IconSetsCompanion.insert(
      id: Value(id),
      name: name,
      url: url,
      icons: icons,
      lastUpdateTime: Value(lastUpdateTime),
      order: Value(order ?? this.order),
    );
  }
}
