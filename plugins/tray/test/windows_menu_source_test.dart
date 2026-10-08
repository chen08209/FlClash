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

String _body(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: signature);
  final end = source.indexOf('\n}\n', start);
  return source.substring(start, end);
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

  test('windows puts the detail in the accelerator column', () {
    expect(pluginSource, contains('StringAt(*entry, "detail")'));
    expect(pluginSource, contains("text += L'\\t';"));
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
    final show = _body(pluginSource, 'bool TrayPlugin::Show(');
    final lastRejection = show.lastIndexOf('return false;');
    final rebuild = show.indexOf('RebuildMenu(menu_, *items);');

    expect(lastRejection, isNonNegative);
    expect(rebuild, greaterThan(lastRejection));
  });

  test('windows retries an icon the shell refused at sign-in', () {
    final show = _body(pluginSource, 'bool TrayPlugin::Show(');

    expect(show, contains('ScheduleRestore();'));
    expect(show.trimRight(), endsWith('return true;'));
    expect(
      _body(pluginSource, 'void TrayPlugin::RestoreIcon('),
      contains('ApplyIcon(false) || ApplyIcon(true)'),
    );
    expect(pluginSource, contains('message == WM_TIMER'));
  });

  test('windows hide deletes an icon whose add may have landed', () {
    final hide = _body(pluginSource, 'void TrayPlugin::Hide(');

    expect(
      hide,
      contains('''
  if (icon_requested_) {
    ::Shell_NotifyIconW(NIM_DELETE, &icon_data_);
  }'''),
    );
    expect(
      hide.indexOf('icon_requested_ = false;'),
      greaterThan(hide.indexOf('NIM_DELETE')),
    );
  });
}
