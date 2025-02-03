import 'dart:collection';

class FixedList<T> {
  final int maxLength;
  final List<T> _list = [];

  FixedList(this.maxLength);

  add(T item) {
    if (_list.length == maxLength) {
      _list.removeAt(0);
    }
    _list.add(item);
  }

  List<T> get list => List.unmodifiable(_list);

  int get length => _list.length;

  T operator [](int index) => _list[index];
}

class FixedMap<K, V> {
  final int maxSize;
  final Map<K, V> _map = {};
  final Queue<K> _queue = Queue<K>();

  FixedMap(this.maxSize);

  put(K key, V value) {
    if (_map.length == maxSize) {
      final oldestKey = _queue.removeFirst();
      _map.remove(oldestKey);
    }
    _map[key] = value;
    _queue.add(key);
  }

  clear(){
    _map.clear();
    _queue.clear();
  }

  V? get(K key) => _map[key];

  bool containsKey(K key) => _map.containsKey(key);

  int get length => _map.length;

  Map<K, V> get map => Map.unmodifiable(_map);
}

extension ListExtension<T> on List<T> {
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
