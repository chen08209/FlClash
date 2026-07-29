import 'dart:async';

extension IterableExt<E> on Iterable<E> {
  Iterable<E> separated(E separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    yield iterator.current;

    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  Iterable<List<E>> chunks(int size) sync* {
    if (length == 0) return;
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = [iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }

  Iterable<E> fill(int length, {required E Function(int count) filler}) sync* {
    int count = 0;
    for (final item in this) {
      yield item;
      count++;
      if (count >= length) return;
    }
    while (count < length) {
      yield filler(count);
      count++;
    }
  }

  Iterable<E> takeLast({int count = 50}) {
    if (count <= 0) return Iterable.empty();
    return count >= length ? this : toList().skip(length - count);
  }

  Future<void> forEachConcurrent(
    FutureOr<void> Function(E item) action, {
    int concurrency = 8,
  }) async {
    final items = toList(growable: false);
    if (items.isEmpty) return;
    final workerCount = concurrency.clamp(1, items.length).toInt();
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex;
        if (index >= items.length) return;
        nextIndex = index + 1;
        await action(items[index]);
      }
    }

    await Future.wait([for (var i = 0; i < workerCount; i++) worker()]);
  }
}

extension ListExt<T> on List<T> {
  void truncate(int maxLength) {
    if (maxLength == 0) {
      return;
    }
    if (length > maxLength) {
      removeRange(0, length - maxLength);
    }
  }

  List<T> intersection(List<T> list) {
    return where((item) => list.contains(item)).toList();
  }

  List<List<T>> batch(int maxConcurrent) {
    final batches = (length / maxConcurrent).ceil();
    final List<List<T>> res = [];
    for (int i = 0; i < batches; i++) {
      if (i != batches - 1) {
        res.add(sublist(i * maxConcurrent, maxConcurrent * (i + 1)));
      } else {
        res.add(sublist(i * maxConcurrent, length));
      }
    }
    return res;
  }

  List<T> copyAndPut(T data, bool Function(T element) test) {
    final newList = List<T>.from(this);
    final index = newList.indexWhere(test);
    if (index != -1) {
      newList[index] = data;
    } else {
      newList.insert(0, data);
    }
    return newList;
  }

  List<T> copyAndReorder(int oldIndex, int newIndex) {
    final newList = List<T>.from(this);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    return newList;
  }

  List<T> safeSublist(int start, [int? end]) {
    if (start <= 0) return this;
    if (start > length) return [];
    if (end != null) {
      return sublist(start, end.clamp(start, length));
    }
    return sublist(start);
  }

  T? safeGet(int index, {T? defaultValue}) {
    if (index < 0 || index >= length) {
      return defaultValue;
    }
    return this[index];
  }

  T safeLast(T defaultValue) {
    if (isNotEmpty) {
      return last;
    }
    return defaultValue;
  }

  void addOrRemove(T value) {
    if (contains(value)) {
      remove(value);
    } else {
      add(value);
    }
  }
}

extension SetExt<T> on Set<T> {
  void addOrRemove(T value) {
    if (contains(value)) {
      remove(value);
    } else {
      add(value);
    }
  }
}

extension DoubleListExt on List<double> {
  int findInterval(num target) {
    if (isEmpty) return -1;
    if (target < first) return -1;
    if (target >= last) return length - 1;

    int left = 0;
    int right = length - 1;

    while (left <= right) {
      final int mid = left + (right - left) ~/ 2;

      if (mid == length - 1 ||
          (this[mid] <= target && target < this[mid + 1])) {
        return mid;
      } else if (target < this[mid]) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    return -1;
  }
}

extension MapExt<K, V> on Map<K, V> {
  V updateCacheValue(K key, V Function() callback) {
    if (this[key] == null) {
      this[key] = callback();
    }
    return this[key]!;
  }

  Map<K, V> copyWitUpdate(K key, V? value) {
    final newMap = Map<K, V>.from(this);
    if (value == null) {
      newMap.remove(key);
    } else {
      newMap[key] = value;
    }
    return newMap;
  }
}
