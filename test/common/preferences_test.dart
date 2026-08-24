import 'dart:convert';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sharedState = SharedState(
  stopTip: 'stop',
  startTip: 'start',
  currentProfileName: 'profile',
  stopText: 'stopped',
  onlyStatisticsProxy: true,
  crashlytics: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late SharedPreferences store;

  setUp(() async {
    store = await SharedPreferences.getInstance();
    await store.clear();
  });

  group('version', () {
    test('defaults to 0 when never written', () async {
      expect(await preferences.getVersion(), 0);
    });

    test('round-trips a written version', () async {
      await preferences.setVersion(7);

      expect(await preferences.getVersion(), 7);
    });
  });

  group('config', () {
    test('getConfig returns null when nothing is stored', () async {
      expect(await preferences.getConfig(), isNull);
    });

    test('saveConfig then getConfig round-trips the model', () async {
      const config = Config(
        themeProps: defaultThemeProps,
        currentProfileId: 42,
        overrideDns: true,
        excludeSSIDs: ['home'],
      );

      expect(await preferences.saveConfig(config), isTrue);
      final restored = await preferences.getConfig();

      expect(restored, isNotNull);
      expect(restored!.currentProfileId, 42);
      expect(restored.overrideDns, isTrue);
      expect(restored.excludeSSIDs, ['home']);
    });

    test('getConfigMap returns null for malformed JSON', () async {
      await store.setString(configKey, 'not-json');

      expect(await preferences.getConfigMap(), isNull);
    });

    test('getConfigMap returns null when the payload is not a map', () async {
      await store.setString(configKey, '123');

      expect(await preferences.getConfigMap(), isNull);
    });
  });

  group('clash config', () {
    test('getClashConfigMap returns null when nothing is stored', () async {
      expect(await preferences.getClashConfigMap(), isNull);
    });

    test('getClashConfigMap decodes a stored map', () async {
      await store.setString(clashConfigKey, json.encode({'mode': 'rule'}));

      expect(await preferences.getClashConfigMap(), {'mode': 'rule'});
    });

    test('getClashConfigMap returns null for malformed JSON', () async {
      await store.setString(clashConfigKey, '{oops');

      expect(await preferences.getClashConfigMap(), isNull);
    });

    test('clearClashConfig removes only the clash config entry', () async {
      await store.setString(clashConfigKey, json.encode({'mode': 'rule'}));
      await preferences.setVersion(3);

      await preferences.clearClashConfig();

      expect(await preferences.getClashConfigMap(), isNull);
      expect(await preferences.getVersion(), 3);
    });
  });

  test('saveShareState writes the encoded shared state', () async {
    await preferences.saveShareState(_sharedState);

    final raw = store.getString('sharedState');
    expect(raw, isNotNull);
    expect(
      SharedState.fromJson(json.decode(raw!) as Map<String, Object?>),
      _sharedState,
    );
  });

  test('clearPreferences empties every stored key', () async {
    await preferences.setVersion(9);
    await preferences.saveConfig(const Config(themeProps: defaultThemeProps));

    await preferences.clearPreferences();

    expect(await preferences.getVersion(), 0);
    expect(await preferences.getConfig(), isNull);
  });

  test('isInit resolves true once shared preferences are available', () async {
    expect(await preferences.isInit, isTrue);
  });
}
