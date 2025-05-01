import 'package:flutter_js/flutter_js.dart';

class Javascript {
  static Javascript? _instance;

  Javascript._internal();

  JavascriptRuntime get runTime {
    return getJavascriptRuntime();
  }

  factory Javascript() {
    _instance ??= Javascript._internal();
    return _instance!;
  }
}

final js = Javascript();
