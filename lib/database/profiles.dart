part of 'database.dart';

@DataClassName('RawProfile')
class Profiles extends Table {
  @override
  String get tableName => 'profiles';

  IntColumn get id => integer()();

  TextColumn get label => text()();

  TextColumn get currentGroupName => text().nullable()();

  TextColumn get url => text()();

  DateTimeColumn get lastUpdateDate => dateTime().nullable()();

  TextColumn get overwriteType => textEnum<OverwriteType>()();

  IntColumn get scriptId => integer().nullable()();

  IntColumn get autoUpdateDurationMillis => integer()();

  TextColumn get subscriptionInfo =>
      text().map(const SubscriptionInfoConverter()).nullable()();

  BoolColumn get autoUpdate => boolean()();

  TextColumn get selectedMap => text().map(const StringMapConverter())();

  TextColumn get unfoldSet => text().map(const StringSetConverter())();

  IntColumn get order => integer().nullable()();

  TextColumn get loginPassword => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SubscriptionInfoConverter
    extends TypeConverter<SubscriptionInfo?, String?> {
  const SubscriptionInfoConverter();

  @override
  SubscriptionInfo? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return SubscriptionInfo.fromJson(json.decode(fromDb));
  }

  @override
  String? toSql(SubscriptionInfo? value) {
    if (value == null) return null;
    return json.encode(value.toJson());
  }
}

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<Database> with _$ProfilesDaoMixin {
  ProfilesDao(super.attachedDatabase);

  Selectable<Profile> all() {
    final stmt = profiles.select();
    stmt.orderBy([
      (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return stmt.map((item) => item.toProfile());
  }

  Future<void> setAll(Iterable<Profile> profiles) async {
    await batch((b) async {
      setAllWithBatch(b, profiles);
    });
  }

  Future<void> putAll<T extends Table, D extends DataClass>(
    Iterable<Insertable<D>> items,
  ) async {
    await batch((b) async {
      putAllWithBatch(b, items);
    });
  }

  void putAllWithBatch<T extends Table, D extends DataClass>(
    Batch batch,
    Iterable<Insertable<D>> items,
  ) {
    batch.insertAllOnConflictUpdate(profiles, items);
  }

  void setAllWithBatch(Batch batch, Iterable<Profile> profiles) {
    final List<ProfilesCompanion> items = [];
    final List<int> ids = [];
    profiles.forEachIndexed((index, profile) {
      ids.add(profile.id);
      items.add(profile.toCompanion(index));
    });

    this.profiles.setAll(batch, items, deleteFilter: (t) => t.id.isNotIn(ids));
  }
}

class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();

  @override
  Map<String, String> fromSql(String fromDb) {
    return Map<String, String>.from(json.decode(fromDb));
  }

  @override
  String toSql(Map<String, String> value) {
    return json.encode(value);
  }
}

class StringSetConverter extends TypeConverter<Set<String>, String> {
  const StringSetConverter();

  @override
  Set<String> fromSql(String fromDb) {
    return Set<String>.from(json.decode(fromDb));
  }

  @override
  String toSql(Set<String> value) {
    return json.encode(value.toList());
  }
}

extension RawProfilExt on RawProfile {
  Profile toProfile() {
    return Profile(
      id: id,
      label: label,
      currentGroupName: currentGroupName,
      url: url,
      lastUpdateDate: lastUpdateDate,
      autoUpdateDuration: Duration(milliseconds: autoUpdateDurationMillis),
      subscriptionInfo: subscriptionInfo,
      autoUpdate: autoUpdate,
      selectedMap: selectedMap,
      unfoldSet: unfoldSet,
      overwriteType: overwriteType,
      scriptId: scriptId,
      order: order,
      loginPassword: loginPassword,
    );
  }
}

extension ProfilesCompanionExt on Profile {
  ProfilesCompanion toCompanion([int? order]) {
    return ProfilesCompanion.insert(
      id: Value(id),
      label: label,
      currentGroupName: Value(currentGroupName),
      url: url,
      lastUpdateDate: Value(lastUpdateDate),
      autoUpdateDurationMillis: autoUpdateDuration.inMilliseconds,
      subscriptionInfo: Value(subscriptionInfo),
      autoUpdate: autoUpdate,
      selectedMap: selectedMap,
      unfoldSet: unfoldSet,
      overwriteType: overwriteType,
      scriptId: Value(scriptId),
      order: Value(order ?? this.order),
      loginPassword: Value(loginPassword),
    );
  }
}
