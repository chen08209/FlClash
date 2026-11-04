part of 'database.dart';

@DataClassName('AppTrafficRecord')
@TableIndex(name: 'idx_app_traffic_profile_day', columns: {#profileId, #day})
class AppTrafficRecords extends Table {
  @override
  String get tableName => 'app_traffic_records';

  IntColumn get day => integer()();

  IntColumn get profileId => integer()();

  TextColumn get profileLabel => text()();

  TextColumn get applicationId => text()();

  TextColumn get applicationLabel => text()();

  TextColumn get processPath => text()();

  TextColumn get proxy => text()();

  TextColumn get provider => text()();

  IntColumn get upload => integer().withDefault(const Constant(0))();

  IntColumn get download => integer().withDefault(const Constant(0))();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {
    day,
    profileId,
    applicationId,
    proxy,
    provider,
  };
}

@DriftAccessor(tables: [AppTrafficRecords])
class AppTrafficDao extends DatabaseAccessor<Database>
    with _$AppTrafficDaoMixin {
  AppTrafficDao(super.attachedDatabase);

  Future<void> addAll(Iterable<AppTrafficDelta> deltas) async {
    final values = deltas.where((delta) => delta.total > 0).toList();
    if (values.isEmpty) {
      return;
    }
    await transaction(() async {
      for (final delta in values) {
        await customStatement(
          'INSERT INTO app_traffic_records '
          '(day, profile_id, profile_label, application_id, '
          'application_label, process_path, proxy, provider, upload, '
          'download, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
          'ON CONFLICT(day, profile_id, application_id, proxy, provider) '
          'DO UPDATE SET profile_label = excluded.profile_label, '
          'application_label = excluded.application_label, '
          'process_path = excluded.process_path, '
          'upload = app_traffic_records.upload + excluded.upload, '
          'download = app_traffic_records.download + excluded.download, '
          'updated_at = excluded.updated_at',
          [
            delta.day.millisecondsSinceEpoch,
            delta.profileId,
            delta.profileLabel,
            delta.applicationId,
            delta.applicationLabel,
            delta.processPath,
            delta.proxy,
            delta.provider,
            delta.upload,
            delta.download,
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      }
    });
    attachedDatabase.notifyUpdates({TableUpdate.onTable(appTrafficRecords)});
  }

  Selectable<AppTrafficUsage> queryUsage({int? profileId, DateTime? since}) {
    final conditions = <String>[];
    final variables = <Variable<Object>>[];
    if (profileId != null) {
      conditions.add('profile_id = ?');
      variables.add(Variable.withInt(profileId));
    }
    if (since != null) {
      conditions.add('day >= ?');
      variables.add(Variable.withInt(since.millisecondsSinceEpoch));
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return customSelect(
      'SELECT application_id, MAX(application_label) AS application_label, '
      'MAX(process_path) AS process_path, SUM(upload) AS upload, '
      'SUM(download) AS download, GROUP_CONCAT(DISTINCT proxy) AS proxies, '
      'GROUP_CONCAT(DISTINCT provider) AS providers '
      'FROM app_traffic_records $where GROUP BY application_id '
      'ORDER BY SUM(upload + download) DESC, application_label ASC',
      variables: variables,
      readsFrom: {appTrafficRecords},
    ).map((row) {
      List<String> values(String column) {
        return (row.readNullable<String>(column) ?? '')
            .split(',')
            .where((value) => value.isNotEmpty)
            .toList();
      }

      return AppTrafficUsage(
        applicationId: row.read<String>('application_id'),
        applicationLabel: row.read<String>('application_label'),
        processPath: row.read<String>('process_path'),
        upload: row.read<int>('upload'),
        download: row.read<int>('download'),
        proxies: values('proxies'),
        providers: values('providers'),
      );
    });
  }

  Future<int> clear({int? profileId}) {
    final stmt = appTrafficRecords.delete();
    if (profileId != null) {
      stmt.where((row) => row.profileId.equals(profileId));
    }
    return stmt.go();
  }
}
