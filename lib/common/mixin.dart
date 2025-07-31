import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

mixin AutoDisposeNotifierMixin<T> on AnyNotifier<T, T> {
  set value(T value) {
    if (ref.mounted) {
      state = value;
    } else {
      onUpdate(value);
    }
  }

  @override
  bool updateShouldNotify(previous, next) {
    final res = super.updateShouldNotify(previous, next);
    if (res) {
      onUpdate(next);
    }
    return res;
  }

  void onUpdate(T value) {}
}

mixin AnyNotifierMixin<T> on AnyNotifier<T, T> {
  T get value;

  set value(T value) {
    if (ref.mounted) {
      state = value;
    } else {
      onUpdate(value);
    }
  }

  @override
  bool updateShouldNotify(previous, next) {
    final res = super.updateShouldNotify(previous, next);
    if (res) {
      onUpdate(next);
    }
    return res;
  }

  void onUpdate(T value) {}
}
