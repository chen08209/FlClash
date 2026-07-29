import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class Preferences {
  static Preferences? _instance;
  Completer<SharedPreferences?> sharedPreferencesCompleter = Completer();

  Future<bool> get isInit async =>
      await sharedPreferencesCompleter.future != null;

  Preferences._internal() {
    SharedPreferences.getInstance()
        .then((value) => sharedPreferencesCompleter.complete(value))
        .onError((_, _) => sharedPreferencesCompleter.complete(null));
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  Future<int> getVersion() async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getInt('version') ?? 0;
  }

  Future<void> setVersion(int version) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setInt('version', version);
  }

  Future<void> saveShareState(SharedState shareState) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setString('sharedState', json.encode(shareState));
  }

  Future<Map<String, Object?>?> getConfigMap() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      final configString = preferences?.getString(configKey);
      if (configString == null) return null;
      final Map<String, Object?>? configMap = json.decode(configString);
      return configMap;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, Object?>?> getClashConfigMap() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      final clashConfigString = preferences?.getString(clashConfigKey);
      if (clashConfigString == null) return null;
      return json.decode(clashConfigString);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearClashConfig() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      await preferences?.remove(clashConfigKey);
      return;
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
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setString(configKey, json.encode(config)) ?? false;
  }

  Future<List<String>?> getStringList(String key) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setStringList(key, value) ?? false;
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setBool(key, value) ?? false;
  }

  Future<int?> getInt(String key) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setInt(key, value) ?? false;
  }

  Future<String?> getString(String key) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setString(key, value) ?? false;
  }

  Future<void> clearPreferences() async {
    final sharedPreferencesIns = await sharedPreferencesCompleter.future;
    await sharedPreferencesIns?.clear();
  }
}

final preferences = Preferences();
