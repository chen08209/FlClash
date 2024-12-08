import 'dart:async';

class Debouncer {
  Map<dynamic, Timer> operators = {};

  call(
    dynamic tag,
    Function func, {
    List<dynamic>? args,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    final timer = operators[tag];
    if (timer != null) {
      timer.cancel();
    }
    operators[tag] = Timer(
      duration,
      () {
        operators.remove(tag);
        Function.apply(
          func,
          args,
        );
      },
    );
  }

  cancel(dynamic tag) {
    operators[tag]?.cancel();
  }
}

final debouncer = Debouncer();
