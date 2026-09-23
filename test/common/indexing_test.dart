import 'package:fl_clash/common/indexing.dart';
import 'package:test/test.dart';

void main() {
  final indexing = Indexing();

  group('generateKeyBetween', () {
    test('returns integerZero when both bounds are null', () {
      final key = indexing.generateKeyBetween(null, null);
      expect(key, Indexing.integerZero);
    });

    test('generates key after a when b is null', () {
      const a = 'a0V';
      final key = indexing.generateKeyBetween(a, null);
      expect(key, isNotNull);
      expect(key!.compareTo(a), greaterThan(0));
    });

    test('generates key before b when a is null', () {
      const b = 'a0V';
      final key = indexing.generateKeyBetween(null, b);
      expect(key, isNotNull);
      expect(key!.compareTo(b), lessThan(0));
    });

    test('generates key between two keys', () {
      const a = 'a0V';
      const b = 'a0W';
      final key = indexing.generateKeyBetween(a, b);
      expect(key, isNotNull);
      expect(key!.compareTo(a), greaterThan(0));
      expect(key.compareTo(b), lessThan(0));
    });

    test('throws when a >= b', () {
      expect(
        () => indexing.generateKeyBetween('a0V', 'a0V'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => indexing.generateKeyBetween('a0W', 'a0V'),
        throwsA(isA<Exception>()),
      );
    });

    test('generates multiple distinct keys between same bounds', () {
      final keys = indexing.generateNKeysBetween('a0V', 'a0W', 10);
      final uniqueKeys = keys.whereType<String>().toSet();
      expect(uniqueKeys.length, greaterThan(1));
    });
  });

  group('generateNKeysBetween', () {
    test('returns empty list for n <= 0', () {
      expect(indexing.generateNKeysBetween(null, null, 0), isEmpty);
      expect(indexing.generateNKeysBetween(null, null, -1), isEmpty);
    });

    test('generates n keys between null bounds', () {
      final keys = indexing.generateNKeysBetween(null, null, 5);
      expect(keys.length, 5);
      for (final key in keys) {
        expect(key, isNotNull);
      }
    });

    test('generates n keys between two bounds', () {
      final keys = indexing.generateNKeysBetween('a0V', 'a0W', 3);
      expect(keys.length, 3);
      for (final key in keys) {
        expect(key, isNotNull);
        expect(key!.compareTo('a0V'), greaterThan(0));
        expect(key.compareTo('a0W'), lessThan(0));
      }
    });

    test('generates sorted keys', () {
      final keys = indexing.generateNKeysBetween(null, null, 10);
      final nonNullKeys = keys.whereType<String>().toList();
      for (int i = 1; i < nonNullKeys.length; i++) {
        expect(nonNullKeys[i].compareTo(nonNullKeys[i - 1]), greaterThan(0));
      }
    });
  });

  group('generateNKeys', () {
    test('generates n keys from scratch', () {
      final keys = indexing.generateNKeys(5);
      expect(keys.length, 5);
      for (final key in keys) {
        expect(key, isNotNull);
      }
    });

    test('generates sorted keys', () {
      final keys = indexing.generateNKeys(8);
      final nonNullKeys = keys.whereType<String>().toList();
      for (int i = 1; i < nonNullKeys.length; i++) {
        expect(nonNullKeys[i].compareTo(nonNullKeys[i - 1]), greaterThan(0));
      }
    });
  });
}
