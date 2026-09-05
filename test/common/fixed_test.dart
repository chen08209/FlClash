import 'package:fl_clash/common/fixed.dart';
import 'package:test/test.dart';

void main() {
  group('FixedList', () {
    test('rejects an uncapped list', () {
      expect(() => FixedList<int>(0), throwsA(isA<AssertionError>()));
    });

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

    test('list caches the snapshot until the next mutation', () {
      final list = FixedList(3, list: [1, 2]);
      expect(identical(list.list, list.list), isTrue);
      list.add(3);
      expect(list.list, [1, 2, 3]);
    });

    test('append yields a new generation over the same buffer', () {
      final first = FixedList(3, list: [1, 2]);
      final second = first.append(3);
      expect(second.list, [1, 2, 3]);
      expect(second.revision, first.revision + 1);
    });

    test('append makes the wrapper unequal so listeners are notified', () {
      final first = FixedList(3, list: [1, 2]);
      expect(first == first.copyWith(), isFalse, reason: 'distinct buffers');
      expect(first == first.append(3), isFalse, reason: 'distinct generations');
    });

    test('a snapshot taken before append is unaffected by it', () {
      final first = FixedList(3, list: [1, 2]);
      final before = first.list;
      first.append(3);
      expect(before, [1, 2]);
    });

    test('append still honours maxLength', () {
      var list = FixedList<int>(2);
      for (var i = 1; i <= 4; i++) {
        list = list.append(i);
      }
      expect(list.list, [3, 4]);
    });
  });

  group('retainTrimmedHead', () {
    final items = List.generate(6, (i) => Object());

    test('passes latest through when nothing was trimmed', () {
      final current = items.sublist(0, 3);
      final latest = items.sublist(0, 5);
      expect(retainTrimmedHead(current, latest, 10), same(latest));
      expect(retainTrimmedHead(<Object>[], latest, 10), same(latest));
    });

    test('restores entries trimmed off the front', () {
      final current = items.sublist(0, 4);
      final latest = items.sublist(2, 6);
      expect(retainTrimmedHead(current, latest, 10), items);
    });

    test('keeps everything current when latest is entirely newer', () {
      final current = items.sublist(0, 2);
      final latest = items.sublist(4, 6);
      expect(retainTrimmedHead(current, latest, 10), [...current, ...latest]);
    });

    test('caps growth from the tail', () {
      final current = items.sublist(0, 4);
      final latest = items.sublist(2, 6);
      expect(retainTrimmedHead(current, latest, 5), items.sublist(0, 5));
    });
  });
}
