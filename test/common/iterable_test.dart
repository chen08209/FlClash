import 'package:fl_clash/common/iterable.dart';
import 'package:test/test.dart';

void main() {
  group('IterableExt.separated', () {
    test('inserts separator between elements', () {
      final result = [1, 2, 3].separated(0).toList();
      expect(result, [1, 0, 2, 0, 3]);
    });

    test('returns single element without separator', () {
      final result = [1].separated(0).toList();
      expect(result, [1]);
    });

    test('returns empty for empty iterable', () {
      final result = <int>[].separated(0).toList();
      expect(result, isEmpty);
    });
  });

  group('IterableExt.chunks', () {
    test('splits into equal chunks', () {
      final result = [1, 2, 3, 4].chunks(2).toList();
      expect(result, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('handles last incomplete chunk', () {
      final result = [1, 2, 3, 4, 5].chunks(2).toList();
      expect(result, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('returns single chunk for size >= length', () {
      final result = [1, 2, 3].chunks(5).toList();
      expect(result, [
        [1, 2, 3],
      ]);
    });

    test('returns empty for empty iterable', () {
      final result = <int>[].chunks(2).toList();
      expect(result, isEmpty);
    });
  });

  group('IterableExt.fill', () {
    test('pads with filler when shorter', () {
      final result = [1, 2].fill(5, filler: (i) => 0).toList();
      expect(result, [1, 2, 0, 0, 0]);
    });

    test('truncates when longer', () {
      final result = [1, 2, 3, 4].fill(2, filler: (i) => 0).toList();
      expect(result, [1, 2]);
    });

    test('provides index to filler', () {
      final result = [].fill(3, filler: (i) => i * 10).toList();
      expect(result, [0, 10, 20]);
    });
  });

  group('ListExt.truncate', () {
    test('removes from beginning when over max', () {
      final list = [1, 2, 3, 4, 5];
      list.truncate(3);
      expect(list, [3, 4, 5]);
    });

    test('does nothing when within max', () {
      final list = [1, 2, 3];
      list.truncate(5);
      expect(list, [1, 2, 3]);
    });

    test('does nothing when maxLength is 0', () {
      final list = [1, 2, 3];
      list.truncate(0);
      expect(list, [1, 2, 3]);
    });
  });

  group('ListExt.batch', () {
    test('splits into batches', () {
      final result = [1, 2, 3, 4, 5].batch(2);
      expect(result, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('single batch when size >= length', () {
      final result = [1, 2].batch(5);
      expect(result, [
        [1, 2],
      ]);
    });
  });

  group('ListExt.copyAndPut', () {
    test('replaces matching element', () {
      final result = [1, 2, 3].copyAndPut(99, (e) => e == 2);
      expect(result, [1, 99, 3]);
    });

    test('inserts at beginning when no match', () {
      final result = [1, 2, 3].copyAndPut(99, (e) => e == 5);
      expect(result, [99, 1, 2, 3]);
    });
  });

  group('ListExt.copyAndReorder', () {
    test('uses final insertion index when moving an item forward', () {
      final result = ['a', 'b', 'c', 'd'].copyAndReorder(1, 3);

      expect(result, ['a', 'c', 'd', 'b']);
    });

    test('uses final insertion index when moving an item backward', () {
      final result = ['a', 'b', 'c', 'd'].copyAndReorder(3, 1);

      expect(result, ['a', 'd', 'b', 'c']);
    });

    test('does not mutate original list', () {
      final list = ['a', 'b', 'c'];
      final result = list.copyAndReorder(0, 2);

      expect(list, ['a', 'b', 'c']);
      expect(result, ['b', 'c', 'a']);
    });
  });

  group('ListExt.safeGet', () {
    test('returns element at valid index', () {
      expect([10, 20, 30].safeGet(1), 20);
    });

    test('returns defaultValue for out of bounds', () {
      expect([10, 20].safeGet(5, defaultValue: -1), -1);
    });

    test('returns null for out of bounds without default', () {
      expect([10, 20].safeGet(5), isNull);
    });
  });

  group('ListExt.safeLast', () {
    test('returns last element', () {
      expect([1, 2, 3].safeLast(0), 3);
    });

    test('returns default for empty list', () {
      expect(<int>[].safeLast(0), 0);
    });
  });

  group('ListExt.addOrRemove', () {
    test('adds when not present', () {
      final list = [1, 2, 3];
      list.addOrRemove(4);
      expect(list, [1, 2, 3, 4]);
    });

    test('removes when present', () {
      final list = [1, 2, 3];
      list.addOrRemove(2);
      expect(list, [1, 3]);
    });
  });

  group('SetExt.addOrRemove', () {
    test('adds when not present', () {
      final set = {1, 2, 3};
      set.addOrRemove(4);
      expect(set, {1, 2, 3, 4});
    });

    test('removes when present', () {
      final set = {1, 2, 3};
      set.addOrRemove(2);
      expect(set, {1, 3});
    });
  });

  group('MapExt.updateCacheValue', () {
    test('creates entry when missing', () {
      final map = <String, int>{};
      final result = map.updateCacheValue('a', () => 42);
      expect(result, 42);
      expect(map['a'], 42);
    });

    test('returns existing entry', () {
      final map = {'a': 10};
      final result = map.updateCacheValue('a', () => 42);
      expect(result, 10);
    });
  });
}
