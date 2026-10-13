import 'package:fl_clash/common/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backs [preferences] with a fresh in-memory store holding [values].
Future<void> mockPreferences([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return preferences.rebind();
}
