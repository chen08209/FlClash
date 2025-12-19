import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/models/selector.dart';
import 'package:isar_community/isar.dart';

class Version {
  static Version? _instance;

  Version._internal();

  factory Version() {
    _instance ??= Version._internal();
    return _instance!;
  }

  Future<void> migration(Config config, Isar isar) async {
    final version = await preferences.getVersion();
    if (version == 0) {
      await _oldToV1(config, isar);
      return;
    }
  }

  Future<void> _oldToV1(Config config, Isar isar) async {
    final configMap = await preferences.getConfigMap();
    if (configMap == null) {
      return;
    }
    Map<String, Object?> nextConfigMap = {};
    try {
      nextConfigMap = await oldToV1Task(VM2(a: configMap, b: isar));
    } catch (_) {}
    config = Config.fromJson(nextConfigMap);
    await preferences.setVersion(1);
  }
}

final version = Version();
