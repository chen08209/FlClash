import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:flutter_js/flutter_js.dart';

Future<Map<String, dynamic>> handleEvaluate(
  String scriptContent,
  Map<String, dynamic> config,
) async {
  if (config['proxy-providers'] == null) {
    config['proxy-providers'] = {};
  }
  final configJs = json.encode(config);
  final runtime = getJavascriptRuntime();
  try {
    final res = await runtime.evaluateAsync('''
      $scriptContent
      main($configJs)
    ''');
    if (res.isError) {
      throw res.stringResult;
    }
    final value = switch (res.rawResult is ffi.Pointer) {
      true => runtime.convertValue<Map<String, dynamic>>(res),
      false => Map<String, dynamic>.from(res.rawResult),
    };
    return value ?? config;
  } finally {
    runtime.dispose();
  }
}
