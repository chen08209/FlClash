import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:rust_api/rust_api.dart' as rust_api;

import 'print.dart';

@visibleForTesting
Future<List<String>> Function() systemFontFamiliesReader =
    rust_api.systemFontFamilies;

/// The font families the engine resolves by name on this host, sorted for the
/// picker.
Future<List<String>> loadSystemFontFamilies() async {
  try {
    return await systemFontFamiliesReader();
  } catch (e) {
    commonPrint.log('loadSystemFontFamilies: $e', logLevel: LogLevel.warning);
    return const [];
  }
}
