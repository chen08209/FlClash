import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/file.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

const _defaultPrefix = 'flutter.';

/// Stands in for the Windows and Linux stores, which truncate the file before
/// writing it (flutter/flutter#89211): same file and format, but each save
/// replaces it with a flushed sibling.
class AtomicFilePreferencesStore extends SharedPreferencesStorePlatform {
  AtomicFilePreferencesStore(this._path);

  final Future<String> _path;
  Future<Map<String, Object>>? _values;
  Future<bool> _lastWrite = Future.value(true);

  Future<Map<String, Object>> _read() {
    return _values ??= _load().catchError((Object error, StackTrace stack) {
      _values = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<Map<String, Object>> _load() async {
    final file = File(await _path);
    if (!await file.exists()) {
      return {};
    }
    final content = await file.readAsString();
    if (content.isEmpty) {
      return {};
    }
    final data = json.decode(content);
    return data is Map ? Map<String, Object>.from(data) : {};
  }

  Future<bool> _update(void Function(Map<String, Object> values) change) async {
    final values = await _read();
    change(values);
    final content = json.encode(values);
    return _lastWrite = _lastWrite.then((_) => _write(content));
  }

  Future<bool> _write(String content) async {
    final file = File(await _path);
    try {
      await file.writeAsStringAtomically(content);
      return true;
    } catch (error) {
      commonPrint.log(
        'Save preferences failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  @override
  Future<Map<String, Object>> getAll() {
    return getAllWithParameters(
      GetAllParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),
    );
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    final filter = parameters.filter;
    final values = await _read();
    return {
      for (final entry in values.entries)
        if (_matches(filter, entry.key)) entry.key: entry.value,
    };
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    return _update((values) => values[key] = value);
  }

  @override
  Future<bool> remove(String key) {
    return _update((values) => values.remove(key));
  }

  @override
  Future<bool> clear() {
    return clearWithParameters(
      ClearParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),
    );
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) {
    return _update(
      (values) =>
          values.removeWhere((key, _) => _matches(parameters.filter, key)),
    );
  }

  bool _matches(PreferencesFilter filter, String key) {
    return key.startsWith(filter.prefix) &&
        (filter.allowList?.contains(key) ?? true);
  }
}
