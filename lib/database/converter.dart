part of 'database.dart';

class RuleActionConverter extends TypeConverter<RuleAction, String>
    with JsonTypeConverter<RuleAction, String> {
  const RuleActionConverter();

  @override
  RuleAction fromSql(String fromDb) {
    return RuleAction.values.firstWhere(
      (action) => action.name == fromDb || action.value == fromDb,
      orElse: () => throw ArgumentError.value(fromDb, 'fromDb'),
    );
  }

  @override
  String toSql(RuleAction value) {
    return value.name;
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

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return List<String>.from(json.decode(fromDb));
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value.toList());
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
