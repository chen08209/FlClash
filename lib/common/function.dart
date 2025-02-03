import 'dart:async';

class Debouncer {
  final Map<dynamic, Timer> _operations = {};

  call(
    dynamic tag,
    Function func, {
    List<dynamic>? args,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    final timer = _operations[tag];
    if (timer != null) {
      timer.cancel();
    }
    _operations[tag] = Timer(
      duration,
      () {
        _operations[tag]?.cancel();
        _operations.remove(tag);
        Function.apply(
          func,
          args,
        );
      },
    );
  }

  cancel(dynamic tag) {
    _operations[tag]?.cancel();
  }
}

class Throttler {
  final Map<dynamic, Timer> _operations = {};

  call(
    String tag,
    Function func, {
    List<dynamic>? args,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    final timer = _operations[tag];
    if (timer != null) {
      return true;
    }
    _operations[tag] = Timer(
      duration,
      () {
        _operations[tag]?.cancel();
        _operations.remove(tag);
        Function.apply(
          func,
          args,
        );
      },
    );
    return false;
  }

  cancel(dynamic tag) {
    _operations[tag]?.cancel();
  }
}


final debouncer = Debouncer();

final throttler = Throttler();