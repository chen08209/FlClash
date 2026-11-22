import 'dart:typed_data';

/// A hash of each rule's type and payload, all a rule place is checked by,
/// since a profile can inline tens of thousands of rules.
class RuleTable {
  final Int64List _hashes;

  const RuleTable._(this._hashes);

  static RuleTable fromJson(Object? result) {
    final rules = (result as Map)['rules'] as List;
    final hashes = Int64List(rules.length);
    for (var index = 0; index < rules.length; index++) {
      final rule = rules[index] as Map;
      hashes[index] = _hashOf(
        rule['type'] as String,
        rule['payload'] as String,
      );
    }
    return RuleTable._(hashes);
  }

  factory RuleTable.of(Iterable<({String type, String payload})> rules) =>
      RuleTable._(
        Int64List.fromList([
          for (final rule in rules) _hashOf(rule.type, rule.payload),
        ]),
      );

  int get length => _hashes.length;

  bool holds(int index, {required String type, required String payload}) =>
      index >= 0 &&
      index < _hashes.length &&
      _hashes[index] == _hashOf(type, payload);

  static int _hashOf(String type, String payload) {
    var hash = _fnvOffset;
    for (final unit in type.codeUnits) {
      hash = (hash ^ unit) * _fnvPrime;
    }
    hash *= _fnvPrime;
    for (final unit in payload.codeUnits) {
      hash = (hash ^ unit) * _fnvPrime;
    }
    return hash;
  }
}

const _fnvOffset = 0xcbf29ce484222325;
const _fnvPrime = 0x100000001b3;
