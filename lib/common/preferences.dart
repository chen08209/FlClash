import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/boot_record.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/system_dns.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences prefixes every key it writes, so a file it has produced
/// has to lose the prefix before its own keys can be recognized, and a file
/// this app writes has to carry the prefix to stay the plugin's own file.
const _keyPrefix = 'flutter.';

String _prefixed(String key) => '$_keyPrefix$key';

String _unprefixed(String key) =>
    key.startsWith(_keyPrefix) ? key.substring(_keyPrefix.length) : key;

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
      if (!await file.exists()) {
        return {};
      }
      final content = await file.readAsString();
      if (content.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        throw const FormatException('Preferences file is not a JSON map');
      }
      final data = <String, Object?>{};
      for (final entry in decoded.entries) {
        data[_unprefixed(entry.key)] = entry.value;
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
      final encoded = {
        for (final entry in data.entries) _prefixed(entry.key): entry.value,
      };
      await file.safeWriteAsString(jsonEncode(encoded));
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
  /// Only a key this store loaded is ever removed on save, so a key another
  /// user of SharedPreferences owns survives a rewrite.
  Map<String, Object?> _loaded = {};

  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {for (final key in prefs.getKeys()) key: prefs.get(key)};
      _loaded = Map.of(data);
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
      final results = <Future<bool>>[];
      for (final key in _loaded.keys) {
        if (!data.containsKey(key)) {
          results.add(prefs.remove(key));
        }
      }
      for (final entry in data.entries) {
        results.add(_setValue(prefs, entry.key, entry.value));
      }
      _loaded = Map.of(data);
      return (await Future.wait(results)).every((result) => result);
    } catch (e) {
      commonPrint.log(
        'Failed to save preferences: $e',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  /// A value shared_preferences cannot type was never written by this app, so
  /// dropping it is not a failed write and must not fail the ones that were.
  Future<bool> _setValue(SharedPreferences prefs, String key, Object? value) {
    return switch (value) {
      int() => prefs.setInt(key, value),
      String() => prefs.setString(key, value),
      bool() => prefs.setBool(key, value),
      double() => prefs.setDouble(key, value),
      List<String>() => prefs.setStringList(key, value),
      _ => Future.value(true),
    };
  }
}

class Preferences {
  static Preferences? _instance;
  final Future<_PreferencesStore> _store;
  final Completer<Map<String, Object?>?> _preferencesCompleter = Completer();
  Future<bool> _lastSave = Future.value(true);

  Preferences._internal() : _store = _resolveStore() {
    _init();
  }

  Preferences._withStore(_PreferencesStore store)
    : _store = Future.value(store) {
    _init();
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  /// A `path` is a file store over that file, no path the platform store.
  @visibleForTesting
  static Preferences createForTest({String? path}) {
    return path == null
        ? Preferences._withStore(_SharedPreferencesStore())
        : Preferences._withStore(_FileStore(pathOverride: path));
  }

  /// shared_preferences writes into the system data directory, the one thing a
  /// portable build cannot carry with it, so it reads the file beside its data.
  static Future<_PreferencesStore> _resolveStore() async {
    if (system.isDesktop && appPath.isPortable) {
      return _FileStore();
    }
    return _SharedPreferencesStore();
  }

  Future<Map<String, Object?>?> get _preferences =>
      _preferencesCompleter.future;

  Future<bool> get isInit async => await _preferences != null;

  Future<void> _init() async {
    try {
      final store = await _store;
      _preferencesCompleter.complete(await store.load());
    } catch (e) {
      commonPrint.log(
        'Failed to load preferences: $e',
        logLevel: LogLevel.warning,
      );
      _preferencesCompleter.complete(null);
    }
  }

  Future<bool> _save() async {
    final preferences = await _preferences;
    if (preferences == null) return false;
    // Saves are chained so two writes cannot interleave in one file, and each
    // queued save carries a snapshot no older than the one before it.
    _lastSave = _lastSave.then((_) async {
      final store = await _store;
      return store.save(Map.of(preferences));
    });
    return _lastSave;
  }

  Future<bool> _write(String key, Object? value) async {
    final preferences = await _preferences;
    if (preferences == null) return false;
    preferences[key] = value;
    return _save();
  }

  Future<void> _remove(String key) async {
    final preferences = await _preferences;
    if (preferences == null) return;
    preferences.remove(key);
    await _save();
  }

  Future<int> getVersion() async {
    final preferences = await _preferences;
    final version = preferences?['version'];
    return version is num ? version.toInt() : 0;
  }

  Future<void> setVersion(int version) async {
    await _write('version', version);
  }

  Future<void> saveShareState(SharedState shareState) async {
    await _write('sharedState', jsonEncode(shareState));
  }

  Future<Map<String, Object?>?> getConfigMap() async {
    try {
      final preferences = await _preferences;
      final configString = preferences?[configKey] as String?;
      if (configString == null) return null;
      final Map<String, Object?>? configMap = jsonDecode(configString);
      return configMap;
    } catch (e) {
      commonPrint.log(
        'getConfigMap error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<Map<String, Object?>?> getClashConfigMap() async {
    try {
      final preferences = await _preferences;
      final clashConfigString = preferences?[clashConfigKey] as String?;
      if (clashConfigString == null) return null;
      return jsonDecode(clashConfigString) as Map<String, Object?>;
    } catch (e) {
      commonPrint.log(
        'getClashConfigMap error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<void> clearClashConfig() async {
    try {
      await _remove(clashConfigKey);
      return;
    } catch (e) {
      commonPrint.log(
        'clearClashConfig error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
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
    return _write(configKey, jsonEncode(config));
  }

  Future<SystemDnsRecord?> getSystemDnsRecord() async {
    try {
      final preferences = await _preferences;
      final raw = preferences?[systemDnsRecordKey] as String?;
      if (raw == null) {
        return null;
      }
      return SystemDnsRecord.fromJson(jsonDecode(raw));
    } catch (e) {
      commonPrint.log(
        'getSystemDnsRecord error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<void> saveSystemDnsRecord(SystemDnsRecord record) async {
    await _write(systemDnsRecordKey, jsonEncode(record));
  }

  Future<void> clearSystemDnsRecord() async {
    await _remove(systemDnsRecordKey);
  }

  Future<BootRecord?> getBootRecord() async {
    try {
      final preferences = await _preferences;
      final raw = preferences?[bootRecordKey] as String?;
      if (raw == null) {
        return null;
      }
      return BootRecord.fromJson(jsonDecode(raw));
    } catch (e) {
      commonPrint.log(
        'getBootRecord error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<void> saveBootRecord(BootRecord record) async {
    await _write(bootRecordKey, jsonEncode(record));
  }

  Future<void> clearPreferences() async {
    final preferences = await _preferences;
    if (preferences == null) return;
    preferences.clear();
    await _save();
  }
}

final preferences = Preferences();
