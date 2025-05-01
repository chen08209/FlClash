import 'package:flutter_js/flutter_js.dart';

class Javascript {
  static Javascript? _instance;
  late JavascriptRuntime runtime;

  Javascript._internal() {
    runtime = getJavascriptRuntime();
  }

  Future<String> evaluate(String js) async {
    final evaluate = runtime.evaluate(js);
    return evaluate.stringResult;
  }

  factory Javascript() {
    _instance ??= Javascript._internal();
    return _instance!;
  }
}

final js = Javascript();
