import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _resolveSource(String relativePath) {
  final direct = File(relativePath);
  if (direct.existsSync()) {
    return direct;
  }
  final inPlugin = File('plugins/tray/$relativePath');
  if (inPlugin.existsSync()) {
    return inPlugin;
  }
  return direct;
}

void main() {
  late String pluginSource;

  setUpAll(() {
    pluginSource = _resolveSource('windows/tray_plugin.cpp').readAsStringSync();
  });

  test('windows menu clicks come from TrackPopupMenu, not WM_COMMAND', () {
    expect(pluginSource, contains('TPM_RETURNCMD'));
    expect(pluginSource, isNot(contains('WM_COMMAND')));
  });

  test('windows show reports a failed icon load', () {
    expect(
      pluginSource,
      contains('''
  if (loaded == nullptr) {
    return false;
  }'''),
    );
  });

  test('windows rejected show leaves the visible menu untouched', () {
    expect(pluginSource, contains('bool applied = ApplyIcon(!visible_);'));
    expect(
      pluginSource,
      contains('''
  if (!applied) {
    return false;
  }
  visible_ = true;

  const flutter::EncodableList* items'''),
    );
  });
}
