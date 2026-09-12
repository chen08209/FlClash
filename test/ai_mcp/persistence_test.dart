import 'dart:convert';

import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test(
    'local credential roundtrip stays out of Config and exported backup map',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(aiMcpStoreProvider);
      final token = AiMcpService.randomToken();
      final settings = <String, Object?>{'port': 17891, 'token': token};
      await store.save(settings);
      expect(await store.load(), settings);
      final config = container.read(configProvider);
      expect(jsonEncode(config.toJson()), isNot(contains(token)));
      expect(jsonEncode(config.toJson()), isNot(contains('aiMcpLocal')));
      await preferences.saveConfig(config);
      expect(
        jsonEncode(await preferences.getConfigMap()),
        isNot(contains(token)),
      );
    },
  );
}
