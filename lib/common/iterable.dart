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
