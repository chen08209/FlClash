import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

class Debouncer {
  final Map<FunctionTag, Timer?> _operations = {};

  void call(
    FunctionTag tag,
    Function func, {
    List<dynamic>? args,
    Duration? duration,
  }) {
    final timer = _operations[tag];
    if (timer != null) {
      timer.cancel();
    }
    _operations[tag] = Timer(duration ?? const Duration(milliseconds: 600), () {
      _operations[tag]?.cancel();
      _operations.remove(tag);
      Function.apply(func, args);
    });
  }

  void cancel(dynamic tag) {
    _operations[tag]?.cancel();
    _operations[tag] = null;
  }
}

class Throttler {
  final Map<FunctionTag, Timer?> _operations = {};

  bool call(
    FunctionTag tag,
    Function func, {
    List<dynamic>? args,
    Duration duration = const Duration(milliseconds: 600),
    bool fire = false,
  }) {
    final timer = _operations[tag];
    if (timer != null) {
      return true;
    }
    if (fire) {
      Function.apply(func, args);
      _operations[tag] = Timer(duration, () {
        _operations[tag]?.cancel();
        _operations.remove(tag);
      });
    } else {
      _operations[tag] = Timer(duration, () {
        Function.apply(func, args);
        _operations[tag]?.cancel();
        _operations.remove(tag);
      });
    }
    return false;
  }

  void cancel(dynamic tag) {
    _operations[tag]?.cancel();
    _operations[tag] = null;
  }
}

Future<T> retry<T>({
  required Future<T> Function() task,
  int maxAttempts = 3,
  required bool Function(T res) retryIf,
  Duration delay = midDuration,
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    final res = await task();
    if (!retryIf(res) || attempts >= maxAttempts) {
      return res;
    }
    attempts++;
  }
  throw 'retry error';
}

final debouncer = Debouncer();

final throttler = Throttler();
