import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'file.dart';
import 'path.dart';
import 'print.dart';

const _legacyKeyPrefix = 'flutter.';

abstract class _PreferencesStore {
  Future<Map<String, Object?>?> load();
  Future<bool> save(Map<String, Object?> data);
}

class _FileStore implements _PreferencesStore {
  final String? pathOverride;

  _FileStore({this.pathOverride});

  Future<String> _resolvePath() async =>
      pathOverride ?? await appPath.sharedPreferencesPath;

  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final file = File(await _resolvePath());
      final Map<String, Object?> data = {};
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is! Map) {
            throw const FormatException('Preferences file is not a JSON map');
          }
          for (final MapEntry(:key, :value) in decoded.entries) {
            data[key.startsWith(_legacyKeyPrefix)
                ? key.substring(_legacyKeyPrefix.length)
                : key] = value;
          }
        }
      }
      return data;
    } catch (e) {
      commonPrint.log(
        'Failed to load preferences: $e',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  @override
  Future<bool> save(Map<String, Object?> data) async {
    try {
      final file = File(await _resolvePath());
      await file.safeWriteAsString(jsonEncode(data));
      return true;
    } catch (e) {
      commonPrint.log(
        'Failed to save preferences: $e',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }
}

class _SharedPreferencesStore implements _PreferencesStore {
  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, Object?>{};
      for (final key in prefs.getKeys()) {
        data[key] = prefs.get(key);
      }
      return data;
    } catch (e) {
      commonPrint.log(
        'Failed to load preferences: $e',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  @override
  Future<bool> save(Map<String, Object?> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final results = <Future<bool>>[];
      data.forEach((key, value) {
        results.add(_setSharedPreferencesValue(prefs, key, value));
      });
      return (await Future.wait(results)).every((result) => result);
    } catch (e) {
      commonPrint.log(
        'Failed to save preferences: $e',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }
}

Future<bool> _setSharedPreferencesValue(
  SharedPreferences prefs,
  String key,
  Object? value,
) {
  return switch (value) {
    int() => prefs.setInt(key, value),
    String() => prefs.setString(key, value),
    bool() => prefs.setBool(key, value),
    double() => prefs.setDouble(key, value),
    List<String>() => prefs.setStringList(key, value),
    _ => Future.value(false),
  };
}

class Preferences {
  static Preferences? _instance;
  final _PreferencesStore _store;
  final Completer<Map<String, Object?>?> _preferencesCompleter = Completer();

  Preferences._internal({String? pathOverride})
    : _store = pathOverride != null
          ? _FileStore(pathOverride: pathOverride)
          : Platform.isWindows || Platform.isMacOS || Platform.isLinux
          ? _FileStore()
          : _SharedPreferencesStore() {
    _init();
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  @visibleForTesting
  static Preferences createForTest({String? path}) {
    return Preferences._internal(pathOverride: path);
  }

  Future<Map<String, Object?>?> get _preferences async =>
      _preferencesCompleter.future;

  Future<bool> get isInit async => await _preferences != null;

  Future<void> _init() async {
    try {
      final data = await _store.load();
      _preferencesCompleter.complete(data);
    } catch (e) {
      commonPrint.log(
        'Failed to load preferences: $e',
        logLevel: LogLevel.warning,
      );
      _preferencesCompleter.complete(null);
    }
  }

  Future<bool> _save() async {
    final data = await _preferences;
    if (data == null) return false;
    return _store.save(data);
  }

  Future<int> getVersion() async {
    final preferences = await _preferences;
    return preferences?['version'] as int? ?? 0;
  }

  Future<void> setVersion(int version) async {
    final preferences = await _preferences;
    if (preferences == null) return;
    preferences['version'] = version;
    await _save();
  }

  Future<void> saveShareState(SharedState shareState) async {
    final preferences = await _preferences;
    if (preferences == null) return;
    preferences['sharedState'] = jsonEncode(shareState);
    await _save();
  }

  Future<Map<String, Object?>?> getConfigMap() async {
    try {
      final preferences = await _preferences;
      final configString = preferences?[configKey] as String?;
      if (configString == null) return null;
      final Map<String, Object?>? configMap = jsonDecode(configString);
      return configMap;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, Object?>?> getClashConfigMap() async {
    try {
      final preferences = await _preferences;
      final clashConfigString = preferences?[clashConfigKey] as String?;
      if (clashConfigString == null) return null;
      return jsonDecode(clashConfigString) as Map<String, Object?>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearClashConfig() async {
    try {
      final preferences = await _preferences;
      if (preferences == null) return;
      preferences.remove(clashConfigKey);
      await _save();
    } catch (_) {
      return;
    }
  }

  Future<Config?> getConfig() async {
    final configMap = await getConfigMap();
    if (configMap == null) {
      return null;
    }
    return Config.fromJson(configMap);
  }

  Future<bool> saveConfig(Config config) async {
    final preferences = await _preferences;
    if (preferences == null) return false;
    preferences[configKey] = jsonEncode(config);
    return _save();
  }

  Future<void> clearPreferences() async {
    final preferences = await _preferences;
    if (preferences == null) return;
    preferences.clear();
    await _save();
  }
}

final preferences = Preferences();