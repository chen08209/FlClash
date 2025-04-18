extension IterableExt<T> on Iterable<T> {
  Iterable<T> separated(T separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    yield iterator.current;

    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  Iterable<List<T>> chunks(int size) sync* {
    if (length == 0) return;
    var iterator = this.iterator;
    while (iterator.moveNext()) {
      var chunk = [iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }

  Iterable<T> fill(
    int length, {
    required T Function(int count) filler,
  }) sync* {
    int count = 0;
    for (var item in this) {
      yield item;
      count++;
      if (count >= length) return;
    }
    while (count < length) {
      yield filler(count);
      count++;
    }
  }

  Iterable<T> takeLast({int count = 50}) {
    if (count <= 0) return Iterable.empty();
    return count >= length ? this : toList().skip(length - count);
  }
}

extension ListExt<T> on List<T> {
  void truncate(int maxLength) {
    assert(maxLength > 0);
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

  List<T> safeSublist(int start) {
    if (start <= 0) return this;
    if (start > length) return [];
    return sublist(start);
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
      int mid = left + (right - left) ~/ 2;

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
  updateCacheValue(K key, V Function() callback) {
    if (this[key] == null) {
      this[key] = callback();
    }
    return this[key];
  }
}
