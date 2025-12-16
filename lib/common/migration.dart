import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';

class Migration {
  static Migration? _instance;
  late int _oldVersion;

  Migration._internal();

  final currentVersion = 1;

  factory Migration() {
    _instance ??= Migration._internal();
    return _instance!;
  }

  Future<MigrationData> migrationIfNeeded(
    Map<String, Object?>? configMap,
  ) async {
    _oldVersion = await preferences.getVersion();
    MigrationData data = MigrationData(configMap: configMap);
    if (_oldVersion == 0 && configMap != null) {
      data = await _oldToNow(configMap);
    }
    await preferences.setVersion(currentVersion);
    return data;
  }

  Future<void> rollback() async {
    await preferences.setVersion(_oldVersion);
  }

  Future<MigrationData> _oldToNow(Map<String, Object?> configMap) async {
    return await oldToNowTask(configMap);
  }
}

final migration = Migration();
