// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProfileCollectionCollection on Isar {
  IsarCollection<ProfileCollection> get profileCollections => this.collection();
}

const ProfileCollectionSchema = CollectionSchema(
  name: r'Profile',
  id: 1266279811925214857,
  properties: {
    r'autoUpdate': PropertySchema(
      id: 0,
      name: r'autoUpdate',
      type: IsarType.bool,
    ),
    r'autoUpdateDurationMillis': PropertySchema(
      id: 1,
      name: r'autoUpdateDurationMillis',
      type: IsarType.long,
    ),
    r'currentGroupName': PropertySchema(
      id: 2,
      name: r'currentGroupName',
      type: IsarType.string,
    ),
    r'label': PropertySchema(id: 3, name: r'label', type: IsarType.string),
    r'lastUpdateDate': PropertySchema(
      id: 4,
      name: r'lastUpdateDate',
      type: IsarType.dateTime,
    ),
    r'order': PropertySchema(id: 5, name: r'order', type: IsarType.long),
    r'overwrite': PropertySchema(
      id: 6,
      name: r'overwrite',
      type: IsarType.object,

      target: r'OverwriteEmbedded',
    ),
    r'selectedMapEntries': PropertySchema(
      id: 7,
      name: r'selectedMapEntries',
      type: IsarType.objectList,

      target: r'StringMapEntryEmbedded',
    ),
    r'subscriptionInfo': PropertySchema(
      id: 8,
      name: r'subscriptionInfo',
      type: IsarType.object,

      target: r'SubscriptionInfoEmbedded',
    ),
    r'unfoldList': PropertySchema(
      id: 9,
      name: r'unfoldList',
      type: IsarType.stringList,
    ),
    r'url': PropertySchema(id: 10, name: r'url', type: IsarType.string),
  },

  estimateSize: _profileCollectionEstimateSize,
  serialize: _profileCollectionSerialize,
  deserialize: _profileCollectionDeserialize,
  deserializeProp: _profileCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'order': IndexSchema(
      id: 5897270977454184057,
      name: r'order',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {
    r'customRules': LinkSchema(
      id: -8100151165153720393,
      name: r'customRules',
      target: r'Rule',
      single: false,
    ),
  },
  embeddedSchemas: {
    r'SubscriptionInfoEmbedded': SubscriptionInfoEmbeddedSchema,
    r'StringMapEntryEmbedded': StringMapEntryEmbeddedSchema,
    r'OverwriteEmbedded': OverwriteEmbeddedSchema,
    r'StandardOverwriteEmbedded': StandardOverwriteEmbeddedSchema,
    r'RuleEmbedded': RuleEmbeddedSchema,
    r'ScriptOverwriteEmbedded': ScriptOverwriteEmbeddedSchema,
  },

  getId: _profileCollectionGetId,
  getLinks: _profileCollectionGetLinks,
  attach: _profileCollectionAttach,
  version: '3.3.0',
);

int _profileCollectionEstimateSize(
  ProfileCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.currentGroupName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.label.length * 3;
  {
    final value = object.overwrite;
    if (value != null) {
      bytesCount +=
          3 +
          OverwriteEmbeddedSchema.estimateSize(
            value,
            allOffsets[OverwriteEmbedded]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.selectedMapEntries.length * 3;
  {
    final offsets = allOffsets[StringMapEntryEmbedded]!;
    for (var i = 0; i < object.selectedMapEntries.length; i++) {
      final value = object.selectedMapEntries[i];
      bytesCount += StringMapEntryEmbeddedSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.subscriptionInfo;
    if (value != null) {
      bytesCount +=
          3 +
          SubscriptionInfoEmbeddedSchema.estimateSize(
            value,
            allOffsets[SubscriptionInfoEmbedded]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.unfoldList.length * 3;
  {
    for (var i = 0; i < object.unfoldList.length; i++) {
      final value = object.unfoldList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _profileCollectionSerialize(
  ProfileCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoUpdate);
  writer.writeLong(offsets[1], object.autoUpdateDurationMillis);
  writer.writeString(offsets[2], object.currentGroupName);
  writer.writeString(offsets[3], object.label);
  writer.writeDateTime(offsets[4], object.lastUpdateDate);
  writer.writeLong(offsets[5], object.order);
  writer.writeObject<OverwriteEmbedded>(
    offsets[6],
    allOffsets,
    OverwriteEmbeddedSchema.serialize,
    object.overwrite,
  );
  writer.writeObjectList<StringMapEntryEmbedded>(
    offsets[7],
    allOffsets,
    StringMapEntryEmbeddedSchema.serialize,
    object.selectedMapEntries,
  );
  writer.writeObject<SubscriptionInfoEmbedded>(
    offsets[8],
    allOffsets,
    SubscriptionInfoEmbeddedSchema.serialize,
    object.subscriptionInfo,
  );
  writer.writeStringList(offsets[9], object.unfoldList);
  writer.writeString(offsets[10], object.url);
}

ProfileCollection _profileCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProfileCollection();
  object.autoUpdate = reader.readBool(offsets[0]);
  object.autoUpdateDurationMillis = reader.readLong(offsets[1]);
  object.currentGroupName = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.label = reader.readString(offsets[3]);
  object.lastUpdateDate = reader.readDateTimeOrNull(offsets[4]);
  object.order = reader.readLong(offsets[5]);
  object.overwrite = reader.readObjectOrNull<OverwriteEmbedded>(
    offsets[6],
    OverwriteEmbeddedSchema.deserialize,
    allOffsets,
  );
  object.selectedMapEntries =
      reader.readObjectList<StringMapEntryEmbedded>(
        offsets[7],
        StringMapEntryEmbeddedSchema.deserialize,
        allOffsets,
        StringMapEntryEmbedded(),
      ) ??
      [];
  object.subscriptionInfo = reader.readObjectOrNull<SubscriptionInfoEmbedded>(
    offsets[8],
    SubscriptionInfoEmbeddedSchema.deserialize,
    allOffsets,
  );
  object.unfoldList = reader.readStringList(offsets[9]) ?? [];
  object.url = reader.readString(offsets[10]);
  return object;
}

P _profileCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readObjectOrNull<OverwriteEmbedded>(
            offset,
            OverwriteEmbeddedSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 7:
      return (reader.readObjectList<StringMapEntryEmbedded>(
                offset,
                StringMapEntryEmbeddedSchema.deserialize,
                allOffsets,
                StringMapEntryEmbedded(),
              ) ??
              [])
          as P;
    case 8:
      return (reader.readObjectOrNull<SubscriptionInfoEmbedded>(
            offset,
            SubscriptionInfoEmbeddedSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _profileCollectionGetId(ProfileCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _profileCollectionGetLinks(
  ProfileCollection object,
) {
  return [object.customRules];
}

void _profileCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProfileCollection object,
) {
  object.id = id;
  object.customRules.attach(
    col,
    col.isar.collection<RuleCollection>(),
    r'customRules',
    id,
  );
}

extension ProfileCollectionQueryWhereSort
    on QueryBuilder<ProfileCollection, ProfileCollection, QWhere> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhere> anyOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'order'),
      );
    });
  }
}

extension ProfileCollectionQueryWhere
    on QueryBuilder<ProfileCollection, ProfileCollection, QWhereClause> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  orderEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'order', value: [order]),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  orderNotEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'order',
                lower: [],
                upper: [order],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'order',
                lower: [order],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'order',
                lower: [order],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'order',
                lower: [],
                upper: [order],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  orderGreaterThan(int order, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'order',
          lower: [order],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  orderLessThan(int order, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'order',
          lower: [],
          upper: [order],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterWhereClause>
  orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'order',
          lower: [lowerOrder],
          includeLower: includeLower,
          upper: [upperOrder],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProfileCollectionQueryFilter
    on QueryBuilder<ProfileCollection, ProfileCollection, QFilterCondition> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  autoUpdateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoUpdate', value: value),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  autoUpdateDurationMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoUpdateDurationMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  autoUpdateDurationMillisGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoUpdateDurationMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  autoUpdateDurationMillisLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoUpdateDurationMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  autoUpdateDurationMillisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoUpdateDurationMillis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentGroupName'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentGroupName'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentGroupName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentGroupName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentGroupName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentGroupName', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  currentGroupNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentGroupName', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUpdateDate'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUpdateDate'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdateDate', value: value),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdateDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdateDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  lastUpdateDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdateDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  orderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  orderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  overwriteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'overwrite'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  overwriteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'overwrite'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedMapEntries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedMapEntries', 0, true, 0, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedMapEntries', 0, false, 999999, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedMapEntries', 0, true, length, include);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedMapEntries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedMapEntries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  subscriptionInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'subscriptionInfo'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  subscriptionInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'subscriptionInfo'),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unfoldList',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unfoldList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unfoldList',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unfoldList', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unfoldList', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'unfoldList', length, true, length, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'unfoldList', 0, true, 0, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'unfoldList', 0, false, 999999, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'unfoldList', 0, true, length, include);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'unfoldList', length, include, 999999, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  unfoldListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unfoldList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension ProfileCollectionQueryObject
    on QueryBuilder<ProfileCollection, ProfileCollection, QFilterCondition> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  overwrite(FilterQuery<OverwriteEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'overwrite');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  selectedMapEntriesElement(FilterQuery<StringMapEntryEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'selectedMapEntries');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  subscriptionInfo(FilterQuery<SubscriptionInfoEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'subscriptionInfo');
    });
  }
}

extension ProfileCollectionQueryLinks
    on QueryBuilder<ProfileCollection, ProfileCollection, QFilterCondition> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRules(FilterQuery<RuleCollection> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'customRules');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'customRules', length, true, length, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'customRules', 0, true, 0, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'customRules', 0, false, 999999, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'customRules', 0, true, length, include);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'customRules', length, include, 999999, true);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterFilterCondition>
  customRulesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'customRules',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ProfileCollectionQuerySortBy
    on QueryBuilder<ProfileCollection, ProfileCollection, QSortBy> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByAutoUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdate', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByAutoUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdate', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByAutoUpdateDurationMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateDurationMillis', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByAutoUpdateDurationMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateDurationMillis', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByCurrentGroupName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentGroupName', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByCurrentGroupNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentGroupName', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByLastUpdateDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ProfileCollectionQuerySortThenBy
    on QueryBuilder<ProfileCollection, ProfileCollection, QSortThenBy> {
  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByAutoUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdate', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByAutoUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdate', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByAutoUpdateDurationMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateDurationMillis', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByAutoUpdateDurationMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateDurationMillis', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByCurrentGroupName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentGroupName', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByCurrentGroupNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentGroupName', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByLastUpdateDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QAfterSortBy>
  thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ProfileCollectionQueryWhereDistinct
    on QueryBuilder<ProfileCollection, ProfileCollection, QDistinct> {
  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByAutoUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdate');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByAutoUpdateDurationMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdateDurationMillis');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByCurrentGroupName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currentGroupName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateDate');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct>
  distinctByUnfoldList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unfoldList');
    });
  }

  QueryBuilder<ProfileCollection, ProfileCollection, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension ProfileCollectionQueryProperty
    on QueryBuilder<ProfileCollection, ProfileCollection, QQueryProperty> {
  QueryBuilder<ProfileCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProfileCollection, bool, QQueryOperations> autoUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdate');
    });
  }

  QueryBuilder<ProfileCollection, int, QQueryOperations>
  autoUpdateDurationMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdateDurationMillis');
    });
  }

  QueryBuilder<ProfileCollection, String?, QQueryOperations>
  currentGroupNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentGroupName');
    });
  }

  QueryBuilder<ProfileCollection, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<ProfileCollection, DateTime?, QQueryOperations>
  lastUpdateDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateDate');
    });
  }

  QueryBuilder<ProfileCollection, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<ProfileCollection, OverwriteEmbedded?, QQueryOperations>
  overwriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overwrite');
    });
  }

  QueryBuilder<
    ProfileCollection,
    List<StringMapEntryEmbedded>,
    QQueryOperations
  >
  selectedMapEntriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedMapEntries');
    });
  }

  QueryBuilder<ProfileCollection, SubscriptionInfoEmbedded?, QQueryOperations>
  subscriptionInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscriptionInfo');
    });
  }

  QueryBuilder<ProfileCollection, List<String>, QQueryOperations>
  unfoldListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unfoldList');
    });
  }

  QueryBuilder<ProfileCollection, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRuleCollectionCollection on Isar {
  IsarCollection<RuleCollection> get ruleCollections => this.collection();
}

const RuleCollectionSchema = CollectionSchema(
  name: r'Rule',
  id: -2659006343538057288,
  properties: {
    r'value': PropertySchema(id: 0, name: r'value', type: IsarType.string),
  },

  estimateSize: _ruleCollectionEstimateSize,
  serialize: _ruleCollectionSerialize,
  deserialize: _ruleCollectionDeserialize,
  deserializeProp: _ruleCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _ruleCollectionGetId,
  getLinks: _ruleCollectionGetLinks,
  attach: _ruleCollectionAttach,
  version: '3.3.0',
);

int _ruleCollectionEstimateSize(
  RuleCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.value.length * 3;
  return bytesCount;
}

void _ruleCollectionSerialize(
  RuleCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.value);
}

RuleCollection _ruleCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RuleCollection();
  object.id = id;
  object.value = reader.readString(offsets[0]);
  return object;
}

P _ruleCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ruleCollectionGetId(RuleCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ruleCollectionGetLinks(RuleCollection object) {
  return [];
}

void _ruleCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  RuleCollection object,
) {
  object.id = id;
}

extension RuleCollectionQueryWhereSort
    on QueryBuilder<RuleCollection, RuleCollection, QWhere> {
  QueryBuilder<RuleCollection, RuleCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RuleCollectionQueryWhere
    on QueryBuilder<RuleCollection, RuleCollection, QWhereClause> {
  QueryBuilder<RuleCollection, RuleCollection, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RuleCollectionQueryFilter
    on QueryBuilder<RuleCollection, RuleCollection, QFilterCondition> {
  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'value',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'value', value: ''),
      );
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterFilterCondition>
  valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'value', value: ''),
      );
    });
  }
}

extension RuleCollectionQueryObject
    on QueryBuilder<RuleCollection, RuleCollection, QFilterCondition> {}

extension RuleCollectionQueryLinks
    on QueryBuilder<RuleCollection, RuleCollection, QFilterCondition> {}

extension RuleCollectionQuerySortBy
    on QueryBuilder<RuleCollection, RuleCollection, QSortBy> {
  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension RuleCollectionQuerySortThenBy
    on QueryBuilder<RuleCollection, RuleCollection, QSortThenBy> {
  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<RuleCollection, RuleCollection, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension RuleCollectionQueryWhereDistinct
    on QueryBuilder<RuleCollection, RuleCollection, QDistinct> {
  QueryBuilder<RuleCollection, RuleCollection, QDistinct> distinctByValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value', caseSensitive: caseSensitive);
    });
  }
}

extension RuleCollectionQueryProperty
    on QueryBuilder<RuleCollection, RuleCollection, QQueryProperty> {
  QueryBuilder<RuleCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RuleCollection, String, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScriptCollectionCollection on Isar {
  IsarCollection<ScriptCollection> get scriptCollections => this.collection();
}

const ScriptCollectionSchema = CollectionSchema(
  name: r'Script',
  id: 8766020371142212049,
  properties: {
    r'label': PropertySchema(id: 0, name: r'label', type: IsarType.string),
    r'lastUpdateTime': PropertySchema(
      id: 1,
      name: r'lastUpdateTime',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _scriptCollectionEstimateSize,
  serialize: _scriptCollectionSerialize,
  deserialize: _scriptCollectionDeserialize,
  deserializeProp: _scriptCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _scriptCollectionGetId,
  getLinks: _scriptCollectionGetLinks,
  attach: _scriptCollectionAttach,
  version: '3.3.0',
);

int _scriptCollectionEstimateSize(
  ScriptCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  return bytesCount;
}

void _scriptCollectionSerialize(
  ScriptCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.label);
  writer.writeDateTime(offsets[1], object.lastUpdateTime);
}

ScriptCollection _scriptCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScriptCollection();
  object.id = id;
  object.label = reader.readString(offsets[0]);
  object.lastUpdateTime = reader.readDateTime(offsets[1]);
  return object;
}

P _scriptCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scriptCollectionGetId(ScriptCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scriptCollectionGetLinks(ScriptCollection object) {
  return [];
}

void _scriptCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  ScriptCollection object,
) {
  object.id = id;
}

extension ScriptCollectionQueryWhereSort
    on QueryBuilder<ScriptCollection, ScriptCollection, QWhere> {
  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScriptCollectionQueryWhere
    on QueryBuilder<ScriptCollection, ScriptCollection, QWhereClause> {
  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ScriptCollectionQueryFilter
    on QueryBuilder<ScriptCollection, ScriptCollection, QFilterCondition> {
  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  lastUpdateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdateTime', value: value),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  lastUpdateTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  lastUpdateTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterFilterCondition>
  lastUpdateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdateTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ScriptCollectionQueryObject
    on QueryBuilder<ScriptCollection, ScriptCollection, QFilterCondition> {}

extension ScriptCollectionQueryLinks
    on QueryBuilder<ScriptCollection, ScriptCollection, QFilterCondition> {}

extension ScriptCollectionQuerySortBy
    on QueryBuilder<ScriptCollection, ScriptCollection, QSortBy> {
  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }
}

extension ScriptCollectionQuerySortThenBy
    on QueryBuilder<ScriptCollection, ScriptCollection, QSortThenBy> {
  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QAfterSortBy>
  thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }
}

extension ScriptCollectionQueryWhereDistinct
    on QueryBuilder<ScriptCollection, ScriptCollection, QDistinct> {
  QueryBuilder<ScriptCollection, ScriptCollection, QDistinct> distinctByLabel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptCollection, ScriptCollection, QDistinct>
  distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }
}

extension ScriptCollectionQueryProperty
    on QueryBuilder<ScriptCollection, ScriptCollection, QQueryProperty> {
  QueryBuilder<ScriptCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScriptCollection, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<ScriptCollection, DateTime, QQueryOperations>
  lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StringMapEntryEmbeddedSchema = Schema(
  name: r'StringMapEntryEmbedded',
  id: 4933299157747379828,
  properties: {
    r'key': PropertySchema(id: 0, name: r'key', type: IsarType.string),
    r'value': PropertySchema(id: 1, name: r'value', type: IsarType.string),
  },

  estimateSize: _stringMapEntryEmbeddedEstimateSize,
  serialize: _stringMapEntryEmbeddedSerialize,
  deserialize: _stringMapEntryEmbeddedDeserialize,
  deserializeProp: _stringMapEntryEmbeddedDeserializeProp,
);

int _stringMapEntryEmbeddedEstimateSize(
  StringMapEntryEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.value.length * 3;
  return bytesCount;
}

void _stringMapEntryEmbeddedSerialize(
  StringMapEntryEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeString(offsets[1], object.value);
}

StringMapEntryEmbedded _stringMapEntryEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StringMapEntryEmbedded();
  object.key = reader.readString(offsets[0]);
  object.value = reader.readString(offsets[1]);
  return object;
}

P _stringMapEntryEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StringMapEntryEmbeddedQueryFilter
    on
        QueryBuilder<
          StringMapEntryEmbedded,
          StringMapEntryEmbedded,
          QFilterCondition
        > {
  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'value',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'value', value: ''),
      );
    });
  }

  QueryBuilder<
    StringMapEntryEmbedded,
    StringMapEntryEmbedded,
    QAfterFilterCondition
  >
  valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'value', value: ''),
      );
    });
  }
}

extension StringMapEntryEmbeddedQueryObject
    on
        QueryBuilder<
          StringMapEntryEmbedded,
          StringMapEntryEmbedded,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RuleEmbeddedSchema = Schema(
  name: r'RuleEmbedded',
  id: -590334916944944295,
  properties: {
    r'id': PropertySchema(id: 0, name: r'id', type: IsarType.long),
    r'value': PropertySchema(id: 1, name: r'value', type: IsarType.string),
  },

  estimateSize: _ruleEmbeddedEstimateSize,
  serialize: _ruleEmbeddedSerialize,
  deserialize: _ruleEmbeddedDeserialize,
  deserializeProp: _ruleEmbeddedDeserializeProp,
);

int _ruleEmbeddedEstimateSize(
  RuleEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.value.length * 3;
  return bytesCount;
}

void _ruleEmbeddedSerialize(
  RuleEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.id);
  writer.writeString(offsets[1], object.value);
}

RuleEmbedded _ruleEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RuleEmbedded();
  object.id = reader.readLong(offsets[0]);
  object.value = reader.readString(offsets[1]);
  return object;
}

P _ruleEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RuleEmbeddedQueryFilter
    on QueryBuilder<RuleEmbedded, RuleEmbedded, QFilterCondition> {
  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> idLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition>
  valueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition>
  valueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition> valueMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'value',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition>
  valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'value', value: ''),
      );
    });
  }

  QueryBuilder<RuleEmbedded, RuleEmbedded, QAfterFilterCondition>
  valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'value', value: ''),
      );
    });
  }
}

extension RuleEmbeddedQueryObject
    on QueryBuilder<RuleEmbedded, RuleEmbedded, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StandardOverwriteEmbeddedSchema = Schema(
  name: r'StandardOverwriteEmbedded',
  id: -1849861002552400142,
  properties: {
    r'addedRules': PropertySchema(
      id: 0,
      name: r'addedRules',
      type: IsarType.objectList,

      target: r'RuleEmbedded',
    ),
    r'disabledRuleIds': PropertySchema(
      id: 1,
      name: r'disabledRuleIds',
      type: IsarType.longList,
    ),
  },

  estimateSize: _standardOverwriteEmbeddedEstimateSize,
  serialize: _standardOverwriteEmbeddedSerialize,
  deserialize: _standardOverwriteEmbeddedDeserialize,
  deserializeProp: _standardOverwriteEmbeddedDeserializeProp,
);

int _standardOverwriteEmbeddedEstimateSize(
  StandardOverwriteEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.addedRules.length * 3;
  {
    final offsets = allOffsets[RuleEmbedded]!;
    for (var i = 0; i < object.addedRules.length; i++) {
      final value = object.addedRules[i];
      bytesCount += RuleEmbeddedSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.disabledRuleIds.length * 8;
  return bytesCount;
}

void _standardOverwriteEmbeddedSerialize(
  StandardOverwriteEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<RuleEmbedded>(
    offsets[0],
    allOffsets,
    RuleEmbeddedSchema.serialize,
    object.addedRules,
  );
  writer.writeLongList(offsets[1], object.disabledRuleIds);
}

StandardOverwriteEmbedded _standardOverwriteEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StandardOverwriteEmbedded();
  object.addedRules =
      reader.readObjectList<RuleEmbedded>(
        offsets[0],
        RuleEmbeddedSchema.deserialize,
        allOffsets,
        RuleEmbedded(),
      ) ??
      [];
  object.disabledRuleIds = reader.readLongList(offsets[1]) ?? [];
  return object;
}

P _standardOverwriteEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<RuleEmbedded>(
                offset,
                RuleEmbeddedSchema.deserialize,
                allOffsets,
                RuleEmbedded(),
              ) ??
              [])
          as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StandardOverwriteEmbeddedQueryFilter
    on
        QueryBuilder<
          StandardOverwriteEmbedded,
          StandardOverwriteEmbedded,
          QFilterCondition
        > {
  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'addedRules', length, true, length, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'addedRules', 0, true, 0, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'addedRules', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'addedRules', 0, true, length, include);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'addedRules', length, include, 999999, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'addedRules',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'disabledRuleIds', value: value),
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'disabledRuleIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'disabledRuleIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'disabledRuleIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'disabledRuleIds', length, true, length, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'disabledRuleIds', 0, true, 0, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'disabledRuleIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'disabledRuleIds', 0, true, length, include);
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'disabledRuleIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  disabledRuleIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'disabledRuleIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension StandardOverwriteEmbeddedQueryObject
    on
        QueryBuilder<
          StandardOverwriteEmbedded,
          StandardOverwriteEmbedded,
          QFilterCondition
        > {
  QueryBuilder<
    StandardOverwriteEmbedded,
    StandardOverwriteEmbedded,
    QAfterFilterCondition
  >
  addedRulesElement(FilterQuery<RuleEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'addedRules');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ScriptOverwriteEmbeddedSchema = Schema(
  name: r'ScriptOverwriteEmbedded',
  id: 3933184861921816147,
  properties: {
    r'scriptId': PropertySchema(id: 0, name: r'scriptId', type: IsarType.long),
  },

  estimateSize: _scriptOverwriteEmbeddedEstimateSize,
  serialize: _scriptOverwriteEmbeddedSerialize,
  deserialize: _scriptOverwriteEmbeddedDeserialize,
  deserializeProp: _scriptOverwriteEmbeddedDeserializeProp,
);

int _scriptOverwriteEmbeddedEstimateSize(
  ScriptOverwriteEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _scriptOverwriteEmbeddedSerialize(
  ScriptOverwriteEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.scriptId);
}

ScriptOverwriteEmbedded _scriptOverwriteEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScriptOverwriteEmbedded();
  object.scriptId = reader.readLongOrNull(offsets[0]);
  return object;
}

P _scriptOverwriteEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ScriptOverwriteEmbeddedQueryFilter
    on
        QueryBuilder<
          ScriptOverwriteEmbedded,
          ScriptOverwriteEmbedded,
          QFilterCondition
        > {
  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'scriptId'),
      );
    });
  }

  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'scriptId'),
      );
    });
  }

  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scriptId', value: value),
      );
    });
  }

  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scriptId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scriptId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ScriptOverwriteEmbedded,
    ScriptOverwriteEmbedded,
    QAfterFilterCondition
  >
  scriptIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scriptId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ScriptOverwriteEmbeddedQueryObject
    on
        QueryBuilder<
          ScriptOverwriteEmbedded,
          ScriptOverwriteEmbedded,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CustomOverwriteEmbeddedSchema = Schema(
  name: r'CustomOverwriteEmbedded',
  id: 6265409911132484050,
  properties: {},

  estimateSize: _customOverwriteEmbeddedEstimateSize,
  serialize: _customOverwriteEmbeddedSerialize,
  deserialize: _customOverwriteEmbeddedDeserialize,
  deserializeProp: _customOverwriteEmbeddedDeserializeProp,
);

int _customOverwriteEmbeddedEstimateSize(
  CustomOverwriteEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _customOverwriteEmbeddedSerialize(
  CustomOverwriteEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {}
CustomOverwriteEmbedded _customOverwriteEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomOverwriteEmbedded();
  return object;
}

P _customOverwriteEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CustomOverwriteEmbeddedQueryFilter
    on
        QueryBuilder<
          CustomOverwriteEmbedded,
          CustomOverwriteEmbedded,
          QFilterCondition
        > {}

extension CustomOverwriteEmbeddedQueryObject
    on
        QueryBuilder<
          CustomOverwriteEmbedded,
          CustomOverwriteEmbedded,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const OverwriteEmbeddedSchema = Schema(
  name: r'OverwriteEmbedded',
  id: 6327086372311451678,
  properties: {
    r'scriptOverwrite': PropertySchema(
      id: 0,
      name: r'scriptOverwrite',
      type: IsarType.object,

      target: r'ScriptOverwriteEmbedded',
    ),
    r'standardOverwrite': PropertySchema(
      id: 1,
      name: r'standardOverwrite',
      type: IsarType.object,

      target: r'StandardOverwriteEmbedded',
    ),
    r'type': PropertySchema(
      id: 2,
      name: r'type',
      type: IsarType.string,
      enumMap: _OverwriteEmbeddedtypeEnumValueMap,
    ),
  },

  estimateSize: _overwriteEmbeddedEstimateSize,
  serialize: _overwriteEmbeddedSerialize,
  deserialize: _overwriteEmbeddedDeserialize,
  deserializeProp: _overwriteEmbeddedDeserializeProp,
);

int _overwriteEmbeddedEstimateSize(
  OverwriteEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.scriptOverwrite;
    if (value != null) {
      bytesCount +=
          3 +
          ScriptOverwriteEmbeddedSchema.estimateSize(
            value,
            allOffsets[ScriptOverwriteEmbedded]!,
            allOffsets,
          );
    }
  }
  {
    final value = object.standardOverwrite;
    if (value != null) {
      bytesCount +=
          3 +
          StandardOverwriteEmbeddedSchema.estimateSize(
            value,
            allOffsets[StandardOverwriteEmbedded]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _overwriteEmbeddedSerialize(
  OverwriteEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<ScriptOverwriteEmbedded>(
    offsets[0],
    allOffsets,
    ScriptOverwriteEmbeddedSchema.serialize,
    object.scriptOverwrite,
  );
  writer.writeObject<StandardOverwriteEmbedded>(
    offsets[1],
    allOffsets,
    StandardOverwriteEmbeddedSchema.serialize,
    object.standardOverwrite,
  );
  writer.writeString(offsets[2], object.type.name);
}

OverwriteEmbedded _overwriteEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OverwriteEmbedded();
  object.scriptOverwrite = reader.readObjectOrNull<ScriptOverwriteEmbedded>(
    offsets[0],
    ScriptOverwriteEmbeddedSchema.deserialize,
    allOffsets,
  );
  object.standardOverwrite = reader.readObjectOrNull<StandardOverwriteEmbedded>(
    offsets[1],
    StandardOverwriteEmbeddedSchema.deserialize,
    allOffsets,
  );
  object.type =
      _OverwriteEmbeddedtypeValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      OverwriteType.standard;
  return object;
}

P _overwriteEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<ScriptOverwriteEmbedded>(
            offset,
            ScriptOverwriteEmbeddedSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 1:
      return (reader.readObjectOrNull<StandardOverwriteEmbedded>(
            offset,
            StandardOverwriteEmbeddedSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 2:
      return (_OverwriteEmbeddedtypeValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              OverwriteType.standard)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _OverwriteEmbeddedtypeEnumValueMap = {
  r'standard': r'standard',
  r'script': r'script',
  r'custom': r'custom',
};
const _OverwriteEmbeddedtypeValueEnumMap = {
  r'standard': OverwriteType.standard,
  r'script': OverwriteType.script,
  r'custom': OverwriteType.custom,
};

extension OverwriteEmbeddedQueryFilter
    on QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QFilterCondition> {
  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  scriptOverwriteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'scriptOverwrite'),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  scriptOverwriteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'scriptOverwrite'),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  standardOverwriteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'standardOverwrite'),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  standardOverwriteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'standardOverwrite'),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeEqualTo(OverwriteType value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeGreaterThan(
    OverwriteType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeLessThan(
    OverwriteType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeBetween(
    OverwriteType lower,
    OverwriteType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension OverwriteEmbeddedQueryObject
    on QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QFilterCondition> {
  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  scriptOverwrite(FilterQuery<ScriptOverwriteEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'scriptOverwrite');
    });
  }

  QueryBuilder<OverwriteEmbedded, OverwriteEmbedded, QAfterFilterCondition>
  standardOverwrite(FilterQuery<StandardOverwriteEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'standardOverwrite');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SubscriptionInfoEmbeddedSchema = Schema(
  name: r'SubscriptionInfoEmbedded',
  id: -6285878164182475669,
  properties: {
    r'download': PropertySchema(id: 0, name: r'download', type: IsarType.long),
    r'expire': PropertySchema(id: 1, name: r'expire', type: IsarType.long),
    r'total': PropertySchema(id: 2, name: r'total', type: IsarType.long),
    r'upload': PropertySchema(id: 3, name: r'upload', type: IsarType.long),
  },

  estimateSize: _subscriptionInfoEmbeddedEstimateSize,
  serialize: _subscriptionInfoEmbeddedSerialize,
  deserialize: _subscriptionInfoEmbeddedDeserialize,
  deserializeProp: _subscriptionInfoEmbeddedDeserializeProp,
);

int _subscriptionInfoEmbeddedEstimateSize(
  SubscriptionInfoEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _subscriptionInfoEmbeddedSerialize(
  SubscriptionInfoEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.download);
  writer.writeLong(offsets[1], object.expire);
  writer.writeLong(offsets[2], object.total);
  writer.writeLong(offsets[3], object.upload);
}

SubscriptionInfoEmbedded _subscriptionInfoEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubscriptionInfoEmbedded();
  object.download = reader.readLong(offsets[0]);
  object.expire = reader.readLong(offsets[1]);
  object.total = reader.readLong(offsets[2]);
  object.upload = reader.readLong(offsets[3]);
  return object;
}

P _subscriptionInfoEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SubscriptionInfoEmbeddedQueryFilter
    on
        QueryBuilder<
          SubscriptionInfoEmbedded,
          SubscriptionInfoEmbedded,
          QFilterCondition
        > {
  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  downloadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'download', value: value),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  downloadGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'download',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  downloadLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'download',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  downloadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'download',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  expireEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expire', value: value),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  expireGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expire',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  expireLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expire',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  expireBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expire',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  totalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'total', value: value),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  totalGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'total',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  totalLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'total',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  totalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'total',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  uploadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'upload', value: value),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  uploadGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'upload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  uploadLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'upload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SubscriptionInfoEmbedded,
    SubscriptionInfoEmbedded,
    QAfterFilterCondition
  >
  uploadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'upload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SubscriptionInfoEmbeddedQueryObject
    on
        QueryBuilder<
          SubscriptionInfoEmbedded,
          SubscriptionInfoEmbedded,
          QFilterCondition
        > {}
