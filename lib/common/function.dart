import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';

void _applyAndReport(dynamic tag, Function func, List<dynamic>? args) {
  void report(Object error, StackTrace stackTrace) {
    commonPrint.log(
      'Scheduled task $tag failed: ${compactError(error)}, $stackTrace',
      logLevel: LogLevel.warning,
    );
  }

  try {
    final result = Function.apply(func, args);
    if (result is Future) {
      result.then<void>((_) {}, onError: report);
    }
  } catch (error, stackTrace) {
    report(error, stackTrace);
  }
}

class Debouncer {
  final Map<dynamic, Timer?> _operations = {};
  final Map<dynamic, ({Function func, List<dynamic>? args})> _pending = {};

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
    _pending[tag] = (func: func, args: args);
    _operations[tag] = Timer(duration ?? const Duration(milliseconds: 600), () {
      _operations[tag]?.cancel();
      _operations.remove(tag);
      final pending = _pending.remove(tag);
      if (pending == null) {
        return;
      }
      _applyAndReport(tag, pending.func, pending.args);
    });
  }

  void flush(dynamic tag) {
    final timer = _operations.remove(tag);
    timer?.cancel();
    final pending = _pending.remove(tag);
    if (timer == null || pending == null) {
      return;
    }
    _applyAndReport(tag, pending.func, pending.args);
  }

  void cancel(dynamic tag) {
    _operations[tag]?.cancel();
    _operations[tag] = null;
    _pending.remove(tag);
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
      _applyAndReport(tag, func, args);
      _operations[tag] = Timer(duration, () {
        _operations[tag]?.cancel();
        _operations.remove(tag);
      });
    } else {
      _operations[tag] = Timer(duration, () {
        _applyAndReport(tag, func, args);
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
  throw TimeoutException('retry gave up after $maxAttempts attempts');
}

final debouncer = Debouncer();

final throttler = Throttler();

FutureOr<T> handleWatch<T>({
  required Function function,
  required void Function() onStart,
  required void Function(T data, int elapsedMilliseconds) onEnd,
}) async {
  if (kDebugMode && watchExecution) {
    onStart();
    final stopwatch = Stopwatch()..start();
    final res = await function();
    stopwatch.stop();
    onEnd(res, stopwatch.elapsedMilliseconds);
    return res;
  }
  return await function();
}
