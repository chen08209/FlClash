import 'iterable.dart';

typedef ValueCallback<T> = T Function();

class FixedList<T> {
  final int maxLength;
  final List<T> _list;

  FixedList(this.maxLength, {List<T>? list})
      : _list = (list ?? [])..truncate(maxLength);

  void add(T item) {
    _list.add(item);
    _list.truncate(maxLength);
  }

  void clear() {
    _list.clear();
  }

  List<T> get list => List.unmodifiable(_list);

  int get length => _list.length;

  T operator [](int index) => _list[index];

  FixedList<T> copyWith() {
    return FixedList(
      maxLength,
      list: _list,
    );
  }
}

class FixedMap<K, V> {
  int maxLength;
  late Map<K, V> _map;

  FixedMap(this.maxLength, {Map<K, V>? map}) {
    _map = map ?? {};
  }

  V updateCacheValue(K key, ValueCallback<V> callback) {
    final realValue = _map.updateCacheValue(
      key,
      callback,
    );
    _adjustMap();
    return realValue;
  }

  void clear() {
    _map.clear();
  }

  void updateMaxLength(int size) {
    maxLength = size;
    _adjustMap();
  }

  void updateMap(Map<K, V> map) {
    _map = map;
    _adjustMap();
  }

  void _adjustMap() {
    if (_map.length > maxLength) {
      _map = Map.fromEntries(
        map.entries.toList()..truncate(maxLength),
      );
    }
  }

  V? get(K key) => _map[key];

  bool containsKey(K key) => _map.containsKey(key);

  int get length => _map.length;

  Map<K, V> get map => Map.unmodifiable(_map);
}
