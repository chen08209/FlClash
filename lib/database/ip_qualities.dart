part of 'database.dart';

@DataClassName('IpQualityRecord')
class IpQualities extends Table {
  @override
  String get tableName => 'ip_qualities';

  TextColumn get ip => text()();

  TextColumn get quality => text().map(const IpQualityConverter())();

  DateTimeColumn get checkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ip};
}

@DriftAccessor(tables: [IpQualities])
class IpQualitiesDao extends DatabaseAccessor<Database>
    with _$IpQualitiesDaoMixin {
  IpQualitiesDao(super.attachedDatabase);

  Expression<bool> _checkedWithin($IpQualitiesTable t, Duration maxAge) {
    final now = DateTime.now();
    return t.checkedAt.isBetweenValues(now.subtract(maxAge), now);
  }

  Future<IpQualityRecord?> fresh(String ip, Duration maxAge) {
    return ipQualities
        .readable(
          (row) => row,
          where: (t) => t.ip.equals(ip) & _checkedWithin(t, maxAge),
        )
        .getSingleOrNull();
  }

  /// Also drops every record older than [maxAge].
  Future<void> put(IpQuality quality, DateTime checkedAt, Duration maxAge) {
    return transaction(() async {
      await ipQualities.remove((t) => _checkedWithin(t, maxAge).not());
      await ipQualities.put(
        IpQualitiesCompanion.insert(
          ip: quality.ip,
          quality: quality,
          checkedAt: checkedAt,
        ),
      );
    });
  }
}
