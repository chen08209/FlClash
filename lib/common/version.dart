import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';

class Version {
  static Version? _instance;

  Version._internal();

  final currentVersion = 1;

  factory Version() {
    _instance ??= Version._internal();
    return _instance!;
  }

  Future<Config?> migration() async {
    final version = await preferences.getVersion();
    final configMap = await preferences.getConfigMap();
    if (configMap == null) {
      return null;
    }
    Config config = Config.fromJson(configMap);
    if (version == currentVersion) {
      return config;
    }
    if (version == 0) {
      config = await _oldToNow(config, configMap);
    }
    await preferences.setVersion(currentVersion);
    return config;
  }

  Future<Config> _oldToNow(
    Config config,
    Map<String, Object?> configMap,
  ) async {
    Map<String, Object?> nextConfigMap = {};
    try {
      nextConfigMap = await oldToNowTask(configMap);
    } catch (_) {}
    return Config.fromJson(nextConfigMap);
  }
}

final version = Version();
