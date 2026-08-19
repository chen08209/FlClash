import 'package:fl_clash/common/fixed.dart';
import 'package:test/test.dart';

void main() {
  group('FixedList', () {
    test('respects maxLength on creation', () {
      final list = FixedList(3, list: [1, 2, 3, 4, 5]);
      expect(list.length, 3);
      expect(list.list, [3, 4, 5]);
    });

    test('truncates when adding beyond maxLength', () {
      final list = FixedList(3);
      list.add(1);
      list.add(2);
      list.add(3);
      list.add(4);
      expect(list.list, [2, 3, 4]);
    });

    test('clear empties the list', () {
      final list = FixedList(3, list: [1, 2, 3]);
      list.clear();
      expect(list.length, 0);
      expect(list.list, isEmpty);
    });

    test('copyWith creates independent copy', () {
      final original = FixedList(3, list: [1, 2, 3]);
      final copy = original.copyWith();
      copy.add(4);
      expect(original.list, [1, 2, 3]);
      expect(copy.list, [2, 3, 4]);
    });

    test('notifyClone shares storage but has new identity', () {
      final original = FixedList(3, list: [1, 2]);
      final clone = original.notifyClone();
      expect(identical(original, clone), isFalse);
      original.add(3);
      expect(clone.list, [1, 2, 3]);
      clone.add(4);
      expect(original.list, [2, 3, 4]);
    });

    test('operator [] returns correct element', () {
      final list = FixedList(5, list: [10, 20, 30]);
      expect(list[0], 10);
      expect(list[2], 30);
    });

    test('list getter returns unmodifiable view', () {
      final list = FixedList(3, list: [1, 2, 3]);
      final view = list.list;
      expect(() => view.add(4), throwsA(isA<UnsupportedError>()));
    });
  });

  group('FixedMap', () {
    test('stores and retrieves values', () {
      final map = FixedMap<String, int>(5);
      map.updateCacheValue('a', () => 1);
      map.updateCacheValue('b', () => 2);
      expect(map.get('a'), 1);
      expect(map.get('b'), 2);
    });

    test('returns existing value without calling callback', () {
      final map = FixedMap<String, int>(5);
      map.updateCacheValue('a', () => 1);
      var called = false;
      final result = map.updateCacheValue('a', () {
        called = true;
        return 2;
      });
      expect(result, 1);
      expect(called, isFalse);
    });

    test('truncates when exceeding maxLength', () {
      final map = FixedMap<int, int>(3);
      map.updateCacheValue(1, () => 10);
      map.updateCacheValue(2, () => 20);
      map.updateCacheValue(3, () => 30);
      map.updateCacheValue(4, () => 40);
      expect(map.length, 3);
      expect(map.containsKey(1), isFalse);
      expect(map.containsKey(4), isTrue);
    });

    test('clear empties the map', () {
      final map = FixedMap<String, int>(3);
      map.updateCacheValue('a', () => 1);
      map.clear();
      expect(map.length, 0);
    });

    test('updateMaxLength truncates existing data', () {
      final map = FixedMap<int, int>(5);
      for (int i = 0; i < 5; i++) {
        map.updateCacheValue(i, () => i * 10);
      }
      map.updateMaxLength(2);
      expect(map.length, 2);
    });

    test('updateMap replaces underlying data', () {
      final map = FixedMap<String, int>(5);
      map.updateCacheValue('a', () => 1);
      map.updateMap({'x': 100, 'y': 200});
      expect(map.get('a'), isNull);
      expect(map.get('x'), 100);
    });

    test('map getter returns unmodifiable view', () {
      final map = FixedMap<String, int>(3);
      map.updateCacheValue('a', () => 1);
      final view = map.map;
      expect(() => view['b'] = 2, throwsA(isA<UnsupportedError>()));
    });

    test('containsKey works correctly', () {
      final map = FixedMap<String, int>(3);
      map.updateCacheValue('a', () => 1);
      expect(map.containsKey('a'), isTrue);
      expect(map.containsKey('b'), isFalse);
    });

    test('get returns null for missing key', () {
      final map = FixedMap<String, int>(3);
      expect(map.get('missing'), isNull);
    });
  });
}
