import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(Function action, List<dynamic> positionalArguments, [Map<Symbol, dynamic>? namedArguments]) {
    _timer?.cancel();
    _timer = Timer(delay, () => Function.apply(action, positionalArguments, namedArguments));
  }
}

Function debounce<F extends Function>(F func,{int milliseconds = 600}) {
  Timer? timer;

  return ([List<dynamic>? args, Map<Symbol, dynamic>? namedArgs]) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: milliseconds), () async {
      await Function.apply(func, args ?? [], namedArgs);
    });
  };
}