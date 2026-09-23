import 'dart:convert';

import 'package:fl_clash/database/database.dart';
import 'package:test/test.dart';

void main() {
  group('StringMapConverter', () {
    const converter = StringMapConverter();

    test('roundtrip encodes and decodes correctly', () {
      final original = {'key1': 'value1', 'key2': 'value2'};
      final encoded = converter.toSql(original);
      final decoded = converter.fromSql(encoded);
      expect(decoded, original);
    });

    test('handles empty map', () {
      final encoded = converter.toSql({});
      final decoded = converter.fromSql(encoded);
      expect(decoded, isEmpty);
    });

    test('handles special characters in values', () {
      final original = {'key': 'value with "quotes" and \\backslash'};
      final encoded = converter.toSql(original);
      final decoded = converter.fromSql(encoded);
      expect(decoded, original);
    });

    test('produces valid JSON string', () {
      final encoded = converter.toSql({'a': 'b'});
      expect(() => json.decode(encoded), returnsNormally);
    });
  });

  group('StringListConverter', () {
    const converter = StringListConverter();

    test('roundtrip encodes and decodes correctly', () {
      final original = ['a', 'b', 'c'];
      final encoded = converter.toSql(original);
      final decoded = converter.fromSql(encoded);
      expect(decoded, original);
    });

    test('handles empty list', () {
      final encoded = converter.toSql([]);
      final decoded = converter.fromSql(encoded);
      expect(decoded, isEmpty);
    });

    test('handles list with duplicates', () {
      final original = ['a', 'a', 'b'];
      final encoded = converter.toSql(original);
      final decoded = converter.fromSql(encoded);
      expect(decoded, original);
    });
  });

  group('StringSetConverter', () {
    const converter = StringSetConverter();

    test('roundtrip encodes and decodes correctly', () {
      final original = {'x', 'y', 'z'};
      final encoded = converter.toSql(original);
      final decoded = converter.fromSql(encoded);
      expect(decoded, original);
    });

    test('handles empty set', () {
      final encoded = converter.toSql(<String>{});
      final decoded = converter.fromSql(encoded);
      expect(decoded, isEmpty);
    });

    test('deduplicates on decode', () {
      final encoded = json.encode(['a', 'a', 'b']);
      final decoded = converter.fromSql(encoded);
      expect(decoded.length, 2);
      expect(decoded, containsAll(['a', 'b']));
    });
  });
}
