import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/selector.dart';

class Migration {
  static Migration? _instance;

  Migration._internal();

  final currentVersion = 1;

  factory Migration() {
    _instance ??= Migration._internal();
    return _instance!;
  }

  Future<MigrationData> migrationIfNeeded(
    Map<String, Object?>? configMap,
  ) async {
    final version = await preferences.getVersion();
    MigrationData data = MigrationData(configMap: configMap);
    if (version == 0 && configMap != null) {
      data = await _oldToNow(configMap);
    }
    await preferences.setVersion(currentVersion);
    return data;
  }

  Future<MigrationData> _oldToNow(Map<String, Object?> configMap) async {
    return await oldToNowTask(configMap);
  }
}

final migration = Migration();
