import 'dart:async';

import 'package:fl_clash/common/common.dart';

class Debouncer {
  final Map<dynamic, Timer?> _operations = {};

  void call(
    dynamic tag,
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

class SerialTaskScheduler {
  Future<void> _serialTail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _serialTail = _serialTail.then((_) async {
      try {
        completer.complete(await task());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}

class Throttler {
  final Map<dynamic, Timer?> _operations = {};

  bool call(
    dynamic tag,
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
    attempts++;
    if (!retryIf(res) || attempts >= maxAttempts) {
      return res;
    }
    await Future.delayed(delay);
  }
  throw 'retry error';
}

final debouncer = Debouncer();

final throttler = Throttler();
