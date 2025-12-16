import 'dart:async';

class Store<T> {
  late T _data;

  Store(Stream stream, T defaultValue) {
    stream.listen((data) {
      _add(data);
    });
    _data = defaultValue;
  }

  bool equals(T oldValue, T newValue) {
    return oldValue == newValue;
  }

  void _add(T value) {
    if (!equals(_data, value)) {
      _streamController.add(value);
      _data = value;
    }
  }

  final StreamController<T> _streamController = StreamController<T>.broadcast();

  Stream<T> get stream => _streamController.stream;

  T get value => _data;

  set value(T value) {
    _add(value);
  }
}
