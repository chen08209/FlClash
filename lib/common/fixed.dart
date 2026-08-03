import 'iterable.dart';

class FixedList<T> {
  final int maxLength;
  final List<T> _list;

  final int _revision;
  List<T>? _snapshot;

  FixedList(this.maxLength, {List<T>? list})
    : assert(maxLength > 0, 'FixedList without a cap grows without bound'),
      _list = (list ?? [])..truncate(maxLength),
      _revision = 0;

  FixedList._(this.maxLength, this._list, this._revision);

  int get revision => _revision;

  FixedList._shared(this.maxLength, this._list);

  void add(T item) {
    _list.add(item);
    _list.truncate(maxLength);
    _snapshot = null;
  }

  void clear() {
    _list.clear();
    _snapshot = null;
  }

  FixedList<T> append(T item) {
    add(item);
    return FixedList._(maxLength, _list, _revision + 1);
  }

  List<T> get list => _snapshot ??= List.unmodifiable(_list);

  int get length => _list.length;

  T operator [](int index) => _list[index];

  /// New FixedList identity over the same backing storage.
  /// Used so Riverpod can notify without copying every element.
  FixedList<T> notifyClone() => FixedList._shared(maxLength, _list);

  FixedList<T> copyWith() {
    return FixedList(maxLength, list: List.of(_list));
  }

  @override
  bool operator ==(Object other) =>
      other is FixedList<T> &&
      identical(other._list, _list) &&
      other._revision == _revision;

  @override
  int get hashCode => Object.hash(identityHashCode(_list), _revision);
}
