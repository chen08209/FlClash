// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, RawProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProfileType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProfileType>($ProfilesTable.$convertertype);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentGroupNameMeta = const VerificationMeta(
    'currentGroupName',
  );
  @override
  late final GeneratedColumn<String> currentGroupName = GeneratedColumn<String>(
    'current_group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageSecretKeyMeta = const VerificationMeta(
    'ageSecretKey',
  );
  @override
  late final GeneratedColumn<String> ageSecretKey = GeneratedColumn<String>(
    'age_secret_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdateDateMeta = const VerificationMeta(
    'lastUpdateDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateDate =
      GeneratedColumn<DateTime>(
        'last_update_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ExtendType, String> extendType =
      GeneratedColumn<String>(
        'extend_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExtendType>($ProfilesTable.$converterextendType);
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<int> scriptId = GeneratedColumn<int>(
    'script_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchTargetMeta = const VerificationMeta(
    'matchTarget',
  );
  @override
  late final GeneratedColumn<String> matchTarget = GeneratedColumn<String>(
    'match_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoUpdateDurationMillisMeta =
      const VerificationMeta('autoUpdateDurationMillis');
  @override
  late final GeneratedColumn<int> autoUpdateDurationMillis =
      GeneratedColumn<int>(
        'auto_update_duration_millis',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  subscriptionInfo = GeneratedColumn<String>(
    'subscription_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<SubscriptionInfo?>($ProfilesTable.$convertersubscriptionInfo);
  static const VerificationMeta _autoUpdateMeta = const VerificationMeta(
    'autoUpdate',
  );
  @override
  late final GeneratedColumn<bool> autoUpdate = GeneratedColumn<bool>(
    'auto_update',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_update" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  selectedMap = GeneratedColumn<String>(
    'selected_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($ProfilesTable.$converterselectedMap);
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>, String> unfoldSet =
      GeneratedColumn<String>(
        'unfold_set',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<String>>($ProfilesTable.$converterunfoldSet);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProfileOverrides?, String>
  overrides = GeneratedColumn<String>(
    'overrides',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ProfileOverrides?>($ProfilesTable.$converteroverrides);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    label,
    currentGroupName,
    url,
    ageSecretKey,
    lastUpdateDate,
    extendType,
    scriptId,
    matchTarget,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
    overrides,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('current_group_name')) {
      context.handle(
        _currentGroupNameMeta,
        currentGroupName.isAcceptableOrUnknown(
          data['current_group_name']!,
          _currentGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('age_secret_key')) {
      context.handle(
        _ageSecretKeyMeta,
        ageSecretKey.isAcceptableOrUnknown(
          data['age_secret_key']!,
          _ageSecretKeyMeta,
        ),
      );
    }
    if (data.containsKey('last_update_date')) {
      context.handle(
        _lastUpdateDateMeta,
        lastUpdateDate.isAcceptableOrUnknown(
          data['last_update_date']!,
          _lastUpdateDateMeta,
        ),
      );
    }
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    }
    if (data.containsKey('match_target')) {
      context.handle(
        _matchTargetMeta,
        matchTarget.isAcceptableOrUnknown(
          data['match_target']!,
          _matchTargetMeta,
        ),
      );
    }
    if (data.containsKey('auto_update_duration_millis')) {
      context.handle(
        _autoUpdateDurationMillisMeta,
        autoUpdateDurationMillis.isAcceptableOrUnknown(
          data['auto_update_duration_millis']!,
          _autoUpdateDurationMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateDurationMillisMeta);
    }
    if (data.containsKey('auto_update')) {
      context.handle(
        _autoUpdateMeta,
        autoUpdate.isAcceptableOrUnknown(data['auto_update']!, _autoUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $ProfilesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      currentGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_group_name'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      ageSecretKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_secret_key'],
      ),
      lastUpdateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_date'],
      ),
      extendType: $ProfilesTable.$converterextendType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extend_type'],
        )!,
      ),
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}script_id'],
      ),
      matchTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_target'],
      ),
      autoUpdateDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_duration_millis'],
      )!,
      subscriptionInfo: $ProfilesTable.$convertersubscriptionInfo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subscription_info'],
        ),
      ),
      autoUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_update'],
      )!,
      selectedMap: $ProfilesTable.$converterselectedMap.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_map'],
        )!,
      ),
      unfoldSet: $ProfilesTable.$converterunfoldSet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unfold_set'],
        )!,
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
      overrides: $ProfilesTable.$converteroverrides.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}overrides'],
        ),
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProfileType, String, String> $convertertype =
      const EnumNameConverter<ProfileType>(ProfileType.values);
  static JsonTypeConverter2<ExtendType, String, String> $converterextendType =
      const EnumNameConverter<ExtendType>(ExtendType.values);
  static TypeConverter<SubscriptionInfo?, String?> $convertersubscriptionInfo =
      const SubscriptionInfoConverter();
  static TypeConverter<Map<String, String>, String> $converterselectedMap =
      const StringMapConverter();
  static TypeConverter<Set<String>, String> $converterunfoldSet =
      const StringSetConverter();
  static TypeConverter<ProfileOverrides?, String?> $converteroverrides =
      const ProfileOverridesConverter();
}

class RawProfile extends DataClass implements Insertable<RawProfile> {
  final int id;
  final ProfileType type;
  final String label;
  final String? currentGroupName;
  final String url;
  final String? ageSecretKey;
  final DateTime? lastUpdateDate;
  final ExtendType extendType;
  final int? scriptId;
  final String? matchTarget;
  final int autoUpdateDurationMillis;
  final SubscriptionInfo? subscriptionInfo;
  final bool autoUpdate;
  final Map<String, String> selectedMap;
  final Set<String> unfoldSet;
  final int? order;
  final ProfileOverrides? overrides;
  const RawProfile({
    required this.id,
    required this.type,
    required this.label,
    this.currentGroupName,
    required this.url,
    this.ageSecretKey,
    this.lastUpdateDate,
    required this.extendType,
    this.scriptId,
    this.matchTarget,
    required this.autoUpdateDurationMillis,
    this.subscriptionInfo,
    required this.autoUpdate,
    required this.selectedMap,
    required this.unfoldSet,
    this.order,
    this.overrides,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>($ProfilesTable.$convertertype.toSql(type));
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || currentGroupName != null) {
      map['current_group_name'] = Variable<String>(currentGroupName);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || ageSecretKey != null) {
      map['age_secret_key'] = Variable<String>(ageSecretKey);
    }
    if (!nullToAbsent || lastUpdateDate != null) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate);
    }
    {
      map['extend_type'] = Variable<String>(
        $ProfilesTable.$converterextendType.toSql(extendType),
      );
    }
    if (!nullToAbsent || scriptId != null) {
      map['script_id'] = Variable<int>(scriptId);
    }
    if (!nullToAbsent || matchTarget != null) {
      map['match_target'] = Variable<String>(matchTarget);
    }
    map['auto_update_duration_millis'] = Variable<int>(
      autoUpdateDurationMillis,
    );
    if (!nullToAbsent || subscriptionInfo != null) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo),
      );
    }
    map['auto_update'] = Variable<bool>(autoUpdate);
    {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap),
      );
    }
    {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    if (!nullToAbsent || overrides != null) {
      map['overrides'] = Variable<String>(
        $ProfilesTable.$converteroverrides.toSql(overrides),
      );
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      type: Value(type),
      label: Value(label),
      currentGroupName: currentGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(currentGroupName),
      url: Value(url),
      ageSecretKey: ageSecretKey == null && nullToAbsent
          ? const Value.absent()
          : Value(ageSecretKey),
      lastUpdateDate: lastUpdateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateDate),
      extendType: Value(extendType),
      scriptId: scriptId == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptId),
      matchTarget: matchTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(matchTarget),
      autoUpdateDurationMillis: Value(autoUpdateDurationMillis),
      subscriptionInfo: subscriptionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionInfo),
      autoUpdate: Value(autoUpdate),
      selectedMap: Value(selectedMap),
      unfoldSet: Value(unfoldSet),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
      overrides: overrides == null && nullToAbsent
          ? const Value.absent()
          : Value(overrides),
    );
  }

  factory RawProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfile(
      id: serializer.fromJson<int>(json['id']),
      type: $ProfilesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      label: serializer.fromJson<String>(json['label']),
      currentGroupName: serializer.fromJson<String?>(json['currentGroupName']),
      url: serializer.fromJson<String>(json['url']),
      ageSecretKey: serializer.fromJson<String?>(json['ageSecretKey']),
      lastUpdateDate: serializer.fromJson<DateTime?>(json['lastUpdateDate']),
      extendType: $ProfilesTable.$converterextendType.fromJson(
        serializer.fromJson<String>(json['extendType']),
      ),
      scriptId: serializer.fromJson<int?>(json['scriptId']),
      matchTarget: serializer.fromJson<String?>(json['matchTarget']),
      autoUpdateDurationMillis: serializer.fromJson<int>(
        json['autoUpdateDurationMillis'],
      ),
      subscriptionInfo: serializer.fromJson<SubscriptionInfo?>(
        json['subscriptionInfo'],
      ),
      autoUpdate: serializer.fromJson<bool>(json['autoUpdate']),
      selectedMap: serializer.fromJson<Map<String, String>>(
        json['selectedMap'],
      ),
      unfoldSet: serializer.fromJson<Set<String>>(json['unfoldSet']),
      order: serializer.fromJson<int?>(json['order']),
      overrides: serializer.fromJson<ProfileOverrides?>(json['overrides']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $ProfilesTable.$convertertype.toJson(type),
      ),
      'label': serializer.toJson<String>(label),
      'currentGroupName': serializer.toJson<String?>(currentGroupName),
      'url': serializer.toJson<String>(url),
      'ageSecretKey': serializer.toJson<String?>(ageSecretKey),
      'lastUpdateDate': serializer.toJson<DateTime?>(lastUpdateDate),
      'extendType': serializer.toJson<String>(
        $ProfilesTable.$converterextendType.toJson(extendType),
      ),
      'scriptId': serializer.toJson<int?>(scriptId),
      'matchTarget': serializer.toJson<String?>(matchTarget),
      'autoUpdateDurationMillis': serializer.toJson<int>(
        autoUpdateDurationMillis,
      ),
      'subscriptionInfo': serializer.toJson<SubscriptionInfo?>(
        subscriptionInfo,
      ),
      'autoUpdate': serializer.toJson<bool>(autoUpdate),
      'selectedMap': serializer.toJson<Map<String, String>>(selectedMap),
      'unfoldSet': serializer.toJson<Set<String>>(unfoldSet),
      'order': serializer.toJson<int?>(order),
      'overrides': serializer.toJson<ProfileOverrides?>(overrides),
    };
  }

  RawProfile copyWith({
    int? id,
    ProfileType? type,
    String? label,
    Value<String?> currentGroupName = const Value.absent(),
    String? url,
    Value<String?> ageSecretKey = const Value.absent(),
    Value<DateTime?> lastUpdateDate = const Value.absent(),
    ExtendType? extendType,
    Value<int?> scriptId = const Value.absent(),
    Value<String?> matchTarget = const Value.absent(),
    int? autoUpdateDurationMillis,
    Value<SubscriptionInfo?> subscriptionInfo = const Value.absent(),
    bool? autoUpdate,
    Map<String, String>? selectedMap,
    Set<String>? unfoldSet,
    Value<int?> order = const Value.absent(),
    Value<ProfileOverrides?> overrides = const Value.absent(),
  }) => RawProfile(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label ?? this.label,
    currentGroupName: currentGroupName.present
        ? currentGroupName.value
        : this.currentGroupName,
    url: url ?? this.url,
    ageSecretKey: ageSecretKey.present ? ageSecretKey.value : this.ageSecretKey,
    lastUpdateDate: lastUpdateDate.present
        ? lastUpdateDate.value
        : this.lastUpdateDate,
    extendType: extendType ?? this.extendType,
    scriptId: scriptId.present ? scriptId.value : this.scriptId,
    matchTarget: matchTarget.present ? matchTarget.value : this.matchTarget,
    autoUpdateDurationMillis:
        autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
    subscriptionInfo: subscriptionInfo.present
        ? subscriptionInfo.value
        : this.subscriptionInfo,
    autoUpdate: autoUpdate ?? this.autoUpdate,
    selectedMap: selectedMap ?? this.selectedMap,
    unfoldSet: unfoldSet ?? this.unfoldSet,
    order: order.present ? order.value : this.order,
    overrides: overrides.present ? overrides.value : this.overrides,
  );
  RawProfile copyWithCompanion(ProfilesCompanion data) {
    return RawProfile(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      currentGroupName: data.currentGroupName.present
          ? data.currentGroupName.value
          : this.currentGroupName,
      url: data.url.present ? data.url.value : this.url,
      ageSecretKey: data.ageSecretKey.present
          ? data.ageSecretKey.value
          : this.ageSecretKey,
      lastUpdateDate: data.lastUpdateDate.present
          ? data.lastUpdateDate.value
          : this.lastUpdateDate,
      extendType: data.extendType.present
          ? data.extendType.value
          : this.extendType,
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      matchTarget: data.matchTarget.present
          ? data.matchTarget.value
          : this.matchTarget,
      autoUpdateDurationMillis: data.autoUpdateDurationMillis.present
          ? data.autoUpdateDurationMillis.value
          : this.autoUpdateDurationMillis,
      subscriptionInfo: data.subscriptionInfo.present
          ? data.subscriptionInfo.value
          : this.subscriptionInfo,
      autoUpdate: data.autoUpdate.present
          ? data.autoUpdate.value
          : this.autoUpdate,
      selectedMap: data.selectedMap.present
          ? data.selectedMap.value
          : this.selectedMap,
      unfoldSet: data.unfoldSet.present ? data.unfoldSet.value : this.unfoldSet,
      order: data.order.present ? data.order.value : this.order,
      overrides: data.overrides.present ? data.overrides.value : this.overrides,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfile(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('ageSecretKey: $ageSecretKey, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('extendType: $extendType, ')
          ..write('scriptId: $scriptId, ')
          ..write('matchTarget: $matchTarget, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order, ')
          ..write('overrides: $overrides')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    label,
    currentGroupName,
    url,
    ageSecretKey,
    lastUpdateDate,
    extendType,
    scriptId,
    matchTarget,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
    overrides,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfile &&
          other.id == this.id &&
          other.type == this.type &&
          other.label == this.label &&
          other.currentGroupName == this.currentGroupName &&
          other.url == this.url &&
          other.ageSecretKey == this.ageSecretKey &&
          other.lastUpdateDate == this.lastUpdateDate &&
          other.extendType == this.extendType &&
          other.scriptId == this.scriptId &&
          other.matchTarget == this.matchTarget &&
          other.autoUpdateDurationMillis == this.autoUpdateDurationMillis &&
          other.subscriptionInfo == this.subscriptionInfo &&
          other.autoUpdate == this.autoUpdate &&
          other.selectedMap == this.selectedMap &&
          other.unfoldSet == this.unfoldSet &&
          other.order == this.order &&
          other.overrides == this.overrides);
}

class ProfilesCompanion extends UpdateCompanion<RawProfile> {
  final Value<int> id;
  final Value<ProfileType> type;
  final Value<String> label;
  final Value<String?> currentGroupName;
  final Value<String> url;
  final Value<String?> ageSecretKey;
  final Value<DateTime?> lastUpdateDate;
  final Value<ExtendType> extendType;
  final Value<int?> scriptId;
  final Value<String?> matchTarget;
  final Value<int> autoUpdateDurationMillis;
  final Value<SubscriptionInfo?> subscriptionInfo;
  final Value<bool> autoUpdate;
  final Value<Map<String, String>> selectedMap;
  final Value<Set<String>> unfoldSet;
  final Value<int?> order;
  final Value<ProfileOverrides?> overrides;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.currentGroupName = const Value.absent(),
    this.url = const Value.absent(),
    this.ageSecretKey = const Value.absent(),
    this.lastUpdateDate = const Value.absent(),
    this.extendType = const Value.absent(),
    this.scriptId = const Value.absent(),
    this.matchTarget = const Value.absent(),
    this.autoUpdateDurationMillis = const Value.absent(),
    this.subscriptionInfo = const Value.absent(),
    this.autoUpdate = const Value.absent(),
    this.selectedMap = const Value.absent(),
    this.unfoldSet = const Value.absent(),
    this.order = const Value.absent(),
    this.overrides = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required ProfileType type,
    required String label,
    this.currentGroupName = const Value.absent(),
    required String url,
    this.ageSecretKey = const Value.absent(),
    this.lastUpdateDate = const Value.absent(),
    required ExtendType extendType,
    this.scriptId = const Value.absent(),
    this.matchTarget = const Value.absent(),
    required int autoUpdateDurationMillis,
    this.subscriptionInfo = const Value.absent(),
    required bool autoUpdate,
    required Map<String, String> selectedMap,
    required Set<String> unfoldSet,
    this.order = const Value.absent(),
    this.overrides = const Value.absent(),
  }) : type = Value(type),
       label = Value(label),
       url = Value(url),
       extendType = Value(extendType),
       autoUpdateDurationMillis = Value(autoUpdateDurationMillis),
       autoUpdate = Value(autoUpdate),
       selectedMap = Value(selectedMap),
       unfoldSet = Value(unfoldSet);
  static Insertable<RawProfile> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? label,
    Expression<String>? currentGroupName,
    Expression<String>? url,
    Expression<String>? ageSecretKey,
    Expression<DateTime>? lastUpdateDate,
    Expression<String>? extendType,
    Expression<int>? scriptId,
    Expression<String>? matchTarget,
    Expression<int>? autoUpdateDurationMillis,
    Expression<String>? subscriptionInfo,
    Expression<bool>? autoUpdate,
    Expression<String>? selectedMap,
    Expression<String>? unfoldSet,
    Expression<int>? order,
    Expression<String>? overrides,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (currentGroupName != null) 'current_group_name': currentGroupName,
      if (url != null) 'url': url,
      if (ageSecretKey != null) 'age_secret_key': ageSecretKey,
      if (lastUpdateDate != null) 'last_update_date': lastUpdateDate,
      if (extendType != null) 'extend_type': extendType,
      if (scriptId != null) 'script_id': scriptId,
      if (matchTarget != null) 'match_target': matchTarget,
      if (autoUpdateDurationMillis != null)
        'auto_update_duration_millis': autoUpdateDurationMillis,
      if (subscriptionInfo != null) 'subscription_info': subscriptionInfo,
      if (autoUpdate != null) 'auto_update': autoUpdate,
      if (selectedMap != null) 'selected_map': selectedMap,
      if (unfoldSet != null) 'unfold_set': unfoldSet,
      if (order != null) 'order': order,
      if (overrides != null) 'overrides': overrides,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<ProfileType>? type,
    Value<String>? label,
    Value<String?>? currentGroupName,
    Value<String>? url,
    Value<String?>? ageSecretKey,
    Value<DateTime?>? lastUpdateDate,
    Value<ExtendType>? extendType,
    Value<int?>? scriptId,
    Value<String?>? matchTarget,
    Value<int>? autoUpdateDurationMillis,
    Value<SubscriptionInfo?>? subscriptionInfo,
    Value<bool>? autoUpdate,
    Value<Map<String, String>>? selectedMap,
    Value<Set<String>>? unfoldSet,
    Value<int?>? order,
    Value<ProfileOverrides?>? overrides,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      url: url ?? this.url,
      ageSecretKey: ageSecretKey ?? this.ageSecretKey,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      extendType: extendType ?? this.extendType,
      scriptId: scriptId ?? this.scriptId,
      matchTarget: matchTarget ?? this.matchTarget,
      autoUpdateDurationMillis:
          autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      selectedMap: selectedMap ?? this.selectedMap,
      unfoldSet: unfoldSet ?? this.unfoldSet,
      order: order ?? this.order,
      overrides: overrides ?? this.overrides,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ProfilesTable.$convertertype.toSql(type.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (currentGroupName.present) {
      map['current_group_name'] = Variable<String>(currentGroupName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (ageSecretKey.present) {
      map['age_secret_key'] = Variable<String>(ageSecretKey.value);
    }
    if (lastUpdateDate.present) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate.value);
    }
    if (extendType.present) {
      map['extend_type'] = Variable<String>(
        $ProfilesTable.$converterextendType.toSql(extendType.value),
      );
    }
    if (scriptId.present) {
      map['script_id'] = Variable<int>(scriptId.value);
    }
    if (matchTarget.present) {
      map['match_target'] = Variable<String>(matchTarget.value);
    }
    if (autoUpdateDurationMillis.present) {
      map['auto_update_duration_millis'] = Variable<int>(
        autoUpdateDurationMillis.value,
      );
    }
    if (subscriptionInfo.present) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo.value),
      );
    }
    if (autoUpdate.present) {
      map['auto_update'] = Variable<bool>(autoUpdate.value);
    }
    if (selectedMap.present) {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap.value),
      );
    }
    if (unfoldSet.present) {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (overrides.present) {
      map['overrides'] = Variable<String>(
        $ProfilesTable.$converteroverrides.toSql(overrides.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('ageSecretKey: $ageSecretKey, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('extendType: $extendType, ')
          ..write('scriptId: $scriptId, ')
          ..write('matchTarget: $matchTarget, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order, ')
          ..write('overrides: $overrides')
          ..write(')'))
        .toString();
  }
}

class $ScriptsTable extends Scripts with TableInfo<$ScriptsTable, RawScript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateTimeMeta = const VerificationMeta(
    'lastUpdateTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateTime =
      GeneratedColumn<DateTime>(
        'last_update_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, lastUpdateTime, url, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawScript> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
        _lastUpdateTimeMeta,
        lastUpdateTime.isAcceptableOrUnknown(
          data['last_update_time']!,
          _lastUpdateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdateTimeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawScript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawScript(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      lastUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_time'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ScriptsTable createAlias(String alias) {
    return $ScriptsTable(attachedDatabase, alias);
  }
}

class RawScript extends DataClass implements Insertable<RawScript> {
  final int id;
  final String label;
  final DateTime lastUpdateTime;
  final String? url;
  final int? order;
  const RawScript({
    required this.id,
    required this.label,
    required this.lastUpdateTime,
    this.url,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['last_update_time'] = Variable<DateTime>(lastUpdateTime);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    return map;
  }

  ScriptsCompanion toCompanion(bool nullToAbsent) {
    return ScriptsCompanion(
      id: Value(id),
      label: Value(label),
      lastUpdateTime: Value(lastUpdateTime),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawScript.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawScript(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      lastUpdateTime: serializer.fromJson<DateTime>(json['lastUpdateTime']),
      url: serializer.fromJson<String?>(json['url']),
      order: serializer.fromJson<int?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'lastUpdateTime': serializer.toJson<DateTime>(lastUpdateTime),
      'url': serializer.toJson<String?>(url),
      'order': serializer.toJson<int?>(order),
    };
  }

  RawScript copyWith({
    int? id,
    String? label,
    DateTime? lastUpdateTime,
    Value<String?> url = const Value.absent(),
    Value<int?> order = const Value.absent(),
  }) => RawScript(
    id: id ?? this.id,
    label: label ?? this.label,
    lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    url: url.present ? url.value : this.url,
    order: order.present ? order.value : this.order,
  );
  RawScript copyWithCompanion(ScriptsCompanion data) {
    return RawScript(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
      url: data.url.present ? data.url.value : this.url,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawScript(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('url: $url, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, lastUpdateTime, url, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawScript &&
          other.id == this.id &&
          other.label == this.label &&
          other.lastUpdateTime == this.lastUpdateTime &&
          other.url == this.url &&
          other.order == this.order);
}

class ScriptsCompanion extends UpdateCompanion<RawScript> {
  final Value<int> id;
  final Value<String> label;
  final Value<DateTime> lastUpdateTime;
  final Value<String?> url;
  final Value<int?> order;
  const ScriptsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.url = const Value.absent(),
    this.order = const Value.absent(),
  });
  ScriptsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required DateTime lastUpdateTime,
    this.url = const Value.absent(),
    this.order = const Value.absent(),
  }) : label = Value(label),
       lastUpdateTime = Value(lastUpdateTime);
  static Insertable<RawScript> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<DateTime>? lastUpdateTime,
    Expression<String>? url,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
      if (url != null) 'url': url,
      if (order != null) 'order': order,
    });
  }

  ScriptsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<DateTime>? lastUpdateTime,
    Value<String?>? url,
    Value<int?>? order,
  }) {
    return ScriptsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      url: url ?? this.url,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<DateTime>(lastUpdateTime.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScriptsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('url: $url, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RawRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleAction, String> ruleAction =
      GeneratedColumn<String>(
        'rule_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RuleAction>($RulesTable.$converterruleAction);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleTargetMeta = const VerificationMeta(
    'ruleTarget',
  );
  @override
  late final GeneratedColumn<String> ruleTarget = GeneratedColumn<String>(
    'rule_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleProviderMeta = const VerificationMeta(
    'ruleProvider',
  );
  @override
  late final GeneratedColumn<String> ruleProvider = GeneratedColumn<String>(
    'rule_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subRuleMeta = const VerificationMeta(
    'subRule',
  );
  @override
  late final GeneratedColumn<String> subRule = GeneratedColumn<String>(
    'sub_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noResolveMeta = const VerificationMeta(
    'noResolve',
  );
  @override
  late final GeneratedColumn<bool> noResolve = GeneratedColumn<bool>(
    'no_resolve',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_resolve" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<bool> src = GeneratedColumn<bool>(
    'src',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("src" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    ruleAction,
    content,
    ruleTarget,
    ruleProvider,
    subRule,
    noResolve,
    src,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('rule_target')) {
      context.handle(
        _ruleTargetMeta,
        ruleTarget.isAcceptableOrUnknown(data['rule_target']!, _ruleTargetMeta),
      );
    }
    if (data.containsKey('rule_provider')) {
      context.handle(
        _ruleProviderMeta,
        ruleProvider.isAcceptableOrUnknown(
          data['rule_provider']!,
          _ruleProviderMeta,
        ),
      );
    }
    if (data.containsKey('sub_rule')) {
      context.handle(
        _subRuleMeta,
        subRule.isAcceptableOrUnknown(data['sub_rule']!, _subRuleMeta),
      );
    }
    if (data.containsKey('no_resolve')) {
      context.handle(
        _noResolveMeta,
        noResolve.isAcceptableOrUnknown(data['no_resolve']!, _noResolveMeta),
      );
    }
    if (data.containsKey('src')) {
      context.handle(
        _srcMeta,
        src.isAcceptableOrUnknown(data['src']!, _srcMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      ruleAction: $RulesTable.$converterruleAction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rule_action'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      ruleTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_target'],
      ),
      ruleProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_provider'],
      ),
      subRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_rule'],
      ),
      noResolve: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_resolve'],
      )!,
      src: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}src'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleAction, String, String> $converterruleAction =
      const EnumNameConverter<RuleAction>(RuleAction.values);
}

class RawRule extends DataClass implements Insertable<RawRule> {
  final int id;
  final int? profileId;
  final RuleAction ruleAction;
  final String? content;
  final String? ruleTarget;
  final String? ruleProvider;
  final String? subRule;
  final bool noResolve;
  final bool src;
  final String? order;
  const RawRule({
    required this.id,
    this.profileId,
    required this.ruleAction,
    this.content,
    this.ruleTarget,
    this.ruleProvider,
    this.subRule,
    required this.noResolve,
    required this.src,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    {
      map['rule_action'] = Variable<String>(
        $RulesTable.$converterruleAction.toSql(ruleAction),
      );
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || ruleTarget != null) {
      map['rule_target'] = Variable<String>(ruleTarget);
    }
    if (!nullToAbsent || ruleProvider != null) {
      map['rule_provider'] = Variable<String>(ruleProvider);
    }
    if (!nullToAbsent || subRule != null) {
      map['sub_rule'] = Variable<String>(subRule);
    }
    map['no_resolve'] = Variable<bool>(noResolve);
    map['src'] = Variable<bool>(src);
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      ruleAction: Value(ruleAction),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      ruleTarget: ruleTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleTarget),
      ruleProvider: ruleProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleProvider),
      subRule: subRule == null && nullToAbsent
          ? const Value.absent()
          : Value(subRule),
      noResolve: Value(noResolve),
      src: Value(src),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawRule(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      ruleAction: $RulesTable.$converterruleAction.fromJson(
        serializer.fromJson<String>(json['ruleAction']),
      ),
      content: serializer.fromJson<String?>(json['content']),
      ruleTarget: serializer.fromJson<String?>(json['ruleTarget']),
      ruleProvider: serializer.fromJson<String?>(json['ruleProvider']),
      subRule: serializer.fromJson<String?>(json['subRule']),
      noResolve: serializer.fromJson<bool>(json['noResolve']),
      src: serializer.fromJson<bool>(json['src']),
      order: serializer.fromJson<String?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'ruleAction': serializer.toJson<String>(
        $RulesTable.$converterruleAction.toJson(ruleAction),
      ),
      'content': serializer.toJson<String?>(content),
      'ruleTarget': serializer.toJson<String?>(ruleTarget),
      'ruleProvider': serializer.toJson<String?>(ruleProvider),
      'subRule': serializer.toJson<String?>(subRule),
      'noResolve': serializer.toJson<bool>(noResolve),
      'src': serializer.toJson<bool>(src),
      'order': serializer.toJson<String?>(order),
    };
  }

  RawRule copyWith({
    int? id,
    Value<int?> profileId = const Value.absent(),
    RuleAction? ruleAction,
    Value<String?> content = const Value.absent(),
    Value<String?> ruleTarget = const Value.absent(),
    Value<String?> ruleProvider = const Value.absent(),
    Value<String?> subRule = const Value.absent(),
    bool? noResolve,
    bool? src,
    Value<String?> order = const Value.absent(),
  }) => RawRule(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    ruleAction: ruleAction ?? this.ruleAction,
    content: content.present ? content.value : this.content,
    ruleTarget: ruleTarget.present ? ruleTarget.value : this.ruleTarget,
    ruleProvider: ruleProvider.present ? ruleProvider.value : this.ruleProvider,
    subRule: subRule.present ? subRule.value : this.subRule,
    noResolve: noResolve ?? this.noResolve,
    src: src ?? this.src,
    order: order.present ? order.value : this.order,
  );
  RawRule copyWithCompanion(RulesCompanion data) {
    return RawRule(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ruleAction: data.ruleAction.present
          ? data.ruleAction.value
          : this.ruleAction,
      content: data.content.present ? data.content.value : this.content,
      ruleTarget: data.ruleTarget.present
          ? data.ruleTarget.value
          : this.ruleTarget,
      ruleProvider: data.ruleProvider.present
          ? data.ruleProvider.value
          : this.ruleProvider,
      subRule: data.subRule.present ? data.subRule.value : this.subRule,
      noResolve: data.noResolve.present ? data.noResolve.value : this.noResolve,
      src: data.src.present ? data.src.value : this.src,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawRule(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleAction: $ruleAction, ')
          ..write('content: $content, ')
          ..write('ruleTarget: $ruleTarget, ')
          ..write('ruleProvider: $ruleProvider, ')
          ..write('subRule: $subRule, ')
          ..write('noResolve: $noResolve, ')
          ..write('src: $src, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    ruleAction,
    content,
    ruleTarget,
    ruleProvider,
    subRule,
    noResolve,
    src,
    order,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawRule &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.ruleAction == this.ruleAction &&
          other.content == this.content &&
          other.ruleTarget == this.ruleTarget &&
          other.ruleProvider == this.ruleProvider &&
          other.subRule == this.subRule &&
          other.noResolve == this.noResolve &&
          other.src == this.src &&
          other.order == this.order);
}

class RulesCompanion extends UpdateCompanion<RawRule> {
  final Value<int> id;
  final Value<int?> profileId;
  final Value<RuleAction> ruleAction;
  final Value<String?> content;
  final Value<String?> ruleTarget;
  final Value<String?> ruleProvider;
  final Value<String?> subRule;
  final Value<bool> noResolve;
  final Value<bool> src;
  final Value<String?> order;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.ruleAction = const Value.absent(),
    this.content = const Value.absent(),
    this.ruleTarget = const Value.absent(),
    this.ruleProvider = const Value.absent(),
    this.subRule = const Value.absent(),
    this.noResolve = const Value.absent(),
    this.src = const Value.absent(),
    this.order = const Value.absent(),
  });
  RulesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required RuleAction ruleAction,
    this.content = const Value.absent(),
    this.ruleTarget = const Value.absent(),
    this.ruleProvider = const Value.absent(),
    this.subRule = const Value.absent(),
    this.noResolve = const Value.absent(),
    this.src = const Value.absent(),
    this.order = const Value.absent(),
  }) : ruleAction = Value(ruleAction);
  static Insertable<RawRule> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? ruleAction,
    Expression<String>? content,
    Expression<String>? ruleTarget,
    Expression<String>? ruleProvider,
    Expression<String>? subRule,
    Expression<bool>? noResolve,
    Expression<bool>? src,
    Expression<String>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (ruleAction != null) 'rule_action': ruleAction,
      if (content != null) 'content': content,
      if (ruleTarget != null) 'rule_target': ruleTarget,
      if (ruleProvider != null) 'rule_provider': ruleProvider,
      if (subRule != null) 'sub_rule': subRule,
      if (noResolve != null) 'no_resolve': noResolve,
      if (src != null) 'src': src,
      if (order != null) 'order': order,
    });
  }

  RulesCompanion copyWith({
    Value<int>? id,
    Value<int?>? profileId,
    Value<RuleAction>? ruleAction,
    Value<String?>? content,
    Value<String?>? ruleTarget,
    Value<String?>? ruleProvider,
    Value<String?>? subRule,
    Value<bool>? noResolve,
    Value<bool>? src,
    Value<String?>? order,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ruleAction: ruleAction ?? this.ruleAction,
      content: content ?? this.content,
      ruleTarget: ruleTarget ?? this.ruleTarget,
      ruleProvider: ruleProvider ?? this.ruleProvider,
      subRule: subRule ?? this.subRule,
      noResolve: noResolve ?? this.noResolve,
      src: src ?? this.src,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (ruleAction.present) {
      map['rule_action'] = Variable<String>(
        $RulesTable.$converterruleAction.toSql(ruleAction.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (ruleTarget.present) {
      map['rule_target'] = Variable<String>(ruleTarget.value);
    }
    if (ruleProvider.present) {
      map['rule_provider'] = Variable<String>(ruleProvider.value);
    }
    if (subRule.present) {
      map['sub_rule'] = Variable<String>(subRule.value);
    }
    if (noResolve.present) {
      map['no_resolve'] = Variable<bool>(noResolve.value);
    }
    if (src.present) {
      map['src'] = Variable<bool>(src.value);
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('ruleAction: $ruleAction, ')
          ..write('content: $content, ')
          ..write('ruleTarget: $ruleTarget, ')
          ..write('ruleProvider: $ruleProvider, ')
          ..write('subRule: $subRule, ')
          ..write('noResolve: $noResolve, ')
          ..write('src: $src, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $DisabledRulesTable extends DisabledRules
    with TableInfo<$DisabledRulesTable, RawDisabledRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisabledRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rules (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, ruleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'disabled_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawDisabledRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, ruleId};
  @override
  RawDisabledRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawDisabledRule(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
    );
  }

  @override
  $DisabledRulesTable createAlias(String alias) {
    return $DisabledRulesTable(attachedDatabase, alias);
  }
}

class RawDisabledRule extends DataClass implements Insertable<RawDisabledRule> {
  final int profileId;
  final int ruleId;
  const RawDisabledRule({required this.profileId, required this.ruleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['rule_id'] = Variable<int>(ruleId);
    return map;
  }

  DisabledRulesCompanion toCompanion(bool nullToAbsent) {
    return DisabledRulesCompanion(
      profileId: Value(profileId),
      ruleId: Value(ruleId),
    );
  }

  factory RawDisabledRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawDisabledRule(
      profileId: serializer.fromJson<int>(json['profileId']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'ruleId': serializer.toJson<int>(ruleId),
    };
  }

  RawDisabledRule copyWith({int? profileId, int? ruleId}) => RawDisabledRule(
    profileId: profileId ?? this.profileId,
    ruleId: ruleId ?? this.ruleId,
  );
  RawDisabledRule copyWithCompanion(DisabledRulesCompanion data) {
    return RawDisabledRule(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawDisabledRule(')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, ruleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawDisabledRule &&
          other.profileId == this.profileId &&
          other.ruleId == this.ruleId);
}

class DisabledRulesCompanion extends UpdateCompanion<RawDisabledRule> {
  final Value<int> profileId;
  final Value<int> ruleId;
  final Value<int> rowid;
  const DisabledRulesCompanion({
    this.profileId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DisabledRulesCompanion.insert({
    required int profileId,
    required int ruleId,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       ruleId = Value(ruleId);
  static Insertable<RawDisabledRule> custom({
    Expression<int>? profileId,
    Expression<int>? ruleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (ruleId != null) 'rule_id': ruleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DisabledRulesCompanion copyWith({
    Value<int>? profileId,
    Value<int>? ruleId,
    Value<int>? rowid,
  }) {
    return DisabledRulesCompanion(
      profileId: profileId ?? this.profileId,
      ruleId: ruleId ?? this.ruleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisabledRulesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('ruleId: $ruleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProxyGroupsTable extends ProxyGroups
    with TableInfo<$ProxyGroupsTable, RawProxyGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProxyGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> proxies =
      GeneratedColumn<String>(
        'proxies',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ProxyGroupsTable.$converterproxiesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> use =
      GeneratedColumn<String>(
        'use',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ProxyGroupsTable.$converterusen);
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    type,
    proxies,
    use,
    definition,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proxy_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProxyGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProxyGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProxyGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      proxies: $ProxyGroupsTable.$converterproxiesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}proxies'],
        ),
      ),
      use: $ProxyGroupsTable.$converterusen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}use'],
        ),
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProxyGroupsTable createAlias(String alias) {
    return $ProxyGroupsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterproxies =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterproxiesn =
      NullAwareTypeConverter.wrap($converterproxies);
  static TypeConverter<List<String>, String> $converteruse =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterusen =
      NullAwareTypeConverter.wrap($converteruse);
}

class RawProxyGroup extends DataClass implements Insertable<RawProxyGroup> {
  final int id;
  final int profileId;
  final String name;
  final String type;
  final List<String>? proxies;
  final List<String>? use;
  final String definition;
  final String? order;
  const RawProxyGroup({
    required this.id,
    required this.profileId,
    required this.name,
    required this.type,
    this.proxies,
    this.use,
    required this.definition,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || proxies != null) {
      map['proxies'] = Variable<String>(
        $ProxyGroupsTable.$converterproxiesn.toSql(proxies),
      );
    }
    if (!nullToAbsent || use != null) {
      map['use'] = Variable<String>(
        $ProxyGroupsTable.$converterusen.toSql(use),
      );
    }
    map['definition'] = Variable<String>(definition);
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    return map;
  }

  ProxyGroupsCompanion toCompanion(bool nullToAbsent) {
    return ProxyGroupsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      type: Value(type),
      proxies: proxies == null && nullToAbsent
          ? const Value.absent()
          : Value(proxies),
      use: use == null && nullToAbsent ? const Value.absent() : Value(use),
      definition: Value(definition),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProxyGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProxyGroup(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      proxies: serializer.fromJson<List<String>?>(json['proxies']),
      use: serializer.fromJson<List<String>?>(json['use']),
      definition: serializer.fromJson<String>(json['definition']),
      order: serializer.fromJson<String?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'proxies': serializer.toJson<List<String>?>(proxies),
      'use': serializer.toJson<List<String>?>(use),
      'definition': serializer.toJson<String>(definition),
      'order': serializer.toJson<String?>(order),
    };
  }

  RawProxyGroup copyWith({
    int? id,
    int? profileId,
    String? name,
    String? type,
    Value<List<String>?> proxies = const Value.absent(),
    Value<List<String>?> use = const Value.absent(),
    String? definition,
    Value<String?> order = const Value.absent(),
  }) => RawProxyGroup(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    type: type ?? this.type,
    proxies: proxies.present ? proxies.value : this.proxies,
    use: use.present ? use.value : this.use,
    definition: definition ?? this.definition,
    order: order.present ? order.value : this.order,
  );
  RawProxyGroup copyWithCompanion(ProxyGroupsCompanion data) {
    return RawProxyGroup(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      proxies: data.proxies.present ? data.proxies.value : this.proxies,
      use: data.use.present ? data.use.value : this.use,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProxyGroup(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('proxies: $proxies, ')
          ..write('use: $use, ')
          ..write('definition: $definition, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, name, type, proxies, use, definition, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProxyGroup &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.type == this.type &&
          other.proxies == this.proxies &&
          other.use == this.use &&
          other.definition == this.definition &&
          other.order == this.order);
}

class ProxyGroupsCompanion extends UpdateCompanion<RawProxyGroup> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<String> type;
  final Value<List<String>?> proxies;
  final Value<List<String>?> use;
  final Value<String> definition;
  final Value<String?> order;
  const ProxyGroupsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.proxies = const Value.absent(),
    this.use = const Value.absent(),
    this.definition = const Value.absent(),
    this.order = const Value.absent(),
  });
  ProxyGroupsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    required String type,
    this.proxies = const Value.absent(),
    this.use = const Value.absent(),
    this.definition = const Value.absent(),
    this.order = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       type = Value(type);
  static Insertable<RawProxyGroup> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? proxies,
    Expression<String>? use,
    Expression<String>? definition,
    Expression<String>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (proxies != null) 'proxies': proxies,
      if (use != null) 'use': use,
      if (definition != null) 'definition': definition,
      if (order != null) 'order': order,
    });
  }

  ProxyGroupsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<String>? type,
    Value<List<String>?>? proxies,
    Value<List<String>?>? use,
    Value<String>? definition,
    Value<String?>? order,
  }) {
    return ProxyGroupsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      type: type ?? this.type,
      proxies: proxies ?? this.proxies,
      use: use ?? this.use,
      definition: definition ?? this.definition,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (proxies.present) {
      map['proxies'] = Variable<String>(
        $ProxyGroupsTable.$converterproxiesn.toSql(proxies.value),
      );
    }
    if (use.present) {
      map['use'] = Variable<String>(
        $ProxyGroupsTable.$converterusen.toSql(use.value),
      );
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProxyGroupsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('proxies: $proxies, ')
          ..write('use: $use, ')
          ..write('definition: $definition, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $IconRecordsTable extends IconRecords
    with TableInfo<$IconRecordsTable, IconRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IconRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedMeta = const VerificationMeta(
    'lastAccessed',
  );
  @override
  late final GeneratedColumn<int> lastAccessed = GeneratedColumn<int>(
    'last_accessed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [url, lastAccessed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<IconRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_accessed')) {
      context.handle(
        _lastAccessedMeta,
        lastAccessed.isAcceptableOrUnknown(
          data['last_accessed']!,
          _lastAccessedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  IconRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconRecord(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastAccessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed'],
      )!,
    );
  }

  @override
  $IconRecordsTable createAlias(String alias) {
    return $IconRecordsTable(attachedDatabase, alias);
  }
}

class IconRecord extends DataClass implements Insertable<IconRecord> {
  final String url;
  final int lastAccessed;
  const IconRecord({required this.url, required this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['last_accessed'] = Variable<int>(lastAccessed);
    return map;
  }

  IconRecordsCompanion toCompanion(bool nullToAbsent) {
    return IconRecordsCompanion(
      url: Value(url),
      lastAccessed: Value(lastAccessed),
    );
  }

  factory IconRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconRecord(
      url: serializer.fromJson<String>(json['url']),
      lastAccessed: serializer.fromJson<int>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'lastAccessed': serializer.toJson<int>(lastAccessed),
    };
  }

  IconRecord copyWith({String? url, int? lastAccessed}) => IconRecord(
    url: url ?? this.url,
    lastAccessed: lastAccessed ?? this.lastAccessed,
  );
  IconRecord copyWithCompanion(IconRecordsCompanion data) {
    return IconRecord(
      url: data.url.present ? data.url.value : this.url,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconRecord(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconRecord &&
          other.url == this.url &&
          other.lastAccessed == this.lastAccessed);
}

class IconRecordsCompanion extends UpdateCompanion<IconRecord> {
  final Value<String> url;
  final Value<int> lastAccessed;
  final Value<int> rowid;
  const IconRecordsCompanion({
    this.url = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IconRecordsCompanion.insert({
    required String url,
    required int lastAccessed,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       lastAccessed = Value(lastAccessed);
  static Insertable<IconRecord> custom({
    Expression<String>? url,
    Expression<int>? lastAccessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (lastAccessed != null) 'last_accessed': lastAccessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IconRecordsCompanion copyWith({
    Value<String>? url,
    Value<int>? lastAccessed,
    Value<int>? rowid,
  }) {
    return IconRecordsCompanion(
      url: url ?? this.url,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastAccessed.present) {
      map['last_accessed'] = Variable<int>(lastAccessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconRecordsCompanion(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IconSetsTable extends IconSets
    with TableInfo<$IconSetsTable, RawIconSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IconSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<IconSetIcon>, String> icons =
      GeneratedColumn<String>(
        'icons',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<IconSetIcon>>($IconSetsTable.$convertericons);
  static const VerificationMeta _lastUpdateTimeMeta = const VerificationMeta(
    'lastUpdateTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateTime =
      GeneratedColumn<DateTime>(
        'last_update_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    url,
    icons,
    lastUpdateTime,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawIconSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
        _lastUpdateTimeMeta,
        lastUpdateTime.isAcceptableOrUnknown(
          data['last_update_time']!,
          _lastUpdateTimeMeta,
        ),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawIconSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawIconSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      icons: $IconSetsTable.$convertericons.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}icons'],
        )!,
      ),
      lastUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_time'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $IconSetsTable createAlias(String alias) {
    return $IconSetsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<IconSetIcon>, String> $convertericons =
      const IconSetIconsConverter();
}

class RawIconSet extends DataClass implements Insertable<RawIconSet> {
  final int id;
  final String name;
  final String url;
  final List<IconSetIcon> icons;
  final DateTime? lastUpdateTime;
  final int? order;
  const RawIconSet({
    required this.id,
    required this.name,
    required this.url,
    required this.icons,
    this.lastUpdateTime,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    {
      map['icons'] = Variable<String>(
        $IconSetsTable.$convertericons.toSql(icons),
      );
    }
    if (!nullToAbsent || lastUpdateTime != null) {
      map['last_update_time'] = Variable<DateTime>(lastUpdateTime);
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    return map;
  }

  IconSetsCompanion toCompanion(bool nullToAbsent) {
    return IconSetsCompanion(
      id: Value(id),
      name: Value(name),
      url: Value(url),
      icons: Value(icons),
      lastUpdateTime: lastUpdateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateTime),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawIconSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawIconSet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      icons: serializer.fromJson<List<IconSetIcon>>(json['icons']),
      lastUpdateTime: serializer.fromJson<DateTime?>(json['lastUpdateTime']),
      order: serializer.fromJson<int?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'icons': serializer.toJson<List<IconSetIcon>>(icons),
      'lastUpdateTime': serializer.toJson<DateTime?>(lastUpdateTime),
      'order': serializer.toJson<int?>(order),
    };
  }

  RawIconSet copyWith({
    int? id,
    String? name,
    String? url,
    List<IconSetIcon>? icons,
    Value<DateTime?> lastUpdateTime = const Value.absent(),
    Value<int?> order = const Value.absent(),
  }) => RawIconSet(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    icons: icons ?? this.icons,
    lastUpdateTime: lastUpdateTime.present
        ? lastUpdateTime.value
        : this.lastUpdateTime,
    order: order.present ? order.value : this.order,
  );
  RawIconSet copyWithCompanion(IconSetsCompanion data) {
    return RawIconSet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      icons: data.icons.present ? data.icons.value : this.icons,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawIconSet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('icons: $icons, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, url, icons, lastUpdateTime, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawIconSet &&
          other.id == this.id &&
          other.name == this.name &&
          other.url == this.url &&
          other.icons == this.icons &&
          other.lastUpdateTime == this.lastUpdateTime &&
          other.order == this.order);
}

class IconSetsCompanion extends UpdateCompanion<RawIconSet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> url;
  final Value<List<IconSetIcon>> icons;
  final Value<DateTime?> lastUpdateTime;
  final Value<int?> order;
  const IconSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.icons = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.order = const Value.absent(),
  });
  IconSetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String url,
    required List<IconSetIcon> icons,
    this.lastUpdateTime = const Value.absent(),
    this.order = const Value.absent(),
  }) : name = Value(name),
       url = Value(url),
       icons = Value(icons);
  static Insertable<RawIconSet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? icons,
    Expression<DateTime>? lastUpdateTime,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (icons != null) 'icons': icons,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
      if (order != null) 'order': order,
    });
  }

  IconSetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? url,
    Value<List<IconSetIcon>>? icons,
    Value<DateTime?>? lastUpdateTime,
    Value<int?>? order,
  }) {
    return IconSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      icons: icons ?? this.icons,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (icons.present) {
      map['icons'] = Variable<String>(
        $IconSetsTable.$convertericons.toSql(icons.value),
      );
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<DateTime>(lastUpdateTime.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('icons: $icons, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $ClashProvidersTable extends ClashProviders
    with TableInfo<$ClashProvidersTable, RawClashProvider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClashProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProviderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProviderKind>($ClashProvidersTable.$converterkind);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleProviderBehavior?, String>
  behavior =
      GeneratedColumn<String>(
        'behavior',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RuleProviderBehavior?>(
        $ClashProvidersTable.$converterbehaviorn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<RuleProviderFormat?, String>
  format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<RuleProviderFormat?>($ClashProvidersTable.$converterformatn);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    label,
    url,
    behavior,
    format,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clash_providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawClashProvider> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawClashProvider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawClashProvider(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $ClashProvidersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      behavior: $ClashProvidersTable.$converterbehaviorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}behavior'],
        ),
      ),
      format: $ClashProvidersTable.$converterformatn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}format'],
        ),
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ClashProvidersTable createAlias(String alias) {
    return $ClashProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProviderKind, String, String> $converterkind =
      const EnumNameConverter<ProviderKind>(ProviderKind.values);
  static JsonTypeConverter2<RuleProviderBehavior, String, String>
  $converterbehavior = const EnumNameConverter<RuleProviderBehavior>(
    RuleProviderBehavior.values,
  );
  static JsonTypeConverter2<RuleProviderBehavior?, String?, String?>
  $converterbehaviorn = JsonTypeConverter2.asNullable($converterbehavior);
  static JsonTypeConverter2<RuleProviderFormat, String, String>
  $converterformat = const EnumNameConverter<RuleProviderFormat>(
    RuleProviderFormat.values,
  );
  static JsonTypeConverter2<RuleProviderFormat?, String?, String?>
  $converterformatn = JsonTypeConverter2.asNullable($converterformat);
}

class RawClashProvider extends DataClass
    implements Insertable<RawClashProvider> {
  final int id;
  final ProviderKind kind;
  final String label;
  final String url;
  final RuleProviderBehavior? behavior;
  final RuleProviderFormat? format;
  final int? order;
  const RawClashProvider({
    required this.id,
    required this.kind,
    required this.label,
    required this.url,
    this.behavior,
    this.format,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $ClashProvidersTable.$converterkind.toSql(kind),
      );
    }
    map['label'] = Variable<String>(label);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || behavior != null) {
      map['behavior'] = Variable<String>(
        $ClashProvidersTable.$converterbehaviorn.toSql(behavior),
      );
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(
        $ClashProvidersTable.$converterformatn.toSql(format),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    return map;
  }

  ClashProvidersCompanion toCompanion(bool nullToAbsent) {
    return ClashProvidersCompanion(
      id: Value(id),
      kind: Value(kind),
      label: Value(label),
      url: Value(url),
      behavior: behavior == null && nullToAbsent
          ? const Value.absent()
          : Value(behavior),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawClashProvider.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawClashProvider(
      id: serializer.fromJson<int>(json['id']),
      kind: $ClashProvidersTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      label: serializer.fromJson<String>(json['label']),
      url: serializer.fromJson<String>(json['url']),
      behavior: $ClashProvidersTable.$converterbehaviorn.fromJson(
        serializer.fromJson<String?>(json['behavior']),
      ),
      format: $ClashProvidersTable.$converterformatn.fromJson(
        serializer.fromJson<String?>(json['format']),
      ),
      order: serializer.fromJson<int?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $ClashProvidersTable.$converterkind.toJson(kind),
      ),
      'label': serializer.toJson<String>(label),
      'url': serializer.toJson<String>(url),
      'behavior': serializer.toJson<String?>(
        $ClashProvidersTable.$converterbehaviorn.toJson(behavior),
      ),
      'format': serializer.toJson<String?>(
        $ClashProvidersTable.$converterformatn.toJson(format),
      ),
      'order': serializer.toJson<int?>(order),
    };
  }

  RawClashProvider copyWith({
    int? id,
    ProviderKind? kind,
    String? label,
    String? url,
    Value<RuleProviderBehavior?> behavior = const Value.absent(),
    Value<RuleProviderFormat?> format = const Value.absent(),
    Value<int?> order = const Value.absent(),
  }) => RawClashProvider(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    url: url ?? this.url,
    behavior: behavior.present ? behavior.value : this.behavior,
    format: format.present ? format.value : this.format,
    order: order.present ? order.value : this.order,
  );
  RawClashProvider copyWithCompanion(ClashProvidersCompanion data) {
    return RawClashProvider(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      behavior: data.behavior.present ? data.behavior.value : this.behavior,
      format: data.format.present ? data.format.value : this.format,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawClashProvider(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('behavior: $behavior, ')
          ..write('format: $format, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, label, url, behavior, format, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawClashProvider &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.url == this.url &&
          other.behavior == this.behavior &&
          other.format == this.format &&
          other.order == this.order);
}

class ClashProvidersCompanion extends UpdateCompanion<RawClashProvider> {
  final Value<int> id;
  final Value<ProviderKind> kind;
  final Value<String> label;
  final Value<String> url;
  final Value<RuleProviderBehavior?> behavior;
  final Value<RuleProviderFormat?> format;
  final Value<int?> order;
  const ClashProvidersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.behavior = const Value.absent(),
    this.format = const Value.absent(),
    this.order = const Value.absent(),
  });
  ClashProvidersCompanion.insert({
    this.id = const Value.absent(),
    required ProviderKind kind,
    required String label,
    required String url,
    this.behavior = const Value.absent(),
    this.format = const Value.absent(),
    this.order = const Value.absent(),
  }) : kind = Value(kind),
       label = Value(label),
       url = Value(url);
  static Insertable<RawClashProvider> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<String>? url,
    Expression<String>? behavior,
    Expression<String>? format,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (behavior != null) 'behavior': behavior,
      if (format != null) 'format': format,
      if (order != null) 'order': order,
    });
  }

  ClashProvidersCompanion copyWith({
    Value<int>? id,
    Value<ProviderKind>? kind,
    Value<String>? label,
    Value<String>? url,
    Value<RuleProviderBehavior?>? behavior,
    Value<RuleProviderFormat?>? format,
    Value<int?>? order,
  }) {
    return ClashProvidersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      url: url ?? this.url,
      behavior: behavior ?? this.behavior,
      format: format ?? this.format,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ClashProvidersTable.$converterkind.toSql(kind.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (behavior.present) {
      map['behavior'] = Variable<String>(
        $ClashProvidersTable.$converterbehaviorn.toSql(behavior.value),
      );
    }
    if (format.present) {
      map['format'] = Variable<String>(
        $ClashProvidersTable.$converterformatn.toSql(format.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClashProvidersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('behavior: $behavior, ')
          ..write('format: $format, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $CustomProxiesTable extends CustomProxies
    with TableInfo<$CustomProxiesTable, RawCustomProxy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomProxiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  definition =
      GeneratedColumn<String>(
        'definition',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $CustomProxiesTable.$converterdefinition,
      );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<String> order = GeneratedColumn<String>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>?, String>
  emptyOptions = GeneratedColumn<String>(
    'empty_options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Set<String>?>($CustomProxiesTable.$converteremptyOptionsn);
  @override
  List<GeneratedColumn> get $columns => [id, definition, order, emptyOptions];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_proxies';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawCustomProxy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawCustomProxy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawCustomProxy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      definition: $CustomProxiesTable.$converterdefinition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}definition'],
        )!,
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order'],
      ),
      emptyOptions: $CustomProxiesTable.$converteremptyOptionsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}empty_options'],
        ),
      ),
    );
  }

  @override
  $CustomProxiesTable createAlias(String alias) {
    return $CustomProxiesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterdefinition =
      const JsonMapConverter();
  static TypeConverter<Set<String>, String> $converteremptyOptions =
      const StringSetConverter();
  static TypeConverter<Set<String>?, String?> $converteremptyOptionsn =
      NullAwareTypeConverter.wrap($converteremptyOptions);
}

class RawCustomProxy extends DataClass implements Insertable<RawCustomProxy> {
  final int id;
  final Map<String, dynamic> definition;
  final String? order;
  final Set<String>? emptyOptions;
  const RawCustomProxy({
    required this.id,
    required this.definition,
    this.order,
    this.emptyOptions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['definition'] = Variable<String>(
        $CustomProxiesTable.$converterdefinition.toSql(definition),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<String>(order);
    }
    if (!nullToAbsent || emptyOptions != null) {
      map['empty_options'] = Variable<String>(
        $CustomProxiesTable.$converteremptyOptionsn.toSql(emptyOptions),
      );
    }
    return map;
  }

  CustomProxiesCompanion toCompanion(bool nullToAbsent) {
    return CustomProxiesCompanion(
      id: Value(id),
      definition: Value(definition),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
      emptyOptions: emptyOptions == null && nullToAbsent
          ? const Value.absent()
          : Value(emptyOptions),
    );
  }

  factory RawCustomProxy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawCustomProxy(
      id: serializer.fromJson<int>(json['id']),
      definition: serializer.fromJson<Map<String, dynamic>>(json['definition']),
      order: serializer.fromJson<String?>(json['order']),
      emptyOptions: serializer.fromJson<Set<String>?>(json['emptyOptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'definition': serializer.toJson<Map<String, dynamic>>(definition),
      'order': serializer.toJson<String?>(order),
      'emptyOptions': serializer.toJson<Set<String>?>(emptyOptions),
    };
  }

  RawCustomProxy copyWith({
    int? id,
    Map<String, dynamic>? definition,
    Value<String?> order = const Value.absent(),
    Value<Set<String>?> emptyOptions = const Value.absent(),
  }) => RawCustomProxy(
    id: id ?? this.id,
    definition: definition ?? this.definition,
    order: order.present ? order.value : this.order,
    emptyOptions: emptyOptions.present ? emptyOptions.value : this.emptyOptions,
  );
  RawCustomProxy copyWithCompanion(CustomProxiesCompanion data) {
    return RawCustomProxy(
      id: data.id.present ? data.id.value : this.id,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      order: data.order.present ? data.order.value : this.order,
      emptyOptions: data.emptyOptions.present
          ? data.emptyOptions.value
          : this.emptyOptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawCustomProxy(')
          ..write('id: $id, ')
          ..write('definition: $definition, ')
          ..write('order: $order, ')
          ..write('emptyOptions: $emptyOptions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, definition, order, emptyOptions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawCustomProxy &&
          other.id == this.id &&
          other.definition == this.definition &&
          other.order == this.order &&
          other.emptyOptions == this.emptyOptions);
}

class CustomProxiesCompanion extends UpdateCompanion<RawCustomProxy> {
  final Value<int> id;
  final Value<Map<String, dynamic>> definition;
  final Value<String?> order;
  final Value<Set<String>?> emptyOptions;
  const CustomProxiesCompanion({
    this.id = const Value.absent(),
    this.definition = const Value.absent(),
    this.order = const Value.absent(),
    this.emptyOptions = const Value.absent(),
  });
  CustomProxiesCompanion.insert({
    this.id = const Value.absent(),
    required Map<String, dynamic> definition,
    this.order = const Value.absent(),
    this.emptyOptions = const Value.absent(),
  }) : definition = Value(definition);
  static Insertable<RawCustomProxy> custom({
    Expression<int>? id,
    Expression<String>? definition,
    Expression<String>? order,
    Expression<String>? emptyOptions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definition != null) 'definition': definition,
      if (order != null) 'order': order,
      if (emptyOptions != null) 'empty_options': emptyOptions,
    });
  }

  CustomProxiesCompanion copyWith({
    Value<int>? id,
    Value<Map<String, dynamic>>? definition,
    Value<String?>? order,
    Value<Set<String>?>? emptyOptions,
  }) {
    return CustomProxiesCompanion(
      id: id ?? this.id,
      definition: definition ?? this.definition,
      order: order ?? this.order,
      emptyOptions: emptyOptions ?? this.emptyOptions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(
        $CustomProxiesTable.$converterdefinition.toSql(definition.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<String>(order.value);
    }
    if (emptyOptions.present) {
      map['empty_options'] = Variable<String>(
        $CustomProxiesTable.$converteremptyOptionsn.toSql(emptyOptions.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomProxiesCompanion(')
          ..write('id: $id, ')
          ..write('definition: $definition, ')
          ..write('order: $order, ')
          ..write('emptyOptions: $emptyOptions')
          ..write(')'))
        .toString();
  }
}

class $ProxyDialersTable extends ProxyDialers
    with TableInfo<$ProxyDialersTable, RawProxyDialer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProxyDialersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _proxyIdMeta = const VerificationMeta(
    'proxyId',
  );
  @override
  late final GeneratedColumn<int> proxyId = GeneratedColumn<int>(
    'proxy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_proxies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, proxyId, target];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proxy_dialers';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProxyDialer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('proxy_id')) {
      context.handle(
        _proxyIdMeta,
        proxyId.isAcceptableOrUnknown(data['proxy_id']!, _proxyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_proxyIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, proxyId};
  @override
  RawProxyDialer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProxyDialer(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      proxyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proxy_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
    );
  }

  @override
  $ProxyDialersTable createAlias(String alias) {
    return $ProxyDialersTable(attachedDatabase, alias);
  }
}

class RawProxyDialer extends DataClass implements Insertable<RawProxyDialer> {
  final int profileId;
  final int proxyId;
  final String target;
  const RawProxyDialer({
    required this.profileId,
    required this.proxyId,
    required this.target,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['proxy_id'] = Variable<int>(proxyId);
    map['target'] = Variable<String>(target);
    return map;
  }

  ProxyDialersCompanion toCompanion(bool nullToAbsent) {
    return ProxyDialersCompanion(
      profileId: Value(profileId),
      proxyId: Value(proxyId),
      target: Value(target),
    );
  }

  factory RawProxyDialer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProxyDialer(
      profileId: serializer.fromJson<int>(json['profileId']),
      proxyId: serializer.fromJson<int>(json['proxyId']),
      target: serializer.fromJson<String>(json['target']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'proxyId': serializer.toJson<int>(proxyId),
      'target': serializer.toJson<String>(target),
    };
  }

  RawProxyDialer copyWith({int? profileId, int? proxyId, String? target}) =>
      RawProxyDialer(
        profileId: profileId ?? this.profileId,
        proxyId: proxyId ?? this.proxyId,
        target: target ?? this.target,
      );
  RawProxyDialer copyWithCompanion(ProxyDialersCompanion data) {
    return RawProxyDialer(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      proxyId: data.proxyId.present ? data.proxyId.value : this.proxyId,
      target: data.target.present ? data.target.value : this.target,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProxyDialer(')
          ..write('profileId: $profileId, ')
          ..write('proxyId: $proxyId, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, proxyId, target);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProxyDialer &&
          other.profileId == this.profileId &&
          other.proxyId == this.proxyId &&
          other.target == this.target);
}

class ProxyDialersCompanion extends UpdateCompanion<RawProxyDialer> {
  final Value<int> profileId;
  final Value<int> proxyId;
  final Value<String> target;
  final Value<int> rowid;
  const ProxyDialersCompanion({
    this.profileId = const Value.absent(),
    this.proxyId = const Value.absent(),
    this.target = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProxyDialersCompanion.insert({
    required int profileId,
    required int proxyId,
    required String target,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       proxyId = Value(proxyId),
       target = Value(target);
  static Insertable<RawProxyDialer> custom({
    Expression<int>? profileId,
    Expression<int>? proxyId,
    Expression<String>? target,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (proxyId != null) 'proxy_id': proxyId,
      if (target != null) 'target': target,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProxyDialersCompanion copyWith({
    Value<int>? profileId,
    Value<int>? proxyId,
    Value<String>? target,
    Value<int>? rowid,
  }) {
    return ProxyDialersCompanion(
      profileId: profileId ?? this.profileId,
      proxyId: proxyId ?? this.proxyId,
      target: target ?? this.target,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (proxyId.present) {
      map['proxy_id'] = Variable<int>(proxyId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProxyDialersCompanion(')
          ..write('profileId: $profileId, ')
          ..write('proxyId: $proxyId, ')
          ..write('target: $target, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IpQualitiesTable extends IpQualities
    with TableInfo<$IpQualitiesTable, IpQualityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IpQualitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
    'ip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IpQuality, String> quality =
      GeneratedColumn<String>(
        'quality',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IpQuality>($IpQualitiesTable.$converterquality);
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ip, quality, checkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ip_qualities';
  @override
  VerificationContext validateIntegrity(
    Insertable<IpQualityRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ip};
  @override
  IpQualityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IpQualityRecord(
      ip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip'],
      )!,
      quality: $IpQualitiesTable.$converterquality.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quality'],
        )!,
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      )!,
    );
  }

  @override
  $IpQualitiesTable createAlias(String alias) {
    return $IpQualitiesTable(attachedDatabase, alias);
  }

  static TypeConverter<IpQuality, String> $converterquality =
      const IpQualityConverter();
}

class IpQualityRecord extends DataClass implements Insertable<IpQualityRecord> {
  final String ip;
  final IpQuality quality;
  final DateTime checkedAt;
  const IpQualityRecord({
    required this.ip,
    required this.quality,
    required this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ip'] = Variable<String>(ip);
    {
      map['quality'] = Variable<String>(
        $IpQualitiesTable.$converterquality.toSql(quality),
      );
    }
    map['checked_at'] = Variable<DateTime>(checkedAt);
    return map;
  }

  IpQualitiesCompanion toCompanion(bool nullToAbsent) {
    return IpQualitiesCompanion(
      ip: Value(ip),
      quality: Value(quality),
      checkedAt: Value(checkedAt),
    );
  }

  factory IpQualityRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IpQualityRecord(
      ip: serializer.fromJson<String>(json['ip']),
      quality: serializer.fromJson<IpQuality>(json['quality']),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ip': serializer.toJson<String>(ip),
      'quality': serializer.toJson<IpQuality>(quality),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
    };
  }

  IpQualityRecord copyWith({
    String? ip,
    IpQuality? quality,
    DateTime? checkedAt,
  }) => IpQualityRecord(
    ip: ip ?? this.ip,
    quality: quality ?? this.quality,
    checkedAt: checkedAt ?? this.checkedAt,
  );
  IpQualityRecord copyWithCompanion(IpQualitiesCompanion data) {
    return IpQualityRecord(
      ip: data.ip.present ? data.ip.value : this.ip,
      quality: data.quality.present ? data.quality.value : this.quality,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IpQualityRecord(')
          ..write('ip: $ip, ')
          ..write('quality: $quality, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ip, quality, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IpQualityRecord &&
          other.ip == this.ip &&
          other.quality == this.quality &&
          other.checkedAt == this.checkedAt);
}

class IpQualitiesCompanion extends UpdateCompanion<IpQualityRecord> {
  final Value<String> ip;
  final Value<IpQuality> quality;
  final Value<DateTime> checkedAt;
  final Value<int> rowid;
  const IpQualitiesCompanion({
    this.ip = const Value.absent(),
    this.quality = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IpQualitiesCompanion.insert({
    required String ip,
    required IpQuality quality,
    required DateTime checkedAt,
    this.rowid = const Value.absent(),
  }) : ip = Value(ip),
       quality = Value(quality),
       checkedAt = Value(checkedAt);
  static Insertable<IpQualityRecord> custom({
    Expression<String>? ip,
    Expression<String>? quality,
    Expression<DateTime>? checkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ip != null) 'ip': ip,
      if (quality != null) 'quality': quality,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IpQualitiesCompanion copyWith({
    Value<String>? ip,
    Value<IpQuality>? quality,
    Value<DateTime>? checkedAt,
    Value<int>? rowid,
  }) {
    return IpQualitiesCompanion(
      ip: ip ?? this.ip,
      quality: quality ?? this.quality,
      checkedAt: checkedAt ?? this.checkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(
        $IpQualitiesTable.$converterquality.toSql(quality.value),
      );
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IpQualitiesCompanion(')
          ..write('ip: $ip, ')
          ..write('quality: $quality, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ScriptsTable scripts = $ScriptsTable(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $DisabledRulesTable disabledRules = $DisabledRulesTable(this);
  late final $ProxyGroupsTable proxyGroups = $ProxyGroupsTable(this);
  late final $IconRecordsTable iconRecords = $IconRecordsTable(this);
  late final $IconSetsTable iconSets = $IconSetsTable(this);
  late final $ClashProvidersTable clashProviders = $ClashProvidersTable(this);
  late final $CustomProxiesTable customProxies = $CustomProxiesTable(this);
  late final $ProxyDialersTable proxyDialers = $ProxyDialersTable(this);
  late final $IpQualitiesTable ipQualities = $IpQualitiesTable(this);
  late final Index idxRuleTarget = Index(
    'idx_rule_target',
    'CREATE INDEX idx_rule_target ON rules (rule_target)',
  );
  late final Index idxRulesProfileOrder = Index(
    'idx_rules_profile_order',
    'CREATE INDEX idx_rules_profile_order ON rules (profile_id, "order")',
  );
  late final Index idxProxyGroupsProfileOrder = Index(
    'idx_proxy_groups_profile_order',
    'CREATE INDEX idx_proxy_groups_profile_order ON proxy_groups (profile_id, "order")',
  );
  late final Index lastAccessedUrl = Index(
    'last_accessed_url',
    'CREATE INDEX last_accessed_url ON icon_records (last_accessed, url)',
  );
  late final ProfilesDao profilesDao = ProfilesDao(this as Database);
  late final ScriptsDao scriptsDao = ScriptsDao(this as Database);
  late final RulesDao rulesDao = RulesDao(this as Database);
  late final ProxyGroupsDao proxyGroupsDao = ProxyGroupsDao(this as Database);
  late final IconRecordsDao iconRecordsDao = IconRecordsDao(this as Database);
  late final IconSetsDao iconSetsDao = IconSetsDao(this as Database);
  late final ClashProvidersDao clashProvidersDao = ClashProvidersDao(
    this as Database,
  );
  late final CustomProxiesDao customProxiesDao = CustomProxiesDao(
    this as Database,
  );
  late final ProxyDialersDao proxyDialersDao = ProxyDialersDao(
    this as Database,
  );
  late final IpQualitiesDao ipQualitiesDao = IpQualitiesDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    scripts,
    rules,
    disabledRules,
    proxyGroups,
    iconRecords,
    iconSets,
    clashProviders,
    customProxies,
    proxyDialers,
    ipQualities,
    idxRuleTarget,
    idxRulesProfileOrder,
    idxProxyGroupsProfileOrder,
    lastAccessedUrl,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('disabled_rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('disabled_rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('proxy_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('proxy_dialers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_proxies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('proxy_dialers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required ProfileType type,
      required String label,
      Value<String?> currentGroupName,
      required String url,
      Value<String?> ageSecretKey,
      Value<DateTime?> lastUpdateDate,
      required ExtendType extendType,
      Value<int?> scriptId,
      Value<String?> matchTarget,
      required int autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      required bool autoUpdate,
      required Map<String, String> selectedMap,
      required Set<String> unfoldSet,
      Value<int?> order,
      Value<ProfileOverrides?> overrides,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<ProfileType> type,
      Value<String> label,
      Value<String?> currentGroupName,
      Value<String> url,
      Value<String?> ageSecretKey,
      Value<DateTime?> lastUpdateDate,
      Value<ExtendType> extendType,
      Value<int?> scriptId,
      Value<String?> matchTarget,
      Value<int> autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      Value<bool> autoUpdate,
      Value<Map<String, String>> selectedMap,
      Value<Set<String>> unfoldSet,
      Value<int?> order,
      Value<ProfileOverrides?> overrides,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$Database, $ProfilesTable, RawProfile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RulesTable, List<RawRule>> _rulesRefsTable(
    _$Database db,
  ) => MultiTypedResultKey.fromTable(
    db.rules,
    aliasName: 'profiles__id__rules__profile_id',
  );

  $$RulesTableProcessedTableManager get rulesRefs {
    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DisabledRulesTable, List<RawDisabledRule>>
  _disabledRulesRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.disabledRules,
    aliasName: 'profiles__id__disabled_rules__profile_id',
  );

  $$DisabledRulesTableProcessedTableManager get disabledRulesRefs {
    final manager = $$DisabledRulesTableTableManager(
      $_db,
      $_db.disabledRules,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_disabledRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProxyGroupsTable, List<RawProxyGroup>>
  _proxyGroupsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.proxyGroups,
    aliasName: 'profiles__id__proxy_groups__profile_id',
  );

  $$ProxyGroupsTableProcessedTableManager get proxyGroupsRefs {
    final manager = $$ProxyGroupsTableTableManager(
      $_db,
      $_db.proxyGroups,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_proxyGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProxyDialersTable, List<RawProxyDialer>>
  _proxyDialersRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.proxyDialers,
    aliasName: 'profiles__id__proxy_dialers__profile_id',
  );

  $$ProxyDialersTableProcessedTableManager get proxyDialersRefs {
    final manager = $$ProxyDialersTableTableManager(
      $_db,
      $_db.proxyDialers,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_proxyDialersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProfileType, ProfileType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageSecretKey => $composableBuilder(
    column: $table.ageSecretKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExtendType, ExtendType, String>
  get extendType => $composableBuilder(
    column: $table.extendType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchTarget => $composableBuilder(
    column: $table.matchTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubscriptionInfo?, SubscriptionInfo, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<String>, Set<String>, String>
  get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProfileOverrides?, ProfileOverrides, String>
  get overrides => $composableBuilder(
    column: $table.overrides,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> rulesRefs(
    Expression<bool> Function($$RulesTableFilterComposer f) f,
  ) {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> disabledRulesRefs(
    Expression<bool> Function($$DisabledRulesTableFilterComposer f) f,
  ) {
    final $$DisabledRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disabledRules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisabledRulesTableFilterComposer(
            $db: $db,
            $table: $db.disabledRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> proxyGroupsRefs(
    Expression<bool> Function($$ProxyGroupsTableFilterComposer f) f,
  ) {
    final $$ProxyGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyGroups,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyGroupsTableFilterComposer(
            $db: $db,
            $table: $db.proxyGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> proxyDialersRefs(
    Expression<bool> Function($$ProxyDialersTableFilterComposer f) f,
  ) {
    final $$ProxyDialersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyDialers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyDialersTableFilterComposer(
            $db: $db,
            $table: $db.proxyDialers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageSecretKey => $composableBuilder(
    column: $table.ageSecretKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extendType => $composableBuilder(
    column: $table.extendType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchTarget => $composableBuilder(
    column: $table.matchTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrides => $composableBuilder(
    column: $table.overrides,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProfileType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get ageSecretKey => $composableBuilder(
    column: $table.ageSecretKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ExtendType, String> get extendType =>
      $composableBuilder(
        column: $table.extendType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get scriptId =>
      $composableBuilder(column: $table.scriptId, builder: (column) => column);

  GeneratedColumn<String> get matchTarget => $composableBuilder(
    column: $table.matchTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<String>, String> get unfoldSet =>
      $composableBuilder(column: $table.unfoldSet, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProfileOverrides?, String> get overrides =>
      $composableBuilder(column: $table.overrides, builder: (column) => column);

  Expression<T> rulesRefs<T extends Object>(
    Expression<T> Function($$RulesTableAnnotationComposer a) f,
  ) {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> disabledRulesRefs<T extends Object>(
    Expression<T> Function($$DisabledRulesTableAnnotationComposer a) f,
  ) {
    final $$DisabledRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disabledRules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisabledRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.disabledRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> proxyGroupsRefs<T extends Object>(
    Expression<T> Function($$ProxyGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProxyGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyGroups,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.proxyGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> proxyDialersRefs<T extends Object>(
    Expression<T> Function($$ProxyDialersTableAnnotationComposer a) f,
  ) {
    final $$ProxyDialersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyDialers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyDialersTableAnnotationComposer(
            $db: $db,
            $table: $db.proxyDialers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfilesTable,
          RawProfile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (RawProfile, $$ProfilesTableReferences),
          RawProfile,
          PrefetchHooks Function({
            bool rulesRefs,
            bool disabledRulesRefs,
            bool proxyGroupsRefs,
            bool proxyDialersRefs,
          })
        > {
  $$ProfilesTableTableManager(_$Database db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ProfileType> type = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> currentGroupName = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> ageSecretKey = const Value.absent(),
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                Value<ExtendType> extendType = const Value.absent(),
                Value<int?> scriptId = const Value.absent(),
                Value<String?> matchTarget = const Value.absent(),
                Value<int> autoUpdateDurationMillis = const Value.absent(),
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                Value<bool> autoUpdate = const Value.absent(),
                Value<Map<String, String>> selectedMap = const Value.absent(),
                Value<Set<String>> unfoldSet = const Value.absent(),
                Value<int?> order = const Value.absent(),
                Value<ProfileOverrides?> overrides = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                type: type,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                ageSecretKey: ageSecretKey,
                lastUpdateDate: lastUpdateDate,
                extendType: extendType,
                scriptId: scriptId,
                matchTarget: matchTarget,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
                overrides: overrides,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ProfileType type,
                required String label,
                Value<String?> currentGroupName = const Value.absent(),
                required String url,
                Value<String?> ageSecretKey = const Value.absent(),
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                required ExtendType extendType,
                Value<int?> scriptId = const Value.absent(),
                Value<String?> matchTarget = const Value.absent(),
                required int autoUpdateDurationMillis,
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                required bool autoUpdate,
                required Map<String, String> selectedMap,
                required Set<String> unfoldSet,
                Value<int?> order = const Value.absent(),
                Value<ProfileOverrides?> overrides = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                type: type,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                ageSecretKey: ageSecretKey,
                lastUpdateDate: lastUpdateDate,
                extendType: extendType,
                scriptId: scriptId,
                matchTarget: matchTarget,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
                overrides: overrides,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, RawProfile>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rulesRefs = false,
                disabledRulesRefs = false,
                proxyGroupsRefs = false,
                proxyDialersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rulesRefs) db.rules,
                    if (disabledRulesRefs) db.disabledRules,
                    if (proxyGroupsRefs) db.proxyGroups,
                    if (proxyDialersRefs) db.proxyDialers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rulesRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawRule
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._rulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).rulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (disabledRulesRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawDisabledRule
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._disabledRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).disabledRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (proxyGroupsRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawProxyGroup
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._proxyGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).proxyGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (proxyDialersRefs)
                        await $_getPrefetchedData<
                          RawProfile,
                          $ProfilesTable,
                          RawProxyDialer
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._proxyDialersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).proxyDialersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfilesTable,
      RawProfile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (RawProfile, $$ProfilesTableReferences),
      RawProfile,
      PrefetchHooks Function({
        bool rulesRefs,
        bool disabledRulesRefs,
        bool proxyGroupsRefs,
        bool proxyDialersRefs,
      })
    >;
typedef $$ScriptsTableCreateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      required String label,
      required DateTime lastUpdateTime,
      Value<String?> url,
      Value<int?> order,
    });
typedef $$ScriptsTableUpdateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<DateTime> lastUpdateTime,
      Value<String?> url,
      Value<int?> order,
    });

class $$ScriptsTableFilterComposer extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScriptsTableOrderingComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScriptsTableAnnotationComposer
    extends Composer<_$Database, $ScriptsTable> {
  $$ScriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$ScriptsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ScriptsTable,
          RawScript,
          $$ScriptsTableFilterComposer,
          $$ScriptsTableOrderingComposer,
          $$ScriptsTableAnnotationComposer,
          $$ScriptsTableCreateCompanionBuilder,
          $$ScriptsTableUpdateCompanionBuilder,
          (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
          RawScript,
          PrefetchHooks Function()
        > {
  $$ScriptsTableTableManager(_$Database db, $ScriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> lastUpdateTime = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ScriptsCompanion(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
                url: url,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required DateTime lastUpdateTime,
                Value<String?> url = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ScriptsCompanion.insert(
                id: id,
                label: label,
                lastUpdateTime: lastUpdateTime,
                url: url,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScriptsTable, RawScript>(table),
                  BaseReferences<_$Database, $ScriptsTable, RawScript>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ScriptsTable,
      RawScript,
      $$ScriptsTableFilterComposer,
      $$ScriptsTableOrderingComposer,
      $$ScriptsTableAnnotationComposer,
      $$ScriptsTableCreateCompanionBuilder,
      $$ScriptsTableUpdateCompanionBuilder,
      (RawScript, BaseReferences<_$Database, $ScriptsTable, RawScript>),
      RawScript,
      PrefetchHooks Function()
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      required RuleAction ruleAction,
      Value<String?> content,
      Value<String?> ruleTarget,
      Value<String?> ruleProvider,
      Value<String?> subRule,
      Value<bool> noResolve,
      Value<bool> src,
      Value<String?> order,
    });
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      Value<RuleAction> ruleAction,
      Value<String?> content,
      Value<String?> ruleTarget,
      Value<String?> ruleProvider,
      Value<String?> subRule,
      Value<bool> noResolve,
      Value<bool> src,
      Value<String?> order,
    });

final class $$RulesTableReferences
    extends BaseReferences<_$Database, $RulesTable, RawRule> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias('rules__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DisabledRulesTable, List<RawDisabledRule>>
  _disabledRulesRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.disabledRules,
    aliasName: 'rules__id__disabled_rules__rule_id',
  );

  $$DisabledRulesTableProcessedTableManager get disabledRulesRefs {
    final manager = $$DisabledRulesTableTableManager(
      $_db,
      $_db.disabledRules,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_disabledRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RulesTableFilterComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RuleAction, RuleAction, String>
  get ruleAction => $composableBuilder(
    column: $table.ruleAction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subRule => $composableBuilder(
    column: $table.subRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noResolve => $composableBuilder(
    column: $table.noResolve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> disabledRulesRefs(
    Expression<bool> Function($$DisabledRulesTableFilterComposer f) f,
  ) {
    final $$DisabledRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disabledRules,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisabledRulesTableFilterComposer(
            $db: $db,
            $table: $db.disabledRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableOrderingComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleAction => $composableBuilder(
    column: $table.ruleAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subRule => $composableBuilder(
    column: $table.subRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noResolve => $composableBuilder(
    column: $table.noResolve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RulesTableAnnotationComposer extends Composer<_$Database, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleAction, String> get ruleAction =>
      $composableBuilder(
        column: $table.ruleAction,
        builder: (column) => column,
      );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get ruleTarget => $composableBuilder(
    column: $table.ruleTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleProvider => $composableBuilder(
    column: $table.ruleProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subRule =>
      $composableBuilder(column: $table.subRule, builder: (column) => column);

  GeneratedColumn<bool> get noResolve =>
      $composableBuilder(column: $table.noResolve, builder: (column) => column);

  GeneratedColumn<bool> get src =>
      $composableBuilder(column: $table.src, builder: (column) => column);

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> disabledRulesRefs<T extends Object>(
    Expression<T> Function($$DisabledRulesTableAnnotationComposer a) f,
  ) {
    final $$DisabledRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disabledRules,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisabledRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.disabledRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $RulesTable,
          RawRule,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RawRule, $$RulesTableReferences),
          RawRule,
          PrefetchHooks Function({bool profileId, bool disabledRulesRefs})
        > {
  $$RulesTableTableManager(_$Database db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<RuleAction> ruleAction = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> ruleTarget = const Value.absent(),
                Value<String?> ruleProvider = const Value.absent(),
                Value<String?> subRule = const Value.absent(),
                Value<bool> noResolve = const Value.absent(),
                Value<bool> src = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                profileId: profileId,
                ruleAction: ruleAction,
                content: content,
                ruleTarget: ruleTarget,
                ruleProvider: ruleProvider,
                subRule: subRule,
                noResolve: noResolve,
                src: src,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required RuleAction ruleAction,
                Value<String?> content = const Value.absent(),
                Value<String?> ruleTarget = const Value.absent(),
                Value<String?> ruleProvider = const Value.absent(),
                Value<String?> subRule = const Value.absent(),
                Value<bool> noResolve = const Value.absent(),
                Value<bool> src = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                profileId: profileId,
                ruleAction: ruleAction,
                content: content,
                ruleTarget: ruleTarget,
                ruleProvider: ruleProvider,
                subRule: subRule,
                noResolve: noResolve,
                src: src,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RulesTable, RawRule>(table),
                  $$RulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, disabledRulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (disabledRulesRefs) db.disabledRules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable: $$RulesTableReferences
                                        ._profileIdTable(db),
                                    referencedColumn: $$RulesTableReferences
                                        ._profileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (disabledRulesRefs)
                        await $_getPrefetchedData<
                          RawRule,
                          $RulesTable,
                          RawDisabledRule
                        >(
                          currentTable: table,
                          referencedTable: $$RulesTableReferences
                              ._disabledRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RulesTableReferences(
                                db,
                                table,
                                p0,
                              ).disabledRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ruleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $RulesTable,
      RawRule,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RawRule, $$RulesTableReferences),
      RawRule,
      PrefetchHooks Function({bool profileId, bool disabledRulesRefs})
    >;
typedef $$DisabledRulesTableCreateCompanionBuilder =
    DisabledRulesCompanion Function({
      required int profileId,
      required int ruleId,
      Value<int> rowid,
    });
typedef $$DisabledRulesTableUpdateCompanionBuilder =
    DisabledRulesCompanion Function({
      Value<int> profileId,
      Value<int> ruleId,
      Value<int> rowid,
    });

final class $$DisabledRulesTableReferences
    extends BaseReferences<_$Database, $DisabledRulesTable, RawDisabledRule> {
  $$DisabledRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias('disabled_rules__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RulesTable _ruleIdTable(_$Database db) =>
      db.rules.createAlias('disabled_rules__rule_id__rules__id');

  $$RulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DisabledRulesTableFilterComposer
    extends Composer<_$Database, $DisabledRulesTable> {
  $$DisabledRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableFilterComposer get ruleId {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisabledRulesTableOrderingComposer
    extends Composer<_$Database, $DisabledRulesTable> {
  $$DisabledRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableOrderingComposer get ruleId {
    final $$RulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableOrderingComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisabledRulesTableAnnotationComposer
    extends Composer<_$Database, $DisabledRulesTable> {
  $$DisabledRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RulesTableAnnotationComposer get ruleId {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisabledRulesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $DisabledRulesTable,
          RawDisabledRule,
          $$DisabledRulesTableFilterComposer,
          $$DisabledRulesTableOrderingComposer,
          $$DisabledRulesTableAnnotationComposer,
          $$DisabledRulesTableCreateCompanionBuilder,
          $$DisabledRulesTableUpdateCompanionBuilder,
          (RawDisabledRule, $$DisabledRulesTableReferences),
          RawDisabledRule,
          PrefetchHooks Function({bool profileId, bool ruleId})
        > {
  $$DisabledRulesTableTableManager(_$Database db, $DisabledRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisabledRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisabledRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisabledRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DisabledRulesCompanion(
                profileId: profileId,
                ruleId: ruleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required int ruleId,
                Value<int> rowid = const Value.absent(),
              }) => DisabledRulesCompanion.insert(
                profileId: profileId,
                ruleId: ruleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DisabledRulesTable, RawDisabledRule>(table),
                  $$DisabledRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$DisabledRulesTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$DisabledRulesTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (ruleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ruleId,
                                referencedTable: $$DisabledRulesTableReferences
                                    ._ruleIdTable(db),
                                referencedColumn: $$DisabledRulesTableReferences
                                    ._ruleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DisabledRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $DisabledRulesTable,
      RawDisabledRule,
      $$DisabledRulesTableFilterComposer,
      $$DisabledRulesTableOrderingComposer,
      $$DisabledRulesTableAnnotationComposer,
      $$DisabledRulesTableCreateCompanionBuilder,
      $$DisabledRulesTableUpdateCompanionBuilder,
      (RawDisabledRule, $$DisabledRulesTableReferences),
      RawDisabledRule,
      PrefetchHooks Function({bool profileId, bool ruleId})
    >;
typedef $$ProxyGroupsTableCreateCompanionBuilder =
    ProxyGroupsCompanion Function({
      Value<int> id,
      required int profileId,
      required String name,
      required String type,
      Value<List<String>?> proxies,
      Value<List<String>?> use,
      Value<String> definition,
      Value<String?> order,
    });
typedef $$ProxyGroupsTableUpdateCompanionBuilder =
    ProxyGroupsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> name,
      Value<String> type,
      Value<List<String>?> proxies,
      Value<List<String>?> use,
      Value<String> definition,
      Value<String?> order,
    });

final class $$ProxyGroupsTableReferences
    extends BaseReferences<_$Database, $ProxyGroupsTable, RawProxyGroup> {
  $$ProxyGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias('proxy_groups__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProxyGroupsTableFilterComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get proxies => $composableBuilder(
    column: $table.proxies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String> get use =>
      $composableBuilder(
        column: $table.use,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableOrderingComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proxies => $composableBuilder(
    column: $table.proxies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get use => $composableBuilder(
    column: $table.use,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableAnnotationComposer
    extends Composer<_$Database, $ProxyGroupsTable> {
  $$ProxyGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get proxies =>
      $composableBuilder(column: $table.proxies, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get use =>
      $composableBuilder(column: $table.use, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyGroupsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProxyGroupsTable,
          RawProxyGroup,
          $$ProxyGroupsTableFilterComposer,
          $$ProxyGroupsTableOrderingComposer,
          $$ProxyGroupsTableAnnotationComposer,
          $$ProxyGroupsTableCreateCompanionBuilder,
          $$ProxyGroupsTableUpdateCompanionBuilder,
          (RawProxyGroup, $$ProxyGroupsTableReferences),
          RawProxyGroup,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProxyGroupsTableTableManager(_$Database db, $ProxyGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProxyGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProxyGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProxyGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<List<String>?> proxies = const Value.absent(),
                Value<List<String>?> use = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => ProxyGroupsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                type: type,
                proxies: proxies,
                use: use,
                definition: definition,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                required String type,
                Value<List<String>?> proxies = const Value.absent(),
                Value<List<String>?> use = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> order = const Value.absent(),
              }) => ProxyGroupsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                type: type,
                proxies: proxies,
                use: use,
                definition: definition,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProxyGroupsTable, RawProxyGroup>(table),
                  $$ProxyGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ProxyGroupsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ProxyGroupsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProxyGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProxyGroupsTable,
      RawProxyGroup,
      $$ProxyGroupsTableFilterComposer,
      $$ProxyGroupsTableOrderingComposer,
      $$ProxyGroupsTableAnnotationComposer,
      $$ProxyGroupsTableCreateCompanionBuilder,
      $$ProxyGroupsTableUpdateCompanionBuilder,
      (RawProxyGroup, $$ProxyGroupsTableReferences),
      RawProxyGroup,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$IconRecordsTableCreateCompanionBuilder =
    IconRecordsCompanion Function({
      required String url,
      required int lastAccessed,
      Value<int> rowid,
    });
typedef $$IconRecordsTableUpdateCompanionBuilder =
    IconRecordsCompanion Function({
      Value<String> url,
      Value<int> lastAccessed,
      Value<int> rowid,
    });

class $$IconRecordsTableFilterComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IconRecordsTableOrderingComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IconRecordsTableAnnotationComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => column,
  );
}

class $$IconRecordsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $IconRecordsTable,
          IconRecord,
          $$IconRecordsTableFilterComposer,
          $$IconRecordsTableOrderingComposer,
          $$IconRecordsTableAnnotationComposer,
          $$IconRecordsTableCreateCompanionBuilder,
          $$IconRecordsTableUpdateCompanionBuilder,
          (
            IconRecord,
            BaseReferences<_$Database, $IconRecordsTable, IconRecord>,
          ),
          IconRecord,
          PrefetchHooks Function()
        > {
  $$IconRecordsTableTableManager(_$Database db, $IconRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IconRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IconRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IconRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<int> lastAccessed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required int lastAccessed,
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion.insert(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IconRecordsTable, IconRecord>(table),
                  BaseReferences<_$Database, $IconRecordsTable, IconRecord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IconRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $IconRecordsTable,
      IconRecord,
      $$IconRecordsTableFilterComposer,
      $$IconRecordsTableOrderingComposer,
      $$IconRecordsTableAnnotationComposer,
      $$IconRecordsTableCreateCompanionBuilder,
      $$IconRecordsTableUpdateCompanionBuilder,
      (IconRecord, BaseReferences<_$Database, $IconRecordsTable, IconRecord>),
      IconRecord,
      PrefetchHooks Function()
    >;
typedef $$IconSetsTableCreateCompanionBuilder =
    IconSetsCompanion Function({
      Value<int> id,
      required String name,
      required String url,
      required List<IconSetIcon> icons,
      Value<DateTime?> lastUpdateTime,
      Value<int?> order,
    });
typedef $$IconSetsTableUpdateCompanionBuilder =
    IconSetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> url,
      Value<List<IconSetIcon>> icons,
      Value<DateTime?> lastUpdateTime,
      Value<int?> order,
    });

class $$IconSetsTableFilterComposer
    extends Composer<_$Database, $IconSetsTable> {
  $$IconSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<IconSetIcon>, List<IconSetIcon>, String>
  get icons => $composableBuilder(
    column: $table.icons,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IconSetsTableOrderingComposer
    extends Composer<_$Database, $IconSetsTable> {
  $$IconSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icons => $composableBuilder(
    column: $table.icons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IconSetsTableAnnotationComposer
    extends Composer<_$Database, $IconSetsTable> {
  $$IconSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<IconSetIcon>, String> get icons =>
      $composableBuilder(column: $table.icons, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$IconSetsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $IconSetsTable,
          RawIconSet,
          $$IconSetsTableFilterComposer,
          $$IconSetsTableOrderingComposer,
          $$IconSetsTableAnnotationComposer,
          $$IconSetsTableCreateCompanionBuilder,
          $$IconSetsTableUpdateCompanionBuilder,
          (RawIconSet, BaseReferences<_$Database, $IconSetsTable, RawIconSet>),
          RawIconSet,
          PrefetchHooks Function()
        > {
  $$IconSetsTableTableManager(_$Database db, $IconSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IconSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IconSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IconSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<List<IconSetIcon>> icons = const Value.absent(),
                Value<DateTime?> lastUpdateTime = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => IconSetsCompanion(
                id: id,
                name: name,
                url: url,
                icons: icons,
                lastUpdateTime: lastUpdateTime,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String url,
                required List<IconSetIcon> icons,
                Value<DateTime?> lastUpdateTime = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => IconSetsCompanion.insert(
                id: id,
                name: name,
                url: url,
                icons: icons,
                lastUpdateTime: lastUpdateTime,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IconSetsTable, RawIconSet>(table),
                  BaseReferences<_$Database, $IconSetsTable, RawIconSet>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IconSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $IconSetsTable,
      RawIconSet,
      $$IconSetsTableFilterComposer,
      $$IconSetsTableOrderingComposer,
      $$IconSetsTableAnnotationComposer,
      $$IconSetsTableCreateCompanionBuilder,
      $$IconSetsTableUpdateCompanionBuilder,
      (RawIconSet, BaseReferences<_$Database, $IconSetsTable, RawIconSet>),
      RawIconSet,
      PrefetchHooks Function()
    >;
typedef $$ClashProvidersTableCreateCompanionBuilder =
    ClashProvidersCompanion Function({
      Value<int> id,
      required ProviderKind kind,
      required String label,
      required String url,
      Value<RuleProviderBehavior?> behavior,
      Value<RuleProviderFormat?> format,
      Value<int?> order,
    });
typedef $$ClashProvidersTableUpdateCompanionBuilder =
    ClashProvidersCompanion Function({
      Value<int> id,
      Value<ProviderKind> kind,
      Value<String> label,
      Value<String> url,
      Value<RuleProviderBehavior?> behavior,
      Value<RuleProviderFormat?> format,
      Value<int?> order,
    });

class $$ClashProvidersTableFilterComposer
    extends Composer<_$Database, $ClashProvidersTable> {
  $$ClashProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProviderKind, ProviderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RuleProviderBehavior?,
    RuleProviderBehavior,
    String
  >
  get behavior => $composableBuilder(
    column: $table.behavior,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RuleProviderFormat?,
    RuleProviderFormat,
    String
  >
  get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClashProvidersTableOrderingComposer
    extends Composer<_$Database, $ClashProvidersTable> {
  $$ClashProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get behavior => $composableBuilder(
    column: $table.behavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClashProvidersTableAnnotationComposer
    extends Composer<_$Database, $ClashProvidersTable> {
  $$ClashProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProviderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleProviderBehavior?, String>
  get behavior =>
      $composableBuilder(column: $table.behavior, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleProviderFormat?, String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$ClashProvidersTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ClashProvidersTable,
          RawClashProvider,
          $$ClashProvidersTableFilterComposer,
          $$ClashProvidersTableOrderingComposer,
          $$ClashProvidersTableAnnotationComposer,
          $$ClashProvidersTableCreateCompanionBuilder,
          $$ClashProvidersTableUpdateCompanionBuilder,
          (
            RawClashProvider,
            BaseReferences<_$Database, $ClashProvidersTable, RawClashProvider>,
          ),
          RawClashProvider,
          PrefetchHooks Function()
        > {
  $$ClashProvidersTableTableManager(_$Database db, $ClashProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClashProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClashProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClashProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ProviderKind> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<RuleProviderBehavior?> behavior = const Value.absent(),
                Value<RuleProviderFormat?> format = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ClashProvidersCompanion(
                id: id,
                kind: kind,
                label: label,
                url: url,
                behavior: behavior,
                format: format,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ProviderKind kind,
                required String label,
                required String url,
                Value<RuleProviderBehavior?> behavior = const Value.absent(),
                Value<RuleProviderFormat?> format = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ClashProvidersCompanion.insert(
                id: id,
                kind: kind,
                label: label,
                url: url,
                behavior: behavior,
                format: format,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClashProvidersTable, RawClashProvider>(table),
                  BaseReferences<
                    _$Database,
                    $ClashProvidersTable,
                    RawClashProvider
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClashProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ClashProvidersTable,
      RawClashProvider,
      $$ClashProvidersTableFilterComposer,
      $$ClashProvidersTableOrderingComposer,
      $$ClashProvidersTableAnnotationComposer,
      $$ClashProvidersTableCreateCompanionBuilder,
      $$ClashProvidersTableUpdateCompanionBuilder,
      (
        RawClashProvider,
        BaseReferences<_$Database, $ClashProvidersTable, RawClashProvider>,
      ),
      RawClashProvider,
      PrefetchHooks Function()
    >;
typedef $$CustomProxiesTableCreateCompanionBuilder =
    CustomProxiesCompanion Function({
      Value<int> id,
      required Map<String, dynamic> definition,
      Value<String?> order,
      Value<Set<String>?> emptyOptions,
    });
typedef $$CustomProxiesTableUpdateCompanionBuilder =
    CustomProxiesCompanion Function({
      Value<int> id,
      Value<Map<String, dynamic>> definition,
      Value<String?> order,
      Value<Set<String>?> emptyOptions,
    });

final class $$CustomProxiesTableReferences
    extends BaseReferences<_$Database, $CustomProxiesTable, RawCustomProxy> {
  $$CustomProxiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProxyDialersTable, List<RawProxyDialer>>
  _proxyDialersRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.proxyDialers,
    aliasName: 'custom_proxies__id__proxy_dialers__proxy_id',
  );

  $$ProxyDialersTableProcessedTableManager get proxyDialersRefs {
    final manager = $$ProxyDialersTableTableManager(
      $_db,
      $_db.proxyDialers,
    ).filter((f) => f.proxyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_proxyDialersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomProxiesTableFilterComposer
    extends Composer<_$Database, $CustomProxiesTable> {
  $$CustomProxiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<String>?, Set<String>, String>
  get emptyOptions => $composableBuilder(
    column: $table.emptyOptions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> proxyDialersRefs(
    Expression<bool> Function($$ProxyDialersTableFilterComposer f) f,
  ) {
    final $$ProxyDialersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyDialers,
      getReferencedColumn: (t) => t.proxyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyDialersTableFilterComposer(
            $db: $db,
            $table: $db.proxyDialers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomProxiesTableOrderingComposer
    extends Composer<_$Database, $CustomProxiesTable> {
  $$CustomProxiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emptyOptions => $composableBuilder(
    column: $table.emptyOptions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomProxiesTableAnnotationComposer
    extends Composer<_$Database, $CustomProxiesTable> {
  $$CustomProxiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<String>?, String> get emptyOptions =>
      $composableBuilder(
        column: $table.emptyOptions,
        builder: (column) => column,
      );

  Expression<T> proxyDialersRefs<T extends Object>(
    Expression<T> Function($$ProxyDialersTableAnnotationComposer a) f,
  ) {
    final $$ProxyDialersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proxyDialers,
      getReferencedColumn: (t) => t.proxyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProxyDialersTableAnnotationComposer(
            $db: $db,
            $table: $db.proxyDialers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomProxiesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $CustomProxiesTable,
          RawCustomProxy,
          $$CustomProxiesTableFilterComposer,
          $$CustomProxiesTableOrderingComposer,
          $$CustomProxiesTableAnnotationComposer,
          $$CustomProxiesTableCreateCompanionBuilder,
          $$CustomProxiesTableUpdateCompanionBuilder,
          (RawCustomProxy, $$CustomProxiesTableReferences),
          RawCustomProxy,
          PrefetchHooks Function({bool proxyDialersRefs})
        > {
  $$CustomProxiesTableTableManager(_$Database db, $CustomProxiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomProxiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomProxiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomProxiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Map<String, dynamic>> definition = const Value.absent(),
                Value<String?> order = const Value.absent(),
                Value<Set<String>?> emptyOptions = const Value.absent(),
              }) => CustomProxiesCompanion(
                id: id,
                definition: definition,
                order: order,
                emptyOptions: emptyOptions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Map<String, dynamic> definition,
                Value<String?> order = const Value.absent(),
                Value<Set<String>?> emptyOptions = const Value.absent(),
              }) => CustomProxiesCompanion.insert(
                id: id,
                definition: definition,
                order: order,
                emptyOptions: emptyOptions,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomProxiesTable, RawCustomProxy>(table),
                  $$CustomProxiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({proxyDialersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (proxyDialersRefs) db.proxyDialers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (proxyDialersRefs)
                    await $_getPrefetchedData<
                      RawCustomProxy,
                      $CustomProxiesTable,
                      RawProxyDialer
                    >(
                      currentTable: table,
                      referencedTable: $$CustomProxiesTableReferences
                          ._proxyDialersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomProxiesTableReferences(
                            db,
                            table,
                            p0,
                          ).proxyDialersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.proxyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomProxiesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $CustomProxiesTable,
      RawCustomProxy,
      $$CustomProxiesTableFilterComposer,
      $$CustomProxiesTableOrderingComposer,
      $$CustomProxiesTableAnnotationComposer,
      $$CustomProxiesTableCreateCompanionBuilder,
      $$CustomProxiesTableUpdateCompanionBuilder,
      (RawCustomProxy, $$CustomProxiesTableReferences),
      RawCustomProxy,
      PrefetchHooks Function({bool proxyDialersRefs})
    >;
typedef $$ProxyDialersTableCreateCompanionBuilder =
    ProxyDialersCompanion Function({
      required int profileId,
      required int proxyId,
      required String target,
      Value<int> rowid,
    });
typedef $$ProxyDialersTableUpdateCompanionBuilder =
    ProxyDialersCompanion Function({
      Value<int> profileId,
      Value<int> proxyId,
      Value<String> target,
      Value<int> rowid,
    });

final class $$ProxyDialersTableReferences
    extends BaseReferences<_$Database, $ProxyDialersTable, RawProxyDialer> {
  $$ProxyDialersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias('proxy_dialers__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomProxiesTable _proxyIdTable(_$Database db) => db.customProxies
      .createAlias('proxy_dialers__proxy_id__custom_proxies__id');

  $$CustomProxiesTableProcessedTableManager get proxyId {
    final $_column = $_itemColumn<int>('proxy_id')!;

    final manager = $$CustomProxiesTableTableManager(
      $_db,
      $_db.customProxies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_proxyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProxyDialersTableFilterComposer
    extends Composer<_$Database, $ProxyDialersTable> {
  $$ProxyDialersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomProxiesTableFilterComposer get proxyId {
    final $$CustomProxiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proxyId,
      referencedTable: $db.customProxies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomProxiesTableFilterComposer(
            $db: $db,
            $table: $db.customProxies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyDialersTableOrderingComposer
    extends Composer<_$Database, $ProxyDialersTable> {
  $$ProxyDialersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomProxiesTableOrderingComposer get proxyId {
    final $$CustomProxiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proxyId,
      referencedTable: $db.customProxies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomProxiesTableOrderingComposer(
            $db: $db,
            $table: $db.customProxies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyDialersTableAnnotationComposer
    extends Composer<_$Database, $ProxyDialersTable> {
  $$ProxyDialersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomProxiesTableAnnotationComposer get proxyId {
    final $$CustomProxiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proxyId,
      referencedTable: $db.customProxies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomProxiesTableAnnotationComposer(
            $db: $db,
            $table: $db.customProxies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProxyDialersTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProxyDialersTable,
          RawProxyDialer,
          $$ProxyDialersTableFilterComposer,
          $$ProxyDialersTableOrderingComposer,
          $$ProxyDialersTableAnnotationComposer,
          $$ProxyDialersTableCreateCompanionBuilder,
          $$ProxyDialersTableUpdateCompanionBuilder,
          (RawProxyDialer, $$ProxyDialersTableReferences),
          RawProxyDialer,
          PrefetchHooks Function({bool profileId, bool proxyId})
        > {
  $$ProxyDialersTableTableManager(_$Database db, $ProxyDialersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProxyDialersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProxyDialersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProxyDialersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> proxyId = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProxyDialersCompanion(
                profileId: profileId,
                proxyId: proxyId,
                target: target,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required int proxyId,
                required String target,
                Value<int> rowid = const Value.absent(),
              }) => ProxyDialersCompanion.insert(
                profileId: profileId,
                proxyId: proxyId,
                target: target,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProxyDialersTable, RawProxyDialer>(table),
                  $$ProxyDialersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, proxyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ProxyDialersTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ProxyDialersTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (proxyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.proxyId,
                                referencedTable: $$ProxyDialersTableReferences
                                    ._proxyIdTable(db),
                                referencedColumn: $$ProxyDialersTableReferences
                                    ._proxyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProxyDialersTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProxyDialersTable,
      RawProxyDialer,
      $$ProxyDialersTableFilterComposer,
      $$ProxyDialersTableOrderingComposer,
      $$ProxyDialersTableAnnotationComposer,
      $$ProxyDialersTableCreateCompanionBuilder,
      $$ProxyDialersTableUpdateCompanionBuilder,
      (RawProxyDialer, $$ProxyDialersTableReferences),
      RawProxyDialer,
      PrefetchHooks Function({bool profileId, bool proxyId})
    >;
typedef $$IpQualitiesTableCreateCompanionBuilder =
    IpQualitiesCompanion Function({
      required String ip,
      required IpQuality quality,
      required DateTime checkedAt,
      Value<int> rowid,
    });
typedef $$IpQualitiesTableUpdateCompanionBuilder =
    IpQualitiesCompanion Function({
      Value<String> ip,
      Value<IpQuality> quality,
      Value<DateTime> checkedAt,
      Value<int> rowid,
    });

class $$IpQualitiesTableFilterComposer
    extends Composer<_$Database, $IpQualitiesTable> {
  $$IpQualitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IpQuality, IpQuality, String> get quality =>
      $composableBuilder(
        column: $table.quality,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IpQualitiesTableOrderingComposer
    extends Composer<_$Database, $IpQualitiesTable> {
  $$IpQualitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IpQualitiesTableAnnotationComposer
    extends Composer<_$Database, $IpQualitiesTable> {
  $$IpQualitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IpQuality, String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);
}

class $$IpQualitiesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $IpQualitiesTable,
          IpQualityRecord,
          $$IpQualitiesTableFilterComposer,
          $$IpQualitiesTableOrderingComposer,
          $$IpQualitiesTableAnnotationComposer,
          $$IpQualitiesTableCreateCompanionBuilder,
          $$IpQualitiesTableUpdateCompanionBuilder,
          (
            IpQualityRecord,
            BaseReferences<_$Database, $IpQualitiesTable, IpQualityRecord>,
          ),
          IpQualityRecord,
          PrefetchHooks Function()
        > {
  $$IpQualitiesTableTableManager(_$Database db, $IpQualitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IpQualitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IpQualitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IpQualitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ip = const Value.absent(),
                Value<IpQuality> quality = const Value.absent(),
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IpQualitiesCompanion(
                ip: ip,
                quality: quality,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ip,
                required IpQuality quality,
                required DateTime checkedAt,
                Value<int> rowid = const Value.absent(),
              }) => IpQualitiesCompanion.insert(
                ip: ip,
                quality: quality,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IpQualitiesTable, IpQualityRecord>(table),
                  BaseReferences<
                    _$Database,
                    $IpQualitiesTable,
                    IpQualityRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IpQualitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $IpQualitiesTable,
      IpQualityRecord,
      $$IpQualitiesTableFilterComposer,
      $$IpQualitiesTableOrderingComposer,
      $$IpQualitiesTableAnnotationComposer,
      $$IpQualitiesTableCreateCompanionBuilder,
      $$IpQualitiesTableUpdateCompanionBuilder,
      (
        IpQualityRecord,
        BaseReferences<_$Database, $IpQualitiesTable, IpQualityRecord>,
      ),
      IpQualityRecord,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db, _db.scripts);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$DisabledRulesTableTableManager get disabledRules =>
      $$DisabledRulesTableTableManager(_db, _db.disabledRules);
  $$ProxyGroupsTableTableManager get proxyGroups =>
      $$ProxyGroupsTableTableManager(_db, _db.proxyGroups);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db, _db.iconRecords);
  $$IconSetsTableTableManager get iconSets =>
      $$IconSetsTableTableManager(_db, _db.iconSets);
  $$ClashProvidersTableTableManager get clashProviders =>
      $$ClashProvidersTableTableManager(_db, _db.clashProviders);
  $$CustomProxiesTableTableManager get customProxies =>
      $$CustomProxiesTableTableManager(_db, _db.customProxies);
  $$ProxyDialersTableTableManager get proxyDialers =>
      $$ProxyDialersTableTableManager(_db, _db.proxyDialers);
  $$IpQualitiesTableTableManager get ipQualities =>
      $$IpQualitiesTableTableManager(_db, _db.ipQualities);
}

mixin _$ProfilesDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}

mixin _$ScriptsDaoMixin on DatabaseAccessor<Database> {
  $ScriptsTable get scripts => attachedDatabase.scripts;
  ScriptsDaoManager get managers => ScriptsDaoManager(this);
}

class ScriptsDaoManager {
  final _$ScriptsDaoMixin _db;
  ScriptsDaoManager(this._db);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db.attachedDatabase, _db.scripts);
}

mixin _$RulesDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $RulesTable get rules => attachedDatabase.rules;
  $DisabledRulesTable get disabledRules => attachedDatabase.disabledRules;
  RulesDaoManager get managers => RulesDaoManager(this);
}

class RulesDaoManager {
  final _$RulesDaoMixin _db;
  RulesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db.attachedDatabase, _db.rules);
  $$DisabledRulesTableTableManager get disabledRules =>
      $$DisabledRulesTableTableManager(_db.attachedDatabase, _db.disabledRules);
}

mixin _$ProxyGroupsDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProxyGroupsTable get proxyGroups => attachedDatabase.proxyGroups;
  ProxyGroupsDaoManager get managers => ProxyGroupsDaoManager(this);
}

class ProxyGroupsDaoManager {
  final _$ProxyGroupsDaoMixin _db;
  ProxyGroupsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ProxyGroupsTableTableManager get proxyGroups =>
      $$ProxyGroupsTableTableManager(_db.attachedDatabase, _db.proxyGroups);
}

mixin _$IconRecordsDaoMixin on DatabaseAccessor<Database> {
  $IconRecordsTable get iconRecords => attachedDatabase.iconRecords;
  IconRecordsDaoManager get managers => IconRecordsDaoManager(this);
}

class IconRecordsDaoManager {
  final _$IconRecordsDaoMixin _db;
  IconRecordsDaoManager(this._db);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db.attachedDatabase, _db.iconRecords);
}

mixin _$IconSetsDaoMixin on DatabaseAccessor<Database> {
  $IconSetsTable get iconSets => attachedDatabase.iconSets;
  IconSetsDaoManager get managers => IconSetsDaoManager(this);
}

class IconSetsDaoManager {
  final _$IconSetsDaoMixin _db;
  IconSetsDaoManager(this._db);
  $$IconSetsTableTableManager get iconSets =>
      $$IconSetsTableTableManager(_db.attachedDatabase, _db.iconSets);
}

mixin _$ClashProvidersDaoMixin on DatabaseAccessor<Database> {
  $ClashProvidersTable get clashProviders => attachedDatabase.clashProviders;
  ClashProvidersDaoManager get managers => ClashProvidersDaoManager(this);
}

class ClashProvidersDaoManager {
  final _$ClashProvidersDaoMixin _db;
  ClashProvidersDaoManager(this._db);
  $$ClashProvidersTableTableManager get clashProviders =>
      $$ClashProvidersTableTableManager(
        _db.attachedDatabase,
        _db.clashProviders,
      );
}

mixin _$CustomProxiesDaoMixin on DatabaseAccessor<Database> {
  $CustomProxiesTable get customProxies => attachedDatabase.customProxies;
  CustomProxiesDaoManager get managers => CustomProxiesDaoManager(this);
}

class CustomProxiesDaoManager {
  final _$CustomProxiesDaoMixin _db;
  CustomProxiesDaoManager(this._db);
  $$CustomProxiesTableTableManager get customProxies =>
      $$CustomProxiesTableTableManager(_db.attachedDatabase, _db.customProxies);
}

mixin _$ProxyDialersDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CustomProxiesTable get customProxies => attachedDatabase.customProxies;
  $ProxyDialersTable get proxyDialers => attachedDatabase.proxyDialers;
  ProxyDialersDaoManager get managers => ProxyDialersDaoManager(this);
}

class ProxyDialersDaoManager {
  final _$ProxyDialersDaoMixin _db;
  ProxyDialersDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CustomProxiesTableTableManager get customProxies =>
      $$CustomProxiesTableTableManager(_db.attachedDatabase, _db.customProxies);
  $$ProxyDialersTableTableManager get proxyDialers =>
      $$ProxyDialersTableTableManager(_db.attachedDatabase, _db.proxyDialers);
}

mixin _$IpQualitiesDaoMixin on DatabaseAccessor<Database> {
  $IpQualitiesTable get ipQualities => attachedDatabase.ipQualities;
  IpQualitiesDaoManager get managers => IpQualitiesDaoManager(this);
}

class IpQualitiesDaoManager {
  final _$IpQualitiesDaoMixin _db;
  IpQualitiesDaoManager(this._db);
  $$IpQualitiesTableTableManager get ipQualities =>
      $$IpQualitiesTableTableManager(_db.attachedDatabase, _db.ipQualities);
}
