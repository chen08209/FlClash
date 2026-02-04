part of 'database.dart';

@DataClassName('RawGroup')
class Groups extends Table {
  @override
  String get tableName => 'groups';

  IntColumn get profileId => integer().nullable().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get name => text().named('name')();

  TextColumn get type => text().named('type')();

  TextColumn get proxies =>
      text().map(const StringListConverter()).nullable().named('proxies')();

  TextColumn get use =>
      text().map(const StringListConverter()).nullable().named('use')();

  TextColumn get url => text().nullable().named('url')();

  IntColumn get interval => integer().nullable().named('interval')();

  IntColumn get testTimeout => integer().nullable().named('timeout')();

  IntColumn get maxFailedTimes =>
      integer().nullable().named('max_failed_times')();

  BoolColumn get lazy => boolean().nullable().named('lazy')();

  BoolColumn get disableUdp => boolean().nullable().named('disable_udp')();

  TextColumn get filter => text().nullable().named('filter')();

  TextColumn get excludeFilter => text().nullable().named('exclude_filter')();

  TextColumn get excludeType => text().nullable().named('exclude_type')();

  TextColumn get expectedStatus => text().nullable().named('expected_status')();

  BoolColumn get includeAll => boolean().nullable().named('include_all')();

  BoolColumn get includeAllProxies =>
      boolean().nullable().named('include_all_proxies')();

  BoolColumn get includeAllProviders =>
      boolean().nullable().named('include_all_providers')();

  BoolColumn get hidden => boolean().nullable().named('hidden')();

  TextColumn get icon => text().nullable().named('icon')();

  @override
  Set<Column> get primaryKey => {profileId, name};
}
